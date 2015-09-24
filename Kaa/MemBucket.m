//
//  MemBucket.m
//  Kaa
//
//  Created by Anton Bohomol on 8/24/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "MemBucket.h"

#define TAG @"MemBucket >>>"

@interface MemBucket ()

@property (nonatomic) NSInteger maxSize;
@property (nonatomic) NSInteger maxRecordCount;
@property (nonatomic) NSInteger size;

@end

@implementation MemBucket

- (instancetype)initWithId:(NSInteger)bucketId maxSize:(NSInteger)maxSize maxRecordCount:(NSInteger)maxRecordCount {
    self = [super init];
    if (self) {
        _bucketId = bucketId;
        self.maxSize = maxSize;
        self.maxRecordCount = maxRecordCount;
        _records = [NSMutableArray array];
        self.state = MEM_BUCKET_STATE_FREE;
    }
    return self;
}

- (NSInteger)getSize {
    return self.size;
}

- (NSInteger)getCount {
    return [self.records count];
}

- (BOOL)addRecord:(LogRecord *)record {
    if (self.size + [record getSize] > self.maxSize) {
        DDLogVerbose(@"%@ No space left in bucket. Current size: %li, record size: %li, max size: %li", TAG,
                     (long)self.size, (long)[record getSize], (long)self.maxSize);
        return NO;
    } else if ([self getCount] + 1 > self.maxRecordCount) {
        DDLogVerbose(@"%@ No space left in bucket. Current count: %li, max count: %li", TAG,
                     (long)[self getCount], (long)self.maxRecordCount);
        return NO;
    }
    [self.records addObject:record];
    self.size += [record getSize];
    return YES;
}

- (NSArray *)shrinkToSize:(NSInteger)newSize newCount:(NSInteger)newCount {
    DDLogVerbose(@"%@ Shrinking %@ bucket to the new size: %li and count %li", TAG,
                 self, (long)newSize, (long)newCount);
    if (newSize < 0 || newCount < 0) {
        [NSException raise:NSInvalidArgumentException format:@"New size and count values must be non-negative"];
    }
    if (newSize >= self.size && newCount >= [self getCount]) {
        return [NSArray array];
    }
    NSMutableArray *overSize = [NSMutableArray array];
    NSInteger lastIndex = [self.records count] - 1;
    while ((self.size > newSize || [self getCount] > newCount) && lastIndex > 0) {
        LogRecord *currentRecord = [self.records objectAtIndex:lastIndex];
        lastIndex--;
        [overSize addObject:currentRecord];
        self.size -= [currentRecord getSize];
    }
    DDLogVerbose(@"%@ Shrink over-sized elements: %li. New bucket size: %li and count %li", TAG,
                 (long)[overSize count], (long)self.size, (long)[self getCount]);
    return overSize;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MemBucket id:%li maxSize:%li maxRecordCount:%li records count:%li size:%li state:%i", (long)self.bucketId, (long)self.maxSize, (long)self.maxRecordCount,
            (long)[self.records count], (long)self.size, self.state];
}

@end
