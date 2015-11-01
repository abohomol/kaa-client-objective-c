//
//  DefaultBootstrapManagerTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 19.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "KaaInternalChannelManager.h"
#import "IPTransportInfo.h"
#import "BootstrapTransport.h"
#import "DefaultBootstrapManager.h"
#import "TransportProtocolIdHolder.h"
#import "KeyUtils.h"
#import "KeyPair.h"
#import "DefaultFailoverManager.h"
#import "TestsHelper.h"

#pragma mark - ChannelManagerMock

@interface ChannelManagerMock : NSObject <KaaInternalChannelManager>

@property (nonatomic) BOOL serverUpdated;
@property (nonatomic, strong) NSString *receivedURL;
@property (nonatomic) NSInteger callCounter;

@end

@implementation ChannelManagerMock

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serverUpdated = NO;
        self.callCounter = 0;
    }
    return self;
}

- (void)setConnectivityChecker:(ConnectivityChecker *)checker {
}

- (void)addChannel:(id<KaaDataChannel>)channel {
}

- (void)removeChannel:(id<KaaDataChannel>)channel {
}

- (NSArray *)getChannels {
    return nil;
}

- (id<KaaDataChannel>)getChannelById:(NSString *)channelId {
    return nil;
}

- (void)onServerFailed:(id<TransportConnectionInfo>)server {
}

- (void)setFailoverManager:(id<FailoverManager>)failoverManager {
}

- (void)onTransportConnectionInfoUpdated:(id<TransportConnectionInfo>)newServer {
    self.receivedURL = [[[IPTransportInfo alloc] initWithTransportInfo:newServer] getUrl];
    self.serverUpdated = YES;
    self.callCounter += 1;
}

- (void)clearChannelList {
}

- (void)setChannel:(id<KaaDataChannel>)channel withType:(TransportType)type {
}

- (void)removeChannelById:(NSString *)channelId {
}

- (void)shutdown {
}

- (void)pause {
}

- (void)resume {
}

- (void)setOperationDemultiplexer:(id<KaaDataDemultiplexer>)demultiplexer {
    //TODO Auto-generated method stub
}

- (void)setOperationMultiplexer:(id<KaaDataMultiplexer>)multiplexer {
    //TODO Auto-generated method stub
}

- (void)setBootstrapMultiplexer:(id<KaaDataMultiplexer>)multiplexer {
    //TODO Auto-generated method stub
}

- (void)setBootstrapDemultiplexer:(id<KaaDataDemultiplexer>)demultiplexer {
    //TODO Auto-generated method stub
}

- (void)sync:(TransportType)type {
    //TODO Auto-generated method stub
}

- (void)syncAck:(TransportType)type {
    //TODO Auto-generated method stub
}

- (void)syncAll:(TransportType)type {
    //TODO Auto-generated method stub
}

- (id<TransportConnectionInfo>)getActiveServer:(TransportType)type {
    //TODO Auto-generated method stub
    return nil;
}

@end

#pragma mark - DefaultBootstrapManagerTest

@interface DefaultBootstrapManagerTest : XCTestCase

@property (nonatomic) BOOL exception;

@end

@implementation DefaultBootstrapManagerTest

- (void)testReceiveOperationsServerList {
    id <BootstrapTransport> transport = mockProtocol(@protocol(BootstrapTransport));
    DefaultBootstrapManager *manager = [[DefaultBootstrapManager alloc] initWith:transport executorContext:nil];
    
    self.exception = NO;
    @try {
        [manager receiveOperationsServerList];
        [manager useNextOperationsServer:[TransportProtocolIdHolder HTTPTransportID]];
    }
    @catch (NSException *exception) {
        self.exception = YES;
    }
    
    XCTAssertTrue(self.exception);
    [manager receiveOperationsServerList];
    [verifyCount(transport, times(2)) sync];
}

- (void)testOperationsServerInfoRetrieving {
    id <ExecutorContext> executorContext = mockProtocol(@protocol(ExecutorContext));
    DefaultBootstrapManager *manager = [[DefaultBootstrapManager alloc] initWith:nil executorContext:executorContext];
    
    self.exception = NO;
    
    @try {
        [manager useNextOperationsServer:[TransportProtocolIdHolder HTTPTransportID]];
    }
    @catch (NSException *exception) {
        self.exception = YES;
    }
    XCTAssertTrue(self.exception);
    
    id <BootstrapTransport> transport = mockProtocol(@protocol(BootstrapTransport));
    
    //Generating pseudo bootstrap key
    [KeyUtils generateKeyPair];
    ProtocolMetaData *md = [TestsHelper buildMetaDataWithTPid:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9889 andPublicKey:[KeyUtils getPublicKey]];
    NSArray *array = [NSArray arrayWithObject:md];
    
    NSOperationQueue *opQue = [[NSOperationQueue alloc] init];
    [opQue setMaxConcurrentOperationCount:1];
    ChannelManagerMock *channelManager = [[ChannelManagerMock alloc] init];
    [given([executorContext getSheduledExecutor]) willReturn:[opQue underlyingQueue]];
    DefaultFailoverManager *failoverManager = [[DefaultFailoverManager alloc] initWithChannelManager:channelManager context:executorContext failureResolutionTimeout:1 bootstrapServersRetryPeriod:1 operationsServersRetryPeriod:1 noConnectivityRetryPeriod:1 timeUnit:TIME_UNIT_MILLISECONDS];
    
    [manager setChannelManager:channelManager];
    [manager setFailoverManager:failoverManager];
    [manager setTransport:transport];
    [manager onProtocolListUpdated:array];
    [manager useNextOperationsServer:[TransportProtocolIdHolder HTTPTransportID]];
    
    XCTAssertTrue(channelManager.serverUpdated);
    XCTAssertEqualObjects(@"http://localhost:9889", [channelManager receivedURL]);
    
    [manager useNextOperationsServerByAccessPointId:[@"some.name" hash]];
    XCTAssertEqual(1, channelManager.callCounter);
}

- (void)testUseServerByDNSName {
    DefaultBootstrapManager *manager = [[DefaultBootstrapManager alloc] initWith:nil executorContext:nil];
    
    ChannelManagerMock *channelManager = [[ChannelManagerMock alloc] init];
    [manager setChannelManager:channelManager];
    
    id <BootstrapTransport> transport = mockProtocol(@protocol(BootstrapTransport));
    [manager setTransport:transport];
    
    //Generating pseudo bootstrap key
    [KeyUtils generateKeyPair];
    ProtocolMetaData *md = [TestsHelper buildMetaDataWithTPid:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost" port:9889 andPublicKey:[KeyUtils getPublicKey]];
    NSArray *array = [NSArray arrayWithObject:md];
    
    [manager onProtocolListUpdated:array];
    XCTAssertEqualObjects(@"http://localhost:9889", [channelManager receivedURL]);
    
    [manager useNextOperationsServerByAccessPointId:[@"localhost2:9889" hash]];
    [verifyCount(transport, times(1)) sync];
    
    md = [TestsHelper buildMetaDataWithTPid:[TransportProtocolIdHolder HTTPTransportID] host:@"localhost2" port:9889 andPublicKey:[KeyUtils getPublicKey]];
    array = [NSArray arrayWithObject:md];
    
    [manager onProtocolListUpdated:array];
    XCTAssertEqualObjects(@"http://localhost2:9889", [channelManager receivedURL]);
    XCTAssertTrue(channelManager.serverUpdated);
}

@end
