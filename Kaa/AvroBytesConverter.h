//
//  AvroDataConverter.h
//  Kaa
//
//  Created by Anton Bohomol on 7/10/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvroUtils.h"

@interface AvroBytesConverter : NSObject

- (NSData *)toBytes:(id<Avro>)object;
- (id)fromBytes:(NSData *)bytes object:(id<Avro>)object;

@end
