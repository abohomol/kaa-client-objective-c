//
//  DefaultOperationDataProcessorTest.m
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
#import "DefaultOperationDataProcessor.h"
#import "AvroBytesConverter.h"
#import "EndpointGen.h"


@interface DefaultOperationDataProcessorTest : XCTestCase

@end

@implementation DefaultOperationDataProcessorTest

- (void)testUpRequestCreationWithNullTypes {
    DefaultOperationDataProcessor *operationDataProcessor = [[DefaultOperationDataProcessor alloc] init];
    XCTAssertNil([operationDataProcessor compileRequest:nil]);
}

- (void)testUpRequestCreationWithUnknownType {
    DefaultOperationDataProcessor *operationDataProcessor = [[DefaultOperationDataProcessor alloc] init];
    NSDictionary *types = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL] forKey:[NSNumber numberWithInt:TRANSPORT_TYPE_BOOTSTRAP]];
    XCTAssertNil([operationDataProcessor compileRequest:types]);
}

- (void)testUpRequestCreationWithNullTransports {
    DefaultOperationDataProcessor *operationDataProcessor = [[DefaultOperationDataProcessor alloc] init];
    
    NSDictionary *transportTypes = [self getDictionaryWithTransportTypesWithBidirectional];
    
    XCTAssertNotNil([operationDataProcessor compileRequest:transportTypes]);
}

- (void)testUpRequestCreation {
    DefaultOperationDataProcessor *operationDataProcessor = [[DefaultOperationDataProcessor alloc] init];
    
    id <ProfileTransport> profileTransport = mockProtocol(@protocol(ProfileTransport));
    id <EventTransport> eventTransport = mockProtocol(@protocol(EventTransport));
    id <NotificationTransport> notificationTransport = mockProtocol(@protocol(NotificationTransport));
    id <ConfigurationTransport> configurationTransport = mockProtocol(@protocol(ConfigurationTransport));
    id <UserTransport> userTransport = mockProtocol(@protocol(UserTransport));
    id <MetaDataTransport> metaDataTransport = mockProtocol(@protocol(MetaDataTransport));
    id <LogTransport> logTransport = mockProtocol(@protocol(LogTransport));
    
    [operationDataProcessor setConfigurationTransport:configurationTransport];
    [operationDataProcessor setProfileTransport:profileTransport];
    [operationDataProcessor setEventTransport:eventTransport];
    [operationDataProcessor setNotificationTransport:notificationTransport];
    [operationDataProcessor setUserTransport:userTransport];
    [operationDataProcessor setMetaDataTransport:metaDataTransport];
    [operationDataProcessor setLogTransport:logTransport];
    
    NSDictionary *transportTypes = [self getDictionaryWithTransportTypesWithBidirectional];
    
    XCTAssertNotNil([operationDataProcessor compileRequest:transportTypes]);
    [verifyCount(configurationTransport, times(1)) createConfigurationRequest];
    [verifyCount(profileTransport, times(1)) createProfileRequest];
    [verifyCount(notificationTransport, times(1)) createNotificationRequest];
    [verifyCount(userTransport, times(1)) createUserRequest];
    [verifyCount(metaDataTransport, times(1)) createMetaDataRequest];
    [verifyCount(logTransport, times(1)) createLogRequest];
}

- (void)testDownRequestCreation {
    DefaultOperationDataProcessor *operationDataProcessor = [[DefaultOperationDataProcessor alloc] init];
    
    id <ProfileTransport> profileTransport = mockProtocol(@protocol(ProfileTransport));
    id <EventTransport> eventTransport = mockProtocol(@protocol(EventTransport));
    id <NotificationTransport> notificationTransport = mockProtocol(@protocol(NotificationTransport));
    id <ConfigurationTransport> configurationTransport = mockProtocol(@protocol(ConfigurationTransport));
    id <UserTransport> userTransport = mockProtocol(@protocol(UserTransport));
    id <MetaDataTransport> metaDataTransport = mockProtocol(@protocol(MetaDataTransport));
    id <LogTransport> logTransport = mockProtocol(@protocol(LogTransport));
    
    [operationDataProcessor setConfigurationTransport:configurationTransport];
    [operationDataProcessor setProfileTransport:profileTransport];
    [operationDataProcessor setEventTransport:eventTransport];
    [operationDataProcessor setNotificationTransport:notificationTransport];
    [operationDataProcessor setUserTransport:userTransport];
    [operationDataProcessor setMetaDataTransport:metaDataTransport];
    [operationDataProcessor setLogTransport:logTransport];
    
    NSDictionary *transportTypes = [self getDictionaryWithTransportTypesWithDownDirection];
    
    XCTAssertNotNil([operationDataProcessor compileRequest:transportTypes]);
    [verifyCount(configurationTransport, times(1)) createConfigurationRequest];
    [verifyCount(profileTransport, times(1)) createProfileRequest];
    [verifyCount(notificationTransport, times(1)) createEmptyNotificationRequest];
    [verifyCount(userTransport, times(1)) createUserRequest];
    [verifyCount(metaDataTransport, times(1)) createMetaDataRequest];
    [verifyCount(logTransport, times(1)) createLogRequest];
}

