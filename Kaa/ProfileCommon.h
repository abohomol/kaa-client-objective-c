/*
 * Copyright 2014 CyberVision, Inc.
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
#import "EndpointGen.h"
#import "KAADummyProfile.h"

@protocol ProfileContainer

- (KAADummyProfile *)getProfile;

@end

/**
 * This class serialize entity defined in profile schema and returned by profile container.
 * This class have a special behavior in case of default schema and serialize default profile
 * disregarding empty profile container.
 *
 * This implementation is auto-generated. Please modify corresponding template file.
 */
@interface ProfileSerializer : NSObject

/**
 * Retrieves serialized profile.
 */
- (NSData *)toBytes:(id<ProfileContainer>)container;

- (BOOL)isDefault;

@end