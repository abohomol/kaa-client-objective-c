//
//  DefaultLogTransport.m
//  Kaa
//
//  Created by Anton Bohomol on 9/15/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultLogTransport.h"

#define TAG @"DefaultLogTransport >>>"

@interface DefaultLogTransport ()

@property (nonatomic,strong) id<LogProcessor> processor;

@end

@implementation DefaultLogTransport

- (void)setLogProcessor:(id<LogProcessor>)processor {
    self.processor = processor;
}

- (LogSyncRequest *)createLogRequest {
    if (self.processor) {
        LogSyncRequest *request = [[LogSyncRequest alloc] init];
        [self.processor fillSyncRequest:request];
        return request;
    } else {
        DDLogError(@"%@ Can't create request. LogProcessor is nil", TAG);
    }
    return nil;
}

- (void)onLogResponse:(LogSyncResponse *)response {
    if (self.processor) {
        @try {
            [self.processor onLogResponse:response];
        }
        @catch (NSException *exception) {
            DDLogError(@"%@ Failed to process Log response: %@, reason: %@.", TAG, exception.name, exception.reason);
        }
    } else {
        DDLogError(@"%@ Can't process response. LogProcessor is nil", TAG);
    }
}

- (TransportType)getTransportType {
    return TRANSPORT_TYPE_LOGGING;
}

@end
