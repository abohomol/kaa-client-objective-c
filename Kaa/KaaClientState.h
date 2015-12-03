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
@property(nonatomic) int32_t appStateSequenceNumber;
@property(nonatomic) int32_t configSequenceNumber;
@property(nonatomic) int32_t notificationSequenceNumber;
@property(nonatomic,strong) EndpointObjectHash *profileHash;

@property(nonatomic,strong) NSMutableDictionary *attachedEndpoints; //<EndpointAccessToken, EndpointKeyHash> as key-value
@property(nonatomic,strong) NSString *endpointAccessToken;
@property(atomic) int32_t eventSequenceNumber;
@property(nonatomic) BOOL isAttachedToUser;

- (void)addTopic:(Topic *)topic;
- (void)removeTopic:(NSString *)topicId;
- (BOOL)updateTopicSubscriptionInfo:(NSString *)topicId sequence:(int32_t)sequenceNumber;
- (NSDictionary *)getNfSubscriptions; //<NSString, NSInteger> as key-value.
- (NSArray *)getTopics; //<Topic>
- (int32_t)getAndIncrementEventSequenceNumber;
- (BOOL)isConfigurationVersionUpdated;
- (void)persist;
- (NSString *)refreshEndpointAccessToken;
- (void)clean;

@end

#endif