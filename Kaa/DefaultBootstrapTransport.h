//
//  DefaultBootstrapTransport.h
//  Kaa
//
//  Created by Anton Bohomol on 9/9/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AbstractKaaTransport.h"
#import "BootstrapTransport.h"

@interface DefaultBootstrapTransport : AbstractKaaTransport <BootstrapTransport>

- (instancetype)initWithToken:(NSString *)sdkToken;

@end
