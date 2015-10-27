//
//  MessageFactoryTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 26.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "KAATCPConnAck.h"
#import "KAATCPConnect.h"
#import "KAATCPDisconnect.h"
#import "KAATCPPingRequest.h"
#import "KAATCPPingResponse.h"
#import "KAATCPSyncResponse.h"
#import "KAATCPSyncRequest.h"
#import "MessageFactory.h"
#import "TCPDelegates.h"
#import "KeyUtils.h"
#import "KeyPair.h"
#import "AvroBytesConverter.h"
#import "EndpointGen.h"
#import "EndpointObjectHash.h"
#import "MessageEncoderDecoder.h"

@interface MessageFactoryTest : XCTestCase <ConnAckDelegate, ConnectDelegate, SyncResponseDelegate, SyncRequestDelegate, DisconnectDelegate>

@property (nonatomic, strong) NSData *signature;
@property (nonatomic, strong) NSData *sessionKey;
@property (nonatomic, strong) NSData *payload;

@end

@implementation MessageFactoryTest

- (void)testConnackMessageDelegateMethods {
    MessageFactory *factory = [[MessageFactory alloc] initWithFramer:[[Framer alloc] init]];
    char reject[] = {0x20, 0x02, 0x00, 0x03};
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&reject length:sizeof(reject)]];
    id <ConnAckDelegate> idRejectDelegate = mockProtocol(@protocol(ConnAckDelegate));
    [factory registerConnAckDelegate:idRejectDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&reject length:sizeof(reject)]];
    [verifyCount(idRejectDelegate, times(1)) onConnAckMessage:anything()];
    
    char accept[] = {0x20, 0x02, 0x00, 0x01};
    id <ConnAckDelegate> acceptDelegate = mockProtocol(@protocol(ConnAckDelegate));
    [factory registerConnAckDelegate:acceptDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&accept length:sizeof(accept)]];
    
    char badprotocol[] = {0x20, 0x02, 0x00, 0x02};
    id <ConnAckDelegate> badprotocolDelegate = mockProtocol(@protocol(ConnAckDelegate));
    [factory registerConnAckDelegate:badprotocolDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&badprotocol length:sizeof(badprotocol)]];
    
    char serverunavaliable[] = {0x20, 0x02, 0x00, 0x04};
    id <ConnAckDelegate> servUnavaliableDelegate = mockProtocol(@protocol(ConnAckDelegate));
    [factory registerConnAckDelegate:servUnavaliableDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&serverunavaliable length:sizeof(serverunavaliable)]];
    
    char rawConnackBadCredentials[] = {0x20, 0x02, 0x00, 0x05};
    id <ConnAckDelegate> badCredentialsDelegate = mockProtocol(@protocol(ConnAckDelegate));
    [factory registerConnAckDelegate:badCredentialsDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&rawConnackBadCredentials length:sizeof(rawConnackBadCredentials)]];
    
    char rawConnackNoAuth[] = {0x20, 0x02, 0x00, 0x06};
    id <ConnAckDelegate> noAuthDelegate = mockProtocol(@protocol(ConnAckDelegate));
    [factory registerConnAckDelegate:noAuthDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&rawConnackNoAuth length:sizeof(rawConnackNoAuth)]];
    
    char rawConnackUndefined[] = {0x20, 0x02, 0x00, 0x07};
    id <ConnAckDelegate> undefinedDelegate = mockProtocol(@protocol(ConnAckDelegate));
    [factory registerConnAckDelegate:undefinedDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&rawConnackUndefined length:sizeof(rawConnackUndefined)]];
}

