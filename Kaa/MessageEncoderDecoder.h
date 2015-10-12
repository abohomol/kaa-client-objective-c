//
//  MessageEncoderDecoder.h
//  Kaa
//
//  Created by Anton Bohomol on 8/31/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyPair.h"

/**
 * The Class MessageEncoderDecoder is responsible for encoding/decoding logic of
 * endpoint - operations server communication.
 */
@interface MessageEncoderDecoder : NSObject

- (instancetype)initWithKeyPair:(KeyPair *)keys;

- (instancetype)initWithKeyPair:(KeyPair *)keys andRemotePublicKey:(NSData *)remoteKey;

- (instancetype)initWithKeyPair:(KeyPair *)keys andRemotePublicKeyRef:(SecKeyRef)remoteKeyRef;

- (NSData *)getSessionKey;

- (NSData *)getEncodedSessionKey;

/**
 * Encode data using sessionKey.
 *
 * @param message the data
 */
- (NSData *)encodeData:(NSData *)message;

/**
 * Decode data using session key.
 *
 * @param message the data
 */
- (NSData *)decodeData:(NSData *)message;

/**
 * Decode data using session key which is decoded using private key.
 *
 * @param message the date to decode
 * @param encodedKey the encoded key
 */
- (NSData *)decodeData:(NSData *)message withEncodedKey:(NSData *)encodedKey;

- (SecKeyRef)getPrivateKey;

- (SecKeyRef)getPublicKey;

- (SecKeyRef)getRemotePublicKey;

- (NSData *)getRemotePublicKeyAsBytes;

/**
 * Sign message using private key.
 */
- (NSData *)sign:(NSData *)message;

/**
 * Verify message using signature and remote public key.
 */
- (BOOL)verify:(NSData *)message withSignature:(NSData *)signature;

- (void)setRemotePublicKey:(NSData *)remotePublicKey;

@end
