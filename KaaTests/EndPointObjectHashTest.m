/*
 * Copyright 2014-2015 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@import UIKit;
#import <XCTest/XCTest.h>
#import "EndpointObjectHash.h"
#import "NSData+Conversion.h"

@interface EndPointObjectHashTest : XCTestCase

@end

@implementation EndPointObjectHashTest

- (void) testDeltaSameEndpointObjectHash {
    
    EndpointObjectHash *hash1 = [EndpointObjectHash fromString:@"ttt"];
    EndpointObjectHash *hash2 = [EndpointObjectHash fromString:@"ttt"];
    XCTAssertEqualObjects(hash1, hash2);
    
    hash1 = [EndpointObjectHash fromSHA1:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    hash2 = [EndpointObjectHash fromSHA1:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertEqualObjects(hash1, hash2);

}

- (void) testDeltaDifferentEndpointObjectHash {
    
    EndpointObjectHash *hash1 = [EndpointObjectHash fromString:@"test1"];
    EndpointObjectHash *hash2 = [EndpointObjectHash fromString:@"test2"];
    XCTAssertNotEqualObjects(hash1, hash2);
    
    hash1 = [EndpointObjectHash fromSHA1:[@"test1" dataUsingEncoding:NSUTF8StringEncoding]];
    hash2 = [EndpointObjectHash fromSHA1:[@"test2" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertNotEqualObjects(hash1, hash2);
}

- (void) testNullEndpointObjectHash {
    
    EndpointObjectHash *hash1 = [EndpointObjectHash fromSHA1:nil];
    XCTAssertNil(hash1);
    
    hash1 = [EndpointObjectHash fromBytes:nil];
    XCTAssertNil(hash1);
    
    hash1 = [EndpointObjectHash fromString:nil];
    XCTAssertNil(hash1);
}

- (void) testToStringEndpointObjectHash {
    NSData *dat = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    
    EndpointObjectHash *hash1 = [EndpointObjectHash fromBytes:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertNotNil(hash1);
    XCTAssertTrue([[hash1 description] isEqualToString:[dat hexadecimalString]]);
    
}


@end
