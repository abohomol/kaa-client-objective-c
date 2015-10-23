//
//  Kaa.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaaDataChannel.h"
#import "KaaTransport.h"
#import "KaaClient.h"
#import "KaaClientPlatformContext.h"
#import "KaaClientStateDelegate.h"

//TODO: remove, because it's used only to compile headers below
#import "GenericKaaClient.h"
#import "KaaChannelManager.h"
#import "ConfigurationCommon.h"
#import "EndpointRegistrationProcessor.h"
#import "EventManger.h"
#import "BaseEventFamily.h"
#import "ProfileManager.h"
#import "NotificationManager.h"
#import "UserTransport.h"
#import "BootstrapTransport.h"
#import "BootstrapManager.h"
#import "ConfigurationPersistenceManager.h"
#import "RedirectionTransport.h"
#import "MetaDataTransport.h"
#import "KaaClientStateDelegate.h"
#import "SchemaProcessor.h"
#import "ConfigurationTransport.h"
#import "LogCollector.h"
#import "Constants.h"
#import "CommonEPConstants.h"

/**
 * Creates new Kaa client based on platform context and optional state delegate.
 */
@interface Kaa : NSObject

+ (id<KaaClient>)clientWithContext:(id<KaaClientPlatformContext>)context andStateDelegate:(id<KaaClientStateDelegate>)delegate;

+ (id<KaaClient>)clientWithContext:(id<KaaClientPlatformContext>)context;

@end