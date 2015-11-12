//
//  DefaultOperationDataProcessor.m
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultOperationDataProcessor.h"
#import "AvroBytesConverter.h"
#import "KaaLogging.h"

#define TAG @"DefaultOperationDataProcessor >>>"

@interface DefaultOperationDataProcessor ()

@property (nonatomic,strong) AvroBytesConverter *requestConverter;
@property (nonatomic,strong) AvroBytesConverter *responseConverter;

@property (atomic) int requestsCounter;

@property (nonatomic,strong) id<MetaDataTransport> mdTransport;
@property (nonatomic,strong) id<ConfigurationTransport> configurationTransport;
@property (nonatomic,strong) id<EventTransport> eventTransport;
@property (nonatomic,strong) id<NotificationTransport> notificationTransport;
@property (nonatomic,strong) id<ProfileTransport> profileTransport;
@property (nonatomic,strong) id<UserTransport> userTransport;
@property (nonatomic,strong) id<RedirectionTransport> redirectionTransport;
@property (nonatomic,strong) id<LogTransport> logTransport;

@end

@implementation DefaultOperationDataProcessor

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestConverter = [[AvroBytesConverter alloc] init];
        self.responseConverter = [[AvroBytesConverter alloc] init];
    }
    return self;
    
}

- (void)setRedirectionTransport:(id<RedirectionTransport>)transport {
    @synchronized(self) {
        _redirectionTransport = transport;
    }
}

- (void)setMetaDataTransport:(id<MetaDataTransport>)transport {
    @synchronized(self) {
        self.mdTransport = transport;
    }
}

- (void)setConfigurationTransport:(id<ConfigurationTransport>)transport {
    @synchronized(self) {
        _configurationTransport = transport;
    }
}

- (void)setEventTransport:(id<EventTransport>)transport {
    @synchronized(self) {
        _eventTransport = transport;
    }
}

- (void)setNotificationTransport:(id<NotificationTransport>)transport {
    @synchronized(self) {
        _notificationTransport = transport;
    }
}

- (void)setProfileTransport:(id<ProfileTransport>)transport {
    @synchronized(self) {
        _profileTransport = transport;
    }
}

- (void)setUserTransport:(id<UserTransport>)transport {
    @synchronized(self) {
        _userTransport = transport;
    }
}

- (void)setLogTransport:(id<LogTransport>)transport {
    @synchronized(self) {
        _logTransport = transport;
    }
}

- (void)processResponse:(NSData *)data {
    @synchronized(self) {
        if (!data) {
            DDLogError(@"%@ Can't process nil response", TAG);
            return;
        }
        
        SyncResponse *syncResponse = (SyncResponse *)[self.responseConverter fromBytes:data object:[[SyncResponse alloc] init]];
        
        DDLogInfo(@"%@ Received Sync response: %@", TAG, syncResponse);
        if (self.configurationTransport && syncResponse.configurationSyncResponse
            && syncResponse.configurationSyncResponse.branch == KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_BRANCH_0) {
            [self.configurationTransport onConfigurationResponse:syncResponse.configurationSyncResponse.data];
        }
        if (self.eventTransport) {
            [self.eventTransport onSyncResposeIdReceived:syncResponse.requestId];
            if (syncResponse.eventSyncResponse
                && syncResponse.eventSyncResponse.branch == KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_BRANCH_0) {
                [self.eventTransport onEventResponse:syncResponse.eventSyncResponse.data];
            }
        }
        if (self.notificationTransport && syncResponse.notificationSyncResponse
            && syncResponse.notificationSyncResponse.branch == KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_BRANCH_0) {
            [self.notificationTransport onNotificationResponse:syncResponse.notificationSyncResponse.data];
        }
        if (self.userTransport && syncResponse.userSyncResponse
            && syncResponse.userSyncResponse.branch == KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_BRANCH_0) {
            [self.userTransport onUserResponse:syncResponse.userSyncResponse.data];
        }
        if (self.redirectionTransport && syncResponse.redirectSyncResponse
            && syncResponse.redirectSyncResponse.branch == KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_BRANCH_0) {
            [self.redirectionTransport onRedirectionResponse:syncResponse.redirectSyncResponse.data];
        }
        if (self.profileTransport && syncResponse.profileSyncResponse
            && syncResponse.profileSyncResponse.branch == KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_BRANCH_0) {
            [self.profileTransport onProfileResponse:syncResponse.profileSyncResponse.data];
        }
        if (self.logTransport && syncResponse.logSyncResponse
            && syncResponse.logSyncResponse.branch == KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_BRANCH_0) {
            [self.logTransport onLogResponse:syncResponse.logSyncResponse.data];
        }
    }
}

