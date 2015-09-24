//
//  SyncTask.m
//  Kaa
//
//  Created by Anton Bohomol on 9/9/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "SyncTask.h"

@interface SyncTask ()

@property (nonatomic,strong) NSSet *transportTypes;
@property (nonatomic) BOOL ackOnly;
@property (nonatomic) BOOL all;

@end

@implementation SyncTask

- (instancetype)initWithTransport:(TransportType)type ackOnly:(BOOL)ackOnly all:(BOOL)all {
    return [self initWithTransports:[NSSet setWithObject:[NSNumber numberWithInt:type]] ackOnly:ackOnly all:all];
}

- (instancetype)initWithTransports:(NSSet *)types ackOnly:(BOOL)ackOnly all:(BOOL)all {
    self = [super init];
    if (self) {
        self.transportTypes = types;
        self.ackOnly = ackOnly;
        self.all = all;
    }
    return self;
}

- (NSSet *)getTransportTypes {
    return self.transportTypes;
}

- (BOOL)isAckOnly {
    return self.ackOnly;
}

- (BOOL)isAll {
    return self.all;
}

+ (SyncTask *)merge:(SyncTask *)task additionalTasks:(NSArray *)tasks {
    NSMutableSet *types = [NSMutableSet setWithSet:[task getTransportTypes]];
    BOOL ack = [task isAckOnly];
    BOOL all = [task isAll];
    for (SyncTask *task in tasks) {
        [types addObjectsFromArray:[task getTransportTypes].allObjects];
        ack = ack && [task isAckOnly];
        all = all || [task isAll];
    }
    return [[SyncTask alloc] initWithTransports:types ackOnly:ack all:all];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SyncTask [types: %@,ackOnly: %d,all: %d]", self.transportTypes, self.ackOnly, self.all];
}

@end
