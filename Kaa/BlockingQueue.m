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
@property (nonatomic,strong) dispatch_queue_t dispatcher;
@property (nonatomic,strong) NSCondition *condition;

@end

@implementation BlockingQueue

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = [NSMutableArray array];
        NSString *dispatcherName = [NSString stringWithFormat:@"org.kaaproject.kaa.blockingqueue.%li", (long)self.hash];
        self.dispatcher = dispatch_queue_create([dispatcherName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
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
    __block id object;
    __weak typeof(self)this = self;
    dispatch_sync(this.dispatcher, ^{
        [this.condition lock];
        while (this.queue.count == 0) {
            [this.condition wait];
        }
        object = [this.queue objectAtIndex:0];
        [this.queue removeObjectAtIndex:0];
        [this.condition unlock];
    });
    
    return object;
}

- (void)drainTo:(NSMutableArray *)array {
    if ([self.queue count] == 0) {
        return;
    }
    __weak typeof(self)this = self;
    dispatch_sync(this.dispatcher, ^{
        [this.condition lock];
        [array addObjectsFromArray:this.queue];
        [this.queue removeAllObjects];
        [this.condition unlock];
    });
}

- (NSUInteger)size {
    return [self.queue count];
}

@end
