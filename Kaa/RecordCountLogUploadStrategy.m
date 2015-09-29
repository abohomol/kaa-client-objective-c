//
//  RecordCountLogUploadStrategy.m
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


#import "RecordCountLogUploadStrategy.h"
#import "KaaLogging.h"

#define TAG @"PeriodicLogUploadStrategy >>>"

//Start log upload when there is countThreshold records in storage.

@implementation RecordCountLogUploadStrategy

- (instancetype) initWithCountThreshold:(NSInteger)countThreshold {
    
    self = [super init];
    if (self) {
        [self setCountThreshold:countThreshold];
    }
    return self;
}

- (LogUploadStrategyDecision)checkUploadNeeded:(id<LogStorageStatus>)status {
    LogUploadStrategyDecision decision = LOG_UPLOAD_STRATEGY_DECISION_NOOP;
    long currentRecordCount = [status getRecordCount];
    
    if (currentRecordCount == self.countThreshold) {
        DDLogInfo(@"%@ Need to upload logs - current count: %li, threshold: %li",
                  TAG, currentRecordCount, (long)self.countThreshold);
        decision = LOG_UPLOAD_STRATEGY_DECISION_UPLOAD;
    }
    return decision;
}

@end