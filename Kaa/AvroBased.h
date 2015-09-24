//
//  AvroBased.h
//  Kaa
//
//  Created by Anton Bohomol on 7/2/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvroUtils.h"

@interface AvroBased : NSObject <Avro>

@property(nonatomic,strong,readonly) AvroUtils *utils;

@end
