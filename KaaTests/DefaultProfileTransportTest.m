//
//  DefaultOperationsChannelTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 22.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "DefaultProfileTransport.h"
#import "KeyUtils.h"
#import "DefaultProfileManager.h"

#pragma mark ConcreteProfileContainer

@interface ConcreteProfileContainer : NSObject <ProfileContainer>

@end

@implementation ConcreteProfileContainer

- (KAAProfile *)getProfile {
    return [[KAAProfile alloc] init];
}

@end

#pragma mark - DefaultProfileTransportTest

@interface DefaultProfileTransportTest : XCTestCase

@end

@implementation DefaultProfileTransportTest

- (void)testSyncNegative {
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    id <ProfileTransport> transport = [DefaultProfileTransport alloc];
    [transport setClientState:clientState];
    @try {
        [transport sync];
        XCTFail();
    }
    @catch (NSException *exception) {
        NSLog(@"testSyncNegative succeed. Caught ChannelRuntimeException");
    }
}

- (void)testSync {
    id <KaaChannelManager> channelManager = mockProtocol(@protocol(KaaChannelManager));
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    id <ProfileTransport> transport = [[DefaultProfileTransport alloc] init];
    [transport setClientState:clientState];
    [transport setChannelManager:channelManager];
    [transport sync];
    
    [verifyCount(channelManager, times(1)) syncAll:TRANSPORT_TYPE_PROFILE];
}

- (void)testCreateRequest {
    [KeyUtils generateKeyPair];
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    [given([clientState publicKey]) willReturn:(id)[KeyUtils getPublicKeyRef]];
    [given([clientState isRegistred]) willReturnBool:NO];
    
    KaaClientProperties *properties = mock([KaaClientProperties class]);
    id <ProfileManager> profileManager = mockProtocol(@protocol(ProfileManager));
    [given([profileManager getSerializedProfile]) willReturn:[self getDataWith123]];
    
    id <ProfileTransport> transport = [[DefaultProfileTransport alloc] init];
    [transport createProfileRequest];
    [transport setClientState:clientState];
    [transport createProfileRequest];
    [transport setProfileManager:profileManager];
    [transport createProfileRequest];
    [transport setClientProperties:properties];
    
    [transport createProfileRequest];
    [verifyCount(clientState, times(1)) endpointAccessToken];
    [verifyCount(profileManager, times(1)) getSerializedProfile];
}

- (void)testUpToDateProfile {
    NSData *profile = [self getDataWith123];
    id <KaaClientState> clientState = mockProtocol(@protocol(KaaClientState));
    [given([clientState isRegistred]) willReturnBool:YES];
    [given([clientState profileHash]) willReturn:[EndpointObjectHash fromSHA1:profile]];
    
    KaaClientProperties *properties = mock([KaaClientProperties class]);
    id <ProfileManager> profileManager = mockProtocol(@protocol(ProfileManager));
    [given([profileManager getSerializedProfile]) willReturn:profile];
    
    id <ProfileTransport> transport = [[DefaultProfileTransport alloc] init];
    [transport createProfileRequest];
    [transport setClientState:clientState];
    [transport createProfileRequest];
    [transport setProfileManager:profileManager];
    [transport createProfileRequest];
    [transport setClientProperties:properties];
    
    XCTAssertNil([transport createProfileRequest]);
    [verifyCount(clientState, times(0)) endpointAccessToken];
}

- (void)testonProfileResponse {
    id <KaaChannelManager> channelManager = mockProtocol(@protocol(KaaChannelManager));
    id <KaaClientState> clientState1 = mockProtocol(@protocol(KaaClientState));
    
    id <ProfileTransport> transport = [[DefaultProfileTransport alloc] init];
    [transport setChannelManager:channelManager];
    [transport setClientState:clientState1];
    
    ProfileSyncResponse *response1 = [[ProfileSyncResponse alloc] init];
    [response1 setResponseStatus:SYNC_RESPONSE_STATUS_RESYNC];
    
    [transport onProfileResponse:response1];
    
    [verifyCount(channelManager, times(1)) syncAll:TRANSPORT_TYPE_PROFILE];
    
    ProfileSyncResponse *response2 = [[ProfileSyncResponse alloc] init];
    [response2 setResponseStatus:SYNC_RESPONSE_STATUS_DELTA];
    
    [transport setClientState:nil];
    [transport onProfileResponse:response2];
    
    [verifyCount(clientState1, times(0)) setIsRegistred:anything()];
    
    [given([clientState1 isRegistred]) willReturnBool:NO];
    [transport setClientState:clientState1];
    [transport onProfileResponse:response2];
    
    [verifyCount(clientState1, times(1)) setIsRegistred:YES];
    
    id <KaaClientState> clientState2 = mockProtocol(@protocol(KaaClientState));
    [given([clientState2 isRegistred]) willReturnBool:YES];
    [transport setClientState:clientState2];
    [transport onProfileResponse:response2];
    
    [verifyCount(clientState2, times(0)) setIsRegistred:anything()];
}

- (void)testProfileDelegate {
    id <ProfileTransport> transport = mockProtocol(@protocol(ProfileTransport));
    id <ProfileManager> manager = [[DefaultProfileManager alloc] initWith:transport];
    
    [manager setProfileContainer:[[ConcreteProfileContainer alloc] init]];
    [manager updateProfile];
    
    [verifyCount(transport, times(1)) sync];
}

#pragma mark - Supporting methods

- (NSData *) getDataWith123 {
    NSInteger one = 1;
    NSInteger two = 2;
    NSInteger three = 3;
    NSMutableData *data = [NSMutableData dataWithBytes:&one length:sizeof(one)];
    [data appendBytes:&two length:sizeof(two)];
    [data appendBytes:&three length:sizeof(three)];
    return data;
}

@end
