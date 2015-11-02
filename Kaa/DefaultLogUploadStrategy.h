//
//  DefaultLogUploadStrategy.h
//  Kaa
//
//  Created by Anton Bohomol on 8/24/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogUploadStrategy.h"

@interface DefaultLogUploadStrategy : NSObject <LogUploadStrategy>

@property (nonatomic) int32_t timeout;
@property (nonatomic) int32_t uploadCheckPeriod;
@property (nonatomic) int32_t retryPeriod;
@property (nonatomic) int32_t volumeThreshold;
@property (nonatomic) int32_t countThreshold;
@property (nonatomic) int64_t batchSize;
@property (nonatomic) int32_t batchCount;
@property (nonatomic) BOOL    isUploadLocked;
@property (nonatomic) int64_t timeLimit;

- (instancetype)initWithDefaults;

@end
