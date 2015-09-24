//
//  KaaClientPlatformContext.h
//  Kaa
//
//  Created by Anton Bohomol on 9/8/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_KaaClientPlatformContext_h
#define Kaa_KaaClientPlatformContext_h

#import <Foundation/Foundation.h>
#import "KaaClientProperties.h"
#import "AbstractHttpClient.h"
#import "KAABase64.h"
#import "ConnectivityChecker.h"
#import "ExecutorContext.h"

/**
 * Represents platform specific context for Kaa client initialization
 */
@protocol KaaClientPlatformContext

/**
 * Returns platform SDK properties
 */
- (KaaClientProperties *)getProperties;

/**
 * Returns platform dependent implementation of http client
 */
- (AbstractHttpClient *)createHttpClient:(NSString *)url
                              privateKey:(SecKeyRef)privateK
                               publicKey:(SecKeyRef)publicK
                               remoteKey:(NSData *)remoteK;

/**
 * Returns platform dependent implementation of Base64 algorithm
 */
- (id<KAABase64>)getBase64;

/**
 * Creates checker for internet connection
 */
- (ConnectivityChecker *)createConnectivityChecker;

/**
 * Returns SDK thread execution context
 */
- (id<ExecutorContext>)getExecutorContext;

@end

#endif
