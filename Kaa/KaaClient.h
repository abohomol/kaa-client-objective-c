/*
 * Copyright 2014 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef Kaa_KaaClient_h
#define Kaa_KaaClient_h

#import <Foundation/Foundation.h>
#import "GenericKaaClient.h"
#import "KAALog.h"
#import "KAAConfiguration.h"

/**
 * Base interface to operate with Kaa library.
 *
 * @see EventFamilyFactory
 * @see EndpointRegistrationManager
 * @see EventListenersResolver
 * @see KaaChannelManager
 * @see PublicKey
 * @see PrivateKey
 * @see KaaDataChannel
 */
@protocol KaaClient <GenericKaaClient>

/**
 * Adds new log record to local storage.
 *
 * @param record - new log record object
 */
- (void)addLogRecord:(KAALog *)record;

/**
 * Returns latest configuration.
 *
 * @return configuration
 */
- (KAAConfiguration *)getConfiguration;

@end

#endif
