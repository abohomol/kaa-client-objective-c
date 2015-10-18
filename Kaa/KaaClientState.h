//
//  KaaClientState.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_KaaClientState_h
#define Kaa_KaaClientState_h

#import <Security/Security.h>
#import "EndpointKeyHash.h"
#import "EndpointObjectHash.h"
#import "EndpointGen.h"

@protocol KaaClientState

@property(nonatomic) BOOL isRegistred;
@property(readonly,nonatomic) SecKeyRef privateKey;
@property(readonly,nonatomic) SecKeyRef publicKey;
@property(nonatomic,strong,readonly) EndpointKeyHash *endpointKeyHash;
@property(nonatomic) NSInteger appStateSequenceNumber;
@property(nonatomic) NSInteger configSequenceNumber;
@property(nonatomic) NSInteger notificationSequenceNumber;
@property(nonatomic,strong) EndpointObjectHash *profileHash;

@property(nonatomic,strong) NSMutableDictionary *attachedEndpoints; //<EndpointAccessToken, EndpointKeyHash> as key-value
@property(nonatomic,strong) NSString *endpointAccessToken;
@property(atomic) int eventSequenceNumber;
@property(nonatomic) BOOL isAttachedToUser;

- (void)addTopic:(Topic *)topic;
- (void)removeTopic:(NSString *)topicId;
- (BOOL)updateTopicSubscriptionInfo:(NSString *)topicId sequence:(int)sequenceNumber;
- (NSDictionary *)getNfSubscriptions; //<NSString, NSInteger> as key-value.
- (NSArray *)getTopics; //<Topic>
- (int)getAndIncrementEventSequenceNumber;
- (BOOL)isConfigurationVersionUpdated;
- (void)persist;
- (NSString *)refreshEndpointAccessToken;
- (void)clean;

@end

#endif