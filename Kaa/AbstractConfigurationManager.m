//
//  AbstractConfigurationManager.m
//  Kaa
//
//  Created by Anton Bohomol on 8/20/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AbstractConfigurationManager.h"
#import "KaaLogging.h"

#define TAG @"AbstractConfigurationManager >>>"

@interface AbstractConfigurationManager ()

@property(nonatomic,strong) KaaClientProperties *properties;
@property(nonatomic,strong) id<ConfigurationStorage> storage;
@property(nonatomic,strong) NSData *configurationData;

@property(strong) NSMutableSet *delegates;
@property(strong) NSLock *delegatesLock;

- (NSData *)loadConfigurationData;

@end

@implementation AbstractConfigurationManager

- (instancetype)initWithClientProperties:(KaaClientProperties *)properties {
    self = [super init];
    if (self) {
        self.delegates = [NSMutableSet set];
        self.properties = properties;
        _deserializer = [[ConfigurationDeserializer alloc] init];
    }
    return self;
}

- (void)initiate {
    [self getConfigurationData];
    DDLogDebug(@"%@ Configuration manager init completed!", TAG);
}

- (void)addDelegate:(id<ConfigurationDelegate>)delegate {
    if (delegate) {
        DDLogVerbose(@"%@ Adding delegate %@", TAG, delegate);
        [self.delegatesLock lock];
        [self.delegates addObject:delegate];
        [self.delegatesLock unlock];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Can't add nil delegate"];
    }
}

- (void)removeDelegate:(id<ConfigurationDelegate>)delegate {
    if (delegate) {
        DDLogVerbose(@"%@ Removing delegate", TAG);
        [self.delegatesLock lock];
        [self.delegates removeObject:delegate];
        [self.delegatesLock unlock];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Can't remove nil delegate"];

    }
}

- (void)processConfigurationData:(NSData *)data fullResync:(BOOL)fullResync {
    if (fullResync) {
        self.configurationData = data;
        DDLogVerbose(@"%@ Received configuration data: %@", TAG, self.configurationData);
        if (self.storage) {
            DDLogDebug(@"%@ Persisting configuration data from storage: %@", TAG, self.storage);
            [self.storage saveConfiguration:self.configurationData];
            DDLogDebug(@"%@ Persisted configuration data from storage: %@", TAG, self.storage);
        }
        [self.delegatesLock lock];
        [_deserializer notify:self.delegates withData:self.configurationData];
        [self.delegatesLock unlock];
    } else {
        DDLogWarn(@"%@ Only full resync delta is supported!", TAG);
    }
}

- (EndpointObjectHash *)getConfigurationHash {
    return [EndpointObjectHash fromSHA1:[self getConfigurationData]];
}

- (void)setConfigurationStorage:(id<ConfigurationStorage>)storage {
    self.storage = storage;
}

- (NSData *)loadConfigurationData {
    if (self.storage) {
        DDLogDebug(@"%@ Loading configuration data from storage: %@", TAG, self.storage);
        @try {
            self.configurationData = [self.storage loadConfiguration];
        }
        @catch (NSException *exception) {
            DDLogError(@"%@ Failed to load configuration from storage: %@", TAG, exception);
        }
    }
    if (!self.configurationData) {
        DDLogDebug(@"%@ Loading configuration data from defaults: %@", TAG, self.storage);
        self.configurationData = [self getDefaultConfiguratioData];
    }
    DDLogVerbose(@"%@ Loaded configuration data: %@", TAG, self.configurationData);
    return self.configurationData;
}

- (NSData *)getConfigurationData {
    if (!self.configurationData) {
        self.configurationData = [self loadConfigurationData];
    }
    return self.configurationData;
}

- (NSData *)getDefaultConfiguratioData {
    return [self.properties defaultConfigData];
}

- (KAAConfiguration *)getConfiguration {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class!"];
    return nil;
}

@end
