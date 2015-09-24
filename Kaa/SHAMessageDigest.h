//
//  SHAMessageDigest.h
//  Kaa
//
//  Created by Anton Bohomol on 8/19/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface SHAMessageDigest : NSObject

/**
 * Accumulate string data chunk.
 */
- (void)updateWithString:(NSString *)string;

/**
 * Compute message digest with accumulated data chunks.
 * @return pointer to the internal buffer that holds the message digest value.
 */
- (unsigned char *)final;

/**
 * @return size of the message digest in bytes.
 */
- (size_t)size;

@end
