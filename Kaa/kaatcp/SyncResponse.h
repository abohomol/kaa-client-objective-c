//
//  SyncResponse.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "Sync.h"

/**
 * SyncResponse Class.
 * Extend Sync and set request flag to false.
 */
@interface SyncResponse : Sync

- (instancetype)initWithAvro:(NSData *)avroObject zipped:(BOOL)isZipped encypted:(BOOL)isEncrypted;

@end
