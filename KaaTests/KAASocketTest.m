//
//  KAASocketTest.m
//  Kaa
//
//  Created by Anton Bohomol on 10/26/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KAASocket.h"

@interface KAASocketTest : XCTestCase

@end

@implementation KAASocketTest

- (void)testExample {
    KAASocket *socket = [KAASocket socketWithHost:@"localhost" andPort:8080];
    XCTAssertNotNil(socket.input);
    XCTAssertNotNil(socket.output);
}

@end