- (void)testConnackMessageReturnTypes {
    MessageFactory *factory = [[MessageFactory alloc] initWithFramer:[[Framer alloc] init]];
    char reject[] = {0x20, 0x02, 0x00, 0x03};
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&reject length:sizeof(reject)]];
    MessageFactoryTest *idRejectDelegate = [[MessageFactoryTest alloc] init];
    [factory registerConnAckDelegate:idRejectDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&reject length:sizeof(reject)]];
    
    char accept[] = {0x20, 0x02, 0x00, 0x01};
    MessageFactoryTest *acceptDelegate = [[MessageFactoryTest alloc] init];
    [factory registerConnAckDelegate:acceptDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&accept length:sizeof(accept)]];
    
    char badprotocol[] = {0x20, 0x02, 0x00, 0x02};
    MessageFactoryTest *badprotocolDelegate = [[MessageFactoryTest alloc] init];
    [factory registerConnAckDelegate:badprotocolDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&badprotocol length:sizeof(badprotocol)]];
    
    char serverunavaliable[] = {0x20, 0x02, 0x00, 0x04};
    MessageFactoryTest *servUnavaliableDelegate = [[MessageFactoryTest alloc] init];
    [factory registerConnAckDelegate:servUnavaliableDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&serverunavaliable length:sizeof(serverunavaliable)]];
    
    char rawConnackBadCredentials[] = {0x20, 0x02, 0x00, 0x05};
    MessageFactoryTest *badCredentialsDelegate = [[MessageFactoryTest alloc] init];
    [factory registerConnAckDelegate:badCredentialsDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&rawConnackBadCredentials length:sizeof(rawConnackBadCredentials)]];
    
    char rawConnackNoAuth[] = {0x20, 0x02, 0x00, 0x06};
    MessageFactoryTest *noAuthDelegate = [[MessageFactoryTest alloc] init];
    [factory registerConnAckDelegate:noAuthDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&rawConnackNoAuth length:sizeof(rawConnackNoAuth)]];
    
    char rawConnackUndefined[] = {0x20, 0x02, 0x00, 0x07};
    MessageFactoryTest *undefinedDelegate = [[MessageFactoryTest alloc] init];
    [factory registerConnAckDelegate:undefinedDelegate];
    [factory.framer pushBytes:[NSMutableData dataWithBytes:&rawConnackUndefined length:sizeof(rawConnackUndefined)]];
}

- (void)testConnectMessage {
    KeyPair *pair = [KeyUtils generateKeyPair];
    MessageEncoderDecoder *crypt = [[MessageEncoderDecoder alloc] initWithKeyPair:pair andRemotePublicKeyRef:[KeyUtils getPublicKeyRef]];
    
    NSData *rawData = [self getRawData];
    NSData *payload = [crypt encodeData:rawData];
    NSData *sessionKey = [crypt getEncodedSessionKey];
    NSData *signature = [crypt sign:sessionKey];
    self.payload = payload;
    self.sessionKey = sessionKey;
    self.signature = signature;
    
    char connectHeader[] = {0x10, 0xC2, 0x04, 0x00, 0x06, 'K', 'a', 'a', 't', 'c', 'p', 0x01, 0x02, 0xf2, 0x91,  0xf2, 0xd4, 0x11, 0x01, 0x00, 0xC8};
    
    NSMutableData *connectBuffer = [NSMutableData dataWithBytes:&connectHeader length:sizeof(connectHeader)];
    [connectBuffer appendData:sessionKey];
    [connectBuffer appendData:signature];
    [connectBuffer appendData:payload];
    
    MessageFactory *factory = [[MessageFactory alloc] init];
    [factory.framer pushBytes:connectBuffer];
    
    MessageFactoryTest *delegate = [[MessageFactoryTest alloc] init];
    [factory registerConnectDelegate:delegate];
    [factory.framer pushBytes:connectBuffer];
    
    id <ConnectDelegate> mockDelegate = mockProtocol(@protocol(ConnectDelegate));
    [factory registerConnectDelegate:mockDelegate];
    [factory.framer pushBytes:connectBuffer];
    [verifyCount(mockDelegate, times(1)) onConnectMessage:anything()];
}

- (void)testConnectMessageWithoutKey {
    [KeyUtils generateKeyPair];

    NSData *rawData = [self getRawData];
    //we assume that size of rawdata is less then 128 here
    char rawlen= [rawData length] + 18;
    
    char charConnectHeaderPart2[] = {0x10, rawlen, 0x00, 0x06, 'K','a','a','t','c','p', 0x01, 0x02, 0xf2, 0x91, 0xf2, 0xd4, 0x00, 0x00, 0x00, 0xC8};
    NSInteger capacity = rawData.length + 20;
    NSMutableData *connectHeader = [NSMutableData dataWithCapacity:capacity];
    [connectHeader appendBytes:&charConnectHeaderPart2 length:sizeof(charConnectHeaderPart2)];
    
    NSMutableData *connectBuffer = [NSMutableData dataWithData:connectHeader];
    [connectBuffer appendData:rawData];
    
    MessageFactory *factory = [[MessageFactory alloc] init];
    [factory.framer pushBytes:connectBuffer];
    
    MessageFactoryTest *delegate = [[MessageFactoryTest alloc] init];
    [factory registerConnectDelegate:delegate];
    [factory.framer pushBytes:connectBuffer];
    
    id <ConnectDelegate> mockDelegate = mockProtocol(@protocol(ConnectDelegate));
    [factory registerConnectDelegate:mockDelegate];
    [factory.framer pushBytes:connectBuffer];
    [verifyCount(mockDelegate, times(1)) onConnectMessage:anything()];
}

