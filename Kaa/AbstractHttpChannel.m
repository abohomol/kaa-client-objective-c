//
//  AbstractHttpChannel.m
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AbstractHttpChannel.h"
#import "IPTransportInfo.h"
#import "TransportProtocolIdHolder.h"
#import "KaaLogging.h"

#define TAG @"AbstractHttpChannel >>>"

#define UNATHORIZED_HTTP_STATUS 401

@interface AbstractHttpChannel ()

@property (nonatomic,strong) IPTransportInfo *currentServer;
@property (nonatomic,weak) AbstractKaaClient *kaaClient;
@property (nonatomic,strong) id<KaaClientState> kaaState;
@property (nonatomic,strong) id<FailoverManager> failoverMgr;

@property (nonatomic,strong) volatile NSOperationQueue *executor;

@property (nonatomic) volatile BOOL lastConnectionFailed;
@property (nonatomic) volatile BOOL isShutdown;
@property (nonatomic) volatile BOOL isPaused;

@property (nonatomic,weak) AbstractHttpClient *kaaHttpClient;
@property (nonatomic,strong) id<KaaDataDemultiplexer> chDemultiplexer;
@property (nonatomic,strong) id<KaaDataMultiplexer> chMultiplexer;

@end

@implementation AbstractHttpChannel

- (instancetype)initWithClient:(AbstractKaaClient *)client state:(id<KaaClientState>)state
               failoverManager:(id<FailoverManager>)manager {
    self = [super init];
    if (self) {
        self.kaaClient = client;
        self.kaaState = state;
        self.failoverMgr = manager;
    }
    return self;
}

- (TransportProtocolId *)getTransportProtocolId {
    return [TransportProtocolIdHolder HTTPTransportID];
}

- (void)sync:(TransportType)type {
    @synchronized(self) {
        [self syncTransportTypes:[NSSet setWithObject:[NSNumber numberWithInt:type]]];
    }
}

- (void)syncTransportTypes:(NSSet *)types {
    @synchronized(self) {
        if (self.isShutdown) {
            DDLogInfo(@"%@ Can't sync. Channel %@ is down", TAG, [self getId]);
            return;
        }
        if (self.isPaused) {
            DDLogInfo(@"%@ Can't sync. Channel %@ is paused", TAG, [self getId]);
            return;
        }
        if (!self.chMultiplexer) {
            DDLogInfo(@"%@ Can't sync. Channel %@ multiplexer is not set", TAG, [self getId]);
            return;
        }
        if (!self.chDemultiplexer) {
            DDLogWarn(@"%@ Can't sync. Channel %@ demultiplexer is not set", TAG, [self getId]);
            return;
        }
        if (!self.currentServer) {
            self.lastConnectionFailed = YES;
            DDLogWarn(@"%@ Can't sync. Server is nil", TAG);
        }
        
        NSMutableDictionary *typeMap = [NSMutableDictionary dictionary];
        for (NSNumber *type in types) {
            DDLogInfo(@"%@ Processing sync %i for channel %@", TAG, [type intValue], [self getId]);
            NSNumber *channelDirection = [[self getSupportedTransportTypes] objectForKey:type];
            if (channelDirection) {
                [typeMap setObject:channelDirection forKey:type];
            } else {
                DDLogError(@"%@ Unsupported type %i for channel %@", TAG, [type intValue], [self getId]);
            }
        }
        if (self.executor) {
            [self.executor addOperation:[self createChannelRunner:typeMap]];
        } else {
            DDLogError(@"%@ No executor found for channel with id: %@", TAG, [self getId]);
        }
    }
}

- (void)syncAll {
    @synchronized(self) {
        if (self.isShutdown) {
            DDLogInfo(@"%@ Can't sync all. Channel %@ is down", TAG, [self getId]);
            return;
        }
        if (self.isPaused) {
            DDLogInfo(@"%@ Can't sync. Channel %@ is paused", TAG, [self getId]);
            return;
        }
        
        if (!self.chMultiplexer || !self.chDemultiplexer) {
            DDLogWarn(@"%@ Can't sync, multiplexer/demultiplexer not set: %@/%@", TAG, self.chMultiplexer, self.chDemultiplexer);
            return;
        }
        if (self.currentServer) {
            [self.executor addOperation:[self createChannelRunner:[self getSupportedTransportTypes]]];
        } else {
            self.lastConnectionFailed = YES;
            DDLogWarn(@"%@ Can't sync. Server is nil", TAG);
        }
    }
}

