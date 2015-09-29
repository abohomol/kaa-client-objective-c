//
//  ConfigurationStorage.h
//  Kaa
//
//  Created by Anton Bohomol on 7/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_ConfigurationStorage_h
#define Kaa_ConfigurationStorage_h

#import <Foundation/Foundation.h>

@protocol ConfigurationStorage

- (void)saveConfiguration:(NSData *)buffer;
- (void)clearConfiguration;
- (NSData *)loadConfiguration;

@end

#endif
