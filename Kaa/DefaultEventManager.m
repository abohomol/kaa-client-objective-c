//
//  DefaultEventManager.m
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultEventManager.h"
#import "EventListenersRequestBinding.h"
#import "EndpointGen.h"
#include <stdlib.h>
#import "KaaLogging.h"

#define TAG @"DefaultEventManager >>>"

@interface DefaultEventManager ()

@property (nonatomic,strong) id<KaaClientState> state;;
@property (nonatomic,strong) id<ExecutorContext> executorContext;
@property (nonatomic,strong) id<EventTransport> transport;

@property (nonatomic,strong) NSMutableSet *registeredEventFamilies;         //<BaseEventFamily>
@property (nonatomic,strong) NSMutableArray *currentEvents;                 //<Event>
@property (nonatomic,strong) NSMutableDictionary *eventListenersRequests;   //<NSNumber, EventListenersRequestBinding>
@property (nonatomic,strong) NSMutableDictionary *transactions;             //<TransactionId, NSArray<Event>>

@property (nonatomic) BOOL isEngaged;

@property (nonatomic,strong) NSObject *eventGuard;
@property (nonatomic,strong) NSObject *trxGuard;

- (NSMutableArray *)getPendingEvents:(BOOL)clear;

@end

@implementation DefaultEventManager

- (instancetype)initWith:(id<KaaClientState>)state
         executorContext:(id<ExecutorContext>)executorContext
          eventTransport:(id<EventTransport>)transport {
    self = [super init];
    if (self) {
        self.state = state;
        self.executorContext = executorContext;
        self.transport = transport;
        
        self.registeredEventFamilies = [NSMutableSet set];
        self.currentEvents = [NSMutableArray array];
        self.eventListenersRequests = [NSMutableDictionary dictionary];
        self.transactions = [NSMutableDictionary dictionary];
        
        self.isEngaged = NO;
        self.eventGuard = [[NSObject alloc] init];
        self.trxGuard = [[NSObject alloc] init];
    }
    return self;
}

- (void)fillEventListenersSyncRequest:(EventSyncRequest *)request {
    if ([self.eventListenersRequests count] > 0) {
        DDLogDebug(@"%@ Unresolved eventListenersResolution request count: %li",
                   TAG, (long)[self.eventListenersRequests count]);
        NSMutableArray *requests = [NSMutableArray array];
        for (EventListenersRequestBinding *bind in self.eventListenersRequests.allValues) {
            if (!bind.isSent) {
                [requests addObject:bind.request];
                bind.isSent = YES;
            }
        }
        request.eventListenersRequests = [KAAUnion unionWithBranch:KAA_UNION_ARRAY_EVENT_LISTENERS_REQUEST_OR_NULL_BRANCH_0 andData:requests];
    }
}

- (void)clearState {
    @synchronized(self.eventGuard) {
        [self.currentEvents removeAllObjects];
    }
}

- (void)produceEvent:(NSString *)eventFQN data:(NSData *)data target:(NSString *)target {
    [self produceEvent:eventFQN data:data target:target transactionId:nil];
}

- (void)produceEvent:(NSString *)eventFQN data:(NSData *)data target:(NSString *)target transactionId:(TransactionId *)transactionId {
    if (transactionId) {
        DDLogInfo(@"%@ Adding event [eventClassFQN: %@, target: %@] to transaction %@", TAG, eventFQN, (target ? target : @"broadcast"), transactionId);
        @synchronized(self.trxGuard) {
            NSMutableArray *events = [self.transactions objectForKey:transactionId];
            if (events) {
                Event *event = [[Event alloc] init];
                event.seqNum = -1;
                event.eventClassFQN = eventFQN;
                event.eventData = [NSData dataWithData:data];
                if (target) {
                    event.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_0 andData:target];
                }
                [events addObject:event];
            } else {
                DDLogWarn(@"%@ Transaction with id %@ is missing. Ignoring event.", TAG, transactionId);
            }
        }
    } else {
        DDLogInfo(@"%@ Producing event [eventClassFQN: %@, target: %@]", TAG, eventFQN, (target ? target : @"broadcast"));
        @synchronized(self.eventGuard) {
            Event *event = [[Event alloc] init];
            event.seqNum = [self.state getAndIncrementEventSequenceNumber];
            event.eventClassFQN = eventFQN;
            event.eventData = [NSData dataWithData:data];
            if (target) {
                event.target = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_0 andData:target];
            }
            [self.currentEvents addObject:event];
        }
        
        if (!self.isEngaged) {
            [self.transport sync];
        }
    }
}

- (void)registerEventFamily:(id<BaseEventFamily>)eventFamily {
    [self.registeredEventFamilies addObject:eventFamily];
}

