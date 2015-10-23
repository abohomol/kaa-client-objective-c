//
//  EndpointAccessToken.m
//  Kaa
//
//  Created by Anton Bohomol on 5/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "EndpointAccessToken.h"

/**
 * Represents endpoint access token which has to be passed for endpoint attachment.
 */
@implementation EndpointAccessToken

- (instancetype)initWithToken:(NSString *)token {
    self = [super init];
    if (self) {
        self.token = token;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithToken:self.token];
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    return prime + (self.token ? [self.token hash] : 0);
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (object == nil) {
        return NO;
    }
    if ([object isKindOfClass:[EndpointAccessToken class]]) {
        EndpointAccessToken *other = (EndpointAccessToken*)object;
        if (self.token == nil) {
            if (other.token != nil) {
                return NO;
            } else {
                return YES;
            }
        }
        if ([self.token isEqualToString:other.token]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)description {
    return self.token;
}

@end
