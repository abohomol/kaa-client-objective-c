//
//  TransactionId.h
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Class representing unique transaction id for transactions initiated using <Transactable>
 * Note: default constructor will initialize TransactionId with random id.
 */
@interface TransactionId : NSObject <NSCopying>

/**
 * Constructs object with predefined id.
 */
- (instancetype)initWithStringId:(NSString *)stringId;

/**
 * Copy constructor. Copies id from other TransactionId object.
 */
- (instancetype)initWithTransactionId:(TransactionId *)transactionId;

@end
