//
//  EndpointKeyHash.h
//  Kaa
//
//  Created by Anton Bohomol on 5/27/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EndpointKeyHash : NSObject

@property(nonatomic,strong) NSString *keyHash;

- (instancetype)initWithKeyHash:(NSString *)keyHash;

@end
