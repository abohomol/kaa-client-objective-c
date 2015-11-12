//
//  AvroUtils.h
//  Kaa
//
//  Created by Anton Bohomol on 6/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "io.h"
#import "encoding.h"

@protocol Avro

- (void)serialize:(avro_writer_t)writer;
- (void)deserialize:(avro_reader_t)reader;
- (size_t)getSize;
+ (NSString *)FQN;

@end

@interface AvroUtils : NSObject

- (size_t)getStringSize:(NSString *)data;
- (NSString *)deserializeString:(avro_reader_t)reader;
- (void)serializeString:(NSString *)data to:(avro_writer_t)writer;

- (size_t)getBytesSize:(NSData *)data;
- (NSData *)deserializeBytes:(avro_reader_t)reader;
- (void)serializeBytes:(NSData *)data to:(avro_writer_t)writer;

- (size_t)getFixedSize:(NSData *)data;
- (NSData *)deserializeFixed:(avro_reader_t)reader size:(NSNumber *)size;
- (void)serializeFixed:(NSData *)data to:(avro_writer_t)writer;

- (size_t)getBooleanSize:(NSNumber *)data;
- (NSNumber *)deserializeBoolean:(avro_reader_t)reader;
- (void)serializeBoolean:(NSNumber *)data to:(avro_writer_t)writer;

- (size_t)getIntSize:(NSNumber *)data;
- (NSNumber *)deserializeInt:(avro_reader_t)reader;
- (void)serializeInt:(NSNumber *)data to:(avro_writer_t)writer;

- (size_t)getLongSize:(NSNumber *)data;
- (NSNumber *)deserializeLong:(avro_reader_t)reader;
- (void)serializeLong:(NSNumber *)data to:(avro_writer_t)writer;

- (size_t)getFloatSize;
- (NSNumber *)deserializeFloat:(avro_reader_t)reader;
- (void)serializeFloat:(NSNumber *)data to:(avro_writer_t)writer;

- (size_t)getDoubleSize;
- (NSNumber *)deserializeDouble:(avro_reader_t)reader;
- (void)serializeDouble:(NSNumber *)data to:(avro_writer_t)writer;

- (size_t)getEnumSize:(NSNumber *)data;
- (NSNumber *)deserializeEnum:(avro_reader_t)reader;
- (void)serializeEnum:(NSNumber *)data to:(avro_writer_t)writer;

- (id<Avro>)deserializeRecord:(avro_reader_t)reader as:(Class)cls;
- (void)serializeRecord:(id<Avro>)data to:(avro_writer_t)writer;

- (size_t)getArraySize:(NSArray *)array withSelector:(SEL)sizeFunc parameterized:(BOOL)parameterized target:(id)target;
- (NSArray *)deserializeArray:(avro_reader_t)reader
                withSelector:(SEL)deserializeFunc
                    andParam:(id)param
                      target:(id)target;
- (void)serializeArray:(NSArray *)array
                    to:(avro_writer_t)writer
          withSelector:(SEL)serializeFunc
                target:(id)target;

@end
