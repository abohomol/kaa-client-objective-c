//
//  DefaultFailoverManager.h
//  Kaa
//
//  Created by Anton Bohomol on 9/22/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FailoverManager.h"
#import "KaaChannelManager.h"
#import "ExecutorContext.h"
#import "TimeCommons.h"

@interface DefaultFailoverManager : NSObject <FailoverManager>

- (instancetype)initWithChannelManager:(id<KaaChannelManager>)channelMgr context:(id<ExecutorContext>)context;

- (instancetype)initWithChannelManager:(id<KaaChannelManager>)channelMgr
                               context:(id<ExecutorContext>)context
              failureResolutionTimeout:(NSInteger)frTimeout
           bootstrapServersRetryPeriod:(NSInteger)btRetryPeriod
          operationsServersRetryPeriod:(NSInteger)opRetryPeriod
             noConnectivityRetryPeriod:(NSInteger)noConnRetryPeriod
                              timeUnit:(TimeUnit)timeUnit;

@end
