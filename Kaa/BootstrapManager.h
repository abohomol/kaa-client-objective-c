//
//  BootstrapManager.h
//  Kaa
//
//  Created by Anton Bohomol on 8/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_BootstrapManager_h
#define Kaa_BootstrapManager_h

#import <Foundation/Foundation.h>
#import "TransportProtocolId.h"
#import "BootstrapTransport.h"
#import "FailoverManager.h"
#import "KaaInternalChannelManager.h"

@protocol BootstrapTransport;
/**
 * Bootstrap manager manages the list of available operation servers.
 */
@protocol BootstrapManager

/**
 * Receives the latest list of servers from the bootstrap server.
 */
- (void)receiveOperationsServerList;

/**
 * Force switch to the next operations server that support given <TransportProtocolId>
 *
 * @param transportId of the transport protocol.
 * @see TransportProtocolId
 */
- (void)useNextOperationsServer:(TransportProtocolId *)transportId;

/**
 * Update the Channel Manager with endpoint's properties retrieved by its DNS.
 *
 * @param accessPointId endpoint's DNS.
 */
- (void)useNextOperationsServerByAccessPointId:(NSInteger)accessPointId;

/**
 * Sets bootstrap transport object.
 *
 * @param transport object to be set.
 * @see BootstrapTransport
 */
- (void)setTransport:(id<BootstrapTransport>)transport;

/**
 * Sets Channel manager.
 *
 * @param manager the channel manager to be set.
 * @see KaaInternalChannelManager
 */
- (void)setChannelManager:(id<KaaInternalChannelManager>)manager;

/**
 * Sets Failover manager.
 *
 * @param manager the failover manager to be set
 * @see FailoverManager
 */
- (void)setFailoverManager:(id<FailoverManager>)manager;

/**
 * Updates the operation server list.
 *
 * @param list the operation server list. <ProtocolMetaData>
 * @see ProtocolMetaData
 */
- (void)onProtocolListUpdated:(NSArray *)list;

@end

#endif
