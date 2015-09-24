//
//  DefaultBootstrapChannel.h
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AbstractHttpChannel.h"

@interface DefaultBootstrapChannel : AbstractHttpChannel

- (instancetype)initWithClient:(AbstractKaaClient *)client
                         state:(id<KaaClientState>)state
               failoverManager:(id<FailoverManager>)manager;

@end
