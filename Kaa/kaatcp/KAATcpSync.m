//
//  Sync.m
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATcpSync.h"

@implementation KAATcpSync

- (instancetype)initWithOldKaaSync:(KAATcpKaaSync *)old {
    self = [super initWithOldKaaSync:old];
    if (self) {
        [self setKaaSyncMessageType:KAA_SYNC_MESSAGE_TYPE_SYNC];
    }
    return self;
}

- (instancetype)initWithAvro:(NSData *)avroObject request:(BOOL)isRequest zipped:(BOOL)isZipped encypted:(BOOL)isEncrypted {
    self = [super initRequest:isRequest zipped:isZipped encypted:isEncrypted];
    if (self) {
        [self setAvroObject:avroObject];
        [self setKaaSyncMessageType:KAA_SYNC_MESSAGE_TYPE_SYNC];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setKaaSyncMessageType:KAA_SYNC_MESSAGE_TYPE_SYNC];
    }
    return self;
}

- (void)decodeAvroObject:(NSInputStream *)input {
    int avroObjectSize = self.buffer.length - self.bufferPosition;
    if (avroObjectSize > 0) {
        uint8_t data[avroObjectSize];
        [input read:data maxLength:sizeof(data)];
        self.bufferPosition += avroObjectSize;
        _avroObject = [NSData dataWithBytes:data length:sizeof(data)];
    }
}

- (void)pack {
    [self packVeriableHeader];
    [self.buffer appendData:_avroObject];
    self.bufferPosition += _avroObject.length;
}

- (void)decode {
    NSInputStream *input = [self remainingStream];
    [input open];
    [self decodeVariableHeader:input];
    [self decodeAvroObject:input];
    [input close];
}

- (void)setAvroObject:(NSData *)avroObject {
    _avroObject = avroObject;
    self.remainingLength = KAASYNC_VERIABLE_HEADER_LENGTH_V1 + avroObject.length;
}

@end
