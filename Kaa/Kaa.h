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

//TODO: remove, because used to make other headers get compiled
#import "GenericKaaClient.h"
#import "KaaChannelManager.h"
#import "ConfigurationCommon.h"
#import "EndpointRegistrationProcessor.h"
#import "EventManger.h"
#import "BaseEventFamily.h"
#import "KaaClient.h"
#import "ProfileManager.h"
#import "NotificationManager.h"
#import "UserTransport.h"
#import "BootstrapTransport.h"
#import "BootstrapManager.h"
#import "ConfigurationPersistenceManager.h"
#import "KaaClientPlatformContext.h"
#import "RedirectionTransport.h"
#import "MetaDataTransport.h"
#import "KaaClientStateDelegate.h"
#import "SchemaProcessor.h"
#import "ConfigurationTransport.h"
#import "LogCollector.h"
#import "Constants.h"
#import "CommonEPConstants.h"

@interface Kaa : NSObject

@end