/*
 * Copyright 2014 CyberVision, Inc.
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

#import "LogRecord.h"
#import "AvroBytesConverter.h"

@implementation LogRecord

- (instancetype)initWithRecord:(KAADummyLog *)record {
    self = [super init];
    if (self) {
        AvroBytesConverter *converter = [[AvroBytesConverter alloc] init];
        _data = [converter toBytes:record];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (int64_t)getSize {
    return [self.data length];
}

@end
