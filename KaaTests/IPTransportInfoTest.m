//
//  IPTransportInfoTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 12.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IPTransportInfo.h"
#import "KeyUtils.h"
#import "TransportProtocolIdHolder.h"

@interface IPTransportInfoTest : XCTestCase

@end

@implementation IPTransportInfoTest

- (void) testInit {
    [KeyUtils generateKeyPair];
    NSData *publicKey = [KeyUtils getPublicKey];
    TransportProtocolId *TPid = [TransportProtocolIdHolder TCPTransportID];
    uint32_t port = 80;
    
    IPTransportInfo *info = [[IPTransportInfo alloc] initWithTransportInfo:[self createTestServerInfoWithServerType:SERVER_OPERATIONS transportProtocolId:TPid host:@"localhost" port:port andPublicKey:publicKey]];
    
    XCTAssertEqual(SERVER_OPERATIONS, [info serverType]);
    XCTAssertEqualObjects(TPid, [info transportId]);
    XCTAssertEqualObjects(@"localhost", [info getHost]);
    XCTAssertEqual(port, [info getPort]);
}

- (id<TransportConnectionInfo>) createTestServerInfoWithServerType:(ServerType)serverType transportProtocolId:(TransportProtocolId *)TPid host:(NSString *)host port:(uint32_t)port andPublicKey:(NSData *)publicKey {
    ProtocolMetaData *md = [[ProtocolMetaData alloc] init];
    md = [self buildMetaDataWithTPid:TPid host:host port:port andPublicKey:publicKey];
    return  [[GenericTransportInfo alloc] initWithServerType:serverType andMeta:md];
}

- (ProtocolMetaData *) buildMetaDataWithTPid:(TransportProtocolId *)TPid
                                        host:(NSString *)host
                                        port:(uint32_t)port
                                andPublicKey:(NSData *)publicKey {
    uint32_t publicKeyLength = [publicKey length];
    uint32_t hostLength = [host lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = [NSMutableData data];
    ProtocolVersionPair *pair = [[ProtocolVersionPair alloc]init];
    [pair setId:TPid.protocolId];
    [pair setVersion:TPid.protocolVersion];
    
    [data appendBytes:&publicKeyLength length:sizeof(publicKeyLength)];
    [data appendData:publicKey];
    [data appendBytes:&hostLength length:sizeof(hostLength)];
    [data appendData:[host dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendBytes:&port length:sizeof(port)];
    ProtocolMetaData *md = [[ProtocolMetaData alloc] init];
    [md setConnectionInfo:data];
    [md setAccessPointId:[[NSString stringWithFormat:@"%@:%i", host, port] hash]];
    [md setProtocolVersionInfo:pair];
    return md;
}

@end
