//
//  KaaTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_KaaTransport_h
#define Kaa_KaaTransport_h

#import "KaaChannelManager.h"
#import "KaaClientState.h"

/**
 * Transport interface processing request
 * and response for the specific service.
 */
@protocol KaaTransport

/**
 * Sets the specific KaaChannelManager for the current transport.
 */
- (void)setChannelManager:(id<KaaChannelManager>)channelManager;

/**
 * Sets the client's state object.
 */
- (void)setClientState:(id<KaaClientState>)state;

/**
 * Sends update request to the server.
 */
- (void)sync;

@end

#endif
