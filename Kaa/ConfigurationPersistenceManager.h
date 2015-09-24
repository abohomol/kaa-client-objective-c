//
//  ConfigurationPersistenceManager.h
//  Kaa
//
//  Created by Anton Bohomol on 9/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_ConfigurationPersistenceManager_h
#define Kaa_ConfigurationPersistenceManager_h

#import <Foundation/Foundation.h>
#import "ConfigurationStorage.h"

/**
 * Manager for saving and loading of configuration data
 *
 * Provide ConfigurationStorage implementation instance to store merged
 * configuration when configuration deltas are received from Operation server.
 * Once ConfigurationPersistenceManager#setConfigurationStorage(ConfigurationStorage)
 * is called ConfigurationStorage#loadConfiguration() will be invoked to
 * load persisted configuration.
 *
 * @see ConfigurationStorage
 */
@protocol ConfigurationPersistenceManager

/**
 * Provide storage object which is able to persist encoded configuration data.
 */
- (void)setConfigurationStorage:(id<ConfigurationStorage>)storage;

@end

#endif
