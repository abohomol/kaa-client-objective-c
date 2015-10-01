//
//  SingleThreadExecutorContext.h
//  Kaa
//
//  Created by Aleksey Gutyro on 01.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractExecutorContext.h"
#import "ExecutorContext.h"

@interface SingleThreadExecutorContext : AbstractExecutorContext <ExecutorContext>

@end
