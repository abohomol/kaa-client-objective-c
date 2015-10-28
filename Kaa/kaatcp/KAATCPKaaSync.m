//
//  KaaSync.m
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATCPKaaSync.h"
#import "KAATCPSyncResponse.h"
#import "KAATCPSyncRequest.h"

#define KAASYNC_MESSAGE_TYPE_SHIFT 4

static const char FIXED_HEADER_CONST[] = {0x00,0x06,'K','a','a','t','c','p',KAASYNC_VERSION};

@implementation KAATCPKaaSync

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setKaaSyncMessageType:KAA_SYNC_MESSAGE_TYPE_UNUSED];
        [self setMessageType:TCP_MESSAGE_TYPE_KAASYNC];
    }
    return self;
}

- (instancetype)initRequest:(BOOL)isRequest zipped:(BOOL)isZipped encypted:(BOOL)isEncrypted {
    self = [self init];
    if (self) {
        self.request = isRequest;
        self.zipped = isZipped;
        self.encrypted = isEncrypted;
        self.remainingLength = KAASYNC_VERIABLE_HEADER_LENGTH_V1;
    }
    return self;
}

- (instancetype)initWithOldKaaSync:(KAATCPKaaSync *)old {
    self = [super initWithOld:old];
    if (self) {
        [self setMessageType:TCP_MESSAGE_TYPE_KAASYNC];
        self.messageId = old.messageId;
        self.request = old.request;
        self.zipped = old.zipped;
        self.encrypted = old.encrypted;
        self.kaaSyncMessageType = old.kaaSyncMessageType;
    }
    return self;
}

- (void)packVeriableHeader {
    [self.buffer appendBytes:FIXED_HEADER_CONST length:sizeof(FIXED_HEADER_CONST)];
    self.bufferPosition += sizeof(FIXED_HEADER_CONST);
    
    char mId1 = self.messageId & 0x0000FF00;
    [self.buffer appendBytes:&mId1 length:sizeof(mId1)];
    self.bufferPosition++;
    
    char mId2 = self.messageId & 0x000000FF;
    [self.buffer appendBytes:&mId2 length:sizeof(mId2)];
    self.bufferPosition++;
    
    char flags = 0x00;
    if (self.request) {
        flags = flags | KAASYNC_REQUEST_FLAG;
    }
    if (self.zipped) {
        flags = flags | KAASYNC_ZIPPED_FLAG;
    }
    if (self.encrypted) {
        flags = flags | KAASYNC_ENCRYPTED_FLAG;
    }
    flags = flags | (self.kaaSyncMessageType << KAASYNC_MESSAGE_TYPE_SHIFT);
    [self.buffer appendBytes:&flags length:sizeof(flags)];
    self.bufferPosition++;
}

- (void)decodeVariableHeader:(NSInputStream *)input {
    uint8_t header[sizeof(FIXED_HEADER_CONST)];
    [input read:header maxLength:sizeof(header)];
    self.bufferPosition += sizeof(FIXED_HEADER_CONST);
    for (int i = 0; i < sizeof(FIXED_HEADER_CONST); i++) {
        if (header[i] != FIXED_HEADER_CONST[i]) {
            [NSException raise:@"KaaTcpProtocolException" format:@"Kaatcp protocol version missmatch"];
        }
    }
    
    uint8_t msbByte[1];
    [input read:msbByte maxLength:sizeof(msbByte)];
    self.bufferPosition++;
    int32_t msb = ((*(char *)msbByte) & 0xFF) << 8;
    
    uint8_t lsbByte[1];
    [input read:lsbByte maxLength:sizeof(lsbByte)];
    self.bufferPosition++;
    int32_t lsb = (*(char *)lsbByte) & 0xFF;
    
    self.messageId = (msb | lsb);
    
    uint8_t flagByte[1];
    [input read:flagByte maxLength:sizeof(flagByte)];
    self.bufferPosition++;
    char flag = *(char *)flagByte;
    
    self.request = ((flag & 0xFF) & KAASYNC_REQUEST_FLAG) != 0;
    self.zipped = ((flag & 0xFF) & KAASYNC_ZIPPED_FLAG) != 0;
    self.encrypted = ((flag & 0xFF) & KAASYNC_ENCRYPTED_FLAG) != 0;

    self.kaaSyncMessageType = (flag >> KAASYNC_MESSAGE_TYPE_SHIFT) & 0x0F;
}

- (void)pack {
    [self packVeriableHeader];
}

- (void)decode {
    NSInputStream *input = [self remainingStream];
    [input open];
    [self decodeVariableHeader:input];
    [input close];
}

- (MqttFrame *)upgradeFrame {
    switch (self.kaaSyncMessageType) {
        case KAA_SYNC_MESSAGE_TYPE_SYNC:
            if (self.request) {
                return [[KAATCPSyncRequest alloc] initWithOldKaaSync:self];
            } else {
                return [[KAATCPSyncResponse alloc] initWithOldKaaSync:self];
            }
            break;
        case KAA_SYNC_MESSAGE_TYPE_UNUSED:
            [NSException raise:@"KaaTcpProtocolException" format:@"KaaSync Message type is incorrect"];
            break;
    }
    [NSException raise:@"KaaTcpProtocolException" format:@"KaaSync Message type is incorrect"];
    return nil;
}

- (BOOL)isNeedCloseConnection {
    return NO;
}

@end
