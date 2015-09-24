//
//  SyncTask.h
//  Kaa
//
//  Created by Anton Bohomol on 9/9/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportCommon.h"

@interface SyncTask : NSObject

- (instancetype)initWithTransport:(TransportType)type ackOnly:(BOOL)ackOnly all:(BOOL)all;
- (instancetype)initWithTransports:(NSSet *)types ackOnly:(BOOL)ackOnly all:(BOOL)all; //<TransportType>

- (NSSet *)getTransportTypes;
- (BOOL)isAckOnly;
- (BOOL)isAll;

+ (SyncTask *)merge:(SyncTask *)task additionalTasks:(NSArray *)tasks;

@end
