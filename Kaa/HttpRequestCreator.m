//
//  HTTPRequestCreator.m
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#import "HttpRequestCreator.h"
#import "NSData+Conversion.h"
#import "CommonEPConstants.h"

#define TAG @"HTTPRequestCreator >>>"

@implementation HttpRequestCreator

+ (NSDictionary *)createBootstrapHttpRequest:(NSData *)body withEncoderDecoder:(MessageEncoderDecoder *)messageEncDec {
    return [HttpRequestCreator createHttpRequest:body withEncoderDecoder:messageEncDec sign:NO];
}

+ (NSDictionary *)createOperationHttpRequest:(NSData *)body withEncoderDecoder:(MessageEncoderDecoder *)messageEncDec {
    return [HttpRequestCreator createHttpRequest:body withEncoderDecoder:messageEncDec sign:YES];
}

+ (NSDictionary *)createHttpRequest:(NSData *)body withEncoderDecoder:(MessageEncoderDecoder *)messageEncDec sign:(BOOL)sign {
    if (!body || !messageEncDec) {
        DDLogError(@"%@ Unable to create http request, invalid params: %@ %@", TAG, body, messageEncDec);
        return nil;
    }
    
    NSData *requestKeyEncoded = [messageEncDec getEncodedSessionKey];
    NSData *requestBodyEncoded = [messageEncDec encodeData:body];
    NSData *signature = nil;
    
    if (sign) {
        signature = [messageEncDec sign:requestKeyEncoded];
        DDLogVerbose(@"%@ Signature size: %li", TAG, (long)(signature.length));
        DDLogVerbose(@"%@ Signature: %@", TAG, [signature hexadecimalString]);
    }
    
    DDLogVerbose(@"%@ RequestKeyEncoded size: %li", TAG, (long)(requestKeyEncoded.length));
    DDLogVerbose(@"%@ RequestKeyEncoded: %@", TAG, [requestKeyEncoded hexadecimalString]);
    DDLogVerbose(@"%@ RequestBodyEncoded size: %li", TAG, (long)(requestBodyEncoded.length));
    DDLogVerbose(@"%@ RequestBodyEncoded: %@", TAG, [requestBodyEncoded hexadecimalString]);
    
    NSMutableDictionary *requestEntity = [NSMutableDictionary dictionary];
    if (sign) {
        [requestEntity setObject:signature forKey:REQUEST_SIGNATURE_ATTR_NAME];
    }
    [requestEntity setObject:requestKeyEncoded forKey:REQUEST_KEY_ATTR_NAME];
    [requestEntity setObject:requestBodyEncoded forKey:REQUEST_DATA_ATTR_NAME];
    return requestEntity;
}

@end
