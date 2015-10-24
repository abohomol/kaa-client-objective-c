//
//  MessageFactory.m
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "MessageFactory.h"

@interface MessageFactory ()

@property (nonatomic,weak) id<ConnAckDelegate> connAckDelegate;
@property (nonatomic,weak) id<ConnectDelegate> connectDelegate;
@property (nonatomic,weak) id<DisconnectDelegate> disconnectDelegate;
@property (nonatomic,weak) id<PingRequestDelegate> pingRequestDelegate;
@property (nonatomic,weak) id<PingResponseDelegate> pingResponseDelegate;
@property (nonatomic,weak) id<SyncRequestDelegate> syncRequestDelegate;
@property (nonatomic,weak) id<SyncResponseDelegate> syncResponseDelegate;

- (void)onKaaSyncMessage:(KaaSync *)frame;

@end

@implementation MessageFactory

- (instancetype)initWithFramer:(Framer *)framer {
    self = [super init];
    if (self) {
        self.framer = framer;
        [self.framer registerFrameDelegate:self];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFramer:[[Framer alloc] init]];
}

- (void)onMqttFrame:(MqttFrame *)frame {
    switch (frame.messageType) {
        case TCP_MESSAGE_TYPE_CONNACK:
            if (self.connAckDelegate) {
                [self.connAckDelegate onConnAckMessage:(ConnAck *)frame];
            }
            break;
        case TCP_MESSAGE_TYPE_CONNECT:
            if (self.connectDelegate) {
                [self.connectDelegate onConnectMessage:(Connect *)frame];
            }
            break;
        case TCP_MESSAGE_TYPE_DISCONNECT:
            if (self.disconnectDelegate) {
                [self.disconnectDelegate onDisconnectMessage:(Disconnect *)frame];
            }
            break;
        case TCP_MESSAGE_TYPE_KAASYNC:
            [self onKaaSyncMessage:(KaaSync *)frame];
            break;
        case TCP_MESSAGE_TYPE_PINGREQ:
            if (self.pingRequestDelegate) {
                [self.pingRequestDelegate onPingRequestMessage:(PingRequest *)frame];
            }
            break;
        case TCP_MESSAGE_TYPE_PINGRESP:
            if (self.pingResponseDelegate) {
                [self.pingResponseDelegate onPingResponseMessage:(PingResponse *)frame];
            }
            break;
        default:
            break;
    }
}

- (void)onKaaSyncMessage:(KaaSync *)frame {
    switch (frame.kaaSyncMessageType) {
        case KAA_SYNC_MESSAGE_TYPE_SYNC:
            if (frame.request) {
                if (self.syncRequestDelegate) {
                    [self.syncRequestDelegate onSyncRequestMessage:(SyncRequest *)frame];
                }
            } else {
                if (self.syncResponseDelegate) {
                    [self.syncResponseDelegate onSyncResponseMessage:(SyncResponse *)frame];
                }
            }
            break;
        case KAA_SYNC_MESSAGE_TYPE_UNUSED:
            
            break;
    }
}

- (void)registerConnAckDelegate:(id<ConnAckDelegate>)delegate {
    self.connAckDelegate = delegate;
}

- (void)registerConnectDelegate:(id<ConnectDelegate>)delegate {
    self.connectDelegate = delegate;
}

- (void)registerDisconnectDelegate:(id<DisconnectDelegate>)delegate {
    self.disconnectDelegate = delegate;
}

- (void)registerPingRequestDelegate:(id<PingRequestDelegate>)delegate {
    self.pingRequestDelegate = delegate;
}

- (void)registerPingResponseDelegate:(id<PingResponseDelegate>)delegate {
    self.pingResponseDelegate = delegate;
}

- (void)registerSyncRequestDelegate:(id<SyncRequestDelegate>)delegate {
    self.syncRequestDelegate = delegate;
}

- (void)registerSyncResponseDelegate:(id<SyncResponseDelegate>)delegate {
    self.syncResponseDelegate = delegate;
}

@end
