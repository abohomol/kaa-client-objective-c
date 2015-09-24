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

@interface AbstractConfigurationManager : NSObject <ConfigurationManager>

@property(nonatomic,strong,readonly) ConfigurationDeserializer *deserializer;

- (instancetype)initWithClientProperties:(KaaClientProperties *)properties;

- (NSData *)getConfigurationData;

- (NSData *)getDefaultConfiguratioData;

@end
