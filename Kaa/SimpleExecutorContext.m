//
//  SimpleExecutorContext.m
//  Kaa
//
//  Created by Aleksey Gutyro on 01.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "SimpleExecutorContext.h"
#import "KaaLogging.h"

#define SINGLE_THREAD 1

#define TAG @"SimpleExecutorContext >>>"

@interface SimpleExecutorContext ()

@property (nonatomic) NSInteger lifeCycleThreadCount;
@property (nonatomic) NSInteger apiThreadCount;
@property (nonatomic) NSInteger callbackThreadCount;
@property (nonatomic) NSInteger scheduledThreadCount;

@property (strong, nonatomic) NSOperationQueue *lifeCycleExecutor;
@property (strong, nonatomic) NSOperationQueue *apiExecutor;
@property (strong, nonatomic) NSOperationQueue *callBackExecutor;
@property (strong, nonatomic) NSOperationQueue *scheduledExecutor;

@end

@implementation SimpleExecutorContext

- (instancetype)init {
    return [self initWithlifeCycleThreadCount:SINGLE_THREAD
                            andApiThreadCount:SINGLE_THREAD
                       andCallbackThreadCount:SINGLE_THREAD
                      andScheduledThreadCount:SINGLE_THREAD];
}

- (instancetype)initWithlifeCycleThreadCount:(NSInteger)lifeCycleThreadCount
                           andApiThreadCount:(NSInteger)apiThreadCount
                      andCallbackThreadCount:(NSInteger)callbackThreadCount
                     andScheduledThreadCount:(NSInteger)scheduledThreadCount {
    self = [super init];
    if (self) {
        self.lifeCycleThreadCount   = lifeCycleThreadCount;
        self.apiThreadCount         = apiThreadCount;
        self.callbackThreadCount    = callbackThreadCount;
        self.scheduledThreadCount   = scheduledThreadCount;
    }
    return self;
}

- (void)initiate {
    DDLogDebug(@"%@ Creating executor services", TAG);
    self.lifeCycleExecutor = [[NSOperationQueue alloc] init];
    self.apiExecutor = [[NSOperationQueue alloc] init];
    self.callBackExecutor = [[NSOperationQueue alloc] init];
    self.scheduledExecutor = [[NSOperationQueue alloc] init];
    
    [self.lifeCycleExecutor setMaxConcurrentOperationCount:self.lifeCycleThreadCount];
    [self.apiExecutor setMaxConcurrentOperationCount:self.apiThreadCount];
    [self.callBackExecutor setMaxConcurrentOperationCount:self.callbackThreadCount];
    [self.scheduledExecutor setMaxConcurrentOperationCount:self.scheduledThreadCount];
}

- (void)stop {
    [self.lifeCycleExecutor cancelAllOperations];
    [self.apiExecutor cancelAllOperations];
    [self.callBackExecutor cancelAllOperations];
    [self.scheduledExecutor cancelAllOperations];
}

- (NSOperationQueue *)getLifeCycleExecutor {
    return self.lifeCycleExecutor;
}

- (NSOperationQueue *)getApiExecutor {
    return self.apiExecutor;
}

- (NSOperationQueue *)getCallbackExecutor {
    return self.callBackExecutor;
}

- (dispatch_queue_t)getSheduledExecutor {
    return [self.scheduledExecutor underlyingQueue];
}

@end
