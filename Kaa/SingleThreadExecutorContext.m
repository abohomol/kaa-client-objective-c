//
//  SingleThreadExecutorContext.m
//  Kaa
//
//  Created by Aleksey Gutyro on 01.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "SingleThreadExecutorContext.h"
#import "KaaLogging.h"

#define TAG @"SingleThreadExecutorContext >>>"

@interface SingleThreadExecutorContext ()

@property (nonatomic) NSOperationQueue *singleThreadExecutor;

@end

@implementation SingleThreadExecutorContext

- (void)initiate
{
    DDLogDebug(@"%@ Creating executor service", TAG);
    [self.singleThreadExecutor setName:@"singleThreadExecutor queue"];
    DDLogDebug(@"%@ Created executor service", TAG);
}

- (void) stop {
    [self.singleThreadExecutor cancelAllOperations];
}

- (NSOperationQueue*) getLifeCycleExecutor {
    return self.singleThreadExecutor;
}

- (NSOperationQueue*) getApiExecutor {
    return self.singleThreadExecutor;
}

- (NSOperationQueue*) getCallbackExecutor {
    return self.singleThreadExecutor;
}

- (dispatch_queue_t) getSheduledExecutor {
    return [self.singleThreadExecutor underlyingQueue];
}

@end
