//
//  SyncRequest.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATCPSync.h"

/**
 * SyncRequest Class.
 * Extend Sync and set request flag to true.
 */
@interface KAATCPSyncRequest : KAATCPSync

- (instancetype)initWithAvro:(NSData *)avroObject zipped:(BOOL)isZipped encypted:(BOOL)isEncrypted;

@end
