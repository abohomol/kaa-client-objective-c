//
//  DefaultMetaDataTransportTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 21.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "DefaultMetaDataTransport.h"
#import "KaaClientProperties.h"
#import "EndpointObjectHash.h"

@interface DefaultMetaDataTransportTest : XCTestCase

@end

@implementation DefaultMetaDataTransportTest

- (void)testCreateMetaDataRequest {
    KaaClientProperties *properties = mock([KaaClientProperties class]);
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    [given([clientState profileHash]) willReturn:[EndpointObjectHash fromSHA1:[self getNewDataWith123]]];
    EndpointObjectHash *publicHash = [EndpointObjectHash fromSHA1:[self getNewDataWith567]];
    id <MetaDataTransport> transport = [[DefaultMetaDataTransport alloc] init];
    [transport createMetaDataRequest];
    [transport setClientProperties:properties];
    [transport createMetaDataRequest];
    [transport setClientState:clientState];
    [transport createMetaDataRequest];
    [transport setEndpointPublicKeyhash:publicHash];
    [transport setTimeout:5];
    
    SyncRequestMetaData *request = [transport createMetaDataRequest];
    
    [verifyCount(clientState, times(1)) profileHash];
    [verifyCount(properties, times(1)) sdkToken];
    
    XCTAssertEqualObjects([NSNumber numberWithLong:5], request.timeout.data);
}

#pragma mark - Supporting methods

- (NSData *) getNewDataWith123 {
    NSInteger integer = 123;
    NSData *data = [NSData dataWithBytes:&integer length:sizeof(integer)];
    return data;
}

- (NSData *) getNewDataWith567 {
    NSInteger integer = 567;
    NSData *data = [NSData dataWithBytes:&integer length:sizeof(integer)];
    return data;
}

@end
