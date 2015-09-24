//
//  TransportContext.h
//  Kaa
//
//  Created by Anton Bohomol on 9/9/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetaDataTransport.h"
#import "BootstrapTransport.h"
#import "ProfileTransport.h"
#import "EventTransport.h"
#import "NotificationTransport.h"
#import "ConfigurationTransport.h"
#import "UserTransport.h"
#import "RedirectionTransport.h"
#import "LogTransport.h"
#import "KaaChannelManager.h"
#import "KaaClientState.h"

@interface TransportContext : NSObject

- (instancetype)initWithMetaDataTransport:(id<MetaDataTransport>)metaData
                       bootstrapTransport:(id<BootstrapTransport>)bootstrap
                         profileTransport:(id<ProfileTransport>)profile
                           eventTransport:(id<EventTransport>)event
                    notificationTransport:(id<NotificationTransport>)notification
                   configurationTransport:(id<ConfigurationTransport>)configuration
                            userTransport:(id<UserTransport>)user
                     redirectionTransport:(id<RedirectionTransport>)redirection
                             logTransport:(id<LogTransport>)log;

- (id<MetaDataTransport>)getMetaDataTransport;

- (id<BootstrapTransport>)getBootstrapTransport;

- (id<ProfileTransport>)getProfileTransport;

- (id<EventTransport>)getEventTransport;

- (id<NotificationTransport>)getNotificationTransport;

- (id<ConfigurationTransport>)getConfigurationTransport;

- (id<UserTransport>)getUserTransport;

- (id<RedirectionTransport>)getRedirectionTransport;

- (id<LogTransport>)getLogTransport;

- (void)initTransportsWithChannelManager:(id<KaaChannelManager>)manager andState:(id<KaaClientState>)state;

@end
