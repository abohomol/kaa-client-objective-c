//
//  BootstrapTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 8/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_BootstrapTransport_h
#define Kaa_BootstrapTransport_h

#import <Foundation/Foundation.h>
#import "KaaTransport.h"
#import "EndpointGen.h"
#import "BootstrapManager.h"

@protocol BootstrapManager;
/**
 * KaaTransport for the Bootstrap service.
 * Updates the Bootstrap manager state.
 */
@protocol BootstrapTransport <KaaTransport>

/**
 * Creates new Resolve request.
 *
 * @return Resovle request.
 */
- (SyncRequest *)createResolveRequest;

/**
 * Updates the state of the Bootstrap manager according the given response.
 *
 * @param servers response from Bootstrap server.
 */
- (void)onResolveResponse:(SyncResponse *)servers;

/**
 * Sets the given Bootstrap manager.
 *
 * @param manager the Bootstrap manager to be set.
 */
- (void)setBootstrapManager:(id<BootstrapManager>)manager;

@end

#endif
