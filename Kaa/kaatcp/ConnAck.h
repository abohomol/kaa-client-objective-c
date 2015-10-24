//
//  ConnAck.h
//  Kaa
//
//  Created by Anton Bohomol on 10/23/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "MqttFrame.h"

#define CONNACK_REMAINING_LEGTH_V1 (1)

/**
 * CONNACK return code enum
 *  ACCEPTED                    0x01    Connection Accepted
 *  REFUSE_BAD_PROTOCOL         0x02    Connection Refused: unacceptable protocol version
 *  REFUSE_ID_REJECT            0x03    Connection Refused: identifier rejected
 *  REFUSE_SERVER_UNAVAILABLE   0x04    Connection Refused: server unavailable
 *  REFUSE_BAD_CREDENTIALS      0x05    Connection Refused: invalid authentication parameters
 *  REFUSE_NO_AUTH              0x06    Connection Refused: not authorized
 */

typedef enum {
    RETURN_CODE_ACCEPTED = 0x01,
    RETURN_CODE_REFUSE_BAD_PROTOCOL = 0x02,
    RETURN_CODE_REFUSE_ID_REJECT = 0x03,
    RETURN_CODE_REFUSE_SERVER_UNAVAILABLE = 0x04,
    RETURN_CODE_REFUSE_BAD_CREDENTIALS = 0x05,
    RETURN_CODE_REFUSE_NO_AUTH = 0x06,
    RETURN_CODE_UNDEFINED = 0x07
} ReturnCode;


/**
 * ConnAck message Class.
 * The CONNACK message is a message sent by the server in response to a CONNECT request from a client.
 * Variable header
 * byte 1  reserved (0)
 * byte 2 Return Code see enum ReturnCode
 **/
@interface ConnAck : MqttFrame

@property (nonatomic) ReturnCode returnCode;

- (instancetype)initWithReturnCode:(ReturnCode)code;

@end
