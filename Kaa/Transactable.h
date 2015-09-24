//
//  Transactable.h
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_Transactable_h
#define Kaa_Transactable_h

#import <Foundation/Foundation.h>
#import "TransactionId.h"

/**
 * General interface for transaction managers.
 */
@protocol Transactable

/**
 * Create new transaction entry.
 *
 * @return TransactionId - unique id of created transaction.
 */
- (TransactionId *)beginTransaction;

/**
 * Submit the transaction<br>
 *
 * @param trxId - the unique identifier of the transaction which should be submitted.
 */
- (void)commit:(TransactionId *)trxId;

/**
 * Revert the transaction
 *
 * @param trxId The unique identifier of the transaction which should be reverted.
 */
- (void)rollback:(TransactionId *)trxId;

@end

#endif
