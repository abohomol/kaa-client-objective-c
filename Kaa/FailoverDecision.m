//
//  FailoverDecision.m
//  Kaa
//
//  Created by Anton Bohomol on 7/15/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "FailoverDecision.h"

@implementation FailoverDecision

- (instancetype)initWithFailoverAction:(FailoverAction)failoverAction {
    self = [super init];
    if (self) {
        _failoverAction = failoverAction;
    }
    return self;
}

- (instancetype)initWithFailoverAction:(FailoverAction)failoverAction retryPeriodInMilliseconds:(NSInteger)retryPeriod {
    self = [super init];
    if (self) {
        _failoverAction = failoverAction;
        _retryPeriod = retryPeriod;
    }
    return self;
}

@end
