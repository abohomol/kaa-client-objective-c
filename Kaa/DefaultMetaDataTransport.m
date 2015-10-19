//
//  DefaultMetaDataTransport.m
//  Kaa
//
//  Created by Anton Bohomol on 9/11/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultMetaDataTransport.h"
#import "KaaLogging.h"

#define TAG @"DefaultMetaDataTransport >>>"

@interface DefaultMetaDataTransport ()

@property (nonatomic,strong) KaaClientProperties *properties;
@property (nonatomic,strong) id<KaaClientState> state;
@property (nonatomic,strong) EndpointObjectHash *publicKeyHash;
@property (nonatomic) NSInteger timeout;

@end

@implementation DefaultMetaDataTransport

- (SyncRequestMetaData *)createMetaDataRequest {
    if (!self.state || !self.properties || !self.publicKeyHash) {
        DDLogError(@"%@ Unable to create MetaDataRequest - params not completed", TAG);
        return nil;
    }
    
    SyncRequestMetaData *request = [[SyncRequestMetaData alloc] init];
    request.sdkToken = [self.properties sdkToken];
    request.endpointPublicKeyHash = [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_0
                                                      andData:self.publicKeyHash.data];
    
    request.profileHash = [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_0
                                            andData:[self.state profileHash].data];
    
    request.timeout = [KAAUnion unionWithBranch:KAA_UNION_LONG_OR_NULL_BRANCH_0
                                        andData:[NSNumber numberWithLong:self.timeout]];
    return request;
}

- (void)setClientProperties:(KaaClientProperties *)properties {
    _properties = properties;
}

- (void)setClientState:(id<KaaClientState>)state {
    _state = state;
}

- (void)setEndpointPublicKeyhash:(EndpointObjectHash *)hash {
    _publicKeyHash = hash;
}

- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
}

@end
