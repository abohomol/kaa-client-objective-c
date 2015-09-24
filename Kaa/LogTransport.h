//
//  LogTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 7/16/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_LogTransport_h
#define Kaa_LogTransport_h

#import <Foundation/Foundation.h>
#import "KaaTransport.h"
#import "EndpointGen.h"

/**
 * Processes the Logging requests and responses.
 */
@protocol LogProcessor

/**
 * Fills the given request with the latest Logging state.
 */
- (void)fillSyncRequest:(LogSyncRequest *)request;

/**
* Updates the state using response from the server.
*/
- (void)onLogResponse:(LogSyncResponse *)response;

@end

/**
 * <KaaTransport> for the Logging service.
 * Used for sending logs to the remote server.
 */
@protocol LogTransport <KaaTransport>

/**
 * Creates the Log request that consists of current log records.
 */
- (LogSyncRequest *)createLogRequest;

/**
 * Updates the state of the Log collector according to the given response.
 */
- (void)onLogResponse:(LogSyncResponse *)response;

/**
 * Sets the given Log processor.
 */
- (void)setLogProcessor:(id<LogProcessor>)processor;

@end

#endif
