//
//  NSString+Commons.m
//  Kaa
//
//  Created by Anton Bohomol on 8/18/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "NSString+Commons.h"

@implementation NSString (Commons)

- (BOOL)isEmpty {
    if ([self length] == 0) {
        return YES;
    }
    if (![[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]) {
        return YES;
    }
    return NO;
}

@end
