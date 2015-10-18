//
//  DefaultEndpointRegistrationManagerTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 18.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "ExecutorContext.h"
#import "KaaClientState.h"
#import "UserTransport.h"
#import "DefaultEndpointRegistrationManager.h"

#define REQUEST_ID 42

#pragma mark - ConcreteUserAttachDelegate

@interface ConcreteUserAttachDelegate : NSObject <UserAttachDelegate>

@end

@implementation ConcreteUserAttachDelegate

- (void) onAttachResult:(UserAttachResponse *)response {
}

@end

#pragma mark - DefaultEndpointRegistrationManagerTest

@interface DefaultEndpointRegistrationManagerTest : XCTestCase

@property (strong, nonatomic) id <ExecutorContext> executorContext;
@property (strong, nonatomic) NSOperationQueue *executor;

@end

@implementation DefaultEndpointRegistrationManagerTest

- (void)setUp {
    [super setUp];
    
    self.executorContext = mockProtocol(@protocol(ExecutorContext));
    self.executor = [[NSOperationQueue alloc] init];
    [given([self.executorContext getApiExecutor]) willReturn:self.executor];
    [given([self.executorContext getCallbackExecutor]) willReturn:self.executor];
}

- (void) testCheckUserAttachWithNoDefaultVerifier {
    @try {
        id <KaaClientState> state = mockProtocol(@protocol(KaaClientState));
        [given([state endpointAccessToken]) willReturn:@""];
        
        id <UserTransport> transport = mockProtocol(@protocol(UserTransport));
        DefaultEndpointRegistrationManager *manager = [[DefaultEndpointRegistrationManager alloc] initWith:state executorContext:self.executorContext userTransport:transport profileTransport:nil];
        
        [manager attachUser:@"verifierToken" userAccessToken:@"externalId" delegate:nil];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"test CheckUserAttachWithNoDefaultVerifier passed");
    }
}

- (void) testCheckUserAttachWithCustomVerifier {
    id <KaaClientState> state = mockProtocol(@protocol(KaaClientState));
    [given([state endpointAccessToken]) willReturn:@""];
    
    id <UserTransport> transport = mockProtocol(@protocol(UserTransport));
    DefaultEndpointRegistrationManager *manager = [[DefaultEndpointRegistrationManager alloc] initWith:state executorContext:self.executorContext userTransport:transport profileTransport:nil];
    
    [manager attachUser:@"verificationToken" userExternalId:@"externalId" userAccessToken:@"token" delegate:nil];
    [verifyCount(transport, times(1)) sync];
}

- (void) testCheckAttachEndpoint {
    id <KaaClientState> state = mockProtocol(@protocol(KaaClientState));
    [given([state endpointAccessToken]) willReturn:@""];
    id <UserTransport> transport = mockProtocol(@protocol(UserTransport));
    DefaultEndpointRegistrationManager *manager = [[DefaultEndpointRegistrationManager alloc] initWith:state executorContext:self.executorContext userTransport:transport profileTransport:nil];
    id <OnAttachEndpointOperationDelegate> delegate = mockProtocol(@protocol(OnAttachEndpointOperationDelegate));
    
    EndpointAccessToken *token1 = [[EndpointAccessToken alloc] initWithToken:@"accessToken1"];
    EndpointAccessToken *token2 = [[EndpointAccessToken alloc] initWithToken:@"accessToken2"];
    
    [manager attachEndpoint:token1 delegate:delegate];
    [manager attachEndpoint:token2 delegate:delegate];
    
    manager = [[DefaultEndpointRegistrationManager alloc] initWith:state executorContext:self.executorContext userTransport:nil profileTransport:nil];
    [manager attachEndpoint:[[EndpointAccessToken alloc] initWithToken:@"accessToken3"] delegate:nil];
    [verifyCount(transport, times(2)) sync];
}

