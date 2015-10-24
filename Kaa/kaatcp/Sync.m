//
//  Sync.m
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "Sync.h"

@implementation Sync

- (instancetype)initWithOldKaaSync:(KaaSync *)old {
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
    uint8_t *data;
    NSMutableData *avroObject = [NSMutableData data];
    while ([input hasBytesAvailable]) {
        [input read:data maxLength:sizeof(char)];
        [avroObject appendBytes:data length:sizeof(char)];
    }
    _avroObject = avroObject;
}

- (void)pack {
    [self packVeriableHeader];
    [self.buffer appendData:_avroObject];
}

- (void)decode {
    NSInputStream *input = [NSInputStream inputStreamWithData:self.buffer];
    [self decodeVariableHeader:input];
    [self decodeAvroObject:input];
    [input close];
}

- (void)setAvroObject:(NSData *)avroObject {
    _avroObject = avroObject;
    self.remainingLength = KAASYNC_VERIABLE_HEADER_LENGTH_V1 + avroObject.length;
}

@end