- (void)onGenericEvent:(NSString *)eventFQN data:(NSData *)data source:(NSString *)source {
    DDLogInfo(@"%@ Received event [eventClassFQN: %@]", TAG, eventFQN);
    for (id<BaseEventFamily> family in self.registeredEventFamilies) {
        DDLogInfo(@"%@ Lookup event fqn %@ in family %@", TAG, eventFQN, family);
        if ([[family getSupportedEventFQNs] containsObject:eventFQN]) {
            DDLogInfo(@"%@ Event fqn [%@] found in family [%@]", TAG, eventFQN, family);
            [[self.executorContext getCallbackExecutor] addOperationWithBlock:^{
                [family onGenericEvent:eventFQN withData:data from:source];
            }];
        }
    }
}

- (NSInteger)findEventListeners:(NSArray *)eventFQNs delegate:(id<FindEventListenersDelegate>)delegate {
    int requestId = arc4random();
    EventListenersRequest *request = [[EventListenersRequest alloc] init];
    request.requestId = requestId;
    request.eventClassFQNs = eventFQNs;
    EventListenersRequestBinding *bind = [[EventListenersRequestBinding alloc] initWithRequest:request delegate:delegate];
    [self.eventListenersRequests setObject:bind forKey:[NSNumber numberWithInt:requestId]];
    DDLogDebug(@"%@ Adding event listener resolution request. Request ID: %i", TAG, requestId);
    if (!self.isEngaged) {
        [self.transport sync];
    }
    return requestId;
}

- (void)eventListenersResponseReceived:(NSArray *)response {
    for (EventListenersResponse *singleResponse in response) {
        DDLogDebug(@"%@ Received event listener resolution response: %@", TAG, singleResponse);
        EventListenersRequestBinding *bind = [self.eventListenersRequests objectForKey:[NSNumber numberWithInt:singleResponse.requestId]];
        if (bind) {
            [self.eventListenersRequests removeObjectForKey:[NSNumber numberWithInt:singleResponse.requestId]];
            if (singleResponse.result == SYNC_RESPONSE_RESULT_TYPE_SUCCESS
                && singleResponse.listeners.branch == KAA_UNION_ARRAY_STRING_OR_NULL_BRANCH_0) {
                [bind.delegate onEventListenersReceived:((NSArray *)singleResponse.listeners.data)];
            } else {
                [bind.delegate onRequestFailed];
            }
        }
    }
}

- (NSArray *)pollPendingEvents {
    return [self getPendingEvents:YES];
}

- (NSArray *)peekPendingEvents {
    return [self getPendingEvents:NO];
}

- (NSMutableArray *)getPendingEvents:(BOOL)clear {
    @synchronized(self.eventGuard) {
        NSMutableArray *pendingEvents = [NSMutableArray arrayWithArray:self.currentEvents];
        if (clear) {
            [self.currentEvents removeAllObjects];
        }
    return pendingEvents;
    }
}

- (TransactionId *)beginTransaction {
    TransactionId *trxId = [[TransactionId alloc] init];
    @synchronized(self.trxGuard) {
        if (![self.transactions objectForKey:trxId]) {
            DDLogDebug(@"%@ Creating events transaction with id [%@]", TAG, trxId);
            [self.transactions setObject:[NSMutableArray array] forKey:trxId];
        }
    }
    return trxId;
}

- (void)commit:(TransactionId *)trxId {
    DDLogDebug(@"%@ Committing events transaction with id [%@]", TAG, trxId);
    @synchronized(self.trxGuard) {
        NSArray *eventsToCommit = [self.transactions objectForKey:trxId];
        if (eventsToCommit) {
            [self.transactions removeObjectForKey:trxId];
            
            @synchronized(self.eventGuard) {
                for (Event *event in eventsToCommit) {
                    event.seqNum = [self.state getAndIncrementEventSequenceNumber];
                    [self.currentEvents addObject:event];
                }
            }
        }
        if (!self.isEngaged) {
            [self.transport sync];
        }
    }
}

- (void)rollback:(TransactionId *)trxId {
    DDLogDebug(@"%@ Rolling back events transaction with id %@", TAG, trxId);
    @synchronized(self.trxGuard) {
        NSMutableArray *eventsToRemove = [self.transactions objectForKey:trxId];
        if (eventsToRemove) {
            [self.transactions removeObjectForKey:trxId];
            for (Event *event in eventsToRemove) {
                DDLogVerbose(@"%@ Removing event %@", TAG, event);
            }
        } else {
            DDLogDebug(@"%@ Transaction with id [%@] was not created", TAG, trxId);
        }
    }
}

- (void)engageDataChannel {
    @synchronized (self) {
        self.isEngaged = YES;
    }
}

- (BOOL)releaseDataChannel {
    @synchronized (self) {
        self.isEngaged = NO;
        BOOL needSync = [self.currentEvents count] > 0;
        if (!needSync) {
            for (EventListenersRequestBinding *bind in self.eventListenersRequests.allValues) {
                needSync |= !bind.isSent;
            }
        }
        return needSync;
    }
}

@end
