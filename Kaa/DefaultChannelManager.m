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

#import "DefaultChannelManager.h"
#import "SyncTask.h"
#import "BlockingQueue.h"
#import "TransportConnectionInfo.h"
#import "FailoverDecision.h"
#import "KaaLogging.h"
#import "KaaExceptions.h"

#define TAG @"DefaultChannelManager >>>"

#define EXIT_FAILURE 1

@interface DefaultChannelManager ()

@property (nonatomic,strong) NSMutableArray *channels;              //<KaaDataChannel>
@property (nonatomic,strong) NSMutableDictionary *upChannels;       //<TransportType,KaaDataChannel> as key-value
@property (nonatomic,strong) id<BootstrapManager> bootstrapManager;
@property (nonatomic,strong) NSMutableDictionary *lastServers;      //<TransportProtocolId,TransportConnectionInfo>

@property (nonatomic,strong) NSDictionary *bootststrapServers;      //<TransportProtocolId,NSArray<TransportConnectionInfo>>
@property (nonatomic,strong) NSMutableDictionary *lastBSServers;    //<TransportProtocolId,TransportConnectionInfo>

@property (nonatomic,strong) NSMutableDictionary *syncTaskQueueMap; //<NSString,BlockingQueue<SyncTask>> as key-value
@property (nonatomic,strong) NSMutableDictionary *syncWorkers;      //<NSString,SyncWorker>

@property (nonatomic,strong) id<FailoverManager> failoverManager;
@property (nonatomic,strong) id<ExecutorContext> executorContext;

@property (nonatomic,strong) ConnectivityChecker *connectivityChecker;

@property (nonatomic) BOOL isShutdown;
@property (nonatomic) BOOL isPaused;

@property (nonatomic,strong) id<KaaDataDemultiplexer> operationsDemultiplexer;
@property (nonatomic,strong) id<KaaDataMultiplexer> operationsMultiplexer;
@property (nonatomic,strong) id<KaaDataDemultiplexer> bootstrapDemultiplexer;
@property (nonatomic,strong) id<KaaDataMultiplexer> bootstrapMultiplexer;

- (BOOL)useChannel:(id<KaaDataChannel>)channel forType:(TransportType)type;
- (void)useNewChannelForType:(TransportType)type;
- (void)applyNewChannel:(id<KaaDataChannel>)channel;
- (void)replaceAndRemoveChannel:(id<KaaDataChannel>)channel;
- (void)addChannelToList:(id<KaaDataChannel>)channel;
- (id<KaaDataChannel>)getChannel:(TransportType)type;
- (id<TransportConnectionInfo>)getCurrentBootstrapServer:(TransportProtocolId *)protocolId;
- (id<TransportConnectionInfo>)getNextBootstrapServer:(id<TransportConnectionInfo>)currentServer;
- (void)sync:(TransportType)type ack:(BOOL)ack all:(BOOL)all;
- (void)startWorker:(id<KaaDataChannel>)channel;
- (void)stopWorker:(id<KaaDataChannel>)channel;

@end

@implementation DefaultChannelManager

