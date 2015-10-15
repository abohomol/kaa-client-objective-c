//
//  DefaultLogUploadStrategyTest.m
//  Kaa
//
//  Created by Aleksey Gutyro on 15.10.15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LogStorage.h"
#import "DefaultLogUploadStrategy.h"

@interface TestLogStorageStatus : NSObject <LogStorageStatus>

@property (nonatomic) NSInteger consumedVolume;
@property (nonatomic) NSInteger recordCount;

@end

@implementation TestLogStorageStatus

- (instancetype)initWithConsumedVolume:(NSInteger)consumedVolume andRecordCount:(NSInteger)recordCount {
    self = [super init];
    if (self) {
        self.consumedVolume = consumedVolume;
        self.recordCount = recordCount;
    }
    return self;
}

- (NSInteger)getConsumedVolume {
    return self.consumedVolume;
}

- (NSInteger)getRecordCount {
    return self.recordCount;
}

@end


@interface DefaultLogUploadStrategyTest : XCTestCase

@end

@implementation DefaultLogUploadStrategyTest

- (void) testNOOPDecision {
    DefaultLogUploadStrategy *strategy = [[DefaultLogUploadStrategy alloc] initWithDefaults];
    [strategy setBatchSize:20];
    [strategy setVolumeThreshold:60];
    [strategy setTimeout:300];
    TestLogStorageStatus *status = [[TestLogStorageStatus alloc] initWithConsumedVolume:30 andRecordCount:3];
    
    XCTAssertEqual(LOG_UPLOAD_STRATEGY_DECISION_NOOP, [strategy isUploadNeeded:status]);
}

- (void) testUpdateDecision {
    DefaultLogUploadStrategy *strategy = [[DefaultLogUploadStrategy alloc] initWithDefaults];
    [strategy setBatchSize:20];
    [strategy setVolumeThreshold:60];
    [strategy setTimeout:300];
    TestLogStorageStatus *status = [[TestLogStorageStatus alloc] initWithConsumedVolume:60 andRecordCount:3];
    
    XCTAssertEqual(LOG_UPLOAD_STRATEGY_DECISION_UPLOAD, [strategy isUploadNeeded:status]);
    
    status = [[TestLogStorageStatus alloc] initWithConsumedVolume:70 andRecordCount:3];
    XCTAssertEqual(LOG_UPLOAD_STRATEGY_DECISION_UPLOAD, [strategy isUploadNeeded:status]);
}

@end
