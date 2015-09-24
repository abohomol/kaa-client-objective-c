//
//  BlockingQueue.h
//  Kaa
//
//  Created by Anton Bohomol on 9/11/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlockingQueue : NSObject

/**
 * Inserts the specified element into this queue.
 */
- (void)offer:(id)object;

/**
 * Retrieves and removes the head of this queue, 
 * waiting if necessary until an element becomes available.
 */
- (id)take;

/**
 * Removes all available elements from this queue and adds them
 * to the given collection.  This operation may be more
 * efficient than repeatedly polling this queue.
 */
- (void)drainTo:(NSMutableArray *)array;

/**
 * Returns amount of objects in blocking queue.
 */
- (NSUInteger)size;

@end
