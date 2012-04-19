//
//  StixxAppDelegate.h
//  Stixx
//
//  Created by Bobby Ren on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define USING_KIIP 0
#define USING_FACEBOOK 1

#import <UIKit/UIKit.h>

#import "TagViewController.h"
#import "ProfileViewController.h"
//#import "FriendsViewController.h"
//#import "TagDescriptorController.h"
#import "ExploreViewController.h"
#import "Kumulos.h"
#import "Tag.h"
//#import "ARCoordinate.h"
#import "BadgeView.h"
#import "RaisedCenterTabBarController.h"
//#import "LoginSplashController.h"
#import "LoadingViewController.h"
#import "FeedbackViewController.h"
#import <Parse/Parse.h>
#import "AlertPrompt.h"
#import "KumulosHelper.h"
#import "SMWebRequest.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "FacebookLoginController.h"
#import "UserTagAggregator.h"
#import "UserProfileViewController.h"
#import "StixAnimation.h"

#if USING_FACEBOOK
//#import "FBConnect.h"
#import "FacebookHelper.h"
#endif
#import "VerticalFeedController.h"

enum notification_bookmarks {
    NB_NEWSTIX = 0,
    NB_NEWCOMMENT,
    NB_NEWGIFT,
    NB_PEELACTION,
    NB_UPDATECAROUSEL,
    NB_INCREMENTBUX,
    NB_NEWFOLLOWER
};

enum alertview_actions {
    ALERTVIEW_SIMPLE = 0,
    ALERTVIEW_UPGRADE,
    ALERTVIEW_NOTIFICATION,
    ALERTVIEW_PROMPT,
    ALERTVIEW_GOTOSTORE,
    ALERTVIEW_BUYBUX
};

enum actionsheet_tags {
    ACTIONSHEET_TAG_ADMIN = 1000,
    ACTIONSHEET_TAG_SHAREPIX,
    ACTIONSHEET_TAG_BUYBUX,
    ACTIONSHEET_TAG_MAX
};

struct UserInfo {
    NSString * username;
    UIImage * userphoto;
    NSString * email;
    int facebookID;
    int usertagtotal;
    int bux;
    int firstTimeUserStage;

    // user info
//    bool isFirstTimeUser;
//    bool hasAccessedStore;
};

@interface StixxAppDelegate : NSObject <TagViewDelegate, UIImagePickerControllerDelegate, UITabBarControllerDelegate, ProfileViewDelegate, KumulosDelegate, ExploreViewDelegate, RaisedCenterTabBarControllerDelegate, FeedbackViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, VerticalFeedDelegate, KumulosHelperDelegate, ASIHTTPRequestDelegate, UserTagAggregatorDelegate, UserProfileViewDelegate, StixAnimationDelegate, FacebookHelperDelegate, FacebookLoginDelegate, UIApplicationDelegate> {
    
    UIWindow *window;
    
    UIViewController * mainController;
    
	RaisedCenterTabBarController * tabBarController; // tab bar for maintaining multiple views
	//UITabBarController * tabBarController; 	
    TagViewController * tagViewController;
	//FeedViewController *feedController;
    VerticalFeedController *feedController;
	//FriendsViewController *friendController;
	ProfileViewController *profileController;
    UserProfileViewController * userProfileController;
    ExploreViewController * exploreController;
    FacebookLoginController * loginSplashController;
    
    UIViewController * lastViewController;

    bool loggedIn;
    bool isLoggingIn;
    struct UserInfo * myUserInfo;
    bool stixViewsLoadedFromDisk;
    bool fbLoginIsJoin;
    
    NSMutableDictionary * allStix;
    NSMutableDictionary * allStixOrder;
    //NSMutableSet * allFriends;
    NSMutableSet * allFollowers;
    NSMutableSet * allFollowing;
    NSMutableArray * allTags;
    NSMutableDictionary * allCommentCounts;
    
    NSMutableArray * allCarouselViews;
    
    Tag * newestTag;
    NSDate * timeStampOfMostRecentTag;
    int idOfNewestTagOnServer;
    int idOfOldestTagOnServer;
    int idOfNewestTagReceived;
    int idOfOldestTagReceived;
    int idOfLastTagChecked;
    int idOfCurrentTag; // current tag being displayed
    
    int pageOfLastNewerTagsRequest;
    int pageOfLastOlderTagsRequest;
    
    // hack: save some memory from didAddStixToPix - fix is to add the correct callback
    bool isUpdatingAuxStix;
    int updatingAuxTagID;
    NSString * updatingAuxStixStringID;
    CGPoint updatingAuxLocation;
    //float updatingAuxScale;
    //float updatingAuxRotation;
    CGAffineTransform updatingAuxTransform;
    
    // hack: for peelable stix actions
    bool isUpdatingPeelableStix;
    int updatingPeelableTagIndex;
    int updatingPeelableTagID;
    int updatingPeelableAuxStixIndex;
    int updatingPeelableAction;
    int shareActionSheetTagID;
    int shareMethod; // 0 = facebook, 1 = email

    BOOL isDisplayingShareSheet;
    BOOL isDisplayingBuxMenu;
    
    int buyBuxPurchaseAmount;
    UIImageView * buxPurchaseMenu;
    NSMutableArray * buxPurchaseButtons;
    UIButton * buttonBuxPurchaseClose;
    BOOL isShowingBuxPurchaseMenu;
    
    NSMutableDictionary * allUsers;
    int idOfMostRecentUser;
    
    IBOutlet UITextField * loadingMessage;

    NSData * notificationDeviceToken; // if nil, not ready to register yet
    int notificationBookmarkType;
    int notificationTagID;
    NSString * notificationTargetChannel;
    bool updatingNotifiedTagDoJump;
    bool isUpdatingNotifiedTag;
    NSString * notificationGiftStixStringID;
    
