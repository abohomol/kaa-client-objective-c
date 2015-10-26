//
//  Connect.m
//  Kaa
//
//  Created by Anton Bohomol on 10/23/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATCPConnect.h"
#import "KaaLogging.h"

#define TAG @"Connect >>>"

@interface KAATCPConnect ()

- (void)packVeriableHeader;

- (void)decodeSyncRequest:(NSInputStream *)input;
- (void)decodeSignature:(NSInputStream *)input;
- (void)decodeSessionKey:(NSInputStream *)input;
- (void)decodeVariableHeader:(NSInputStream *)input;
- (void)decodeKeepAlive:(NSInputStream *)input;

@end

static const char FIXED_HEADER_CONST[] = {0x00,0x06,'K','a','a','t','c','p',CONNECT_VERSION,CONNECT_FIXED_HEADER_FLAG};

@implementation KAATCPConnect

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keepAlive = 200;
        [self setMessageType:TCP_MESSAGE_TYPE_CONNECT];
    }
    return self;
}

- (instancetype)initWithAlivePeriod:(char)keepAlive
                     nextProtocolId:(int32_t)protocolId
                      aesSessionKey:(NSData *)key
                        syncRequest:(NSData *)request
                          signature:(NSData *)signature {
    self = [self init];
    if (self) {
        [self setKeepAlive:keepAlive];
        [self setNextProtocolId:protocolId];
        [self setAesSessionKey:key];
        [self setSyncRequest:request];
        [self setSignature:signature];
        self.remainingLength = CONNECT_VERIABLE_HEADER_LENGTH_V1;
        if (key) {
            self.remainingLength += CONNECT_AES_SESSION_KEY_LENGTH;
        }
        if (signature) {
            self.remainingLength += CONNECT_SIGNATURE_LENGTH;
        }
        if (request) {
            self.remainingLength += request.length;
        }
        DDLogDebug(@"%@ Created Connect message: session key size: %li, signature size: %li, sync request size: %li",
                   TAG, key.length, signature.length, request.length);
    }
    return self;
}

- (void)pack {
    [self packVeriableHeader];
    if (self.aesSessionKey) {
        [self.buffer appendData:self.aesSessionKey];
    }
    if (self.signature) {
        [self.buffer appendData:self.signature];
    }
    if (self.syncRequest) {
        [self.buffer appendData:self.syncRequest];
    }
}

- (void)setAesSessionKey:(NSData *)aesSessionKey {
    _aesSessionKey = aesSessionKey;
    if (_aesSessionKey) {
        _isEncrypted = YES;
    }
}

- (void)setSignature:(NSData *)signature {
    _signature = signature;
    if (_signature) {
        _hasSignature = YES;
    }
}

- (void)decode {
    NSInputStream *input = [NSInputStream inputStreamWithData:self.buffer];
    [input open];
    [self decodeVariableHeader:input];
    uint8_t protocolId[4];
    [input read:protocolId maxLength:sizeof(protocolId)];
    _nextProtocolId = *(int32_t *)protocolId;
    uint8_t aesKey[1];
    [input read:aesKey maxLength:sizeof(aesKey)];
    _isEncrypted = (*(char *)aesKey) != 0;
    uint8_t sign[1];
    [input read:sign maxLength:sizeof(signed)];
    _hasSignature = (*(char *)sign) != 0;
    [self decodeKeepAlive:input];
    if (_isEncrypted) {
        [self decodeSessionKey:input];
    }
    if (_hasSignature) {
        [self decodeSignature:input];
    }
    [self decodeSyncRequest:input];
    [input close];
}

- (BOOL)isNeedCloseConnection {
    return NO;
}

- (void)decodeSyncRequest:(NSInputStream *)input {
    uint8_t data[1];
    NSMutableData *request = [NSMutableData data];
    while ([input hasBytesAvailable]) {
        [input read:data maxLength:sizeof(data)];
        [request appendBytes:data length:sizeof(data)];
    }
    self.syncRequest = request;
}

- (void)decodeSignature:(NSInputStream *)input {
    uint8_t signature[CONNECT_SIGNATURE_LENGTH];
    [input read:signature maxLength:sizeof(signature)];
    self.signature = [NSData dataWithBytes:signature length:CONNECT_SIGNATURE_LENGTH];
}

- (void)decodeSessionKey:(NSInputStream *)input {
    uint8_t key[CONNECT_AES_SESSION_KEY_LENGTH];
    [input read:key maxLength:sizeof(key)];
    self.aesSessionKey = [NSData dataWithBytes:key length:CONNECT_AES_SESSION_KEY_LENGTH];
}

- (void)decodeVariableHeader:(NSInputStream *)input {
    uint8_t header[sizeof(FIXED_HEADER_CONST)];
    [input read:header maxLength:sizeof(header)];
    for (int i = 0; i < sizeof(FIXED_HEADER_CONST); i++) {
        if (header[i] != FIXED_HEADER_CONST[i]) {
            [NSException raise:@"KaaTcpProtocolException" format:@"Kaatcp protocol version missmatch"];
        }
    }
}

- (void)decodeKeepAlive:(NSInputStream *)input {
    uint8_t msbBytes[1];
    [input read:msbBytes maxLength:sizeof(msbBytes)];
    int msb = (((char)msbBytes) & 0xFF) << 8;
    
    uint8_t lsbBytes[1];
    [input read:lsbBytes maxLength:sizeof(lsbBytes)];
    int lsb = ((char)lsbBytes) & 0xFF;
    self.keepAlive = (msb | lsb);
}

- (void)packVeriableHeader {
    [self.buffer appendBytes:FIXED_HEADER_CONST length:sizeof(FIXED_HEADER_CONST)];
    int32_t protocolId = self.nextProtocolId;
    [self.buffer appendBytes:&protocolId length:sizeof(protocolId)];
    char keyFlag = self.aesSessionKey ? CONNECT_SESSION_KEY_FLAGS : 0;
    [self.buffer appendBytes:&keyFlag length:sizeof(keyFlag)];
    char signFlag = self.signature ? CONNECT_SIGNATURE_FLAGS : 0;
    [self.buffer appendBytes:&signFlag length:sizeof(signFlag)];
    char keepAlive = self.keepAlive;
    [self.buffer appendBytes:&keepAlive length:sizeof(keepAlive)];
}

@end
