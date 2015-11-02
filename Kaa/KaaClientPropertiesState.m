//
//  KaaClientPropertiesState.m
//  Kaa
//
//  Created by Anton Bohomol on 9/6/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "KaaClientPropertiesState.h"
#import "KeyPair.h"
#import "EndpointAccessToken.h"
#import "EndpointKeyHash.h"
#import "AvroBytesConverter.h"
#import "EndpointGen.h"
#import "NSData+Conversion.h"
#import "UUID.h"
#import "KeyUtils.h"
#import "KaaLogging.h"

#define TAG @"KaaClientPropertiesState >>>"

#define APP_STATE_SEQ_NUMBER    @"APP_STATE_SEQ_NUMBER"
#define CONFIG_SEQ_NUMBER       @"CONFIG_SEQ_NUMBER"
#define NOTIFICATION_SEQ_NUMBER @"NOTIFICATION_SEQ_NUMBER"
#define PROFILE_HASH            @"PROFILE_HASH"
#define ENDPOINT_ACCESS_TOKEN   @"ENDPOINT_ACCESS_TOKEN"

#define ATTACHED_ENDPOINTS      @"attached_eps"
#define NF_SUBSCRIPTIONS        @"nf_subscriptions"
#define IS_REGISTERED           @"is_registered"
#define IS_ATTACHED             @"is_attached"
#define EVENT_SEQ_NUM           @"event.seq.num"
#define PROPERTIES_HASH         @"properties.hash"

@interface KaaClientPropertiesState ()

@property (nonatomic,strong) id<KAABase64> base64;
@property (nonatomic,strong) NSMutableDictionary *state;
@property (nonatomic,strong) NSString *stateFileLocation;
@property (nonatomic,strong) NSMutableDictionary *nfSubscriptions;  //<NSString, TopicSubscriptionInfo> as key-value
@property (nonatomic,strong) KeyPair *keyPair;
@property (nonatomic) BOOL isConfigVersionUpdated;

- (void)setPropertiesHash:(NSData *)hash;
- (BOOL)isSDKProperyListUpdated:(KaaClientProperties *)sdkProperties;
- (void)parseNfSubscriptions;
- (KeyPair *)getOrGenerateKeyPair;
- (void)deleteFileAtPath:(NSString *)path;

@end

@implementation KaaClientPropertiesState

@synthesize isRegistred = _isRegistred;
@synthesize privateKey = _privateKey;
@synthesize publicKey = _publicKey;
@synthesize endpointKeyHash = _endpointKeyHash;
@synthesize appStateSequenceNumber = _appStateSequenceNumber;
@synthesize configSequenceNumber = _configSequenceNumber;
@synthesize notificationSequenceNumber = _notificationSequenceNumber;
@synthesize profileHash = _profileHash;
@synthesize attachedEndpoints = _attachedEndpoints;
@synthesize endpointAccessToken = _endpointAccessToken;
@synthesize eventSequenceNumber = _eventSequenceNumber;
@synthesize isAttachedToUser = _isAttachedToUser;

- (instancetype)initWith:(id<KAABase64>)base64 andClientProperties:(KaaClientProperties *)properties {
    self = [super init];
    if (self) {
        self.base64 = base64;
        self.nfSubscriptions = [NSMutableDictionary dictionary];
        self.attachedEndpoints = [NSMutableDictionary dictionary];
        self.isConfigVersionUpdated = NO;
        
        NSString *storage = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
        NSString *stateFileName = [properties stringForKey:STATE_FILE_LOCATION];
        if (!stateFileName) {
            stateFileName = STATE_FILE_DEFAULT;
        }
        self.stateFileLocation = [[[NSURL fileURLWithPath:storage] URLByAppendingPathComponent:stateFileName] path];
        DDLogInfo(@"%@ Version: [%@], commit hash: [%@]", TAG, [properties buildVersion], [properties commitHash]);
        
        self.state = [NSMutableDictionary dictionary];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:self.stateFileLocation]) {
            //TODO ensure stateFileLocation is PLIST and it has correct path for both iOS and OS X
            @try {
                self.state = [[NSMutableDictionary alloc] initWithContentsOfFile:self.stateFileLocation];
                if ([self isSDKProperyListUpdated:properties]) {
                    DDLogInfo(@"%@ SDK properties were updated", TAG);
                    [self setIsRegistred:NO];
                    [self setPropertiesHash:[properties propertiesHash]];
                } else {
                    DDLogInfo(@"%@ SDK properties are up to date", TAG);
                }
                [self parseNfSubscriptions];
                
                NSString *attachedEndpointsString = [self.state objectForKey:ATTACHED_ENDPOINTS];
                if (attachedEndpointsString) {
                    NSArray *endpointsList = [attachedEndpointsString componentsSeparatedByString:@","];
                    for (NSString *attachedEndpoint in endpointsList) {
                        if (attachedEndpoint.length <= 0) {
                            continue;
                        }
                        NSArray *splittedValues = [attachedEndpoint componentsSeparatedByString:@":"];
                        EndpointKeyHash *keyHash = [[EndpointKeyHash alloc] initWithKeyHash:[splittedValues objectAtIndex:1]];
                        EndpointAccessToken *token = [[EndpointAccessToken alloc] initWithToken:[splittedValues objectAtIndex:0]];
                        [self.attachedEndpoints setObject:keyHash forKey:token];
                    }
                }
                
                NSString *eventSeqNumStr = [self.state objectForKey:EVENT_SEQ_NUM];
                if (eventSeqNumStr) {
                    int eventSeqNum = [eventSeqNumStr intValue];
                    if (eventSeqNum == 0) {
                        DDLogError(@"%@ Error occurred parsing event sequence number. Can not parse %@ to integer", TAG, eventSeqNumStr);
                    }
                    self.eventSequenceNumber = eventSeqNum;
                }
            }
            @catch (NSException *exception) {
                DDLogError(@"%@ Can't load state file. Error name: %@. Error reason: %@",
                           TAG, exception.name, exception.reason);
            }
        } else {
            DDLogInfo(@"%@ First SDK start!", TAG);
            [self setPropertiesHash:properties.propertiesHash];
        }
    }
    return self;
}

