//
//  KAASocket.m
//  Kaa
//
//  Created by Anton Bohomol on 10/25/15.
//  Copyright © 2015 CYBERVISION INC. All rights reserved.
//

#import "KAASocket.h"

@interface KAASocket ()

@property (nonatomic,strong) NSString *host;
@property (nonatomic) int port;

@end

@implementation KAASocket

+ (instancetype)socketWithHost:(NSString *)host andPort:(int)port {
    KAASocket *socket = [[KAASocket alloc] init];
    socket.host = host;
    socket.port = port;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &readStream, &writeStream);
    socket.input = (__bridge NSInputStream *)readStream;
    socket.output = (__bridge NSOutputStream *)writeStream;
    return socket;
}

- (void)open {
    [self.input open];
    [self.output open];
}

- (void)close {
    if (self.input) {
        [self.input close];
    }
    if (self.output) {
        [self.output close];
    }
}

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[KAASocket class]]) {
        KAASocket *other = (KAASocket *)object;
        if ([self.host isEqualToString:other.host] && self.port == other.port) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"KAASocket [host:%@ port:%i]", self.host, self.port];
}

@end
