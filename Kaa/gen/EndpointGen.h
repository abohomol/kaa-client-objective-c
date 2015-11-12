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


@interface TopicState : AvroBased

@property(nonatomic) NSString * topicId;
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


@interface SubscriptionCommand : AvroBased

@property(nonatomic) NSString * topicId;
@property(nonatomic) SubscriptionCommandType command;

@end


@interface UserAttachRequest : AvroBased

@property(nonatomic) NSString * userVerifierId;
@property(nonatomic) NSString * userExternalId;
@property(nonatomic) NSString * userAccessToken;

@end


@interface UserAttachResponse : AvroBased

@property(nonatomic) SyncResponseResultType result;
@property(nonatomic) KAAUnion * errorCode;
@property(nonatomic) KAAUnion * errorReason;


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


@interface UserAttachNotification : AvroBased

@property(nonatomic) NSString * userExternalId;
@property(nonatomic) NSString * endpointAccessToken;

@end


@interface UserDetachNotification : AvroBased

@property(nonatomic) NSString * endpointAccessToken;

@end


@interface EndpointAttachRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) NSString * endpointAccessToken;

@end


@interface EndpointAttachResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) KAAUnion * endpointKeyHash;
@property(nonatomic) SyncResponseResultType result;


# ifndef KAA_UNION_STRING_OR_NULL_H_
# define KAA_UNION_STRING_OR_NULL_H_

# define KAA_UNION_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_STRING_OR_NULL_H_

@end


@interface EndpointDetachRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) NSString * endpointKeyHash;

@end


@interface EndpointDetachResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) SyncResponseResultType result;

@end


@interface Event : AvroBased

@property(nonatomic) int32_t seqNum;
@property(nonatomic) NSString * eventClassFQN;
@property(nonatomic) NSData * eventData;
@property(nonatomic) KAAUnion * source;
@property(nonatomic) KAAUnion * target;


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


@interface EventListenersRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) NSArray * eventClassFQNs;

@end


@interface EventListenersResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) KAAUnion * listeners;
@property(nonatomic) SyncResponseResultType result;


# ifndef KAA_UNION_ARRAY_STRING_OR_NULL_H_
# define KAA_UNION_ARRAY_STRING_OR_NULL_H_

# define KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_STRING_OR_NULL_H_

@end


@interface EventSequenceNumberRequest : AvroBased


@end


@interface EventSequenceNumberResponse : AvroBased

@property(nonatomic) int32_t seqNum;

@end


@interface Notification : AvroBased

@property(nonatomic) NSString * topicId;
@property(nonatomic) NotificationType type;
@property(nonatomic) KAAUnion * uid;
@property(nonatomic) KAAUnion * seqNumber;
@property(nonatomic) NSData * body;


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


@interface Topic : AvroBased

@property(nonatomic) NSString * id;
@property(nonatomic) NSString * name;
@property(nonatomic) SubscriptionType subscriptionType;

@end


@interface LogEntry : AvroBased

@property(nonatomic) NSData * data;

@end


@interface SyncRequestMetaData : AvroBased

@property(nonatomic) NSString * sdkToken;
@property(nonatomic) KAAUnion * endpointPublicKeyHash;
@property(nonatomic) KAAUnion * profileHash;
@property(nonatomic) KAAUnion * timeout;


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


@interface ProfileSyncRequest : AvroBased

@property(nonatomic) KAAUnion * endpointPublicKey;
@property(nonatomic) NSData * profileBody;
@property(nonatomic) KAAUnion * endpointAccessToken;


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


@interface ProtocolVersionPair : AvroBased

@property(nonatomic) int32_t id;
@property(nonatomic) int32_t version;

@end


@interface BootstrapSyncRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) NSArray * supportedProtocols;

@end


@interface ConfigurationSyncRequest : AvroBased

@property(nonatomic) int32_t appStateSeqNumber;
@property(nonatomic) KAAUnion * configurationHash;
@property(nonatomic) KAAUnion * resyncOnly;


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


@interface NotificationSyncRequest : AvroBased

@property(nonatomic) int32_t appStateSeqNumber;
@property(nonatomic) KAAUnion * topicListHash;
@property(nonatomic) KAAUnion * topicStates;
@property(nonatomic) KAAUnion * acceptedUnicastNotifications;
@property(nonatomic) KAAUnion * subscriptionCommands;


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


@interface UserSyncRequest : AvroBased

