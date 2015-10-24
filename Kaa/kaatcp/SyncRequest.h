//
//  SyncRequest.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "Sync.h"

/**
 * SyncRequest Class.
 * Extend Sync and set request flag to true.
 */
@interface SyncRequest : Sync

- (instancetype)initWithAvro:(NSData *)avroObject zipped:(BOOL)isZipped encypted:(BOOL)isEncrypted;

@end
