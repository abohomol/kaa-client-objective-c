//
//  DefaultLogTransportTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 21.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "KaaClientState.h"
#import "LogTransport.h"
#import "DefaultLogTransport.h"

@interface DefaultLogTransportTest : XCTestCase

@end

@implementation DefaultLogTransportTest

- (void)testSyncNegative {
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    id <LogTransport> transport = [[DefaultLogTransport alloc] init];
    [transport setClientState:clientState];
    
    @try {
        [transport sync];
    }
    @catch (NSException *exception) {
        NSLog(@"testSyncNegativeSucceed. Caught ChannelRuntimeException");
    }
}

- (void)testSync {
    id <KaaChannelManager> channelManager = mockProtocol(@protocol(KaaChannelManager));
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    
    id <LogTransport> transport = [[DefaultLogTransport alloc] init];
    [transport setChannelManager:channelManager];
    [transport setClientState:clientState];
    [transport sync];
    
    [verifyCount(channelManager, times(1)) sync:TRANSPORT_TYPE_LOGGING];
}

- (void)testCreateRequest {
    id <LogProcessor> processor = mockProtocol(@protocol(LogProcessor));
    
    id <LogTransport> transport = [[DefaultLogTransport alloc] init];
    [transport createLogRequest];
    [transport setLogProcessor:processor];
    [transport createLogRequest];
    
    [verifyCount(processor, times(1)) fillSyncRequest:anything()];
}

- (void)testOnEventResponse {
    id <LogProcessor> processor = mockProtocol(@protocol(LogProcessor));
    id <LogTransport> transport = [[DefaultLogTransport alloc] init];
    LogSyncResponse *response = [[LogSyncResponse alloc] init];
    response.deliveryStatuses = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_BRANCH_1];
    
    [transport onLogResponse:response];
    [transport setLogProcessor:processor];
    [transport onLogResponse:response];
    
    [verifyCount(processor, times(1)) onLogResponse:response];
}

@end
