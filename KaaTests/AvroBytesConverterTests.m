//
//  AvroBytesConverterTests.m
//  Kaa
//
//  Created by Anton Bohomol on 9/27/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

@import UIKit;
#import <XCTest/XCTest.h>
#import "AvroBytesConverter.h"
#import "EndpointGen.h"

@interface AvroBytesConverterTests : XCTestCase

@property (nonatomic,strong) AvroBytesConverter *converter;

@end

@implementation AvroBytesConverterTests

- (void)setUp {
    [super setUp];
    self.converter = [[AvroBytesConverter alloc] init];
}

- (void)testBytesConverter {
    TopicState *state = [[TopicState alloc] init];
    state.topicId = @"TestTopicState";
    state.seqNumber = 100;
    
    NSData *serialized = [self.converter toBytes:state];
    
    TopicState *deserializedState = [self.converter fromBytes:serialized object:[TopicState new]];
    
    XCTAssertTrue([state.topicId isEqualToString:deserializedState.topicId]);
    XCTAssertEqual(state.seqNumber, deserializedState.seqNumber);
    
    
    SubscriptionCommand *command = [[SubscriptionCommand alloc] init];
    command.topicId = @"TestSubscriptionCommand";
    command.command = SUBSCRIPTION_COMMAND_TYPE_REMOVE;
    
    serialized = [self.converter toBytes:command];
    
    SubscriptionCommand *deserializedCommand = [self.converter fromBytes:serialized object:[SubscriptionCommand new]];
    
    XCTAssertTrue([command.topicId isEqualToString:deserializedCommand.topicId]);
    XCTAssertEqual(command.command, deserializedCommand.command);
    
    
    UserAttachNotification *notification = [[UserAttachNotification alloc] init];
    notification.userExternalId = @"TestUserExternalId";
    notification.endpointAccessToken = @"TestEndpointAccessToken";
    
    serialized = [self.converter toBytes:notification];
    
    UserAttachNotification *deserializedNotification = [self.converter fromBytes:serialized object:[UserAttachNotification new]];
    
    XCTAssertTrue([notification.userExternalId isEqualToString:deserializedNotification.userExternalId]);
    XCTAssertTrue([notification.endpointAccessToken isEqualToString:deserializedNotification.endpointAccessToken]);
}

- (void)testKAAUnionSerialization {
    
    UserAttachResponse *response = [[UserAttachResponse alloc] init];
    response.result = SYNC_RESPONSE_RESULT_TYPE_REDIRECT;
    NSNumber *errorCode = [NSNumber numberWithInt:USER_ATTACH_ERROR_CODE_REMOTE_ERROR];
    NSString *errorReason = @"test errorReason";
    response.errorCode = [KAAUnion unionWithBranch:KAA_UNION_USER_ATTACH_ERROR_CODE_OR_NULL_BRANCH_0 andData:errorCode];
    response.errorReason = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_0 andData:errorReason];
    
    NSData *serialized = [self.converter toBytes:response];
    
    UserAttachResponse *deserializedResponse = [self.converter fromBytes:serialized object:[UserAttachResponse new]];
    
    XCTAssertEqual(response.result, deserializedResponse.result);
    XCTAssertEqual(response.errorCode.branch, deserializedResponse.errorCode.branch);
    XCTAssertTrue([errorCode isEqualToNumber:deserializedResponse.errorCode.data]);
    
    XCTAssertEqual(response.errorReason.branch, deserializedResponse.errorReason.branch);
    NSString *deserializedReason = deserializedResponse.errorReason.data;
    XCTAssertTrue([errorReason isEqualToString:deserializedReason]);
}

@end