- (instancetype)initWith:(id<BootstrapManager>)bootstrapMgr
        bootstrapServers:(NSDictionary *)servers
                 context:(id<ExecutorContext>)context {
    self = [super init];
    if (self) {
        if (!bootstrapMgr || !servers || [servers count] <= 0) {
            [NSException raise:KaaChannelRuntimeException format:@"Failed to create channel manager!"];
        }
        
        self.bootstrapManager = bootstrapMgr;
        self.bootststrapServers = servers;
        self.executorContext = context;
        
        self.channels = [NSMutableArray array];
        self.upChannels = [NSMutableDictionary dictionary];
        self.lastServers = [NSMutableDictionary dictionary];
        self.lastBSServers = [NSMutableDictionary dictionary];
        self.syncTaskQueueMap = [NSMutableDictionary dictionary];
        self.syncWorkers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setChannel:(id<KaaDataChannel>)channel withType:(TransportType)type {
    @synchronized(self) {
        if (self.isShutdown) {
            DDLogWarn(@"%@ Can't set a channel. Channel manager is down", TAG);
            return;
        }
        
        if (channel) {
            if (![self useChannel:channel forType:type]) {
                [NSException raise:KaaInvalidChannelException
                            format:@"Unsupported transport type %i for channel with ID: %@", type, [channel getId]];
            }
            if (self.isPaused) {
                [channel pause];
            }
            [self addChannelToList:channel];
        } else {
            DDLogWarn(@"%@ Channel is nil for transport: [%i]", TAG, type);
        }
    }
}

- (void)addChannel:(id<KaaDataChannel>)channel {
    @synchronized(self) {
        if (self.isShutdown) {
            DDLogWarn(@"%@ Can't add a channel. Channel manager is down", TAG);
            return;
        }
        
        if (channel) {
            BOOL isBootstrap = [channel getServerType] == SERVER_BOOTSTRAP;
            
            [channel setMultiplexer:(isBootstrap ? self.bootstrapMultiplexer : self.operationsMultiplexer)];
            [channel setDemultiplexer:(isBootstrap ? self.bootstrapDemultiplexer : self.operationsDemultiplexer)];
            
            if (self.isPaused) {
                [channel pause];
            }
            
            [self addChannelToList:channel];
            [self applyNewChannel:channel];
        } else {
            DDLogWarn(@"%@ Can't add nil channel.", TAG);
        }
    }
}

- (void)removeChannel:(id<KaaDataChannel>)channel {
    @synchronized(self) {
        [self replaceAndRemoveChannel:channel];
    }
}

- (void)removeChannelById:(NSString *)channelId {
    @synchronized(self) {
        for (id<KaaDataChannel> channel in self.channels) {
            if ([[channel getId] isEqualToString:channelId]) {
                [self replaceAndRemoveChannel:channel];
                return;
            }
        }
    }
}

- (NSArray *)getChannels {
    @synchronized(self) {
        return [NSArray arrayWithArray:self.channels];
    }
}

- (id<TransportConnectionInfo>)getActiveServer:(TransportType)type {
    id<KaaDataChannel> channel = [self.upChannels objectForKey:[NSNumber numberWithInt:type]];
    if (!channel || [[NSNull null] isEqual:channel]) {
        return nil;
    }
    return [channel getServer];
}

- (void)sync:(TransportType)type {
    [self sync:type ack:NO all:NO];
}

- (void)syncAck:(TransportType)type {
    [self sync:type ack:YES all:NO];
}

- (void)syncAll:(TransportType)type {
    [self sync:type ack:NO all:YES];
}

- (id<KaaDataChannel>)getChannelById:(NSString *)channelId {
    @synchronized(self) {
        for (id<KaaDataChannel> channel in self.channels) {
            if ([[channel getId] isEqualToString:channelId]) {
                return channel;
            }
        }
        return nil;
    }
}

- (void)onTransportConnectionInfoUpdated:(id<TransportConnectionInfo>)newServer {
    @synchronized(self) {
        DDLogDebug(@"%@ Transport connection info updated for server: %@", TAG, newServer);
        
        if (self.isShutdown) {
            DDLogWarn(@"%@ Can't process server update. Channel manager is down", TAG);
            return;
        }
        
        if ([newServer serverType] == SERVER_OPERATIONS) {
            DDLogInfo(@"%@ Adding new operations server: %@", TAG, newServer);
            [self.lastServers setObject:newServer forKey:[newServer transportId]];
        }
        
        for (id<KaaDataChannel> channel in self.channels) {
            if ([channel getServerType] == [newServer serverType]
                && [[channel getTransportProtocolId] isEqual:[newServer transportId]]) {
                DDLogDebug(@"%@ Applying server %@ for channel %@ type %@",
                           TAG, newServer, [channel getId], [channel getTransportProtocolId]);
                [channel setServer:newServer];
                if (self.failoverManager) {
                    [self.failoverManager onServerChanged:newServer];
                } else {
                    DDLogWarn(@"%@ Failover manager is nil", TAG);
                }
            }
        }
    }
}

- (void)onServerFailed:(id<TransportConnectionInfo>)server {
    @synchronized(self) {
        if (self.isShutdown) {
            DDLogWarn(@"%@ Can't process server failure. Channel manager is down", TAG);
            return;
        }
        
        if ([server serverType] == SERVER_BOOTSTRAP) {
            id<TransportConnectionInfo> nextConnectionInfo = [self getNextBootstrapServer:server];
            if (nextConnectionInfo) {
                DDLogVerbose(@"%@ Using next bootstrap server", TAG);
                FailoverDecision *decision = [self.failoverManager onFailover:FAILOVER_STATUS_CURRENT_BOOTSTRAP_SERVER_NA];
                switch (decision.failoverAction) {
                    case FAILOVER_ACTION_NOOP:
                        DDLogWarn(@"%@ No operation is performed according to failover strategy decision", TAG);
                        break;
                    case FAILOVER_ACTION_RETRY:
                    {
                        NSInteger period = [decision retryPeriod];
                        DDLogWarn(@"%@ Reconnect to current bootstrap server will be made in %li ms", TAG, (long)period);
                        __weak typeof(self)weakSelf = self;
                        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(period * NSEC_PER_MSEC));
                        dispatch_after(delay, [self.executorContext getSheduledExecutor], ^{
                            [weakSelf onTransportConnectionInfoUpdated:server];
                        });
                    }
                        break;
                    case FAILOVER_ACTION_USE_NEXT_BOOTSTRAP:
                    {
                        NSInteger period = [decision retryPeriod];
                        DDLogWarn(@"%@ Connection to next bootstrap server will be made in %li ms", TAG, (long)period);
                        __weak typeof(self)weakSelf = self;
                        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(period * NSEC_PER_MSEC));
                        dispatch_after(delay, [self.executorContext getSheduledExecutor], ^{
                            [weakSelf onTransportConnectionInfoUpdated:nextConnectionInfo];
                        });
                    }
                        break;
                    case FAILOVER_ACTION_STOP_APP:
                        DDLogWarn(@"%@ Stopping application according to failover strategy decision!", TAG);
                        exit(EXIT_FAILURE);
                        //TODO review how to exit application
                        break;
                    default:
                        break;
                }
            } else {
                DDLogVerbose(@"%@ Can't find next bootstrap server", TAG);
                FailoverDecision *decision = [self.failoverManager onFailover:FAILOVER_STATUS_BOOTSTRAP_SERVERS_NA];
                switch (decision.failoverAction) {
                    case FAILOVER_ACTION_NOOP:
                        DDLogWarn(@"%@ No operation is performed according to failover strategy decision", TAG);
                        break;
                    case FAILOVER_ACTION_RETRY:
                    {
                        NSInteger period = [decision retryPeriod];
                        DDLogWarn(@"%@ Reconnect to first bootstrap server will be made in %li ms", TAG, (long)period);
                        __weak typeof(self)weakSelf = self;
                        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(period * NSEC_PER_MSEC));
                        dispatch_after(delay, [self.executorContext getSheduledExecutor], ^{
                            [weakSelf onTransportConnectionInfoUpdated:server];
                        });
                    }
                        break;
                    case FAILOVER_ACTION_STOP_APP:
                        DDLogWarn(@"%@ Stopping application according to failover strategy decision!", TAG);
                        exit(EXIT_FAILURE);
                        //TODO review how to exit application
                        break;
                    default:
                        break;
                }
            }
        } else {
            [self.bootstrapManager useNextOperationsServer:[server transportId]];
        }
    }
}

