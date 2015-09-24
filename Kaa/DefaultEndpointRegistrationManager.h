//
//  DefaultEndpointRegistrationManager.h
//  Kaa
//
//  Created by Anton Bohomol on 8/28/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EndpointRegistrationManager.h"
#import "EndpointRegistrationProcessor.h"
#import "KaaClientState.h"
#import "ExecutorContext.h"
#import "ProfileTransport.h"
#import "UserTransport.h"

@interface DefaultEndpointRegistrationManager : NSObject <EndpointRegistrationManager,EndpointRegistrationProcessor>

- (instancetype)initWith:(id<KaaClientState>)state
         executorContext:(id<ExecutorContext>)context
           userTransport:(id<UserTransport>)userTransport
        profileTransport:(id<ProfileTransport>)profileTransport;

- (void)updateEndpointAccessToken:(NSString *)token;

- (NSString *)refreshEndpointAccessToken;

/**
 * @return dictionary of attached endpoints <EndpointAccessToken, EndpointKeyHash> as key-value;
 */
- (NSDictionary *)getAttachedEndpointList;

@end
