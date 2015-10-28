//
//  MqttFrame.h
//  Kaa
//
//  Created by Anton Bohomol on 10/23/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MQTT_FIXED_HEADER_LEGTH (2)
#define KAA_TCP_NAME_LENGTH (6)

typedef enum {
    TCP_MESSAGE_TYPE_UNKNOWN = 0x00,
    TCP_MESSAGE_TYPE_CONNECT = 0x01,
    TCP_MESSAGE_TYPE_CONNACK = 0x02,
    TCP_MESSAGE_TYPE_PINGREQ = 0x0C,
    TCP_MESSAGE_TYPE_PINGRESP = 0x0D,
    TCP_MESSAGE_TYPE_DISCONNECT = 0x0E,
    TCP_MESSAGE_TYPE_KAASYNC = 0x0F
} TCPMessageType;

typedef enum {
    FRAME_PARSING_STATE_NONE,
    FRAME_PARSING_STATE_PROCESSING_LENGTH,
    FRAME_PARSING_STATE_PROCESSING_PAYLOAD
} FrameParsingState;


/**
 * Basic Mqtt message.
 * Fixed header format
 * bit     7   6   5   4      3          2   1       0
 * byte 1  Message Type    Dup flag    QoS level   RETAIN
 * byte 2           Remaining length
 */
@interface MqttFrame : NSObject

@property (nonatomic,strong) NSMutableData *buffer;
@property (nonatomic) NSUInteger bufferPosition;

@property (nonatomic) TCPMessageType messageType;
@property (nonatomic) BOOL frameDecodeComplete;
/**
 * Remaining length of mqtt frame
 */
@property (nonatomic) int remainingLength;
@property (nonatomic) int multiplier;
@property (nonatomic) FrameParsingState currentState;

- (instancetype)initWithOld:(MqttFrame *)old;

- (NSData *)getFrame;

/**
 * Pack message into mqtt frame
 */
- (void)pack;

/**
 * Decode message from mqttFrame buffer
 * @throws KaaTcpProtocolException
 */
- (void)decode;

/**
 * Check if this Mqtt frame should be last frame on connection and connection should be closed.
 * @return boolean 'true' if connection should be closed after frame transmition.
 */
- (BOOL)isNeedCloseConnection;

/**
 * Fill mqtt frame fixed header
 * @return number of packet bytes
 */
- (int)fillFixedHeader:(int)remainingLength destination:(NSMutableData *)destination;

- (void)onFrameDone;

/**
 * Push bytes of frame
 * @param bytes - bytes array
 * @param position in buffer
 * @return int used bytes from buffer
 * @throws KaaTcpProtocolException
 */
- (int)push:(NSData *)bytes to:(int)position;

/**
 * Used in case if Frame Class should be changed during frame decode,
 * Used for migrate from KaaSync() general frame to specific classes like Sync, Bootstrap.
 * Default implementation is to return this.
 * @return new MqttFrame as specific class.
 * @throws KaaTcpProtocolException
 */
- (MqttFrame *)upgradeFrame;

- (NSInputStream *)remainingStream;

@end
