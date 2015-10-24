//
//  DefaultChannelManagerTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 23.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "DefaultChannelManager.h"
#import "TransportProtocolIdHolder.h"
#import "GenericTransportInfo.h"
#import "KeyUtils.h"
#import "DefaultFailoverManager.h"

@interface DefaultChannelManagerTest : XCTestCase

@property (nonatomic, strong) NSDictionary *SUPPORTED_TYPES;
@property (nonatomic ,strong) id <ExecutorContext> executorContext;

@end

@implementation DefaultChannelManagerTest

- (void) setUp {
    self.SUPPORTED_TYPES =
    [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                                          [NSNumber numberWithInt:CHANNEL_DIRECTION_UP],
                                          [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                                          [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                                          [NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN]]
                                forKeys:@[[NSNumber numberWithInt: TRANSPORT_TYPE_PROFILE],
                                          [NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION],
                                          [NSNumber numberWithInt:TRANSPORT_TYPE_NOTIFICATION],
                                          [NSNumber numberWithInt:TRANSPORT_TYPE_USER],
                                          [NSNumber numberWithInt:TRANSPORT_TYPE_EVENT]]];
    self.executorContext = mockProtocol(@protocol(ExecutorContext));
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
    [given([self.executorContext getSheduledExecutor]) willReturn:[queue underlyingQueue]];
}

- (void)testNullBootStrapServer {
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    @try {
        DefaultChannelManager *channel = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:nil context:nil];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"TestNullBootStrapServer succeed. Caught ChannelRuntimeException");
    }
}

- (void)testEmptyBootstrapServer {
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    @try {
        DefaultChannelManager *channel = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:[[NSDictionary alloc] init] context:nil];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testEmptyBootstrapServer succeed. Caught ChannelRuntimeException");
    }
}

- (void)testEmptyBootstrapManager {
    @try {
        DefaultChannelManager *channel = [[DefaultChannelManager alloc] initWith:nil bootstrapServers:nil context:nil];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testEmptyBootstrapManager succeed. Caught ChannelRuntimeException");
    }
}

- (void)testAddHttpChannel {
    [KeyUtils generateKeyPair];
    NSDictionary *bootstrapServers = [NSDictionary dictionaryWithObject:@[[self createTestServerInfoWithServerType:SERVER_BOOTSTRAP transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9889 andPublicKey:[KeyUtils getPublicKey]]] forKey:[TransportProtocolIdHolder HTTPTransportID]];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getSupportedTransportTypes]) willReturn:self.SUPPORTED_TYPES];
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder HTTPTransportID]];
    [given([channel getServerType]) willReturn:[NSNumber numberWithInt:SERVER_OPERATIONS]];
    [given([channel getId]) willReturn:@"mock_channel"];
    
    id <KaaInternalChannelManager> channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    id <FailoverManager> failoverManager = mockProtocol(@protocol(FailoverManager));
    [channelManager setFailoverManager:failoverManager];
    [channelManager addChannel:channel];
    [channelManager addChannel:channel];
    
    id <TransportConnectionInfo> server = [self createTestServerInfoWithServerType:SERVER_OPERATIONS transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9999 andPublicKey:[KeyUtils getPublicKey]];
    [channelManager onTransportConnectionInfoUpdated:server];
    [verifyCount(failoverManager, times(1)) onServerChanged:anything()];
    
    XCTAssertEqualObjects(channel, [channelManager getChannelById:@"mock_channel"]);
    XCTAssertEqualObjects(channel, [[channelManager getChannels] objectAtIndex:0]);
    
    [channelManager removeChannel:channel];
    XCTAssertNil([channelManager getChannelById:@"mock_channel"]);
    XCTAssertTrue([[channelManager getChannels] count] == 0);
    
    [channelManager addChannel:channel];
    [verifyCount(failoverManager, times(2)) onServerChanged:anything()];
    [verifyCount(channel, times(2)) setServer:server];
    [channelManager clearChannelList];
    XCTAssertTrue([[channelManager getChannels] count] == 0);
}

