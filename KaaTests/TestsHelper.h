//
//  TestsHelper.h
//  Kaa
//
//  Created by Anton Bohomol on 11/1/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportProtocolId.h"
#import "EndpointGen.h"
#import "KaaClientProperties.h"

#define KAATestEqual(a, b)\
if ((a) != (b)) {\
[NSException raise:@"Test failed!" format:@"%li != %li", (long)a, (long)b];\
}

#define KAATestObjectsEqual(a, b)\
if (![(a) isEqual:(b)]) {\
[NSException raise:@"Test failed!" format:@"%@ ISN'T EQUAL TO %@", a, b];\
}

@interface TestsHelper : NSObject

+ (ProtocolMetaData *)buildMetaDataWithTPid:(TransportProtocolId *)TPid
                                       host:(NSString *)host
                                       port:(int32_t)port
                               andPublicKey:(NSData *)publicKey;

+ (KaaClientProperties *)getProperties;

@end
