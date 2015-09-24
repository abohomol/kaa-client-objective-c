//
//  KaaInternalChannelManager.h
//  Kaa
//
//  Created by Anton Bohomol on 8/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_KaaInternalChannelManager_h
#define Kaa_KaaInternalChannelManager_h

#import <Foundation/Foundation.h>
#import "KaaChannelManager.h"
#import "TransportConnectionInfo.h"
#import "ConnectivityChecker.h"
#import "KaaDataMultiplexer.h"
#import "KaaDataDemultiplexer.h"

@protocol KaaInternalChannelManager <KaaChannelManager>

/**
 * Reports to Channel Manager about the new server.
 *
 * @param newServer the parameters of the new server.
 * @see TransportConnectionInfo
 */
- (void)onTransportConnectionInfoUpdated:(id<TransportConnectionInfo>)newServer;

/**
 * Sets connectivity checker to the existing channels.
 *
 * @param checker platform-dependent connectivity checker.
 * @see ConnectivityChecker
 */
- (void)setConnectivityChecker:(ConnectivityChecker *)checker;

/**
 * Shuts down the manager and all registered channels. The instance can no
 * longer be used.
 */
- (void)shutdown;

/**
 * Pauses all active channels.
 */
- (void)pause;

/**
 * Restores channels' activity.
 */
- (void)resume;

- (void)setOperationMultiplexer:(id<KaaDataMultiplexer>)multiplexer;
- (void)setOperationDemultiplexer:(id<KaaDataDemultiplexer>)demultiplexer;

- (void)setBootstrapMultiplexer:(id<KaaDataMultiplexer>)multiplexer;
- (void)setBootstrapDemultiplexer:(id<KaaDataDemultiplexer>)demultiplexer;

@end

#endif
