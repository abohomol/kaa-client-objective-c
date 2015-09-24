//
//  TransportCommon.h
//  Kaa
//
//  Created by Anton Bohomol on 5/26/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_TransportCommon_h
#define Kaa_TransportCommon_h

/**
 * TransportType - enum with list of all possible transport types which
 * every Channel can support.
 */
typedef enum {
    TRANSPORT_TYPE_BOOTSTRAP,
    TRANSPORT_TYPE_PROFILE,
    TRANSPORT_TYPE_CONFIGURATION,
    TRANSPORT_TYPE_NOTIFICATION,
    TRANSPORT_TYPE_USER,
    TRANSPORT_TYPE_EVENT,
    TRANSPORT_TYPE_LOGGING
} TransportType;

typedef enum {
    SERVER_BOOTSTRAP,
    SERVER_OPERATIONS
} ServerType;

typedef enum {
    /**
     *  From the endpoint to the server
     */
    CHANNEL_DIRECTION_UP,
    /**
     *  From the server to the enpoint
     */
    CHANNEL_DIRECTION_DOWN,
    /**
     * In both ways
     */
    CHANNEL_DIRECTION_BIDIRECTIONAL
} ChannelDirection;

#endif
