//
//  MetaDataTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 9/8/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_MetaDataTransport_h
#define Kaa_MetaDataTransport_h

#import <Foundation/Foundation.h>
#import "EndpointGen.h"
#import "KaaClientProperties.h"
#import "KaaClientState.h"
#import "EndpointObjectHash.h"

/**
 * Transport for general client's state.
 */
@protocol MetaDataTransport

/**
 * Creates new Meta data request.
 */
- (SyncRequestMetaData *)createMetaDataRequest;

/**
 * Sets the given client's properties.
 */
- (void)setClientProperties:(KaaClientProperties *)properties;

/**
 * Sets the given client's state .
 */
- (void)setClientState:(id<KaaClientState>)state;

/**
 * Sets the given public key hash.
 */
- (void)setEndpointPublicKeyhash:(EndpointObjectHash *)hash;

/**
 * Sets the response timeout.
 */
- (void)setTimeout:(NSInteger)timeout;

@end

#endif
