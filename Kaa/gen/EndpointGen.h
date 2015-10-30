/*
 * Copyright 2014-2015 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * AUTO-GENERATED CODE
 */

#import <Foundation/Foundation.h>
#import "AvroUtils.h"
#import "AvroBased.h"
#import "KAAUnion.h"


# define TOPIC_STATE_FQN @"org.kaaproject.kaa.common.endpoint.gen.TopicState"

@interface TopicState : AvroBased

@property(nonatomic,strong) NSString *topicId;
@property(nonatomic) int32_t seqNumber;

@end


typedef enum {
    SYNC_RESPONSE_STATUS_NO_DELTA,
    SYNC_RESPONSE_STATUS_DELTA,
    SYNC_RESPONSE_STATUS_RESYNC,
} SyncResponseStatus;


typedef enum {
    NOTIFICATION_TYPE_SYSTEM,
    NOTIFICATION_TYPE_CUSTOM,
} NotificationType;


typedef enum {
    SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION,
    SUBSCRIPTION_TYPE_OPTIONAL_SUBSCRIPTION,
} SubscriptionType;


typedef enum {
    SUBSCRIPTION_COMMAND_TYPE_ADD,
    SUBSCRIPTION_COMMAND_TYPE_REMOVE,
} SubscriptionCommandType;


typedef enum {
    SYNC_RESPONSE_RESULT_TYPE_SUCCESS,
    SYNC_RESPONSE_RESULT_TYPE_FAILURE,
    SYNC_RESPONSE_RESULT_TYPE_PROFILE_RESYNC,
    SYNC_RESPONSE_RESULT_TYPE_REDIRECT,
} SyncResponseResultType;


typedef enum {
    LOG_DELIVERY_ERROR_CODE_NO_APPENDERS_CONFIGURED,
    LOG_DELIVERY_ERROR_CODE_APPENDER_INTERNAL_ERROR,
    LOG_DELIVERY_ERROR_CODE_REMOTE_CONNECTION_ERROR,
    LOG_DELIVERY_ERROR_CODE_REMOTE_INTERNAL_ERROR,
} LogDeliveryErrorCode;


typedef enum {
    USER_ATTACH_ERROR_CODE_NO_VERIFIER_CONFIGURED,
    USER_ATTACH_ERROR_CODE_TOKEN_INVALID,
    USER_ATTACH_ERROR_CODE_TOKEN_EXPIRED,
    USER_ATTACH_ERROR_CODE_INTERNAL_ERROR,
    USER_ATTACH_ERROR_CODE_CONNECTION_ERROR,
    USER_ATTACH_ERROR_CODE_REMOTE_ERROR,
    USER_ATTACH_ERROR_CODE_OTHER,
} UserAttachErrorCode;


# define SUBSCRIPTION_COMMAND_FQN @"org.kaaproject.kaa.common.endpoint.gen.SubscriptionCommand"

@interface SubscriptionCommand : AvroBased

@property(nonatomic,strong) NSString *topicId;
@property(nonatomic) SubscriptionCommandType command;

@end


# define USER_ATTACH_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.UserAttachRequest"

@interface UserAttachRequest : AvroBased

@property(nonatomic,strong) NSString *userVerifierId;
@property(nonatomic,strong) NSString *userExternalId;
@property(nonatomic,strong) NSString *userAccessToken;

@end


# define USER_ATTACH_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.UserAttachResponse"

@interface UserAttachResponse : AvroBased

@property(nonatomic) SyncResponseResultType result;
@property(nonatomic,strong) KAAUnion *errorCode;
@property(nonatomic,strong) KAAUnion *errorReason;


# ifndef KAA_UNION_USER_ATTACH_ERROR_CODE_OR_NULL_H_
# define KAA_UNION_USER_ATTACH_ERROR_CODE_OR_NULL_H_

# define KAA_UNION_USER_ATTACH_ERROR_CODE_OR_NULL_BRANCH_0    0
# define KAA_UNION_USER_ATTACH_ERROR_CODE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_USER_ATTACH_ERROR_CODE_OR_NULL_H_


