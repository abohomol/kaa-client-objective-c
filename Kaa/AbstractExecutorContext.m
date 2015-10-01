//
//  AbstractExecutorContext.m
//  Kaa
//
//  Created by Aleksey Gutyro on 30.09.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "AbstractExecutorContext.h"
#import "KaaLogging.h"

#define TAG @"AbstractExecutorContext >>>"

#define DEFAULT_TIMEOUT     (5)
#define DEFAULT_TIMEUNIT    TIME_UNIT_SECONDS

@implementation AbstractExecutorContext


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeOut = DEFAULT_TIMEOUT;
        self.timeUnit = DEFAULT_TIMEUNIT;
    }
    return self;
}

- (instancetype) initWithTimeOut:(NSInteger)timeOut andTimeUnit:(TimeUnit)timeUnit {
    self = [super init];
    if (self) {
        self.timeOut = timeOut;
        self.timeUnit = timeUnit;
    }
    return self;
}

- (void) shutDownExecutor:(NSOperationQueue*)queue {
    
    if (!queue) {
        DDLogWarn(@"%@ Can't shutdown empty executor", TAG);
    }
    
    DDLogDebug(@"%@ Shutdown executor service", TAG);
    [queue cancelAllOperations];
    DDLogDebug(@"%@ Waiting for executor service to shutdown for %ld %u", TAG, (long)self.timeOut, self.timeUnit);
    @try {
        [queue cancelAllOperations];
    }
    @catch (NSException *exception) {
        DDLogWarn(@"%@ Interrupted while waiting for executor to shutdown. Reason: %@", TAG, exception.reason);
    }
}

- (NSOperationQueue *)getLifeCycleExecutor {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return nil;
}

- (NSOperationQueue *)getApiExecutor {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return nil;
}

- (NSOperationQueue *)getCallbackExecutor {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return nil;
}

- (dispatch_queue_t)getSheduledExecutor {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return nil;
}

- (void) stop {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
}

- (void) initiate {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
}


@end
