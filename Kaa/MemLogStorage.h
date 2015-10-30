//
//  MemLogStorage.h
//  Kaa
//
//  Created by Anton Bohomol on 8/24/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogStorage.h"

@interface MemLogStorage : NSObject <LogStorage,LogStorageStatus>

- (instancetype)initWithDefaults;
- (instancetype)initWithBucketSize:(int64_t)maxBucketSize bucketRecordCount:(int32_t)maxBucketRecordCount;
- (instancetype)initWithMaxStorageSize:(int64_t)maxStorageSize bucketSize:(int64_t)bucketSize bucketRecordCount:(int32_t)bucketRecordCount;

@end
