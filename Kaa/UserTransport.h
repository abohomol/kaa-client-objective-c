//
//  UserTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 8/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_UserTransport_h
#define Kaa_UserTransport_h

#import <Foundation/Foundation.h>
#import "KaaTransport.h"
#import "EndpointGen.h"
#import "EndpointRegistrationProcessor.h"

/**
 * KaaTransport for the Endpoint service.
 * Updates the Endpoint manager state.
 */
@protocol UserTransport <KaaTransport>

/**
 * Creates new User update request.
 *
 * @return new User update request.
 * @see UserSyncRequest
 */
- (UserSyncRequest *)createUserRequest;

/**
* Updates the state of the Endpoint manager according to the given response.
*
* @param response the response from the server.
* @see UserSyncResponse
*/
- (void)onUserResponse:(UserSyncResponse *)response;

/**
 * Sets the given Endpoint processor.
 *
 * @param processor the Endpoint processor to be set.
 * @see EndpointRegistrationProcessor
 */
- (void)setEndpointRegistrationProcessor:(id<EndpointRegistrationProcessor>)processor;

@end

#endif