- (void)testAddBootstrapChannel {
    [KeyUtils generateKeyPair];
    id <TransportConnectionInfo> server = [self createTestServerInfoWithServerType:SERVER_BOOTSTRAP transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9889 andPublicKey:[KeyUtils getPublicKey]];
    NSDictionary *bootstrapServers = [NSDictionary dictionaryWithObject:@[server] forKey:[TransportProtocolIdHolder HTTPTransportID]];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getSupportedTransportTypes]) willReturn:self.SUPPORTED_TYPES];
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder HTTPTransportID]];
    [given([channel getServerType]) willReturn:[NSNumber numberWithInt:SERVER_BOOTSTRAP]];
    [given([channel getId]) willReturn:@"mock_channel"];
    
    id <KaaChannelManager> channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    id <FailoverManager> failoverManager = mockProtocol(@protocol(FailoverManager));
    [channelManager setFailoverManager:failoverManager];
    [channelManager addChannel:channel];
    
    [verifyCount(failoverManager, times(1)) onServerChanged:anything()];
    XCTAssertEqualObjects(channel, [channelManager getChannelById:@"mock_channel"]);
    XCTAssertEqualObjects(channel, [[channelManager getChannels] objectAtIndex:0]);
    
    [channelManager removeChannel:channel];
    XCTAssertNil([channelManager getChannelById:@"mock_channel"]);
    XCTAssertTrue([[channelManager getChannels] count] == 0);
    
    [channelManager addChannel:channel];
    [verifyCount(channel, times(2)) setServer:server];
}

- (void)testOperationServerFailed {
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getSupportedTransportTypes]) willReturn:self.SUPPORTED_TYPES];
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder HTTPTransportID]];
    [given([channel getId]) willReturn:@"mock_channel"];
    
    id <KaaInternalChannelManager> channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:[self getDefaultBootstrapServers] context:nil];
    [channelManager addChannel:channel];
    
    id <TransportConnectionInfo> opServer = [self createTestServerInfoWithServerType:SERVER_OPERATIONS transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9999 andPublicKey:[KeyUtils getPublicKey]];
    [channelManager onTransportConnectionInfoUpdated:opServer];
    
    [channelManager onServerFailed:opServer];
    [verifyCount(bootstrapManager, times(1)) useNextOperationsServer:[TransportProtocolIdHolder HTTPTransportID]];
}

- (void)testBootstrapServerFailed {
    [KeyUtils generateKeyPair];
    id <TransportConnectionInfo> server = [self createTestServerInfoWithServerType:SERVER_BOOTSTRAP transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9889 andPublicKey:[KeyUtils getPublicKey]];
    id <TransportConnectionInfo> server1 = [self createTestServerInfoWithServerType:SERVER_BOOTSTRAP transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost2" port:9889 andPublicKey:[KeyUtils getPublicKey]];
    NSDictionary *bootstrapServers = [NSDictionary dictionaryWithObject:@[server, server1] forKey:[TransportProtocolIdHolder HTTPTransportID]];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getSupportedTransportTypes]) willReturn:self.SUPPORTED_TYPES];
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder HTTPTransportID]];
    [given([channel getServerType]) willReturn:[NSNumber numberWithInt:SERVER_BOOTSTRAP]];
    [given([channel getId]) willReturn:@"mock_channel"];
    
    id <ExecutorContext> executorContext = mockProtocol(@protocol(ExecutorContext));
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
    [given([executorContext getSheduledExecutor]) willReturn:[queue underlyingQueue]];
    id <KaaChannelManager> channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:executorContext];
    id <FailoverManager> failoverManager = mockProtocol(@protocol(FailoverManager));
    [channelManager setFailoverManager:failoverManager];
    
    [channelManager addChannel:channel];
    
    [verifyCount(failoverManager, times(1)) onServerChanged:anything()];
    
    [channelManager onServerFailed:server];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1];
        [verifyCount(channel, times(1)) setServer:server1];
    }];
    [verifyCount(failoverManager, times(1)) onFailover:FAILOVER_STATUS_CURRENT_BOOTSTRAP_SERVER_NA];
}


