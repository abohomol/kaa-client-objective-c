//
//  AbstractLogCollector.h
//  Kaa
//
//  Created by Anton Bohomol on 8/24/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogTransport.h"
#import "ExecutorContext.h"
#import "LogStorage.h"
#import "KaaChannelManager.h"
#import "LogCollector.h"

//Framework limitation
#define MAX_BATCH_VOLUME (512 * 1024)

@interface AbstractLogCollector : NSObject <LogProcessor,LogCollector>

@property (nonatomic,strong,readonly) id<ExecutorContext> executorContext;
@property (nonatomic,strong,readonly) id<LogStorage> storage;

- (instancetype)initWith:(id<LogTransport>)transport
         executorContext:(id<ExecutorContext>)executorContext
          channelManager:(id<KaaChannelManager>)channelManager
         failoverManager:(id<FailoverManager>)failoverManager;

- (void)scheduleUploadCheck;

- (void)uploadIfNeeded;

@end
