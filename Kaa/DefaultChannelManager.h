//
//  DefaultChannelManager.h
//  Kaa
//
//  Created by Anton Bohomol on 9/11/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaaInternalChannelManager.h"
#import "BootstrapManager.h"
#import "ExecutorContext.h"

@interface DefaultChannelManager : NSObject <KaaInternalChannelManager>

- (instancetype)initWith:(id<BootstrapManager>)bootstrapMgr
        bootstrapServers:(NSDictionary *)servers
                 context:(id<ExecutorContext>)context;

@end

@interface SyncWorker : NSThread

@property (nonatomic,strong) id<KaaDataChannel> channel;
@property (nonatomic,weak) DefaultChannelManager *manager;
@property (nonatomic) volatile BOOL isStopped;

- (instancetype)initWith:(id<KaaDataChannel>)channel andManager:(DefaultChannelManager *)manager;

@end
