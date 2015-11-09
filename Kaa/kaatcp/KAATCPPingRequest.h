//
//  PingRequest.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAAMqttFrame.h"

/**
 * Kaatcp PingRequest Class.
 * The PINGREQ message is an "are you alive?" message that is sent
 * from a connected client to the server.
 */
@interface KAATCPPingRequest : KAAMqttFrame

@end
