//
//  AbstractKaaTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 5/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaaTransport.h"
#import "KaaChannelManager.h"
#import "KaaClientState.h"
#import "EndpointGen.h"

@interface AbstractKaaTransport : NSObject <KaaTransport>

@property (nonatomic,strong) id<KaaChannelManager> channelManager;
@property (nonatomic,strong) id<KaaClientState> clientState;

- (void)syncByType:(TransportType)type;
- (void)syncAckByType:(TransportType)type;
- (void)syncByType:(TransportType)type ack:(BOOL)ack;
- (void)syncAll:(TransportType)type;
- (void)syncByType:(TransportType)type ack:(BOOL)ack all:(BOOL)all;
- (void)syncAck;
- (void)syncAck:(SyncResponseStatus)status;
- (TransportType)getTransportType;

@end
