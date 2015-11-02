//
//  RecordCountWithTimeLimitLogUploadStrategy.h
//  Kaa
//
//  Created by Aleksey Gutyro on 28.09.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DefaultLogUploadStrategy.h"
#import "TimeCommons.h"

@interface RecordCountWithTimeLimitLogUploadStrategy : DefaultLogUploadStrategy

@property (nonatomic) int64_t lastUploadTime;

- (instancetype)initWithCountThreshold:(int32_t)countThreshold TimeLimit:(int64_t)timeLimit andTimeUnit:(TimeUnit)timeUnit;

@end
