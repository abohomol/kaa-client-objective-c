//
//  KaaClientPropertiesTest.m
//  Kaa
//
//  Created by Anton Bohomol on 10/5/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KaaClientProperties.h"
#import "TransportProtocolIdHolder.h"
#import "TransportConnectionInfo.h"
#import "TimeCommons.h"

@interface KaaClientPropertiesTest : XCTestCase

@property (nonatomic,strong) KaaClientProperties *properties;

@end

@implementation KaaClientPropertiesTest

- (void)setUp {
    [super setUp];
    NSString *propertiesPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"client_test_properties" ofType:@"plist"];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:propertiesPath]);
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:propertiesPath];
    XCTAssertTrue([defaults count] > 0);
    self.properties = [[KaaClientProperties alloc] initWithDictionary:defaults base64:[CommonBase64 new]];
}

- (void)testGetBootstrapServers {
    NSDictionary *bootstraps = [self.properties bootstrapServers];
    XCTAssertEqual(1, [bootstraps count]);
    
    NSArray *serverInfoList = [bootstraps objectForKey:[TransportProtocolIdHolder TCPTransportID]];
    XCTAssertNotNil(serverInfoList);
    XCTAssertEqual(1, [serverInfoList count]);
    
    id<TransportConnectionInfo> serverInfo = [serverInfoList objectAtIndex:0];
    XCTAssertEqual(SERVER_BOOTSTRAP, [serverInfo serverType]);
    XCTAssertEqual(1, [serverInfo accessPointId]);
    XCTAssertTrue([[TransportProtocolIdHolder TCPTransportID] isEqual:[serverInfo transportId]]);
}

- (void)testGetSdkToken {
    XCTAssertTrue([@"O7D+oECY1jhs6qIK8LA0zdaykmQ=" isEqualToString:[self.properties sdkToken]]);
}

- (void)testGetPollDelay {
    XCTAssertEqual(0, [self.properties pollDelay]);
}

- (void)testGetPollPeriod {
    XCTAssertEqual(10, [self.properties pollPeriod]);
}

- (void)testGetPollUnit {
    XCTAssertEqual(TIME_UNIT_SECONDS, [self.properties pollUnit]);
}

- (void)testGetDefaultConfigData {
    XCTAssertTrue(nil == [self.properties defaultConfigData]);
}

- (void)testGetDefaultConfigSchema {
    XCTAssertTrue(nil == [self.properties defaultConfigSchema]);
}

@end