//
//  EventListenersRequestBinding.h
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDelegates.h"
#import "EndpointGen.h"

@interface EventListenersRequestBinding : NSObject

@property (nonatomic,readonly,strong) EventListenersRequest *request;
@property (nonatomic,readonly,weak) id<FindEventListenersDelegate> delegate;
@property (nonatomic) BOOL isSent;

- (instancetype)initWithRequest:(EventListenersRequest *)request delegate:(id<FindEventListenersDelegate>)delegate;

@end
