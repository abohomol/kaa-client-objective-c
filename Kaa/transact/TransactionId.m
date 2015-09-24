//
//  TransactionId.m
//  Kaa
//
//  Created by Anton Bohomol on 8/25/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "TransactionId.h"
#import "UUID.h"

@interface TransactionId ()

@property (nonatomic,strong) NSString *identifier;

@end

@implementation TransactionId

- (instancetype)init {
    return [self initWithStringId:[UUID randomUUID]];
}

- (instancetype)initWithStringId:(NSString *)stringId {
    self = [super init];
    if (self) {
        self.identifier = stringId;
    }
    return self;
}

- (instancetype)initWithTransactionId:(TransactionId *)transactionId {
    return [self initWithStringId:transactionId.identifier];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithStringId:self.identifier];
}

- (NSUInteger)hash {
    int prime = 31;
    return prime + [self.identifier hash];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TransactionId class]]) {
        TransactionId *other = (TransactionId *)object;
        if ([self.identifier isEqualToString:other.identifier]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)description {
    return self.identifier;
}

@end
