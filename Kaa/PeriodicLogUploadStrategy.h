//
//  PeriodicLogUploadStrategy.h
//  Kaa
//
//  Created by Aleksey Gutyro on 28.09.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DefaultLogUploadStrategy.h"
#import "TimeCommons.h"

@interface PeriodicLogUploadStrategy : DefaultLogUploadStrategy

@property (assign, nonatomic) long lastUploadTime;

- (instancetype) initWithTimeLimit:(long)timeLimit andTimeunit:(TimeUnit) timeUnit;

@end