- (BOOL)isConfigurationVersionUpdated {
    return self.isConfigVersionUpdated;
}

- (BOOL)isRegistred {
    NSString *value = [self.state objectForKey:IS_REGISTERED];
    return value ? [value boolValue] : NO;
}

- (void)setIsRegistred:(BOOL)isRegistred {
    [self.state setObject:(isRegistred ? @"Y" : @"N") forKey:IS_REGISTERED];
}

- (void)persist {
    NSMutableData *encodedData = [NSMutableData data];
    NSArray *subcscriptions = self.nfSubscriptions.allValues;
    @try {
        for (TopicSubscriptionInfo *info in subcscriptions) {
            size_t infoSize = [info getSize];
            char *buffer = (char *)malloc((infoSize) * sizeof(char));
            avro_writer_t writer = avro_writer_memory(buffer, infoSize);
            if (!writer) {
                DDLogError(@"%@ Unable to allocate '%li'bytes for avro writer during persisting", TAG, infoSize);
                continue;
            }
            [info serialize:writer];
            [encodedData appendBytes:writer->buf length:writer->written];
            avro_writer_free(writer);
            DDLogInfo(@"%@ Persisted %@", TAG, info);
        }
        NSData *base64Encoded = [self.base64 encodeBase64:encodedData];
        NSString *base64Str = [[NSString alloc] initWithData:base64Encoded encoding:NSUTF8StringEncoding];
        [self.state setObject:base64Str forKey:NF_SUBSCRIPTIONS];
    }
    @catch (NSException *ex) {
        DDLogError(@"%@ Can't persist notification subscription info. Encoded data: %@", TAG, [encodedData hexadecimalString]);
        DDLogError(@"%@ Error name: %@, reason: %@", TAG, ex.name, ex.reason);
    }
    
    NSMutableString *attachedEndpointsString = [NSMutableString string];
    NSArray *keys = self.attachedEndpoints.allKeys;
    for (EndpointAccessToken *key in keys) {
        EndpointKeyHash *value = [self.attachedEndpoints objectForKey:key];
        [attachedEndpointsString appendString:[NSString stringWithFormat:@"%@:%@,", key.token, value.keyHash]];
    }
    [self.state setObject:attachedEndpointsString forKey:ATTACHED_ENDPOINTS];
    [self.state setObject:[NSString stringWithFormat:@"%i", self.eventSequenceNumber] forKey:EVENT_SEQ_NUM];
    
    @try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *backup = [NSString stringWithFormat:@"%@_bckp", self.stateFileLocation];
        BOOL backupResult = [fileManager copyItemAtPath:self.stateFileLocation toPath:backup error:nil];
        DDLogDebug(@"%@ Backup created: %d", TAG, backupResult);
        
        BOOL result = [self.state writeToFile:self.stateFileLocation atomically:YES];
        DDLogDebug(@"%@ Persist finished with result: %d", TAG, result);
    }
    @catch (NSException *exception) {
        DDLogError(@"%@ Can't persist state file. Error: %@, reason: %@", TAG, exception.name, exception.reason);
    }
}

