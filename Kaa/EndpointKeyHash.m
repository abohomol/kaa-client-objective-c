//
//  EndpointKeyHash.m
//  Kaa
//
//  Created by Anton Bohomol on 5/27/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "EndpointKeyHash.h"

/**
 * Represents endpoint key hash returned from OPS after it was successfully attached.
 */
@implementation EndpointKeyHash

- (instancetype)initWithKeyHash:(NSString *)keyHash {
    self = [super init];
    if (self) {
        self.keyHash = keyHash;
    }
    return self;
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    return prime + [self.keyHash hash];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[EndpointKeyHash class]]) {
        EndpointKeyHash *other = (EndpointKeyHash *)object;
        if ([self.keyHash isEqualToString:other.keyHash]) {
            return YES;
        }
    }
    
    return NO;
}

@end
