//
//  SimpleHttpClient.h
//  Kaa
//
//  Created by Anton Bohomol on 9/22/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "AbstractHttpClient.h"

@interface DefaultHttpClient : AbstractHttpClient

- (instancetype)initWith:(NSString *)url
              privateKey:(SecKeyRef)privateK
               publicKey:(SecKeyRef)publicK
               remoteKey:(NSData *)remoteK;

@end
