//
//  DefaultRedirectionTransportTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 22.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <XCTest/XCTest.h>
#import "DefaultRedirectionTransport.h"

@interface DefaultRedirectionTransportTest : XCTestCase

@end

@implementation DefaultRedirectionTransportTest

- (void)testOnRedirectionReponse {
    id <BootstrapManager> manager = mockProtocol(@protocol(BootstrapManager));
    id <RedirectionTransport> transport = [[DefaultRedirectionTransport alloc] init];
    RedirectSyncResponse *response = [[RedirectSyncResponse alloc] init];
    [transport onRedirectionResponse:response];
    [transport setBootstrapManager:manager];
    [transport onRedirectionResponse:response];
    [response setAccessPointId:1];
    [transport onRedirectionResponse:response];
    [response setAccessPointId:2];
    [transport onRedirectionResponse:response];
    
    [verifyCount(manager, times(1)) useNextOperationsServerByAccessPointId:1];
}

@end
