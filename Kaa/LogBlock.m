//
//  LogBlock.m
//  Kaa
//
//  Created by Anton Bohomol on 7/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "LogBlock.h"

@implementation LogBlock

- (instancetype)initWithBlockId:(int32_t)blockId andRecords:(NSArray *)logRecords {
    self = [super init];
    if (self) {
        _blockId = blockId;
        _logRecords = logRecords;
    }
    return self;
}

@end
