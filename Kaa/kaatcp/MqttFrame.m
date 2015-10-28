//
//  MqttFrame.m
//  Kaa
//
//  Created by Anton Bohomol on 10/23/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "MqttFrame.h"
#import "KaaLogging.h"

#define TAG @"MqttFrame >>>"

@interface MqttFrame ()

- (void)processByte:(char)byte;

@end

@implementation MqttFrame

- (instancetype)init {
    self = [super init];
    if (self) {
        self.multiplier = 1;
        self.frameDecodeComplete = NO;
    }
    return self;
}

- (instancetype)initWithOld:(MqttFrame *)old {
    self = [self init];
    if (self) {
        _messageType = old.messageType;
        _buffer = old.buffer;
        _bufferPosition = old.bufferPosition;
        _frameDecodeComplete = old.frameDecodeComplete;
        _remainingLength = old.remainingLength;
        _multiplier = old.multiplier;
        _currentState = old.currentState;
    }
    return self;
}

- (NSData *)getFrame {
    if (!self.buffer) {
        int remainingLength = self.remainingLength;
        NSMutableData *kaaTcpHeader = [NSMutableData dataWithCapacity:KAA_TCP_NAME_LENGTH];
        int headerSize = [self fillFixedHeader:remainingLength destination:kaaTcpHeader];
        int remainingSize = remainingLength + headerSize;
        DDLogVerbose(@"%@ Allocating buffer size [%i]", TAG, remainingSize);
        self.buffer = [NSMutableData dataWithCapacity:remainingSize];
        [self.buffer appendData:kaaTcpHeader];
        self.bufferPosition += kaaTcpHeader.length;
        [self pack];
        self.bufferPosition = 0;
    }
    return self.buffer;
}

- (int)fillFixedHeader:(int)remainingLength destination:(NSMutableData *)destination {
    char *rawDestination = [destination mutableBytes];
    int size = 1;
    char byte1 = self.messageType;
    byte1 = byte1 & 0x0F;
    byte1 = byte1 << 4;
    rawDestination[0] = byte1;
    char digit = 0x00;
    do {
        digit = remainingLength % 0x00000080;
        remainingLength /= 0x00000080;
        // if there are more digits to encode, set the top bit of this digit
        if (remainingLength > 0) {
            digit = digit | 0x80;
        }
        rawDestination[size] = digit;
        ++size;
    } while ( remainingLength > 0 );
    [destination appendBytes:rawDestination length:size];
    return size;
}

- (void)onFrameDone {
    DDLogVerbose(@"%@ Frame [%i]: payload processed", TAG, self.messageType);
    if (self.buffer) {
        self.bufferPosition = 0;
    }
    [self decode];
    self.frameDecodeComplete = YES;
}

- (void)processByte:(char)byte {
    if (self.currentState == FRAME_PARSING_STATE_PROCESSING_LENGTH) {
        self.remainingLength += ((byte & 0xFF) & 127) * self.multiplier;
        self.multiplier *= 128;
        if (((byte & 0xFF) & 128) == 0) {
            DDLogVerbose(@"%@ Frame [%i]: payload length: %i", TAG, self.messageType, self.remainingLength);
            if (self.remainingLength != 0) {
                self.buffer = [NSMutableData dataWithCapacity:self.remainingLength];
                self.bufferPosition = 0;
                self.currentState = FRAME_PARSING_STATE_PROCESSING_PAYLOAD;
            } else {
                [self onFrameDone];
            }
        }
    }
}

- (int)push:(NSData *)bytes to:(int)position {
    int pos = position;
    const char *rawBytes = [bytes bytes];
    if (self.currentState == FRAME_PARSING_STATE_NONE) {
        self.remainingLength = 0;
        self.currentState = FRAME_PARSING_STATE_PROCESSING_LENGTH;
    }
    while (pos < bytes.length && !self.frameDecodeComplete) {
        if (self.currentState == FRAME_PARSING_STATE_PROCESSING_PAYLOAD) {
            NSUInteger bytesToCopy = (self.remainingLength > bytes.length - pos) ? bytes.length - pos : self.remainingLength;
            [self.buffer appendData:[bytes subdataWithRange:NSMakeRange(pos, bytesToCopy)]];
            self.bufferPosition += bytesToCopy;
            pos += bytesToCopy;
            self.remainingLength -= bytesToCopy;
            DDLogVerbose(@"%@ Frame [%i]: copied %li bytes of payload. %i bytes left",
                         TAG, self.messageType, bytesToCopy, self.remainingLength);
            if (self.remainingLength == 0) {
                [self onFrameDone];
            }
        } else {
            [self processByte:rawBytes[pos]];
            ++pos;
        }
    }
    return pos - position;
}

- (MqttFrame *)upgradeFrame {
    return self;
}

- (NSInputStream *)remainingStream {
    NSRange range = NSMakeRange(self.bufferPosition, self.buffer.length - self.bufferPosition);
    return [NSInputStream inputStreamWithData:[self.buffer subdataWithRange:range]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MqttFrame [messageType:%i currentState:%i]", self.messageType, self.currentState];
}

- (void)decode {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
}

- (void)pack {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
}

- (BOOL)isNeedCloseConnection {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return FALSE;
}

@end
