//
//  KAATCPDelegates.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#ifndef KAATcpDelegates_h
#define KAATcpDelegates_h

#import "KAATcpConnAck.h"
#import "KAATcpConnect.h"
#import "KAATcpDisconnect.h"
#import "KAATcpKaaSync.h"
#import "KAATcpSyncRequest.h"
#import "KAATcpSyncResponse.h"
#import "KAATcpPingRequest.h"
#import "KAATcpPingResponse.h"

@protocol MqttFrameDelegate

- (void)onMqttFrame:(KAAMqttFrame *)frame;

@end

@protocol ConnAckDelegate

- (void)onConnAckMessage:(KAATcpConnAck *)message;

@end

@protocol ConnectDelegate

- (void)onConnectMessage:(KAATcpConnect *)message;

@end

@protocol DisconnectDelegate

- (void)onDisconnectMessage:(KAATcpDisconnect *)message;

@end

@protocol KaaSyncDelegate

- (void)onKaaSyncMessage:(KAATcpKaaSync *)message;

@end

@protocol SyncRequestDelegate

- (void)onSyncRequestMessage:(KAATcpSyncRequest *)message;

@end

@protocol SyncResponseDelegate

- (void)onSyncResponseMessage:(KAATcpSyncResponse *)message;

@end

@protocol PingRequestDelegate

- (void)onPingRequestMessage:(KAATcpPingRequest *)message;

@end

@protocol PingResponseDelegate

- (void)onPingResponseMessage:(KAATcpPingResponse *)message;

@end

#endif /* KAATcpDelegates_h */
