//
//  MemBucketTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 14.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "MemBucket.h"

@interface MemBucketTest : XCTestCase

@end

@implementation MemBucketTest

- (void) testAddLogRecord {
    [self addLogRecordTestHelper:10 :2];
    [self addLogRecordTestHelper:20 :10];
    [self addLogRecordTestHelper:5 :2];

}

- (void) testShrinkToSizeRecord {
    MemBucket *bucket = [[MemBucket alloc] initWithId:1 maxSize:800 maxRecordCount:100];
    [self addN:10 recordsToBucket:bucket];
    NSArray *overSizedRecords = [bucket shrinkToSize:25 newCount:5];
    XCTAssertEqual(3, bucket.getCount);
    XCTAssertEqual(24, bucket.getSize);
    XCTAssertEqual(7, [overSizedRecords count]);
    
    bucket = [[MemBucket alloc] initWithId:1 maxSize:800 maxRecordCount:100];
    [self addN:10 recordsToBucket:bucket];
    overSizedRecords = [bucket shrinkToSize:17 newCount:10];
    XCTAssertEqual(2, bucket.getCount);
    XCTAssertEqual(16, bucket.getSize);
    XCTAssertEqual(8, [overSizedRecords count]);
}

- (void) addLogRecordTestHelper:(NSInteger)maxSize :(NSInteger)maxRecordCount {
    MemBucket *bucket = [[MemBucket alloc] initWithId:1 maxSize:maxSize maxRecordCount:maxRecordCount];
    
    NSInteger curSize = 0;
    NSInteger curRecordCount = 0;
    
    NSInteger bts = 123;
    NSData *data = [NSData dataWithBytes:&bts length:sizeof(bts)];
    
    LogRecord *record = [[LogRecord alloc]initWithData:data];
    
    while (curSize + [record getSize] <= maxSize && curRecordCount < maxRecordCount) {
        XCTAssertTrue([bucket addRecord:record]);
        curRecordCount++;
        curSize += sizeof(NSInteger);
    }
    
    XCTAssertFalse([bucket addRecord:record]);
}

- (void) addN:(NSInteger)n recordsToBucket:(MemBucket *)bucket {
    LogRecord *record = [self getLogRecord];
    while (n-- > 0) {
        [bucket addRecord:record];
    }
}

- (LogRecord *) getLogRecord {
    NSInteger bts = 123;
    NSData *data = [NSData dataWithBytes:&bts length:sizeof(bts)];
    
    LogRecord *record = [[LogRecord alloc]initWithData:data];
    return record;
}

@end
