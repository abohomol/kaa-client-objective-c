//
//  DefaultProfileManager.h
//  Kaa
//
//  Created by Anton Bohomol on 8/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileManager.h"
#import "ProfileTransport.h"

/**
 * Default ProfileManager implementation.
 */
@interface DefaultProfileManager : NSObject <ProfileManager>

- (instancetype)initWith:(id<ProfileTransport>)transport;

@end
