//
//  DefaultOperationDataProcessor.h
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KaaDataDemultiplexer.h"
#import "KaaDataMultiplexer.h"
#import "RedirectionTransport.h"
#import "MetaDataTransport.h"
#import "ConfigurationTransport.h"
#import "EventTransport.h"
#import "NotificationTransport.h"
#import "ProfileTransport.h"
#import "UserTransport.h"
#import "LogTransport.h"

@interface DefaultOperationDataProcessor : NSObject <KaaDataDemultiplexer,KaaDataMultiplexer>

- (void)setRedirectionTransport:(id<RedirectionTransport>)transport;
- (void)setMetaDataTransport:(id<MetaDataTransport>)transport;
- (void)setConfigurationTransport:(id<ConfigurationTransport>)transport;
- (void)setEventTransport:(id<EventTransport>)transport;
- (void)setNotificationTransport:(id<NotificationTransport>)transport;
- (void)setProfileTransport:(id<ProfileTransport>)transport;
- (void)setUserTransport:(id<UserTransport>)transport;
- (void)setLogTransport:(id<LogTransport>)transport;

@end