- (void) testcheckDetachEndpoint {
    id <KaaClientState> state = mockProtocol(@protocol(KaaClientState));
    [given([state endpointAccessToken]) willReturn:@""];
    id <UserTransport> transport = mockProtocol(@protocol(UserTransport));
    id <OnDetachEndpointOperationDelegate> delegate = mockProtocol(@protocol(OnDetachEndpointOperationDelegate));
    
    DefaultEndpointRegistrationManager *manager = [[DefaultEndpointRegistrationManager alloc] initWith:state executorContext:self.executorContext userTransport:transport profileTransport:nil];
    [manager detachEndpoint:[[EndpointKeyHash alloc] initWithKeyHash:@"keyHash1"] delegate:delegate];
    [manager detachEndpoint:[[EndpointKeyHash alloc] initWithKeyHash:@"keyHash2"] delegate:delegate];
    
    manager = [[DefaultEndpointRegistrationManager alloc] initWith:state executorContext:self.executorContext userTransport:nil profileTransport:nil];
    [manager detachEndpoint:[[EndpointKeyHash alloc] initWithKeyHash:@"keyHash3"] delegate:nil];
    [verifyCount(transport, times(2)) sync];
}

- (void) testCheckAttachUser {
    id <KaaClientState> state = mockProtocol(@protocol(KaaClientState));
    [given([state endpointAccessToken]) willReturn:@""];
    
    id <UserTransport> transport = mockProtocol(@protocol(UserTransport));
    DefaultEndpointRegistrationManager *manager = [[DefaultEndpointRegistrationManager alloc] initWith:state executorContext:self.executorContext userTransport:transport profileTransport:nil];
    ConcreteUserAttachDelegate *delegate = [[ConcreteUserAttachDelegate alloc] init];
    [manager attachUser:@"externalId" userExternalId:@"userExternalId" userAccessToken:@"userAccessToke" delegate:delegate];
    
    [verifyCount(transport, times(1)) sync];
}

- (void) testCheckWrappers {
    NSString *token1 = @"token1";
    NSString *token2 = @"token2";
    
    EndpointAccessToken *accessToken1 = [[EndpointAccessToken alloc] initWithToken:token1];
    EndpointAccessToken *accessToken1_2 = [[EndpointAccessToken alloc] initWithToken:token1];
    EndpointAccessToken *accessToken2 = [[EndpointAccessToken alloc] initWithToken:token2];
    
    XCTAssertEqualObjects(accessToken1, accessToken1);
    XCTAssertNotEqualObjects(accessToken1, token1);
    XCTAssertEqualObjects([accessToken1 token], [accessToken1 description]);
    XCTAssertEqualObjects(accessToken1, accessToken1_2);
    XCTAssertNotEqualObjects(accessToken1, accessToken2);
    XCTAssertEqual([accessToken1 hash], [accessToken1_2 hash]);
    XCTAssertNotEqual([accessToken1 hash], [accessToken2 hash]);
    
    [accessToken1_2 setToken:token2];
    XCTAssertEqualObjects(accessToken1_2, accessToken2);
    XCTAssertNotEqualObjects(accessToken1, accessToken1_2);
    
    EndpointAccessToken *emptyToken1 = [[EndpointAccessToken alloc] initWithToken:nil];
    EndpointAccessToken *emptyToken2 = [[EndpointAccessToken alloc] initWithToken:nil];
    
 // TODO
 //   XCTAssertEqualObjects(emptyToken1, emptyToken2);
    XCTAssertEqual([emptyToken1 hash], [emptyToken2 hash]);
    XCTAssertNotEqual(accessToken1, emptyToken2);
    XCTAssertNotNil(accessToken1);
    
    NSString *hash1 = @"hash1";
    NSString *hash2 = @"hash2";
    
    EndpointKeyHash *ekh1 = [[EndpointKeyHash alloc] initWithKeyHash:hash1];
    EndpointKeyHash *ekh1_2 = [[EndpointKeyHash alloc] initWithKeyHash:hash1];
    EndpointKeyHash *ekh2 = [[EndpointKeyHash alloc] initWithKeyHash:hash2];
    
    XCTAssertEqualObjects(ekh1, ekh1);
    XCTAssertNotEqualObjects(ekh1, hash1);
    XCTAssertEqualObjects([ekh1 keyHash], [ekh1 description]);
    XCTAssertEqualObjects(ekh1, ekh1_2);
    XCTAssertNotEqualObjects(ekh1, ekh2);
    XCTAssertNotEqualObjects([ekh1 keyHash], [ekh2 keyHash]);
    XCTAssertEqualObjects([ekh1 keyHash], [ekh1_2 keyHash]);
    
    [ekh1_2 setKeyHash:hash2];
    XCTAssertEqualObjects(ekh1_2, ekh2);
    XCTAssertNotEqualObjects(ekh1_2, ekh1);
    
    EndpointKeyHash *emptyKeyHash1 = [[EndpointKeyHash alloc] initWithKeyHash:nil];
    EndpointKeyHash *emptyKeyHash2 = [[EndpointKeyHash alloc] initWithKeyHash:nil];
    
 //   XCTAssertEqualObjects(emptyKeyHash1, emptyKeyHash2);
    XCTAssertEqual([emptyKeyHash1 hash], [emptyKeyHash2 hash]);
    XCTAssertNotEqualObjects(ekh1, emptyKeyHash1);
    XCTAssertNotNil(ekh1);
}

