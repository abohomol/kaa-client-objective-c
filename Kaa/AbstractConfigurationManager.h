//
//  AbstractConfigurationManager.h
//  Kaa
//
//  Created by Anton Bohomol on 8/20/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigurationCommon.h"
#import "KaaClientProperties.h"
#import "ConfigurationDeserializer.h"
#import "KaaClientState.h"
#import "ExecutorContext.h"

@interface AbstractConfigurationManager : NSObject <ConfigurationManager>

@property(nonatomic,strong,readonly) ConfigurationDeserializer *deserializer;

- (instancetype)initWithClientProperties:(KaaClientProperties *)properties state:(id<KaaClientState>)state andExecutorContext:(id<ExecutorContext>)context;

- (NSData *)getConfigurationData;

- (NSData *)getDefaultConfiguratioData;

@end
