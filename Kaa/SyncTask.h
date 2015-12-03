/*
 * Copyright 2014-2015 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
