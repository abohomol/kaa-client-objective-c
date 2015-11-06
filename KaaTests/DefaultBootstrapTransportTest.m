//
//  DefaultBootstrapTransportTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 20.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "KaaClientState.h"
#import "BootstrapTransport.h"
#import "DefaultBootstrapTransport.h"

@interface DefaultBootstrapTransportTest : XCTestCase

@end

@implementation DefaultBootstrapTransportTest

- (void)testSyncNegative {
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    id <BootstrapTransport> transport = [[DefaultBootstrapTransport alloc] initWithToken:@"some token"];
    [transport setClientState:clientState];
    @try {
        [transport sync];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSyncNegative succeed. Caught ChannelRuntimeException");
    }
}

- (void)testSync {
    id <KaaChannelManager> channelManager = mockProtocol(@protocol(KaaChannelManager));
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    id <BootstrapTransport> transport = [[DefaultBootstrapTransport alloc] initWithToken:@"some token"];
    [transport setChannelManager:channelManager];
    [transport setClientState:clientState];
    [transport sync];
    
    [verifyCount(channelManager, times(1)) sync:TRANSPORT_TYPE_BOOTSTRAP];
}

- (void)testCreateRequest {
    id <KaaChannelManager> channelManager = mockProtocol(@protocol(KaaChannelManager));
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    id <BootstrapTransport> transport = [[DefaultBootstrapTransport alloc] initWithToken:@"some token"];
    [transport setChannelManager:channelManager];
    [transport createResolveRequest];
    [transport setClientState:clientState];
    [transport createResolveRequest];
}

- (void)testOnBootstrapResponse {
    id <BootstrapTransport> transport = [[DefaultBootstrapTransport alloc] initWithToken:@"some token"];
    id <BootstrapManager> manager = mockProtocol(@protocol(BootstrapManager));
    
    SyncResponse *response = [self getNewSyncResponse];
    NSArray *mdArray = [NSArray array];
    BootstrapSyncResponse *bootstrapSyncResponse = [[BootstrapSyncResponse alloc] init];
    bootstrapSyncResponse.requestId = 1;
    bootstrapSyncResponse.supportedProtocols = mdArray;
    [response setBootstrapSyncResponse:[KAAUnion unionWithBranch:KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_BRANCH_0 andData:bootstrapSyncResponse]];
    
    [transport onResolveResponse:response];
    [transport setBootstrapManager:manager];
    [transport onResolveResponse:response];
    
    [verifyCount(manager, times(1)) onProtocolListUpdated:mdArray];
}

#pragma mark - Supported methods

- (SyncResponse *)getNewSyncResponse {
    SyncResponse *response = [[SyncResponse alloc] init];
    response.requestId = 1;
    response.status = SYNC_RESPONSE_RESULT_TYPE_SUCCESS;
    
    return response;
}

@end
