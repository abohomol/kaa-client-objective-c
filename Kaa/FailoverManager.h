//
//  FailoverManager.h
//  Kaa
//
//  Created by Anton Bohomol on 7/15/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_FailoverManager_h
#define Kaa_FailoverManager_h

#import <Foundation/Foundation.h>
#import "TransportConnectionInfo.h"
#import "FailoverDecision.h"

/**
 * Manager is responsible for managing current server's failover/connection events
 */
@protocol FailoverManager

/**
 * Needs to be invoked when a server fail occurs.
 */
- (void)onServerFailed:(id<TransportConnectionInfo>)connectionInfo;

/**
 * Needs to be invoked as soon as current server is changed.
 */
- (void)onServerChanged:(id<TransportConnectionInfo>)connectionInfo;

/**
 * Needs to be invoked as soon as connection to the current server is established.
 */
- (void)onServerConnected:(id<TransportConnectionInfo>)connectionInfo;

/**
 * Needs to be invoked to determine a decision that resolves the failover.
 *
 * failoverStatus - current status of the failover.
 *
 * Return decision which is meant to resolve the failover.
 */
- (FailoverDecision *)onFailover:(FailoverStatus)status;

@end

#endif
