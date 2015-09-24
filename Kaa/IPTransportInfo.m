	//
//  IPTransportInfo.m
//  Kaa
//
//  Created by Anton Bohomol on 9/8/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "IPTransportInfo.h"

@interface IPTransportInfo ()

@property (nonatomic,strong) NSData *publicKey;
@property (nonatomic,strong) NSString *host;
@property (nonatomic) int port;

@end

@implementation IPTransportInfo

- (instancetype)initWithTransportInfo:(id<TransportConnectionInfo>)parent {
    ProtocolMetaData *meta = [[ProtocolMetaData alloc] init];
    meta.accessPointId = [parent accessPointId];
    meta.connectionInfo = [parent connectionInfo];
    ProtocolVersionPair *info = [[ProtocolVersionPair alloc] init];
    info.id = [parent transportId].protocolId;
    info.version = [parent transportId].protocolVersion;
    meta.protocolVersionInfo = info;
    self = [super initWithServerType:[parent serverType] andMeta:meta];
    if (self) {
        self.publicKey = [super.meta.connectionInfo subdataWithRange:NSMakeRange(0, 4)];
        
        NSData *hostData = [super.meta.connectionInfo subdataWithRange:NSMakeRange(4, 8)];
        self.host = [[NSString alloc] initWithData:hostData encoding:NSUTF8StringEncoding];
        
        NSData *portData = [super.meta.connectionInfo subdataWithRange:NSMakeRange(8, 12)];
        self.port = *(int*)([portData bytes]);
    }
    return self;
}

- (NSString *)getHost {
    return self.host;
}

- (int)getPort {
    return self.port;
}

- (NSData *)getPublicKey {
    return self.publicKey;
}

- (NSString *)getUrl {
    return [NSString stringWithFormat:@"http://%@:%i", self.host, self.port];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"IPTransportInfo: %@", [self getUrl]];
}

@end
