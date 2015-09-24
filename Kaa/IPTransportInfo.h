//
//  IPTransportInfo.h
//  Kaa
//
//  Created by Anton Bohomol on 9/8/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "GenericTransportInfo.h"

@interface IPTransportInfo : GenericTransportInfo

- (instancetype)initWithTransportInfo:(id<TransportConnectionInfo>)parent;

- (NSString *)getHost;
- (int)getPort;
- (NSData *)getPublicKey;
- (NSString *)getUrl;

@end
