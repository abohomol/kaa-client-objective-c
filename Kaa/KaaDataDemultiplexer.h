//
//  KaaDataDemultiplexer.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_KaaDataDemultiplexer_h
#define Kaa_KaaDataDemultiplexer_h

/**
 * Demultiplexer is responsible for deserializing of response data and notifying
 * appropriate services.
 *
 * Required in user implementation of any kind of data channel.
 */
@protocol KaaDataDemultiplexer

/**
 * Processes the given response bytes.
 */
- (void)processResponse:(NSData *)data;

/**
 * Routines to be executed before response will be processed
 */
- (void)preProcess;

/**
 * Define routines to be executed after response is processed.
 */
-(void) postProcess;

@end

#endif
