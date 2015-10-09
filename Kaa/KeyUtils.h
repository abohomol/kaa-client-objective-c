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
 * Used to generate key pair with custom tag or default one.
 */
+ (KeyPair *)generateKeyPair;
+ (KeyPair *)generateKeyPairWithPrivateTag:(NSData *)privateTag andPublicTag:(NSData *)publicTag;

/**
 * Gets reference to default public key from keychain.
 */
+ (SecKeyRef)getPublicKeyRef;

/**
 * Gets reference to default private key from keychain.
 */
+ (SecKeyRef)getPrivateKeyRef;

/**
 * Used to get key ref by selected tag from keychain.
 */
+ (SecKeyRef)getKeyRefByTag:(NSData *)tag;

/**
 * Gets default raw public key from keychain.
 */
+ (NSData *)getPublicKey;
+ (NSData *)getPublicKeyByTag:(NSData *)tag;

/**
 * Used to store remote key to keychain.
 */
+ (SecKeyRef)storePublicKey:(NSData *)publicKey withTag:(NSData *)tag;

/**
 * Used to remove stored key from keychain.
 */
+ (void)removeKeyByTag:(NSData *)tag;

/**
 * Used to remove default key pair from keychain.
 * NOTE: for removing key pair with custom tags use (removeKeyByTag:) for each key.
 */
+ (void)deleteExistingKeyPair;

@end
