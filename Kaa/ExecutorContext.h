//
//  ExecutorContext.h
//  Kaa
//
//  Created by Anton Bohomol on 7/16/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_ExecutorContext_h
#define Kaa_ExecutorContext_h

#import <Foundation/Foundation.h>

/**
 * Responsible for creation of thread executor instances for SDK internal usage.
 * Implementation should not manage created executor life-cycle. Executors will be stopped during
 * "stop" procedure, thus executor instances should not be cached in context 
 * or context should check shutdown status before return of cached value.
 */
@protocol ExecutorContext

/**
 * Initialize executors.
 */
- (void)initiate;

/**
 * Stops executors.
 */
- (void)stop;

/**
 * Executes lifecycle events/commands of Kaa client.
 */
- (NSOperationQueue *)getLifeCycleExecutor;

/**
 * Executes user API calls to SDK client. For example, serializing of log
 * records before submit to transport.
 */
- (NSOperationQueue *)getApiExecutor;

/**
 * Executes callback methods provided by SDK client user.
 */
- (NSOperationQueue *)getCallbackExecutor;

/**
 * Executes scheduled tasks(periodically if needed) as log upload.
 */
- (dispatch_queue_t)getSheduledExecutor;

@end

#endif
