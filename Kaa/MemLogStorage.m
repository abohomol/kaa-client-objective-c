//
//  MemLogStorage.m
//  Kaa
//
//  Created by Anton Bohomol on 8/24/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "MemLogStorage.h"
#import "MemBucket.h"

#define TAG @"MemLogStorage >>>"

#define DEFAULT_MAX_STORAGE_SIZE        (16 * 1024 * 1024);
#define DEFAULT_MAX_BUCKET_SIZE         (16 * 1024);
#define DEFAULT_MAX_BUCKET_RECORD_COUNT (256);

@interface MemLogStorage ()

@property (nonatomic) NSInteger maxStorageSize;
@property (nonatomic) NSInteger maxBucketSize;
@property (nonatomic) NSInteger maxBucketRecordCount;
@property (nonatomic,strong) NSMutableDictionary *buckets;
@property (atomic) NSInteger bucketIdSeq;
@property (atomic) volatile NSInteger consumedVolume;
@property (atomic) volatile NSInteger recordCount;

@property (nonatomic,strong) MemBucket *currentBucket;

@property (atomic,strong) NSLock *bucketsLock;

@end

@implementation MemLogStorage

- (instancetype)initWithDefaults {
    self = [super init];
    if (self) {
        self.maxStorageSize = DEFAULT_MAX_STORAGE_SIZE;
        self.maxBucketSize = DEFAULT_MAX_BUCKET_SIZE;
        self.maxBucketRecordCount = DEFAULT_MAX_BUCKET_RECORD_COUNT;
        self.bucketIdSeq = 0;
        self.buckets = [NSMutableDictionary dictionary];
        self.bucketsLock = [[NSLock alloc] init];
    }
    return self;
}

- (instancetype)initWithBucketSize:(NSInteger)maxBucketSize bucketRecordCount:(NSInteger)maxBucketRecordCount {
    self = [super init];
    if (self) {
        self.maxStorageSize = DEFAULT_MAX_STORAGE_SIZE;
        self.maxBucketSize = maxBucketSize;
        self.maxBucketRecordCount = maxBucketRecordCount;
        self.bucketIdSeq = 0;
        self.buckets = [NSMutableDictionary dictionary];
        self.bucketsLock = [[NSLock alloc] init];
    }
    return self;
}

- (instancetype)initWithMaxStorageSize:(NSInteger)maxStorageSize bucketSize:(NSInteger)bucketSize bucketRecordCount:(NSInteger)bucketRecordCount {
    self = [super init];
    if (self) {
        self.maxStorageSize = maxStorageSize;
        self.maxBucketSize = bucketSize;
        self.maxBucketRecordCount = bucketRecordCount;
        self.bucketIdSeq = 0;
        self.buckets = [NSMutableDictionary dictionary];
        self.bucketsLock = [[NSLock alloc] init];
    }
    return self;
}

- (NSInteger)getConsumedVolume {
    DDLogDebug(@"%@ Consumed volume: %li", TAG, (long)self.consumedVolume);
    return self.consumedVolume;
}

- (NSInteger)getRecordCount {
    DDLogDebug(@"%@ Record count: %li", TAG, (long)self.recordCount);
    return self.recordCount;
}

- (void)addLogRecord:(LogRecord *)record {
    DDLogVerbose(@"%@ Adding new log record with size %li", TAG, (long)[record getSize]);
    if ([record getSize] > self.maxBucketSize) {
        [NSException raise:NSInvalidArgumentException format:@"Record size(%li) is bigger than max bucket size(%li)!",
         (long)[record getSize], (long)self.maxBucketSize];
    }
    [self.bucketsLock lock];
    if (self.consumedVolume + [record getSize] > self.maxStorageSize) {
        [NSException raise:@"IllegalStateException" format:@"Storage is full!"];
    }
    if (!self.currentBucket || self.currentBucket.state != MEM_BUCKET_STATE_FREE) {
        self.currentBucket = [[MemBucket alloc] initWithId:self.bucketIdSeq++ maxSize:self.maxBucketSize maxRecordCount:self.maxBucketRecordCount];
        [self.buckets setObject:self.currentBucket forKey:[NSNumber numberWithLong:self.currentBucket.bucketId]];
    }
    if (![self.currentBucket addRecord:record]) {
        DDLogVerbose(@"%@ Current bucket is full. Creating new one.", TAG);
        self.currentBucket.state = MEM_BUCKET_STATE_FULL;
        self.currentBucket = [[MemBucket alloc] initWithId:self.bucketIdSeq++ maxSize:self.maxBucketSize maxRecordCount:self.maxBucketRecordCount];
        [self.buckets setObject:self.currentBucket forKey:[NSNumber numberWithLong:self.currentBucket.bucketId]];
        [self.currentBucket addRecord:record];
    }
    self.recordCount++;
    self.consumedVolume += [record getSize];
    [self.bucketsLock unlock];
    
    DDLogVerbose(@"%@ Added a new log record to bucket with id [%li]", TAG, (long)[self.currentBucket bucketId]);
}

