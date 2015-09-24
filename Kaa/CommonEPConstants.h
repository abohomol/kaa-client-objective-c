//
//  CommonEPConstants.h
//  Kaa
//
//  Created by Anton Bohomol on 9/21/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

/**
 * Common endpoint constants.
 */

#ifndef Kaa_CommonEPConstants_h
#define Kaa_CommonEPConstants_h

#import "Constants.h"

#define ENDPOINT_DOMAIN @"EP"

#define ENDPOINT_REGISTER_COMMAND @"NewEPRegister"

#define ENDPOINT_REGISTER_URI [NSString stringWithFormat:@"%@%@%@%@", URI_DELIM, ENDPOINT_DOMAIN, URI_DELIM, ENDPOINT_REGISTER_COMMAND]

#define ENDPOINT_UPDATE_COMMAND @"EPUpdate"

#define ENDPOINT_UPDATE_URI [NSString stringWithFormat:@"%@%@%@%@", URI_DELIM, ENDPOINT_DOMAIN, URI_DELIM, ENDPOINT_UPDATE_COMMAND]

#define SYNC_COMMAND @"Sync"

#define LONG_SYNC_COMMAND @"LongSync"

#define SYNC_URI [NSString stringWithFormat:@"%@%@%@%@", URI_DELIM, ENDPOINT_DOMAIN, URI_DELIM, SYNC_COMMAND]

#define LONG_SYNC_URI [NSString stringWithFormat:@"%@%@%@%@", URI_DELIM, ENDPOINT_DOMAIN, URI_DELIM, LONG_SYNC_COMMAND]

#define SIGNATURE_HEADER_NAME @"X-SIGNATURE"

#define REQUEST_SIGNATURE_ATTR_NAME @"signature"

#define REQUEST_KEY_ATTR_NAME @"requestKey"

#define RESPONSE_TYPE @"X-RESPONSETYPE"

#define RESPONSE_TYPE_OPERATION @"operation"

#define REQUEST_DATA_ATTR_NAME @"requestData"

#define NEXT_PROTOCOL_ATTR_NAME @"nextProtocol"

#endif
