//
//  EndPointObjectHashTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 02.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

@import UIKit;
#import <XCTest/XCTest.h>
#import "EndpointObjectHash.h"

@interface EndPointObjectHashTest : XCTestCase

@end

@implementation EndPointObjectHashTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


- (void) testDeltaSameEndpointObjectHash {
    
    EndpointObjectHash *hash1 = [EndpointObjectHash fromString:@"test"];
    EndpointObjectHash *hash2 = [EndpointObjectHash fromString:@"test"];
    
    XCTAssertEqual(hash1.data, hash2.data);
}

- (void) testDeltaDifferentEndpointObjectHash {
    
    EndpointObjectHash *hash1 = [EndpointObjectHash fromSHA1:@"test1"];
    EndpointObjectHash *hash2 = [EndpointObjectHash fromSHA1:@"test2"];
    
    XCTAssertNotEqual(hash1.data, hash2.data);
}


@end
