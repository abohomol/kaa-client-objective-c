//
//  KAASocket.h
//  Kaa
//
//  Created by Anton Bohomol on 10/25/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KAASocket : NSObject

@property (nonatomic,strong) NSInputStream *input;
@property (nonatomic,strong) NSOutputStream *output;

+ (instancetype)openWithHost:(NSString *)host andPort:(int)port;
- (void)close;

@end
