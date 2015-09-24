//
//  Base64.m
//  Kaa
//
//  Created by Anton Bohomol on 8/17/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "KAABase64.h"

@implementation CommonBase64

- (NSData *)decodeBase64:(NSData *)base64Data {
    return [[NSData alloc] initWithBase64EncodedData:base64Data options:0];
}

- (NSData *)decodeString:(NSString *)base64String {
    return [[NSData alloc] initWithBase64EncodedString:base64String options:0];
}

- (NSData *)encodeBase64:(NSData *)binaryData {
    return [binaryData base64EncodedDataWithOptions:0];
}

@end
