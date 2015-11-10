//
//  Framer.m
//  Kaa
//
//  Created by Anton Bohomol on 10/23/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAAFramer.h"
#import "KaaLogging.h"

#define TAG @"Framer >>>"

@interface KAAFramer ()

@property (nonatomic,strong) NSMutableArray *delegates;
@property (nonatomic,strong) KAAMqttFrame *currentFrame;

- (void)notifyDelegates:(KAAMqttFrame *)frame;

/**
 * Creates specific Kaatcp message by MessageType
 * @param type - KaaMessageType of mqttFrame
 * @return mqttFrame
 * @throws KaaTcpProtocolException if specified type is unsupported
 */
- (KAAMqttFrame *)getFrameByType:(char)type;

@end

@implementation KAAFramer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegates = [NSMutableArray array];
    }
    return self;
}

- (void)registerFrameDelegate:(id<MqttFrameDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (int)pushBytes:(NSMutableData *)data {
    if (!data) {
        [NSException raise:@"KaaTcpProtocolException" format:@"%@ Received nil data", TAG];
        return -1;
    }
    
    int used = 0;
    char *mutableData = [data mutableBytes];
    while (data.length > used) {
        if (!self.currentFrame) {
            if ((data.length - used) >= 1) { // 1 bytes minimum header length
                int intType = mutableData[used] & 0xFF;
                self.currentFrame = [self getFrameByType:(char) (intType >> 4)];
                ++used;
            } else {
                break;
            }
        }
        used += [self.currentFrame push:data to:used];
        if (self.currentFrame.frameDecodeComplete) {
            [self notifyDelegates:[self.currentFrame upgradeFrame]];
            self.currentFrame = nil;
        }
    }
    return used;
}

- (void)notifyDelegates:(KAAMqttFrame *)frame {
    for (id<MqttFrameDelegate> delegate in self.delegates) {
        [delegate onMqttFrame:frame];
    }
}

- (KAAMqttFrame *)getFrameByType:(char)type {
    KAAMqttFrame *frame = nil;
    switch (type) {
        case TCP_MESSAGE_TYPE_CONNACK:
            frame = [[KAATcpConnAck alloc] init];
            break;
        case TCP_MESSAGE_TYPE_CONNECT:
            frame = [[KAATcpConnect alloc] init];
            break;
        case TCP_MESSAGE_TYPE_DISCONNECT:
            frame = [[KAATcpDisconnect alloc] init];
            break;
        case TCP_MESSAGE_TYPE_KAASYNC:
            frame = [[KAATcpKaaSync alloc] init];
            break;
        case TCP_MESSAGE_TYPE_PINGREQ:
            frame = [[KAATcpPingRequest alloc] init];
            break;
        case TCP_MESSAGE_TYPE_PINGRESP:
            frame = [[KAATcpPingResponse alloc] init];
            break;
        default:
            [NSException raise:@"KaaTcpProtocolException" format:@"Got incorrect messageType format: %i", type];
            break;
    }
    return frame;
}

- (void)flush {
    self.currentFrame = nil;
    DDLogVerbose(@"%@ Invoked flush", TAG);
}

@end
