//
//  KaaClientPropertiesStateTest.m
//  Kaa
//
//  Created by Anton Bohomol on 10/6/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KaaClientPropertiesState.h"
#import "NSData+Conversion.h"

#define STATE_FILE_NAME @"state.properties"

@interface KaaClientPropertiesStateTest : XCTestCase

@property (nonatomic,strong) id<KaaClientState> state;

- (KaaClientProperties *)getProperties;

@end

@implementation KaaClientPropertiesStateTest

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

- (void)setUp {
    [super setUp];
    self.state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
    NSLog(@"New state created!");
}

- (void)testKeys {
    SecKeyRef privateKey = [self.state privateKey];
    SecKeyRef publicKey = [self.state publicKey];
    XCTAssertTrue(privateKey != NULL);
    XCTAssertTrue(publicKey != NULL);
}

- (void)testProfileHash {
    NSData *hashEntry = [@"testProfileHash" dataUsingEncoding:NSUTF8StringEncoding];
    EndpointObjectHash *hash = [EndpointObjectHash fromSHA1:hashEntry];
    [self.state setProfileHash:hash];
    XCTAssertTrue([hash isEqual:[self.state profileHash]]);
}

- (void)testNfSubscription {
    Topic *topic1 = [[Topic alloc] init];
    topic1.id = @"1234";
    topic1.name = @"testName";
    topic1.subscriptionType = SUBSCRIPTION_TYPE_OPTIONAL_SUBSCRIPTION;
    
    Topic *topic2 = [[Topic alloc] init];
    topic2.id = @"4321";
    topic2.name = @"testName";
    topic2.subscriptionType = SUBSCRIPTION_TYPE_MANDATORY_SUBSCRIPTION;
    
    [self.state addTopic:topic1];
    [self.state addTopic:topic2];
    
    [self.state updateTopicSubscriptionInfo:topic2.id sequence:1];
    
    [self.state updateTopicSubscriptionInfo:topic1.id sequence:0];
    [self.state updateTopicSubscriptionInfo:topic1.id sequence:5];
    [self.state updateTopicSubscriptionInfo:topic1.id sequence:1];
    
    NSMutableDictionary *expected = [NSMutableDictionary dictionary];
    [expected setObject:[NSNumber numberWithInt:5] forKey:topic1.id];
    [expected setObject:[NSNumber numberWithInt:1] forKey:topic2.id];
    
    XCTAssertTrue([expected isEqualToDictionary:[self.state getNfSubscriptions]]);
    
    [self.state persist];
    self.state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
    
    XCTAssertTrue([expected isEqualToDictionary:[self.state getNfSubscriptions]]);

    [self.state removeTopic:topic1.id];
    [self.state persist];
    
    self.state = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:[self getProperties]];
    
    [expected removeObjectForKey:topic1.id];
    
    XCTAssertTrue([expected isEqualToDictionary:[self.state getNfSubscriptions]]);
}

- (void)testSDKPropertiesUpdate {
    XCTAssertFalse([self.state isRegistred]);
    
    [self.state setIsRegistred:YES];
    [self.state persist];
    
    XCTAssertTrue([self.state isRegistred]);
    
    KaaClientProperties *properties = [self getProperties];
    [properties setString:@"SDK_TOKEN_100500" forKey:SDK_TOKEN];
    
    KaaClientPropertiesState *newState = [[KaaClientPropertiesState alloc] initWith:[CommonBase64 new] andClientProperties:properties];
    
    XCTAssertFalse([newState isRegistred]);
}

- (void)testClean {
    [self.state persist];
    [self.state persist];
    
    NSString *storage = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *backupFileName = [NSString stringWithFormat:@"%@_bckp", STATE_FILE_DEFAULT];

    NSString *stateFile = [[[NSURL fileURLWithPath:storage] URLByAppendingPathComponent:STATE_FILE_DEFAULT] path];
    NSString *backupFile = [[[NSURL fileURLWithPath:storage] URLByAppendingPathComponent:backupFileName] path];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    XCTAssertTrue([fileManager fileExistsAtPath:stateFile]);
    XCTAssertTrue([fileManager fileExistsAtPath:backupFile]);
    
    [self.state clean];
    XCTAssertFalse([fileManager fileExistsAtPath:stateFile]);
    XCTAssertFalse([fileManager fileExistsAtPath:backupFile]);
}

@end
