//
//  DefaultProfileTransport.m
//  Kaa
//
//  Created by Anton Bohomol on 9/15/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultProfileTransport.h"
#import "KeyUtils.h"
#import "KaaLogging.h"

#define TAG @"DefaultProfileTransport >>>"

@interface DefaultProfileTransport ()

@property (nonatomic,strong) id<ProfileManager> profileMgr;
@property (nonatomic,strong) KaaClientProperties *properties;

- (BOOL)isProfileOutDated:(EndpointObjectHash *)currentProfileHash;

@end

@implementation DefaultProfileTransport

- (void)sync {
    [self syncAll:TRANSPORT_TYPE_PROFILE];
}

- (ProfileSyncRequest *)createProfileRequest {
    if (self.clientState && self.profileMgr && self.properties) {
        NSData *serializedProfile = [self.profileMgr getSerializedProfile];
        EndpointObjectHash *currentProfileHash = [EndpointObjectHash fromSHA1:serializedProfile];
        if ([self isProfileOutDated:currentProfileHash] || ![self.clientState isRegistred]) {
            [self.clientState setProfileHash:currentProfileHash];
            ProfileSyncRequest *request = [[ProfileSyncRequest alloc] init];
            request.endpointAccessToken = [KAAUnion unionWithBranch:KAA_UNION_STRING_OR_NULL_BRANCH_0
                                                            andData:[self.clientState endpointAccessToken]];
            if (![self.clientState isRegistred]) {
                [self.clientState publicKey]; //ensures that key pair is created
                request.endpointPublicKey = [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_0
                                                              andData:[KeyUtils getPublicKey]];
            }
            request.profileBody = serializedProfile;
            return request;
            
        } else {
            DDLogInfo(@"%@ Profile is up to date", TAG);
        }
    } else {
        DDLogError(@"%@ Failed to create ProfileSyncRequest clientState %@, manager %@, properties %@",
                   TAG, self.clientState, self.profileMgr, self.properties);
    }
    return nil;
}

- (void)onProfileResponse:(ProfileSyncResponse *)response {
    if (response.responseStatus == SYNC_RESPONSE_STATUS_RESYNC) {
        [self syncAll:TRANSPORT_TYPE_PROFILE];
    } else if (self.clientState && ![self.clientState isRegistred]) {
        [self.clientState setIsRegistred:YES];
    }
    DDLogInfo(@"%@ Processed profile response", TAG);
}

- (void)setProfileManager:(id<ProfileManager>)manager {
    self.profileMgr = manager;
}

- (void)setClientProperties:(KaaClientProperties *)clientProperties {
    self.properties = clientProperties;
}

- (TransportType)getTransportType {
    return TRANSPORT_TYPE_PROFILE;
}

- (BOOL)isProfileOutDated:(EndpointObjectHash *)currentProfileHash {
    EndpointObjectHash *currentHash = [self.clientState profileHash];
    return !currentHash || ![currentProfileHash isEqual:currentHash];
}

@end
