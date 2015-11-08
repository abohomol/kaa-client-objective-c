//
//  DefaultNotificationManagerTest.m
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
#import "ExecutorContext.h"
#import "KaaClientPropertiesState.h"
#import "KaaClientProperties.h"
#import "NotificationTransport.h"
#import "DefaultNotificationManager.h"
#import "AvroBytesConverter.h"
#import "EndpointGen.h"
#import "TestsHelper.h"

@interface DefaultNotificationManagerTest : XCTestCase <NotificationTopicListDelegate>

@property (nonatomic,strong) id<ExecutorContext> executorContext;
@property (nonatomic,strong) NSOperationQueue *executor;
@property (nonatomic,strong) AvroBytesConverter *converter;
@property (nonatomic,strong) NSMutableArray *topicsArray;

@end

@implementation DefaultNotificationManagerTest

- (void)onListUpdated:(NSArray *)list {
    KAATestEqual(self.topicsArray, list);
    [self.topicsArray removeAllObjects];
}

- (void)setUp {
    [super setUp];
    self.executorContext = mockProtocol(@protocol(ExecutorContext));
    self.executor = [[NSOperationQueue alloc] init];
    self.converter = [[AvroBytesConverter alloc] init];
    
    [self.topicsArray removeAllObjects];
    
    [given([self.executorContext getApiExecutor]) willReturn:self.executor];
    [given([self.executorContext getCallbackExecutor]) willReturn:self.executor];
    
    NSError *error = nil;
    NSString *storage = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *stateFileLocation = [[[NSURL fileURLWithPath:storage] URLByAppendingPathComponent:STATE_FILE_DEFAULT] path];
    [[NSFileManager defaultManager] removeItemAtPath:stateFileLocation error:&error];
}

- (void)tearDown {
    [super tearDown];
    [self.executor cancelAllOperations];
}

- (void)testEmptyTopicList {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    for (Topic *t in [notificationManager getTopics]) {
        NSLog(@"%@", t);
    }
    
    XCTAssertTrue([[notificationManager getTopics] count] == 0);
}

- (void)testTopicsAfterUpdate {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name2";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    
    NSArray *topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    [notificationManager topicsListUpdated:topicsArray];
    
    XCTAssertTrue([[notificationManager getTopics] count] == [topicsArray count]);
}

- (void)testTopicPersistence {
    KaaClientProperties *prop = [TestsHelper getProperties];
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:prop];
    
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name2";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    NSArray *topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:topicsArray];
    [state persist];
    
    KaaClientPropertiesState *newState = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    DefaultNotificationManager *newNotificationManager = [[DefaultNotificationManager alloc] initWith:newState executorContext:self.executorContext notificationTransport:transport];
    
    XCTAssertTrue([[newNotificationManager getTopics] count] == [topicsArray count]);
}

- (void)testTwiceTopicUpdate {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    Topic *topic3 = [[Topic alloc] init];
    topic3.id = @"id3";
    topic3.name = @"topic_name1";
    NSMutableArray *topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:topicsArray];
    
    [topicsArray removeObject:topic2];
    [topicsArray addObject:topic3];
    
    [notificationManager topicsListUpdated:topicsArray];
    
    NSArray *newTopics = [NSArray arrayWithArray:[notificationManager getTopics]];
    
    XCTAssertTrue([newTopics count] == [topicsArray count]);
    XCTAssertTrue([newTopics containsObject:topic1]);
    XCTAssertTrue([newTopics containsObject:topic3]);
}

- (void)testAddTopicUpdateListener {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    Topic *topic3 = [[Topic alloc] init];
    topic3.id = @"id3";
    topic3.name = @"topic_name1";
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, topic3, nil];
    
    [notificationManager addTopicListDelegate:self];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    [NSThread sleepForTimeInterval:0.5f];
    
    XCTAssertEqual(0, [self.topicsArray count]);
}

- (void)testRemoveTopicUpdateDelegate {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    id <NotificationTopicListDelegate> delegate1 = mockProtocol(@protocol(NotificationTopicListDelegate));
    id <NotificationTopicListDelegate> delegate2 = mockProtocol(@protocol(NotificationTopicListDelegate));
    
    [notificationManager addTopicListDelegate:delegate1];
    [notificationManager addTopicListDelegate:delegate2];
    
    NSArray *topicUpdate = [NSArray array];
    
    [notificationManager topicsListUpdated:topicUpdate];
    [notificationManager removeTopicListDelegate:delegate2];
    [notificationManager topicsListUpdated:topicUpdate];
    
    [NSThread sleepForTimeInterval:2];
    [verifyCount(delegate1, times(2)) onListUpdated:topicUpdate];
    [verifyCount(delegate2, times(1)) onListUpdated:topicUpdate];
}

