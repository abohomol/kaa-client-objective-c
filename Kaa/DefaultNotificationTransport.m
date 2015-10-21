//
//  DefaultNotificationTransport.m
//  Kaa
//
//  Created by Anton Bohomol on 9/17/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultNotificationTransport.h"
#import "KaaLogging.h"

#define TAG @"DefaultNotificationTransport >>>"

@interface DefaultNotificationTransport ()

@property (nonatomic,strong) id<NotificationProcessor> nfProcessor;
@property (copy) NSComparisonResult (^nfComparator)(Notification *first, Notification *second);
@property (nonatomic,strong) NSMutableSet *acceptedUnicastNotificationIds;  //<NSString>
@property (nonatomic,strong) NSMutableArray *sentNotificationCommands;      //<SubscriptionCommand>

- (NSArray *)getTopicStates;
- (NSArray *)getUnicastNotifications:(NSArray *)notifications;
- (NSArray *)getMulticastNotifications:(NSArray *)notifications;

@end

@implementation DefaultNotificationTransport

- (instancetype)init {
    self = [super init];
    if (self) {
        self.acceptedUnicastNotificationIds = [NSMutableSet set];
        self.sentNotificationCommands = [NSMutableArray array];
        
        self.nfComparator = ^NSComparisonResult (Notification *first, Notification *second) {
            return [first.seqNumber.data intValue] - [second.seqNumber.data intValue];
        };
    }
    return self;
}

- (NotificationSyncRequest *)createEmptyNotificationRequest {
    if (!self.clientState) {
        return nil;
    }
    
    NotificationSyncRequest *request = [[NotificationSyncRequest alloc] init];
    request.appStateSeqNumber = [self.clientState notificationSequenceNumber];
    request.topicStates = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_TOPIC_STATE_OR_NULL_BRANCH_0 andData:[self getTopicStates]];
    request.acceptedUnicastNotifications = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_1];
    request.topicListHash = [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_1];
    request.subscriptionCommands = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_SUBSCRIPTION_COMMAND_OR_NULL_BRANCH_1];
    return request;
}

- (NotificationSyncRequest *)createNotificationRequest {
    if (!self.clientState) {
        return nil;
    }
    
    NotificationSyncRequest *request = [[NotificationSyncRequest alloc] init];
    request.appStateSeqNumber = [self.clientState notificationSequenceNumber];
    if ([self.acceptedUnicastNotificationIds count] > 0) {
        DDLogInfo(@"%@ Accepted unicast Notifications: %li", TAG,
                  (long)[self.acceptedUnicastNotificationIds count]);
        request.acceptedUnicastNotifications = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_0
                                                                 andData:[self.acceptedUnicastNotificationIds allObjects]];
    } else {
        request.acceptedUnicastNotifications = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_1];
    }
    
    request.topicStates = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_TOPIC_STATE_OR_NULL_BRANCH_0
                                            andData:[self getTopicStates]];
    request.topicListHash = [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_1];
    request.subscriptionCommands = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_SUBSCRIPTION_COMMAND_OR_NULL_BRANCH_0
                                                     andData:self.sentNotificationCommands];
    return request;
}

