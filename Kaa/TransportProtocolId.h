//
//  TransportProtocolId.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransportProtocolId : NSObject <NSCopying>

@property(nonatomic,readonly) int protocolId;
@property(nonatomic,readonly) int protocolVersion;

- (instancetype)initWithId:(int)id andVersion:(int)version;

@end
