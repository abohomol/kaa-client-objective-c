//
//  SyncTaskTest.m
//  Kaa
//
//  Created by Anton Bohomol on 10/5/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SyncTask.h"

#define TAG @"SyncTaskTest >>>"

@interface SyncTaskTest : XCTestCase

@end

@implementation SyncTaskTest

- (void)testMerge {
    SyncTask *task1 = [[SyncTask alloc] initWithTransport:TRANSPORT_TYPE_CONFIGURATION ackOnly:YES all:NO];
    SyncTask *task2 = [[SyncTask alloc] initWithTransport:TRANSPORT_TYPE_NOTIFICATION ackOnly:NO all:NO];
    
    SyncTask *merged = [SyncTask merge:task1 additionalTasks:[NSArray arrayWithObject:task2]];
    
    XCTAssertEqual(2, [[merged getTransportTypes] count]);
    XCTAssertFalse([merged isAckOnly]);
    XCTAssertFalse([merged isAll]);
}

- (void)testMergeAcks {
    SyncTask *task1 = [[SyncTask alloc] initWithTransport:TRANSPORT_TYPE_CONFIGURATION ackOnly:YES all:NO];
    SyncTask *task2 = [[SyncTask alloc] initWithTransport:TRANSPORT_TYPE_NOTIFICATION ackOnly:YES all:NO];
    
    SyncTask *merged = [SyncTask merge:task1 additionalTasks:[NSArray arrayWithObject:task2]];
    
    XCTAssertEqual(2, [[merged getTransportTypes] count]);
    XCTAssertTrue([merged isAckOnly]);
    XCTAssertFalse([merged isAll]);
}

- (void)testMergeAll {
    SyncTask *task1 = [[SyncTask alloc] initWithTransport:TRANSPORT_TYPE_CONFIGURATION ackOnly:YES all:NO];
    SyncTask *task2 = [[SyncTask alloc] initWithTransport:TRANSPORT_TYPE_NOTIFICATION ackOnly:NO all:YES];
    
    SyncTask *merged = [SyncTask merge:task1 additionalTasks:[NSArray arrayWithObject:task2]];
    
    XCTAssertEqual(2, [[merged getTransportTypes] count]);
    XCTAssertFalse([merged isAckOnly]);
    XCTAssertTrue([merged isAll]);
}

@end