- (void)testSyncResponse {
    char charConnectHeaderPart2[] = {0xF0, 0x0D, 0x00, 0x06, 'K','a','a','t','c','p', 0x01, 0x00, 0x05, 0x14, 0xFF};
    NSMutableData *syncRequest = [NSMutableData dataWithBytes:charConnectHeaderPart2 length:sizeof(charConnectHeaderPart2)];
    MessageFactory *factory = [[MessageFactory alloc] init];
    MessageFactoryTest *delegate = [[MessageFactoryTest alloc] init];
    
    [factory registerSyncResponseDelegate:delegate];
    [factory.framer pushBytes:syncRequest];
    
    id <SyncResponseDelegate> syncRespDelegate = mockProtocol(@protocol(SyncResponseDelegate));
    [factory registerSyncResponseDelegate:syncRespDelegate];
    [factory.framer pushBytes:syncRequest];
    [verifyCount(syncRespDelegate, times(1)) onSyncResponseMessage:anything()];
}

- (void)testSyncRequest {
    char charConnectHeaderPart2[] = {0xF0, 0x0D, 0x00, 0x06, 'K','a','a','t','c','p', 0x01, 0x00, 0x05, 0x15, 0xFF};
    NSMutableData *syncRequest = [NSMutableData dataWithBytes:charConnectHeaderPart2 length:sizeof(charConnectHeaderPart2)];
    
    MessageFactoryTest *delegate = [[MessageFactoryTest alloc] init];
    MessageFactory *factory = [[MessageFactory alloc] init];
    [factory registerSyncRequestDelegate:delegate];
    [factory.framer pushBytes:syncRequest];
    
    id <SyncRequestDelegate> syncReqDelegate = mockProtocol(@protocol(SyncRequestDelegate));
    [factory registerSyncRequestDelegate:syncReqDelegate];
    [factory.framer pushBytes:syncRequest];
    [verifyCount(syncReqDelegate, times(1)) onSyncRequestMessage:anything()];
}

- (void)testPingRequest {
    char pingRequestChar[] = {0xC0, 0x00};
    NSMutableData *pingRequest = [NSMutableData dataWithBytes:&pingRequestChar length:sizeof(pingRequestChar)];
    
    MessageFactory *factory = [[MessageFactory alloc] init];
    [factory.framer pushBytes:pingRequest];
    id <PingRequestDelegate> delegate = mockProtocol(@protocol(PingRequestDelegate));
    [factory registerPingRequestDelegate:delegate];
    [factory.framer pushBytes:pingRequest];
    [verifyCount(delegate, times(1)) onPingRequestMessage:anything()];
}

- (void)testPingResponse {
    char pingResponseChar[] = {0xD0, 0x00};
    NSMutableData *pingResponse = [NSMutableData dataWithBytes:&pingResponseChar length:sizeof(pingResponseChar)];
    
    MessageFactory *factory = [[MessageFactory alloc] init];
    [factory.framer pushBytes:pingResponse];
    id <PingResponseDelegate> delegate = mockProtocol(@protocol(PingResponseDelegate));
    [factory registerPingResponseDelegate:delegate];
    [factory.framer pushBytes:pingResponse];
    [verifyCount(delegate, times(1)) onPingResponseMessage:anything()];
}

