//
//  AbstractKaaTransport.m
//  Kaa
//
//  Created by Anton Bohomol on 5/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AbstractKaaTransport.h"

#define TAG @"AbstractKaaTransport >>>"

@implementation AbstractKaaTransport

- (void)setChannelManager:(id<KaaChannelManager>)channelManager {
    self.channelManager = channelManager;
}

- (void)setClientState:(id<KaaClientState>)state {
    self.clientState = state;
}

- (void)syncByType:(TransportType)type {
    [self syncByType:type ack:NO];
}

- (void)syncAckByType:(TransportType)type {
    [self syncByType:type ack:YES];
}

- (void)syncByType:(TransportType)type ack:(BOOL)ack {
    [self syncByType:type ack:ack all:NO];
}

- (void)syncAll:(TransportType)type {
    [self syncByType:type ack:NO all:YES];
}

- (void)syncByType:(TransportType)type ack:(BOOL)ack all:(BOOL)all {
    if (!self.channelManager) {
        DDLogError(@"%@ Channel manager is not set during sync for type %i", TAG, type);
        [NSException raise:@"ChannelRuntimeException" format:@"Failed to find channel for transport %i", type];
    }
    
    if (ack) {
        [self.channelManager syncAck:type];
    } else if (all) {
        [self.channelManager syncAll:type];
    } else {
        [self.channelManager sync:type];
    }
}

- (void)sync {
    [self syncByType:[self getTransportType]];
}

- (void)syncAck {
    [self syncAckByType:[self getTransportType]];
}

- (void)syncAck:(SyncResponseStatus)status {
    if (status != SYNC_RESPONSE_STATUS_NO_DELTA) {
        DDLogInfo(@"%@ Sending ack due to response status: %i", TAG, status);
        [self syncAck];
    }
}

- (TransportType)getTransportType {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class!"];
    return -1;
}

@end
