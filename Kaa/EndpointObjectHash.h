//
//  EndpointObjectHash.h
//  Kaa
//
//  Created by Anton Bohomol on 5/27/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The class EndpointObjectHash is responsible for hash calculation
 */
@interface EndpointObjectHash : NSObject

@property (nonatomic,strong,readonly) NSData *data;

+ (instancetype)fromString:(NSString *)data;
+ (instancetype)fromBytes:(NSData *)data;

/**
 * Creates EndpointObjectHash using SHA1 algorithm over String representation of an object.
 */
+ (instancetype)fromSHA1:(NSData *)data;

//TODO
//getDataBuf
//binaryEquals

@end
