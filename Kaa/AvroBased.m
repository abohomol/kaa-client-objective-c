//
//  AvroBased.m
//  Kaa
//
//  Created by Anton Bohomol on 7/2/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AvroBased.h"

@implementation AvroBased

- (instancetype)init {
    self = [super init];
    if (self) {
        _utils = [[AvroUtils alloc] init];
    }
    return self;
}

- (void)serialize:(avro_writer_t)writer {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented"];
}

- (void)deserialize:(avro_reader_t)reader {
    [NSException raise:NSInternalInconsistencyException format:@"Not implemented"];
}

- (size_t)getSize {
    return 0;
}

+ (NSString *)FQN {
    return nil;
}

@end
