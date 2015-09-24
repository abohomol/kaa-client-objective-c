//
//  TransportProtocolIdHolder.h
//  Kaa
//
//  Created by Anton Bohomol on 9/8/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportProtocolId.h"

/**
 * Class to hold transport id constants. Please note that this constants should
 * match same constants in appropriate transport configs on server side
 */
@interface TransportProtocolIdHolder : NSObject

+ (TransportProtocolId *)HTTPTransportID;
+ (TransportProtocolId *)TCPTransportID;

@end
