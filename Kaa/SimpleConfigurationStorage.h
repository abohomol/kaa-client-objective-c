//
//  SimpleConfigurationStorage.h
//  Kaa
//
//  Created by Anton Bohomol on 9/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigurationStorage.h"
#import "KaaClientPlatformContext.h"

@interface SimpleConfigurationStorage : NSObject <ConfigurationStorage>

- (instancetype)initWithPlatformContext:(id<KaaClientPlatformContext>)context andPath:(NSString *)path;

@end