# ifndef KAA_UNION_STRING_OR_NULL_H_
# define KAA_UNION_STRING_OR_NULL_H_

# define KAA_UNION_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_STRING_OR_NULL_H_

@end


# define USER_ATTACH_NOTIFICATION_FQN @"org.kaaproject.kaa.common.endpoint.gen.UserAttachNotification"

@interface UserAttachNotification : AvroBased

@property(nonatomic,strong) NSString *userExternalId;
@property(nonatomic,strong) NSString *endpointAccessToken;

@end


# define USER_DETACH_NOTIFICATION_FQN @"org.kaaproject.kaa.common.endpoint.gen.UserDetachNotification"

@interface UserDetachNotification : AvroBased

@property(nonatomic,strong) NSString *endpointAccessToken;

@end


# define ENDPOINT_ATTACH_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.EndpointAttachRequest"

@interface EndpointAttachRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic,strong) NSString *endpointAccessToken;

@end


# define ENDPOINT_ATTACH_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.EndpointAttachResponse"

@interface EndpointAttachResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic,strong) KAAUnion *endpointKeyHash;
@property(nonatomic) SyncResponseResultType result;


# ifndef KAA_UNION_STRING_OR_NULL_H_
# define KAA_UNION_STRING_OR_NULL_H_

# define KAA_UNION_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_STRING_OR_NULL_H_

@end


# define ENDPOINT_DETACH_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.EndpointDetachRequest"

@interface EndpointDetachRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic,strong) NSString *endpointKeyHash;

@end


# define ENDPOINT_DETACH_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.EndpointDetachResponse"

@interface EndpointDetachResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) SyncResponseResultType result;

@end


# define EVENT_FQN @"org.kaaproject.kaa.common.endpoint.gen.Event"

@interface Event : AvroBased

@property(nonatomic) int32_t seqNum;
@property(nonatomic,strong) NSString *eventClassFQN;
@property(nonatomic,strong) NSData *eventData;
@property(nonatomic,strong) KAAUnion *source;
@property(nonatomic,strong) KAAUnion *target;


# ifndef KAA_UNION_STRING_OR_NULL_H_
# define KAA_UNION_STRING_OR_NULL_H_

# define KAA_UNION_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_STRING_OR_NULL_H_


# ifndef KAA_UNION_STRING_OR_NULL_H_
# define KAA_UNION_STRING_OR_NULL_H_

# define KAA_UNION_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_STRING_OR_NULL_H_

@end


# define EVENT_LISTENERS_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.EventListenersRequest"

@interface EventListenersRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic,strong) NSArray *eventClassFQNs;

@end


# define EVENT_LISTENERS_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.EventListenersResponse"

@interface EventListenersResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic,strong) KAAUnion *listeners;
@property(nonatomic) SyncResponseResultType result;


# ifndef KAA_UNION_ARRAY_STRING_OR_NULL_H_
# define KAA_UNION_ARRAY_STRING_OR_NULL_H_

# define KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_STRING_OR_NULL_H_

@end


# define EVENT_SEQUENCE_NUMBER_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.EventSequenceNumberRequest"

@interface EventSequenceNumberRequest : AvroBased


@end


# define EVENT_SEQUENCE_NUMBER_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.EventSequenceNumberResponse"

@interface EventSequenceNumberResponse : AvroBased

@property(nonatomic) int32_t seqNum;

@end


# define NOTIFICATION_FQN @"org.kaaproject.kaa.common.endpoint.gen.Notification"

@interface Notification : AvroBased

@property(nonatomic,strong) NSString *topicId;
@property(nonatomic) NotificationType type;
@property(nonatomic,strong) KAAUnion *uid;
@property(nonatomic,strong) KAAUnion *seqNumber;
@property(nonatomic,strong) NSData *body;


# ifndef KAA_UNION_STRING_OR_NULL_H_
# define KAA_UNION_STRING_OR_NULL_H_

# define KAA_UNION_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_STRING_OR_NULL_H_


# ifndef KAA_UNION_INT_OR_NULL_H_
# define KAA_UNION_INT_OR_NULL_H_

