//
//  StorageSizeWithTimeLimitLogUploadStrategy.h
//  Kaa
//
//  Created by Aleksey Gutyro on 28.09.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DefaultLogUploadStrategy.h"
#import "TimeCommons.h"

@interface StorageSizeWithTimeLimitLogUploadStrategy : DefaultLogUploadStrategy

@property (nonatomic) int64_t lastUploadTime;

@end
