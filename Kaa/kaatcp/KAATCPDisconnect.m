//
//  Disconnect.m
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATCPDisconnect.h"

@implementation KAATCPDisconnect

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setMessageType:TCP_MESSAGE_TYPE_DISCONNECT];
    }
    return self;
}

- (instancetype)initWithDisconnectReason:(DisconnectReason)reason {
    self = [self init];
    if (self) {
        [self setReason:reason];
        self.remainingLength = DISCONNECT_REMAINING_LEGTH_V1;
    }
    return self;
}

- (void)pack {
    char zero = 0;
    [self.buffer appendBytes:&zero length:sizeof(char)];
    self.bufferPosition++;
    
    char reason = self.reason;
    [self.buffer appendBytes:&reason length:sizeof(char)];
    self.bufferPosition++;
}

- (void)decode {
    self.reason = ((const char*)[self.buffer bytes])[1];
}

- (BOOL)isNeedCloseConnection {
    return YES;
}

@end
