//
//  KaaTcpMessageTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 26.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATCPConnAck.h"
#import "KAATCPConnect.h"
#import "KAATCPDisconnect.h"
#import "KAATCPPingRequest.h"
#import "KAATCPPingResponse.h"
#import "KAATCPSyncResponse.h"
#import "KAATCPSyncRequest.h"
#import <XCTest/XCTest.h>

@interface KaaTcpMessageTest : XCTestCase

@end

@implementation KaaTcpMessageTest

- (void)testSyncResponseMessage {
    unsigned char bytes = {0xFF};
    char kaatcp[] = {0xF0, 0x0D, 0x00,0x06,'K','a','a','t','c','p', 0x01, 0x00, 0x05, 0x14, 0xFF};
    NSData *kaaSync = [NSData dataWithBytes:&kaatcp length:sizeof(kaatcp)];
    KAATCPSyncResponse *syncResponse = [[KAATCPSyncResponse alloc] init];
    XCTAssertNotNil(syncResponse);
    
    KAATCPSyncResponse *message = [[KAATCPSyncResponse alloc] initWithAvro:[NSData dataWithBytes:&bytes length:1] zipped:NO encypted:YES];
    [message setMessageId:5];
    NSData *actual = [message getFrame];
    XCTAssertEqualObjects(kaaSync, actual);
}

- (void)testSyncRequestMessage {
    char kaatcp[] = {0xF0, 0x0D, 0x00, 0x06,'K','a','a','t','c','p', 0x01, 0x00, 0x05, 0x15, 0xFF};
    NSData *kaaSync = [NSData dataWithBytes:&kaatcp length:sizeof(kaatcp)];
    
    KAATCPSyncRequest *message = [[KAATCPSyncRequest alloc] initWithAvro:[NSData dataWithBytes:(char[]){0xFF} length:1] zipped:NO encypted:YES];
    [message setMessageId:5];
    NSData *actual = [message getFrame];
    XCTAssertEqualObjects(kaaSync, actual);
}

- (void)testConnectMessage {
    char charpayload[] = {0xFF, 0x01, 0x02, 0x03};
    NSData *payload = [NSData dataWithBytes:&charpayload length:sizeof(charpayload)];
    char charConnectHeader[20] = {0x10, 0x16, 0x00, 0x06, 'K','a','a','t','c','p', 0x01, 0x02, 0xd4, 0xf2, 0x91, 0xf2, 0x00, 0x00, 0x00, 0xC8};
    NSData *connectedHeader = [NSData dataWithBytes:&charConnectHeader length:sizeof(charConnectHeader)];
    KAATCPConnect *message = [[KAATCPConnect alloc] initWithAlivePeriod:200 nextProtocolId:0xf291f2d4 aesSessionKey:nil syncRequest:payload signature:nil];
    NSData *frame = [message getFrame];
    uint8_t headerCheck[20];
    uint8_t payloadCheck[4];
    NSInputStream *stream = [NSInputStream inputStreamWithData:frame];
    [stream open];
    [stream read:headerCheck maxLength:sizeof(charConnectHeader)];
    [stream read:payloadCheck maxLength:sizeof(charpayload)];
    [stream close];
    NSData *headerCheckData = [NSData dataWithBytes:&headerCheck length:sizeof(headerCheck)];
    NSData *payloadCheckData = [NSData dataWithBytes:&payloadCheck length:sizeof(payloadCheck)];
    XCTAssertEqualObjects(headerCheckData, connectedHeader);
    XCTAssertEqualObjects(payload, payloadCheckData);
}

- (void)testDisconnect {
    KAATCPDisconnect *message = [[KAATCPDisconnect alloc] initWithDisconnectReason:DISCONNECT_REASON_INTERNAL_ERROR];
    NSData *actual = [message getFrame];
    char disconnect[] = {0xE0, 0x02, 0x00, 0x02};
    XCTAssertEqualObjects(actual, [NSData dataWithBytes:&disconnect length:sizeof(disconnect)]);
}

- (void)testConnack {
    KAATCPConnAck *message = [[KAATCPConnAck alloc] initWithReturnCode:RETURN_CODE_REFUSE_ID_REJECT];
    NSData *actual = [message getFrame];
    char reject[] = {0x20, 0x02, 0x00, 0x03};
    XCTAssertEqualObjects(actual, [NSData dataWithBytes:&reject length:sizeof(reject)]);
}

- (void)testPingRequest {
    KAATCPPingRequest *message = [[KAATCPPingRequest alloc] init];
    NSData *actual = [message getFrame];
    char request[] = {0xC0, 0x00};
    XCTAssertEqualObjects(actual, [NSData dataWithBytes:&request length:sizeof(request)]);
}

- (void)testPingResponse {
    KAATCPPingResponse *message = [[KAATCPPingResponse alloc] init];
    NSData *actual = [message getFrame];
    char response[] = {0xD0, 0x00};
    XCTAssertEqualObjects(actual, [NSData dataWithBytes:&response length:sizeof(response)]);
}

@end
