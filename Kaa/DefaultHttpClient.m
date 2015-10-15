//
//  SimpleHttpClient.m
//  Kaa
//
//  Created by Anton Bohomol on 9/22/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "DefaultHttpClient.h"
#import <AFNetworking/AFNetworking.h>
#import "CommonEPConstants.h"
#import "KaaLogging.h"

#define TAG @"DefaultHttpClient >>>"

#define SUCCESS_CODE        (200)
#define REDIRECTION_CODE    (300)

@interface DefaultHttpClient ()

@property (nonatomic,strong) AFHTTPClient *client;
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@property (nonatomic) volatile BOOL isShutDown;

- (NSData *)getResponseBody:(AFHTTPRequestOperation *)response verify:(BOOL)verify;

@end

@implementation DefaultHttpClient

- (instancetype)initWith:(NSString *)url privateKey:(SecKeyRef)privateK publicKey:(SecKeyRef)publicK
               remoteKeyRef:(SecKeyRef)remoteK {
    self = [super initWith:url privateKey:privateK publicKey:publicK remoteKeyRef:remoteK];
    if (self) {
        self.client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
        self.isShutDown = NO;
    }
    return self;
}

- (NSData *)executeHttpRequest:(NSString *)uri entity:(NSDictionary *)entity verifyResponse:(BOOL)verifyResponse {
    if (self.isShutDown) {
        DDLogError(@"%@ Can't proceed with request because service is down: %@", TAG, uri);
        [NSException raise:@"InterruptedException" format:@"Client is already down"];
        return nil;
    }
    
    NSMutableURLRequest *request =
    [self.client multipartFormRequestWithMethod:@"POST"
                                           path:uri
                                     parameters:nil
                      constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
                          for (NSString *key in entity.allKeys) {
                              [formData appendPartWithFormData:[entity objectForKey:key] name:key];
                          }
                      }];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogVerbose(@"%@ Successfully processed request", TAG);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@ Error processing request: %@", TAG, error);
    }];
    [self.client enqueueHTTPRequestOperation:self.operation];
    [self.operation waitUntilFinished];
    NSData *result = nil;
    NSInteger statusCode = [[self.operation response] statusCode];
    if (statusCode >= SUCCESS_CODE && statusCode < REDIRECTION_CODE) {
        result = [self getResponseBody:self.operation verify:verifyResponse];
    } else {
        DDLogError(@"%@ TransportException response status: %li", TAG, (long)statusCode);
        [NSException raise:@"TransportException" format:@"%li", (long)statusCode];
    }
    self.operation = nil;
    return result;
}

- (void)close {
    if (!self.isShutDown) {
        [self.client.operationQueue cancelAllOperations];
        self.isShutDown = YES;
    }
}

- (void)abort {
    if ([self canAbort]) {
        [self.operation cancel];
        self.operation = nil;
    }
}

- (BOOL)canAbort {
    return self.operation && ![self.operation isCancelled] && ![self.operation isFinished];
}

- (NSData *)getResponseBody:(AFHTTPRequestOperation *)response verify:(BOOL)verify {
    if (!response || !response.responseData) {
        [NSException raise:@"IOException" format:@"Can't read message!"];
    }
    
    NSData *result = nil;
    if (verify) {
        NSDictionary *headers = response.response.allHeaderFields;
        DDLogVerbose(@"%@ %@", TAG, [headers description]);
        NSString *signatureHeader = [headers objectForKey:SIGNATURE_HEADER_NAME];
        if (!signatureHeader) {
            [NSException raise:@"IOException" format:@"Can't verify message"];
        }
        
        NSData *signature = [signatureHeader dataUsingEncoding:NSUTF8StringEncoding];
        
        result = [self verifyResponse:response.responseData signature:signature];
    } else {
        result = response.responseData;
    }
    
    return result;
}

@end
