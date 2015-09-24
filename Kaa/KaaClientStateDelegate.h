//
//  KaaClientStateDelegate.h
//  Kaa
//
//  Created by Anton Bohomol on 9/9/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_KaaClientStateDelegate_h
#define Kaa_KaaClientStateDelegate_h

#import <Foundation/Foundation.h>

/**
 * Notifies about Kaa client state changes and errors
 */
@protocol KaaClientStateDelegate

/**
 * On successful start of Kaa client. Kaa client is successfully connected
 * to Kaa cluster and is ready for usage.
 */
- (void)onStarted;

/**
* On failure during Kaa client startup. Typically failure is related to
* network issues.
*/
- (void)onStartFailure:(NSException *)exception;

/**
* On successful pause of Kaa client. Kaa client is successfully paused
* and does not consume any resources now.
*/
- (void)onPaused;

/**
* On failure during Kaa client pause. Typically related to
* failure to free some resources.
*/
- (void)onPauseFailure:(NSException *)exception;

/**
* On successful resume of Kaa client. Kaa client is successfully connected
* to Kaa cluster and is ready for usage.
*/
- (void)onResume;

/**
* On failure during Kaa client resume. Typically failure is related to
* network issues.
*/
- (void)onResumeFailure:(NSException *)exception;

/**
* On successful stop of Kaa client. Kaa client is successfully stopped
* and does not consume any resources now.
*/
- (void)onStopped;

/**
* On failure during Kaa client stop. Typically related to
* failure to free some resources.
*/
- (void)onStopFailure:(NSException *)exception;

@end

#endif