# define KAA_UNION_INT_OR_NULL_BRANCH_0    0
# define KAA_UNION_INT_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_INT_OR_NULL_H_

@end


# define TOPIC_FQN @"org.kaaproject.kaa.common.endpoint.gen.Topic"

@interface Topic : AvroBased

@property(nonatomic,strong) NSString *id;
@property(nonatomic,strong) NSString *name;
@property(nonatomic) SubscriptionType subscriptionType;

@end


# define LOG_ENTRY_FQN @"org.kaaproject.kaa.common.endpoint.gen.LogEntry"

@interface LogEntry : AvroBased

@property(nonatomic,strong) NSData *data;

@end


# define SYNC_REQUEST_META_DATA_FQN @"org.kaaproject.kaa.common.endpoint.gen.SyncRequestMetaData"

@interface SyncRequestMetaData : AvroBased

@property(nonatomic,strong) NSString *sdkToken;
@property(nonatomic,strong) KAAUnion *endpointPublicKeyHash;
@property(nonatomic,strong) KAAUnion *profileHash;
@property(nonatomic,strong) KAAUnion *timeout;


# ifndef KAA_UNION_BYTES_OR_NULL_H_
# define KAA_UNION_BYTES_OR_NULL_H_

# define KAA_UNION_BYTES_OR_NULL_BRANCH_0    0
# define KAA_UNION_BYTES_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BYTES_OR_NULL_H_


# ifndef KAA_UNION_BYTES_OR_NULL_H_
# define KAA_UNION_BYTES_OR_NULL_H_

# define KAA_UNION_BYTES_OR_NULL_BRANCH_0    0
# define KAA_UNION_BYTES_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BYTES_OR_NULL_H_


# ifndef KAA_UNION_LONG_OR_NULL_H_
# define KAA_UNION_LONG_OR_NULL_H_

# define KAA_UNION_LONG_OR_NULL_BRANCH_0    0
# define KAA_UNION_LONG_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_LONG_OR_NULL_H_

@end


# define PROFILE_SYNC_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.ProfileSyncRequest"

@interface ProfileSyncRequest : AvroBased

@property(nonatomic,strong) KAAUnion *endpointPublicKey;
@property(nonatomic,strong) NSData *profileBody;
@property(nonatomic,strong) KAAUnion *endpointAccessToken;


# ifndef KAA_UNION_BYTES_OR_NULL_H_
# define KAA_UNION_BYTES_OR_NULL_H_

# define KAA_UNION_BYTES_OR_NULL_BRANCH_0    0
# define KAA_UNION_BYTES_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BYTES_OR_NULL_H_


# ifndef KAA_UNION_STRING_OR_NULL_H_
# define KAA_UNION_STRING_OR_NULL_H_

# define KAA_UNION_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_STRING_OR_NULL_H_

@end


# define PROTOCOL_VERSION_PAIR_FQN @"org.kaaproject.kaa.common.endpoint.gen.ProtocolVersionPair"

@interface ProtocolVersionPair : AvroBased

@property(nonatomic) int32_t id;
@property(nonatomic) int32_t version;

@end


# define BOOTSTRAP_SYNC_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.BootstrapSyncRequest"

@interface BootstrapSyncRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic,strong) NSArray *supportedProtocols;

@end


# define CONFIGURATION_SYNC_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.ConfigurationSyncRequest"

@interface ConfigurationSyncRequest : AvroBased

@property(nonatomic) int32_t appStateSeqNumber;
@property(nonatomic,strong) KAAUnion *configurationHash;
@property(nonatomic,strong) KAAUnion *resyncOnly;


# ifndef KAA_UNION_BYTES_OR_NULL_H_
# define KAA_UNION_BYTES_OR_NULL_H_

# define KAA_UNION_BYTES_OR_NULL_BRANCH_0    0
# define KAA_UNION_BYTES_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BYTES_OR_NULL_H_


# ifndef KAA_UNION_BOOLEAN_OR_NULL_H_
# define KAA_UNION_BOOLEAN_OR_NULL_H_

# define KAA_UNION_BOOLEAN_OR_NULL_BRANCH_0    0
# define KAA_UNION_BOOLEAN_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BOOLEAN_OR_NULL_H_

