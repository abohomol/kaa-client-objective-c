//
//  DefaultOperationHttpChannel.m
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultOperationHttpChannel.h"
#import "HttpRequestCreator.h"
#import "KaaLogging.h"
#import "KaaExceptions.h"

#define TAG         @"DefaultOperationHttpChannel >>>"
#define CHANNEL_ID  @"default_operations_http_channel"
#define URL_SUFFIX  @"/EP/Sync"

@interface OperationRunner : NSOperation

@property (nonatomic,weak) DefaultOperationHttpChannel *opChannel;
@property (nonatomic,strong) NSDictionary *opTypes;

- (instancetype)initWithChannel:(DefaultOperationHttpChannel *)channel andTypes:(NSDictionary *)types;

@end

@interface DefaultOperationHttpChannel ()

@property (nonatomic,strong) NSDictionary *SUPPORTED_TYPES; //<TransportType,ChannelDirection> as key-value

- (void)processTypes:(NSDictionary *)types;

@end

@implementation DefaultOperationHttpChannel

- (instancetype)initWithClient:(AbstractKaaClient *)client state:(id<KaaClientState>)state
               failoverManager:(id<FailoverManager>)manager {
    self = [super initWithClient:client state:state failoverManager:manager];
    if (self) {
        self.SUPPORTED_TYPES = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithInt:CHANNEL_DIRECTION_UP],
                                [NSNumber numberWithInt:TRANSPORT_TYPE_EVENT],
                                [NSNumber numberWithInt:CHANNEL_DIRECTION_UP],
                                [NSNumber numberWithInt:TRANSPORT_TYPE_LOGGING], nil];
    }
    return self;
}

- (void)processTypes:(NSDictionary *)types {
    NSData *requestBodyRaw = [[self getMultiplexer] compileRequest:types];
    NSData *decodedResponse = nil;
    @synchronized(self) {
        MessageEncoderDecoder *encoderDecoder = [[self getHttpClient] getEncoderDecoder];
        NSDictionary *requestEntity = [HttpRequestCreator createOperationHttpRequest:requestBodyRaw
                                                                  withEncoderDecoder:encoderDecoder];
        NSData *responseDataRaw = [[self getHttpClient] executeHttpRequest:@""
                                                                    entity:requestEntity
                                                            verifyResponse:NO];
        decodedResponse = [encoderDecoder decodeData:responseDataRaw];
    }
    [[self getDemultiplexer] processResponse:decodedResponse];
}

- (NSString *)getId {
    return CHANNEL_ID;
}

- (ServerType)getServerType {
    return SERVER_OPERATIONS;
}

- (NSDictionary *)getSupportedTransportTypes {
    return self.SUPPORTED_TYPES;
}

- (NSOperation *)createChannelRunner:(NSDictionary *)types {
    return [[OperationRunner alloc] initWithChannel:self andTypes:types];
}

- (NSString *)getURLSuffix {
    return URL_SUFFIX;
}

@end

@implementation OperationRunner

- (instancetype)initWithChannel:(DefaultOperationHttpChannel *)channel andTypes:(NSDictionary *)types {
    self = [super init];
    if (self) {
        self.opChannel = channel;
        self.opTypes = types;
    }
    return self;
}

- (void)main {
    if (self.isCancelled || self.isFinished) {
        return;
    }
    
    @try {
        [self.opChannel processTypes:self.opTypes];
        [self.opChannel connectionStateChanged:NO];
    }
    @catch (NSException *ex) {
        DDLogError(@"%@ Failed to receive response from the operation: %@, reason: %@", TAG, ex.name, ex.reason);
        //TODO replace fckg strings with constants
        if ([ex.name isEqualToString:KaaTransportException]) {
            [self.opChannel connectionStateChanged:YES withStatus:[ex.reason intValue]];

        } else {
            [self.opChannel connectionStateChanged:YES];
        }
    }
}

@end