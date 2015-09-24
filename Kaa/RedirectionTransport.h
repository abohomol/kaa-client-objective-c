//
//  RedirectionTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 9/8/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_RedirectionTransport_h
#define Kaa_RedirectionTransport_h

#import <Foundation/Foundation.h>
#import "BootstrapManager.h"
#import "EndpointGen.h"

/**
 * Transport for processing the Redirection response from server.
 */
@protocol RedirectionTransport

/**
 * Sets the given Bootstrap manager.
 *
 * @param manager the Bootstrap manager to be set.
 * @see BootstrapManager
 */
- (void)setBootstrapManager:(id<BootstrapManager>)manager;

/**
 * Retrieves the redirection info from the response and passes it
 * to Bootstrap manager.
 *
 * @param response the response from the server.
 * @see RedirectSyncResponse
 */
- (void)onRedirectionResponse:(RedirectSyncResponse *)response;

@end

#endif
