//
//  Commons.h
//  Kaa
//
//  Created by Anton Bohomol on 9/22/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TIME_UNIT_MILLISECONDS,
    TIME_UNIT_SECONDS,
    TIME_UNIT_MINUTES
} TimeUnit;

@interface TimeUtils : NSObject

/**
 * Used to convert TimeUnit values
 * @return converted value or -1 if params were invalid
 */
+ (long)convert:(long)value from:(TimeUnit)fromUnit to:(TimeUnit)toUnit;

@end