- (void)testGlobalNotificationDelegates {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    
    KAANotification *notification = [[KAANotification alloc] init];
    NSData *notificationBody = [self.converter toBytes:notification];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    
    Notification *notification1 = [[Notification alloc] init];
    notification1.topicId = @"id1";
    notification1.type = NOTIFICATION_TYPE_CUSTOM;
    notification1.seqNumber = [KAAUnion unionWithBranch:KAA_UNION_INT_OR_NULL_BRANCH_0 andData:[NSNumber numberWithInt:1]];
    notification1.body = notificationBody;
    
    Notification *notification2 = [[Notification alloc] init];
    notification2.topicId = @"id2";
    notification2.type = NOTIFICATION_TYPE_CUSTOM;
    notification2.seqNumber = [KAAUnion unionWithBranch:KAA_UNION_INT_OR_NULL_BRANCH_0 andData:[NSNumber numberWithInt:1]];
    notification2.body = notificationBody;
    
    NSArray *notificationUpdate = [NSArray arrayWithObjects:notification1, notification2, nil];
    
    id <NotificationDelegate> mandatoryDelegate= mockProtocol(@protocol(NotificationDelegate));
    id <NotificationDelegate> globalDelegate = mockProtocol(@protocol(NotificationDelegate));
    
    [notificationManager addNotificationDelegate:mandatoryDelegate];
    [notificationManager notificationReceived:notificationUpdate];
    
    [NSThread sleepForTimeInterval:1.f];
    
    [notificationManager removeNotificationDelegate:mandatoryDelegate];
    [notificationManager addNotificationDelegate:globalDelegate];
    
    [notificationManager notificationReceived:notificationUpdate];
    [notificationManager notificationReceived:notificationUpdate];
    
    [NSThread sleepForTimeInterval:2.f];
    
    [verifyCount(mandatoryDelegate, times([notificationUpdate count])) onNotification:anything() withTopicId:anything()];
    
    [verifyCount(globalDelegate, times([notificationUpdate count] * 2)) onNotification:anything() withTopicId:anything()];
}

- (void)testNotificationDelegateOnTopic {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    
    KAANotification *notification = [[KAANotification alloc] init];
    NSData *notificationBody = [self.converter toBytes:notification];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    
    Notification *notification1 = [[Notification alloc] init];
    notification1.topicId = @"id1";
    notification1.type = NOTIFICATION_TYPE_CUSTOM;
    notification1.seqNumber = [KAAUnion unionWithBranch:KAA_UNION_INT_OR_NULL_BRANCH_0 andData:[NSNumber numberWithInt:1]];
    notification1.body = notificationBody;
    
    Notification *notification2 = [[Notification alloc] init];
    notification2.topicId = @"id2";
    notification2.type = NOTIFICATION_TYPE_CUSTOM;
    notification2.seqNumber = [KAAUnion unionWithBranch:KAA_UNION_INT_OR_NULL_BRANCH_0 andData:[NSNumber numberWithInt:1]];
    notification2.body = notificationBody;
    
    NSArray *notificationUpdate = [NSArray arrayWithObjects:notification1, notification2, nil];
    
    id <NotificationDelegate> globalDelegate= mockProtocol(@protocol(NotificationDelegate));
    id <NotificationDelegate> topicDelegate = mockProtocol(@protocol(NotificationDelegate));
    
    [notificationManager addNotificationDelegate:globalDelegate];
    [notificationManager addNotificationDelegate:topicDelegate forTopic:@"id2"];
    
    [notificationManager notificationReceived:notificationUpdate];
    [notificationManager removeNotificationDelegate:topicDelegate forTopic:@"id2"];
    [notificationManager notificationReceived:notificationUpdate];
    
    [NSThread sleepForTimeInterval:1.f];
    
    [verifyCount(globalDelegate, times([notificationUpdate count] * 2 - 1)) onNotification:anything() withTopicId:anything()];
    
    [NSThread sleepForTimeInterval:1.f];
    
    [verifyCount(topicDelegate, times(1)) onNotification:anything() withTopicId:anything()];
}