- (void)testDisconnect {
    char disconnectChar[] = {0xE0, 0x02, 0x00, 0x02};
    NSMutableData *disconnect = [NSMutableData dataWithBytes:&disconnectChar length:sizeof(disconnectChar)];
    
    MessageFactory *factory = [[MessageFactory alloc] init];
    [factory.framer pushBytes:disconnect];
    
    MessageFactoryTest *delegate = [[MessageFactoryTest alloc] init];
    [factory registerDisconnectDelegate:delegate];
    [factory.framer pushBytes:disconnect];
    
    id <DisconnectDelegate> mockDisconnect = mockProtocol(@protocol(DisconnectDelegate));
    [factory registerDisconnectDelegate:mockDisconnect];
    [factory.framer pushBytes:disconnect];
    [verifyCount(mockDisconnect, times(1)) onDisconnectMessage:anything()];
}

- (void)testBytesPartialPush {
    char syncRequestChar[] = {0xF0, 0x0D, 0x00, 0x06, 'K','a','a','t','c','p', 0x01, 0x00, 0x05, 0x15, 0xFF};
    
    NSMutableData *syncRequest1 = [NSMutableData dataWithBytes:&syncRequestChar length:sizeof(syncRequestChar)];
    NSMutableData *syncRequest2 = [NSMutableData dataWithBytes:&syncRequestChar length:sizeof(syncRequestChar)];
    NSMutableData *syncRequest3 = [NSMutableData dataWithBytes:&syncRequestChar length:sizeof(syncRequestChar)];
    NSInteger totalLength = syncRequest1.length + syncRequest2.length + syncRequest3.length;
    
    NSMutableData *totalBuffer = [NSMutableData dataWithCapacity:totalLength];
    [totalBuffer appendData:syncRequest1];
    [totalBuffer appendData:syncRequest2];
    [totalBuffer appendData:syncRequest3];
    
    uint8_t firstBuffer[syncRequest1.length - 2];
    uint8_t secondBuffer[syncRequest2.length + 4];
    uint8_t thirdBuffer[syncRequest3.length - 2];
    
    NSInputStream *stream = [NSInputStream inputStreamWithData:totalBuffer];
    [stream open];
    [stream read:firstBuffer maxLength:(syncRequest1.length - 2)];
    [stream read:secondBuffer maxLength:syncRequest2.length + 4];
    [stream read:thirdBuffer maxLength:(syncRequest3.length - 2)];
    [stream close];
    
    MessageFactory *factory = [[MessageFactory alloc] init];
    MessageFactoryTest *delegate = [[MessageFactoryTest alloc] init];
    
    [factory registerSyncRequestDelegate:delegate];
    
    NSMutableData *firstBufferData = [NSMutableData dataWithBytes:&firstBuffer length:sizeof(firstBuffer)];
    NSMutableData *secondBufferData = [NSMutableData dataWithBytes:&secondBuffer length:sizeof(secondBuffer)];
    NSMutableData *thirdBufferData = [NSMutableData dataWithBytes:&thirdBuffer length:sizeof(thirdBuffer)];

    int i = [factory.framer pushBytes:firstBufferData];
    XCTAssertEqual(firstBufferData.length, i);
    i = [factory.framer pushBytes:secondBufferData];
    XCTAssertEqual(secondBufferData.length, i);
    i = [factory.framer pushBytes:thirdBufferData];
    XCTAssertEqual(thirdBufferData.length, i);
    
    id <SyncRequestDelegate> syncRequestDelegate = mockProtocol(@protocol(SyncRequestDelegate));
    [factory registerSyncRequestDelegate:syncRequestDelegate];
    
    i = [factory.framer pushBytes:firstBufferData];
    XCTAssertEqual(firstBufferData.length, i);
    i = [factory.framer pushBytes:secondBufferData];
    XCTAssertEqual(secondBufferData.length, i);
    i = [factory.framer pushBytes:thirdBufferData];
    XCTAssertEqual(thirdBufferData.length, i);

    [verifyCount(syncRequestDelegate, times(3)) onSyncRequestMessage:anything()];

}

#pragma mark - Supporting methods

