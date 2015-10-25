//
//  DefaultOperationTcpChannel.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaaDataChannel.h"
#import "KaaClientState.h"
#import "FailoverManager.h"

@interface DefaultOperationTcpChannel : NSObject <KaaDataChannel>

- (instancetype)initWithClientState:(id<KaaClientState>)state andFailoverMgr:(id<FailoverManager>)failoverMgr;
- (NSOperationQueue *)createExecutor;

@end
