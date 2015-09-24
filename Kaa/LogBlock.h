//
//  LogBlock.h
//  Kaa
//
//  Created by Anton Bohomol on 7/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Wrapper class for a log block which is going to be sent.
 *
 * Each log block should have its unique id to be mapped in the log storage and
 * delivery stuff.
 */
@interface LogBlock : NSObject

//Unique id for sending log block
@property(nonatomic,readonly) NSInteger blockId;
//List of sending log records <LogRecord>
@property(nonatomic,strong,readonly) NSArray* logRecords;

- (instancetype)initWithBlockId:(NSInteger)blockId andRecords:(NSArray*)logRecords;

@end
