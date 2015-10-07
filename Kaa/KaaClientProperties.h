//
//  KaaClientProperties.h
//  Kaa
//
//  Created by Anton Bohomol on 8/17/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KAABase64.h"
#import "TimeCommons.h"

#define KAA_CLIENT_PROPERTIES_FILE @"kaaClientPropertiesFile"
#define BUILD_VERSION @"build.version"
#define BUILD_COMMIT_HASH @"build.commit_hash"
#define TRANSPORT_POLL_DELAY @"transport.poll.initial_delay"
#define TRANSPORT_POLL_PERIOD @"transport.poll.period"
#define TRANSPORT_POLL_UNIT @"transport.poll.unit"
#define BOOTSTRAP_SERVERS @"transport.bootstrap.servers"
#define CONFIG_DATA_DEFAULT @"config.data.default"
#define CONFIG_SCHEMA_DEFAULT @"config.schema.default"
#define SDK_TOKEN @"sdk_token"

@interface KaaClientProperties : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)defaults base64:(id<KAABase64>)base64;

- (instancetype)initDefaults:(id<KAABase64>)base64;

- (NSData *)propertiesHash;

- (NSString *)buildVersion;

- (NSString *)commitHash;

- (NSString *)sdkToken;

- (NSInteger)pollDelay;

- (NSInteger)pollPeriod;

- (TimeUnit)pollUnit;

- (NSData *)defaultConfigData;

- (NSData *)defaultConfigSchema;

- (NSDictionary *)bootstrapServers; //<TransportProtocolId, NSArray<TransportConnectionInfo>> as key-value

- (NSString *)stringForKey:(NSString *)key;

- (void)setString:(NSString *)object forKey:(NSString *)key;

@end
