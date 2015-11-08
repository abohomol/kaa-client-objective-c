//
//  EventManagerTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 16.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "BaseEventFamily.h"
#import "KaaClientPropertiesState.h"
#import "EventTransport.h"
#import "ExecutorContext.h"
#import "DefaultEventManager.h"
#import "TestsHelper.h"

#pragma mark - TestFindEventListenersDelegate

@interface TestFindEventListenersDelegate : NSObject <FindEventListenersDelegate>

@end

@implementation TestFindEventListenersDelegate

- (void)onRequestFailed {
}

- (void)onEventListenersReceived:(NSArray *)eventListeners {
}


@end

#pragma mark - ConcreteEventFamily

@interface ConcreteEventFamily : NSObject <BaseEventFamily>

@property (nonatomic,strong) NSSet *supportedEventFQNs;
@property (nonatomic) NSInteger eventsCount;

@end

@implementation ConcreteEventFamily

- (instancetype) initWithSupportedFQN:(NSString *)supportedFQN {
    self = [super init];
    if (self) {
        self.eventsCount = 0;
        self.supportedEventFQNs = [NSSet setWithObject:supportedFQN];
    }
    return self;
}

- (NSSet *)getSupportedEventFQNs {
    return self.supportedEventFQNs;
}

- (void)onGenericEvent:(NSString *)eventFQN withData:(NSData *)data from:(NSString *)source {
    self.eventsCount++;
}


@end

#pragma mark - EventManagerTest

@interface EventManagerTest : XCTestCase

@end

@implementation EventManagerTest

- (void)testNoHandler {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <EventTransport> transport = mockProtocol(@protocol(EventTransport));
    id <BaseEventFamily> eventFamily = mockProtocol(@protocol(BaseEventFamily));
    id <ExecutorContext> executorContext = mockProtocol(@protocol(ExecutorContext));
    
    id <EventManager> eventManager = [[DefaultEventManager alloc] initWith:state executorContext:executorContext eventTransport:transport];
    [eventManager registerEventFamily:eventFamily];
    
    [eventManager produceEvent:@"kaa.test.event.PlayEvent" data:[NSData data] target:nil];
    
    [verifyCount(transport, times(1)) sync];
    [verifyCount(eventFamily, times(0)) getSupportedEventFQNs];
}

- (void)testEngageRelease {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <EventTransport> transport = mockProtocol(@protocol(EventTransport));
    id <BaseEventFamily> eventFamily = mockProtocol(@protocol(BaseEventFamily));
    id <ExecutorContext> executorContext = mockProtocol(@protocol(ExecutorContext));
    
    id <EventManager> eventManager = [[DefaultEventManager alloc] initWith:state executorContext:executorContext eventTransport:transport];
    [eventManager registerEventFamily:eventFamily];
    
    [eventManager produceEvent:@"kaa.test.event.PlayEvent" data:[NSData data] target:nil];
    [verifyCount(transport, times(1)) sync];
    
    [eventManager engageDataChannel];
    [eventManager produceEvent:@"kaa.test.event.PlayEvent" data:[NSData data] target:nil];
    [verifyCount(transport, times(1)) sync];
}

- (void)testTransaction {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <EventTransport> transport = mockProtocol(@protocol(EventTransport));
    id <BaseEventFamily> eventFamily = mockProtocol(@protocol(BaseEventFamily));
    id <ExecutorContext> executorContext = mockProtocol(@protocol(ExecutorContext));
    
    id <EventManager> eventManager = [[DefaultEventManager alloc] initWith:state executorContext:executorContext eventTransport:transport];
    [eventManager registerEventFamily:eventFamily];
    
    TransactionId *trxId = [eventManager beginTransaction];
    XCTAssertNotNil(trxId);
    
    [eventManager produceEvent:@"kaa.test.event.PlayEvent" data:[NSData data] target:nil transactionId:trxId];
    [eventManager produceEvent:@"kaa.test.event.PlayEvent" data:[NSData data] target:nil transactionId:trxId];
    [verifyCount(transport, times(0)) sync];
    
    [eventManager rollback:trxId];
    [verifyCount(transport, times(0)) sync];
    
    trxId = [eventManager beginTransaction];
    [eventManager produceEvent:@"kaa.test.event.PlayEvent" data:[NSData data] target:nil transactionId:trxId];
    [verifyCount(transport, times(0)) sync];
    
    [eventManager commit:trxId];
    [verifyCount(transport, times(1)) sync];
}

