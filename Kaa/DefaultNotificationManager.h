//
//  DefaultNotificationManager.h
//  Kaa
//
//  Created by Anton Bohomol on 8/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationProcessor.h"
#import "NotificationManager.h"
#import "NotificationTransport.h"
#import "KaaClientState.h"
#import "ExecutorContext.h"

@interface DefaultNotificationManager : NSObject <NotificationManager,NotificationProcessor>

- (instancetype)initWith:(id<KaaClientState>)state
         executorContext:(id<ExecutorContext>)context
   notificationTransport:(id<NotificationTransport>)transport;

@end
