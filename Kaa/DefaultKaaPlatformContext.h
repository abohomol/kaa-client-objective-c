//
//  DefaultKaaPlatformContext.h
//  Kaa
//
//  Created by Anton Bohomol on 10/30/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaaClientPlatformContext.h"

@interface DefaultKaaPlatformContext : NSObject <KaaClientPlatformContext>

- (instancetype)initWith:(KaaClientProperties *)properties andExecutor:(id<ExecutorContext>)executor;

@end
