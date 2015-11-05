//
//  BlockingQueue.m
//  Kaa
//
//  Created by Anton Bohomol on 9/11/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "BlockingQueue.h"

@interface BlockingQueue()

@property (nonatomic,strong) NSMutableArray *queue;
@property (nonatomic,strong) NSCondition *condition;

@end

@implementation BlockingQueue

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = [NSMutableArray array];
        self.condition = [[NSCondition alloc] init];
    }
    return self;
}

- (void)offer:(id)object {
    [self.condition lock];
    [self.queue addObject:object];
    [self.condition signal];
    [self.condition unlock];
}

- (id)take {
    id object;
    [self.condition lock];
    while (self.queue.count == 0) {
        [self.condition wait];
    }
    object = [self.queue objectAtIndex:0];
    [self.queue removeObjectAtIndex:0];
    [self.condition unlock];
    
    return object;
}

- (void)drainTo:(NSMutableArray *)array {
    if ([self.queue count] == 0) {
        return;
    }
        [self.condition lock];
        [array addObjectsFromArray:self.queue];
        [self.queue removeAllObjects];
        [self.condition unlock];
}

- (NSUInteger)size {
    return [self.queue count];
}

@end
