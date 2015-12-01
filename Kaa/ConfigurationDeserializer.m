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

#import "ConfigurationDeserializer.h"
#import "AvroBytesConverter.h"
#import "ConfigurationCommon.h"

@implementation ConfigurationDeserializer {
    AvroBytesConverter *converter;
    id<ExecutorContext> executorContext;
}

- (instancetype)initWithExecutorContext:(id<ExecutorContext>)context {
    self = [super init];
    if (self) {
        converter = [[AvroBytesConverter alloc] init];
        executorContext = context;
    }
    return self;
}

- (void)notify:(NSSet *)configurationDelegates withData:(NSData *)configurationData {
    __block KAADummyConfiguration *configuration = [self fromBytes:configurationData];
    for (id<ConfigurationDelegate> delegate in configurationDelegates) {
        [[executorContext getCallbackExecutor] addOperationWithBlock:^{
            [delegate onConfigurationUpdate:configuration];
        }];
    }
}

- (KAADummyConfiguration *)fromBytes:(NSData *)bytes {
    return [converter fromBytes:bytes object:[KAADummyConfiguration new]];
}

@end
