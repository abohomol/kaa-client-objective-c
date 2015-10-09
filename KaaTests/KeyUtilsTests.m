//
//  KeyUtilsTests.m
//  Kaa
//
//  Created by Anton Bohomol on 10/9/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KeyUtils.h"

@interface KeyUtilsTests : XCTestCase

@property (nonatomic,strong) NSData *remoteKeyTag;

@end

@implementation KeyUtilsTests

- (void)setUp {
    [super setUp];
    int randomInt = arc4random();
    self.remoteKeyTag = [NSData dataWithBytes:&randomInt length:sizeof(randomInt)];
}

- (void)testGenerateKeyPair {
    KeyPair *defaultKeyPair = [KeyUtils generateKeyPair];
    
    XCTAssertNotNil(defaultKeyPair);
    XCTAssertTrue([defaultKeyPair getPrivateKeyRef] != NULL);
    XCTAssertTrue([defaultKeyPair getPublicKeyRef] != NULL);
    
    XCTAssertTrue([KeyUtils getPrivateKeyRef] != NULL);
    XCTAssertTrue([KeyUtils getPublicKeyRef] != NULL);
    
    XCTAssertNotNil([KeyUtils getPublicKey]);
    XCTAssertTrue([[KeyUtils getPublicKey] length] > 0);
    
    [KeyUtils deleteExistingKeyPair];
    
    XCTAssertTrue([KeyUtils getPrivateKeyRef] == NULL);
    XCTAssertTrue([KeyUtils getPublicKeyRef] == NULL);
}

- (void)testStoreAndRemoveRemoteKey {
    [KeyUtils generateKeyPair];
    
    NSData *remoteKey = [KeyUtils getPublicKey];
    XCTAssertNotNil(remoteKey);
    XCTAssertTrue([remoteKey length] > 0);
    
    //store
    SecKeyRef remoteKeyRef = [KeyUtils storePublicKey:remoteKey withTag:self.remoteKeyTag];
    XCTAssertTrue(remoteKeyRef != NULL);
    
    //retrieve
    NSData *restoredRemoteKey = [KeyUtils getPublicKeyByTag:self.remoteKeyTag];
    XCTAssertNotNil(restoredRemoteKey);
    XCTAssertTrue([remoteKey isEqualToData:restoredRemoteKey]);
    
    //remove
    [KeyUtils removeKeyByTag:self.remoteKeyTag];
    XCTAssertNil([KeyUtils getPublicKeyByTag:self.remoteKeyTag]);
    
    [KeyUtils deleteExistingKeyPair];
}

@end
