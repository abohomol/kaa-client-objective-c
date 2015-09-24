//
//  EventFamily.h
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_BaseEventFamily_h
#define Kaa_BaseEventFamily_h

#import <Foundation/Foundation.h>

/**
 * Interface for Event Family.
 * Each EventFamily should be accessed through <EventFamilyFactory>
 */
@protocol BaseEventFamily

/**
 * Returns set of supported incoming events in event family
 *
 * @return set of supported events presented as set event fully qualified names
 */
- (NSSet *)getSupportedEventFQNs;

/**
* Generic handler of event received from server.
*
* @param eventFQN - fully qualified name of an event
* @param data     - event data
* @param source   - event source
*/
- (void)onGenericEvent:(NSString *)eventFQN withData:(NSData *)data from:(NSString *)source;

@end

#endif
