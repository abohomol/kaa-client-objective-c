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
- (instancetype)initWithBucketSize:(NSInteger)maxBucketSize bucketRecordCount:(NSInteger)maxBucketRecordCount;
- (instancetype)initWithMaxStorageSize:(NSInteger)maxStorageSize bucketSize:(NSInteger)bucketSize bucketRecordCount:(NSInteger)bucketRecordCount;

@end
