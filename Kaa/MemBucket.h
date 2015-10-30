//
//  MemBucket.h
//  Kaa
//
//  Created by Anton Bohomol on 8/24/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogRecord.h"

typedef enum {
    MEM_BUCKET_STATE_FREE,
    MEM_BUCKET_STATE_FULL,
    MEM_BUCKET_STATE_PENDING
} MemBucketState;

@interface MemBucket : NSObject

@property (nonatomic,readonly) int32_t bucketId;
@property (nonatomic,strong,readonly) NSMutableArray *records;
@property (nonatomic) MemBucketState state;

- (instancetype)initWithId:(int32_t)bucketId maxSize:(int64_t)maxSize maxRecordCount:(int32_t)maxRecordCount;

- (int64_t)getSize;

- (int32_t)getCount;

- (BOOL)addRecord:(LogRecord *)record;

/**
 * Shrinks current bucket to the newSize
 * @param newSize expected max size of a bucket inclusively
 * @return records removed from the bucket
 */
- (NSArray *)shrinkToSize:(int64_t)newSize newCount:(int32_t)newCount;

@end
