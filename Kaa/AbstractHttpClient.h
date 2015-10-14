//
//  AbstractHttpClient.h
//  Kaa
//
//  Created by Anton Bohomol on 9/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageEncoderDecoder.h"

@interface AbstractHttpClient : NSObject

@property (nonatomic,strong) NSString *url;

//- (instancetype)initWith:(NSString *)url
//              privateKey:(SecKeyRef)privateK
//               publicKey:(SecKeyRef)publicK
//               remoteKey:(NSData *)remoteK;
- (instancetype)initWith:(NSString *)url
              privateKey:(SecKeyRef)privateK
               publicKey:(SecKeyRef)publicK
            remoteKeyRef:(SecKeyRef)remoteK;

- (void)disableVerification;
- (NSData *)verifyResponse:(NSData *)body signature:(NSData *)signature;
- (MessageEncoderDecoder *)getEncoderDecoder;

//NOTE: methods below are abstract

- (NSData *)executeHttpRequest:(NSString *)uri entity:(NSDictionary *)entity verifyResponse:(BOOL)verifyResponse;
- (void)close;
- (void)abort;
- (BOOL)canAbort;

@end
