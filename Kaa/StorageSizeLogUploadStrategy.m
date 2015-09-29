//
//  StorageSizeLogUploadStrategy.m
//  Kaa
//
//  Created by Aleksey Gutyro on 28.09.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.



#import "StorageSizeLogUploadStrategy.h"
#import "KaaLogging.h"

#define TAG @"StorageSizeLogUploadStrategy >>>"

// Start log upload when there storage size is >= volumeThreshold bytes.

@implementation StorageSizeLogUploadStrategy

- (instancetype)initWithVolumeThreshold:(NSInteger)volumeThreshold {
    self = [super init];
    if (self) {
        [self setVolumeThreshold:volumeThreshold];
    }
    return self;
}

- (LogUploadStrategyDecision)checkUploadNeeded:(id<LogStorageStatus>)status {
    LogUploadStrategyDecision decision = LOG_UPLOAD_STRATEGY_DECISION_NOOP;
    long currentConsumedVolume = [status getConsumedVolume];
    
    if (currentConsumedVolume == self.countThreshold) {
        DDLogInfo(@"%@ Need to upload logs - current size: %li, threshold: %li",
                  TAG, currentConsumedVolume, (long)self.countThreshold);
        decision = LOG_UPLOAD_STRATEGY_DECISION_UPLOAD;
    }
    return decision;
}

@end
