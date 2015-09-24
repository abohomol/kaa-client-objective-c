//
//  HTTPRequestCreator.h
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageEncoderDecoder.h"

@interface HttpRequestCreator : NSObject

+ (NSDictionary *)createOperationHttpRequest:(NSData *)body withEncoderDecoder:(MessageEncoderDecoder *)messageEncDec;

+ (NSDictionary *)createBootstrapHttpRequest:(NSData *)body withEncoderDecoder:(MessageEncoderDecoder *)messageEncDec;

+ (NSDictionary *)createHttpRequest:(NSData *)body withEncoderDecoder:(MessageEncoderDecoder *)messageEncDec sign:(BOOL)sign;

@end