- (void)onNotificationResponse:(NotificationSyncResponse *)response {
    if (!self.nfProcessor || !self.clientState) {
        DDLogWarn(@"%@ Unable to process NotificationSyncResponse: invalid params", TAG);
        return;
    }
    
    if (response.responseStatus == SYNC_RESPONSE_STATUS_NO_DELTA) {
        [self.acceptedUnicastNotificationIds removeAllObjects];
    }
    
    if (response.availableTopics && response.availableTopics.branch == KAA_UNION_ARRAY_TOPIC_OR_NULL_BRANCH_0) {
        NSArray *topics = response.availableTopics.data;
        for (Topic *topic in topics) {
            [self.clientState addTopic:topic];
        }
        [self.nfProcessor topicsListUpdated:topics];
    }
    
    if (response.notifications && response.notifications.branch == KAA_UNION_ARRAY_NOTIFICATION_OR_NULL_BRANCH_0) {
        NSArray *notifications = response.notifications.data;
        NSMutableArray *newNotifications = [NSMutableArray array];
        
        NSArray *unicastNotifications = [self getUnicastNotifications:notifications];
        NSArray *multicastNotifications = [self getMulticastNotifications:notifications];
        
        for (Notification *notification in unicastNotifications) {
            DDLogInfo(@"%@ Received unicast: %@", TAG, notification);
            if (!notification.uid || notification.uid.branch == KAA_UNION_STRING_OR_NULL_BRANCH_1) {
                DDLogWarn(@"%@ No UID for notification with topic id: %@", TAG, notification.topicId);
                continue;
            }
            if ([self.acceptedUnicastNotificationIds containsObject:notification.uid.data]) {
                DDLogInfo(@"%@ Notification with uid [%@] was already received", TAG, notification.uid.data);
            } else {
                [self.acceptedUnicastNotificationIds addObject:notification.uid.data];
                [newNotifications addObject:notification];
            }
        }
        
        for (Notification *notification in multicastNotifications) {
            DDLogInfo(@"%@ Received multicast: %@", TAG, notification);
            if (!notification.seqNumber || notification.seqNumber.branch == KAA_UNION_INT_OR_NULL_BRANCH_1) {
                DDLogWarn(@"%@ No seq.num for notification with topicId: %@", TAG, notification.topicId);
                continue;
            }
            NSNumber *seqNumber = notification.seqNumber.data;
            if ([self.clientState updateTopicSubscriptionInfo:notification.topicId sequence:[seqNumber intValue]]) {
                [newNotifications addObject:notification];
            } else {
                DDLogInfo(@"%@ Notification with seq number [%i] was already received", TAG, [seqNumber intValue]);
            }
        }
        
        [self.nfProcessor notificationReceived:newNotifications];
    }
    
    @synchronized(self.sentNotificationCommands) {
        [self.sentNotificationCommands removeAllObjects];
    }
    [self.clientState setNotificationSequenceNumber:response.appStateSeqNumber];
    
    [self syncAck:response.responseStatus];
    
    DDLogInfo(@"%@ Processed notification response", TAG);
}

- (void)onSubscriptionChanged:(NSArray *)commands {
    @synchronized(self.sentNotificationCommands) {
        [self.sentNotificationCommands addObjectsFromArray:commands];
    }
}

- (void)setNotificationProcessor:(id<NotificationProcessor>)processor {
    self.nfProcessor = processor;
}

- (TransportType)getTransportType {
    return TRANSPORT_TYPE_NOTIFICATION;
}

- (NSArray *)getUnicastNotifications:(NSArray *)notifications {
    NSMutableArray *result = [NSMutableArray array];
    for (Notification *notification in notifications) {
        if (notification.uid && notification.uid.branch == KAA_UNION_STRING_OR_NULL_BRANCH_0) {
            [result addObject:notification];
        }
    }
    return result;
}

- (NSArray *)getMulticastNotifications:(NSArray *)notifications {
    NSMutableArray *result = [NSMutableArray array];
    for (Notification *notification in notifications) {
        if (!notification.uid || notification.uid.branch == KAA_UNION_STRING_OR_NULL_BRANCH_1) {
            [result addObject:notification];
        }
    }
    return [result sortedArrayUsingComparator:self.nfComparator];
}

- (NSMutableArray *)getTopicStates {
    NSMutableArray *states = nil;
    NSDictionary *nfSubscriptions = [self.clientState getNfSubscriptions];
    if ([nfSubscriptions count] > 0) {
        states = [NSMutableArray array];
        DDLogInfo(@"%@ Topic States:", TAG);
        for (NSString *key in nfSubscriptions.allKeys) {
            TopicState *state = [[TopicState alloc] init];
            state.topicId = key;
            state.seqNumber = [[nfSubscriptions objectForKey:key] intValue];
            [states addObject:state];
            DDLogInfo(@"%@ %@ : %i", TAG, state.topicId, state.seqNumber);
        }
    }
    return states;
}

@end
