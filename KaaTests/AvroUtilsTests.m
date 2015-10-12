//
//  AvroUtilsTests.m
//  Kaa
//
//  Created by Anton Bohomol on 9/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

@import UIKit;
#import "AvroUtils.h"
#import "EndpointGen.h"
#import <XCTest/XCTest.h>

@interface AvroUtilsTests : XCTestCase

@property (nonatomic,strong) AvroUtils *utils;

@end

@implementation AvroUtilsTests

- (void)setUp {
    [super setUp];
    self.utils = [[AvroUtils alloc] init];
}

- (void)testPrimitives {
    
    typedef enum {
        ANACONDA,
        ASP,
        ADDER,
        ADER
    } Snakes;
    
    NSNumber *intOrigin = [NSNumber numberWithInt:23];
    NSNumber *longOrigin = [NSNumber numberWithLong:234];
    NSNumber *floatOrigin = [NSNumber numberWithFloat:394.3];
    NSNumber *doubleOrigin = [NSNumber numberWithDouble:35235.54];
    NSNumber *boolOrigin = [NSNumber numberWithBool:YES];
    NSNumber *enumOrigin = [NSNumber numberWithInt:ADDER];
    
    size_t bufSize = [self.utils getIntSize:intOrigin]
        + [self.utils getLongSize:longOrigin]
        + [self.utils getFloatSize]
        + [self.utils getDoubleSize]
        + [self.utils getBooleanSize:boolOrigin]
        + [self.utils getEnumSize:enumOrigin];
    char *buffer = (char*)malloc(bufSize * sizeof(char));
    avro_writer_t writer = avro_writer_memory(buffer, bufSize);
    if (!writer) {
        XCTFail(@"Can't allocate memory!");
    }
    [self.utils serializeInt:intOrigin to:writer];
    [self.utils serializeLong:longOrigin to:writer];
    [self.utils serializeFloat:floatOrigin to:writer];
    [self.utils serializeDouble:doubleOrigin to:writer];
    [self.utils serializeBoolean:boolOrigin to:writer];
    [self.utils serializeEnum:enumOrigin to:writer];
    
    NSData *serialized = [NSData dataWithBytes:writer->buf length:writer->len];
    avro_writer_free(writer);
    
    avro_reader_t reader = avro_reader_memory([serialized bytes], [serialized length]);
    NSNumber *intDes = [self.utils deserializeInt:reader];
    NSNumber *longDes = [self.utils deserializeLong:reader];
    NSNumber *floatDes = [self.utils deserializeFloat:reader];
    NSNumber *doubleDes = [self.utils deserializeDouble:reader];
    NSNumber *boolDes = [self.utils deserializeBoolean:reader];
    NSNumber *enumDes = [self.utils deserializeEnum:reader];
    avro_reader_free(reader);
    
    XCTAssertTrue([intOrigin isEqualToNumber:intDes]);
    XCTAssertTrue([longOrigin isEqualToNumber:longDes]);
    XCTAssertTrue([floatOrigin isEqualToNumber:floatDes]);
    XCTAssertTrue([doubleOrigin isEqualToNumber:doubleDes]);
    XCTAssertTrue([boolOrigin isEqualToNumber:boolDes]);
    XCTAssertTrue([enumOrigin isEqualToNumber:enumDes]);
}

- (void)testBytes {
    int randomInt = arc4random();
    NSData *data = [NSData dataWithBytes:&randomInt length:sizeof(randomInt)];
    char *buffer = (char *)malloc(([self.utils getBytesSize:data]) * sizeof(char));
    avro_writer_t writer = avro_writer_memory(buffer, [self.utils getBytesSize:data]);
    if (!writer) {
        XCTFail(@"Can't allocate memory!");
    }
    [self.utils serializeBytes:data to:writer];
    NSData *serialized = [NSData dataWithBytes:writer->buf length:writer->written];
    avro_writer_free(writer);
    if (buffer) {
        free(buffer);
    }
    
    avro_reader_t reader = avro_reader_memory([serialized bytes], [serialized length]);
    NSData *deserialized = [self.utils deserializeBytes:reader];
    avro_reader_free(reader);
    XCTAssertTrue([data isEqualToData:deserialized]);
}

