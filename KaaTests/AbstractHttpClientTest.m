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
#import "MessageEncoderDecoder.h"

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

@property (nonatomic,strong) KeyPair *clientPair;

@property (nonatomic,strong) NSData *serverPrivateTag;
@property (nonatomic,strong) NSData *serverPublicTag;
@property (nonatomic,strong) KeyPair *serverPair;

@end

@implementation AbstractHttpClientTest

- (void) setUp {
    [super setUp];
    self.clientPair = [KeyUtils generateKeyPair];
    
    self.serverPrivateTag = [self generateTag];
    self.serverPublicTag = [self generateTag];
    self.serverPair = [KeyUtils generateKeyPairWithPrivateTag:self.serverPrivateTag andPublicTag:self.serverPublicTag];
}

- (void) tearDown {
    [super tearDown];
    [KeyUtils deleteExistingKeyPair];
    [KeyUtils removeKeyByTag:self.serverPrivateTag];
    [KeyUtils removeKeyByTag:self.serverPublicTag];
}

- (void) testDisableVerification {
    TestHttpClient *client = [[TestHttpClient alloc] initWith:@"test_url" privateKey:nil publicKey:nil remoteKeyRef:nil];
    [client disableVerification];
    int a = 1; int b = 2; int c = 3;
    NSMutableData *body = [NSMutableData data];
    [body appendBytes:&a length:sizeof(a)];
    [body appendBytes:&b length:sizeof(b)];
    [body appendBytes:&c length:sizeof(c)];
    
    NSData *signature = [NSData dataWithData:body];
    XCTAssertEqualObjects(body, [client verifyResponse:body signature:signature]);
}

- (void) testSignature {
    TestHttpClient *client = [[TestHttpClient alloc] initWith:@"test_url" privateKey:[self.clientPair getPrivateKeyRef] publicKey:[self.clientPair getPublicKeyRef] remoteKeyRef:[self.serverPair getPublicKeyRef]];
    
    MessageEncoderDecoder *serverEncoder = [[MessageEncoderDecoder alloc] initWithKeyPair:self.serverPair andRemotePublicKeyRef:[self.clientPair getPublicKeyRef]];
    
    int a = 1; int b = 2; int c = 3;
    NSMutableData *message = [NSMutableData data];
    [message appendBytes:&a length:sizeof(a)];
    [message appendBytes:&b length:sizeof(b)];
    [message appendBytes:&c length:sizeof(c)];
    
    NSData *signature = [serverEncoder sign:message];
    XCTAssertEqualObjects(message, [client verifyResponse:message signature:signature]);
}

- (void) testVerifyResponseFailure {
    
    @try {
        TestHttpClient *client = [[TestHttpClient alloc] initWith:@"test_url" privateKey:[self.clientPair getPrivateKeyRef] publicKey:[self.clientPair getPublicKeyRef] remoteKeyRef:[self.serverPair getPublicKeyRef]];
        
        int a = 1; int b = 2; int c = 3;
        NSMutableData *body = [NSMutableData data];
        [body appendBytes:&a length:sizeof(a)];
        [body appendBytes:&b length:sizeof(b)];
        [body appendBytes:&c length:sizeof(c)];
        
        NSData *signature = [NSData dataWithData:body];
        [client verifyResponse:body signature:signature];
        XCTFail();
    }
    @catch (NSException *exception) {
    }
}

- (NSData *)generateTag {
    int randomInt = arc4random();
    return [NSData dataWithBytes:&randomInt length:sizeof(randomInt)];
}
@end
