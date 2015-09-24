//
//  AvroDataConverter.m
//  Kaa
//
//  Created by Anton Bohomol on 7/10/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AvroBytesConverter.h"
#import "AvroUtils.h"

#define TAG @"AvroBytesConverter >>>"

@implementation AvroBytesConverter

- (NSData *)toBytes:(id<Avro>)object {
    size_t objSize = [object getSize];
    char *buffer = (char *)malloc((objSize) * sizeof(char));
    avro_writer_t writer = avro_writer_memory(buffer, objSize);
    if (!writer) {
        DDLogError(@"%@ Unable to allocate '%li'bytes for avro writer", TAG, objSize);
        return nil;
    }
    [object serialize:writer];
    NSData *bytes = [NSData dataWithBytes:writer->buf length:writer->written];
    avro_writer_free(writer);
    return bytes;
}

- (id<Avro>)fromBytes:(NSData *)bytes object:(id<Avro>)object {
    avro_reader_t reader = avro_reader_memory([bytes bytes], [bytes length]);
    [object deserialize:reader];
    avro_reader_free(reader);
    return object;
}

@end