- (void)testFixed {
    int randomInt = arc4random();
    NSData *data = [NSData dataWithBytes:&randomInt length:sizeof(randomInt)];
    char *buffer = (char *)malloc(([self.utils getFixedSize:data]) * sizeof(char));
    avro_writer_t writer = avro_writer_memory(buffer, [self.utils getFixedSize:data]);
    if (!writer) {
        XCTFail(@"Can't allocate memory!");
    }
    [self.utils serializeFixed:data to:writer];
    NSData *serialized = [NSData dataWithBytes:writer->buf length:writer->written];
    avro_writer_free(writer);
    if (buffer) {
        free(buffer);
    }
    
    avro_reader_t reader = avro_reader_memory([serialized bytes], [serialized length]);
    NSData *deserialized = [self.utils deserializeFixed:reader size:[NSNumber numberWithLong:[data length]]];
    avro_reader_free(reader);
    XCTAssertTrue([data isEqualToData:deserialized]);
}

- (void)testString {
    
    NSString *origin = @"Avro Utils Tests";
    char *buffer = (char *)malloc(([self.utils getStringSize:origin]) * sizeof(char));
    avro_writer_t writer = avro_writer_memory(buffer, [self.utils getStringSize:origin]);
    if (!writer) {
        XCTFail(@"Can't allocate memory!");
    }
    [self.utils serializeString:origin to:writer];
    NSData *serialized = [NSData dataWithBytes:writer->buf length:writer->written];
    avro_writer_free(writer);
    if (buffer) {
        free(buffer);
    }

    avro_reader_t reader = avro_reader_memory([serialized bytes], [serialized length]);
    NSString *deserialized = [self.utils deserializeString:reader];
    avro_reader_free(reader);
    XCTAssertTrue([origin isEqualToString:deserialized]);
}


- (void)testArrayWithStrings {
    
    NSArray *array = [NSArray arrayWithObjects:@"Object1", @"Object2", @"Object3", nil];
    size_t size = [self.utils getArraySize:array withSelector:@selector(getStringSize:) parameterized:YES target:self.utils];
    char *buffer = (char *)malloc(size * sizeof(char));
    avro_writer_t writer = avro_writer_memory(buffer, size);
    if (!writer) {
        XCTFail(@"Can't allocate memory!");
    }
    [self.utils serializeArray:array to:writer withSelector:@selector(serializeString:to:) target:self.utils];
    NSData *serialized = [NSData dataWithBytes:writer->buf length:writer->written];
    avro_writer_free(writer);
    if (buffer) {
        free(buffer);
    }
    
    avro_reader_t reader = avro_reader_memory([serialized bytes], [serialized length]);
    NSArray *desirealized = [self.utils deserializeArray:reader withSelector:@selector(deserializeString:) andParam:nil target:self.utils];
    avro_reader_free(reader);
    XCTAssertEqual([array count], [desirealized count]);
    for (int i = 0; i < [array count]; i++) {
        [[array objectAtIndex:i] isEqualToString:[desirealized objectAtIndex:i]];
    }
}


- (void)testArrayOfRecords {
    
    SubscriptionCommand *command1 = [[SubscriptionCommand alloc] init];
    command1.topicId = @"TestSubscriptionCommand1";
    command1.command = SUBSCRIPTION_COMMAND_TYPE_REMOVE;
    SubscriptionCommand *command2 = [[SubscriptionCommand alloc] init];
    command2.topicId = @"TestSubscriptionCommand2";
    command2.command = SUBSCRIPTION_COMMAND_TYPE_REMOVE;
    SubscriptionCommand *command3 = [[SubscriptionCommand alloc] init];
    command3.topicId = @"TestSubscriptionCommand3";
    command3.command = SUBSCRIPTION_COMMAND_TYPE_REMOVE;
    
    NSArray *array = [NSArray arrayWithObjects:command1, command2, command3, nil];
    
    size_t size = [self.utils getArraySize:array withSelector:@selector(getSize) parameterized:NO target:nil];
    char *buffer = (char *)malloc(size * sizeof(char));
    avro_writer_t writer = avro_writer_memory(buffer, size);
    if (!writer) {
        XCTFail(@"Can't allocate memory!");
    }
    [self.utils serializeArray:array to:writer withSelector:@selector(serializeRecord:to:) target:nil];
    NSData *serialized = [NSData dataWithBytes:writer->buf length:writer->written];
    avro_writer_free(writer);
    if (buffer) {
        free(buffer);
    }
    
    avro_reader_t reader = avro_reader_memory([serialized bytes], [serialized length]);
    NSArray *desirealized = [self.utils deserializeArray:reader withSelector:@selector(deserializeRecord:as:) andParam:[SubscriptionCommand class] target:nil];
    avro_reader_free(reader);
    XCTAssertEqual([array count], [desirealized count]);
}

@end
