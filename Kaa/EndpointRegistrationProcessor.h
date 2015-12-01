/*
 * Copyright 2014-2015 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
