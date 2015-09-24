//
//  CommonEventDelegates.h
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_CommonEventDelegates_h
#define Kaa_CommonEventDelegates_h

#import <Foundation/Foundation.h>
#import "EndpointGen.h"
#import "EndpointKeyHash.h"

/**
 * Callback interface for attached endpoint list change notifications
 */
@protocol ChangedAttachedEndpointListDelegate

/**
 * Callback on attached endpoints list changed
 *
 * @param attachedEndpoints <EndpointAccessToken, EndpointKeyHash> as key-value
 *
 */
- (void)onAttachedEndpointListChanged:(NSDictionary *)attachedEndpoints;

@end


/**
 * Callback interface for attached endpoint notifications.
 *
 * Use this interface to receive result of next operations:
 *
 * Attach endpoint to user by <EndpointAccessToken>
 *
 * Once result from Operations server is received, listener is notified with
 * string representation of operation name, result of the operation <SyncResponseResultType>
 * and additional data if available.
 */
@protocol OnAttachEndpointOperationDelegate

/**
 * Callback on endpoint attach response
 *
 * NOTE: resultContext is not null for endpoint attach operation
 * and contains <EndpointKeyHash> object with key hash of attached endpoint.
 *
 * resultContext - additional data of operation result, may be null.
 * For AttachEndpoint operation is populated with <EndpointKeyHash> of attached endpoint.
 */
- (void)onAttach:(SyncResponseResultType)result resultContext:(EndpointKeyHash *)resultContext;

@end


/**
 * Callback interface for detached endpoint notifications.
 *
 * Use this interface to receive result of next operations:
 * Detach endpoint from user by <EndpointKeyHash>
 
 * Once result from Operations server is received, listener is notified with
 * string representation of operation name, result of the operation <SyncResponseResultType>
 * and additional data if available.
 */
@protocol OnDetachEndpointOperationDelegate

/**
 * Callback on endpoint detach response
 */
- (void)onDetach:(SyncResponseResultType)result;

@end


/**
 * Retrieves result of user authentication
 *
 * Use this listener to retrieve result of attaching current endpoint to user.
 */
@protocol UserAttachDelegate

/**
 * Called when auth result is retrieved from operations server.
 */
- (void)onAttachResult:(UserAttachResponse *)response;

@end


/**
 * Callback interface for attached to user notifications.
 *
 * Provide listener implementation to <EndpointRegistrationManager> to
 * retrieve notification when current endpoint is attached to user by another endpoint.
 */
@protocol AttachEndpointToUserDelegate

/**
 * Callback on current endpoint is attached to user.
 */
- (void)onAttachedToUser:(NSString *)userExternalId token:(NSString *)endpointAccessToken;

@end


/**
 * Callback interface for detached from user notifications.
 *
 * Provide listener implementation to <EndpointRegistrationManager> to
 * retrieve notification when current endpoint is detached from user by another endpoint.
 */
@protocol DetachEndpointFromUserDelegate

/**
 * Callback on current endpoint is detached from user.
 */
- (void)onDetachedFromUser:(NSString *)endpointAccessToken;

@end


/**
 * Listener interface for retrieving endpoints list
 * which supports requested event class FQNs
 */
@protocol FindEventListenersDelegate

/**
 * Called when resolve was successful
 *
 * eventListeners - list of endpoints <String>
 */
- (void)onEventListenersReceived:(NSArray *)eventListeners;

// TODO: add some kind of error reason

/**
 * Called when some error occured during resolving endpoints via event class FQNs.
 */
- (void)onRequestFailed;

@end


#endif