- (void)clearChannelList {
    @synchronized(self) {
        [self.channels removeAllObjects];
        [self.upChannels removeAllObjects];
    }
}

- (void)setConnectivityChecker:(ConnectivityChecker *)connectivityChecker {
    if (self.isShutdown) {
        DDLogWarn(@"%@ Can't set connectivity checker. Channel manager is down", TAG);
        return;
    }
    
    _connectivityChecker = connectivityChecker;
    for (id<KaaDataChannel> channel in self.channels) {
        [channel setConnectivityChecker:connectivityChecker];
    }
}

- (void)shutdown {
    @synchronized(self) {
        if (!self.isShutdown) {
            self.isShutdown = YES;
            for (id<KaaDataChannel> channel in self.channels) {
                [channel shutdown];
            }
            for (SyncWorker *worker in self.syncWorkers.allValues) {
                [worker cancel];
            }
        }
    }
}

- (void)pause {
    @synchronized(self) {
        if (self.isShutdown) {
            DDLogWarn(@"%@ Can't pause. Channel manager is down", TAG);
            return;
        }
        
        if (!self.isPaused) {
            self.isPaused = YES;
            for (NSNumber *key in self.upChannels.allKeys) {
                if (![[NSNull null] isEqual:[self.upChannels objectForKey:key]]) {
                    [[self.upChannels objectForKey:key] pause];
                }
            }
        }
    }
}

