//
//  ConnAck.m
//  Kaa
//
//  Created by Anton Bohomol on 10/23/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATCPConnAck.h"

@implementation KAATCPConnAck

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setMessageType:TCP_MESSAGE_TYPE_CONNACK];
        [self setReturnCode:RETURN_CODE_ACCEPTED];
    }
    return self;
}

- (instancetype)initWithReturnCode:(ReturnCode)code {
    self = [super init];
    if (self) {
        [self setMessageType:TCP_MESSAGE_TYPE_CONNACK];
        [self setReturnCode:code];
        self.remainingLength = CONNACK_REMAINING_LEGTH_V1;
    }
    return self;
}

- (void)pack {
    char zero = 0;
    char code = self.returnCode;
    [self.buffer appendBytes:&zero length:sizeof(char)];
    [self.buffer appendBytes:&code length:sizeof(char)];
}

- (void)decode {
    self.returnCode = ((const char*)[self.buffer bytes])[1];
}

- (BOOL)isNeedCloseConnection {
    return NO;
}

@end
