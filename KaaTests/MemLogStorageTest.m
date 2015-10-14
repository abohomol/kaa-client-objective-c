//
//  MemLogStorageTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 14.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LogStorage.h"
#import "MemLogStorage.h"

@interface MemLogStorageTest : XCTestCase

@end

@implementation MemLogStorageTest

- (void) testRemovalWithBucketShrinking {
    id <LogStorage> storage = [self getStorageWithBucketSize:30 andRecordCount:4];
    LogRecord *record = [self getLogRecord];
    
    NSInteger insertionCount = 4;
    NSInteger iter = insertionCount;
    
    while (iter-- > 0) {
        [storage addLogRecord:record];
    }
    
    NSInteger maxSize = 16;
    NSInteger maxCount = 3;
    LogBlock *logBlock = [storage getRecordBlock:16 batchCount:3];
    XCTAssertTrue([[logBlock logRecords] count] <= maxCount);
    XCTAssertTrue([self getLogBlockSize:logBlock] <= maxSize);
    XCTAssertEqual(insertionCount - [[logBlock logRecords] count], [[storage getStatus] getRecordCount]);
    
    
}

- (MemLogStorage *) getStorageWithBucketSize:(NSInteger)bucketSize andRecordCount:(NSInteger)recordCount {
    return [[MemLogStorage alloc]initWithBucketSize:bucketSize bucketRecordCount:recordCount];
}

- (NSInteger) getLogBlockSize:(LogBlock *)logBlock {
    NSInteger size = 0;
    for (LogRecord *record in [logBlock logRecords]) {
        size += [record getSize];
    }
    return size;
}

- (LogRecord *) getLogRecord {
    NSInteger bts = 123;
    NSData *data = [NSData dataWithBytes:&bts length:sizeof(bts)];
    
    LogRecord *record = [[LogRecord alloc]initWithData:data];
    return record;
}

@end
