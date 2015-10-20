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

#define STATE_FILE_NAME @"state.properties"
#define STATE_FILE_LOCATION @"state_file_location"
#define STATE_FILE_DEFAULT  @"state_properties"

static NSArray *topicsArray;


@interface TestNotificationTopicListDelegate : NSObject <NotificationTopicListDelegate>

@end

@implementation TestNotificationTopicListDelegate

- (void) onListUpdated:(NSArray *)list {
    XCTAssertEqualObjects(topicsArray, list);
    topicsArray = [NSArray array];
}

@end

@interface DefaultNotificationManagerTest : XCTestCase

@property (strong, nonatomic) id <ExecutorContext> executorContext;
@property (strong, nonatomic) NSOperationQueue *executor;
@property (nonatomic,strong) AvroBytesConverter *converter;

- (KaaClientProperties *)getProperties;

@end

@implementation DefaultNotificationManagerTest

- (void) setUp {
    [super setUp];
    self.executorContext = mockProtocol(@protocol(ExecutorContext));
    self.executor = [[NSOperationQueue alloc] init];
    self.converter = [[AvroBytesConverter alloc] init];
    
    [given([self.executorContext getApiExecutor]) willReturn:self.executor];
    [given([self.executorContext getCallbackExecutor]) willReturn:self.executor];
    
    NSError *error = nil;
    NSString *storage = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *stateFileName = STATE_FILE_DEFAULT;
    NSString *stateFileLocation = [[[NSURL fileURLWithPath:storage] URLByAppendingPathComponent:stateFileName] path];
    [[NSFileManager defaultManager] removeItemAtPath:stateFileLocation error:&error];
}

- (void) testEmptyTopicList {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
    
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    for (Topic *t in [notificationManager getTopics]) {
        NSLog(@"%@", t);
    }
    
    XCTAssertTrue([[notificationManager getTopics] count] == 0);
}

- (void) testTopicsAfterUpdate {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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

- (void) testTopicPersistence {
    KaaClientProperties *prop = [self getProperties];
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
    
    KaaClientPropertiesState *newState = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
    DefaultNotificationManager *newNotificationManager = [[DefaultNotificationManager alloc] initWith:newState executorContext:self.executorContext notificationTransport:transport];
    
    XCTAssertTrue([[newNotificationManager getTopics] count] == [topicsArray count]);
}

- (void) testTwiceTopicUpdate {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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

- (void) testAddTopicUpdateListener {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, topic3, nil];
    
    TestNotificationTopicListDelegate *delegate = [[TestNotificationTopicListDelegate alloc] init];
    [notificationManager addTopicListDelegate:delegate];
    
    [notificationManager topicsListUpdated:topicsArray];
    [NSThread sleepForTimeInterval:3.f];
    
    XCTAssertEqual(0, [topicsArray count]);
}

- (void) testRemoveTopicUpdateDelegate {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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

- (void) testGlobalNotificationDelegates {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    
    KAANotification *notification = [[KAANotification alloc] init];
    NSData *notificationBody = [self.converter toBytes:notification];
    
    [notificationManager topicsListUpdated:topicsArray];
    
    Notification *notification1 = [[Notification alloc] init];
    notification1.topicId = @"id1";
    notification1.type = NOTIFICATION_TYPE_CUSTOM;
    notification1.uid = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    notification1.seqNumber = [KAAUnion unionWithBranch:KAA_UNION_INT_OR_NULL_BRANCH_0 andData:[NSNumber numberWithInt:1]];
    notification1.body = notificationBody;
    Notification *notification2 = [[Notification alloc] init];
    notification2.topicId = @"id2";
    notification2.type = NOTIFICATION_TYPE_CUSTOM;
    notification2.uid = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
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

- (void) testNotificationDelegateOnTopic {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
    id <NotificationTransport> transport = mockProtocol(@protocol(NotificationTransport));
    
    DefaultNotificationManager *notificationManager = [[DefaultNotificationManager alloc] initWith:state executorContext:self.executorContext notificationTransport:transport];
    
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"id1";
    topic1.name = @"topic_name1";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"id2";
    topic2.name = @"topic_name1";
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    
    KAANotification *notification = [[KAANotification alloc] init];
    NSData *notificationBody = [self.converter toBytes:notification];
    
    [notificationManager topicsListUpdated:topicsArray];
    
    Notification *notification1 = [[Notification alloc] init];
    notification1.topicId = @"id1";
    notification1.type = NOTIFICATION_TYPE_CUSTOM;
    notification1.uid = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
    notification1.seqNumber = [KAAUnion unionWithBranch:KAA_UNION_INT_OR_NULL_BRANCH_0 andData:[NSNumber numberWithInt:1]];
    notification1.body = notificationBody;
    Notification *notification2 = [[Notification alloc] init];
    notification2.topicId = @"id2";
    notification2.type = NOTIFICATION_TYPE_CUSTOM;
    notification2.uid = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_1];
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
    
    [NSThread sleepForTimeInterval:5.f];
    
    [verifyCount(globalDelegate, times([notificationUpdate count] * 2 - 1)) onNotification:anything() withTopicId:anything()];
    [verifyCount(topicDelegate, times(1)) onNotification:anything() withTopicId:anything()];
}

- (void) testAddDelegateForUnknownTopic {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:topicsArray];
    
    id <NotificationDelegate> delegate= mockProtocol(@protocol(NotificationDelegate));
    @try {
        [notificationManager addNotificationDelegate:delegate forTopic:@"unknown_id"];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testAddDelegateForUnknownTopic sucseed");
    }
}

- (void) testRemoveDelegateForUnknownTopic {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:topicsArray];
    
    id <NotificationDelegate> delegate= mockProtocol(@protocol(NotificationDelegate));
    @try {
        [notificationManager removeNotificationDelegate:delegate forTopic:@"unknown_id"];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testRemoveDelegateForUnknownTopic sucseed");
    }
}

