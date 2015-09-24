//
//  ProfileManager.h
//  Kaa
//
//  Created by Anton Bohomol on 8/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_ProfileManager_h
#define Kaa_ProfileManager_h

#import <Foundation/Foundation.h>
#import "ProfileCommon.h"

/**
 * Interface for the profile manager.
 *
 * Responsible for the management of the user-defined profile container
 *
 * Profile manager is used to track any profile updates.
 * If no container is set, Kaa won't be able to process these updates.
 *
 * @see AbstractProfileContainer
 * @see SerializedProfileContainer
 */
@protocol ProfileManager

/**
 * Sets profile container implemented by the user.
 *
 * @param container User-defined container
 * @see AbstractProfileContainer
 */
- (void)setProfileContainer:(id<ProfileContainer>)container;

/**
 * Retrieves serialized profile
 *
 * @return serialized profile data
 */
- (NSData *)getSerializedProfile;

/**
 * Force sync of updated profile with server
 */
- (void)updateProfile;

@end

#endif
