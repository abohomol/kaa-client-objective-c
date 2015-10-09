//
//  KeyUtil.h
//  Kaa
//
//  Created by Anton Bohomol on 8/31/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyPair.h"

/**
 * Class is used to persist and fetch Public and Private Keys.
 */
@interface KeyUtils : NSObject

/**
 * Generate key pair.
 */
+ (KeyPair *)generateKeyPair;
+ (KeyPair *)generateKeyPairWithPrivateTag:(NSData *)privateTag andPublicTag:(NSData *)publicTag;

/**
 * Gets reference to the public key from keychain.
 */
+ (SecKeyRef)getPublicKeyRef;
+ (SecKeyRef)getPublicKeyRefByTag:(NSData *)tag;

/**
 * Gets reference to the private key from keychain.
 */
+ (SecKeyRef)getPrivateKeyRef;
+ (SecKeyRef)getPrivateKeyRefByTag:(NSData *)tag;

/**
 * Gets raw public key from keychain.
 */
+ (NSData *)getPublicKey;
+ (NSData *)getPublicKeyByTag:(NSData *)tag;

/**
 * Used to store remote key to keychain.
 */
+ (SecKeyRef)storePublicKey:(NSData *)publicKey withTag:(NSData *)tag;

/**
 * Used to remove stored remote key from keychain.
 */
+ (void)removeKeyByTag:(NSData *)tag;

/**
 * Used to remove key pair from keychain.
 */
+ (void)deleteExistingKeyPair;
+ (void)deleteExistingKeyPairWithPrivateTag:(NSData *)privateTag andPublicTag:(NSData *)publicTag;

@end
