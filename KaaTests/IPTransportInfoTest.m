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
#import "TestsHelper.h"

@interface IPTransportInfoTest : XCTestCase

@end

@implementation IPTransportInfoTest

- (void)testInit {
    [KeyUtils generateKeyPair];
    NSData *publicKey = [KeyUtils getPublicKey];
    TransportProtocolId *TPid = [TransportProtocolIdHolder TCPTransportID];
    uint32_t port = 80;
    
    IPTransportInfo *info = [[IPTransportInfo alloc] initWithTransportInfo:[self createTestServerInfoWithServerType:SERVER_OPERATIONS transportProtocolId:TPid host:@"localhost" port:port andPublicKey:publicKey]];
    
    XCTAssertEqual(SERVER_OPERATIONS, [info serverType]);
    XCTAssertEqualObjects(TPid, [info transportId]);
    XCTAssertEqualObjects(@"localhost", [info getHost]);
    XCTAssertEqual(port, CFSwapInt32([info getPort]));
}

- (id<TransportConnectionInfo>)createTestServerInfoWithServerType:(ServerType)serverType
                                               transportProtocolId:(TransportProtocolId *)TPid
                                                              host:(NSString *)host
                                                              port:(uint32_t)port
                                                      andPublicKey:(NSData *)publicKey {
    ProtocolMetaData *md = [TestsHelper buildMetaDataWithTPid:TPid host:host port:port andPublicKey:publicKey];
    return  [[GenericTransportInfo alloc] initWithServerType:serverType andMeta:md];
}

@end