- (void)syncAck:(TransportType)type {
    [self syncAckTransportTypes:[NSSet setWithObject:[NSNumber numberWithInt:type]]];
}

- (void)syncAckTransportTypes:(NSSet *)types {
    DDLogInfo(@"%@ Sync ack message is ignored for Channel with id: %@", TAG, [self getId]);
}

- (void)setMultiplexer:(id<KaaDataMultiplexer>)multiplexer {
    @synchronized(self) {
        if (multiplexer) {
            self.chMultiplexer = multiplexer;
        }
    }
}

- (void)setDemultiplexer:(id<KaaDataDemultiplexer>)demultiplexer {
    @synchronized(self) {
        if (demultiplexer) {
            self.chDemultiplexer = demultiplexer;
        }
    }
}

- (void)setServer:(id<TransportConnectionInfo>)server {
    @synchronized(self) {
        if (self.isShutdown) {
            DDLogInfo(@"%@ Can't set server. Channel %@ is down", TAG, [self getId]);
            return;
        }
        if (!self.executor && !self.isPaused) {
            self.executor = [self createExecutor];
        }
        if (server) {
            self.currentServer = [[IPTransportInfo alloc] initWithTransportInfo:server];
            NSString *url = [NSString stringWithFormat:@"%@%@", [self.currentServer getUrl], [self getURLSuffix]];
            self.kaaHttpClient = [self.kaaClient createHttpClientWithURL:url
                                                              privateKey:[self.kaaState privateKey]
                                                               publicKey:[self.kaaState publicKey]
                                                               remoteKey:[self.currentServer getPublicKey]];
            if (self.lastConnectionFailed && !self.isPaused) {
                self.lastConnectionFailed = NO;
                [self syncAll];
            }
        }
    }
}

- (id<TransportConnectionInfo>)getServer {
    return self.currentServer;
}

- (void)setConnectivityChecker:(ConnectivityChecker *)checker {
    DDLogInfo(@"%@ Ignore set connectivity checker", TAG);
}

- (void)shutdown {
    if (!self.isShutdown) {
        self.isShutdown = YES;
        if (self.executor) {
            [self.executor cancelAllOperations];
        }
    }
}

- (void)pause {
    if (self.isShutdown) {
        DDLogInfo(@"%@ Can't pause. Channel %@ is down", TAG, [self getId]);
        return;
    }
    if (!self.isPaused) {
        self.isPaused = YES;
        if (self.executor) {
            [self.executor cancelAllOperations];
            self.executor = nil;
        }
    }
}

- (void)resume {
    if (self.isShutdown) {
        DDLogInfo(@"%@ Can't resume. Channel %@ is down", TAG, [self getId]);
        return;
    }
    
    if (self.isPaused) {
        self.isPaused = NO;
        if (!self.executor) {
            self.executor = [self createExecutor];
        }
        if (self.lastConnectionFailed) {
            self.lastConnectionFailed = NO;
            [self syncAll];
        }
    }
}

- (ServerType)getServerType {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return -1;
}

- (NSDictionary *)getSupportedTransportTypes {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return nil;
}

- (NSString *)getId {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return nil;
}

- (void)connectionStateChanged:(BOOL)failed {
    [self connectionStateChanged:failed withStatus:-1];
}

- (void)connectionStateChanged:(BOOL)failed withStatus:(int)status {
    switch (status) {
        case UNATHORIZED_HTTP_STATUS:
            [self.kaaState clean];
            break;
        default:
            break;
    }
    self.lastConnectionFailed = failed;
    if (failed) {
        [self.failoverMgr onServerFailed:self.currentServer];
    } else {
        [self.failoverMgr onServerConnected:self.currentServer];
    }
}

- (id<KaaDataMultiplexer>)getMultiplexer {
    return self.chMultiplexer;
}

- (id<KaaDataDemultiplexer>)getDemultiplexer {
    return self.chDemultiplexer;
}

- (AbstractHttpClient *)getHttpClient {
    return self.kaaHttpClient;
}

- (NSOperation *)createChannelRunner:(NSDictionary *)types {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return nil;
}

- (NSString *)getURLSuffix {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented in abstract class"];
    return nil;
}

- (NSOperationQueue *)createExecutor {
    DDLogInfo(@"%@ Creating a new executor for channel: %@", TAG, [self getId]);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    return queue;
}

@end
