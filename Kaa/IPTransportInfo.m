	//
//  IPTransportInfo.m
//  Kaa
//
//  Created by Anton Bohomol on 9/8/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "IPTransportInfo.h"

#define NSUINTEGERSIZE 8

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
        int pointStart = 0;
        int len = NSUINTEGERSIZE;
        NSUInteger length = 0;
        NSData *lengthData = [NSData data];
        
        lengthData = [super.meta.connectionInfo subdataWithRange:NSMakeRange(pointStart, len)];
        [lengthData getBytes:&length length:sizeof(NSUInteger)];
        pointStart += len;
        len = (int)length;
        
        self.publicKey = [super.meta.connectionInfo subdataWithRange:NSMakeRange(pointStart, len)];
        pointStart += len;
        len = NSUINTEGERSIZE;
        
        lengthData = [super.meta.connectionInfo subdataWithRange:NSMakeRange(pointStart, len)];
        [lengthData getBytes:&length length:sizeof(NSUInteger)];
        pointStart += len;
        len = (int)length;
        
        NSData *hostData = [super.meta.connectionInfo subdataWithRange:NSMakeRange(pointStart, len)];
        self.host = [[NSString alloc] initWithData:hostData encoding:NSUTF8StringEncoding];
        pointStart += len;
        len = NSUINTEGERSIZE;
        
        NSData *portData = [super.meta.connectionInfo subdataWithRange:NSMakeRange(pointStart, len)];
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
