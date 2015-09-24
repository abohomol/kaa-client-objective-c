//
//  KaaUnion.h
//  Kaa
//
//  Created by Anton Bohomol on 7/2/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KAAUnion : NSObject

@property(nonatomic) int branch;
@property(nonatomic, strong) id data;

- (instancetype)initWithBranch:(int)branch andData:(id)data;
- (instancetype)initWithBranch:(int)branch;

+ (instancetype)unionWithBranch:(int)branch andData:(id)data;
+ (instancetype)unionWithBranch:(int)branch;

@end
