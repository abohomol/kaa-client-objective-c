//
//  AbstractHttpClientTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 13.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AbstractHttpClient.h"
#import <Foundation/Foundation.h>
#import "KeyUtils.h"
#import "KeyPair.h"

@interface TestHttpClient : AbstractHttpClient

@end



@implementation TestHttpClient

- (NSData *)executeHttpRequest:(NSString *)uri entity:(NSDictionary *)entity verifyResponse:(BOOL)verifyResponse {
    return nil;
}

- (void)close {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ NSException raised in close method.", NSStringFromClass([self class])] userInfo:nil];
}

- (void) abort {
}

- (BOOL) canAbort {
    return FALSE;
}

@end


@interface AbstractHttpClientTest : XCTestCase

@end

@implementation AbstractHttpClientTest


- (void) testDisableVerification {
    TestHttpClient *client = [[TestHttpClient alloc] initWith:@"test_url" privateKey:nil publicKey:nil remoteKey:nil];
    [client disableVerification];
    int a = 1; int b = 2; int c = 3;
    NSMutableData *body = [NSMutableData data];
    [body appendBytes:&a length:sizeof(a)];
    [body appendBytes:&b length:sizeof(b)];
    [body appendBytes:&c length:sizeof(c)];
    
    NSData *signature = [NSData dataWithData:body];
    XCTAssertEqualObjects(body, [client verifyResponse:body signature:signature]);
}

@end
