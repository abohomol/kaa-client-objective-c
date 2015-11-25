//
//  DefaultOperationTcpChannelTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 27.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "DefaultOperationTcpChannel.h"
#import "KAASocket.h"
#import "KaaClientState.h"
#import "KeyUtils.h"
#import "AvroBytesConverter.h"
#import "GenericTransportInfo.h"
#import "TransportProtocolIdHolder.h"
#import "KAATcpSyncResponse.h"
#import "IPTransportInfo.h"
#import "KAATcpPingResponse.h"
#import "KAATcpDisconnect.h"
#import "TestsHelper.h"

#pragma mark - MockedOperationTcpChannel

@interface MockedOperationTcpChannel : DefaultOperationTcpChannel

@property (nonatomic, strong) KAASocket *socketMock;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation MockedOperationTcpChannel

- (instancetype)initWithClientState:(id<KaaClientState>)state andFailoverMgr:(id<FailoverManager>)failoverMgr {
    self = [super initWithClientState:state andFailoverMgr:failoverMgr];
    if (self) {
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreateBoundPair(NULL, &readStream, &writeStream, 4096);
        
        self.inputStream = (__bridge_transfer NSInputStream *)readStream;
        self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
        
        self.socketMock = mock([KAASocket class]);
        
        [given([self.socketMock input]) willReturn:self.inputStream];
        [given([self.socketMock output]) willReturn:self.outputStream];
    }
    return self;
}

- (KAASocket *)createSocket {
    return self.socketMock;
}

@end

#pragma mark - DefaultOperationTcpChannelTest

@interface DefaultOperationTcpChannelTest : XCTestCase

@end

@implementation DefaultOperationTcpChannelTest


- (void)testDefaultOperationTcpChannel {
    id <KaaClientState> state = mockProtocol(@protocol(KaaClientState));
    id <FailoverManager> failoverManager = mockProtocol(@protocol(FailoverManager));
    id <KaaDataChannel> tcpchannel = [[DefaultOperationTcpChannel alloc] initWithClientState:state andFailoverMgr:failoverManager];
    XCTAssertNotNil([tcpchannel getId]);
    XCTAssertNotNil([tcpchannel getSupportedTransportTypes]);
    XCTAssertNotEqual(0, [[tcpchannel getSupportedTransportTypes] count]);
}

/**
 * The issue behind this test is that stream delegate methods don't get triggered after mocking KAASocket
 */
