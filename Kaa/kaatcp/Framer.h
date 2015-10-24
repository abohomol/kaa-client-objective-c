//
//  Framer.h
//  Kaa
//
//  Created by Anton Bohomol on 10/23/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPDelegates.h"

/**
 * Kaatcp Framer class.
 * Used to cut incoming byte stream into MQTT frames, and deliver frames to MqttFrameDelegate.
 * Framer Class typically used from MessageFactory class.
 */
@interface Framer : NSObject

- (void)registerFrameDelegate:(id<MqttFrameDelegate>)delegate;

/**
 * Process incoming bytes stream.
 * Assumes that bytes are unprocessed bytes.
 * In case of previous #pushBytes eaten not all bytes on next iterations
 *  bytes array should start from unprocessed bytes.
 * @param bytes bytes to push
 * @return number of bytes processed from this array.
 * @throws KaaTcpProtocolException throws in case of protocol errors.
 */
- (int)pushBytes:(NSMutableData *)data;

/**
 * Reset Framer state by dropping currentFrame.
 */
- (void)flush;

@end