@end


# define NOTIFICATION_SYNC_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.NotificationSyncRequest"

@interface NotificationSyncRequest : AvroBased

@property(nonatomic) int32_t appStateSeqNumber;
@property(nonatomic,strong) KAAUnion *topicListHash;
@property(nonatomic,strong) KAAUnion *topicStates;
@property(nonatomic,strong) KAAUnion *acceptedUnicastNotifications;
@property(nonatomic,strong) KAAUnion *subscriptionCommands;


# ifndef KAA_UNION_BYTES_OR_NULL_H_
# define KAA_UNION_BYTES_OR_NULL_H_

# define KAA_UNION_BYTES_OR_NULL_BRANCH_0    0
# define KAA_UNION_BYTES_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BYTES_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_TOPIC_STATE_OR_NULL_H_
# define KAA_UNION_ARRAY_TOPIC_STATE_OR_NULL_H_

# define KAA_UNION_ARRAY_TOPIC_STATE_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_TOPIC_STATE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_TOPIC_STATE_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_STRING_OR_NULL_H_
# define KAA_UNION_ARRAY_STRING_OR_NULL_H_

# define KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_STRING_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_SUBSCRIPTION_COMMAND_OR_NULL_H_
# define KAA_UNION_ARRAY_SUBSCRIPTION_COMMAND_OR_NULL_H_

# define KAA_UNION_ARRAY_SUBSCRIPTION_COMMAND_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_SUBSCRIPTION_COMMAND_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_SUBSCRIPTION_COMMAND_OR_NULL_H_

@end


# define USER_SYNC_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.UserSyncRequest"

@interface UserSyncRequest : AvroBased

@property(nonatomic,strong) KAAUnion *userAttachRequest;
@property(nonatomic,strong) KAAUnion *endpointAttachRequests;
@property(nonatomic,strong) KAAUnion *endpointDetachRequests;


# ifndef KAA_UNION_USER_ATTACH_REQUEST_OR_NULL_H_
# define KAA_UNION_USER_ATTACH_REQUEST_OR_NULL_H_

# define KAA_UNION_USER_ATTACH_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_USER_ATTACH_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_USER_ATTACH_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_ENDPOINT_ATTACH_REQUEST_OR_NULL_H_
# define KAA_UNION_ARRAY_ENDPOINT_ATTACH_REQUEST_OR_NULL_H_

# define KAA_UNION_ARRAY_ENDPOINT_ATTACH_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_ENDPOINT_ATTACH_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_ENDPOINT_ATTACH_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_ENDPOINT_DETACH_REQUEST_OR_NULL_H_
# define KAA_UNION_ARRAY_ENDPOINT_DETACH_REQUEST_OR_NULL_H_

# define KAA_UNION_ARRAY_ENDPOINT_DETACH_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_ENDPOINT_DETACH_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_ENDPOINT_DETACH_REQUEST_OR_NULL_H_

@end


# define EVENT_SYNC_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.EventSyncRequest"

@interface EventSyncRequest : AvroBased

@property(nonatomic,strong) KAAUnion *eventSequenceNumberRequest;
@property(nonatomic,strong) KAAUnion *eventListenersRequests;
@property(nonatomic,strong) KAAUnion *events;


# ifndef KAA_UNION_EVENT_SEQUENCE_NUMBER_REQUEST_OR_NULL_H_
# define KAA_UNION_EVENT_SEQUENCE_NUMBER_REQUEST_OR_NULL_H_

# define KAA_UNION_EVENT_SEQUENCE_NUMBER_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_EVENT_SEQUENCE_NUMBER_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_EVENT_SEQUENCE_NUMBER_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_EVENT_LISTENERS_REQUEST_OR_NULL_H_
# define KAA_UNION_ARRAY_EVENT_LISTENERS_REQUEST_OR_NULL_H_

# define KAA_UNION_ARRAY_EVENT_LISTENERS_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_EVENT_LISTENERS_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_EVENT_LISTENERS_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_EVENT_OR_NULL_H_
# define KAA_UNION_ARRAY_EVENT_OR_NULL_H_

