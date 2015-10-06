//
//  EndpointObjectHash.m
//  Kaa
//
//  Created by Anton Bohomol on 5/27/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "EndpointObjectHash.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSData+Conversion.h"


@interface EndpointObjectHash ()

- (instancetype)initWithData:(NSData *)data;

@end

@implementation EndpointObjectHash

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = [[NSData data] initWithData:data];
    }
    return self;
}

+ (instancetype)fromString:(NSString *)data {
    if (!data) {
        return nil;
    }
    NSData *utf8Data = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encodedData = [utf8Data base64EncodedDataWithOptions:0];
    return [[super alloc] initWithData: encodedData];
}

+ (instancetype)fromBytes:(NSData *)data {
    if (!data) {
        return nil;
    }
    return [[super alloc] initWithData:data];
}

+ (instancetype)fromSHA1:(NSData *)data {
    if (!data) {
        return nil;
    }
    unsigned char hashedChars[20];
    CC_SHA1([data bytes], [data length], hashedChars);
    NSData *hashedData = [NSData dataWithBytes:hashedChars length:20];
    return [[super alloc] initWithData:hashedData];
}

- (NSUInteger)hash {
    const NSUInteger prime = 31;
    return prime + [self.data hash];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[EndpointObjectHash class]]) {
        EndpointObjectHash *other = (EndpointObjectHash*)object;
        if ([self.data isEqualToData:other.data]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)description {
    return [self.data hexadecimalString];
}

@end
