//
//  DefaultProfileManagerTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 16.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DefaultProfileManager.h"
#import "ProfileTransport.h"
#import "KAADummyProfile.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

@interface TestProfileContainer : NSObject <ProfileContainer>

@end

@implementation TestProfileContainer

- (KAADummyProfile *)getProfile {
    return [[KAADummyProfile alloc] init];
}

@end

@interface DefaultProfileManagerTest : XCTestCase

@end

@implementation DefaultProfileManagerTest

- (void) testProfileManager {
    
    id <ProfileTransport> transport = mockProtocol(@protocol(ProfileTransport));
    TestProfileContainer *container = [[TestProfileContainer alloc] init];
    
    DefaultProfileManager *profileManager =  [[DefaultProfileManager alloc] initWith:transport];
    [profileManager setProfileContainer:container];
    
    XCTAssertNotNil([profileManager getSerializedProfile]);
    
    [profileManager updateProfile];
    [verify(transport) sync];
}

@end