- (void)testSingleBootstrapServerFailed {
    [KeyUtils generateKeyPair];
    id <TransportConnectionInfo> server = [self createTestServerInfoWithServerType:SERVER_BOOTSTRAP transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9889 andPublicKey:[KeyUtils getPublicKey]];
    NSDictionary *bootstrapServers = [NSDictionary dictionaryWithObject:@[server] forKey:[TransportProtocolIdHolder HTTPTransportID]];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getSupportedTransportTypes]) willReturn:self.SUPPORTED_TYPES];
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder HTTPTransportID]];
    [given([channel getServerType]) willReturn:[NSNumber numberWithInt:SERVER_BOOTSTRAP]];
    [given([channel getId]) willReturn:@"mock_channel"];
    
    id <KaaChannelManager> channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    id <FailoverManager> failoverManager = mockProtocol(@protocol(FailoverManager));
    [channelManager setFailoverManager:failoverManager];
    [channelManager addChannel:channel];
    
    [verifyCount(failoverManager, times(1)) onServerChanged:anything()];
    
    [channelManager onServerFailed:server];
}

- (void)testRemoveHttpLpChannel {
    NSDictionary *bootstrapServers = [self getDefaultBootstrapServers];

    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    
    NSDictionary *typesForChannel2 =
    [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                                          [NSNumber numberWithInt:CHANNEL_DIRECTION_UP],
                                          [NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                                          [NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN]]
                                forKeys:@[[NSNumber numberWithInt: TRANSPORT_TYPE_PROFILE],
                                          [NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION],
                                          [NSNumber numberWithInt:TRANSPORT_TYPE_NOTIFICATION],
                                          [NSNumber numberWithInt:TRANSPORT_TYPE_EVENT]]];
    id <KaaDataChannel> channel1 = mockProtocol(@protocol(KaaDataChannel));
    [given([channel1 getSupportedTransportTypes]) willReturn:typesForChannel2];
    [given([channel1 getTransportProtocolId]) willReturn:[TransportProtocolIdHolder HTTPTransportID]];
    [given([channel1 getServerType]) willReturn:[NSNumber numberWithInt:SERVER_OPERATIONS]];
    [given([channel1 getId]) willReturn:@"mock_channel1"];
    
    id <KaaDataChannel> channel2 = mockProtocol(@protocol(KaaDataChannel));
    [given([channel2 getSupportedTransportTypes]) willReturn:self.SUPPORTED_TYPES];
    [given([channel2 getTransportProtocolId]) willReturn:[TransportProtocolIdHolder HTTPTransportID]];
    [given([channel2 getServerType]) willReturn:[NSNumber numberWithInt:SERVER_OPERATIONS]];
    [given([channel2 getId]) willReturn:@"mock_channel2"];
    
    id <KaaDataChannel> channel3 = mockProtocol(@protocol(KaaDataChannel));
    [given([channel3 getSupportedTransportTypes]) willReturn:typesForChannel2];
    [given([channel3 getTransportProtocolId]) willReturn:[TransportProtocolIdHolder TCPTransportID]];
    [given([channel3 getServerType]) willReturn:[NSNumber numberWithInt:SERVER_OPERATIONS]];
    [given([channel3 getId]) willReturn:@"mock_channel3"];
    
    id <KaaInternalChannelManager> channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    
    id <FailoverManager> failoverManager = mockProtocol(@protocol(FailoverManager));
    [channelManager setFailoverManager:failoverManager];
    
    [channelManager addChannel:channel1];
    [channelManager addChannel:channel2];
    
    id <TransportConnectionInfo> opServer = [self createTestServerInfoWithServerType:SERVER_OPERATIONS transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9999 andPublicKey:[KeyUtils getPublicKey]];
    
    [channelManager onTransportConnectionInfoUpdated:opServer];

    id <TransportConnectionInfo> opServer2 = [self createTestServerInfoWithServerType:SERVER_OPERATIONS transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9889 andPublicKey:[KeyUtils getPublicKey]];
    
    [channelManager onTransportConnectionInfoUpdated:opServer2];
    
    [verifyCount(channel1, times(1)) setServer:opServer];
    [verifyCount(channel2, times(1)) setServer:opServer2];
    
    [channelManager removeChannel:channel2];
    
    id <TransportConnectionInfo> opServer3 = [self createTestServerInfoWithServerType:SERVER_OPERATIONS transportProtocolId:[TransportProtocolIdHolder TCPTransportID] host:@"localhost" port:9009 andPublicKey:[KeyUtils getPublicKey]];
    [channelManager addChannel:channel3];
    [channelManager onTransportConnectionInfoUpdated:opServer3];
    
    [verifyCount(channel3, times(1)) setServer:opServer3];
}

