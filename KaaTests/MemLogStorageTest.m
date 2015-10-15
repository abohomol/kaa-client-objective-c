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

- (void) testEmptyLogRecord {
    NSInteger bucketSize = 8;
    NSInteger recordCount = 3;
    
    id <LogStorage> storage = [self getStorageWithBucketSize:bucketSize andRecordCount:recordCount];
    LogBlock *group = [storage getRecordBlock:10 batchCount:1];
    XCTAssertTrue(group == nil);
    [storage close];
}

- (void) testRecordCountAndConsumedBytes {
    NSInteger bucketSize = 8;
    NSInteger recordCount = 3;
    
    id <LogStorage> storage = [self getStorageWithBucketSize:bucketSize andRecordCount:recordCount];
    LogRecord *record = [self getLogRecord];
    
    //size of each record is 8B
    NSInteger insertionCount = 1;
    NSInteger iter = insertionCount;
    
    while (iter-- > 0) {
        [storage addLogRecord:record];
    }
    
    XCTAssertTrue([[storage getStatus] getRecordCount] == insertionCount);
    XCTAssertTrue([[storage getStatus] getConsumedVolume] == (insertionCount * [record getSize]));
    [storage close];
}

- (void) testUniqueIdGenerator {
    NSInteger bucketSize = 8;
    NSInteger recordCount = 3;
    
    id <LogStorage> storage = [self getStorageWithBucketSize:bucketSize andRecordCount:recordCount];
    LogRecord *record = [self getLogRecord];
    
    //size of each record is 8B
    NSInteger insertionCount = 3;
    NSInteger iter = insertionCount;
    
    while (iter-- > 0) {
        [storage addLogRecord:record];
    }
    
    LogBlock *group1 = [storage getRecordBlock:16 batchCount:2];
    LogBlock *group2 = [storage getRecordBlock:16 batchCount:2];
    XCTAssertNotEqual([group1 blockId], [group2 blockId]);
    [storage close];
}

- (void) testLogRecordAdding {
    //size of each record is 8B
    [self testAddHelper:1 :8 :1 :1];
    [self testAddHelper:4 :8 :2 :1];
    [self testAddHelper:3 :24 :4 :3];
    [self testAddHelper:5 :12 :2 :1];
}

- (void) testGetSameLogBlock {
    NSInteger bucketSize = 8;
    NSInteger recordCount = 3;
    
    id <LogStorage> storage = [self getStorageWithBucketSize:bucketSize andRecordCount:recordCount];
    LogRecord *record = [self getLogRecord];
    
    //size of each record is 8B
    NSInteger insertionCount = 1;
    NSInteger iter = insertionCount;
    
    while (iter-- > 0) {
        [storage addLogRecord:record];
    }
    
    LogBlock *group1 = [storage getRecordBlock:20 batchCount:2];
    [storage notifyUploadFailed:[group1 blockId]];
    LogBlock *group2 = [storage getRecordBlock:20 batchCount:2];
    
    XCTAssertTrue([[group1 logRecords] count] == [[group2 logRecords] count]);
    
    NSArray *group1Array = [NSArray arrayWithArray:[group1 logRecords]];
    NSArray *group2Array = [NSArray arrayWithArray:[group2 logRecords]];
    
    for (int i = 0; i < [group1Array count]; i++) {
        LogRecord *expected = group1Array[i];
        LogRecord *actual = group2Array[i];
        
        XCTAssertTrue([expected getSize] == [actual getSize]);
        XCTAssertEqualObjects([expected data], [actual data]);
    }
    [storage close];
}

- (void) testRecordRemoval {
    NSInteger bucketSize = 24;
    NSInteger recordCount = 3;
    
    id <LogStorage> storage = [self getStorageWithBucketSize:bucketSize andRecordCount:recordCount];
    LogRecord *record = [self getLogRecord];
    
    //size of each record is 8B
    NSInteger insertionCount = 3;
    NSInteger iter = insertionCount;
    
    while (iter-- > 0) {
        [storage addLogRecord:record];
    }
    
    LogBlock *removingBlock = [storage getRecordBlock:20 batchCount:2];
    
    insertionCount -= [[removingBlock logRecords] count];
    [storage removeRecordBlock:[removingBlock blockId]];
    removingBlock = [storage getRecordBlock:24 batchCount:3];
    insertionCount -= [[removingBlock logRecords] count];
    [storage removeRecordBlock:[removingBlock blockId]];
    
    LogBlock *leftBlock = [storage getRecordBlock:50 batchCount:50];
    XCTAssertTrue([[leftBlock logRecords] count] == insertionCount);
    [storage close];
}

