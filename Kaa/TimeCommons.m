//
//  Header.h
//  Kaa
//
//  Created by Anton Bohomol on 9/23/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "TimeCommons.h"

#define SEC_TO_MIN(x)   (long)((double)(x) / 60.0)
#define SEC_TO_MS(x)    (long)((x) * 1000)

#define MS_TO_SEC(x)    (long)((double)(x) / 1000)
#define MS_TO_MIN(x)    (long)(SEC_TO_MIN(MS_TO_SEC(x)))

#define MIN_TO_SEC(x)   (long)((x) * 60)
#define MIN_TO_MS(x)    (long)(SEC_TO_MS(MIN_TO_SEC(x)))

@implementation TimeUtils

+ (long)convert:(long)value from:(TimeUnit)fromUnit to:(TimeUnit)toUnit {
    long result = -1;
    if (value < 0) {
        return -1;
    }
    
    if (fromUnit == toUnit) {
        
        result = value;
        
    } else if (fromUnit == TIME_UNIT_MILLISECONDS) {
        
        if (toUnit == TIME_UNIT_SECONDS) {
            result = MS_TO_SEC(value);
        } else if (toUnit == TIME_UNIT_MINUTES) {
            result = MS_TO_MIN(value);
        }
        
    } else if (fromUnit == TIME_UNIT_SECONDS) {
        
        if (toUnit == TIME_UNIT_MILLISECONDS) {
            result = SEC_TO_MS(value);
        } else if (toUnit == TIME_UNIT_MINUTES) {
            result = SEC_TO_MIN(value);
        }
        
    } else if (fromUnit == TIME_UNIT_MINUTES) {
        
        if (toUnit == TIME_UNIT_MILLISECONDS) {
            result = MIN_TO_MS(value);
        } else if (toUnit == TIME_UNIT_SECONDS) {
            result = MIN_TO_SEC(value);
        }
        
    }
    return result;
}

@end
