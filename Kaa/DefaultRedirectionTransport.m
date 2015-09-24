//
//  DefaultRedirectionTransport.m
//  Kaa
//
//  Created by Anton Bohomol on 9/15/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultRedirectionTransport.h"

@interface DefaultRedirectionTransport ()

@property (nonatomic,strong) id<BootstrapManager> manager;

@end

@implementation DefaultRedirectionTransport

- (void)setBootstrapManager:(id<BootstrapManager>)manager {
    self.manager = manager;
}

- (void)onRedirectionResponse:(RedirectSyncResponse *)response {
    if (response && self.manager) {
        [self.manager useNextOperationsServerByAccessPointId:response.accessPointId];
    }
}

@end
