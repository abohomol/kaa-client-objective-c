//
//  TCPDelegates.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#ifndef TCPDelegates_h
#define TCPDelegates_h

#import "KAATCPConnAck.h"
#import "KAATCPConnect.h"
#import "KAATCPDisconnect.h"
#import "KAATCPKaaSync.h"
#import "KAATCPSyncRequest.h"
#import "KAATCPSyncResponse.h"
#import "KAATCPPingRequest.h"
#import "KAATCPPingResponse.h"

@protocol MqttFrameDelegate

- (void)onMqttFrame:(MqttFrame *)frame;

@end

@protocol ConnAckDelegate

- (void)onConnAckMessage:(KAATCPConnAck *)message;

@end

@protocol ConnectDelegate

- (void)onConnectMessage:(KAATCPConnect *)message;

@end

@protocol DisconnectDelegate

- (void)onDisconnectMessage:(KAATCPDisconnect *)message;

@end

@protocol KaaSyncDelegate

- (void)onKaaSyncMessage:(KAATCPKaaSync *)message;

@end

@protocol SyncRequestDelegate

- (void)onSyncRequestMessage:(KAATCPSyncRequest *)message;

@end

@protocol SyncResponseDelegate

- (void)onSyncResponseMessage:(KAATCPSyncResponse *)message;

@end

@protocol PingRequestDelegate

- (void)onPingRequestMessage:(KAATCPPingRequest *)message;

@end

@protocol PingResponseDelegate

- (void)onPingResponseMessage:(KAATCPPingResponse *)message;

@end

#endif /* TCPDelegates_h */