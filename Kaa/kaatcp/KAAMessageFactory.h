//
//  MessageFactory.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KAATcpDelegates.h"
#import "KAAFramer.h"

/**
 * MessageFactory Class. Used to transform byte stream to specific protocol messages.
 *
 * Typical use:
 *
 * MessageFactory *factory = [[MessageFactory alloc] init];
 * [factory registerMessageDelegate:delegate];
 * [[factory framer] pushBytes:bytes];
 *
 * Where delegate instance of class which implements one of protocol message
 * delegetes and bytes - NSData object received from TCP/IP.
 */
@interface KAAMessageFactory : NSObject <MqttFrameDelegate>

@property (nonatomic,strong) KAAFramer *framer;

- (instancetype)initWithFramer:(KAAFramer *)framer;

- (void)registerConnAckDelegate:(id<ConnAckDelegate>)delegate;
- (void)registerConnectDelegate:(id<ConnectDelegate>)delegate;
- (void)registerDisconnectDelegate:(id<DisconnectDelegate>)delegate;
- (void)registerPingRequestDelegate:(id<PingRequestDelegate>)delegate;
- (void)registerPingResponseDelegate:(id<PingResponseDelegate>)delegate;
- (void)registerSyncRequestDelegate:(id<SyncRequestDelegate>)delegate;
- (void)registerSyncResponseDelegate:(id<SyncResponseDelegate>)delegate;

@end
