//
//  DefaultLogTransportTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 20.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "KaaClientState.h"
#import "DefaultEventTransport.h"
#import "DefaultEventManager.h"

static NSMutableData *dataWith123;

@interface DefaultEventTransportTest : XCTestCase

@end

@implementation DefaultEventTransportTest

- (void)testSyncNegative {
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    id <EventTransport> transport = [[DefaultEventTransport alloc] initWithState:clientState];
    @try {
        [transport sync];
    }
    @catch (NSException *exception) {
        NSLog(@"testSyncNegative succeed. Caught ChannelRuntimeException");
    }
}

- (void)testSync {
    id <KaaChannelManager> channelManager = mockProtocol(@protocol(KaaChannelManager));
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    
    id <EventTransport> transport = [[DefaultEventTransport alloc] initWithState:clientState];
    [transport setChannelManager:channelManager];
    [transport sync];
    
    [verifyCount(channelManager, times(1)) sync:TRANSPORT_TYPE_EVENT];
}

- (void)testCreateRequest {
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    DefaultEventManager *manager = mock([DefaultEventManager class]);
    Event *event1 = [[Event alloc] init];
    [event1 setSeqNum:1];
    Event *event2 = [[Event alloc] init];
    [event2 setSeqNum:2];
    [given([manager pollPendingEvents]) willReturn:@[event1, event2]];
    
    id <EventTransport> transport = [[DefaultEventTransport alloc] initWithState:clientState];
    [transport createEventRequest:1];
    [transport setEventManager:manager];
    [transport createEventRequest:2];
    [transport onEventResponse:[self getNewEmptyEventResponse]];
    
    [transport createEventRequest:3];
    EventSyncRequest *request = [transport createEventRequest:4];
    
    XCTAssertEqual(2, [request.events.data count]);
}

- (void)testOnEventResponse {
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    DefaultEventManager *manager = mock([DefaultEventManager class]);
    id <EventTransport> transport = [[DefaultEventTransport alloc] initWithState:clientState];
    EventSyncResponse *response = [self getNewEmptyEventResponse];
    
    [transport onEventResponse:response];
    [transport setEventManager:manager];
    [transport onEventResponse:response];
    
    NSMutableArray *events = [NSMutableArray array];
    [response setEvents:[KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_0 andData:events]];
    [transport onEventResponse:response];
    [events addObject:[self getNewEvent]];
    [transport onEventResponse:response];
    
    NSMutableArray *delegates = [NSMutableArray array];
    [response setEventListenersResponses:[KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_BRANCH_0 andData:delegates]];
    [transport onEventResponse:response];
    [delegates addObject:[self getNewEventListenerResponse]];
    [transport onEventResponse:response];
    
    
    [verifyCount(manager, times(3)) onGenericEvent:@"eventClassFQN" data:dataWith123 source:@"source"];
    [verifyCount(manager, times(1)) eventListenersResponseReceived:delegates];
}

- (void)testRemoveByResponseId {
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    DefaultEventManager *manager = mock([DefaultEventManager class]);
    [given([manager pollPendingEvents]) willReturn:@[[[Event alloc] init], [[Event alloc] init]]];
    
    id <EventTransport> transport = [[DefaultEventTransport alloc] initWithState:clientState];
    [transport createEventRequest:1];
    [transport setEventManager:manager];
    [transport createEventRequest:2];
    [transport onEventResponse:[self getNewEmptyEventResponse]];
    [transport createEventRequest:3];
    
    [transport onSyncResposeIdReceived:3];
    
    EventSyncRequest *request = [transport createEventRequest:4];
    XCTAssertTrue([request.events.data count] == 2);
}

- (void)testEventSequenceNumberSyncRequest {
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    Event *event = [[Event alloc] init];
    event.seqNum = 1;
    event.eventClassFQN = nil;
    event.eventData = nil;
    event.source = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    event.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    NSArray *events = @[event];
    
    DefaultEventManager *manager = mock([DefaultEventManager class]);
    [given([manager pollPendingEvents]) willReturn:events];
    
    id <EventTransport> transport = [[DefaultEventTransport alloc] initWithState:clientState];
    [transport setEventManager:manager];
    
    NSInteger requestId = 1;
    EventSyncRequest *eventRequest1 = [transport createEventRequest:requestId++];
    
    XCTAssertTrue(eventRequest1.eventSequenceNumberRequest.data != nil);
    XCTAssertNil(eventRequest1.events.data);
    
    EventSyncRequest *eventRequest2 = [transport createEventRequest:requestId++];
    
    XCTAssertTrue(eventRequest2.eventSequenceNumberRequest.data != nil);
    XCTAssertNil(eventRequest2.events.data);
}

