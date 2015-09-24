//
//  TransportProtocolId.m
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "TransportProtocolId.h"

/**
 * Immutable class to represent transport ID. Holds references to transport
 * protocol id and transport protocol version
 */
@implementation TransportProtocolId

- (instancetype)initWithId:(int)id andVersion:(int)version {
    self = [super init];
    if (self) {
        _protocolId = id;
        _protocolVersion = version;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithId:self.protocolId andVersion:self.protocolVersion];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + self.protocolId;
    result = prime * result + self.protocolVersion;
    return result;
}

- (BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[TransportProtocolId class]]) {
        TransportProtocolId *other = (TransportProtocolId*)object;
        if (other.protocolId == self.protocolId && other.protocolVersion == self.protocolVersion) {
            YES;
        }
    }
    
    return NO;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"TransportProtocolId [id:%i, version:%i]", self.protocolId, self.protocolVersion];
}

@end
