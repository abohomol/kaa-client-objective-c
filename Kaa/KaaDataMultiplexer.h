//
//  KaaDataMultiplexer.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_KaaDataMultiplexer_h
#define Kaa_KaaDataMultiplexer_h

/**
 * Multiplexer collects the info about states from different
 * services and compiles it in one request.
 *
 * Required in user implementation of any kind of data channel.
 */
@protocol KaaDataMultiplexer

/**
 * Compiles request for given transport types.
 *
 * types - map of types to be polled.
 * 
 * <TransportType, ChannelDirection>
 *
 */
- (NSData *)compileRequest:(NSDictionary *)types;

@end

#endif
