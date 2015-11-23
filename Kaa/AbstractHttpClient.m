//
//  AbstractHttpClient.m
//  Kaa
//
//  Created by Anton Bohomol on 9/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AbstractHttpClient.h"
#import "KaaExceptions.h"
@interface AbstractHttpClient ()

@property (nonatomic,strong) MessageEncoderDecoder *encoderDecoder;
@property (nonatomic) BOOL verificationEnabled;

@end

@implementation AbstractHttpClient

- (instancetype)initWith:(NSString *)url
              privateKey:(SecKeyRef)privateK
               publicKey:(SecKeyRef)publicK
               remoteKey:(NSData *)remoteK {
    self = [super init];
    if (self) {
        self.url = url;
        KeyPair *keys = [[KeyPair alloc] initWithPrivate:privateK andPublic:publicK];
        self.encoderDecoder = [[MessageEncoderDecoder alloc] initWithKeyPair:keys andRemotePublicKey:remoteK];
        self.verificationEnabled = YES;
    }
    return self;
}

- (instancetype)initWith:(NSString *)url
              privateKey:(SecKeyRef)privateK
               publicKey:(SecKeyRef)publicK
               remoteKeyRef:(SecKeyRef)remoteK {
    self = [super init];
    if (self) {
        self.url = url;
        KeyPair *keys = [[KeyPair alloc] initWithPrivate:privateK andPublic:publicK];
        self.encoderDecoder = [[MessageEncoderDecoder alloc] initWithKeyPair:keys andRemotePublicKeyRef:remoteK];
        self.verificationEnabled = YES;
    }
    return self;
}

- (void)disableVerification {
    self.verificationEnabled = NO;
}

- (NSData *)verifyResponse:(NSData *)body signature:(NSData *)signature {
    if (!self.verificationEnabled || [self.encoderDecoder verify:body withSignature:signature]) {
        return body;
    } else {
        [NSException raise:KaaSecurityException format:@"Message can't be verified"];
        return nil;
    }
}

- (MessageEncoderDecoder *)getEncoderDecoder {
    return self.encoderDecoder;
}

- (NSData *)executeHttpRequest:(NSString *)uri entity:(NSDictionary *)entity verifyResponse:(BOOL)verifyResponse {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented"];
    return nil;
}

- (void)close {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented"];
}

- (void)abort {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented"];
}

- (BOOL)canAbort {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented"];
    return NO;
}

@end
