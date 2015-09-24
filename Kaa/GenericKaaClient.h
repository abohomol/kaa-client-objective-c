//
//  GenericKaaClient.h
//  Kaa
//
//  Created by Anton Bohomol on 6/22/15.
//  Copyright (c) 2015 CYBERVISION INC. All rights reserved.
//

#ifndef Kaa_GenericKaaClient_h
#define Kaa_GenericKaaClient_h

#import "ConfigurationStorage.h"
#import "NotificationTopicListDelegate.h"
#import "LogStorage.h"
#import "LogUploadStrategy.h"
#import "EventDelegates.h"
#import "KaaChannelManager.h"
#import "EndpointAccessToken.h"
#import "EndpointRegistrationManager.h"
#import "EventFamilyFactory.h"
#import "ProfileCommon.h"
#import "ConfigurationCommon.h"
#import "NotificationCommon.h"

/**
 * Root interface for the Kaa client.
 * This interface contain methods that are predefined and does not contain any auto-generated code.
 */
@protocol GenericKaaClient <NSObject>

/**
 * Starts Kaa's workflow.
 */
- (void)start;

/**
 * Stops Kaa's workflow.
 */
- (void)stop;

/**
 * Pauses Kaa's workflow.
 */
- (void)pause;

/**
 * Resumes Kaa's workflow.
 */
- (void)resume;

/**
 * Sets profile container implemented by the user.
 */
- (void)setProfileContainer:(id<ProfileContainer>)container;

/**
 * Sync of updated profile with server
 */
- (void)updateProfile;

/**
 * Sets the configuration storage that will be used to persist configuration.
 */
- (void)setConfigurationStorage:(id<ConfigurationStorage>)storage;

/**
 * Register configuration update delegate
 */
-(void)addConfigurationDelegate:(id<ConfigurationDelegate>)delegate;

/**
 * Removes configuration update delegate
 */
- (void)removeConfigurationDelegate:(id<ConfigurationDelegate>)delegate;

/**
 * Add delegate for notification topics' list updates.
 */
- (void)addTopicListDelegate:(id<NotificationTopicListDelegate>)delegate;

/**
 * Remove delegate of notification topics' list updates.
 */
- (void)removeTopicListDelegate:(id<NotificationTopicListDelegate>)delegate;

/**
 * Retrieve a list of available notification topics.
 * @return List of available topics <Topic>
 */
- (NSArray *)getTopics;

/**
 * Add delegate to receive all notifications (both for mandatory and optional topics).
 */
- (void)addNotificationDelegate:(id<NotificationDelegate>)delegate;

/**
 * Add delegate to receive notifications relating to the specified topic.
 * Delegate(s) for optional topics may be added/removed irrespective to
 * whether subscription was already or not.
 *
 * @throws UnavailableTopicException if unknown topic id is provided.
 */
- (void)addNotificationDelegate:(id<NotificationDelegate>)delegate for:(NSString *)topicId;

/**
 * Remove delegate receiving all notifications (both for mandatory and optional topics).
 */
- (void)removeNotificationDelegate:(id<NotificationDelegate>) delegate;

/**
 * Remove delegate receiving notifications for the specified topic.
 * Delegate(s) for optional topics may be added/removed irrespective to
 * whether subscription was already or not.
 *
 * @param topicId - id of topic (both mandatory and optional).
 *
 * @throws UnavailableTopicException if unknown topic id is provided.
 */
- (void)removeNotificationDelegate:(id<NotificationDelegate>)delegate for:(NSString *) topicId;

/**
 * Subscribe to notifications relating to the specified optional topic.
 * @param topicId - id of a optional topic.
 *
 * @throws UnavailableTopicException if unknown topic id is provided or topic isn't optional.
 */
- (void)subscribeToTopic:(NSString *)topicId;

/**
 * Subscribe to notifications relating to the specified optional topic.
 *
 * @param topicId - id of a optional topic.
 * @param forceSync- define whether current subscription update should be accepted immediately.
 *
 * @throws UnavailableTopicException if unknown topic id is provided or topic isn't optional.
 */
- (void)subscribeToTopic:(NSString *)topicId forceSync:(BOOL)forceSync;

/**
 * Subscribe to notifications relating to the specified list of optional topics.
 *
 * @param topicIds - list of optional topic id. <NSString>
 *
 * @throws UnavailableTopicException if unknown topic id is provided or topic isn't optional.
 */
- (void)subscribeToTopics:(NSArray *)topicIds;

/**
 * Subscribe to notifications relating to the specified list of optional topics.
 *
 * @param topicIds - list of optional topic id. <NSString>
 * @param forceSync - define whether current subscription update should be accepted immediately.
 *
 * @throws UnavailableTopicException if unknown topic id is provided or topic isn't optional.
 *
 */
- (void)subscribeToTopics:(NSArray *)topicIds forceSync:(BOOL)forceSync;

/**
 * Unsubscribe from notifications relating to the specified optional topic.
 * All previously added delegates will be removed automatically.
 *
 * @param topicId - id of a optional topic.
 *
 * @throws UnavailableTopicException if unknown topic id is provided or topic isn't optional.
 */