- (void)resume {
    @synchronized(self) {
        if (self.isShutdown) {
            DDLogWarn(@"%@ Can't resume. Channel manager is down", TAG);
            return;
        }
        
        if (self.isPaused) {
            self.isPaused = NO;
            for (NSNumber *key in self.upChannels.allKeys) {
                if (![[NSNull null] isEqual:[self.upChannels objectForKey:key]]) {
                    [[self.upChannels objectForKey:key] resume];
                }
            }
        }
    }
}

- (void)setOperationMultiplexer:(id<KaaDataMultiplexer>)multiplexer {
    _operationsMultiplexer = multiplexer;
}

- (void)setOperationDemultiplexer:(id<KaaDataDemultiplexer>)demultiplexer {
    _operationsDemultiplexer = demultiplexer;
}

- (void)setBootstrapMultiplexer:(id<KaaDataMultiplexer>)bootstrapMultiplexer {
    _bootstrapMultiplexer = bootstrapMultiplexer;
}

- (void)setBootstrapDemultiplexer:(id<KaaDataDemultiplexer>)bootstrapDemultiplexer {
    _bootstrapDemultiplexer = bootstrapDemultiplexer;
}

- (void)setFailoverManager:(id<FailoverManager>)failoverManager {
    _failoverManager = failoverManager;
}

- (void)sync:(TransportType)type ack:(BOOL)ack all:(BOOL)all {
    DDLogDebug(@"%@ Lookup channel by type [%i]", TAG, type);
    id<KaaDataChannel> channel = [self getChannel:type];
    @synchronized(self.syncTaskQueueMap) {
        BlockingQueue *queue = [self.syncTaskQueueMap objectForKey:[channel getId]];
        if (queue) {
            [queue offer:[[SyncTask alloc] initWithTransport:type ackOnly:ack all:all]];
        } else {
            DDLogWarn(@"%@ Can't find queue for channel [%@]", TAG, [channel getId]);
        }
    }
}

- (void)startWorker:(id<KaaDataChannel>)channel {
    [self stopWorker:channel];
    SyncWorker *worker = [[SyncWorker alloc] initWith:channel andManager:self];
    @synchronized(self.syncTaskQueueMap) {
        [self.syncTaskQueueMap setObject:[BlockingQueue new] forKey:[channel getId]];
    }
    [self.syncWorkers setObject:worker forKey:[channel getId]];
    [worker start];
}

