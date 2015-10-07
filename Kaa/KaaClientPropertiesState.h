//
//  KaaClientPropertiesState.h
//  Kaa
//
//  Created by Anton Bohomol on 9/6/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaaClientState.h"
#import "KAABase64.h"
#import "KaaClientProperties.h"

#define STATE_FILE_LOCATION @"state_file_location"
#define STATE_FILE_DEFAULT  @"state_properties"

@interface KaaClientPropertiesState : NSObject <KaaClientState>

- (instancetype)initWith:(id<KAABase64>)base64 andClientProperties:(KaaClientProperties *)properties;

@end