- (void)unsubscribeFromTopic:(NSString *)topicId;

/**
 * Unsubscribe from notifications relating to the specified optional topic.
 * All previously added delegates will be removed automatically.
 *
 * @param topicId - id of a optional topic.
 * @param forceSync - define whether current subscription update should be accepted immediately.
 *
 * @throws UnavailableTopicException if unknown topic id is provided or topic isn't optional.
 */
- (void)unsubscribeFromTopic:(NSString *)topicId forceSync:(BOOL)forceSync;

/**
 * Unsubscribe from notifications relating to the specified list of optional topics.
 * All previously added delegates will be removed automatically.
 *
 * @param topicIds - list of optional topic id. <NSString>
 *
 * @throws UnavailableTopicException if unknown topic id is provided or topic isn't optional.
 */
- (void)unsubscribeFromTopics:(NSArray *)topicIds;

/**
 * Unsubscribe from notifications relating to the specified list of optional topics.
 * All previously added delegates will be removed automatically.
 *
 * @param topicIds - list of optional topic id. <NSString>
 * @param forceSync - define whether current subscription update should be accepted immediately.
 *
 * @throws UnavailableTopicException if unknown topic id is provided or topic isn't optional.
 */
- (void)unsubscribeFromTopics:(NSArray *)topicIds forceSync:(BOOL)forceSync;

/**
 * Force sync of pending subscription changes with server.
 */
- (void)syncTopicsList;

/**
 * Set user implementation of a log storage.
 */
- (void)setLogStorage:(id<LogStorage>)storage;

/**
 * Set user implementation of a log upload strategy.
 */
- (void)setLogUploadStrategy:(id<LogUploadStrategy>)strategy;

/**
 * Retrieves Kaa event family factory.
 */
- (EventFamilyFactory *)getEventFamilyFactory;

/**
 * Submits an event delegates resolution request.
 *
 * @param eventFQNs - list of event class FQNs which have to be supported by endpoint. <NSString>
 */
- (void)findEventListeners:(NSArray *)eventFQNs delegate:(id<FindEventListenersDelegate>) delegate;

/**
 * Retrieves Kaa channel manager.
 */
- (id<KaaChannelManager>)getChannelManager;

/**
 * Retrieves the client's public key.
 * Required in user implementation of an operation data channel. Public key
 * hash (SHA-1) is used by servers as identification number to uniquely
 * identify each connected endpoint.
 */
- (SecKeyRef)getClientPublicKey;

/**
 * Retrieves endpoint public key hash.
 * Required in EndpointRegistrationManager implementation to react
 * on detach response from Operations server.
 *
 * @return NSString containing current endpoint's public key hash.
 */
- (NSString *)getEndpointKeyHash;

/**
 * Retrieves the client's private key.
 * Required in user implementation of an operation data channel. Private key
 * is used by encryption schema between endpoint and servers.
 *
 * @return client's private key
 */
- (SecKeyRef)getClientPrivateKey;

/**
 * Set new access token for a current endpoint.
 */
- (void)setEndpointAccessToken:(NSString *)token;

/**
 * Generate new access token for a current endpoint.
 */
- (NSString *)refreshEndpointAccessToken;

/**
 * Retrieve an access token for a current endpoint.
 */
- (NSString *)getEndpointAccessToken;

/**
 * Updates with new endpoint attach request<br>
 * OnAttachEndpointOperationCallback is populated with EndpointKeyHash of an attached endpoint.
 *
 * @param endpointAccessToken - access token of the attaching endpoint
 * @param delegate - delegate to notify about result of the endpoint attaching
 */
- (void)attachEndpoint:(EndpointAccessToken *)endpointAccessToken delegate:(id<OnAttachEndpointOperationDelegate>) delegate;

/**
 * Updates with new endpoint detach request
 *
 * @param endpointKeyHash - key hash of the detaching endpoint
 * @param delegate - delegate to notify about result of the enpoint attaching
 */
- (void)detachEndpoint:(EndpointKeyHash *)endpointKeyHash delegate:(id<OnDetachEndpointOperationDelegate>)delegate;

/**
 * Creates user attach request using default verifier. Default verifier is selected during SDK generation.
 * If there was no default verifier selected this method will throw runtime exception.
 */
- (void)attachUser:(NSString *)userExternalId token:(NSString *)userAccessToken delegate:(id<UserAttachDelegate>)delegate;

/**
 * Creates user attach request using specified verifier.
 */
- (void)attachUser:(NSString*)userVerifierToken
                id:(NSString*)userExternalId
             token:(NSString*)userAccessToken
          delegate:(id<UserAttachDelegate>)delegate;

/**
 * Checks if current endpoint is attached to user.
 */
- (BOOL)isAttachedToUser;

/**
 * Sets callback for notifications when current endpoint is attached to user.
 */
- (void)setAttachedDelegate:(id<AttachEndpointToUserDelegate>)delegate;

/**
 * Sets callback for notifications when current endpoint is detached from user.
 */
- (void)setDetachedDelegate:(id<DetachEndpointFromUserDelegate>)delegate;

@end
#endif
