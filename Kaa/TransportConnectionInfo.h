//
//  TransportConnectionInfo.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_TransportConnectionInfo_h
#define Kaa_TransportConnectionInfo_h

#import "TransportProtocolId.h"
#import "TransportCommon.h"

/**
 * Interface for server information. Used by KaaDataChannel and KaaChannelManager.
 */
@protocol TransportConnectionInfo

@property(nonatomic,readonly) ServerType serverType;
@property(nonatomic,strong,readonly) TransportProtocolId *transportId;

- (int)accessPointId;

/**
 * Retrieves serialized connection properties. 
 * Serialization may be specific for each transport protocol implementation.
 */
- (NSData *)connectionInfo;

@end

#endif
