//
//  KaaClientProperties.m
//  Kaa
//
//  Created by Anton Bohomol on 8/17/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "KaaClientProperties.h"
#import "NSString+Commons.h"
#import "EndpointGen.h"
#import "TransportProtocolId.h"
#import "GenericTransportInfo.h"
#import "TransportCommon.h"
#import "SHAMessageDigest.h"

#define DEFAULT_CLIENT_PROPERTIES @"client_properties"

@interface KaaClientProperties ()

@property(nonatomic,strong) NSUserDefaults *properties;
@property(nonatomic,strong) id<KAABase64> base64;
@property(nonatomic,strong) NSData *cachedPropertiesHash;

- (NSDictionary *)loadProperties;
- (NSDictionary *)parseBootstrapServers:(NSString *)serversStr;

@end

@implementation KaaClientProperties

- (instancetype)initWithDictionary:(NSDictionary *)defaults base64:(id<KAABase64>)base64 {
    self = [super init];
    if (self) {
        self.properties = [NSUserDefaults standardUserDefaults];
        for (NSString *key in defaults) {
            [self.properties setObject:[defaults objectForKey:key] forKey:key];
        }
        self.base64 = base64;
    }
    return self;
}

- (instancetype)initDefaults:(id<KAABase64>)base64 {
    self = [super init];
    if (self) {
        self.properties = [NSUserDefaults standardUserDefaults];
        [self.properties registerDefaults:[self loadProperties]];
        self.base64 = base64;
    }
    return self;
}

- (NSData *)propertiesHash {
    if (!self.cachedPropertiesHash) {
        SHAMessageDigest *digest = [[SHAMessageDigest alloc] init];
        [digest updateWithString:[self.properties objectForKey:TRANSPORT_POLL_DELAY]];
        [digest updateWithString:[self.properties objectForKey:TRANSPORT_POLL_PERIOD]];
        [digest updateWithString:[self.properties objectForKey:TRANSPORT_POLL_UNIT]];
        [digest updateWithString:[self.properties objectForKey:BOOTSTRAP_SERVERS]];
        [digest updateWithString:[self.properties objectForKey:CONFIG_DATA_DEFAULT]];
        [digest updateWithString:[self.properties objectForKey:CONFIG_SCHEMA_DEFAULT]];
        [digest updateWithString:[self.properties objectForKey:SDK_TOKEN]];
        self.cachedPropertiesHash = [NSMutableData dataWithBytes:[digest final] length:[digest size]];
    }
    return self.cachedPropertiesHash;
}

- (NSData *)propertyAsData:(NSString *)property {
    return [[self.properties objectForKey:property] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)loadProperties {
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"KaaResources" withExtension:@"bundle"]];
    NSString *clientProperties = [bundle pathForResource:KAA_CLIENT_PROPERTIES_FILE ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:clientProperties]) {
        clientProperties = [bundle pathForResource:DEFAULT_CLIENT_PROPERTIES ofType:@"plist"];
    }
    return [NSMutableDictionary dictionaryWithContentsOfFile:clientProperties];
}

- (NSDictionary *)parseBootstrapServers:(NSString *)serversStr {
    NSMutableDictionary *servers = [NSMutableDictionary dictionary];
    NSArray *splittedServers = [serversStr componentsSeparatedByString:@";"];
    for (NSString *server in splittedServers) {
        if (server && server.length > 0) {
            NSArray *tokens = [server componentsSeparatedByString:@":"];
            ProtocolMetaData *metaData = [[ProtocolMetaData alloc] init];
            [metaData setAccessPointId:[[tokens objectAtIndex:0] intValue]];
            ProtocolVersionPair *versionInfo = [[ProtocolVersionPair alloc] init];
            versionInfo.id = [[tokens objectAtIndex:1] intValue];
            versionInfo.version = [[tokens objectAtIndex:2] intValue];
            [metaData setProtocolVersionInfo:versionInfo];
            [metaData setConnectionInfo:[self.base64 decodeString:[tokens objectAtIndex:3]]];
            TransportProtocolId *key = [[TransportProtocolId alloc] initWithId:versionInfo.id andVersion:versionInfo.version];
            NSMutableArray *serverList = [servers objectForKey:key];
            if (!serverList) {
                serverList = [NSMutableArray array];
                [servers setObject:serverList forKey:key];
            }
            [serverList addObject:[[GenericTransportInfo alloc] initWithServerType:SERVER_BOOTSTRAP andMeta:metaData]];
        }
    }
    return servers;
}

- (NSDictionary *)bootstrapServers {
    return [self parseBootstrapServers:[self.properties stringForKey:BOOTSTRAP_SERVERS]];
}

- (NSString *)buildVersion {
    return [self.properties stringForKey:BUILD_VERSION];
}

- (NSString *)commitHash {
    return [self.properties stringForKey:BUILD_COMMIT_HASH];
}

- (NSString *)sdkToken {
    return [self.properties stringForKey:SDK_TOKEN];
}

- (NSInteger)pollDelay {
    return [[self.properties stringForKey:TRANSPORT_POLL_DELAY] intValue];
}

- (NSInteger)pollPeriod {
    return [[self.properties stringForKey:TRANSPORT_POLL_PERIOD] intValue];
}

- (TimeUnit)pollUnit {
    return (TimeUnit)[[self.properties stringForKey:TRANSPORT_POLL_UNIT] intValue];
}

- (NSData *)defaultConfigData {
    NSString *schema = [self.properties stringForKey:CONFIG_DATA_DEFAULT];
    if (!schema) {
        return nil;
    }
    return [self.base64 decodeBase64:[schema dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData *)defaultConfigSchema {
    NSString *schema = [self.properties stringForKey:CONFIG_SCHEMA_DEFAULT];
    if (!schema) {
        return nil;
    }
    return [schema dataUsingEncoding:NSUTF8StringEncoding]; 
}

- (NSString *)stringForKey:(NSString *)key {
    return [self.properties stringForKey:key];
}

- (void)setString:(NSString *)object forKey:(NSString *)key {
    [self.properties setObject:object forKey:key];
}

@end
