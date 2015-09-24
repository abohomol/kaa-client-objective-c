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

#define TAG @"KeyUtil >>>"

#define KEY_PAIR_SIZE   2048

enum {
    CSSM_ALGID_NONE =               0x00000000L,
    CSSM_ALGID_VENDOR_DEFINED =     CSSM_ALGID_NONE + 0x80000000L,
    CSSM_ALGID_AES
};

static const uint8_t publicKeyIdentifier[]  = "org.kaaproject.kaa.publickey";
static const uint8_t privateKeyIdentifier[] = "org.kaaproject.kaa.privatekey";

@interface KeyUtils ()

+ (void)deleteExisticKeyPair;
+ (NSData *)publicKeyTag;
+ (NSData *)privateKeyTag;

+ (SecKeyRef)getKeyRefWithPersistentKeyRef:(CFTypeRef)persistentRef;
+ (NSData *)stripPublicKeyHeader:(NSData *)theKey;

@end

@implementation KeyUtils

+ (KeyPair *)generateKeyPair {
    OSStatus sanityCheck = noErr;
    SecKeyRef publicKeyRef = NULL;
    SecKeyRef privateKeyRef = NULL;
    
    [KeyUtils deleteExisticKeyPair];
    
    NSMutableDictionary * privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * keyPairAttr = [[NSMutableDictionary alloc] init];
    
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:KEY_PAIR_SIZE] forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:[self privateKeyTag] forKey:(__bridge id)kSecAttrApplicationTag];
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:[self publicKeyTag] forKey:(__bridge id)kSecAttrApplicationTag];
    
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
    OSStatus sanityCheck = noErr;
    SecKeyRef publicKeyReference = NULL;
    
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:[self publicKeyTag] forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyReference);
    
    if (sanityCheck != noErr) {
        publicKeyReference = NULL;
    }
    
    return publicKeyReference;
}

+ (SecKeyRef)getPrivateKeyRef {
    OSStatus sanityCheck = noErr;
    SecKeyRef privateKeyReference = NULL;
    
    NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:[self privateKeyTag] forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKeyReference);
    
    if (sanityCheck != noErr) {
        privateKeyReference = NULL;
    }
    
    return privateKeyReference;
}

+ (NSData *)getPublicKey {
    OSStatus sanityCheck = noErr;
    
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:[self publicKeyTag] forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    CFDataRef data;
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&data);
    NSData * publicKeyBits = (__bridge_transfer NSData *)data;

    if (sanityCheck != noErr) {
        publicKeyBits = nil;
    }
    
    return publicKeyBits;
}

+ (NSData *)privateKeyTag {
    return [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
}

+ (NSData *)publicKeyTag {
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
    
    if(sanityCheck == noErr || sanityCheck == errSecDuplicateItem){
        DDLogError(@"%@ Problem adding the remote public key to the keychain. OSStatus: %i", TAG, (int)sanityCheck);
        return NULL;
    }
    
    if (persistPeer) {
        remoteKeyRef = [KeyUtils getKeyRefWithPersistentKeyRef:persistPeer];
    } else {
        [peerPublicKeyAttr removeObjectForKey:(__bridge id)kSecValueData];
        [peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
        sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&remoteKeyRef);
    }
    if (persistPeer) {
        CFRelease(persistPeer);
    }
    
    return remoteKeyRef;
}

+ (void)removeKeyByTag:(NSData *)tag {
    
    NSMutableDictionary * queryRemoteKey = [[NSMutableDictionary alloc] init];
    [queryRemoteKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryRemoteKey setObject:tag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryRemoteKey setObject:[NSNumber numberWithUnsignedInt:CSSM_ALGID_AES] forKey:(__bridge id)kSecAttrKeyType];
    
    OSStatus sanityCheck = noErr;
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryRemoteKey);
    if (sanityCheck != noErr || sanityCheck != errSecItemNotFound) {
        DDLogWarn(@"%@ Error removing remote public key. OSStatus: %i", TAG, (int)sanityCheck);
    }
}

+ (void)deleteExisticKeyPair {
    OSStatus sanityCheck = noErr;
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    NSData *publicKeyTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicKeyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];

    NSData *privateKeyTag = [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateKeyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    if (sanityCheck == noErr) {
        DDLogInfo(@"%@ Successfully removed private key", TAG);
    } else {
        DDLogWarn(@"%@ Error removing private key, status: %i", TAG, (int)sanityCheck);
    }
    
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    if (sanityCheck == noErr) {
        DDLogInfo(@"%@ Successfully removed public key", TAG);
    } else {
        DDLogWarn(@"%@ Error removing public key, status: %i", TAG, (int)sanityCheck);
    }
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
    
    return keyRef;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)theKey {
    if (theKey == nil) return nil;
    
    unsigned int len = [theKey length];
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