# define KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_EVENT_OR_NULL_H_

@end


# define LOG_SYNC_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.LogSyncRequest"

@interface LogSyncRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic,strong) KAAUnion *logEntries;


# ifndef KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_H_
# define KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_H_

# define KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_H_

@end


# define PROTOCOL_META_DATA_FQN @"org.kaaproject.kaa.common.endpoint.gen.ProtocolMetaData"

@interface ProtocolMetaData : AvroBased

@property(nonatomic) int32_t accessPointId;
@property(nonatomic,strong) ProtocolVersionPair *protocolVersionInfo;
@property(nonatomic,strong) NSData *connectionInfo;

@end


# define BOOTSTRAP_SYNC_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.BootstrapSyncResponse"

@interface BootstrapSyncResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic,strong) NSArray *supportedProtocols;

@end


# define PROFILE_SYNC_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.ProfileSyncResponse"

@interface ProfileSyncResponse : AvroBased

@property(nonatomic) SyncResponseStatus responseStatus;

@end


# define CONFIGURATION_SYNC_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.ConfigurationSyncResponse"

@interface ConfigurationSyncResponse : AvroBased

@property(nonatomic) int32_t appStateSeqNumber;
@property(nonatomic) SyncResponseStatus responseStatus;
@property(nonatomic,strong) KAAUnion *confSchemaBody;
@property(nonatomic,strong) KAAUnion *confDeltaBody;


# ifndef KAA_UNION_BYTES_OR_NULL_H_
# define KAA_UNION_BYTES_OR_NULL_H_

# define KAA_UNION_BYTES_OR_NULL_BRANCH_0    0
# define KAA_UNION_BYTES_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BYTES_OR_NULL_H_


# ifndef KAA_UNION_BYTES_OR_NULL_H_
# define KAA_UNION_BYTES_OR_NULL_H_

# define KAA_UNION_BYTES_OR_NULL_BRANCH_0    0
# define KAA_UNION_BYTES_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BYTES_OR_NULL_H_

@end


# define NOTIFICATION_SYNC_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.NotificationSyncResponse"

@interface NotificationSyncResponse : AvroBased

@property(nonatomic) int32_t appStateSeqNumber;
@property(nonatomic) SyncResponseStatus responseStatus;
@property(nonatomic,strong) KAAUnion *notifications;
@property(nonatomic,strong) KAAUnion *availableTopics;


# ifndef KAA_UNION_ARRAY_NOTIFICATION_OR_NULL_H_
# define KAA_UNION_ARRAY_NOTIFICATION_OR_NULL_H_

# define KAA_UNION_ARRAY_NOTIFICATION_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_NOTIFICATION_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_NOTIFICATION_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_TOPIC_OR_NULL_H_
# define KAA_UNION_ARRAY_TOPIC_OR_NULL_H_

# define KAA_UNION_ARRAY_TOPIC_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_TOPIC_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_TOPIC_OR_NULL_H_

@end


# define USER_SYNC_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.UserSyncResponse"

@interface UserSyncResponse : AvroBased

@property(nonatomic,strong) KAAUnion *userAttachResponse;
@property(nonatomic,strong) KAAUnion *userAttachNotification;
@property(nonatomic,strong) KAAUnion *userDetachNotification;
@property(nonatomic,strong) KAAUnion *endpointAttachResponses;
@property(nonatomic,strong) KAAUnion *endpointDetachResponses;


# ifndef KAA_UNION_USER_ATTACH_RESPONSE_OR_NULL_H_
# define KAA_UNION_USER_ATTACH_RESPONSE_OR_NULL_H_

# define KAA_UNION_USER_ATTACH_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_USER_ATTACH_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_USER_ATTACH_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_USER_ATTACH_NOTIFICATION_OR_NULL_H_
# define KAA_UNION_USER_ATTACH_NOTIFICATION_OR_NULL_H_

# define KAA_UNION_USER_ATTACH_NOTIFICATION_OR_NULL_BRANCH_0    0
# define KAA_UNION_USER_ATTACH_NOTIFICATION_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_USER_ATTACH_NOTIFICATION_OR_NULL_H_


