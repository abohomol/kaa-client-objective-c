//
//  NSDataUtils.m
//  Kaa
//
//  Created by Aleksey Gutyro on 05.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "NSDataUtils.h"

@implementation NSDataUtils

+ (NSString *)toHex:(NSData*)data {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end
