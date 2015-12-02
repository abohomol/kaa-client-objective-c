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

#import "DefaultOperationTcpChannel.h"
#import "KaaLogging.h"
#import "IPTransportInfo.h"
#import "MessageEncoderDecoder.h"
#import "KAAMessageFactory.h"
#import "Constants.h"
#import "TransportProtocolIdHolder.h"

typedef enum {
    CHANNEL_STATE_SHUTDOWN,
    CHANNEL_STATE_PAUSE,
    CHANNEL_STATE_CLOSED,
    CHANNEL_STATE_OPENED
} ChannelState;

#define TAG                 @"DefaultOperationTcpChannel >>>"
#define EXIT_FAILURE        1
#define PING_TIMEOUT_SEC    100
#define CHANNEL_TIMEOUT     200
#define MAX_THREADS_COUNT   2
#define CHANNEL_ID          @"default_operation_tcp_channel"

@interface PingTask : NSOperation

@property (nonatomic,weak) DefaultOperationTcpChannel *channel;

- (instancetype)initWithChannel:(DefaultOperationTcpChannel *)channel;

@end

@interface OpenConnectionTask : NSOperation

@property (nonatomic,weak) DefaultOperationTcpChannel *channel;
@property (nonatomic) NSInteger delay;

- (instancetype)initWithChannel:(DefaultOperationTcpChannel *)channel andDelay:(NSInteger)delay; //delay in milliseconds

@end

@interface DefaultOperationTcpChannel () <ConnAckDelegate,PingResponseDelegate,SyncResponseDelegate,DisconnectDelegate,NSStreamDelegate>

@property (nonatomic,strong) NSDictionary *SUPPORTED_TYPES; //<TransportType,ChannelDirection> as key-value
@property (nonatomic,strong) IPTransportInfo *currentServer;
@property (nonatomic,strong) id<KaaClientState> state;
@property (nonatomic) volatile ChannelState channelState;
@property (nonatomic,strong) id<KaaDataDemultiplexer> demultiplexer;
@property (nonatomic,strong) id<KaaDataMultiplexer> multiplexer;
@property (nonatomic,strong) MessageEncoderDecoder *encDec;
@property (nonatomic,strong) id<FailoverManager> failoverManager;
@property (nonatomic,strong) volatile ConnectivityChecker *checker;
@property (nonatomic,strong) KAAMessageFactory *messageFactory;
@property (nonatomic,strong) NSOperation *pingTaskFuture;//volatile
@property (nonatomic) volatile BOOL isOpenConnectionScheduled;
@property (nonatomic,strong) NSOperationQueue *executor;
@property (nonatomic,strong) KAASocket *socket;//volatile

- (void)onServerFailed;
- (void)closeConnection;
- (void)sendFrame:(KAAMqttFrame *)frame;
- (void)sendPingRequest;
- (void)sendDisconnect;
- (void)sendKaaSyncRequest:(NSDictionary *)types; //<TransportType, ChannelDirection> as key-value
- (void)sendConnect;
- (void)openConnection;
- (void)scheduleOpenConnectionTask:(NSInteger)retryPeriod;
- (void)schedulePingTask;
- (void)destroyExecutor;

@end

@implementation DefaultOperationTcpChannel

