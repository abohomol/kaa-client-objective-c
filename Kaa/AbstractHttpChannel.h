//
//  AbstractHttpChannel.h
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaaDataChannel.h"
#import "AbstractKaaClient.h"
#import "KaaClientState.h"
#import "AbstractHttpClient.h"

@interface AbstractHttpChannel : NSObject <KaaDataChannel>

- (instancetype)initWithClient:(AbstractKaaClient *)client state:(id<KaaClientState>)state
               failoverManager:(id<FailoverManager>)manager;

- (NSOperationQueue *)createExecutor;

- (NSString *)getURLSuffix;

- (void)connectionStateChanged:(BOOL)failed;

- (void)connectionStateChanged:(BOOL)failed withStatus:(int)status;

- (id<KaaDataMultiplexer>)getMultiplexer;

- (id<KaaDataDemultiplexer>)getDemultiplexer;

- (AbstractHttpClient *)getHttpClient;

- (NSOperation *)createChannelRunner:(NSDictionary *)types;

@end