- (NSData *)compileRequest:(NSDictionary *)types {
    @synchronized(self) {
        if (!types) {
            DDLogError(@"%@ Can't compile request with empty types list", TAG);
            return nil;
        }
        
        SyncRequest *request = [[SyncRequest alloc] init];
        self.requestsCounter++;
        request.requestId = self.requestsCounter;
        
        if (self.mdTransport) {
            SyncRequestMetaData *mdRequest = [self.mdTransport createMetaDataRequest];
            if (mdRequest) {
                request.syncRequestMetaData = [KAAUnion unionWithBranch:KAA_UNION_SYNC_REQUEST_META_DATA_OR_NULL_BRANCH_0
                                                                andData:mdRequest];
            }
        }
        
        for (NSNumber *key in types.allKeys) {
            BOOL isDownDirection = [[types objectForKey:key] intValue] == CHANNEL_DIRECTION_DOWN;
            switch ([key intValue]) {
                case TRANSPORT_TYPE_CONFIGURATION:
                    if (self.configurationTransport) {
                        ConfigurationSyncRequest *cfRequest = [self.configurationTransport createConfigurationRequest];
                        if (cfRequest) {
                            request.configurationSyncRequest =
                            [KAAUnion unionWithBranch:KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_BRANCH_0
                                              andData:cfRequest];
                        }
                    }
                    break;
                case TRANSPORT_TYPE_EVENT:
                {
                    KAAUnion *eventUnion;
                    if (isDownDirection) {
                        eventUnion = [KAAUnion unionWithBranch:KAA_UNION_EVENT_SYNC_REQUEST_OR_NULL_BRANCH_0
                                                       andData:[[EventSyncRequest alloc] init]];
                    } else if (self.eventTransport) {
                        EventSyncRequest *evRequest = [self.eventTransport createEventRequest:request.requestId];
                        if (evRequest) {
                            eventUnion = [KAAUnion unionWithBranch:KAA_UNION_EVENT_SYNC_REQUEST_OR_NULL_BRANCH_0
                                                           andData:evRequest];
                        }
                    }
                    request.eventSyncRequest = eventUnion;
                }
                    break;
                case TRANSPORT_TYPE_NOTIFICATION:
                {
                    if (self.notificationTransport) {
                        NotificationSyncRequest *nfRequest;
                        if (isDownDirection) {
                            nfRequest = [self.notificationTransport createEmptyNotificationRequest];
                        } else {
                            nfRequest = [self.notificationTransport createNotificationRequest];
                        }
                        if (nfRequest) {
                            request.notificationSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_NOTIFICATION_SYNC_REQUEST_OR_NULL_BRANCH_0
                                                                                andData:nfRequest];
                        }
                    }
                }
                    break;
                case TRANSPORT_TYPE_PROFILE:
                    if (!isDownDirection && self.profileTransport) {
                        ProfileSyncRequest *pfRequest = [self.profileTransport createProfileRequest];
                        if (pfRequest) {
                            request.profileSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_PROFILE_SYNC_REQUEST_OR_NULL_BRANCH_0
                                                                           andData:pfRequest];
                        }
                    }
                    break;
                case TRANSPORT_TYPE_USER:
                {
                    UserSyncRequest *userRequest = nil;
                    if (isDownDirection) {
                        userRequest = [[UserSyncRequest alloc] init];
                    } else if (self.userTransport) {
                        userRequest = [self.userTransport createUserRequest];
                    }
                    if (userRequest) {
                        request.userSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_USER_SYNC_REQUEST_OR_NULL_BRANCH_0
                                                                    andData:userRequest];
                    }
                }
                    break;
                case TRANSPORT_TYPE_LOGGING:
                {
                    LogSyncRequest *logRequest = nil;
                    if (isDownDirection) {
                        logRequest = [[LogSyncRequest alloc] init];
                    } else if (self.logTransport) {
                        logRequest = [self.logTransport createLogRequest];
                    }
                    if (logRequest) {
                        request.logSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_LOG_SYNC_REQUEST_OR_NULL_BRANCH_0
                                                                   andData:logRequest];
                    }
                }
                    break;
                default:
                    DDLogError(@"%@ Invalid transport type: [%i]", TAG, [key intValue]);
                    return nil;
                    break;
            }
        }
        DDLogInfo(@"%@ Created Sync request: %@", TAG, request);
        return [self.requestConverter toBytes:request];
    }
}

- (void)preProcess {
    if (self.eventTransport) {
        [self.eventTransport blockEventManager];
    }
}

- (void)postProcess {
    if (self.eventTransport) {
        [self.eventTransport releaseEventManager];
    }
}

@end