- (void)testResponse {
    DefaultOperationDataProcessor *operationDataProcessor = [[DefaultOperationDataProcessor alloc] init];
    
    id <ProfileTransport> profileTransport = mockProtocol(@protocol(ProfileTransport));
    id <EventTransport> eventTransport = mockProtocol(@protocol(EventTransport));
    id <NotificationTransport> notificationTransport = mockProtocol(@protocol(NotificationTransport));
    id <ConfigurationTransport> configurationTransport = mockProtocol(@protocol(ConfigurationTransport));
    id <UserTransport> userTransport = mockProtocol(@protocol(UserTransport));
    id <LogTransport> logTransport = mockProtocol(@protocol(LogTransport));
    id <RedirectionTransport> redirectionTransport = mockProtocol(@protocol(RedirectionTransport));
    
    [operationDataProcessor setConfigurationTransport:configurationTransport];
    [operationDataProcessor setProfileTransport:profileTransport];
    [operationDataProcessor setEventTransport:eventTransport];
    [operationDataProcessor setNotificationTransport:notificationTransport];
    [operationDataProcessor setUserTransport:userTransport];
    [operationDataProcessor setRedirectionTransport:redirectionTransport];
    [operationDataProcessor setLogTransport:logTransport];
    
    SyncResponse *response = [[SyncResponse alloc] init];
    [response setStatus:SYNC_RESPONSE_RESULT_TYPE_SUCCESS];
    [response setRequestId:1];
    [response setBootstrapSyncResponse:[self getBootstrapResponseUnion]];
    [response setProfileSyncResponse:[self getProfileSyncResponseUnion]];
    [response setConfigurationSyncResponse:[self getConfigurationUnion]];
    [response setNotificationSyncResponse:[self getNotificationUnion]];
    [response setUserSyncResponse:[self getUserUnion]];
    [response setEventSyncResponse:[self getEventUnion]];
    [response setRedirectSyncResponse:[self getRedirectUnion]];
    [response setLogSyncResponse:[self getLogUnion]];
    
    AvroBytesConverter *converter = [[AvroBytesConverter alloc] init];
    NSData *data = [converter toBytes:response];
    [operationDataProcessor processResponse:data];
    
    [verifyCount(profileTransport, times(1)) onProfileResponse:anything()];
    [verifyCount(eventTransport, times(1)) onEventResponse:anything()];
    [verifyCount(notificationTransport, times(1)) onNotificationResponse:anything()];
    [verifyCount(configurationTransport, times(1)) onConfigurationResponse:anything()];
    [verifyCount(userTransport, times(1)) onUserResponse:anything()];
    [verifyCount(redirectionTransport, times(1)) onRedirectionResponse:anything()];
    [verifyCount(logTransport, times(1)) onLogResponse:anything()];
}

- (void)testResponseWithNullTransport {
    DefaultOperationDataProcessor *operationDataProcessor = [[DefaultOperationDataProcessor alloc] init];
    
    SyncResponse *response = [[SyncResponse alloc] init];
    [response setStatus:SYNC_RESPONSE_RESULT_TYPE_SUCCESS];
    [response setBootstrapSyncResponse:[self getBootstrapResponseUnion]];
    [response setProfileSyncResponse:[self getProfileSyncResponseUnion]];
    [response setConfigurationSyncResponse:[self getConfigurationUnion]];
    [response setNotificationSyncResponse:[self getNotificationUnion]];
    [response setUserSyncResponse:[self getUserUnion]];
    [response setEventSyncResponse:[self getEventUnion]];
    [response setRedirectSyncResponse:[self getRedirectUnion]];
    [response setLogSyncResponse:[self getLogUnion]];
    
    AvroBytesConverter *converter = [[AvroBytesConverter alloc] init];
    NSData *data = [converter toBytes:response];
    [operationDataProcessor processResponse:data];
}