- (NSString *)refreshEndpointAccessToken {
    NSString *newAccessToken = [UUID randomUUID];
    [self setEndpointAccessToken:newAccessToken];
    return newAccessToken;
}

- (SecKeyRef)publicKey {
    return [[self getOrGenerateKeyPair] getPublicKeyRef];
}

- (SecKeyRef)privateKey {
    return [[self getOrGenerateKeyPair] getPrivateKeyRef];
}

- (EndpointKeyHash *)endpointKeyHash {
    if (!self.endpointKeyHash) {
        
        //to ensure key pair generated
        [self getOrGenerateKeyPair];
        
        EndpointObjectHash *publicKeyHash = [EndpointObjectHash fromSHA1:[KeyUtils getPublicKey]];
        NSString *base64Str = [[NSString alloc] initWithData:[self.base64 encodeBase64:publicKeyHash.data] encoding:NSUTF8StringEncoding];
        _endpointKeyHash = [[EndpointKeyHash alloc] initWithKeyHash:base64Str];
    }
    return self.endpointKeyHash;
}

- (int32_t)appStateSequenceNumber {
    NSString *value = [self.state objectForKey:APP_STATE_SEQ_NUMBER];
    return value ? (int32_t)[value integerValue] : 1;
}

- (EndpointObjectHash *)profileHash {
    NSString *hash = [self.state objectForKey:PROFILE_HASH];
    if (!hash) {
        hash = [[NSString alloc] initWithData:[self.base64 encodeBase64:[NSData data]] encoding:NSUTF8StringEncoding];
    }
    return [EndpointObjectHash fromBytes:[self.base64 decodeBase64:[hash dataUsingEncoding:NSUTF8StringEncoding]]];
}

- (void)setAppStateSequenceNumber:(int32_t)appStateSequenceNumber {
    [self.state setObject:[@(appStateSequenceNumber) stringValue] forKey:APP_STATE_SEQ_NUMBER];
}

- (void)setProfileHash:(EndpointObjectHash *)profileHash {
    NSData *base64Data = [self.base64 encodeBase64:profileHash.data];
    NSString *base64Str = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    [self.state setObject:base64Str forKey:PROFILE_HASH];
}

- (void)addTopic:(Topic *)topic {
    TopicSubscriptionInfo *info = [self.nfSubscriptions objectForKey:topic.id];
    if (!info) {
        info = [[TopicSubscriptionInfo alloc] init];
        info.topicInfo = topic;
        info.seqNumber = 0;
        [self.nfSubscriptions setObject:info forKey:topic.id];
        DDLogInfo(@"%@ Adding new seqNumber 0 for %@ subscription", TAG, topic.id);
    }
}

- (void)removeTopic:(NSString *)topicId {
    [self.nfSubscriptions removeObjectForKey:topicId];
    DDLogDebug(@"%@ Removed subscription info for %@", TAG, topicId);
}

- (BOOL)updateTopicSubscriptionInfo:(NSString *)topicId sequence:(int)sequenceNumber {
    TopicSubscriptionInfo *info = [self.nfSubscriptions objectForKey:topicId];
    BOOL updated = NO;
    if (info && sequenceNumber > info.seqNumber) {
        updated = YES;
        info.seqNumber = sequenceNumber;
        [self.nfSubscriptions setObject:info forKey:topicId];
        DDLogDebug(@"%@ Updated seqNumber to %i for %@ subscription", TAG, sequenceNumber, topicId);
    }
    return updated;
}

- (NSDictionary *)getNfSubscriptions {
    NSMutableDictionary *subscriptions = [NSMutableDictionary dictionary];
    for (NSString *key in self.nfSubscriptions.allKeys) {
        TopicSubscriptionInfo *value = [self.nfSubscriptions objectForKey:key];
        [subscriptions setObject:[NSNumber numberWithInt:value.seqNumber] forKey:key];
    }
    return subscriptions;
}

- (NSArray *)getTopics {
    NSMutableArray *topics = [NSMutableArray array];
    for (TopicSubscriptionInfo *info in self.nfSubscriptions.allValues) {
        [topics addObject:info.topicInfo];
    }
    return topics;
}

- (void)setAttachedEndpoints:(NSMutableDictionary *)attachedEndpoints {
    [self.attachedEndpoints removeAllObjects];
    [self.attachedEndpoints addEntriesFromDictionary:attachedEndpoints];
}

- (void)setEndpointAccessToken:(NSString *)endpointAccessToken {
    [self.state setObject:endpointAccessToken forKey:ENDPOINT_ACCESS_TOKEN];
}

