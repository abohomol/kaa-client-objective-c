//
//  EventListenersRequestBinding.m
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "EventListenersRequestBinding.h"

@implementation EventListenersRequestBinding

- (instancetype)initWithRequest:(EventListenersRequest *)request delegate:(id<FindEventListenersDelegate>)delegate {
    self = [super init];
    if (self) {
        _request = request;
        _delegate = delegate;
        self.isSent = NO;
    }
    return self;
}

@end