- (void)stopWorker:(id<KaaDataChannel>)channel {
    @synchronized(self.syncTaskQueueMap) {
        BlockingQueue *skippedTasks = [self.syncTaskQueueMap objectForKey:[channel getId]];
        if (skippedTasks) {
            [self.syncTaskQueueMap removeObjectForKey:[channel getId]];
            DDLogInfo(@"%@ Tasks skipped due to worker shutdown for channel id: %@", TAG, [channel getId]);
        }
    }
    SyncWorker *worker = [self.syncWorkers objectForKey:[channel getId]];
    if (worker) {
        [self.syncWorkers removeObjectForKey:[channel getId]];
        DDLogDebug(@"%@ Stopping worker for channel with id: %@", TAG, [channel getId]);
        [worker cancel];
    }
}

- (id<KaaDataChannel>)getChannel:(TransportType)type {
    id<KaaDataChannel> result = [self.upChannels objectForKey:[NSNumber numberWithInt:type]];
    if (!result || [[NSNull null] isEqual:result]) {
        DDLogError(@"%@ Failed to find channel for transport: [%i]", TAG, type);
        [NSException raise:KaaChannelRuntimeException format:@"Failed to find channel for transport: [%i]", type];
    }
    return result;
}

- (BOOL)useChannel:(id<KaaDataChannel>)channel forType:(TransportType)type {
    NSNumber *key = [NSNumber numberWithInt:type];
    NSNumber *value = [[channel getSupportedTransportTypes] objectForKey:key];
    ChannelDirection direction = [value intValue];
    if (value && (direction == CHANNEL_DIRECTION_BIDIRECTIONAL || direction == CHANNEL_DIRECTION_UP)) {
        [self.upChannels setObject:channel forKey:[NSNumber numberWithInt:type]];
        return YES;
    }
    return NO;
}

- (void)useNewChannelForType:(TransportType)type {
    for (id<KaaDataChannel> channel in self.channels) {
        if ([self useChannel:channel forType:type]) {
            return;
        }
    }
    
    [self.upChannels setObject:[NSNull null] forKey:[NSNumber numberWithInt:type]];
}

- (void)applyNewChannel:(id<KaaDataChannel>)channel {
    for (NSNumber *key in [channel getSupportedTransportTypes].allKeys) {
        [self useChannel:channel forType:[key intValue]];
    }
}

- (void)replaceAndRemoveChannel:(id<KaaDataChannel>)channel {
    [self.channels removeObject:channel];
    for (NSNumber *key in self.upChannels.allKeys) {
        if ([[self.upChannels objectForKey:key] isEqual: channel]) {
            [self useNewChannelForType:[key intValue]];
        }
    }
    [self stopWorker:channel];
    [channel shutdown];
}

- (void)addChannelToList:(id<KaaDataChannel>)channel {
    if ([self.channels containsObject:channel]) {
        DDLogInfo(@"%@ Unable tot add channel to list: channel already in the list", TAG);
        return;
    }
    
    [channel setConnectivityChecker:self.connectivityChecker];
    [self.channels addObject:channel];
    [self startWorker:channel];
    id<TransportConnectionInfo> server = nil;
    if ([channel getServerType] == SERVER_BOOTSTRAP) {
        server = [self getCurrentBootstrapServer:[channel getTransportProtocolId]];
    } else {
        server = [self.lastServers objectForKey:[channel getTransportProtocolId]];
    }
    if (server) {
        DDLogDebug(@"%@ Applying server %@ for channel %@ type %@", TAG, server, [channel getId], [channel getTransportProtocolId]);
        [channel setServer:server];
        if (self.failoverManager) {
            [self.failoverManager onServerChanged:server];
        } else {
            DDLogWarn(@"%@ Failover manager is nil", TAG);
        }
    } else if (self.lastServers.count == 0){
        if ([channel getServerType] == SERVER_BOOTSTRAP) {
            DDLogWarn(@"%@ Failed to find bootstrap server for channel %@ type %@",
                      TAG, [channel getId], [channel getTransportProtocolId]);
        } else {
            DDLogInfo(@"%@ Failed to find operation server for channel %@ type %@",
                      TAG, [channel getId], [channel getTransportProtocolId]);
        }
    } else {
        DDLogDebug(@"%@ List of servers is empty for channel %@ type %@", TAG, [channel getId], [channel getTransportProtocolId]);
    }
}