- (void)testAddDelegateForUnknownTopic {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    
    id <NotificationDelegate> delegate= mockProtocol(@protocol(NotificationDelegate));
    @try {
        [notificationManager addNotificationDelegate:delegate forTopic:@"unknown_id"];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testAddDelegateForUnknownTopic sucseed");
    }
}

- (void)testRemoveDelegateForUnknownTopic {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    
    id <NotificationDelegate> delegate= mockProtocol(@protocol(NotificationDelegate));
    @try {
        [notificationManager removeNotificationDelegate:delegate forTopic:@"unknown_id"];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testRemoveDelegateForUnknownTopic sucseed");
    }
}

- (void)testSubsribeForUnknownTopic1 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    
    @try {
        [notificationManager subscribeToTopic:@"unknown_id" forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubsribeForUnknownTopic1 sucseed");
    }
}

- (void)testSubsribeForUnknownTopic2 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    NSArray *topics = [NSArray arrayWithObjects:@"id1", @"id2", @"unknown_id", nil];
    @try {
        [notificationManager subscribeToTopics:topics forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubsribeForUnknownTopic2 sucseed");
    }
}

- (void)testUnsubsribeForUnknownTopic1 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    @try {
        [notificationManager unsubscribeFromTopic:@"unknown_id" forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubsribeForUnknownTopic1 sucseed");
    }
}

- (void)testUnsubsribeForUnknownTopic2 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    NSArray *topics = [NSArray arrayWithObjects:@"id1", @"id2", @"unknown_id", nil];
    @try {
        [notificationManager unsubscribeFromTopics:topics forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubsribeForUnknownTopic1 sucseed");
    }
}

- (void)testSubscribeOnMandatoryTopic1 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_OPTIONAL_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    [notificationManager topicsListUpdated:self.topicsArray];
    @try {
        [notificationManager subscribeToTopic:@"id2" forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubscribeOnMandatoryTopic1 succseed");
    }
}

- (void)testSubscribeOnMandatoryTopic2 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_OPTIONAL_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    [notificationManager topicsListUpdated:self.topicsArray];
    NSArray *array = [NSArray arrayWithObjects:@"id1", @"id2", nil];
    @try {
        [notificationManager subscribeToTopics:array forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubscribeOnMandatoryTopic2 succseed");
    }
}

- (void)testUnsubscribeFromMandatoryTopic1 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_OPTIONAL_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    [notificationManager topicsListUpdated:self.topicsArray];
    @try {
        [notificationManager unsubscribeFromTopic:@"id2" forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubscribeOnMandatoryTopic2 succseed");
    }
}

- (void)testUnsubscribeFromMandatoryTopic2 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_OPTIONAL_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, nil];
    [notificationManager topicsListUpdated:self.topicsArray];
    NSArray *array = [NSArray arrayWithObjects:@"id1", @"id2", nil];
    @try {
        [notificationManager unsubscribeFromTopics:array forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubscribeOnMandatoryTopic2 succseed");
    }
}

- (void)testSuccessSubscriptionToTopic {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[TestsHelper getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_OPTIONAL_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_OPTIONAL_SUBSCRIPTION;
    Topic *topic3 = [[Topic alloc] init];
    topic3.id = @"id3";
    topic3.name = @"topic_name1";
    topic3.subscriptionType = SUBSCRIPTION_TYPE_OPTIONAL_SUBSCRIPTION;
    self.topicsArray = [NSMutableArray arrayWithObjects:topic1, topic2, topic3, nil];
    
    [notificationManager topicsListUpdated:self.topicsArray];
    [notificationManager subscribeToTopic:@"id1" forceSync:YES];
    
    [verifyCount(transport, times(1)) sync];
    
    [notificationManager subscribeToTopics:@[@"id1", @"id2"] forceSync:NO];
    [notificationManager unsubscribeFromTopic:@"id1" forceSync:NO];
    
    [verifyCount(transport, times(1)) sync];
    
    [notificationManager sync];
    
    [verifyCount(transport, times(2)) sync];
    
    [notificationManager unsubscribeFromTopics:@[@"id1", @"id2"] forceSync:YES];
    
    [verifyCount(transport, times(3)) sync];
}

@end
