//
//  DefaultBootstrapDataProcessorTest.m
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
#import "DefaultBootstrapDataProcessor.h"
#import "EndpointGen.h"
#import "AvroBytesConverter.h"

@interface DefaultBootstrapDataProcessorTest : XCTestCase

@end

@implementation DefaultBootstrapDataProcessorTest

- (void)testRequestCreation {
    DefaultBootstrapDataProcessor *processor = [[DefaultBootstrapDataProcessor alloc] init];
    id <BootstrapTransport> transport = mockProtocol(@protocol(BootstrapTransport));
    [given([transport createResolveRequest]) willReturn:[self getNewSyncRequest]];
    [processor setBootstrapTransport:transport];
    XCTAssertNotNil([processor compileRequest:nil]);
    [verifyCount(transport, times(1)) createResolveRequest];
}

- (void)testRequestCreationWithNullTransport {
    DefaultBootstrapDataProcessor *processor = [[DefaultBootstrapDataProcessor alloc] init];
    XCTAssertNil([processor compileRequest:nil]);
}

- (void)testResponse {
    DefaultBootstrapDataProcessor *processor = [[DefaultBootstrapDataProcessor alloc] init];
    id <BootstrapTransport> transport = mockProtocol(@protocol(BootstrapTransport));
    [processor setBootstrapTransport:transport];
    SyncResponse *response = [self getNewSyncResponse];
    NSArray *mdArray = [NSArray array];
    BootstrapSyncResponse *bootstrapSyncResponse = [[BootstrapSyncResponse alloc] init];
    bootstrapSyncResponse.requestId = 1;
    bootstrapSyncResponse.supportedProtocols = mdArray;
    [response setBootstrapSyncResponse:[KAAUnion unionWithBranch:KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_BRANCH_0 andData:bootstrapSyncResponse]];
    AvroBytesConverter *converter = [[AvroBytesConverter alloc] init];
    NSData *data = [converter toBytes:response];
    [processor processResponse:data];
    [verifyCount(transport, times(1)) onResolveResponse:anything()];
}

- (void)testNullResponse {
    DefaultBootstrapDataProcessor *processor = [[DefaultBootstrapDataProcessor alloc] init];
    id <BootstrapTransport> transport = mockProtocol(@protocol(BootstrapTransport));
    [processor setBootstrapTransport:transport];
    [processor processResponse:nil];
    [verifyCount(transport, times(0)) onResolveResponse:anything()];
}

- (void)testNullResponseWithNullTransport {
    DefaultBootstrapDataProcessor *processor = [[DefaultBootstrapDataProcessor alloc] init];
    [processor processResponse:nil];
}

#pragma mark - Supporting methods

- (SyncRequest *) getNewSyncRequest {
    SyncRequest *request = [[SyncRequest alloc] init];
    request.syncRequestMetaData = [KAAUnion unionWithBranch:KAA_UNION_SYNC_REQUEST_META_DATA_OR_NULL_BRANCH_1];
    request.bootstrapSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_BOOTSTRAP_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.profileSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_PROFILE_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.configurationSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_CONFIGURATION_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.notificationSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_NOTIFICATION_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.userSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_USER_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.eventSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_EVENT_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.logSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_LOG_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.requestId = 1;
    return request;
}

- (SyncResponse *) getNewSyncResponse {
    SyncResponse *response = [[SyncResponse alloc] init];
    response.requestId = 1;
    response.status = SYNC_RESPONSE_RESULT_TYPE_SUCCESS;
    response.bootstrapSyncResponse =
    [KAAUnion unionWithBranch:KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_BRANCH_1];
    response.profileSyncResponse =
    [KAAUnion unionWithBranch:KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_BRANCH_1];
    response.configurationSyncResponse =
    [KAAUnion unionWithBranch:KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_BRANCH_1];
    response.notificationSyncResponse =
    [KAAUnion unionWithBranch:KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_BRANCH_1];
    response.userSyncResponse =
    [KAAUnion unionWithBranch:KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_BRANCH_1];
    response.eventSyncResponse =
    [KAAUnion unionWithBranch:KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_BRANCH_1];
    response.redirectSyncResponse =
    [KAAUnion unionWithBranch:KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_BRANCH_1];
    response.logSyncResponse = [KAAUnion unionWithBranch:KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_BRANCH_1];
    
    return response;
}

@end
