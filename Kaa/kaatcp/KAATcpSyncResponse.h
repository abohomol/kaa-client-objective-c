//
//  SyncResponse.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATcpSync.h"

/**
 * SyncResponse Class.
 * Extend Sync and set request flag to false.
 */
@interface KAATcpSyncResponse : KAATcpSync

- (instancetype)initWithAvro:(NSData *)avroObject zipped:(BOOL)isZipped encypted:(BOOL)isEncrypted;

@end
