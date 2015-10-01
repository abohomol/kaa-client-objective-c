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

@property (nonatomic) NSOperationQueue *lifeCycleExecutor;
@property (nonatomic) NSOperationQueue *apiExecutor;
@property (nonatomic) NSOperationQueue *callBackExecutor;
@property (nonatomic) NSOperationQueue *scheduledExecutor;

@end

@implementation SimpleExecutorContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [self initWithlifeCycleThreadCount:SINGLE_THREAD
                                andApiThreadCount:SINGLE_THREAD
                           andCallbackThreadCount:SINGLE_THREAD
                          andScheduledThreadCount:SINGLE_THREAD];
    }
    return self;
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

- (void) initiate {
    DDLogDebug(@"%@ Creating executor services", TAG);
    [self.lifeCycleExecutor setName:@"lifeCycleExecutor queue"];
    [self.apiExecutor setName:@"apiExecutor queue"];
    [self.callBackExecutor setName:@"callBackExecutor queue"];
    [self.scheduledExecutor setName:@"scheduledExecutor queue"];
    
    [self.lifeCycleExecutor setMaxConcurrentOperationCount:self.lifeCycleThreadCount];
    [self.apiExecutor setMaxConcurrentOperationCount:self.apiThreadCount];
    [self.callBackExecutor setMaxConcurrentOperationCount:self.callbackThreadCount];
    [self.scheduledExecutor setMaxConcurrentOperationCount:self.scheduledThreadCount];
}

- (void) stop {
    [self.lifeCycleExecutor cancelAllOperations];
    [self.apiExecutor cancelAllOperations];
    [self.callBackExecutor cancelAllOperations];
    [self.scheduledExecutor cancelAllOperations];
}

@end