# ifndef KAA_UNION_USER_DETACH_NOTIFICATION_OR_NULL_H_
# define KAA_UNION_USER_DETACH_NOTIFICATION_OR_NULL_H_

# define KAA_UNION_USER_DETACH_NOTIFICATION_OR_NULL_BRANCH_0    0
# define KAA_UNION_USER_DETACH_NOTIFICATION_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_USER_DETACH_NOTIFICATION_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_ENDPOINT_ATTACH_RESPONSE_OR_NULL_H_
# define KAA_UNION_ARRAY_ENDPOINT_ATTACH_RESPONSE_OR_NULL_H_

# define KAA_UNION_ARRAY_ENDPOINT_ATTACH_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_ENDPOINT_ATTACH_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_ENDPOINT_ATTACH_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_ENDPOINT_DETACH_RESPONSE_OR_NULL_H_
# define KAA_UNION_ARRAY_ENDPOINT_DETACH_RESPONSE_OR_NULL_H_

# define KAA_UNION_ARRAY_ENDPOINT_DETACH_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_ENDPOINT_DETACH_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_ENDPOINT_DETACH_RESPONSE_OR_NULL_H_

@end


# define EVENT_SYNC_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.EventSyncResponse"

@interface EventSyncResponse : AvroBased

@property(nonatomic,strong) KAAUnion *eventSequenceNumberResponse;
@property(nonatomic,strong) KAAUnion *eventListenersResponses;
@property(nonatomic,strong) KAAUnion *events;


# ifndef KAA_UNION_EVENT_SEQUENCE_NUMBER_RESPONSE_OR_NULL_H_
# define KAA_UNION_EVENT_SEQUENCE_NUMBER_RESPONSE_OR_NULL_H_

# define KAA_UNION_EVENT_SEQUENCE_NUMBER_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_EVENT_SEQUENCE_NUMBER_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_EVENT_SEQUENCE_NUMBER_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_H_
# define KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_H_

# define KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_ARRAY_EVENT_OR_NULL_H_
# define KAA_UNION_ARRAY_EVENT_OR_NULL_H_

# define KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_EVENT_OR_NULL_H_

@end


# define LOG_DELIVERY_STATUS_FQN @"org.kaaproject.kaa.common.endpoint.gen.LogDeliveryStatus"

@interface LogDeliveryStatus : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) SyncResponseResultType result;
@property(nonatomic,strong) KAAUnion *errorCode;


# ifndef KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_H_
# define KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_H_

# define KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_BRANCH_0    0
# define KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_H_

@end


# define LOG_SYNC_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.LogSyncResponse"

@interface LogSyncResponse : AvroBased

@property(nonatomic,strong) KAAUnion *deliveryStatuses;


# ifndef KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_H_
# define KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_H_

# define KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_H_

@end


# define REDIRECT_SYNC_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.RedirectSyncResponse"

@interface RedirectSyncResponse : AvroBased

@property(nonatomic) int32_t accessPointId;

@end


# define SYNC_REQUEST_FQN @"org.kaaproject.kaa.common.endpoint.gen.SyncRequest"

@interface SyncRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic,strong) KAAUnion *syncRequestMetaData;
@property(nonatomic,strong) KAAUnion *bootstrapSyncRequest;
@property(nonatomic,strong) KAAUnion *profileSyncRequest;
@property(nonatomic,strong) KAAUnion *configurationSyncRequest;
@property(nonatomic,strong) KAAUnion *notificationSyncRequest;
@property(nonatomic,strong) KAAUnion *userSyncRequest;
@property(nonatomic,strong) KAAUnion *eventSyncRequest;
@property(nonatomic,strong) KAAUnion *logSyncRequest;


# ifndef KAA_UNION_SYNC_REQUEST_META_DATA_OR_NULL_H_
# define KAA_UNION_SYNC_REQUEST_META_DATA_OR_NULL_H_

# define KAA_UNION_SYNC_REQUEST_META_DATA_OR_NULL_BRANCH_0    0
# define KAA_UNION_SYNC_REQUEST_META_DATA_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_SYNC_REQUEST_META_DATA_OR_NULL_H_