- (void) testComplexRemoval {
    NSInteger bucketSize = 24;
    NSInteger recordCount = 3;
    
    id <LogStorage> storage = [self getStorageWithBucketSize:bucketSize andRecordCount:recordCount];
    LogRecord *record = [self getLogRecord];
    
    //size of each record is 8B
    NSInteger insertionCount = 3;
    NSInteger iter = insertionCount;
    
    while (iter-- > 0) {
        [storage addLogRecord:record];
    }
    
    LogBlock *removingBlock1 = [storage getRecordBlock:20 batchCount:2];
    insertionCount -= [[removingBlock1 logRecords] count];
    
    LogBlock *removingBlock2 = [storage getRecordBlock:24 batchCount:3];
    insertionCount -= [[removingBlock2 logRecords] count];
    
    LogBlock *removingBlock3 = [storage getRecordBlock:16 batchCount:2];
    insertionCount -= [[removingBlock3 logRecords] count];
    
    [storage removeRecordBlock:[removingBlock2 blockId]];
    [storage notifyUploadFailed:[removingBlock1 blockId]];
    insertionCount += [[removingBlock1 logRecords] count];
    
    LogBlock *leftBlock1 = [storage getRecordBlock:50 batchCount:50];
    LogBlock *leftBlock2 = [storage getRecordBlock:50 batchCount:50];
    NSInteger leftSize = [[leftBlock1 logRecords] count];
    if (leftBlock2 != nil)
        leftSize += [[leftBlock2 logRecords] count];
    XCTAssertEqual(leftSize, insertionCount);
    [storage close];
}

- (void) testLogStorageCountAndVolume {
    NSInteger bucketSize = 24;
    NSInteger recordCount = 3;
    
    id <LogStorage> storage = [self getStorageWithBucketSize:bucketSize andRecordCount:recordCount];
    LogRecord *record = [self getLogRecord];
    
    //size of each record is 8B
    NSInteger insertionCount = 3;
    NSInteger receivedCount = 0;
    NSInteger iter = insertionCount;
    
    while (iter-- > 0) {
        [storage addLogRecord:record];
    }
    
    LogBlock *logBlock = [storage getRecordBlock:16 batchCount:2];
    receivedCount = [self addIfNotEmpty:receivedCount :logBlock];
    XCTAssertEqual(insertionCount - receivedCount, [[storage getStatus] getRecordCount]);
    XCTAssertEqual((insertionCount - receivedCount) * 8, [[storage getStatus] getConsumedVolume]);
    
    logBlock = [storage getRecordBlock:20 batchCount:3];
    receivedCount = [self addIfNotEmpty:receivedCount :logBlock];
    XCTAssertEqual(insertionCount - receivedCount, [[storage getStatus] getRecordCount]);
    XCTAssertEqual((insertionCount - receivedCount) * 8, [[storage getStatus] getConsumedVolume]);
    
    logBlock = [storage getRecordBlock:20 batchCount:2];
    receivedCount = [self addIfNotEmpty:receivedCount :logBlock];
    XCTAssertEqual(insertionCount - receivedCount, [[storage getStatus] getRecordCount]);
    XCTAssertEqual((insertionCount - receivedCount) * 8, [[storage getStatus] getConsumedVolume]);
    
    //    [storage notifyUploadFailed:[logBlock blockId]];
    //    receivedCount -= [[logBlock logRecords] count];
    //    XCTAssertEqual(insertionCount - receivedCount, [[storage getStatus] getRecordCount]);
    //    XCTAssertEqual((insertionCount - receivedCount) * 8, [[storage getStatus] getConsumedVolume]);
    
}

- (void) testAddHelper:(NSInteger)addedN :(NSInteger)blockSize :(NSInteger)batchSize :(NSInteger)expectedN {
    id <LogStorage> storage = [self getStorageWithBucketSize:blockSize andRecordCount:batchSize];
    LogRecord *record = [self getLogRecord];
    NSMutableArray *expectedArray = [NSMutableArray array];
    
    while (addedN-- > 0) {
        [storage addLogRecord:record];
    }
    
    while (expectedN-- > 0) {
        [expectedArray addObject:record];
    }
    
    LogBlock *group = [storage getRecordBlock:blockSize batchCount:batchSize];
    NSArray *actualArray = [group logRecords];
    
    XCTAssertTrue([expectedArray count] == [actualArray count]);
    
    for (int i = 0; i < [expectedArray count]; i++) {
        LogRecord *expected = expectedArray[i];
        LogRecord *actual = actualArray[i];
        
        XCTAssertTrue([expected getSize] == [actual getSize]);
        XCTAssertEqualObjects([expected data], [actual data]);
    }
    [storage close];
}

- (NSInteger) addIfNotEmpty:(NSInteger)count :(LogBlock *)logBlock {
    if (logBlock && [[logBlock logRecords] count]) {
        count += [[logBlock logRecords] count];
    }
    return count;
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
