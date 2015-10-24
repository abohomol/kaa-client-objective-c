//
//  TCPDelegates.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#ifndef TCPDelegates_h
#define TCPDelegates_h

#import "ConnAck.h"
#import "Connect.h"
#import "Disconnect.h"
#import "KaaSync.h"
#import "SyncRequest.h"
#import "SyncResponse.h"
#import "PingRequest.h"
#import "PingResponse.h"

@protocol MqttFrameDelegate

- (void)onMqttFrame:(MqttFrame *)frame;

@end

@protocol ConnAckDelegate

- (void)onConnAckMessage:(ConnAck *)message;

@end

@protocol ConnectDelegate

- (void)onConnectMessage:(Connect *)message;

@end

@protocol DisconnectDelegate

- (void)onDisconnectMessage:(Disconnect *)message;

@end

@protocol KaaSyncDelegate

- (void)onKaaSyncMessage:(KaaSync *)message;

@end

@protocol SyncRequestDelegate

- (void)onSyncRequestMessage:(SyncRequest *)message;

@end

@protocol SyncResponseDelegate

- (void)onSyncResponseMessage:(SyncResponse *)message;

@end

@protocol PingRequestDelegate

- (void)onPingRequestMessage:(PingRequest *)message;

@end

@protocol PingResponseDelegate

- (void)onPingResponseMessage:(PingResponse *)message;

@end

#endif /* TCPDelegates_h */
