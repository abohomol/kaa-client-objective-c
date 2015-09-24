//
//  EndpointAccessToken.h
//  Kaa
//
//  Created by Anton Bohomol on 5/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EndpointAccessToken : NSObject <NSCopying>

@property(nonatomic,strong) NSString *token;

- (instancetype)initWithToken:(NSString *)token;

@end
