//
//  FailoverDecision.h
//  Kaa
//
//  Created by Anton Bohomol on 7/15/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Enum which describes status of the current failover state.
 * Managed by a failover strategy.
 */
typedef enum {
    FAILOVER_STATUS_BOOTSTRAP_SERVERS_NA,
    FAILOVER_STATUS_CURRENT_BOOTSTRAP_SERVER_NA,
    FAILOVER_STATUS_OPERATION_SERVERS_NA,
    FAILOVER_STATUS_NO_OPERATION_SERVERS_RECEIVED,
    FAILOVER_STATUS_NO_CONNECTIVITY
} FailoverStatus;

/**
 * Enum which represents an action corresponding to a failover scenario.
 */
typedef enum  {
    FAILOVER_ACTION_NOOP,               // doing nothing
    FAILOVER_ACTION_RETRY,
    FAILOVER_ACTION_USE_NEXT_BOOTSTRAP,
    FAILOVER_ACTION_USE_NEXT_OPERATIONS,
    FAILOVER_ACTION_STOP_APP
} FailoverAction;

/**
 * Class that describes a decision which is made by a failover manager, 
 * which corresponds to a failover strategy.
 */
@interface FailoverDecision : NSObject

@property(nonatomic,readonly) FailoverAction failoverAction;
@property(nonatomic,readonly) int64_t retryPeriod;

- (instancetype)initWithFailoverAction:(FailoverAction)failoverAction;
- (instancetype)initWithFailoverAction:(FailoverAction)failoverAction retryPeriodInMilliseconds:(int64_t)retryPeriod;

@end