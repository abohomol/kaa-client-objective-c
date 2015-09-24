//
//  TransportProtocolIdHolder.m
//  Kaa
//
//  Created by Anton Bohomol on 9/8/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "TransportProtocolIdHolder.h"

#define HTTP_TRANSPORT_PROTOCOL_ID          (0xfb9a3cf0)
#define HTTP_TRANSPORT_PROTOCOL_VERSION     (1)

#define TCP_TRANSPORT_PROTOCOL_ID           (0x56c8ff92)
#define TCP_TRANSPORT_PROTOCOL_VERSION      (1)

@implementation TransportProtocolIdHolder

+ (TransportProtocolId *)HTTPTransportID {
    return [[TransportProtocolId alloc] initWithId:HTTP_TRANSPORT_PROTOCOL_ID andVersion:HTTP_TRANSPORT_PROTOCOL_VERSION];
}

+ (TransportProtocolId *)TCPTransportID {
    return [[TransportProtocolId alloc] initWithId:TCP_TRANSPORT_PROTOCOL_ID andVersion:TCP_TRANSPORT_PROTOCOL_VERSION];
}

@end