- (void)testConnectivityChecker {
    NSDictionary *bootstrapServers = [self getDefaultBootstrapServers];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    DefaultChannelManager *channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    
    TransportProtocolId *type = [TransportProtocolIdHolder TCPTransportID];
    id <KaaDataChannel> channel1 = mockProtocol(@protocol(KaaDataChannel));
    [given([channel1 getTransportProtocolId]) willReturn:type];
    [given([channel1 getId]) willReturn:@"Channel1"];
    id <KaaDataChannel> channel2 = mockProtocol(@protocol(KaaDataChannel));
    [given([channel2 getTransportProtocolId]) willReturn:type];
    [given([channel2 getId]) willReturn:@"Channel2"];
    
    [channelManager addChannel:channel1];
    [channelManager addChannel:channel2];
    
    ConnectivityChecker *checker = mock([ConnectivityChecker class]);
    
    [channelManager setConnectivityChecker:checker];
    
    [verifyCount(channel1, times(1)) setConnectivityChecker:checker];
    [verifyCount(channel2, times(1)) setConnectivityChecker:checker];
    
    id <KaaDataChannel> channel3 = mockProtocol(@protocol(KaaDataChannel));
    [given([channel3 getTransportProtocolId]) willReturn:type];
    [given([channel3 getId]) willReturn:@"Channel3"];
    
    [channelManager addChannel:channel3];
    [verifyCount(channel3, times(1)) setConnectivityChecker:checker];
}

- (void)testUpdateForSpecifiedTransport {
    NSDictionary *bootstrapServers = [self getDefaultBootstrapServers];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    DefaultChannelManager *channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    
    NSDictionary *types = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL], [NSNumber numberWithInt:CHANNEL_DIRECTION_UP]] forKeys:@[[NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION], [NSNumber numberWithInt:TRANSPORT_TYPE_LOGGING]]];
    
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder TCPTransportID]];
    [given([channel getSupportedTransportTypes]) willReturn:types];
    [given([channel getId]) willReturn:@"channel1"];
    
    id <KaaDataChannel> channel2 = mockProtocol(@protocol(KaaDataChannel));
    [given([channel2 getTransportProtocolId]) willReturn:[TransportProtocolIdHolder TCPTransportID]];
    [given([channel2 getSupportedTransportTypes]) willReturn:types];
    [given([channel2 getId]) willReturn:@"channel2"];
    
    [channelManager addChannel:channel2];
    [channelManager setChannel:channel withType:TRANSPORT_TYPE_LOGGING];
    [channelManager setChannel:nil withType:TRANSPORT_TYPE_LOGGING];
    [channelManager removeChannelById:[channel2 getId]];
}

- (void)testNegativeUpdateForSpecifiedTransport {
    NSDictionary *bootstrapServers = [self getDefaultBootstrapServers];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    DefaultChannelManager *channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    
    NSDictionary *types =
    [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:CHANNEL_DIRECTION_DOWN],
                                          [NSNumber numberWithInt:CHANNEL_DIRECTION_UP]]
                                forKeys:@[[NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION],
                                          [NSNumber numberWithInt:TRANSPORT_TYPE_LOGGING]]];
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder TCPTransportID]];
    [given([channel getSupportedTransportTypes]) willReturn:types];
    @try {
        [channelManager setChannel:channel withType:TRANSPORT_TYPE_CONFIGURATION];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testNegativeUpdateForSpecifiedTransport succeed. Caught KaaInvalidChannelException");
    }
}

- (void)testShutdown {
    NSDictionary *bootstrapServers = [self getDefaultBootstrapServers];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    DefaultChannelManager *channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    
    NSDictionary *types =
    [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL],
                                          [NSNumber numberWithInt:CHANNEL_DIRECTION_UP]]
                                forKeys:@[[NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION],
                                          [NSNumber numberWithInt:TRANSPORT_TYPE_LOGGING]]];
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder TCPTransportID]];
    [given([channel getSupportedTransportTypes]) willReturn:types];
    [given([channel getId]) willReturn:@"channel1"];
    
    [channelManager addChannel:channel];
    
    [channelManager shutdown];
    [channelManager onServerFailed:nil];
    [channelManager onTransportConnectionInfoUpdated:nil];
    [channelManager addChannel:nil];
    [channelManager setChannel:nil withType:0];
    [channelManager setConnectivityChecker:nil];
    [verifyCount(channel, times(1)) shutdown];
}

