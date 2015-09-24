//
//  ConnectivityChecker.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Checker of a network connectivity.
 */
@interface ConnectivityChecker : NSObject

/**
 * Check whether network connectivity exists.
 */
- (BOOL)isConnected;

@end
