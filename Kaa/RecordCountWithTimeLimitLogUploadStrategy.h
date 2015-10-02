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

@property (nonatomic) long lastUploadTime;

- (instancetype) initWithCountThreshold:(NSInteger)countThreshold TimeLimit:(long)timeLimit andTimeUnit:(TimeUnit)timeUnit;

@end