- (LogBlock *)getRecordBlock:(NSInteger)blockSize batchCount:(NSInteger)batchCount {
    DDLogVerbose(@"%@ Getting new record block with block size: %li and count: %li", TAG, (long)blockSize, (long)batchCount);
    if (blockSize > self.maxBucketSize || batchCount > self.maxBucketRecordCount) {
        //TODO add support of block resize
        DDLogWarn(@"%@ Resize of record block is not supported yet", TAG);
    }
    LogBlock *result = nil;
    MemBucket *bucketCandidate = nil;
    [self.bucketsLock lock];
    for (MemBucket *bucket in self.buckets.allValues) {
        if (bucket.state == MEM_BUCKET_STATE_FREE) {
            bucketCandidate = bucket;
        }
        if (bucket.state == MEM_BUCKET_STATE_FULL) {
            bucket.state = MEM_BUCKET_STATE_PENDING;
            bucketCandidate = bucket;
            break;
        }
    }
    if (bucketCandidate) {
        self.consumedVolume -= [bucketCandidate getSize];
        self.recordCount -= [bucketCandidate getCount];
        if (bucketCandidate.state == MEM_BUCKET_STATE_FREE) {
            DDLogVerbose(@"%@ Only a bucket with state FREE found: [%li]. Changing its state to PENDING",
                         TAG, (long)bucketCandidate.bucketId);
            bucketCandidate.state = MEM_BUCKET_STATE_PENDING;
        }
        if ([bucketCandidate getSize] <= blockSize && [bucketCandidate getCount] <= batchCount) {
            result = [[LogBlock alloc] initWithBlockId:bucketCandidate.bucketId andRecords:bucketCandidate.records];
            DDLogDebug(@"%@ Return record block with records count: [%li]", TAG, (long)[bucketCandidate getCount]);
        } else {
            DDLogDebug(@"%@ Shrinking bucket %@ to new size: [%li] and count: [%li]", TAG, bucketCandidate, (long)blockSize, (long)batchCount);
            NSArray *overSized = [bucketCandidate shrinkToSize:blockSize newCount:batchCount];
            result = [[LogBlock alloc] initWithBlockId:bucketCandidate.bucketId andRecords:bucketCandidate.records];
            for (LogRecord *logRecord in overSized) {
                [self addLogRecord:logRecord];
            }
        }
    }
    [self.bucketsLock unlock];
    return result;
}

- (void)removeRecordBlock:(NSInteger)blockId {
    DDLogVerbose(@"%@ Removing record block with id [%li]", TAG, (long)blockId);
    [self.bucketsLock lock];
    [self.buckets removeObjectForKey:[NSNumber numberWithLong:blockId]];
    [self.bucketsLock unlock];
}

- (void)notifyUploadFailed:(NSInteger)blockId {
    DDLogVerbose(@"%@ Upload of record block [%li] failed", TAG, (long)blockId);
    [self.bucketsLock lock];
    MemBucket * bucket = [self.buckets objectForKey:[NSNumber numberWithLong:blockId]];
    bucket.state = MEM_BUCKET_STATE_FULL;
    self.consumedVolume += [bucket getSize];
    self.recordCount += [bucket getCount];
    [self.bucketsLock unlock];
}

- (void)close {
    DDLogDebug(@"%@ Closing log storage", TAG);
    //TODO: forgot to clean up anything?
}

- (id<LogStorageStatus>)getStatus {
    return self;
}

@end