- (void)testSynchronizedSN {
    NSInteger restoredEventSN = 10;
    NSInteger lastEventSN = restoredEventSN -1;
    
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    [given([clientState eventSequenceNumber]) willReturnInteger:restoredEventSN];
    
    Event *event1 = [[Event alloc] init];
    event1.seqNum = (int)restoredEventSN++;
    event1.eventClassFQN = nil;
    event1.eventData = nil;
    event1.source = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    event1.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    Event *event2 = [[Event alloc] init];
    event2.seqNum = (int)restoredEventSN++;
    event2.eventClassFQN = nil;
    event2.eventData = nil;
    event2.source = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    event2.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    Event *event3 = [[Event alloc] init];
    event3.seqNum = (int)restoredEventSN++;
    event3.eventClassFQN = nil;
    event3.eventData = nil;
    event3.source = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    event3.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    NSArray *events = @[event1, event2, event3];
    
    DefaultEventManager *manager = mock([DefaultEventManager class]);
    [given([manager pollPendingEvents]) willReturn:events];
    
    id <EventTransport> transport = [[DefaultEventTransport alloc] initWithState:clientState];
    [transport setEventManager:manager];
    
    NSInteger requestId = 1;
    [transport createEventRequest:requestId++];
    
    EventSyncResponse *eventResponse = [[EventSyncResponse alloc] init];
    eventResponse.eventSequenceNumberResponse =
    [KAAUnion unionWithBranch:KAA_UNION_EVENT_SEQUENCE_NUMBER_RESPONSE_OR_NULL_BRANCH_0
                      andData:[NSNumber numberWithInteger:lastEventSN]];
    eventResponse.eventListenersResponses =
    [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_BRANCH_1];
    eventResponse.events = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_1];
    
    [transport onEventResponse:eventResponse];
    
    EventSyncRequest *eventRequest2 = [transport createEventRequest:requestId];
    
    XCTAssertTrue(eventRequest2.eventSequenceNumberRequest.data == nil);
    XCTAssertTrue([eventRequest2.events.data count] == [events count]);
    
    NSInteger expectedSN = lastEventSN + 1;
    for (Event *ev in eventRequest2.events.data) {
        XCTAssertEqual(expectedSN++, ev.seqNum);
    }
}

- (void)testSequenceNumberSynchronization {
    NSInteger restoredEventSN = 10;
    
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    [given([clientState eventSequenceNumber]) willReturnInteger:restoredEventSN];
    
    Event *event1 = [[Event alloc] init];
    event1.seqNum = (int)restoredEventSN++;
    event1.eventClassFQN = nil;
    event1.eventData = nil;
    event1.source = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    event1.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    Event *event2 = [[Event alloc] init];
    event2.seqNum = (int)restoredEventSN++;
    event2.eventClassFQN = nil;
    event2.eventData = nil;
    event2.source = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    event2.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    Event *event3 = [[Event alloc] init];
    event3.seqNum = (int)restoredEventSN++;
    event3.eventClassFQN = nil;
    event3.eventData = nil;
    event3.source = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    event3.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    NSArray *events1 = @[event1, event2, event3];
    
    id <EventManager> manager1 = mockProtocol(@protocol(EventManager));
    [given([manager1 pollPendingEvents]) willReturn:events1];
    [given([manager1 peekPendingEvents]) willReturn:events1];
    
    id <EventTransport> transport = [[DefaultEventTransport alloc] initWithState:clientState];
    [transport setEventManager:manager1];
    
    NSInteger requestId = 1;
    [transport createEventRequest:requestId++];
    
    int lastReceivedSN = 5;
    EventSyncResponse *eventResponse1 = [[EventSyncResponse alloc] init];
    eventResponse1.eventSequenceNumberResponse =
    [KAAUnion unionWithBranch:KAA_UNION_EVENT_SEQUENCE_NUMBER_RESPONSE_OR_NULL_BRANCH_0
                      andData:[NSNumber numberWithInt:lastReceivedSN]];
    eventResponse1.eventListenersResponses =
    [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_BRANCH_1];
    eventResponse1.events = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_1];
    
    [transport onEventResponse:eventResponse1];
    
    EventSyncRequest *eventRequest2 = [transport createEventRequest:requestId];
    
    XCTAssertTrue(eventRequest2.eventSequenceNumberRequest.data == nil);
    XCTAssertTrue([eventRequest2.events.data count] == [events1 count]);
    
    NSInteger synchronizedSN = lastReceivedSN + 1;
    for (Event *ev in eventRequest2.events.data) {
        XCTAssertEqual(synchronizedSN++, ev.seqNum);
    }
    
    [transport onSyncResposeIdReceived:requestId++];
    
    Event *event = [[Event alloc] init];
    event.seqNum = (int)synchronizedSN;
    event.eventClassFQN = nil;
    event.eventData = nil;
    event.source = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    event.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    NSArray *events2 = @[event];
    id <EventManager> manager2 = mockProtocol(@protocol(EventManager));
    [given([manager2 pollPendingEvents]) willReturn:events2];
    [transport setEventManager:manager2];
    
    EventSyncRequest *eventRequest4 = [transport createEventRequest:requestId++];
    
    XCTAssertTrue([eventRequest4.events.data[0] seqNum] == synchronizedSN);
}

#pragma mark - Supporting methods

- (EventSyncResponse *) getNewEmptyEventResponse {
    EventSyncResponse *response = [[EventSyncResponse alloc] init];
    response.eventSequenceNumberResponse =
    [KAAUnion unionWithBranch:KAA_UNION_EVENT_SEQUENCE_NUMBER_RESPONSE_OR_NULL_BRANCH_0
                      andData:[NSNumber numberWithInt:0]];
    
    response.eventListenersResponses =
    [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_LISTENERS_RESPONSE_OR_NULL_BRANCH_1];
    
    response.events = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_OR_NULL_BRANCH_1];
    return response;
}

- (Event *) getNewEvent {
    NSInteger one = 1;
    NSInteger two = 2;
    NSInteger three = 3;
    NSMutableData *data = [NSMutableData dataWithBytes:&one length:sizeof(one)];
    [data appendBytes:&two length:sizeof(two)];
    [data appendBytes:&three length:sizeof(three)];
    dataWith123 = data;
    Event *event = [[Event alloc] init];
    event.seqNum = 5;
    event.eventClassFQN = @"eventClassFQN";
    event.eventData = data;
    event.source = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_0 andData:@"source"];
    event.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_0 andData:@"target"];
    return event;
}

- (EventListenersResponse *) getNewEventListenerResponse {
    EventListenersResponse *response = [[EventListenersResponse alloc] init];
    response.requestId = 0;
    response.listeners = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_1];
    response.result = SYNC_RESPONSE_RESULT_TYPE_SUCCESS;
    return  response;
}


@end