- (void) testSubsribeForUnknownTopic1 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:topicsArray];
    
    @try {
        [notificationManager subscribeToTopic:@"unknown_id" forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubsribeForUnknownTopic1 sucseed");
    }
}

- (void) testSubsribeForUnknownTopic2 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:topicsArray];
    NSArray *topics = [NSArray arrayWithObjects:@"id1", @"id2", @"unknown_id", nil];
    @try {
        [notificationManager subscribeToTopics:topics forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubsribeForUnknownTopic2 sucseed");
    }
}

- (void) testUnsubsribeForUnknownTopic1 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:topicsArray];
    @try {
        [notificationManager unsubscribeFromTopic:@"unknown_id" forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubsribeForUnknownTopic1 sucseed");
    }
}

- (void) testUnsubsribeForUnknownTopic2 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    
    [notificationManager topicsListUpdated:topicsArray];
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
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    [notificationManager topicsListUpdated:topicsArray];
    @try {
        [notificationManager subscribeToTopic:@"id2" forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubscribeOnMandatoryTopic1 succseed");
    }
}

- (void)testSubscribeOnMandatoryTopic2 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    [notificationManager topicsListUpdated:topicsArray];
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
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    [notificationManager topicsListUpdated:topicsArray];
    @try {
        [notificationManager unsubscribeFromTopic:@"id2" forceSync:YES];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSubscribeOnMandatoryTopic2 succseed");
    }
}

- (void)testUnsubscribeFromMandatoryTopic2 {
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, nil];
    [notificationManager topicsListUpdated:topicsArray];
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
    KaaClientPropertiesState *state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
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
    topicsArray = [NSArray arrayWithObjects:topic1, topic2, topic3, nil];
    
    [notificationManager topicsListUpdated:topicsArray];
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

#pragma mark - Supporting methods

- (KaaClientProperties *)getProperties {
    KaaClientProperties *properties = [[KaaClientProperties alloc] initDefaults:[CommonBase64 new]];
    [properties setString:STATE_FILE_NAME forKey:STATE_FILE_LOCATION];
    [properties setString:@"0" forKey:TRANSPORT_POLL_DELAY];
    [properties setString:@"1" forKey:TRANSPORT_POLL_PERIOD];
    [properties setString:@"1" forKey:TRANSPORT_POLL_UNIT];
    [properties setString:@"123456" forKey:SDK_TOKEN];
    [properties setString:STATE_FILE_DEFAULT forKey:STATE_FILE_LOCATION];
    return properties;
}



@end
