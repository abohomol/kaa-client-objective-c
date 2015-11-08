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

#define BUILD_VERSION_KEY           @"build.version"
#define BUILD_COMMIT_HASH_KEY       @"build.commit_hash"
#define TRANSPORT_POLL_DELAY_KEY    @"transport.poll.initial_delay"
#define TRANSPORT_POLL_PERIOD_KEY   @"transport.poll.period"
#define TRANSPORT_POLL_UNIT_KEY     @"transport.poll.unit"
#define BOOTSTRAP_SERVERS_KEY       @"transport.bootstrap.servers"
#define CONFIG_DATA_DEFAULT_KEY     @"config.data.default"
#define CONFIG_SCHEMA_DEFAULT_KEY   @"config.schema.default"
#define STATE_FILE_LOCATION_KEY     @"state.file.location"
#define SDK_TOKEN_KEY               @"sdk_token"

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
