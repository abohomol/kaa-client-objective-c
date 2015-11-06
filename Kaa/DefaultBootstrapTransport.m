//
//  DefaultBootstrapTransport.m
//  Kaa
//
//  Created by Anton Bohomol on 9/9/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultBootstrapTransport.h"
#import "KaaLogging.h"

#define TAG @"DefaultBootstrapTransport >>>"

@interface DefaultBootstrapTransport ()

@property (nonatomic,strong) id<BootstrapManager> manager;
@property (nonatomic,strong) NSString *sdkToken;
@property (atomic) int increment;

@end

@implementation DefaultBootstrapTransport

- (instancetype)initWithToken:(NSString *)sdkToken {
    self = [super init];
    if (self) {
        self.sdkToken = sdkToken;
        self.increment = 0;
    }
    return self;
}

- (SyncRequest *)createResolveRequest {
    if (!self.clientState) {
        return nil;
    }
    SyncRequest *request = [[SyncRequest alloc] init];
    request.requestId = ++(self.increment);
    
    BootstrapSyncRequest *resolveRequest = [[BootstrapSyncRequest alloc] init];
    NSArray *channels = [self.channelManager getChannels];
    NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:[channels count]];
    for (id<KaaDataChannel> channel in channels) {
        TransportProtocolId *channelTransportId = [channel getTransportProtocolId];
        ProtocolVersionPair *pair = [[ProtocolVersionPair alloc] init];
        pair.id = channelTransportId.protocolId;
        pair.version = channelTransportId.protocolVersion;
        [pairs addObject:pair];
        DDLogDebug(@"%@ Adding '%@' to resolve request", TAG, pair);
    }
    resolveRequest.supportedProtocols = pairs;
    resolveRequest.requestId = self.increment;
    
    request.bootstrapSyncRequest =
    [KAAUnion unionWithBranch:KAA_UNION_BOOTSTRAP_SYNC_REQUEST_OR_NULL_BRANCH_0 andData:resolveRequest];
    
    SyncRequestMetaData *meta = [[SyncRequestMetaData alloc] init];
    meta.sdkToken = self.sdkToken;
    
    request.syncRequestMetaData =
    [KAAUnion unionWithBranch:KAA_UNION_SYNC_REQUEST_META_DATA_OR_NULL_BRANCH_0 andData:meta];
    return request;
}

- (void)onResolveResponse:(SyncResponse *)servers {
    if (self.manager && servers
        && servers.bootstrapSyncResponse.branch == KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_BRANCH_0) {
        BootstrapSyncResponse *responce = (BootstrapSyncResponse *)servers.bootstrapSyncResponse.data;
        [self.manager onProtocolListUpdated:responce.supportedProtocols];
    }
}

- (void)setBootstrapManager:(id<BootstrapManager>)manager {
    self.manager = manager;
}

- (TransportType)getTransportType {
    return TRANSPORT_TYPE_BOOTSTRAP;
}

@end
