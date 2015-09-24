//
//  DefaultBootstrapDataProcessor.m
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultBootstrapDataProcessor.h"
#import "AvroBytesConverter.h"

#define TAG @"DefaultBootstrapDataProcessor >>>"

@interface DefaultBootstrapDataProcessor ()

@property (nonatomic,strong) AvroBytesConverter *requestConverter;
@property (nonatomic,strong) AvroBytesConverter *responseConverter;

@property (nonatomic,strong) id<BootstrapTransport> btTransport;

@end

@implementation DefaultBootstrapDataProcessor

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestConverter = [[AvroBytesConverter alloc] init];
        self.responseConverter = [[AvroBytesConverter alloc] init];
    }
    return self;
}

- (void)setBootstrapTransport:(id<BootstrapTransport>)transport {
    self.btTransport = transport;
}

- (NSData *)compileRequest:(NSDictionary *)types {
    @synchronized(self) {
        if (!self.btTransport) {
            DDLogError(@"%@ Unable to compile request: Bootstrap transport is nil", TAG);
            return nil;
        }
        
        SyncRequest *request = [self.btTransport createResolveRequest];
        DDLogVerbose(@"%@ Created Resolve request: %@", TAG, request);
        return [self.requestConverter toBytes:request];
    }
}

- (void)processResponse:(NSData *)data {
    @synchronized(self) {
        if (!self.btTransport || !data) {
            DDLogError(@"%@ Unable to process response: %@:%@", TAG, self.btTransport, data);
            return;
        }
        
        SyncResponse *list = [self.responseConverter fromBytes:data object:[[SyncResponse alloc] init]];
        DDLogVerbose(@"%@ Received OperationsServerList response: %@", TAG, list);
        [self.btTransport onResolveResponse:list];
    }
}

- (void)preProcess {
    DDLogInfo(@"%@ preProcess get called", TAG);
}

- (void)postProcess {
    DDLogInfo(@"%@ postProcess get called", TAG);
}

@end