- (void) onConnAckMessage:(KAATCPConnAck *)message {
    switch (message.returnCode) {
        case RETURN_CODE_ACCEPTED:
            XCTAssertEqual(RETURN_CODE_ACCEPTED, message.returnCode);
            break;
            
        case RETURN_CODE_REFUSE_BAD_CREDENTIALS:
            XCTAssertEqual(RETURN_CODE_REFUSE_BAD_CREDENTIALS, message.returnCode);
            break;
            
        case RETURN_CODE_REFUSE_ID_REJECT:
            XCTAssertEqual(RETURN_CODE_REFUSE_ID_REJECT, message.returnCode);
            break;
            
        case RETURN_CODE_REFUSE_BAD_PROTOCOL:
            XCTAssertEqual(RETURN_CODE_REFUSE_BAD_PROTOCOL, message.returnCode);
            break;
            
        case RETURN_CODE_REFUSE_NO_AUTH:
            XCTAssertEqual(RETURN_CODE_REFUSE_NO_AUTH, message.returnCode);
            break;
            
        case RETURN_CODE_REFUSE_SERVER_UNAVAILABLE:
            XCTAssertEqual(RETURN_CODE_REFUSE_SERVER_UNAVAILABLE, message.returnCode);
            break;
            
        case RETURN_CODE_UNDEFINED:
            XCTAssertEqual(RETURN_CODE_UNDEFINED, message.returnCode);
            break;
            
        default:
            break;
    }
}

- (void) onConnectMessage:(KAATCPConnect *)message {
    int16_t keepAlive = 200;
    int32_t nextProtocolId = 0xf291f2d4;
    XCTAssertEqual(keepAlive, message.keepAlive);
    XCTAssertEqual(nextProtocolId, message.nextProtocolId);
    NSData *rawData = [self getRawData];
    XCTAssertEqualObjects(rawData, message.syncRequest);
    if (message.signature) {
        XCTAssertEqualObjects(self.signature, message.signature);
    }
    if (message.aesSessionKey) {
        XCTAssertEqualObjects(self.sessionKey, message.aesSessionKey);
    }
    if (message.syncRequest) {
        XCTAssertEqualObjects(self.payload, message.syncRequest);
    }
}

- (NSData *) getRawData {
    AvroBytesConverter *requestConverter = [[AvroBytesConverter alloc] init];
    SyncRequest *request = [[SyncRequest alloc] init];
    
    EndpointObjectHash *publicKeyHash = [EndpointObjectHash fromSHA1:[KeyUtils getPublicKey]];
    
    request.requestId = 42;
    SyncRequestMetaData *md = [[SyncRequestMetaData alloc] init];
    md.sdkToken = @"sdkToken";
    md.endpointPublicKeyHash =
    [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_0
                      andData:publicKeyHash.data];
    md.profileHash = [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_1];
    md.timeout = [KAAUnion unionWithBranch:KAA_UNION_LONG_OR_NULL_BRANCH_1];
    request.syncRequestMetaData =
    [KAAUnion unionWithBranch:KAA_UNION_SYNC_REQUEST_META_DATA_OR_NULL_BRANCH_0 andData:md];
    
    request.bootstrapSyncRequest =
    [KAAUnion unionWithBranch:KAA_UNION_BOOTSTRAP_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.profileSyncRequest =
    [KAAUnion unionWithBranch:KAA_UNION_PROFILE_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.configurationSyncRequest =
    [KAAUnion unionWithBranch:KAA_UNION_CONFIGURATION_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.notificationSyncRequest =
    [KAAUnion unionWithBranch:KAA_UNION_NOTIFICATION_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.userSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_USER_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.eventSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_EVENT_SYNC_REQUEST_OR_NULL_BRANCH_1];
    request.logSyncRequest = [KAAUnion unionWithBranch:KAA_UNION_LOG_SYNC_REQUEST_OR_NULL_BRANCH_1];
    
    NSData *rawData = [requestConverter toBytes:request];
    return rawData;
}

- (void) onSyncResponseMessage:(KAATCPSyncResponse *)message {
    XCTAssertEqual(1, message.avroObject.length);
    XCTAssertEqual(5, message.messageId);
    XCTAssertEqual(NO, message.zipped);
    XCTAssertEqual(YES, message.encrypted);
    XCTAssertEqual(NO, message.request);
}

- (void)onSyncRequestMessage:(KAATCPSyncRequest *)message {
    XCTAssertEqual(1, message.avroObject.length);
    XCTAssertEqual(5, message.messageId);
    XCTAssertEqual(NO, message.zipped);
    XCTAssertEqual(YES, message.encrypted);
    XCTAssertEqual(YES, message.request);
}

- (void)onDisconnectMessage:(KAATCPDisconnect *)message {
    XCTAssertEqual(DISCONNECT_REASON_INTERNAL_ERROR, message.reason);
}
     
@end
