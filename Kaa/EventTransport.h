//
//  EventTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_EventTransport_h
#define Kaa_EventTransport_h

#import <Foundation/Foundation.h>
#import "KaaTransport.h"
#import "EndpointGen.h"
#import "EventManger.h"

/**
 * <KaaTransport> for the Event service.
 * Updates the Event manager state.
 */
@protocol EventTransport <KaaTransport>

/**
 * Creates the Event request.
 *
 * @param requestId - new request id of the SyncRequest.
 * @return new Event request.
 * @see EventSyncRequest
 */
- (EventSyncRequest *)createEventRequest:(NSInteger)requestId;

/**
 * Updates the state of the Event manager according to the given response.
 *
 * @param response - the response from the server.
 * @see EventSyncResponse
 */
- (void)onEventResponse:(EventSyncResponse *)response;

/**
 * Notifies event transport about response from server for specific request.
 *
 * @param requestId - request id of the corresponding SyncRequest
 */
- (void)onSyncResposeIdReceived:(NSInteger)requestId;

/**
 * Sets the given Event manager.
 *
 * @param manager - the Event manager which is going to be set.
 * @see EventManager
 */
- (void)setEventManager:(id<EventManager>)manager;

- (void)blockEventManager;

- (void)releaseEventManager;

@end

#endif
