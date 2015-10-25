//
//  Disconnect.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "MqttFrame.h"

/**
 *  DISCONNECT reason
 *  NONE                        0x00    No error
 *  BAD_REQUEST                 0x01    Client sent a corrupted data
 *  INTERNAL_ERROR              0x02    Internal error has been occurred
 */
typedef enum {
    DISCONNECT_REASON_NONE = 0x00,
    DISCONNECT_REASON_BAD_REQUEST = 0x01,
    DISCONNECT_REASON_INTERNAL_ERROR = 0x02
} DisconnectReason;

/**
 * Disconnect message Class.
 * The DISCONNECT message is sent from the client to the server to indicate that it is about to close
 * its TCP/IP connection. This provides a clean disconnection, rather than just dropping the line.
 * If the client had connected with the clean session flag set,
 * then all previously maintained information about the client will be discarded.
 * A server should not rely on the client to close the TCP/IP connection after receiving a DISCONNECT.
 */

#define DISCONNECT_REMAINING_LEGTH_V1 2

@interface KAATCPDisconnect : MqttFrame

@property (nonatomic) DisconnectReason reason;

- (instancetype)initWithDisconnectReason:(DisconnectReason)reason;

@end
