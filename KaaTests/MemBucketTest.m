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

- (void)testAddLogRecord {
    [self addLogRecordTestHelper:10 :2];
    [self addLogRecordTestHelper:14 :10];
    [self addLogRecordTestHelper:2 :10];
    [self addLogRecordTestHelper:10 :1];
}

- (void)testShrinkToSizeRecord {
    MemBucket *bucket = [[MemBucket alloc] initWithId:1 maxSize:100 maxRecordCount:100];
    [self addN:10 recordsToBucket:bucket];
    NSArray *overSizedRecords = [bucket shrinkToSize:10 newCount:4];
    XCTAssertEqual(3, bucket.getCount);
    XCTAssertEqual(9, bucket.getSize);
    XCTAssertEqual(7, [overSizedRecords count]);
    
    bucket = [[MemBucket alloc] initWithId:1 maxSize:100 maxRecordCount:100];
    [self addN:10 recordsToBucket:bucket];
    overSizedRecords = [bucket shrinkToSize:10 newCount:2];
    XCTAssertEqual(2, bucket.getCount);
    XCTAssertEqual(6, bucket.getSize);
    XCTAssertEqual(8, [overSizedRecords count]);
    
    overSizedRecords = [bucket shrinkToSize:400 newCount:400];
    XCTAssertEqual(0, [overSizedRecords count]);
}

- (void)addLogRecordTestHelper:(int32_t)maxSize :(int32_t)maxRecordCount {
    MemBucket *bucket = [[MemBucket alloc] initWithId:1 maxSize:maxSize maxRecordCount:maxRecordCount];
    
    int32_t curSize = 0;
    int32_t curRecordCount = 0;
    
    LogRecord *record = [self getLogRecord];
    
    while ((curSize + [record getSize] <= maxSize) && (curRecordCount < maxRecordCount)) {
        XCTAssertTrue([bucket addRecord:record]);
        curRecordCount++;
        curSize += 3;
    }
    
    XCTAssertFalse([bucket addRecord:record]);
}

- (void)addN:(NSInteger)n recordsToBucket:(MemBucket *)bucket {
    while (n-- > 0) {
        [bucket addRecord:[self getLogRecord]];
    }
}

- (LogRecord *)getLogRecord {
    char _1byte = 0;
    int DATA_SIZE = 3;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:DATA_SIZE];
    for (int i = 0; i < DATA_SIZE; i++) {
        [data appendBytes:&_1byte length:sizeof(char)];
    }
    
    LogRecord *record = [[LogRecord alloc]initWithData:data];
    return record;
}

@end
