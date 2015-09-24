//
//  SHAMessageDigest.m
//  Kaa
//
//  Created by Anton Bohomol on 8/19/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "SHAMessageDigest.h"
#import "NSString+Commons.h"

@interface SHAMessageDigest ()

- (void)reset;

@end

@implementation SHAMessageDigest {
    CC_SHA1_CTX context;
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
}

- (void)reset {
    CC_SHA1_Init(&context);
    memset(digest, 0, sizeof(digest));
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)updateWithString:(NSString *)string {
    if (string && ![string isEmpty]) {
        const char *cString = [string cStringUsingEncoding:NSUTF8StringEncoding];
        CC_LONG strLength = strlen(cString);
        CC_SHA1_Update(&context, cString, strLength);
    }
}

- (size_t)size {
    return sizeof(digest);
}

- (unsigned char *)final {
    CC_SHA1_Final(digest, &context);
    return digest;
}

@end
