//
//  GenericLogCollector.h
//  Kaa
//
//  Created by Anton Bohomol on 7/15/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_GenericLogCollector_h
#define Kaa_GenericLogCollector_h

#import <Foundation/Foundation.h>
#import "LogStorage.h"
#import "LogUploadStrategy.h"

/**
 * Root interface for a log collector.
 *
 * Adds new log record to a local storage.
 *
 * May be configured by setting user defined log record storage and log upload
 * strategy. Each of them may be set independently of others.
 *
 * Reference implementation of each module is provided.
 *
 * @see LogStorage
 * @see LogStorageStatus
 * @see LogUploadStrategy
 * @see LogUploadConfiguration
 */
@protocol GenericLogCollector

/**
 * Set user implementation of a log storage.
 *
 * storage - user-defined log storage object
 */
- (void)setStorage:(id<LogStorage>)storage;

/**
 * Set user implementation of a log upload strategy.
 *
 * strategy - user-defined log upload strategy object.
 */
- (void)setStrategy:(id<LogUploadStrategy>)strategy;

/**
 * Stops and/or cleanup resources.
 */
- (void)stop;

@end
#endif
