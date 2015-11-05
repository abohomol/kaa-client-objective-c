//
//  DefaultConfigurationTransport.m
//  Kaa
//
//  Created by Anton Bohomol on 9/15/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultConfigurationTransport.h"
#import "ConfigurationCommon.h"
#import "SchemaProcessor.h"
#import "KaaLogging.h"

#define TAG @"DefaultConfigurationTransport >>>"

@interface DefaultConfigurationTransport ()

@property (nonatomic) BOOL resyncOnly;
@property (nonatomic,strong) id<ConfigurationHashContainer> hashContainer;
@property (nonatomic,strong) id<ConfigurationProcessor> configProcessor;
@property (nonatomic,strong) id<SchemaProcessor> schemaProc;

@end

@implementation DefaultConfigurationTransport

- (void)setConfigurationHashContainer:(id<ConfigurationHashContainer>)container {
    self.hashContainer = container;
}

- (void)setConfigurationProcessor:(id<ConfigurationProcessor>)processor {
    self.configProcessor = processor;
}

- (void)setSchemaProcessor:(id<SchemaProcessor>)schemaProcessor {
    self.schemaProc = schemaProcessor;
}

- (ConfigurationSyncRequest *)createConfigurationRequest {
    if (self.clientState && self.hashContainer) {
        EndpointObjectHash *hash = [self.hashContainer getConfigurationHash];
        ConfigurationSyncRequest *request = [[ConfigurationSyncRequest alloc] init];
        if (hash.data) {
            request.configurationHash = [KAAUnion unionWithBranch:KAA_UNION_BYTES_OR_NULL_BRANCH_0 andData:hash.data];
        }
        request.appStateSeqNumber = [self.clientState configSequenceNumber];
        request.resyncOnly = [KAAUnion unionWithBranch:KAA_UNION_BOOLEAN_OR_NULL_BRANCH_0
                                               andData:[NSNumber numberWithBool:self.resyncOnly]];
        return request;
    } else {
        DDLogError(@"%@ Can't create config request due to invalid params: %@, %@", TAG, self.clientState, self.hashContainer);
    }
    return nil;
}

- (void)onConfigurationResponse:(ConfigurationSyncResponse *)response {
    if (!self.clientState || !self.configProcessor) {
        return;
    }
    
    [self.clientState setConfigSequenceNumber:response.appStateSeqNumber];
    if (response.confSchemaBody && response.confSchemaBody.branch == KAA_UNION_BYTES_OR_NULL_BRANCH_0) {
        [self.schemaProc loadSchema:response.confSchemaBody.data];
    }
    if (response.confDeltaBody && response.confDeltaBody.branch == KAA_UNION_BYTES_OR_NULL_BRANCH_0) {
        BOOL fullResync = response.responseStatus == SYNC_RESPONSE_STATUS_RESYNC;
        [self.configProcessor processConfigurationData:response.confDeltaBody.data fullResync:fullResync];
    }
    [self syncAck:response.responseStatus];
    DDLogInfo(@"%@ Processed configuration response", TAG);
}

- (TransportType)getTransportType {
    return TRANSPORT_TYPE_CONFIGURATION;
}

- (void)setResyncOnly:(BOOL)resyncOnly {
    _resyncOnly = resyncOnly;
}

@end