- (void)testResponseWithNullTransportAndResponses {
    DefaultOperationDataProcessor *operationDataProcessor = [[DefaultOperationDataProcessor alloc] init];
    
    SyncResponse *response = [[SyncResponse alloc] init];
    [response setStatus:SYNC_RESPONSE_RESULT_TYPE_SUCCESS];
    [response setBootstrapSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setProfileSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setConfigurationSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setNotificationSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setUserSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setEventSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setRedirectSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setLogSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    
    AvroBytesConverter *converter = [[AvroBytesConverter alloc] init];
    NSData *data = [converter toBytes:response];
    [operationDataProcessor processResponse:data];
}

- (void)testResponseWithNullResponses {
    DefaultOperationDataProcessor *operationDataProcessor = [[DefaultOperationDataProcessor alloc] init];
    
    id <ProfileTransport> profileTransport = mockProtocol(@protocol(ProfileTransport));
    id <EventTransport> eventTransport = mockProtocol(@protocol(EventTransport));
    id <NotificationTransport> notificationTransport = mockProtocol(@protocol(NotificationTransport));
    id <ConfigurationTransport> configurationTransport = mockProtocol(@protocol(ConfigurationTransport));
    id <UserTransport> userTransport = mockProtocol(@protocol(UserTransport));
    id <LogTransport> logTransport = mockProtocol(@protocol(LogTransport));
    id <RedirectionTransport> redirectionTransport = mockProtocol(@protocol(RedirectionTransport));
    
    [operationDataProcessor setConfigurationTransport:configurationTransport];
    [operationDataProcessor setProfileTransport:profileTransport];
    [operationDataProcessor setEventTransport:eventTransport];
    [operationDataProcessor setNotificationTransport:notificationTransport];
    [operationDataProcessor setUserTransport:userTransport];
    [operationDataProcessor setRedirectionTransport:redirectionTransport];
    [operationDataProcessor setLogTransport:logTransport];
    
    SyncResponse *response = [[SyncResponse alloc] init];
    [response setStatus:SYNC_RESPONSE_RESULT_TYPE_SUCCESS];
    [response setBootstrapSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setProfileSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setConfigurationSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setNotificationSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setUserSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setEventSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setRedirectSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    [response setLogSyncResponse:
     [KAAUnion unionWithBranch:KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_BRANCH_1]];
    
    AvroBytesConverter *converter = [[AvroBytesConverter alloc] init];
    NSData *data = [converter toBytes:response];
    [operationDataProcessor processResponse:data];
    
    [verifyCount(profileTransport, times(0)) onProfileResponse:anything()];
    [verifyCount(eventTransport, times(0)) onEventResponse:anything()];
    [verifyCount(notificationTransport, times(0)) onNotificationResponse:anything()];
    [verifyCount(configurationTransport, times(0)) onConfigurationResponse:anything()];
    [verifyCount(userTransport, times(0)) onUserResponse:anything()];
    [verifyCount(redirectionTransport, times(0)) onRedirectionResponse:anything()];
    [verifyCount(logTransport, times(0)) onLogResponse:anything()];
}

#pragma mark - Supporting methods 

- (NSDictionary *) getDictionaryWithTransportTypesWithBidirectional {
    NSArray *keys = @[[NSNumber numberWithInt:TRANSPORT_TYPE_PROFILE],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_NOTIFICATION],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_USER],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_EVENT],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_LOGGING]];
    NSArray *objects = @[[NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],];
    NSDictionary *transportTypes = [NSDictionary dictionaryWithObjects:objects
                                                               forKeys:keys];
    return transportTypes;
}

- (NSDictionary *) getDictionaryWithTransportTypesWithDownDirection {
    NSArray *keys = @[[NSNumber numberWithInt:TRANSPORT_TYPE_PROFILE],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_NOTIFICATION],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_USER],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_EVENT],
                      [NSNumber numberWithInt:TRANSPORT_TYPE_LOGGING]];
    NSArray *objects = @[[NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN],
                         [NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN],];
    NSDictionary *transportTypes = [NSDictionary dictionaryWithObjects:objects
                                                               forKeys:keys];
    return transportTypes;
}

- (ConfigurationSyncResponse *) getConfigurationResponse {
    ConfigurationSyncResponse *response = [[ConfigurationSyncResponse alloc] init];
    response.appStateSeqNumber = 1;
    response.responseStatus = SYNC_RESPONSE_STATUS_DELTA;
    response.confSchemaBody = [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_1];
    response.confDeltaBody = [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_1];
    return response;
}

