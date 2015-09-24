//
//  UUID.m
//  Kaa
//
//  Created by Anton Bohomol on 9/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "UUID.h"

@implementation UUID

+ (NSString *)randomUUID {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *identifier = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return identifier;
}

@end
