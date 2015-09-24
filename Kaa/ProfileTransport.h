//
//  ProfileTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 8/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_ProfileTransport_h
#define Kaa_ProfileTransport_h

#import <Foundation/Foundation.h>
#import "KaaTransport.h"
#import "EndpointGen.h"
#import "ProfileManager.h"
#import "KaaClientProperties.h"

/**
 * KaaTransport for the Profile service.
 * Updates the Profile manager state.
 */
@protocol ProfileTransport <KaaTransport>

/**
 * Creates a new Profile update request.
 *
 * @return new Profile update request.
 * @see ProfileSyncRequest
 */
- (ProfileSyncRequest *)createProfileRequest;

/**
 * Updates the state of the Profile manager from the given response.
 *
 * @param response the response from the server.
 * @see ProfileSyncResponse
 */
- (void)onProfileResponse:(ProfileSyncResponse *)response;

/**
 * Sets the given Profile manager.
 *
 * @param manager the Profile manager to be set.
 * @see ProfileManager
 */
- (void)setProfileManager:(id<ProfileManager>)manager;

/**
 * Sets the given client's properties.
 *
 * @param properties the client's properties to be set.
 * @see KaaClientProperties
 */
- (void)setClientProperties:(KaaClientProperties *)clientProperties;

@end

#endif