- (void)testOneEventForTwoDifferentFamilies {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    
    id <EventTransport> transport = mockProtocol(@protocol(EventTransport));
    ConcreteEventFamily *eventFamily1 = [[ConcreteEventFamily alloc] initWithSupportedFQN:@"kaa.test.event.PlayEvent"];
    ConcreteEventFamily *eventFamily2 = [[ConcreteEventFamily alloc] initWithSupportedFQN:@"kaa.test.event.StopEvent"];
    
    id <ExecutorContext> executorContext = mockProtocol(@protocol(ExecutorContext));
    NSOperationQueue *executor = [[NSOperationQueue alloc] init];
    
    [given([executorContext getCallbackExecutor]) willReturn:executor];
    
    id <EventManager> eventManager = [[DefaultEventManager alloc] initWith:state executorContext:executorContext eventTransport:transport];
    [eventManager registerEventFamily:eventFamily1];
    [eventManager registerEventFamily:eventFamily2];
    
    XCTAssertEqual(0, [eventFamily1 eventsCount]);
    XCTAssertEqual(0, [eventFamily2 eventsCount]);
    
    [eventManager onGenericEvent:@"kaa.test.event.PlayEvent" data:[NSData data] source:nil];
    
    [NSThread sleepForTimeInterval:0.5f];
    
    XCTAssertEqual(1, eventFamily1.eventsCount);
    XCTAssertEqual(0, eventFamily2.eventsCount);
    
    [eventManager onGenericEvent:@"kaa.test.event.StopEvent" data:[NSData data] source:nil];
    
    [NSThread sleepForTimeInterval:0.5f];
    
    XCTAssertEqual(1, eventFamily1.eventsCount);
    XCTAssertEqual(1, eventFamily2.eventsCount);
    
    [eventManager onGenericEvent:@"kaa.test.event.NoSuchEvent" data:[NSData data] source:nil];
    
    [NSThread sleepForTimeInterval:0.5f];
    
    XCTAssertEqual(1, eventFamily1.eventsCount);
    XCTAssertEqual(1, eventFamily2.eventsCount);
}

- (void)testFillRequest {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    
    id <EventTransport> transport = mockProtocol(@protocol(EventTransport));
    id <ExecutorContext> executorContext = mockProtocol(@protocol(ExecutorContext));
    id <EventManager> eventManager = [[DefaultEventManager alloc] initWith:state executorContext:executorContext eventTransport:transport];
    
    EventSyncRequest *request = [[EventSyncRequest alloc] init];

    [eventManager produceEvent:@"kaa.test.event.SomeEvent" data:[NSData data] target:@"theTarget"];
    [eventManager fillEventListenersSyncRequest:request];
    request.events = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_0 andData:[eventManager pollPendingEvents]];
    
    XCTAssertNotNil(request.events);
    XCTAssertEqual(1, [request.events.data count]);
    XCTAssertEqualObjects(@"kaa.test.event.SomeEvent", [request.events.data[0] eventClassFQN]);
    XCTAssertEqualObjects([NSData data], [request.events.data[0] eventData]);
    
    request = [[EventSyncRequest alloc] init];
    NSArray *eventFQNs = [NSArray arrayWithObject:@"eventFQN1"];
    [eventManager findEventListeners:eventFQNs delegate:[[TestFindEventListenersDelegate alloc] init]];
    [eventManager findEventListeners:eventFQNs delegate:[[TestFindEventListenersDelegate alloc] init]];
    
    [eventManager fillEventListenersSyncRequest:request];
    
    XCTAssertNotNil([request eventListenersRequests]);
    XCTAssertEqual(2, [request.eventListenersRequests.data count]);
    XCTAssertEqualObjects(eventFQNs[0], [[request.eventListenersRequests.data[0] eventClassFQNs] objectAtIndex:0]);
}

- (void)testEventListenersSyncRequestResponse {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    
    id <EventTransport> transport = mockProtocol(@protocol(EventTransport));
    id <ExecutorContext> executorContext = mockProtocol(@protocol(ExecutorContext));
    id <EventManager> eventManager = [[DefaultEventManager alloc] initWith:state executorContext:executorContext eventTransport:transport];
    
    NSArray *eventFQNs = [NSArray arrayWithObject:@"eventFQN1"];
    
    id <FindEventListenersDelegate> fetchListener = mockProtocol(@protocol(FindEventListenersDelegate));
    NSInteger requestIdOk = [eventManager findEventListeners:eventFQNs delegate:fetchListener];
    NSInteger requestIdBad = [eventManager findEventListeners:eventFQNs delegate:fetchListener];
    
    [verifyCount(transport, atLeastOnce()) sync];
    
    NSMutableArray *response = [NSMutableArray array];
    
    EventListenersResponse *response1 = [self getNewEventListResponseWithRequestId:(int)requestIdOk
                                                                        resultType:SYNC_RESPONSE_RESULT_TYPE_SUCCESS];
    EventListenersResponse *response2 = [self getNewEventListResponseWithRequestId:(int)requestIdBad
                                                                        resultType:SYNC_RESPONSE_RESULT_TYPE_FAILURE];
    [response addObject:response1];
    [response addObject:response2];
    
    [eventManager eventListenersResponseReceived:response];
    [verifyCount(fetchListener, times(1)) onRequestFailed];
    [verifyCount(fetchListener, times(1)) onEventListenersReceived:anything()];
}

#pragma mark - Supporting methods

- (EventListenersResponse *)getNewEventListResponseWithRequestId:(int)requestId resultType:(SyncResponseResultType)resultType {
    EventListenersResponse *response = [[EventListenersResponse alloc] init];
    response.requestId = requestId;
    response.result = resultType;
    response.listeners = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_0 andData:[NSArray array]];
    return response;
}

@end
