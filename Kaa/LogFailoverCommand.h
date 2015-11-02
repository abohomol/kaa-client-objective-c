//
//  LogFailoverCommand.h
//  Kaa
//
//  Created by Anton Bohomol on 7/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_LogFailoverCommand_h
#define Kaa_LogFailoverCommand_h

#import <Foundation/Foundation.h>
#import "AccessPointCommand.h"

@protocol LogFailoverCommand <AccessPointCommand>

- (void)retryLogUpload;
- (void)retryLogUpload:(int32_t)delay;

@end

#endif