- (id<TransportConnectionInfo>)getCurrentBootstrapServer:(TransportProtocolId *)protocolId {
    id<TransportConnectionInfo> bsi = [self.lastBSServers objectForKey:protocolId];
    if (!bsi) {
        NSArray *serverList = [self.bootststrapServers objectForKey:protocolId];
        if (serverList && [serverList count] > 0) {
            bsi = [serverList objectAtIndex:0];
            [self.lastBSServers setObject:bsi forKey:protocolId];
        }
    }
    return bsi;
}

- (id<TransportConnectionInfo>)getNextBootstrapServer:(id<TransportConnectionInfo>)currentServer {
    id<TransportConnectionInfo> bsi;
    NSArray *serverList = [self.bootststrapServers objectForKey:[currentServer transportId]];
    NSUInteger serverIndex = [serverList indexOfObject:currentServer];
    if (serverIndex != NSNotFound) {
        if (++serverIndex == [serverList count]) {
            serverIndex = 0;
        }
        bsi = [serverList objectAtIndex:serverIndex];
        [self.lastBSServers setObject:bsi forKey:[currentServer transportId]];
    }
    return bsi;
}

@end

@implementation SyncWorker

- (instancetype)initWith:(id<KaaDataChannel>)channel andManager:(DefaultChannelManager *)manager {
    self = [super init];
    if (self) {
        self.channel = channel;
        self.manager = manager;
        self.isStopped = NO;
    }
    return self;
}

- (void)main {
    if (self.isCancelled || self.isFinished) {
        DDLogWarn(@"%@ Thread finished before starting processing for channel with id: %@", TAG, [self.channel getId]);
        return;
    }
    DDLogDebug(@"%@ Worker started for channel with id: %@", TAG, [self.channel getId]);
    while (!self.isCancelled && !self.isStopped) {
        @try {
            BlockingQueue *taskQueue;
            @synchronized(self.manager.syncTaskQueueMap) {
                taskQueue = [self.manager.syncTaskQueueMap objectForKey:[self.channel getId]];
            }
            SyncTask *task = [taskQueue take];
            NSMutableArray *additionalTasks = [NSMutableArray array];
            [taskQueue drainTo:additionalTasks];
            if ([additionalTasks count] > 0) {
                DDLogDebug(@"%@ [%@] Merging task %@ with %@", TAG, [self.channel getId], task, additionalTasks);
                task = [SyncTask merge:task additionalTasks:additionalTasks];
            }
            if (task.isAll) {
                DDLogDebug(@"%@ [%@] Going to invoke syncAll method for types %@",
                           TAG, [self.channel getId], [task getTransportTypes]);
                [self.channel syncAll];
            } else if (task.isAckOnly) {
                DDLogDebug(@"%@ [%@] Going to invoke syncAck method for types %@",
                           TAG, [self.channel getId], [task getTransportTypes]);
                [self.channel syncAckTransportTypes:[task getTransportTypes]];
            } else {
                DDLogDebug(@"%@ [%@] Going to invoke sync method", TAG, [self.channel getId]);
                [self.channel syncTransportTypes:[task getTransportTypes]];
            }
        }
        @catch (NSException *exception) {
            DDLogWarn(@"%@ Worker interruped for %@ channel: %@, reason: %@",
                      TAG, [self.channel getId], exception.name, exception.reason);
        }
    }
    DDLogDebug(@"%@ Stopped worker for channel with id: %@", TAG, [self.channel getId]);
}

- (void)cancel {
    [super cancel];
    self.isStopped = YES;
}

@end
