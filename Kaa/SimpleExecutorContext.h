//
//  SimpleExecutorContext.h
//  Kaa
//
//  Created by Aleksey Gutyro on 01.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractExecutorContext.h"
#import "TransportContext.h"

@interface SimpleExecutorContext : AbstractExecutorContext <ExecutorContext>

- (instancetype)initWithlifeCycleThreadCount:(NSInteger)lifeCycleThreadCount andApiThreadCount:(NSInteger)apiThreadCount andCallbackThreadCount:(NSInteger)callbackThreadCount andScheduledThreadCount:(NSInteger)scheduledThreadCount;

@end
