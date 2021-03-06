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

#import "DefaultBootstrapDataProcessor.h"
#import "AvroBytesConverter.h"
#import "KaaLogging.h"

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
        
        SyncResponse *list = (SyncResponse *)[self.responseConverter fromBytes:data object:[[SyncResponse alloc] init]];
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
