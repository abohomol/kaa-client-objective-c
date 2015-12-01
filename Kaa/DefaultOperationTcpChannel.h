/*
 * Copyright 2014-2015 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "KaaDataChannel.h"
#import "KaaClientState.h"
#import "FailoverManager.h"
#import "KeyPair.h"
#import "KAASocket.h"

@interface DefaultOperationTcpChannel : NSObject <KaaDataChannel>

- (KAASocket *)createSocket;
- (void)setServer:(id<TransportConnectionInfo>)server withKeyPair:(KeyPair *) sendedKeyPair;
- (instancetype)initWithClientState:(id<KaaClientState>)state andFailoverMgr:(id<FailoverManager>)failoverMgr;
- (NSOperationQueue *)createExecutor;

@end