- (NotificationSyncResponse *) getNotificationSyncReponse {
    NotificationSyncResponse *response = [[NotificationSyncResponse alloc]init];
    response.appStateSeqNumber = 1;
    response.responseStatus = SYNC_RESPONSE_STATUS_DELTA;
    response.notifications = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_NOTIFICATION_OR_NULL_BRANCH_1];
    response.availableTopics = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_TOPIC_OR_NULL_BRANCH_1];
    return response;
}

- (ProfileSyncResponse *) getProfileSyncResponse {
    ProfileSyncResponse *response = [[ProfileSyncResponse alloc] init];
    response.responseStatus = SYNC_RESPONSE_STATUS_DELTA;
    return response;
}

- (RedirectSyncResponse *) getRedirectSyncReponse {
    RedirectSyncResponse *response = [[RedirectSyncResponse alloc] init];
    response.accessPointId = 1;
    return response;
}

- (LogSyncResponse *) getLogSyncResponse {
    LogDeliveryStatus *status = [[LogDeliveryStatus alloc] init];
    status.requestId = 42;
    status.result = SYNC_RESPONSE_RESULT_TYPE_SUCCESS;
    status.errorCode = [KAAUnion unionWithBranch:KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_BRANCH_1];
    
    LogSyncResponse *response = [[LogSyncResponse alloc] init];
    NSArray *array = [NSArray arrayWithObject:status];
    response.deliveryStatuses = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_BRANCH_0 andData:array];
    return response;
}

- (EventSyncResponse *) getEventSyncResponse {
    EventSyncResponse *response = [[EventSyncResponse alloc] init];
    response.eventSequenceNumberResponse =
    [KAAUnion unionWithBranch:KAA_UNION_EVENT_SEQUENCE_NUMBER_RESPONSE_OR_NULL_BRANCH_1];
    response.eventListenersResponses =
    [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_BRANCH_1];
    response.events = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_1];
    return response;
}

- (UserSyncResponse *) getUserSyncResponse {
    UserSyncResponse *response = [[UserSyncResponse alloc] init];
    response.userAttachResponse =
    [KAAUnion unionWithBranch:KAA_UNION_USER_ATTACH_RESPONSE_OR_NULL_BRANCH_1];
    response.userAttachNotification =
    [KAAUnion unionWithBranch:KAA_UNION_USER_ATTACH_NOTIFICATION_OR_NULL_BRANCH_1];
    response.userDetachNotification =
    [KAAUnion unionWithBranch:KAA_UNION_USER_DETACH_NOTIFICATION_OR_NULL_BRANCH_1];
    response.endpointAttachResponses =
    [KAAUnion unionWithBranch:KAA_UNION_ARRAY_ENDPOINT_ATTACH_RESPONSE_OR_NULL_BRANCH_1];
    response.endpointDetachResponses =
    [KAAUnion unionWithBranch:KAA_UNION_ARRAY_ENDPOINT_DETACH_RESPONSE_OR_NULL_BRANCH_1];
    return response;
}

- (KAAUnion *) getBootstrapResponseUnion {
    KAAUnion *bootstrapUnin = [KAAUnion unionWithBranch:KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_BRANCH_1];
    return bootstrapUnin;
}

- (KAAUnion *) getProfileSyncResponseUnion {
    KAAUnion *profileUnion = [KAAUnion unionWithBranch:KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_BRANCH_0 andData:[self getProfileSyncResponse]];
    return profileUnion;
}

- (KAAUnion *) getConfigurationUnion {
    KAAUnion *confUnion = [KAAUnion unionWithBranch:KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_BRANCH_0 andData:[self getConfigurationResponse]];
    return confUnion;
}

- (KAAUnion *) getNotificationUnion {
    KAAUnion *notifUnion = [KAAUnion unionWithBranch:KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_BRANCH_0 andData:[self getNotificationSyncReponse]];
    return notifUnion;
}

- (KAAUnion *) getUserUnion {
    KAAUnion *userUnion = [KAAUnion unionWithBranch:KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_BRANCH_0 andData:[self getUserSyncResponse]];
    return userUnion;
}

- (KAAUnion *) getEventUnion {
    KAAUnion *eventUnion = [KAAUnion unionWithBranch:KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_BRANCH_0 andData:[self getEventSyncResponse]];
    return eventUnion;
}

- (KAAUnion *) getRedirectUnion {
    KAAUnion *redirectUnion = [KAAUnion unionWithBranch:KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_BRANCH_0 andData:[self getRedirectSyncReponse]];
    return redirectUnion;
}

- (KAAUnion *) getLogUnion {
    KAAUnion *logUnion = [KAAUnion unionWithBranch:KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_BRANCH_0 andData:[self getLogSyncResponse]];
    return logUnion;
}

@end
