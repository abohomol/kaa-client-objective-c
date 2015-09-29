//
//  SimpleConfigurationStorage.m
//  Kaa
//
//  Created by Anton Bohomol on 9/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "SimpleConfigurationStorage.h"
#import "NSData+Conversion.h"
#import "KaaLogging.h"

#define TAG @"SimpleConfigurationStorage >>>"
#define _8KB (1024 * 8)

@interface SimpleConfigurationStorage ()

@property (nonatomic,strong) id<KaaClientPlatformContext> context;
@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) NSFileManager *fileManager;

@end

@implementation SimpleConfigurationStorage

- (instancetype)initWithPlatformContext:(id<KaaClientPlatformContext>)context andPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.context = context;
        self.path = path;
        self.fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)saveConfiguration:(NSData *)buffer {
    DDLogVerbose(@"%@ Writing bytes to file: %@", TAG, [buffer hexadecimalString]);
    [self.fileManager createFileAtPath:self.path contents:buffer attributes:nil];
}

- (void)clearConfiguration {
    NSError *error;
    if ([self.fileManager isDeletableFileAtPath:self.path]) {
        BOOL success = [self.fileManager removeItemAtPath:self.path error:&error];
        if (!success) {
            DDLogInfo(@"%@ Deleting failed with error: %@", TAG, error);
        }
    } else {
        DDLogInfo(@"%@ File doesn't exist at path or doesn't have delete privileges", TAG);
    }
    
}

- (NSData *)loadConfiguration {
    if (![self.fileManager fileExistsAtPath:self.path]) {
        DDLogInfo(@"%@ There is no configuration in storage yet", TAG);
        return nil;
    }
    NSFileHandle *configFile = nil;
    NSMutableArray *chunks = [NSMutableArray array];
    int bytesRead = 0;
    @try {
        unsigned long long fileSize = [[self.fileManager attributesOfItemAtPath:self.path error:NULL] fileSize];
        configFile = [NSFileHandle fileHandleForReadingAtPath:self.path];
        if (!configFile) {
            [NSException raise:@"UnableOpenFile" format:@"Failed to open configuration file"];
        }
        NSData *buffer = nil;
        do {
            [configFile seekToFileOffset:bytesRead];
            buffer = [configFile readDataOfLength:_8KB];
            if ([buffer length] > 0) {
                bytesRead += [buffer length];
                [chunks addObject:buffer];
            }
            
        } while ([buffer length] == _8KB && bytesRead < fileSize);
        
    }
    @catch (NSException *exception) {
        DDLogError(@"%@ Error loading configuration: %@. Reason: %@", TAG, exception.name, exception.reason);
    }
    @finally {
        if (configFile) {
            [configFile closeFile];
        }
    }
    NSMutableData *configuration = nil;
    if (bytesRead > 0) {
        configuration = [NSMutableData data];
        for (NSData *chunk in chunks) {
            [configuration appendData:chunk];
        }
    }
    return configuration;
}

@end