@property(nonatomic) KAAUnion * userAttachRequest;
@property(nonatomic) KAAUnion * endpointAttachRequests;
@property(nonatomic) KAAUnion * endpointDetachRequests;


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


@interface EventSyncRequest : AvroBased

@property(nonatomic) KAAUnion * eventSequenceNumberRequest;
@property(nonatomic) KAAUnion * eventListenersRequests;
@property(nonatomic) KAAUnion * events;


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


@interface LogSyncRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) KAAUnion * logEntries;


# ifndef KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_H_
# define KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_H_

# define KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_LOG_ENTRY_OR_NULL_H_

@end


@interface ProtocolMetaData : AvroBased

@property(nonatomic) int32_t accessPointId;
@property(nonatomic,strong) ProtocolVersionPair *protocolVersionInfo;
@property(nonatomic) NSData * connectionInfo;

@end


@interface BootstrapSyncResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) NSArray * supportedProtocols;

@end


@interface ProfileSyncResponse : AvroBased

@property(nonatomic) SyncResponseStatus responseStatus;

@end


@interface ConfigurationSyncResponse : AvroBased

@property(nonatomic) int32_t appStateSeqNumber;
@property(nonatomic) SyncResponseStatus responseStatus;
@property(nonatomic) KAAUnion * confSchemaBody;
@property(nonatomic) KAAUnion * confDeltaBody;


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


@interface NotificationSyncResponse : AvroBased

@property(nonatomic) int32_t appStateSeqNumber;
@property(nonatomic) SyncResponseStatus responseStatus;
@property(nonatomic) KAAUnion * notifications;
@property(nonatomic) KAAUnion * availableTopics;


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


@interface UserSyncResponse : AvroBased

@property(nonatomic) KAAUnion * userAttachResponse;
@property(nonatomic) KAAUnion * userAttachNotification;
@property(nonatomic) KAAUnion * userDetachNotification;
@property(nonatomic) KAAUnion * endpointAttachResponses;
@property(nonatomic) KAAUnion * endpointDetachResponses;


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


@interface EventSyncResponse : AvroBased

@property(nonatomic) KAAUnion * eventSequenceNumberResponse;
@property(nonatomic) KAAUnion * eventListenersResponses;
@property(nonatomic) KAAUnion * events;


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


@interface LogDeliveryStatus : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) SyncResponseResultType result;
@property(nonatomic) KAAUnion * errorCode;


# ifndef KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_H_
# define KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_H_

# define KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_BRANCH_0    0
# define KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_LOG_DELIVERY_ERROR_CODE_OR_NULL_H_

@end


@interface LogSyncResponse : AvroBased

@property(nonatomic) KAAUnion * deliveryStatuses;


# ifndef KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_H_
# define KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_H_

# define KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_BRANCH_0    0
# define KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_BRANCH_1    1

# endif // KAA_UNION_ARRAY_LOG_DELIVERY_STATUS_OR_NULL_H_

@end


@interface RedirectSyncResponse : AvroBased

@property(nonatomic) int32_t accessPointId;

@end


@interface SyncRequest : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) KAAUnion * syncRequestMetaData;
@property(nonatomic) KAAUnion * bootstrapSyncRequest;
@property(nonatomic) KAAUnion * profileSyncRequest;
@property(nonatomic) KAAUnion * configurationSyncRequest;
@property(nonatomic) KAAUnion * notificationSyncRequest;
@property(nonatomic) KAAUnion * userSyncRequest;
@property(nonatomic) KAAUnion * eventSyncRequest;
@property(nonatomic) KAAUnion * logSyncRequest;


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


@interface SyncResponse : AvroBased

@property(nonatomic) int32_t requestId;
@property(nonatomic) SyncResponseResultType status;
@property(nonatomic) KAAUnion * bootstrapSyncResponse;
@property(nonatomic) KAAUnion * profileSyncResponse;
@property(nonatomic) KAAUnion * configurationSyncResponse;
@property(nonatomic) KAAUnion * notificationSyncResponse;
@property(nonatomic) KAAUnion * userSyncResponse;
@property(nonatomic) KAAUnion * eventSyncResponse;
@property(nonatomic) KAAUnion * redirectSyncResponse;
@property(nonatomic) KAAUnion * logSyncResponse;


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


@interface TopicSubscriptionInfo : AvroBased

@property(nonatomic,strong) Topic *topicInfo;
@property(nonatomic) int32_t seqNumber;

@end
