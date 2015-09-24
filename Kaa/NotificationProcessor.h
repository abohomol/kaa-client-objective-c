//
//  NotificationProcessor.h
//  Kaa
//
//  Created by Anton Bohomol on 8/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_NotificationProcessor_h
#define Kaa_NotificationProcessor_h

#import <Foundation/Foundation.h>
#import "EndpointGen.h"

/**
 * Used to process notifications.
 */
@protocol NotificationProcessor

/**
 * Called on topics' list update.
 *
 * @param list the new topics' list. <Topic>
 * @see Topic
 */
- (void)topicsListUpdated:(NSArray *)topics;

/**
 * Called when new notifications arrived.
 *
 * @param notifications the list of new notifications.
 * @see Notification
 */
- (void)notificationReceived:(NSArray *)notifications;

@end

#endif
