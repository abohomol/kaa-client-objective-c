//
//  KaaUnion.m
//  Kaa
//
//  Created by Anton Bohomol on 7/2/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "KAAUnion.h"

@implementation KAAUnion

- (instancetype)initWithBranch:(int)branch andData:(id)data {
    self = [super init];
    if (self) {
        self.branch = branch;
        self.data = data;
    }
    return self;
}

- (instancetype)initWithBranch:(int)branch {
    self = [super init];
    if (self) {
        self.branch = branch;
        self.data = nil;
    }
    return self;
}

+ (instancetype)unionWithBranch:(int)branch andData:(id)data {
    return [[KAAUnion alloc] initWithBranch:branch andData:data];
}

+ (instancetype)unionWithBranch:(int)branch {
    return [[KAAUnion alloc] initWithBranch:branch];
}

- (NSString *)description {
    if (self.data) {
        return [NSString stringWithFormat:@"Branch:%i Data(%@):%@", self.branch, [self.data class], [self.data description]];
    } else {
        return [NSString stringWithFormat:@"Empty union with branch: %i", self.branch];
    }
}

@end
