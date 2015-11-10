//
//  PingRequest.m
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATcpPingRequest.h"

@implementation KAATcpPingRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setMessageType:TCP_MESSAGE_TYPE_PINGREQ];
        self.remainingLength = 0;
    }
    return self;
}

- (void)pack {
}

- (void)decode {
}

- (BOOL)isNeedCloseConnection {
    return NO;
}

@end
