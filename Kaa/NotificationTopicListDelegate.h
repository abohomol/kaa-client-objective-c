//
//  NotificationTopicListListener.h
//  Kaa
//
//  Created by Anton Bohomol on 7/7/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_NotificationTopicListListener_h
#define Kaa_NotificationTopicListListener_h

/**
 * The delegate for topics' list updates.
 */
@protocol NotificationTopicListDelegate <NSObject>

/**
 * Called on topics' list updates.
 */
- (void)onListUpdated:(NSArray *)list;

@end

#endif
