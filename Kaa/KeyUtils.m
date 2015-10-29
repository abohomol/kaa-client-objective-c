//
//  KeyUtil.m
//  Kaa
//
//  Created by Anton Bohomol on 8/31/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "KeyUtils.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+Conversion.h"
#import "KaaLogging.h"

#define TAG @"KeyUtil >>>"

#define KEY_PAIR_SIZE   2048

static const uint8_t publicKeyIdentifier[]  = "org.kaaproject.kaa.publickey";
static const uint8_t privateKeyIdentifier[] = "org.kaaproject.kaa.privatekey";

@interface KeyUtils ()

+ (NSData *)defaultPublicKeyTag;
+ (NSData *)defaultPrivateKeyTag;

+ (SecKeyRef)getKeyRefWithPersistentKeyRef:(CFTypeRef)persistentRef;

+ (NSData *)stripPublicKeyHeader:(NSData *)theKey;

@end

@implementation KeyUtils

+ (KeyPair *)generateKeyPair {
    return [self generateKeyPairWithPrivateTag:[self defaultPrivateKeyTag] andPublicTag:[self defaultPublicKeyTag]];
}

+ (KeyPair *)generateKeyPairWithPrivateTag:(NSData *)privateTag andPublicTag:(NSData *)publicTag {
    OSStatus sanityCheck = noErr;
    SecKeyRef publicKeyRef = NULL;
    SecKeyRef privateKeyRef = NULL;

    DDLogVerbose(@"%@ Removing key pair with same tags if exists", TAG);
    [KeyUtils removeKeyByTag:privateTag];
    [KeyUtils removeKeyByTag:publicTag];
    
    NSMutableDictionary * privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * keyPairAttr = [[NSMutableDictionary alloc] init];
    
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:KEY_PAIR_SIZE] forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    
    sanityCheck = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKeyRef, &privateKeyRef);
    
    if (sanityCheck == noErr && publicKeyRef != NULL && privateKeyRef != NULL) {
        DDLogInfo(@"%@ Successfully generated new key pair", TAG);
        return [[KeyPair alloc] initWithPrivate:privateKeyRef andPublic:publicKeyRef];
    } else {
        DDLogError(@"%@ Failed to generate new key pair", TAG);
        [NSException raise:@"KeyPairGenerationException" format:@"Failed to generate new key pair!"];
        return nil;
    }

}

+ (SecKeyRef)getPublicKeyRef {
    return [self getKeyRefByTag:[self defaultPublicKeyTag]];
}

+ (SecKeyRef)getPrivateKeyRef {
    return [self getKeyRefByTag:[self defaultPrivateKeyTag]];
}

+ (SecKeyRef)getKeyRefByTag:(NSData *)tag {
    OSStatus sanityCheck = noErr;
    SecKeyRef keyReference = NULL;
    
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    
    [queryKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryKey setObject:tag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&keyReference);
    
    if (sanityCheck != noErr) {
        DDLogWarn(@"%@ Can't get SecKeyRef by tag %@. OSStatus: %i", TAG, [tag hexadecimalString], (int)sanityCheck);
        keyReference = NULL;
    }
    
    return keyReference;
}

+ (NSData *)getPublicKey {
    return [self getPublicKeyByTag:[self defaultPublicKeyTag]];
}

+ (NSData *)getPublicKeyByTag:(NSData *)tag {
    OSStatus sanityCheck = noErr;
    
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:tag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef data = NULL;
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, &data);
    NSData * publicKeyBits = (__bridge NSData *)(data);

    if (sanityCheck != noErr) {
        DDLogWarn(@"%@ Can't get public key bytes by tag. OSStatus: %i", TAG, (int)sanityCheck);
    }
    
    return publicKeyBits;
}

+ (NSData *)defaultPrivateKeyTag {
    return [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
}

+ (NSData *)defaultPublicKeyTag {
    return [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
}

+ (SecKeyRef)storePublicKey:(NSData *)publicKey withTag:(NSData *)tag {
    NSData *processedKey = [KeyUtils stripPublicKeyHeader:publicKey];
    if (!processedKey) {
        DDLogWarn(@"%@ Wasn't ablt to stripe header for remote public key, passing plain public key to keychain", TAG);
        processedKey = publicKey;
    }
    DDLogDebug(@"%@ Remote public key: %@", TAG, [publicKey hexadecimalString]);
    
    OSStatus sanityCheck = noErr;
    CFTypeRef persistPeer = NULL;
    SecKeyRef remoteKeyRef;
    
    NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];
    [peerPublicKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [peerPublicKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [peerPublicKeyAttr setObject:tag forKey:(__bridge id)kSecAttrApplicationTag];
    [peerPublicKeyAttr setObject:processedKey forKey:(__bridge id)kSecValueData];
    [peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&persistPeer);
    
    if(sanityCheck != noErr){
        DDLogError(@"%@ Problem adding the remote public key to the keychain. OSStatus: %i", TAG, (int)sanityCheck);
        return NULL;
    }
    
    remoteKeyRef = [self getKeyRefByTag:tag];
    if (remoteKeyRef == NULL && persistPeer) {
        remoteKeyRef = [KeyUtils getKeyRefWithPersistentKeyRef:persistPeer];
    }
    if (persistPeer) {
        CFRelease(persistPeer);
    }
    
    return remoteKeyRef;
}

+ (void)removeKeyByTag:(NSData *)tag {
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    [queryKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryKey setObject:tag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];

    OSStatus sanityCheck = noErr;
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryKey);
    if (sanityCheck == noErr) {
        DDLogInfo(@"%@ Successfully removed key", TAG);
    } else {
        DDLogWarn(@"%@ Error removing key, status: %i", TAG, (int)sanityCheck);
    }
}

+ (void)deleteExistingKeyPair {
    DDLogDebug(@"%@ Goint to remove default private key", TAG);
    [self removeKeyByTag:[self defaultPrivateKeyTag]];
    
    DDLogDebug(@"%@ Goint to remove default public key", TAG);
    [self removeKeyByTag:[self defaultPublicKeyTag]];
}

+ (SecKeyRef)getKeyRefWithPersistentKeyRef:(CFTypeRef)persistentRef {
    if (persistentRef == NULL) {
        DDLogError(@"%@ PersistentRef object cannot be NULL", TAG);
        return NULL;
    }
    
    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
    
    [queryKey setObject:(__bridge id)persistentRef forKey:(__bridge id)kSecValuePersistentRef];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecKeyRef keyRef = NULL;
    OSStatus sanityCheck = noErr;
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&keyRef);
    if (sanityCheck != noErr) {
        DDLogWarn(@"%@ Can't get key ref with persistent key ref, status: %i", TAG, (int)sanityCheck);
    }
    
    return keyRef;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)theKey {
    if (theKey == nil) return nil;
    
    NSUInteger len = [theKey length];
    if (!len) return nil;
    
    unsigned char *c_key = (unsigned char *)[theKey bytes];
    unsigned int  idx    = 0;
    
    if (c_key[idx++] != 0x30) return nil;
    
    if (c_key[idx] > 0x80) {
        idx += c_key[idx] - 0x80 + 1;
    } else {
        idx++;
    }
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };
    
    if (memcmp(&c_key[idx], seqiod, 15)) return nil;
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return nil;
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return nil;
    
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

@end
