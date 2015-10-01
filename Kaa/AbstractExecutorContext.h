//
//  AbstractExecutorContext.h
//  Kaa
//
//  Created by Aleksey Gutyro on 30.09.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExecutorContext.h"
#import "TimeCommons.h"

@interface AbstractExecutorContext : NSObject <ExecutorContext>

@property (nonatomic) NSInteger timeOut;
@property (nonatomic) TimeUnit timeUnit;

- (instancetype) initWithTimeOut:(NSInteger)timeOut andTimeUnit:(TimeUnit)timeUnit;
- (void) shutDownExecutor:(NSOperationQueue*)queue;

@end
