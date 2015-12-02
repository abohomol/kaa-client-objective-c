//
//  DefaultProfileManager.m
//  Kaa
//
//  Created by Anton Bohomol on 8/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultProfileManager.h"
#import "ProfileCommon.h"

@interface DefaultProfileManager ()

@property (nonatomic,strong) ProfileSerializer *serializer;

@property (nonatomic,strong) id<ProfileTransport> transport;
@property (nonatomic,strong) id<ProfileContainer> container;

@end

@implementation DefaultProfileManager

- (instancetype)initWith:(id<ProfileTransport>)transport {
    self = [super init];
    if (self) {
        self.transport = transport;
        self.serializer = [[ProfileSerializer alloc] init];
    }
    return self;
}

- (void)setProfileContainer:(id<ProfileContainer>)container {
    self.container = container;
}

- (NSData *)getSerializedProfile {
    return [self.serializer toBytes:self.container];
}

- (void)updateProfile {
    [self.transport sync];
}

- (BOOL)isInitialized {
    return self.container != nil || [self.serializer isDefault];
}

@end
