//
//  GenericTransportInfo.h
//  Kaa
//
//  Created by Anton Bohomol on 8/18/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportConnectionInfo.h"
#import "TransportProtocolId.h"
#import "EndpointGen.h"

@interface GenericTransportInfo : NSObject <TransportConnectionInfo>

@property (nonatomic,strong) ProtocolMetaData *meta;

- (instancetype)initWithServerType:(ServerType)serverType andMeta:(ProtocolMetaData *)meta;

- (int)accessPointId;

- (NSData *)connectionInfo;

@end
