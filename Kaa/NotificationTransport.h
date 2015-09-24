//
//  NotificationTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 8/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_NotificationTransport_h
#define Kaa_NotificationTransport_h

#import <Foundation/Foundation.h>
#import "EndpointGen.h"
#import "NotificationProcessor.h"
#import "KaaTransport.h"

/**
 * KaaTransport for the Notification service.
 * Updates the Notification manager state.
 */
@protocol NotificationTransport <KaaTransport>

/**
 * Creates a new Notification request.
 *
 * @return new Notification request.
 * @see NotificationSyncRequest
 */
- (NotificationSyncRequest *)createNotificationRequest;

/**
 * Creates a new empty Notification request.
 *
 * @return new empty Notification request.
 * @see NotificationSyncRequest
 */
- (NotificationSyncRequest *)createEmptyNotificationRequest;

/**
 * Updates the state of the Notification manager according to the given response.
 *
 * @param response the response from the server.
 * @see NotificationSyncResponse
 */
- (void)onNotificationResponse:(NotificationSyncResponse *)response;

/**
 * Sets the given Notification processor.
 *
 * @param processor the Notification processor which to be set.
 * @see NotificationProcessor
 */
- (void)setNotificationProcessor:(id<NotificationProcessor>)processor;

/**
 * Notify about new subscription info.
 *
 * Will be called when one either subscribes or unsubscribes
 * on\from some optional topic(s).
 *
 * @param commands Info about subscription actions (subscribe/unsubscribe). <SubscriptionCommand>
 */
- (void)onSubscriptionChanged:(NSArray *)commands;

@end

#endif
