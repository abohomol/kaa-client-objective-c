//
//  SyncRequest.m
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "SyncRequest.h"

@implementation SyncRequest

- (instancetype)initWithAvro:(NSData *)avroObject zipped:(BOOL)isZipped encypted:(BOOL)isEncrypted {
    return [self initWithAvro:avroObject request:YES zipped:isZipped encypted:isEncrypted];
}

- (instancetype)initWithOldKaaSync:(KaaSync *)old {
    self = [super initWithOldKaaSync:old];
    if (self) {
        [self setRequest:YES];
        NSInputStream *input = [NSInputStream inputStreamWithData:self.buffer];
        [self decodeAvroObject:input];
        [input close];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setRequest:YES];
    }
    return self;
}

@end
