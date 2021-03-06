/*
 * Copyright 2014-2015 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface SHAMessageDigest : NSObject

/**
 * Accumulate string data chunk.
 */
- (void)updateWithString:(NSString *)string;

- (void)update:(NSData *)data;

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
