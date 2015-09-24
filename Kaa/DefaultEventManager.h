//
//  DefaultEventManager.h
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventManger.h"
#import "KaaClientState.h"
#import "ExecutorContext.h"
#import "EventTransport.h"

/**
 * Default <EventManager> implementation.
 */
@interface DefaultEventManager : NSObject <EventManager>

- (instancetype)initWith:(id<KaaClientState>)state
         executorContext:(id<ExecutorContext>)executorContext
          eventTransport:(id<EventTransport>)transport;

@end
