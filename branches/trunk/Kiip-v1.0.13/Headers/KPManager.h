//
//  KPManager.h
//  Kiip
//
//  Created on 2/16/11.
//  Copyright 2011 Kiip, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPUIConstants.h"
#import "KPManagerDelegate.h"

extern NSString* KPManagerVersion;

/*!
 * @class
 * @abstract
 */
@interface KPManager : NSObject {

    id<KPManagerDelegate> delegate;
    BOOL shouldAutoRotate;
    BOOL authenticated;

@private
    int testFrequency;
    NSMutableArray* rewardQueue;
}

/*!
 * @property shouldAutoRotate
 * @abstract Determines whether the manager should autorotate notifications
 * based on the device's orientation.
 */
@property (nonatomic, assign) BOOL shouldAutoRotate;

/*!
 * @property authenticated
 * @abstract Indicates whether Kiip is currently authenticated. (read-only)
 */
@property (nonatomic, readonly, getter=isAuthenticated) BOOL authenticated;

/*!
 * @property delegate
 * @abstract The delegate to the manager. It will recieve callback notifications
 * when views appear and disappear on screen.
 */
@property (nonatomic, assign) id<KPManagerDelegate> delegate;

/*!
 * @method initWithKey:secret:
 * @abstract Creates a new object with the proper credentials.
 * @param key The Oauth consumer key.
 * @param secret The OAuth consumer secret.
 * @result
 */
- (id) initWithKey:(NSString*)key secret:(NSString*)secret;

/*!
 * @method initWithKey:secret:withTags:
 * @abstract Creates a new object with the proper credentials.
 * @param key The Oauth consumer key.
 * @param secret The OAuth consumer secret.
 * @param tags Optional tags to better target rewards ex. male/female, sports, etc.
 * @result
 */
- (id) initWithKey:(NSString*)key secret:(NSString*)secret withTags:(NSArray*)tags;

/*!
 * @method initWithKey:secret:testFrequency:
 * @abstract Creates a new object with the proper credentials.
 * @param key The Oauth consumer key.
 * @param secret The Oauth consumer secret.
 * @param frequency The frequency at which to generate rewards when events
 * are triggered.
 * @result
 */
- (id) initWithKey:(NSString*)key secret:(NSString*)secret testFrequency:(int)frequency;

/*!
 * @method initWithKey:secret:testFrequency:withTags:
 * @abstract Creates a new object with the proper credentials.
 * @param key The Oauth consumer key.
 * @param secret The Oauth consumer secret.
 * @param frequency The frequency at which to generate rewards when events
 * are triggered.
 * @param tags Optional tags to better target rewards ex. male/female, sports, etc.
 * @result
 */
- (id) initWithKey:(NSString*)key secret:(NSString*)secret testFrequency:(int)frequency withTags:(NSArray*)tags;

/*!
 * @method  sharedManager
 * @abstract Access to the shared object for this class.
 * @result
 */
+ (KPManager*) sharedManager;

/*!
 * @method setSharedManager:
 * @abstract Set the shared manager for this class.
 * @param manager The shared manager.
 */
+ (void) setSharedManager:(KPManager*)manager;

/*!
 * @method startSession
 * @abstract Starts a new session. Note, this
 * method is called upon object initialization so
 * you should only call this method if you have called
 * closeSession previously.
 */
- (void) startSession;

/*!
 * @method startSessionWithTags:
 * @abstract Starts a new session. Note, this
 * method is called upon object initialization so
 * you should only call this method if you have called
 * closeSession previously.
 * @param tags Optional tags to better target rewards ex. male/female, sports, etc.
 */
- (void) startSessionWithTags:(NSArray*)tags;

/*!
 * @method updateLatitude:longitude:
 * @abstract Update the lat/lon for the current session.
 * @param latitude The latitude of the device.
 * @param longitude The longitude of the device.
 */
- (void) updateLatitude:(double)latitude longitude:(double)longitude;

/*!
 * @method updateUserInfo:
 * @abstract Update the user info for the current session.
 * Examples:
 * * alias - The alias will be used to make rewards more personal and to show
 * on leaderboard scores.
 * * email - The email will be used to pre-populate reward units.
 * @param info Dictionary of the user's information.
 */
- (void) updateUserInfo:(NSDictionary*)alias;

/*!
 * @method unlockAchievement:
 * @abstract Announce that a user has unlocked an achievement.
 * @param achievementId The achievement that was unlocked.
 */
- (void) unlockAchievement:(NSString*)achievementId;

/*!
 * @method unlockAchievement:withTags:
 * @abstract Announce that a user has unlocked an achievement.
 * @param achievementId The achievement that was unlocked.
 * @param tags Optional tags to better target rewards ex. movies, sports, etc.
 */
- (void) unlockAchievement:(NSString*)achievementId withTags:(NSArray*)tags;

/*!
 * @method updateScore:onLeaderboard:
 * @abstract Update the score for the given session.
 * @param score The score to use when updating the leaderboard.
 * @param leaderboardId The leaderboard to update.
 */
- (void) updateScore:(double)score onLeaderboard:(NSString*)leaderboardId;

/*!
 * @method updateScore:onLeaderboard:withTags:
 * @abstract Update the score for the given session.
 * @param score The score to use when updating the leaderboard.
 * @param leaderboardId The leaderboard to update.
 * @param tags Optional tags to better target rewards ex. movies, sports, etc.
 */
- (void) updateScore:(double)score onLeaderboard:(NSString*)leaderboardId withTags:(NSArray*)tags;

/*!
 * @method presentReward:
 * @abstract Present a Kiip reward to the user ontop of the keyWindow.
 * @param reward The reward to present.
 */
- (void) presentReward:(NSDictionary*)resource;

/*!
 * @method presentReward:onView:
 * @abstract Presents a Kiip reward to the user.
 * @param reward The reward to present.
 * @param view The view to use as the superview of the notification. If
 * nil is passed, the keyWindow will be used.
 */
- (void) presentReward:(NSDictionary*)resource onView:(UIView*)view;

/*!
 * @method getActivePromos:
 * @abstract Gets a NSArray of the live promos
 */
- (void) getActivePromos;

/*!
 * @method setGlobalOrientation:
 * @abstract Sets the orientation of all future notifications.
 * This is useful when your application doesn't acknowledge
 * device orientation notifications.
 * @param orientation ￼
 */
- (void) setGlobalOrientation:(UIDeviceOrientation)orientation;

/*!
 * @method endSession
 * @abstract Ends the current session.
 */
- (void) endSession;

@end
