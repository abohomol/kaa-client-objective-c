//
//  PingResponse.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "MqttFrame.h"

/**
 * Kaatcp PingResponse Class.
 * A PINGRESP message is the response sent by a server to a PINGREQ message
 * and means "yes I am alive".
 */
@interface PingResponse : MqttFrame

@end
