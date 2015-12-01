//
//  AbstractLogCollector.m
//  Kaa
//
//  Created by Anton Bohomol on 8/24/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AbstractLogCollector.h"
#import "DefaultLogUploadStrategy.h"
#import "MemLogStorage.h"
#import "LogFailoverCommand.h"
#import "KaaChannelManager.h"
#import "FailoverManager.h"
#import "KaaLogging.h"

#define TAG @"AbstractLogCollector >>>"

@interface AbstractLogCollector () <LogFailoverCommand>

@property (nonatomic,strong) id<LogUploadStrategy> strategy;
@property (nonatomic,strong) id<KaaChannelManager> channelManager;
@property (nonatomic,strong) id<LogTransport> transport;
@property (nonatomic,strong) id<FailoverManager> failoverManager;
@property (nonatomic,strong) NSMutableSet *timeouts;
@property (nonatomic,strong) NSLock *timeoutsLock;
@property (atomic) BOOL uploadCheckInProgress;
@property (nonatomic,strong) NSLock *uploadCheckLock;
@property (nonatomic,strong) NSObject *uploadCheckGuard;   //variable to sync

- (void)checkDeliveryTimeout:(int32_t)bucketId;
- (void)processUploadDecision:(LogUploadStrategyDecision)decision;

@end

@implementation AbstractLogCollector

- (instancetype)initWith:(id<LogTransport>)transport
         executorContext:(id<ExecutorContext>)executorContext
          channelManager:(id<KaaChannelManager>)channelManager
         failoverManager:(id<FailoverManager>)failoverManager {
    self = [super init];
    if (self) {
        self.strategy = [[DefaultLogUploadStrategy alloc] initWithDefaults];
        self.storage = [[MemLogStorage alloc] initWithBucketSize:[self.strategy getBatchSize] bucketRecordCount:[self.strategy getBatchCount]];
        self.channelManager = channelManager;
        self.transport = transport;
        _executorContext = executorContext;
        self.failoverManager = failoverManager;
        self.timeouts = [NSMutableSet set];
        self.timeoutsLock = [[NSLock alloc] init];
        self.uploadCheckInProgress = NO;
        self.uploadCheckLock = [[NSLock alloc] init];
        self.uploadCheckGuard = [[NSObject alloc] init];
    }
    return self;
}

- (void)setStrategy:(id<LogUploadStrategy>)strategy {
    if (!strategy) {
        [NSException raise:NSInvalidArgumentException format:@"%@ Strategy is nil!", TAG];
    }
    _strategy = strategy;
    DDLogInfo(@"%@ New log upload strategy was set: %@", TAG, strategy);
}

- (void)setStorage:(id<LogStorage>)storage {
    if (!storage) {
        [NSException raise:NSInvalidArgumentException format:@"%@ Storage is nil!", TAG];
    }
    _storage = storage;
    DDLogInfo(@"%@ New log storage was set: %@", TAG, storage);
}

- (void)fillSyncRequest:(LogSyncRequest *)request {
    LogBlock *group = nil;
    if ([[self.storage getStatus] getRecordCount] == 0) {
        DDLogDebug(@"%@ Log storage is empty", TAG);
        return;
    }
    group = [self.storage getRecordBlock:[self.strategy getBatchSize] batchCount:[self.strategy getBatchCount]];
    if (group) {
        NSArray *recordList = group.logRecords;
        if ([recordList count] > 0) {
            DDLogVerbose(@"%@ Sending %li log records", TAG, (long)[recordList count]);
            NSMutableArray *logs = [NSMutableArray array];
            for (LogRecord *record in recordList) {
                LogEntry *logEntry = [[LogEntry alloc] init];
                logEntry.data = [NSData dataWithData:record.data];
                [logs addObject:logEntry];
            }
            request.requestId = group.blockId;
            request.logEntries = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_BRANCH_0 andData:logs];
            DDLogInfo(@"%@ Adding following bucket id [%i] for timeout tracking", TAG, group.blockId);
            [self.timeoutsLock lock];
            [self.timeouts addObject:[NSNumber numberWithLong:group.blockId]];
            [self.timeoutsLock unlock];
            
            __weak typeof(self)weakSelf = self;
            __block LogBlock *timeoutGroup = group;
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.strategy getTimeout] * NSEC_PER_SEC));
            dispatch_after(delay, [self.executorContext getSheduledExecutor], ^{
                [weakSelf checkDeliveryTimeout:timeoutGroup.blockId];
            });
        }
    } else {
        DDLogWarn(@"%@ Log group is nil: log group size is too small", TAG);
    }
}