- (instancetype)initWithClientState:(id<KaaClientState>)state andFailoverMgr:(id<FailoverManager>)failoverMgr {
    self = [super init];
    if (self) {
        self.SUPPORTED_TYPES = @{
            [NSNumber numberWithInt:TRANSPORT_TYPE_PROFILE] : [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
            [NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION] : [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
            [NSNumber numberWithInt:TRANSPORT_TYPE_NOTIFICATION] : [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
            [NSNumber numberWithInt:TRANSPORT_TYPE_USER] : [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
            [NSNumber numberWithInt:TRANSPORT_TYPE_EVENT] : [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
            [NSNumber numberWithInt:TRANSPORT_TYPE_LOGGING] : [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL]
        };
        self.channelState = CHANNEL_STATE_CLOSED;
        self.messageFactory = [[KAAMessageFactory alloc] init];
        self.state = state;
        self.failoverManager = failoverMgr;
        [self.messageFactory registerConnAckDelegate:self];
        [self.messageFactory registerSyncResponseDelegate:self];
        [self.messageFactory registerPingResponseDelegate:self];
        [self.messageFactory registerDisconnectDelegate:self];
    }
    return self;
}

- (void)onConnAckMessage:(KAATcpConnAck *)message {
    DDLogInfo(@"%@ ConnAck [%i] message received for channel [%@]", TAG, message.returnCode, [self getId]);
    if (message.returnCode != RETURN_CODE_ACCEPTED) {
        DDLogError(@"%@ Connection for channel [%@] was rejected: %i", TAG, [self getId], message.returnCode);
        if (message.returnCode == RETURN_CODE_REFUSE_BAD_CREDENTIALS) {
            DDLogInfo(@"%@ Cleaning client state", TAG);
            [self.state clean];
        }
        [self onServerFailed];
    }
}

- (void)onPingResponseMessage:(KAATcpPingResponse *)message {
    DDLogInfo(@"%@ PingResponse message received for channel [%@]", TAG, [self getId]);
}

- (void)onSyncResponseMessage:(KAATcpSyncResponse *)message {
    DDLogInfo(@"%@ KaaSync message (zipped:%i, encrypted:%i) received for channel [%@]",
              TAG, message.zipped, message.encrypted, [self getId]);
    NSData *resultBody = nil;
    if (message.encrypted) {
        @synchronized(self) {
            @try {
                resultBody = [self.encDec decodeData:[message avroObject]];
            }
            @catch (NSException *ex) {
                DDLogError(@"%@ Failed to decrypt message body for channel [%@]", TAG, [self getId]);
                DDLogError(@"%@ Error: %@, reason: %@", TAG, ex.name, ex.reason);
            }
        }
    } else {
        resultBody = [message avroObject];
    }
    if (resultBody) {
        @try {
            [self.demultiplexer preProcess];
            [self.demultiplexer processResponse:resultBody];
            [self.demultiplexer postProcess];
        }
        @catch (NSException *ex) {
            DDLogError(@"%@ Failed to process response for channel [%@]: %@. Reason: %@", TAG, [self getId], ex.name, ex.reason);
        }
        
        @synchronized(self) {
            self.channelState = CHANNEL_STATE_OPENED;
        }
        
        [self.failoverManager onServerConnected:self.currentServer];
    } else {
        DDLogWarn(@"%@ Result body in nil", TAG);
    }
}

- (void)onDisconnectMessage:(KAATcpDisconnect *)message {
    DDLogInfo(@"%@ Disconnect message (reason:%i) received for channel [%@]", TAG, message.reason, [self getId]);
    if (message.reason != DISCONNECT_REASON_NONE) {
        DDLogError(@"%@ Server error occurred: %i", TAG, message.reason);
        [self onServerFailed];
    } else {
        [self closeConnection];
    }
}

- (void)sendFrame:(KAAMqttFrame *)frame {
    if (self.socket) {
        @synchronized(self.socket) {
            [self.socket.output write:[[frame getFrame] bytes] maxLength:[frame getFrame].length];
        }
    }
}

- (void)sendPingRequest {
    DDLogDebug(@"%@ Sending PinRequest from channel: %@", TAG, [self getId]);
    [self sendFrame:[[KAATcpPingRequest alloc] init]];
}

- (void)sendDisconnect {
    DDLogDebug(@"%@ Sending Disconnect from channel: %@", TAG, [self getId]);
    [self sendFrame:[[KAATcpDisconnect alloc] initWithDisconnectReason:DISCONNECT_REASON_NONE]];
}

- (void)sendKaaSyncRequest:(NSDictionary *)types {
    DDLogDebug(@"%@ Sending KaaSync from channel: %@", TAG, [self getId]);
    NSData *body = [self.multiplexer compileRequest:types];
    NSData *requestBodyEncoded = [self.encDec encodeData:body];
    [self sendFrame:[[KAATcpSyncRequest alloc] initWithAvro:requestBodyEncoded zipped:NO encypted:YES]];
}

- (void)sendConnect {
    DDLogDebug(@"%@ Sending Connect from channel: %@", TAG, [self getId]);
    NSData *body = [self.multiplexer compileRequest:[self getSupportedTransportTypes]];
    NSData *requestBodyEncoded = [self.encDec encodeData:body];
    NSData *sessionKey = [self.encDec getEncodedSessionKey];
    NSData *signature = [self.encDec sign:sessionKey];
    [self sendFrame:[[KAATcpConnect alloc] initWithAlivePeriod:CHANNEL_TIMEOUT
                                                 nextProtocolId:KAA_PLATFORM_PROTOCOL_AVRO_ID
                                                  aesSessionKey:sessionKey
                                                    syncRequest:requestBodyEncoded
                                                      signature:signature]];
}

- (void)closeConnection {
    @synchronized(self) {
        if (self.pingTaskFuture && !self.pingTaskFuture.isCancelled) {
            [self.pingTaskFuture cancel];
        }
        
        if (!self.socket) {
            return;
        }
        DDLogInfo(@"%@ Channel [%@]: closing current connection", TAG, [self getId]);
        @try {
            [self sendDisconnect];
        }
        @catch (NSException *ex) {
            DDLogError(@"%@ Failed to send Disconnect to server: %@. Reason: %@", TAG, ex.name, ex.reason);
        }
        @finally {
            @try {
                [self.socket.input removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                [self.socket close];
            }
            @catch (NSException *exception) {
                DDLogError(@"%@ Failed to close socket: %@. Reason: %@", TAG, exception.name, exception.reason);
            }
            @finally {
                self.socket = nil;
                [self.messageFactory.framer flush];
                if (self.channelState != CHANNEL_STATE_SHUTDOWN) {
                    self.channelState = CHANNEL_STATE_CLOSED;
                }
            }
        }
    }
}

- (void)openConnection {
    @synchronized(self) {
        if (self.channelState == CHANNEL_STATE_PAUSE || self.channelState == CHANNEL_STATE_SHUTDOWN) {
            DDLogInfo(@"%@ Can't open connection, as channel is in the %i state", TAG, self.channelState);
            return;
        }

        DDLogInfo(@"%@ Channel [%@]: opening connection to server %@", TAG, [self getId], self.currentServer);
        self.isOpenConnectionScheduled = NO;
        self.socket = [self createSocket];
        
        [self.socket.input setDelegate:self];
        [self.socket.input scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self.socket open];
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
        {
            __weak typeof(self) weakSelf = self;
            [self.executor addOperationWithBlock:^{
                [weakSelf sendConnect];
                [weakSelf schedulePingTask];
            }];
            
        }
           break;
        case NSStreamEventErrorOccurred:
            [self onServerFailed];
            break;
            
        case NSStreamEventEndEncountered:
            DDLogInfo(@"%@ End of stream detected for channel [%@]", TAG, [self getId]);
            break;
        case NSStreamEventHasBytesAvailable:
        {
            __weak typeof(self) weakSelf = self;
            
            [self.executor addOperationWithBlock:^{
                
                if (aStream != weakSelf.socket.input) {
                    DDLogWarn(@"%@ Found outdated ref to socket stream", TAG);
                    return;
                }
                
                uint8_t buffer[1024];
                while ([weakSelf.socket.input hasBytesAvailable]) {
                    long read = [weakSelf.socket.input read:buffer maxLength:sizeof(buffer)];
                    if (read > 0) {
                        DDLogVerbose(@"%@ Read %li bytes from input stream", TAG, read);
                        [weakSelf.messageFactory.framer pushBytes:[NSMutableData dataWithBytes:buffer length:read]];
                    } else if (read == -1) {
                        DDLogInfo(@"%@ Channel [%@] received end of stream", TAG, [weakSelf getId]);
                    }
                }
            }];
        }
            break;
        default:
            break;
    }
}


- (KAASocket *)createSocket {
    return [KAASocket socketWithHost:[self.currentServer getHost] andPort:[self.currentServer getPort]];
}

- (void)onServerFailed {
    DDLogInfo(@"%@ [%@] has failed", TAG, [self getId]);
    [self closeConnection];
    if (self.checker && ![self.checker isConnected]) {
        DDLogWarn(@"%@ Loss of connectivity detected", TAG);
        FailoverDecision *decision = [self.failoverManager onFailover:FAILOVER_STATUS_NO_CONNECTIVITY];
        switch (decision.failoverAction) {
            case FAILOVER_ACTION_NOOP:
                DDLogWarn(@"%@ No operation is performed according to failover strategy decision", TAG);
                break;
            case FAILOVER_ACTION_RETRY:
            {
                NSInteger retryPeriod = decision.retryPeriod;
                DDLogWarn(@"%@ Attempt to reconnect will be made in %li ms according to failover strategy decision", TAG, retryPeriod);
                [self scheduleOpenConnectionTask:retryPeriod];
            }
                break;
            case FAILOVER_ACTION_STOP_APP:
                DDLogWarn(@"%@ Stopping application according to failover strategy decision!", TAG);
                exit(EXIT_FAILURE);
                //TODO review how to exit application
                break;
            case FAILOVER_ACTION_USE_NEXT_BOOTSTRAP:
            case FAILOVER_ACTION_USE_NEXT_OPERATIONS:
                DDLogWarn(@"%@ Failover actions NEXT_BOOTSTRAP & NEXT_OPERATIONS not supported yet!", TAG);
        }
    } else {
        [self.failoverManager onServerFailed:self.currentServer];
    }
}

- (void)scheduleOpenConnectionTask:(NSInteger)retryPeriod {
    @synchronized(self) {
        if (!self.isOpenConnectionScheduled) {
            if (self.executor) {
                DDLogInfo(@"%@ Scheduling open connection task", TAG);
                [self.executor addOperation:[[OpenConnectionTask alloc] initWithChannel:self andDelay:retryPeriod]];
                self.isOpenConnectionScheduled = YES;
            } else {
                DDLogWarn(@"%@ Executor is nil, can't schedule open connection task", TAG);
            }
        } else {
            DDLogInfo(@"%@ Reconnect is already scheduled, ignoring the call", TAG);
        }
    }
}

- (void)schedulePingTask {
    if (self.executor) {
        self.pingTaskFuture = [[PingTask alloc] initWithChannel:self];
        [self.executor addOperation:self.pingTaskFuture];
        DDLogDebug(@"%@ Submitting a ping task for channel [%@]", TAG, [self getId]);
    } else {
        DDLogWarn(@"%@ Executor is nil, can't schedule ping connection task", TAG);
    }
}

- (NSOperationQueue *)createExecutor {
    DDLogDebug(@"%@ Creating a new executor for channel [%@]", TAG, [self getId]);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = MAX_THREADS_COUNT;
    return queue;
}

- (void)sync:(TransportType)type {
    @synchronized(self) {
        [self syncTransportTypes:[NSSet setWithObject:[NSNumber numberWithInt:type]]];
    }
}

- (void)syncTransportTypes:(NSSet *)types {
    @synchronized(self) {
        if (self.channelState == CHANNEL_STATE_SHUTDOWN) {
            DDLogInfo(@"%@ Can't sync. Channel %@ is down", TAG, [self getId]);
            return;
        }
        if (self.channelState == CHANNEL_STATE_PAUSE) {
            DDLogInfo(@"%@ Can't sync. Channel %@ is paused", TAG, [self getId]);
            return;
        }
        if (self.channelState != CHANNEL_STATE_OPENED) {
            DDLogInfo(@"%@ Can't sync. Channel %@ is waiting for CONNACK message + KAASYNC message", TAG, [self getId]);
            return;
        }
        if (!self.multiplexer) {
            DDLogWarn(@"%@ Can't sync. Channel %@ multiplexer is not set", TAG, [self getId]);
            return;
        }
        if (!self.demultiplexer) {
            DDLogWarn(@"%@ Can't sync. Channel %@ demultiplexer is not set", TAG, [self getId]);
            return;
        }
        if (!self.currentServer || !self.socket) {
            DDLogWarn(@"%@ Can't sync. Server is %@, socket is %@", TAG, self.currentServer, self.socket);
            return;
        }
        
        NSMutableDictionary *typeMap = [NSMutableDictionary dictionaryWithCapacity:[[self getSupportedTransportTypes] count]];
        for (NSNumber *typeNum in types) {
            DDLogInfo(@"%@ Processing sync %i for channel [%@]", TAG, [typeNum intValue], [self getId]);
            NSNumber *directionNum = [[self getSupportedTransportTypes] objectForKey:typeNum];
            if (directionNum) {
                [typeMap setObject:directionNum forKey:typeNum];
            } else {
                DDLogError(@"%@ Unsupported type %i for channel [%@]", TAG, [typeNum intValue], [self getId]);
            }
            for (NSNumber *transportType in [self getSupportedTransportTypes].allKeys) {
                if (![transportType isEqualToNumber:typeNum]) {
                    [typeMap setObject:[NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN] forKey:transportType];
                }
            }
        }
        
        @try {
            [self sendKaaSyncRequest:typeMap];
        }
        @catch (NSException *ex) {
            DDLogError(@"%@ Failed to sync channel %@: %@, reason: %@", TAG, [self getId], ex.name, ex.reason);
        }
    }
}

- (void)syncAll {
    @synchronized(self) {
        if (self.channelState == CHANNEL_STATE_SHUTDOWN) {
            DDLogInfo(@"%@ Can't sync. Channel %@ is down", TAG, [self getId]);
            return;
        }
        if (self.channelState == CHANNEL_STATE_PAUSE) {
            DDLogInfo(@"%@ Can't sync. Channel %@ is paused", TAG, [self getId]);
            return;
        }
        if (self.channelState != CHANNEL_STATE_OPENED) {
            DDLogInfo(@"%@ Can't sync. Channel %@ is waiting for CONNACK message + KAASYNC message", TAG, [self getId]);
            return;
        }
        if (!self.multiplexer || !self.demultiplexer) {
            DDLogWarn(@"%@ Can't sync. Multiplexer/Demultiplexer for channel [%@] not set", TAG, [self getId]);
            return;
        }
        if (!self.currentServer || !self.socket) {
            DDLogWarn(@"%@ Can't sync. Server is %@, socket is %@", TAG, self.currentServer, self.socket);
            return;
        }
        DDLogInfo(@"%@ Processing sync all for channel [%@]", TAG, [self getId]);
        @try {
            [self sendKaaSyncRequest:[self getSupportedTransportTypes]];
        }
        @catch (NSException *ex) {
            DDLogError(@"%@ Failed to sync channel %@: %@, reason: %@", TAG, [self getId], ex.name, ex.reason);
            [self onServerFailed];
        }
    }
}

- (void)syncAck:(TransportType)type {
    DDLogInfo(@"%@ Adding sync acknowledgement for type %i as a regular sync for channel [%@]", TAG, type, [self getId]);
    [self syncAckTransportTypes:[NSSet setWithObject:[NSNumber numberWithInt:type]]];
}

- (void)syncAckTransportTypes:(NSSet *)types {
    @synchronized(self) {
        if (self.channelState != CHANNEL_STATE_OPENED) {
            DDLogInfo(@"%@ First KaaSync message received and processed for channel [%@]", TAG, [self getId]);
            self.channelState = CHANNEL_STATE_OPENED;
            [self.failoverManager onServerConnected:self.currentServer];
            DDLogDebug(@"%@ There are pending requests for channel [%@] -> starting sync", TAG, [self getId]);
            [self syncAll];
        } else {
            DDLogDebug(@"%@ Acknowledgment is pending for channel [%@] -> starting sync", TAG, [self getId]);
            if ([types count] == 1) {
                [self sync:[types.allObjects[0] intValue]];
            } else {
                [self syncAll];
            }
        }
    }
}

- (void)setDemultiplexer:(id<KaaDataDemultiplexer>)demultiplexer {
    @synchronized(self) {
        if (demultiplexer) {
            _demultiplexer = demultiplexer;
        }
    }
}

- (void)setMultiplexer:(id<KaaDataMultiplexer>)multiplexer {
    @synchronized(self) {
        if (multiplexer) {
            _multiplexer = multiplexer;
        }
    }
}

- (void)setServer:(id<TransportConnectionInfo>)server {
    [self setServer:server withKeyPair:nil];
}

- (void)setServer:(id<TransportConnectionInfo>)server withKeyPair:(KeyPair *) sendedKeyPair {
    @synchronized(self) {
        if (!server) {
            DDLogWarn(@"%@ Server is nil for channel [%@]", TAG, [self getId]);
            return;
        }
        if (self.channelState == CHANNEL_STATE_SHUTDOWN) {
            DDLogWarn(@"%@ Can't set server. Channel [%@] is down", TAG, [self getId]);
            return;
        }
        DDLogInfo(@"%@ Setting server [%@] for channel [%@]", TAG, server, [self getId]);
        IPTransportInfo *oldServer = self.currentServer;
        self.currentServer = [[IPTransportInfo alloc] initWithTransportInfo:server];
        KeyPair *keyPair;
        if (sendedKeyPair) {
            keyPair = sendedKeyPair;
        } else {
            keyPair = [[KeyPair alloc] initWithPrivate:[self.state privateKey] andPublic:[self.state publicKey]];
        }
        self.encDec = [[MessageEncoderDecoder alloc] initWithKeyPair:keyPair andRemotePublicKey:[self.currentServer getPublicKey]];
        if (self.channelState != CHANNEL_STATE_PAUSE) {
            if (!self.executor) {
                self.executor = [self createExecutor];
            }
            if (!oldServer
                || !self.socket
                || ![[oldServer getHost] isEqualToString:[self.currentServer getHost]]
                || [oldServer getPort] != [self.currentServer getPort]) {
                DDLogInfo(@"%@ New server's: %@ host or ip is different from the old %@, reconnecting",
                          TAG, oldServer, self.currentServer);
                [self closeConnection];
                [self scheduleOpenConnectionTask:0];
            }
        } else {
            DDLogInfo(@"%@ Can't start new session. Channel [%@] is paused", TAG, [self getId]);
        }
    }
}

- (id<TransportConnectionInfo>)getServer {
    return _currentServer;
}

- (void)setConnectivityChecker:(ConnectivityChecker *)checker {
    _checker = checker;
}

- (void)shutdown {
    @synchronized(self) {
        DDLogInfo(@"%@ Shutting down...", TAG);
        self.channelState = CHANNEL_STATE_SHUTDOWN;
        [self closeConnection];
        [self destroyExecutor];
    }
}

- (void)pause {
    @synchronized(self) {
        if (self.channelState != CHANNEL_STATE_PAUSE) {
            DDLogInfo(@"%@ Pausing...", TAG);
            self.channelState = CHANNEL_STATE_PAUSE;
            [self closeConnection];
            [self destroyExecutor];
        }
    }
}

- (void)resume {
    @synchronized(self) {
        if (self.channelState == CHANNEL_STATE_PAUSE) {
            DDLogInfo(@"%@ Resuming...", TAG);
            self.channelState = CHANNEL_STATE_CLOSED;
            if (!self.executor) {
                self.executor = [self createExecutor];
            }
            [self scheduleOpenConnectionTask:0];
        }
    }
}

- (NSString *)getId {
    return CHANNEL_ID;
}

- (TransportProtocolId *)getTransportProtocolId {
    return [TransportProtocolIdHolder TCPTransportID];
}

- (ServerType)getServerType {
    return SERVER_OPERATIONS;
}

- (NSDictionary *)getSupportedTransportTypes {
    return self.SUPPORTED_TYPES;
}

- (void)destroyExecutor {
    @synchronized(self) {
        if (self.executor) {
            [self.executor cancelAllOperations];
            self.isOpenConnectionScheduled = NO;
            self.executor = nil;
        }
    }
}

@end


@implementation PingTask

- (instancetype)initWithChannel:(DefaultOperationTcpChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)main {
    [NSThread sleepForTimeInterval:PING_TIMEOUT_SEC];
    
    if (self.isCancelled || self.isFinished) {
        DDLogInfo(@"%@ Can't execute ping task for channel [%@]. Task was cancelled.", TAG, [self.channel getId]);
        return;
    }
    
    @try {
        DDLogInfo(@"%@ Executing ping task for channel [%@]", TAG, [self.channel getId]);
        [self.channel sendPingRequest];
        if (self.isCancelled) {
            DDLogInfo(@"%@ Can't schedule new ping task for channel [%@]. Task was cancelled.", TAG, [self.channel getId]);
        } else {
            [self.channel schedulePingTask];
        }
    }
    @catch (NSException *ex) {
        DDLogError(@"%@ Failed to send ping request for channel [%@]: %@. Reason: %@", TAG, [self.channel getId], ex.name, ex.reason);
        [self.channel onServerFailed];
    }
}

@end


@implementation OpenConnectionTask

- (instancetype)initWithChannel:(DefaultOperationTcpChannel *)channel andDelay:(NSInteger)delay {
    self = [super init];
    if (self) {
        _channel = channel;
        _delay = delay;
    }
    return self;
}

- (void)main {
    if (self.isFinished || self.isCancelled) {
        DDLogWarn(@"%@ Can't run OpenConnectionTask: task was cancelled/finished", TAG);
        return;
    }
    [NSThread sleepForTimeInterval:self.delay / 1000];
    [self.channel openConnection];
}

@end
