//
//  Base64.h
//  Kaa
//
//  Created by Anton Bohomol on 8/17/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KAABase64

- (NSData *)decodeBase64:(NSData *)base64Data;
- (NSData *)decodeString:(NSString *)base64String;
- (NSData *)encodeBase64:(NSData *)binaryData;

@end

@interface CommonBase64 : NSObject <KAABase64>

@end
