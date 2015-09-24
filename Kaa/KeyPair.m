//
//  KeyPair.m
//  Kaa
//
//  Created by Anton Bohomol on 8/31/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "KeyPair.h"

@interface KeyPair ()

@property (nonatomic) SecKeyRef privateKey;
@property (nonatomic) SecKeyRef publicKey;

@end

@implementation KeyPair

- (instancetype)initWithPrivate:(SecKeyRef)privateKey andPublic:(SecKeyRef)publicKey {
    self = [super init];
    if (self) {
        self.privateKey = privateKey;
        self.publicKey = publicKey;
    }
    return self;
}

- (SecKeyRef)getPrivateKeyRef {
    return self.privateKey;
}

- (SecKeyRef)getPublicKeyRef {
    return self.publicKey;
}

@end
