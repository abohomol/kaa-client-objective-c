//
//  KeyPair.h
//  Kaa
//
//  Created by Anton Bohomol on 8/31/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Used to hold Public and Private key pair.
 */
@interface KeyPair : NSObject

- (instancetype)initWithPrivate:(SecKeyRef)privateKey andPublic:(SecKeyRef)publicKey;

- (SecKeyRef)getPrivateKeyRef;
- (SecKeyRef)getPublicKeyRef;

@end
