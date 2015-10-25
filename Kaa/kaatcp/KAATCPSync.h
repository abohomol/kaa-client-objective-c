//
//  Sync.h
//  Kaa
//
//  Created by Anton Bohomol on 10/24/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAATCPKaaSync.h"

/**
 * Sync message Class.
 * The SYNC message is used as intermediate class for decoding messages
 * SyncRequest,SyncResponse
 *
 *
 * Sync message extend KaaSync with  Payload Avro object.
 *
 *  Payload Avro object depend on Flags object can be zipped and than encrypted with AES SessionKey
 *  exchanged with the CONNECT message.
 */
@interface KAATCPSync : KAATCPKaaSync

@property (nonatomic,strong) NSData *avroObject; //Avro object byte representation

- (instancetype)initWithAvro:(NSData *)avroObject request:(BOOL)isRequest zipped:(BOOL)isZipped encypted:(BOOL)isEncrypted;

- (void)decodeAvroObject:(NSInputStream *)input;

@end
