//
//  DefaultBootstrapDataProcessor.h
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaaDataMultiplexer.h"
#import "KaaDataDemultiplexer.h"
#import "BootstrapTransport.h"

@interface DefaultBootstrapDataProcessor : NSObject <KaaDataMultiplexer, KaaDataDemultiplexer>

- (void)setBootstrapTransport:(id<BootstrapTransport>)transport;

@end