- (void)DISABLED_testSync {
    KeyPair *clientKeys = [KeyUtils generateKeyPair];
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    [given([clientState privateKey]) willReturnStruct:[clientKeys getPrivateKeyRef] objCType:@encode(SecKeyRef)];
    [given([clientState publicKey]) willReturnStruct:[clientKeys getPublicKeyRef] objCType:@encode(SecKeyRef)];
    
    id <FailoverManager> failoverManager = mockProtocol(@protocol(FailoverManager));
    MockedOperationTcpChannel *tcpChannel = [[MockedOperationTcpChannel alloc] initWithClientState:clientState andFailoverMgr:failoverManager];
    
    AvroBytesConverter *requestCreator = [[AvroBytesConverter alloc] init];
    id <KaaDataMultiplexer> multiplexer = mockProtocol(@protocol(KaaDataMultiplexer));
    [given([multiplexer compileRequest:anything()])willReturn:[requestCreator toBytes:[[SyncRequest alloc] init]]];
    id <KaaDataDemultiplexer> demultiplexer = mockProtocol(@protocol(KaaDataDemultiplexer));
    
    [tcpChannel setMultiplexer:multiplexer];
    [tcpChannel setDemultiplexer:demultiplexer];
    [tcpChannel sync:TRANSPORT_TYPE_USER];    // will cause call to KaaDataMultiplexer.compileRequest(...) after "CONNECT" messsage
    [tcpChannel sync:TRANSPORT_TYPE_PROFILE];
    
    [KeyUtils generateKeyPair];
    id <TransportConnectionInfo> server = [self createTestServerInfoWithServerType:SERVER_OPERATIONS transportProtocolId:[TransportProtocolIdHolder TCPTransportID] host:@"localhost" port:9009 andPublicKey:[KeyUtils getPublicKey]];
    
    [tcpChannel setServer:server withKeyPair:clientKeys];
    uint8_t rawConnackChar[] = {0x20, 0x02, 0x00, 0x01};
    [tcpChannel.outputStream write:rawConnackChar maxLength:sizeof(rawConnackChar)];
    
    SyncResponse *response = [[SyncResponse alloc] init];
    [response setStatus:SYNC_RESPONSE_RESULT_TYPE_SUCCESS];
    NSData *kaatcpsyncrespData = [self getNewKAATcpSyncResponse:response];
    [tcpChannel.outputStream write:[kaatcpsyncrespData bytes] maxLength:[kaatcpsyncrespData length]];
    
    [NSThread sleepForTimeInterval:1]; // sleep a bit to let the message to be received
    [tcpChannel sync:TRANSPORT_TYPE_USER]; // causes call to KaaDataMultiplexer.compileRequest(...) for "KAA_SYNC" messsage
    [verifyCount(multiplexer, times(2)) compileRequest:anything()];
    
    [tcpChannel sync:TRANSPORT_TYPE_EVENT];
    [verifyCount(multiplexer, times(3)) compileRequest:anything()];
    [verifyCount(tcpChannel.socketMock, times(3)) output];
    
    [tcpChannel.outputStream write:[[[[KAATcpPingResponse alloc] init] getFrame] bytes] maxLength:[[[[KAATcpPingResponse alloc] init] getFrame] length]];
    
    [tcpChannel syncAll];
    [verifyCount(multiplexer, times(2)) compileRequest:[tcpChannel getSupportedTransportTypes]];
    
    KAATcpDisconnect *disconnect = [[KAATcpDisconnect alloc] initWithDisconnectReason:DISCONNECT_REASON_INTERNAL_ERROR];
    [tcpChannel.outputStream write:[[disconnect getFrame] bytes] maxLength:[[disconnect getFrame] length]];
    
    [tcpChannel syncAll];
    [verifyCount(multiplexer, times(3)) compileRequest:[tcpChannel getSupportedTransportTypes]];
    [tcpChannel shutdown];
}

- (void)testConnectivity {
    KeyPair *clientKeys = [KeyUtils generateKeyPair];
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    [given([clientState privateKey]) willReturnStruct:[clientKeys getPrivateKeyRef] objCType:@encode(SecKeyRef)];
    [given([clientState publicKey]) willReturnStruct:[clientKeys getPublicKeyRef] objCType:@encode(SecKeyRef)];
    
    id <FailoverManager> failoverManager = mockProtocol(@protocol(FailoverManager));
    DefaultOperationTcpChannel *channel = [[DefaultOperationTcpChannel alloc] initWithClientState:clientState andFailoverMgr:failoverManager];
    
    id <TransportConnectionInfo> server = [self createTestServerInfoWithServerType:SERVER_OPERATIONS transportProtocolId:[TransportProtocolIdHolder TCPTransportID] host:@"www.test.fake" port:999 andPublicKey:[KeyUtils getPublicKey]];
    XCTAssertNotNil(server);
    
    ConnectivityChecker *checker = mock([ConnectivityChecker class]);
    [given([checker isConnected]) willReturnBool:NO];
    [channel setConnectivityChecker:checker];
}

#pragma mark - Supporting methods

- (id<TransportConnectionInfo>)createTestServerInfoWithServerType:(ServerType)serverType
                                              transportProtocolId:(TransportProtocolId *)TPid
                                                             host:(NSString *)host
                                                             port:(uint32_t)port
                                                     andPublicKey:(NSData *)publicKey {
    ProtocolMetaData *md = [TestsHelper buildMetaDataWithTPid:TPid host:host port:port andPublicKey:publicKey];
    return  [[GenericTransportInfo alloc] initWithServerType:serverType andMeta:md];
}

- (NSData *)getNewKAATcpSyncResponse:(SyncResponse *)syncResponse {
    AvroBytesConverter *responseCreator = [[AvroBytesConverter alloc] init];
    NSData *data = [responseCreator toBytes:syncResponse];
    KAATcpSyncResponse *response = [[KAATcpSyncResponse alloc] initWithAvro:data zipped:NO encypted:NO];
    return [response getFrame];
}

@end