- (void) testCheckOnAttachedDelegate {
    id <KaaClientState> state = mockProtocol(@protocol(KaaClientState));
    [given([state endpointAccessToken]) willReturn:@""];
    UserAttachNotification *attachNotification = [[UserAttachNotification alloc] init];
    attachNotification.userExternalId = @"foo";
    attachNotification.endpointAccessToken = @"bar";
    
    id <AttachEndpointToUserDelegate> delegate = mockProtocol(@protocol(AttachEndpointToUserDelegate));
    
    DefaultEndpointRegistrationManager *manager = [[DefaultEndpointRegistrationManager alloc] initWith:state executorContext:self.executorContext userTransport:nil profileTransport:nil];
    [manager setAttachedDelegate:nil];
    [manager onUpdate:nil detachResponses:nil userResponse:nil userAttachNotification:attachNotification userDetachNotification:nil];
    [manager setAttachedDelegate:delegate];
    [manager onUpdate:nil detachResponses:nil userResponse:nil userAttachNotification:attachNotification userDetachNotification:nil];
    
    [NSThread sleepForTimeInterval:1.f];
    [verifyCount(delegate, times(1)) onAttachedToUser:@"foo" token:@"bar"];
    [verifyCount(state, times(2)) setIsAttachedToUser:YES];
    
    [manager setAttachedDelegate:nil];
    [manager attachUser:@"externalId" userExternalId:@"foo" userAccessToken:@"bar" delegate:nil];
    [manager onUpdate:nil detachResponses:nil userResponse:[self getUserAttachResponse] userAttachNotification:nil userDetachNotification:nil];
    
    [manager setAttachedDelegate:delegate];
    [manager attachUser:@"externalId" userExternalId:@"foo" userAccessToken:@"bar" delegate:nil];
    [manager onUpdate:nil detachResponses:nil userResponse:[self getUserAttachResponse] userAttachNotification:nil userDetachNotification:nil];
    
    [NSThread sleepForTimeInterval:1.f];
    [verifyCount(delegate, times(1)) onAttachedToUser:@"foo" token:@"bar"];
    [verifyCount(state, times(4)) setIsAttachedToUser:YES];
}

- (void) testCheckOnDetachedDelegate {
    id <KaaClientState> state = mockProtocol(@protocol(KaaClientState));
    [given([state endpointAccessToken]) willReturn:@""];
    UserDetachNotification *detachedNotification = [[UserDetachNotification alloc] init];
    detachedNotification.endpointAccessToken = @"foo";

    id <DetachEndpointFromUserDelegate> delegate = mockProtocol(@protocol(DetachEndpointFromUserDelegate));
    
    DefaultEndpointRegistrationManager *manager = [[DefaultEndpointRegistrationManager alloc] initWith:state executorContext:self.executorContext userTransport:nil profileTransport:nil];
    [manager setDetachedDelegate:nil];
    [manager onUpdate:nil detachResponses:nil userResponse:nil userAttachNotification:nil userDetachNotification:detachedNotification];
    
    [manager setDetachedDelegate:delegate];
    [manager onUpdate:nil detachResponses:nil userResponse:nil userAttachNotification:nil userDetachNotification:detachedNotification];
    
    [NSThread sleepForTimeInterval:1.f];
    [verifyCount(delegate, times(1)) onDetachedFromUser:@"foo"];
    [verifyCount(state, times(2)) setIsAttachedToUser:NO];
}

- (UserAttachResponse *) getUserAttachResponse {
    UserAttachResponse *response = [[UserAttachResponse alloc] init];
    response.result = SYNC_RESPONSE_RESULT_TYPE_SUCCESS;
    response.errorCode = [[KAAUnion alloc] initWithBranch:KAA_UNION_USER_ATTACH_ERROR_CODE_OR_NULL_BRANCH_1];
    response.errorReason = [[KAAUnion alloc] initWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    return response;
}

@end
