//
//  DefaultKaaPlatformContext.m
//  Kaa
//
//  Created by Anton Bohomol on 10/30/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultKaaPlatformContext.h"
#import "DefaultHttpClient.h"

@interface DefaultKaaPlatformContext ()

@property (nonatomic,strong) KaaClientProperties *props;
@property (nonatomic,strong) id<ExecutorContext> exContext;

@end

@implementation DefaultKaaPlatformContext

- (instancetype)initWith:(KaaClientProperties *)properties andExecutor:(id<ExecutorContext>)executor {
    self = [super init];
    if (self) {
        _props = properties;
        _exContext = executor;
    }
    return self;
}

- (AbstractHttpClient *)createHttpClient:(NSString *)url
                              privateKey:(SecKeyRef)privateK
                               publicKey:(SecKeyRef)publicK
                               remoteKey:(NSData *)remoteK {
    return [[DefaultHttpClient alloc] initWith:url privateKey:privateK publicKey:publicK remoteKey:remoteK];
}

- (id<KAABase64>)getBase64 {
    return [[CommonBase64 alloc] init];
}

- (ConnectivityChecker *)createConnectivityChecker {
    return [[ConnectivityChecker alloc] init];
}

- (id<ExecutorContext>)getExecutorContext {
    return _exContext;
}

- (KaaClientProperties *)getProperties {
    return _props;
}

@end
