//
//  KaaChannelManager.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_KaaChannelManager_h
#define Kaa_KaaChannelManager_h

#import "TransportCommon.h"
#import "KaaDataChannel.h"
#import "FailoverManager.h"

/**
 * Channel manager establishes/removes channels' links between client and server.
 *
 * Use this manager to add or remove specific network channel implementation for 
 * client-server communication.
 */
@protocol KaaChannelManager

/**
 * Updates the manager by setting the channel to the specified transport type.
 */
- (void)setChannel:(id<KaaDataChannel>)channel withType:(TransportType)type;

/**
 * Updates the manager by adding the channel.
 */
- (void)addChannel:(id<KaaDataChannel>)channel;

/**
 * Updates the manager by removing the channel from the manager.
 */
- (void)removeChannel:(id<KaaDataChannel>)channel;

- (void)removeChannelById:(NSString*)channelId;

- (NSArray*)getChannels;

- (id<KaaDataChannel>)getChannelById:(NSString*)channelId;

/**
 * Reports to Channel Manager in case link with server was not established.
 */
- (void)onServerFailed:(id<TransportConnectionInfo>)server;

- (void)clearChannelList;

/**
 * Invoke sync on active channel by specified transport type.
 */
- (void)sync:(TransportType)type;

/**
 * Invoke sync acknowledgement on active channel by specified transport type;
 *
 */
- (void)syncAck:(TransportType)type;

/**
 * Invoke sync acknowledgement on active channel;
 * type is used to identify active channel.
 */
- (void)syncAll:(TransportType)type;

/**
 * Returns information about server that is used for data transfer for specified TransportType.
 */
- (id<TransportConnectionInfo>)getActiveServer:(TransportType)type;

/**
 * Sets a new failover manager
 */
- (void)setFailoverManager:(id<FailoverManager>)failoverManager;

@end

#endif
