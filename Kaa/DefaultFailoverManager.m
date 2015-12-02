/*
 * Copyright 2014-2015 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "DefaultFailoverManager.h"
#import "KaaLogging.h"

#define TAG @"DefaultFailoverManager >>>"

// all timeout values are specified in seconds
#define DEFAULT_FAILURE_RESOLUTION_TIMEOUT      (10)
#define DEFAULT_BOOTSTRAP_SERVERS_RETRY_PERIOD  (2)
#define DEFAULT_OPERATION_SERVERS_RETRY_PERIOD  (2)
#define DEFAULT_NO_CONNECTIVITY_RETRY_PERIOD    (5)
#define DEFAULT_TIME_UNIT                       TIME_UNIT_SECONDS

@interface Resolution : NSOperation

@property (nonatomic,weak) DefaultFailoverManager *failoverMgr;
@property (nonatomic,weak) id<TransportConnectionInfo> info;

- (instancetype)initWithManager:(DefaultFailoverManager *)manager andInfo:(id<TransportConnectionInfo>)info;

@end

@interface AccessPointIdResolution : NSObject

@property (nonatomic, readonly) int accessPointId;
@property (nonatomic) long resolutionTime;          //in milliseconds
@property (nonatomic,strong) Resolution *resolution;

- (instancetype)initWithAccessId:(int)accessId andResolution:(Resolution *)resolution;

@end

@interface DefaultFailoverManager ()

@property (nonatomic) NSInteger failureResolutionTimeout;
@property (nonatomic) NSInteger bootstrapServersRetryPeriod;
@property (nonatomic) NSInteger operationsServersRetryPeriod;
@property (nonatomic) NSInteger noConnectivityRetryPeriod;
@property (nonatomic) TimeUnit  timeUnit;

@property (nonatomic,strong) id<KaaChannelManager> kaaChannelMgr;
@property (nonatomic,strong) id<ExecutorContext> executorContext;

@property (nonatomic,strong) NSMutableDictionary *resolutionProgressMap;

- (void)cancelCurrentFailResolution:(AccessPointIdResolution *)resolution;

@end

@implementation DefaultFailoverManager

- (instancetype)initWithChannelManager:(id<KaaChannelManager>)channelMgr context:(id<ExecutorContext>)context {
    return [self initWithChannelManager:channelMgr
                                context:context
               failureResolutionTimeout:DEFAULT_FAILURE_RESOLUTION_TIMEOUT
            bootstrapServersRetryPeriod:DEFAULT_BOOTSTRAP_SERVERS_RETRY_PERIOD
           operationsServersRetryPeriod:DEFAULT_OPERATION_SERVERS_RETRY_PERIOD
              noConnectivityRetryPeriod:DEFAULT_NO_CONNECTIVITY_RETRY_PERIOD
                               timeUnit:DEFAULT_TIME_UNIT];
}

- (instancetype)initWithChannelManager:(id<KaaChannelManager>)channelMgr
                               context:(id<ExecutorContext>)context
              failureResolutionTimeout:(NSInteger)frTimeout
           bootstrapServersRetryPeriod:(NSInteger)btRetryPeriod
          operationsServersRetryPeriod:(NSInteger)opRetryPeriod
             noConnectivityRetryPeriod:(NSInteger)noConnRetryPeriod
                              timeUnit:(TimeUnit)timeUnit {
    self = [super init];
    if (self) {
        self.kaaChannelMgr = channelMgr;
        self.executorContext = context;
        self.failureResolutionTimeout = frTimeout;
        self.bootstrapServersRetryPeriod = btRetryPeriod;
        self.operationsServersRetryPeriod = opRetryPeriod;
        self.noConnectivityRetryPeriod = noConnRetryPeriod;
        self.timeUnit = timeUnit;
        
        self.resolutionProgressMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)onServerFailed:(id<TransportConnectionInfo>)connectionInfo {
    @synchronized(self) {
        
        if (!connectionInfo) {
            DDLogWarn(@"%@ Server failed, but connection info is nil, can't resolve", TAG);
            return;
        } else {
            DDLogInfo(@"%@ Server [%i, %i] failed", TAG, [connectionInfo serverType], [connectionInfo accessPointId]);
        }
        
        long currentResolutionTime = -1;
        NSNumber *serverTypeKey = [NSNumber numberWithInt:[connectionInfo serverType]];
        AccessPointIdResolution *pointResolution = [self.resolutionProgressMap objectForKey:serverTypeKey];
        if (pointResolution) {
            currentResolutionTime = pointResolution.resolutionTime;
            if (pointResolution.accessPointId == [connectionInfo accessPointId]
                && pointResolution.resolution
                && ([[NSDate date] timeIntervalSince1970] * 1000) < currentResolutionTime) {
                DDLogDebug(@"%@ Resolution is in progress for %@ server", TAG, connectionInfo);
                return;
            } else if (pointResolution.resolution) {
                DDLogVerbose(@"%@ Cancelling old resolution: %@", TAG, pointResolution);
                [self cancelCurrentFailResolution:pointResolution];
            }
        }
        
        DDLogVerbose(@"%@ Next fail resolution will be available in [delay:%li timeunit:%i]",
                     TAG, (long)self.failureResolutionTimeout, self.timeUnit);
        
        Resolution *resolution = [[Resolution alloc] initWithManager:self andInfo:connectionInfo];
        
        long secondsTimeout = [TimeUtils convert:self.failureResolutionTimeout from:self.timeUnit to:TIME_UNIT_SECONDS];
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondsTimeout * NSEC_PER_SEC));
        dispatch_after(delay, [self.executorContext getSheduledExecutor], ^{
            [resolution start];
        });
        
        [self.kaaChannelMgr onServerFailed:connectionInfo];
        
        long updatedResolutionTime = pointResolution ?  pointResolution.resolutionTime : currentResolutionTime;
        AccessPointIdResolution *newPointResolution =
        [[AccessPointIdResolution alloc] initWithAccessId:[connectionInfo accessPointId] andResolution:resolution];
        
        if (updatedResolutionTime != currentResolutionTime) {
            newPointResolution.resolutionTime = updatedResolutionTime;
        }
        
        [self.resolutionProgressMap setObject:newPointResolution
                                       forKey:[NSNumber numberWithInt:[connectionInfo serverType]]];
    }
}

- (void)onServerChanged:(id<TransportConnectionInfo>)connectionInfo {
    @synchronized(self) {
        if (!connectionInfo) {
            DDLogWarn(@"%@ Server has changed, but its connection info is nil, can't resolve", TAG);
            return;
        } else {
            DDLogVerbose(@"%@ Server [%i, %i] has changed", TAG, [connectionInfo serverType], [connectionInfo accessPointId]);
        }
        
        NSNumber *serverTypeKey = [NSNumber numberWithInt:[connectionInfo serverType]];
        AccessPointIdResolution *pointResolution = [self.resolutionProgressMap objectForKey:serverTypeKey];
        if (!pointResolution) {
            AccessPointIdResolution *newPointResolution =
            [[AccessPointIdResolution alloc] initWithAccessId:[connectionInfo accessPointId] andResolution:nil];
            [self.resolutionProgressMap setObject:newPointResolution forKey:serverTypeKey];
        } else if (pointResolution.accessPointId != [connectionInfo accessPointId]) {
            if (pointResolution.resolution) {
                DDLogVerbose(@"%@ Cancelling fail resolution: %@", TAG, pointResolution);
                [self cancelCurrentFailResolution:pointResolution];
            }
            AccessPointIdResolution *newPointResolution =
            [[AccessPointIdResolution alloc] initWithAccessId:[connectionInfo accessPointId] andResolution:nil];
            [self.resolutionProgressMap setObject:newPointResolution forKey:serverTypeKey];
        } else {
            DDLogDebug(@"%@ Same server [%@] is used, nothing has changed", TAG, connectionInfo);
        }
    }
}

- (void)onServerConnected:(id<TransportConnectionInfo>)connectionInfo {
    @synchronized(self) {
        DDLogVerbose(@"%@ Server %@ has connected", TAG, connectionInfo);
        if (!connectionInfo) {
            DDLogWarn(@"%@ Server connection info is nil, can't resolve", TAG);
            return;
        }
        
        NSNumber *serverTypeKey = [NSNumber numberWithInt:[connectionInfo serverType]];
        AccessPointIdResolution *pointResolution = [self.resolutionProgressMap objectForKey:serverTypeKey];
        if (!pointResolution) {
            DDLogVerbose(@"%@ Server hasn't been set (failover resolution has happened), new server %@ can't be connected",
                         TAG, connectionInfo);
        } else if (pointResolution.resolution
                   && pointResolution.accessPointId == [connectionInfo accessPointId]) {
            DDLogVerbose(@"%@ Cancelling fail resolution: %@", TAG, pointResolution);
            [self cancelCurrentFailResolution:pointResolution];
        } else if (pointResolution.resolution) {
            DDLogDebug(@"%@ Connection for outdated accessPointId: %i was received - ignoring. New accessPointId: %i",
                       TAG, [connectionInfo accessPointId], pointResolution.accessPointId);
        } else {
            DDLogVerbose(@"%@ There is no current resolution in progress, connected to the same server: %@",
                         TAG, connectionInfo);
        }
    }
}

- (FailoverDecision *)onFailover:(FailoverStatus)status {
    @synchronized(self) {
        DDLogInfo(@"%@ Applying failover strategy for status: %i", TAG, status);
        NSNumber *serverTypeKey = nil;
        switch (status) {
            case FAILOVER_STATUS_BOOTSTRAP_SERVERS_NA:
            {
                serverTypeKey = [NSNumber numberWithInt:SERVER_BOOTSTRAP];
                AccessPointIdResolution *btResolution = [self.resolutionProgressMap objectForKey:serverTypeKey];
                long period = [TimeUtils convert:self.bootstrapServersRetryPeriod
                                            from:self.timeUnit
                                              to:TIME_UNIT_MILLISECONDS];
                if (btResolution) {
                    btResolution.resolutionTime = [[NSDate date] timeIntervalSince1970] * 1000 + period;
                }
                return [[FailoverDecision alloc] initWithFailoverAction:FAILOVER_ACTION_RETRY
                                              retryPeriodInMilliseconds:period];
            }
                break;
            case FAILOVER_STATUS_CURRENT_BOOTSTRAP_SERVER_NA:
            {
                serverTypeKey = [NSNumber numberWithInt:SERVER_BOOTSTRAP];
                AccessPointIdResolution *btResolution = [self.resolutionProgressMap objectForKey:serverTypeKey];
                long period = [TimeUtils convert:self.bootstrapServersRetryPeriod
                                            from:self.timeUnit
                                              to:TIME_UNIT_MILLISECONDS];
                if (btResolution) {
                    btResolution.resolutionTime = [[NSDate date] timeIntervalSince1970] * 1000 + period;
                }
                return [[FailoverDecision alloc] initWithFailoverAction:FAILOVER_ACTION_USE_NEXT_BOOTSTRAP
                                              retryPeriodInMilliseconds:period];
            }
                break;
            case FAILOVER_STATUS_NO_OPERATION_SERVERS_RECEIVED:
            {
                serverTypeKey = [NSNumber numberWithInt:SERVER_BOOTSTRAP];
                AccessPointIdResolution *btResolution = [self.resolutionProgressMap objectForKey:serverTypeKey];
                if (btResolution) {
                    btResolution.resolutionTime = [[NSDate date] timeIntervalSince1970] * 1000;
                }
                long period = [TimeUtils convert:self.bootstrapServersRetryPeriod
                                            from:self.timeUnit
                                              to:TIME_UNIT_MILLISECONDS];
                return [[FailoverDecision alloc] initWithFailoverAction:FAILOVER_ACTION_USE_NEXT_BOOTSTRAP
                                              retryPeriodInMilliseconds:period];
            }
                break;
            case FAILOVER_STATUS_OPERATION_SERVERS_NA:
            {
                serverTypeKey = [NSNumber numberWithInt:SERVER_OPERATIONS];
                AccessPointIdResolution *opResolution = [self.resolutionProgressMap objectForKey:serverTypeKey];
                long period = [TimeUtils convert:self.operationsServersRetryPeriod
                                            from:self.timeUnit
                                              to:TIME_UNIT_MILLISECONDS];
                if (opResolution) {
                    opResolution.resolutionTime = [[NSDate date] timeIntervalSince1970] * 1000 + period;
                }
                return [[FailoverDecision alloc] initWithFailoverAction:FAILOVER_ACTION_RETRY
                                              retryPeriodInMilliseconds:period];
            }
                break;
            case FAILOVER_STATUS_NO_CONNECTIVITY:
            {
                long period = [TimeUtils convert:self.noConnectivityRetryPeriod
                                            from:self.timeUnit
                                              to:TIME_UNIT_MILLISECONDS];
                return [[FailoverDecision alloc] initWithFailoverAction:FAILOVER_ACTION_RETRY
                                              retryPeriodInMilliseconds:period];
            }
                break;
            default:
                return [[FailoverDecision alloc] initWithFailoverAction:FAILOVER_ACTION_NOOP];
                break;
        }
    }
}

- (void)cancelCurrentFailResolution:(AccessPointIdResolution *)pointResolution {
    if (pointResolution.resolution) {
        [pointResolution.resolution cancel];
        pointResolution.resolution = nil;
    } else {
        DDLogVerbose(@"%@ Current resolution is nil, can't cancel", TAG);
    }
}

@end



@implementation Resolution

- (instancetype)initWithManager:(DefaultFailoverManager *)manager andInfo:(id<TransportConnectionInfo>)info {
    self = [super init];
    if (self) {
        self.failoverMgr = manager;
        self.info = info;
    }
    return self;
}

- (void)main {
    if (!self.isCancelled || !self.isFinished) {
        DDLogDebug(@"%@ Removing server %@ from resolution map for type: %i", TAG, self.info, [self.info serverType]);
        [self.failoverMgr.resolutionProgressMap removeObjectForKey:[NSNumber numberWithInt:[self.info serverType]]];
    }
}

@end



@implementation AccessPointIdResolution

- (instancetype)initWithAccessId:(int)accessId andResolution:(Resolution *)resolution {
    self = [super init];
    if (self) {
        _accessPointId = accessId;
        self.resolution = resolution;
        self.resolutionTime = NSIntegerMax;
    }
    return self;
}

- (NSUInteger)hash {
    NSUInteger result = self.accessPointId;
    return 31 * result + (self.resolution ? [self.resolution hash] : 0);
}

- (BOOL)isEqual:(id)object {
    if ([self isEqual:object]) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return false;
    }
    AccessPointIdResolution *pointResolution = (AccessPointIdResolution *)object;
    if (self.accessPointId != pointResolution.accessPointId) {
        return NO;
    }
    if (self.resolution != nil
        ? ![self.resolution isEqual:pointResolution.resolution]
        : pointResolution.resolution != nil) {
        return NO;
    }
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"AccessPointIdResolution [accessPointId:%i resolutionTime:%li resolution:%@]",
            self.accessPointId, self.resolutionTime, self.resolution];
}

@end