# ifndef KAA_UNION_BOOTSTRAP_SYNC_REQUEST_OR_NULL_H_
# define KAA_UNION_BOOTSTRAP_SYNC_REQUEST_OR_NULL_H_

# define KAA_UNION_BOOTSTRAP_SYNC_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_BOOTSTRAP_SYNC_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BOOTSTRAP_SYNC_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_PROFILE_SYNC_REQUEST_OR_NULL_H_
# define KAA_UNION_PROFILE_SYNC_REQUEST_OR_NULL_H_

# define KAA_UNION_PROFILE_SYNC_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_PROFILE_SYNC_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_PROFILE_SYNC_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_CONFIGURATION_SYNC_REQUEST_OR_NULL_H_
# define KAA_UNION_CONFIGURATION_SYNC_REQUEST_OR_NULL_H_

# define KAA_UNION_CONFIGURATION_SYNC_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_CONFIGURATION_SYNC_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_CONFIGURATION_SYNC_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_NOTIFICATION_SYNC_REQUEST_OR_NULL_H_
# define KAA_UNION_NOTIFICATION_SYNC_REQUEST_OR_NULL_H_

# define KAA_UNION_NOTIFICATION_SYNC_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_NOTIFICATION_SYNC_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_NOTIFICATION_SYNC_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_USER_SYNC_REQUEST_OR_NULL_H_
# define KAA_UNION_USER_SYNC_REQUEST_OR_NULL_H_

# define KAA_UNION_USER_SYNC_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_USER_SYNC_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_USER_SYNC_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_EVENT_SYNC_REQUEST_OR_NULL_H_
# define KAA_UNION_EVENT_SYNC_REQUEST_OR_NULL_H_

# define KAA_UNION_EVENT_SYNC_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_EVENT_SYNC_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_EVENT_SYNC_REQUEST_OR_NULL_H_


# ifndef KAA_UNION_LOG_SYNC_REQUEST_OR_NULL_H_
# define KAA_UNION_LOG_SYNC_REQUEST_OR_NULL_H_

# define KAA_UNION_LOG_SYNC_REQUEST_OR_NULL_BRANCH_0    0
# define KAA_UNION_LOG_SYNC_REQUEST_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_LOG_SYNC_REQUEST_OR_NULL_H_

@end


# define SYNC_RESPONSE_FQN @"org.kaaproject.kaa.common.endpoint.gen.SyncResponse"

@interface SyncResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) SyncResponseResultType status;
@property(nonatomic,strong) KAAUnion *bootstrapSyncResponse;
@property(nonatomic,strong) KAAUnion *profileSyncResponse;
@property(nonatomic,strong) KAAUnion *configurationSyncResponse;
@property(nonatomic,strong) KAAUnion *notificationSyncResponse;
@property(nonatomic,strong) KAAUnion *userSyncResponse;
@property(nonatomic,strong) KAAUnion *eventSyncResponse;
@property(nonatomic,strong) KAAUnion *redirectSyncResponse;
@property(nonatomic,strong) KAAUnion *logSyncResponse;


# ifndef KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_H_
# define KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_H_

# define KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_BOOTSTRAP_SYNC_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_H_
# define KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_H_

# define KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_PROFILE_SYNC_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_H_
# define KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_H_

# define KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_CONFIGURATION_SYNC_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_H_
# define KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_H_

# define KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_NOTIFICATION_SYNC_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_H_
# define KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_H_

# define KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_USER_SYNC_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_H_
# define KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_H_

# define KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_EVENT_SYNC_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_H_
# define KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_H_

# define KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_REDIRECT_SYNC_RESPONSE_OR_NULL_H_


# ifndef KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_H_
# define KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_H_

# define KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_BRANCH_0    0
# define KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_LOG_SYNC_RESPONSE_OR_NULL_H_

@end


# define TOPIC_SUBSCRIPTION_INFO_FQN @"org.kaaproject.kaa.common.endpoint.gen.TopicSubscriptionInfo"

@interface TopicSubscriptionInfo : AvroBased

@property(nonatomic,strong) Topic *topicInfo;
@property(nonatomic) int32_t seqNumber;

@end
