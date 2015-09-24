//
//  TransportContext.m
//  Kaa
//
//  Created by Anton Bohomol on 9/9/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "TransportContext.h"

@interface TransportContext ()

@property (nonatomic,strong) id<MetaDataTransport> mdTransport;
@property (nonatomic,strong) id<BootstrapTransport> bootstrapTransport;
@property (nonatomic,strong) id<ProfileTransport> profileTransport;
@property (nonatomic,strong) id<EventTransport> eventTransport;
@property (nonatomic,strong) id<NotificationTransport> notificationTransport;
@property (nonatomic,strong) id<ConfigurationTransport> configurationTransport;
@property (nonatomic,strong) id<UserTransport> userTransport;
@property (nonatomic,strong) id<RedirectionTransport> redirectionTransport;
@property (nonatomic,strong) id<LogTransport> logTransport;

@end

@implementation TransportContext

- (instancetype)initWithMetaDataTransport:(id<MetaDataTransport>)metaData
                       bootstrapTransport:(id<BootstrapTransport>)bootstrap
                         profileTransport:(id<ProfileTransport>)profile
                           eventTransport:(id<EventTransport>)event
                    notificationTransport:(id<NotificationTransport>)notification
                   configurationTransport:(id<ConfigurationTransport>)configuration
                            userTransport:(id<UserTransport>)user
                     redirectionTransport:(id<RedirectionTransport>)redirection
                             logTransport:(id<LogTransport>)log {
    self = [super init];
    if (self) {
        self.mdTransport = metaData;
        self.bootstrapTransport = bootstrap;
        self.profileTransport = profile;
        self.eventTransport = event;
        self.notificationTransport = notification;
        self.configurationTransport = configuration;
        self.userTransport = user;
        self.redirectionTransport = redirection;
        self.logTransport = log;
    }
    return self;
}

- (id<MetaDataTransport>)getMetaDataTransport {
    return self.mdTransport;
}

- (id<BootstrapTransport>)getBootstrapTransport {
    return self.bootstrapTransport;
}

- (id<ProfileTransport>)getProfileTransport {
    return self.profileTransport;
}

- (id<EventTransport>)getEventTransport {
    return self.eventTransport;
}

- (id<NotificationTransport>)getNotificationTransport {
    return self.notificationTransport;
}

- (id<ConfigurationTransport>)getConfigurationTransport {
    return self.configurationTransport;
}

- (id<UserTransport>)getUserTransport {
    return self.userTransport;
}

- (id<RedirectionTransport>)getRedirectionTransport {
    return self.redirectionTransport;
}

- (id<LogTransport>)getLogTransport {
    return self.logTransport;
}

- (void)initTransportsWithChannelManager:(id<KaaChannelManager>)manager andState:(id<KaaClientState>)state {
    NSArray *kaaTransports = [NSArray arrayWithObjects:
                      self.bootstrapTransport, self.profileTransport,
                      self.eventTransport, self.notificationTransport,
                      self.configurationTransport, self.userTransport, self.logTransport, nil];
    for (id<KaaTransport> transport in kaaTransports) {
        [transport setChannelManager:manager];
        [transport setClientState:state];
    }
}

@end
