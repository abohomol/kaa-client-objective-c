/*
 * Copyright 2014-2015 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
