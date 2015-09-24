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

- (instancetype)initWithDefaults;

- (void)setTimeout:(NSInteger)timeout;

- (void)setRetryPeriod:(NSInteger)retryPeriod;

- (void)setVolumeThreshold:(NSInteger)volumeThreshold;

- (void)setCountThreshold:(NSInteger)countThreshold;

- (void)setBatchSize:(NSInteger)batchSize;

- (void)setBatchCount:(NSInteger)batchCount;

- (void)setUploadCheckPeriod:(NSInteger)uploadCheckPeriod;

@end
