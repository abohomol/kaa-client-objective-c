//
//  DefaultBootstrapManager.h
//  Kaa
//
//  Created by Anton Bohomol on 8/30/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BootstrapManager.h"
#import "ExecutorContext.h"

/**
 * Default BootstrapManager implementation
 */
@interface DefaultBootstrapManager : NSObject <BootstrapManager>

- (instancetype)initWith:(id<BootstrapTransport>)transport executorContext:(id<ExecutorContext>)context;

@end
