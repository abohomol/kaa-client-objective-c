//
//  GenericTransportInfo.m
//  Kaa
//
//  Created by Anton Bohomol on 8/18/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "GenericTransportInfo.h"

@implementation GenericTransportInfo

@synthesize serverType = _serverType;
@synthesize transportId = _transportId;

- (instancetype)initWithServerType:(ServerType)serverType andMeta:(ProtocolMetaData *)meta {
    self = [super init];
    if (self) {
        _serverType = serverType;
        self.meta = meta;
    }
    return self;
}

- (int)accessPointId {
    return [self.meta accessPointId];
}

- (NSData *)connectionInfo {
    return [self.meta connectionInfo];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[GenericTransportInfo class]]) {
        GenericTransportInfo *other = (GenericTransportInfo*)object;
        if (other.serverType == _serverType && [other.transportId isEqual:_transportId] && [[other connectionInfo] isEqualToData:[self connectionInfo]]) {
            YES;
        }
    }
    
    return NO;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + _serverType;
    result = prime * result + [_transportId hash];
    result = prime * result + [_meta hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"GenericTransportInfo [serverType = %i] [transportId = %@] [meta = %@]", _serverType, _transportId, _meta];
}

@end