- (void)testPauseAfterAdd {
    NSDictionary *bootstrapServers = [self getDefaultBootstrapServers];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    DefaultChannelManager *channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    
    NSDictionary *types =
    [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL]
                                forKey:[NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION]];
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder TCPTransportID]];
    [given([channel getSupportedTransportTypes]) willReturn:types];
    [given([channel getId]) willReturn:@"channel1"];

    [channelManager pause];
    [channelManager addChannel:channel];
    [verifyCount(channel, times(1)) pause];
}

- (void)testPauseAfterSet {
    NSDictionary *bootstrapServers = [self getDefaultBootstrapServers];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    DefaultChannelManager *channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    
    NSDictionary *types =
    [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL]
                                forKey:[NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION]];
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder TCPTransportID]];
    [given([channel getSupportedTransportTypes]) willReturn:types];
    [given([channel getId]) willReturn:@"channel1"];
    
    [channelManager pause];
    [channelManager setChannel:channel withType:TRANSPORT_TYPE_CONFIGURATION];
    [verifyCount(channel, times(1)) pause];
}

- (void)testResume {
    NSDictionary *bootstrapServers = [self getDefaultBootstrapServers];
    
    id <BootstrapManager> bootstrapManager = mockProtocol(@protocol(BootstrapManager));
    DefaultChannelManager *channelManager = [[DefaultChannelManager alloc] initWith:bootstrapManager bootstrapServers:bootstrapServers context:nil];
    
    NSDictionary *types =
    [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:CHANNEL_DIRECTION_BIDIRECTIONAL]
                                forKey:[NSNumber numberWithInt:TRANSPORT_TYPE_CONFIGURATION]];
    id <KaaDataChannel> channel = mockProtocol(@protocol(KaaDataChannel));
    [given([channel getTransportProtocolId]) willReturn:[TransportProtocolIdHolder TCPTransportID]];
    [given([channel getSupportedTransportTypes]) willReturn:types];
    [given([channel getId]) willReturn:@"channel1"];
    
    [channelManager pause];
    [channelManager addChannel:channel];
    [channelManager resume];
    
    [verifyCount(channel, times(1)) pause];
    [verifyCount(channel, times(1)) resume];
}

#pragma mark - Supporting methods

- (NSDictionary *) getDefaultBootstrapServers {
    [KeyUtils generateKeyPair];
    id <TransportConnectionInfo> server = [self createTestServerInfoWithServerType:SERVER_BOOTSTRAP transportProtocolId:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9889 andPublicKey:[KeyUtils getPublicKey]];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@[server] forKey:[TransportProtocolIdHolder HTTPTransportID]];
    return dictionary;
}

- (id<TransportConnectionInfo>) createTestServerInfoWithServerType:(ServerType)serverType transportProtocolId:(TransportProtocolId *)TPid host:(NSString *)host port:(NSUInteger)port andPublicKey:(NSData *)publicKey {
    ProtocolMetaData *md = [[ProtocolMetaData alloc] init];
    md = [self buildMetaDataWithTPid:TPid host:host port:port andPublicKey:publicKey];
    return  [[GenericTransportInfo alloc] initWithServerType:serverType andMeta:md];
}

- (ProtocolMetaData *) buildMetaDataWithTPid:(TransportProtocolId *)TPid
                                        host:(NSString *)host
                                        port:(NSUInteger)port
                                andPublicKey:(NSData *)publicKey {
    NSUInteger publicKeyLength = [publicKey length];
    NSUInteger hostLength = [host lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = [NSMutableData data];
    ProtocolVersionPair *pair = [[ProtocolVersionPair alloc]init];
    [pair setId:TPid.protocolId];
    [pair setVersion:TPid.protocolVersion];
    
    [data appendBytes:&publicKeyLength length:sizeof(publicKeyLength)];
    [data appendData:publicKey];
    [data appendBytes:&hostLength length:sizeof(hostLength)];
    [data appendData:[host dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendBytes:&port length:sizeof(port)];
    ProtocolMetaData *md = [[ProtocolMetaData alloc] init];
    [md setConnectionInfo:data];
    [md setAccessPointId:(int)[NSString stringWithFormat:@"%@:%lu", host, (unsigned long)port]];
    [md setProtocolVersionInfo:pair];
    return md;
}

@end
