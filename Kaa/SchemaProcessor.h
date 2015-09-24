//
//  SchemaProcessor.h
//  Kaa
//
//  Created by Anton Bohomol on 9/9/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_SchemaProcessor_h
#define Kaa_SchemaProcessor_h

/**
 * Receives the data from stream and creates the schema object.
 */
#import <Foundation/Foundation.h>

@protocol SchemaProcessor

/**
 * Loads new schema from the buffer.
 *
 * @throws IOException in case of loading schema failure
 * @param buffer schema buffer
 */
- (void)loadSchema:(NSData *)buffer;

/**
 * Retrieves current schema object.
 */
//TODO
//- (Schema)getSchema;

@end

#endif
