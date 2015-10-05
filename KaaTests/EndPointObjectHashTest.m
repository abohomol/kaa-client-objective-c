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


- (void) testDeltaSameEndpointObjectHash {
    
    EndpointObjectHash *hash1 = [EndpointObjectHash fromString:@"ttt"];
    EndpointObjectHash *hash2 = [EndpointObjectHash fromString:@"ttt"];
    XCTAssertEqualObjects(hash1, hash2);
    
    hash1 = [EndpointObjectHash fromBytes:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    hash2 = [EndpointObjectHash fromBytes:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(hash1, hash2);
    
}

- (void) testDeltaDifferentEndpointObjectHash {
    
    EndpointObjectHash *hash1 = [EndpointObjectHash fromString:@"test1"];
    EndpointObjectHash *hash2 = [EndpointObjectHash fromString:@"test2"];
    XCTAssertNotEqualObjects(hash1, hash2);
    
    hash1 = [EndpointObjectHash fromBytes:[@"test1" dataUsingEncoding:NSUTF8StringEncoding]];
    hash2 = [EndpointObjectHash fromBytes:[@"test2" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(hash1, hash2);
    
}


@end
