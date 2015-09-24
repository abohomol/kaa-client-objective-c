//
//  EndpointRegistrationProcessor.h
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_EndpointRegistrationProcessor_h
#define Kaa_EndpointRegistrationProcessor_h

#import <Foundation/Foundation.h>
#import "EndpointGen.h"

/**
 * This processor that applies the endpoint registration
 * updates received from the remote server.
 */
@protocol EndpointRegistrationProcessor

/**
 * Retrieves current attach requests.
 *
 * @return the map <NSNumber, EndpointAccessToken> (key-value) of access tokens.
 */
- (NSDictionary *)getAttachEndpointRequests;

/**
 * Retrieves current detach requests.
 *
 * @return the map <NSNumber, EndpointKeyHash> (key-value) of endpoint key hashes.
 */
- (NSDictionary *)getDetachEndpointRequests;

/**
 * Retrieves the user attach request.
 *
 * @return the user attach request.
 */
- (UserAttachRequest *)getUserAttachRequest;

/**
 * Updates the manager's state.
 *
 * @param attachResponses - the list of attach responses. <EndpointAttachResponse>
 * @param detachResponses - the list of detach responses. <EndpointDetachResponse>
 * @param userResponse - the user attach response.
 */
- (void)onUpdate:(NSArray *)attachResponses detachResponses:(NSArray *)detachResponses
    userResponse:(UserAttachResponse *)userResponse
userAttachNotification:(UserAttachNotification *)attachNotification
userDetachNotification:(UserDetachNotification *)detachNotification;

@end

#endif