    UIImagePickerController * camera;

    Kumulos* k;
    NSDate * lastKumulosErrorTimestamp;
        
    NSString * versionStringStable;
    NSString * versionStringBeta;
    NSString * currVersion;
    int versionIsOutdated;
    
    NSMutableArray * alertAction;
    NSMutableArray * alertQueue;
    int alertActionCurrent;
        
    FacebookHelper * fbHelper;
    UserTagAggregator * aggregator;
    
    BOOL followListsDidChangeDuringProfileView;
    
    UIImageView * buxInstructions;
    UIButton * buttonBuxInstructionsClose;
    BOOL isShowingBuxInstructions;
    UIButton * buttonBuxStore;
}

-(void)initializeBadgesFromKumulos;
-(void)checkVersion;
// saving and loading
-(void)saveStixDataToDefaults;
-(int)saveStixDataToDefaultsForStixStringID:(NSString*)stixStringID;
-(int)loadUserInfoFromDefaults;
-(int)loadStixDataFromDefaults;
-(void)saveStixTypesToDefaults;

- (void)showAlertWithTitle:(NSString *) title andMessage:(NSString*)message andButton:(NSString*)buttonTitle andOtherButton:(NSString*)otherButtonTitle andAlertType:(int)alertType;
-(NSString*)coordinateArrayPath; // calls FileHelpers.m to create path
-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID;
-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID overwrite:(bool)bOverwrite;
-(void)updateCommentCount:(int)tagID;
-(void)adminUpdateAllStixCountsToZero;
-(void)adminIncrementAllUsersBuxCounts;
-(void)adminIncrementAllStixCounts;
-(void) adminSetAllUsersBuxCounts;
-(void)adminSetUnlimitedStix;
-(void)adminEasterEggShowMenu:(NSString*)password;
-(void)updateUserTagTotal;
-(void)changeBuxCountByAmount:(int)change;
//-(void)adminSaveFeed;
-(void)adminResetAllStixOrders;

-(Tag*) getTagWithID:(int)tagID;

-(void) Parse_subscribeToChannel:(NSString*) channel;
-(void) Parse_sendBadgedNotification:(NSString*)message OfType:(int)type toChannel:(NSString*) channel withTag:(NSNumber*)tagID orGiftStix:(NSString*)giftStixStringID;
//-(void) Parse_unsubscribeFromAll;

-(void) Parse_createSubscriptions;
-(void)handleNotificationBookmarks:(bool)doJump withMessage:(NSString*)message;
-(void)showAllAlerts;
-(void)reloadAllCarousels;
-(void)rewardStix;
-(void)rewardBux;
-(void)rewardLocation;
-(void)logMetricTimeInApp;
-(void)checkConsistency;
-(void)updateBuxCountFromKumulos;
-(void)didDismissSecondaryView;
// former store methods
-(void)updateBuxCount;
-(void)didGetStixFromStore:(NSString*)stixStringID;
-(void)didPurchaseBux:(int)buxPurchased;

-(void)hideFirstTimeUserMessage;
-(void)advanceFirstTimeUserMessage;
-(void)showBuxPurchaseMenu;
-(void)agitateFirstTimePointer;
- (void)didLoginWithUsername:(NSString *)name andPhoto:(UIImage *)photo andEmail:(NSString*)email andFacebookID:(NSNumber*)facebookID andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary *)stixOrder;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UIViewController * emptyViewController;
@property (nonatomic, retain) RaisedCenterTabBarController *tabBarController;
@property (nonatomic, retain) TagViewController *tagViewController;
//@property (nonatomic, retain) FeedViewController *feedController;
@property (nonatomic, retain) VerticalFeedController *feedController;
@property (nonatomic, retain) ProfileViewController *profileController;
@property (nonatomic, retain) UserProfileViewController *userProfileController;
//@property (nonatomic, retain) FriendsViewController *friendController;
@property (nonatomic, retain) ExploreViewController *exploreController;
@property (nonatomic, retain) FacebookLoginController * loginSplashController;
@property (nonatomic, assign) struct UserInfo * myUserInfo;
@property (nonatomic, assign) UIViewController * lastViewController;
@property (nonatomic, retain) NSMutableArray * allTags;
@property (nonatomic, retain) NSMutableDictionary * allTagIDs; // fast check for existence of allTags
@property (nonatomic, retain) NSDate * timeStampOfMostRecentTag;
@property (nonatomic, retain) NSMutableDictionary * allUsers;
@property (nonatomic, retain) NSMutableDictionary * allUserPhotos;
@property (nonatomic, retain) NSMutableDictionary * allStix;
@property (nonatomic, retain) NSMutableDictionary * allStixOrder;
//@property (nonatomic, retain) NSMutableSet * allFriends;
@property (nonatomic, retain) NSMutableSet * allFollowers;
@property (nonatomic, retain) NSMutableSet * allFollowing;
@property (nonatomic, retain) NSMutableArray * allUserFacebookIDs;
@property (nonatomic, retain) NSMutableArray * allUserEmails;
@property (nonatomic, retain) NSMutableArray * allUserNames;
@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, retain) NSMutableDictionary * allCommentCounts;
@property (nonatomic, retain) NSMutableDictionary * allCommentHistories;
@property (nonatomic, retain) NSMutableArray * allCarouselViews;
@property (nonatomic, retain) IBOutlet UITextField * loadingMessage;
@property (nonatomic, retain) NSMutableArray * alertQueue;
@property (nonatomic, retain) UIImagePickerController * camera;
@property (nonatomic, retain) NSDate * metricLogonTime;
@property (nonatomic, retain) NSDate * lastKumulosErrorTimestamp;
@property (nonatomic, retain) FacebookHelper * fbHelper;

@end

