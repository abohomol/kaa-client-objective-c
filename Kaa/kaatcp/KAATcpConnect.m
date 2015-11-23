//
//  Connect.m
//  Kaa
//
//  Created by Anton Bohomol on 10/23/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATcpConnect.h"
#import "KaaLogging.h"
#import "KaaExceptions.h"

#define TAG @"Connect >>>"

@interface KAATcpConnect ()

- (void)packVeriableHeader;

- (void)decodeSyncRequest:(NSInputStream *)input;
- (void)decodeSignature:(NSInputStream *)input;
- (void)decodeSessionKey:(NSInputStream *)input;
- (void)decodeVariableHeader:(NSInputStream *)input;
- (void)decodeKeepAlive:(NSInputStream *)input;

@end

static const char FIXED_HEADER_CONST[] = {0x00,0x06,'K','a','a','t','c','p',CONNECT_VERSION,CONNECT_FIXED_HEADER_FLAG};

@implementation KAATcpConnect

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keepAlive = 200;
        [self setMessageType:TCP_MESSAGE_TYPE_CONNECT];
    }
    return self;
}

- (instancetype)initWithAlivePeriod:(uint16_t)keepAlive
                     nextProtocolId:(uint32_t)protocolId
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
        self.bufferPosition += self.aesSessionKey.length;
    }
    if (self.signature) {
        [self.buffer appendData:self.signature];
        self.bufferPosition += self.signature.length;
    }
    if (self.syncRequest) {
        [self.buffer appendData:self.syncRequest];
        self.bufferPosition += self.syncRequest.length;
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
    NSInputStream *input = [self remainingStream];
    [input open];
    
    [self decodeVariableHeader:input];
    
    uint8_t protocolId[4];
    [input read:protocolId maxLength:sizeof(protocolId)];
    _nextProtocolId = ntohl(*(uint32_t *)protocolId);
    self.bufferPosition += sizeof(protocolId);
    
    uint8_t aesKey[1];
    [input read:aesKey maxLength:sizeof(aesKey)];
    _isEncrypted = (*(char *)aesKey) != 0;
    self.bufferPosition += sizeof(aesKey);
    
    uint8_t sign[1];
    [input read:sign maxLength:sizeof(sign)];
    _hasSignature = (*(char *)sign) != 0;
    self.bufferPosition += sizeof(sign);
    
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
    int syncRequestSize = self.buffer.length - self.bufferPosition;
    if (syncRequestSize > 0) {
        uint8_t data[syncRequestSize];
        [input read:data maxLength:sizeof(data)];
        self.bufferPosition += syncRequestSize;
        self.syncRequest = [NSData dataWithBytes:data length:sizeof(data)];
    }
}

- (void)decodeSignature:(NSInputStream *)input {
    uint8_t signature[CONNECT_SIGNATURE_LENGTH];
    [input read:signature maxLength:sizeof(signature)];
    self.bufferPosition += CONNECT_SIGNATURE_LENGTH;
    self.signature = [NSData dataWithBytes:signature length:CONNECT_SIGNATURE_LENGTH];
}

- (void)decodeSessionKey:(NSInputStream *)input {
    uint8_t key[CONNECT_AES_SESSION_KEY_LENGTH];
    [input read:key maxLength:sizeof(key)];
    self.bufferPosition += CONNECT_AES_SESSION_KEY_LENGTH;
    self.aesSessionKey = [NSData dataWithBytes:key length:CONNECT_AES_SESSION_KEY_LENGTH];
}

- (void)decodeVariableHeader:(NSInputStream *)input {
    int headerSize = sizeof(FIXED_HEADER_CONST);
    uint8_t header[headerSize];
    [input read:header maxLength:headerSize];
    self.bufferPosition += headerSize;
    for (int i = 0; i < headerSize; i++) {
        if (header[i] != FIXED_HEADER_CONST[i]) {
            [NSException raise:KaaTcpProtocolException format:@"Kaatcp protocol version missmatch"];
        }
    }
}

- (void)decodeKeepAlive:(NSInputStream *)input {
    uint8_t keepAliveBytes[2];
    [input read:keepAliveBytes maxLength:sizeof(keepAliveBytes)];
    self.bufferPosition += sizeof(keepAliveBytes);
    self.keepAlive = ntohs(*(uint16_t *)keepAliveBytes);
}

- (void)packVeriableHeader {
    [self.buffer appendBytes:FIXED_HEADER_CONST length:sizeof(FIXED_HEADER_CONST)];
    self.bufferPosition += sizeof(FIXED_HEADER_CONST);
    
    uint32_t protocolId = htonl(self.nextProtocolId);
    [self.buffer appendBytes:&protocolId length:sizeof(protocolId)];
    self.bufferPosition += sizeof(protocolId);
    
    char keyFlag = self.aesSessionKey ? CONNECT_SESSION_KEY_FLAGS : 0;
    [self.buffer appendBytes:&keyFlag length:sizeof(keyFlag)];
    self.bufferPosition += sizeof(keyFlag);
    
    char signFlag = self.signature ? CONNECT_SIGNATURE_FLAGS : 0;
    [self.buffer appendBytes:&signFlag length:sizeof(signFlag)];
    self.bufferPosition += sizeof(signFlag);
    
    uint16_t keepAlive = htons(self.keepAlive);
    [self.buffer appendBytes:&keepAlive length:sizeof(keepAlive)];
    self.bufferPosition += sizeof(keepAlive);
}

@end