- (NSString *)endpointAccessToken {
    NSString *token = [self.state objectForKey:ENDPOINT_ACCESS_TOKEN];
    return token ? token : @"";
}

- (void)setConfigSequenceNumber:(int32_t)configSequenceNumber {
    [self.state setObject:[@(configSequenceNumber) stringValue] forKey:CONFIG_SEQ_NUMBER];
}

- (int32_t)configSequenceNumber {
    NSString *number = [self.state objectForKey:CONFIG_SEQ_NUMBER];
    return (int32_t)[(number ? number : @"1") integerValue];
}

- (void)setNotificationSequenceNumber:(int32_t)notificationSequenceNumber {
    [self.state setObject:[@(notificationSequenceNumber) stringValue] forKey:NOTIFICATION_SEQ_NUMBER];
}

- (int32_t)notificationSequenceNumber {
    NSString *number = [self.state objectForKey:NOTIFICATION_SEQ_NUMBER];
    return (int32_t)[(number ? number : @"1") integerValue];
}

- (int32_t)getAndIncrementEventSequenceNumber {
    return self.eventSequenceNumber++;
}

- (BOOL)isAttachedToUser {
    NSString *value = [self.state objectForKey:IS_ATTACHED];
    return value ? [value boolValue] : NO;
}

- (void)setIsAttachedToUser:(BOOL)isAttachedToUser {
    [self.state setObject:(isAttachedToUser ? @"Y" : @"N") forKey:IS_ATTACHED];
}

- (void)clean {
    [self setIsRegistred:NO];
    [self deleteFileAtPath:self.stateFileLocation];
    [self deleteFileAtPath:[NSString stringWithFormat:@"%@_bckp", self.stateFileLocation]];
}

- (void)setPropertiesHash:(NSData *)hash {
    NSData *encodedHash = [self.base64 encodeBase64:hash];
    [self.state setObject:[[NSString alloc] initWithData:encodedHash encoding:NSUTF8StringEncoding] forKey:PROPERTIES_HASH];
}

- (BOOL)isSDKProperyListUpdated:(KaaClientProperties *)sdkProperties {
    NSData *hashFromSDK = [sdkProperties propertiesHash];
    NSString *stateHash = [self.state objectForKey:PROPERTIES_HASH];
    if (!stateHash) {
        NSData *emptyData = [self.base64 encodeBase64:[NSData data]];
        stateHash = [[NSString alloc] initWithData:emptyData encoding:NSUTF8StringEncoding];
    }
    NSData *hashFromStateFile = [self.base64 decodeBase64:[stateHash dataUsingEncoding:NSUTF8StringEncoding]];
    return ![hashFromSDK isEqualToData:hashFromStateFile];
}

- (void)parseNfSubscriptions {
    NSString *subscriptionInfo = [self.state objectForKey:NF_SUBSCRIPTIONS];
    if (subscriptionInfo) {
        NSData *data = [self.base64 decodeString:subscriptionInfo];
        TopicSubscriptionInfo *decodedInfo = nil;
        avro_reader_t reader = avro_reader_memory([data bytes], [data length]);
        @try {
            while (reader->read < reader->len) {
                decodedInfo = [[TopicSubscriptionInfo alloc] init];
                [decodedInfo deserialize:reader];
                DDLogDebug(@"%@ Loaded %@", TAG, decodedInfo);
                if (decodedInfo) {
                    [self.nfSubscriptions setObject:decodedInfo forKey:decodedInfo.topicInfo.id];
                }
            }
        }
        @catch (NSException *exception) {
            DDLogError(@"%@ Error occurred while reading information from decoder: %@", TAG, [data hexadecimalString]);
        }
        avro_reader_free(reader);
    } else {
        DDLogInfo(@"%@ No subscription info found in state", TAG);
    }
}

- (KeyPair *)getOrGenerateKeyPair {
    if (self.keyPair) {
        return self.keyPair;
    }
    
    SecKeyRef private = [KeyUtils getPrivateKeyRef];
    SecKeyRef public = [KeyUtils getPublicKeyRef];
    if (private != NULL && public != NULL) {
        DDLogDebug(@"%@ Found existing key pair", TAG);
        self.keyPair = [[KeyPair alloc] initWithPrivate:private andPublic:public];
        return self.keyPair;
    }
    
    DDLogDebug(@"%@ Generating new key pair", TAG);
    self.keyPair = [KeyUtils generateKeyPair];
    return self.keyPair;
}

- (void)deleteFileAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:path error:NULL] == NO) {
        DDLogWarn(@"%@ Unable to remove file at path: %@", TAG, path);
    }
}

@end
