//
//  Constants.h
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//


/**
 * Common Kaa project Constants.
 */

#ifndef Kaa_Constants_h
#define Kaa_Constants_h

/**
 * Used URI delimiter.
 */
#define URI_DELIM @"/"

/**
 * HTTP response content-type.
 */
#define RESPONSE_CONTENT_TYPE @"\"application/x-kaa\""

/**
 * HTTP response custom header for set RSA Signature encoded in base64
 */
#define SIGNATURE_HEADER_NAME @"X-SIGNATURE"

/**
 * The identifier for the Avro platform protocol
 */
#define KAA_PLATFORM_PROTOCOL_AVRO_ID (0xf291f2d4)

/**
 * The identifier for the Binary platform protocol
 */
#define KAA_PLATFORM_PROTOCOL_BINARY_ID (0x3553c66f)

/**
 * The size of sdk token
 */
#define SDK_TOKEN_SIZE 28

/**
 * The size of application token
 */
#define APP_TOKEN_SIZE 20

/**
 * The size of user verifier token
 */
#define USER_VERIFIER_TOKEN_SIZE 20

#endif
