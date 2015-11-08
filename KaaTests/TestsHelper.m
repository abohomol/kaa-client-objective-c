//
//  TestsHelper.m
//  Kaa
//
//  Created by Anton Bohomol on 11/1/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "TestsHelper.h"
#import "KaaClientPropertiesState.h"

@implementation TestsHelper

+ (ProtocolMetaData *)buildMetaDataWithTPid:(TransportProtocolId *)TPid
                                       host:(NSString *)host
                                       port:(int32_t)port
                               andPublicKey:(NSData *)publicKey {
    int32_t publicKeyLength = CFSwapInt32([publicKey length]);
    int32_t hostLength = CFSwapInt32([host lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    port = CFSwapInt32(port);
    NSMutableData *data = [NSMutableData data];
    
    [data appendBytes:&publicKeyLength length:sizeof(publicKeyLength)];
    [data appendData:publicKey];
    [data appendBytes:&hostLength length:sizeof(hostLength)];
    [data appendData:[host dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendBytes:&port length:sizeof(port)];
    
    ProtocolVersionPair *pair = [[ProtocolVersionPair alloc]init];
    [pair setId:TPid.protocolId];
    [pair setVersion:TPid.protocolVersion];
    
    ProtocolMetaData *md = [[ProtocolMetaData alloc] init];
    [md setConnectionInfo:data];
    [md setAccessPointId:[[NSString stringWithFormat:@"%@:%i", host, port] hash]];
    [md setProtocolVersionInfo:pair];
    return md;
}

+ (KaaClientProperties *)getProperties {
    KaaClientProperties *properties = [[KaaClientProperties alloc] initDefaults:[CommonBase64 new]];
    [properties setString:@"0" forKey:TRANSPORT_POLL_DELAY_KEY];
    [properties setString:@"1" forKey:TRANSPORT_POLL_PERIOD_KEY];
    [properties setString:@"1" forKey:TRANSPORT_POLL_UNIT_KEY];
    [properties setString:@"123456" forKey:SDK_TOKEN_KEY];
    [properties setString:STATE_FILE_DEFAULT forKey:STATE_FILE_LOCATION_KEY];
    return properties;
}

@end