- (void)onLogResponse:(LogSyncResponse *)response {
    @synchronized (self) {
        if (response.deliveryStatuses && response.deliveryStatuses.branch == KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_BRANCH_0) {
            BOOL isAlreadyScheduled = NO;
            NSArray *deliveryStatuses = response.deliveryStatuses.data;
            for (LogDeliveryStatus *status in deliveryStatuses) {
                if (status.result == SYNC_RESPONSE_RESULT_TYPE_SUCCESS) {
                    [self.storage removeRecordBlock:status.requestId];
                } else {
                    [self.storage notifyUploadFailed:status.requestId];
                    __weak typeof(self) weakSelf = self;
                    [[self.executorContext getCallbackExecutor] addOperationWithBlock:^{
                        [weakSelf.strategy onFailure:weakSelf errorCode:[((NSNumber *)status.errorCode.data) intValue]];
                    }];
                    isAlreadyScheduled = YES;
                }
                DDLogInfo(@"%@ Removing bucket id from timeouts: %i", TAG, status.requestId);
                [self.timeoutsLock lock];
                [self.timeouts removeObject:[NSNumber numberWithLong:status.requestId]];
                [self.timeoutsLock unlock];
            }
            if (!isAlreadyScheduled) {
                [self processUploadDecision:[self.strategy isUploadNeeded:[self.storage getStatus]]];
            }
        }
    }
}

- (void)stop {
    [self.storage close];
}

- (void)processUploadDecision:(LogUploadStrategyDecision)decision {
    switch (decision) {
        case LOG_UPLOAD_STRATEGY_DECISION_UPLOAD:
            [self.transport sync];
            break;
        case LOG_UPLOAD_STRATEGY_DECISION_NOOP:
            if ([self.strategy getUploadCheckPeriod] > 0 && [[self.storage getStatus] getRecordCount] > 0) {
                [self scheduleUploadCheck];
            }
            break;
        default:
            break;
    }
}

- (void)scheduleUploadCheck {
    DDLogVerbose(@"%@ Attempt to execute upload check: %i", TAG, self.uploadCheckInProgress);
    @synchronized(self.uploadCheckGuard) {
        if (!self.uploadCheckInProgress) {
            DDLogVerbose(@"%@ Scheduling upload check with timeout: %li", TAG, (long)[self.strategy getUploadCheckPeriod]);
            self.uploadCheckInProgress = YES;
            __weak typeof(self)weakSelf = self;
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.strategy getUploadCheckPeriod] * NSEC_PER_SEC));
            dispatch_after(delay, [self.executorContext getSheduledExecutor], ^{
                
                @synchronized(self.uploadCheckGuard) {
                    weakSelf.uploadCheckInProgress = NO;
                }
                
                [weakSelf uploadIfNeeded];
            });
        } else {
            DDLogVerbose(@"%@ Upload check is already scheduled!", TAG);
        }
    }
}

- (void)checkDeliveryTimeout:(int32_t)bucketId {
    DDLogDebug(@"%@ Checking for a delivery timeout of the bucket with id: [%li]", TAG, (long)bucketId);
    [self.timeoutsLock lock];
    BOOL isTimeout = NO;
    if ([self.timeouts containsObject:[NSNumber numberWithLong:bucketId]]) {
        [self.timeouts removeObject:[NSNumber numberWithLong:bucketId]];
        isTimeout = YES;
    }
    [self.timeoutsLock unlock];
    
    if (isTimeout) {
        DDLogInfo(@"%@ Log delivery timeout detected for the bucket with id: [%li]", TAG, (long)bucketId);
        [self.storage notifyUploadFailed:bucketId];
        __weak typeof(self)weakSelf = self;
        [[self.executorContext getCallbackExecutor] addOperationWithBlock:^{
            [weakSelf.strategy onTimeout:weakSelf];
        }];
    } else {
        DDLogVerbose(@"%@ No log delivery timeout for the bucket with id [%li] was detected", TAG, (long)bucketId);
    }
}

- (void)uploadIfNeeded {
    [self processUploadDecision:[self.strategy isUploadNeeded:[self.storage getStatus]]];
}

- (void)switchAccessPoint {
    id<TransportConnectionInfo> server = [self.channelManager getActiveServer:TRANSPORT_TYPE_LOGGING];
    if (server) {
        [self.failoverManager onServerFailed:server];
    } else {
        DDLogWarn(@"%@ Failed to switch Operation server. No channel is used for logging transport", TAG);
    }
}

- (void)retryLogUpload {
    [self uploadIfNeeded];
}

- (void)retryLogUpload:(int32_t)delay {
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), [self.executorContext getSheduledExecutor], ^{
        [weakSelf uploadIfNeeded];
    });
}

@end
