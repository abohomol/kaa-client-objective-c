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
        NSInputStream *input = [NSInputStream inputStreamWithData:super.meta.connectionInfo];
        [input open];
        
        uint8_t keySizeBytes[sizeof(uint32_t)];
        [input read:keySizeBytes maxLength:sizeof(keySizeBytes)];
        uint32_t keySize = *(uint32_t *)keySizeBytes;
        
        uint8_t key[keySize];
        [input read:key maxLength:sizeof(key)];
        self.publicKey = [NSData dataWithBytes:key length:sizeof(key)];
        
        uint8_t hostSizeBytes[sizeof(uint32_t)];
        [input read:hostSizeBytes maxLength:sizeof(hostSizeBytes)];
        uint32_t hostSize = *(uint32_t *)hostSizeBytes;
        
        uint8_t host[hostSize];
        [input read:host maxLength:sizeof(host)];
        self.host = [[NSString alloc] initWithBytes:host length:sizeof(host) encoding:NSUTF8StringEncoding];
        
        uint8_t portBytes[sizeof(uint32_t)];
        [input read:portBytes maxLength:sizeof(portBytes)];
        self.port = *(uint32_t *)portBytes;
        
        [input close];
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
