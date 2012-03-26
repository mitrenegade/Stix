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
#import "FriendsViewController.h"
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
#import "FacebookLoginController.h"

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
    NB_INCREMENTBUX
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
    int usertagtotal;
    int bux;

    // user info
//    bool isFirstTimeUser;
//    bool hasAccessedStore;
};

@interface StixxAppDelegate : NSObject <TagViewDelegate, UIImagePickerControllerDelegate, UITabBarControllerDelegate, ProfileViewDelegate, KumulosDelegate, FriendsViewDelegate, ExploreViewDelegate, RaisedCenterTabBarControllerDelegate, /*LoginSplashDelegate, */FeedbackViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, VerticalFeedDelegate, KumulosHelperDelegate, ASIHTTPRequestDelegate,

//#if USING_FACEBOOK
    FacebookHelperDelegate, FacebookLoginDelegate,
//#endif
    UIApplicationDelegate> {
    UIWindow *window;
    
    UIViewController * mainController;
    
	RaisedCenterTabBarController * tabBarController; // tab bar for maintaining multiple views
	//UITabBarController * tabBarController; 	
    TagViewController * tagViewController;
	//FeedViewController *feedController;
    VerticalFeedController *feedController;
	FriendsViewController *friendController;
	ProfileViewController *profileController;
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
    NSMutableSet * allFriends;
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
    int buyBuxPurchaseAmount;
    
    NSMutableDictionary * allUserPhotos;
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
}

-(void)initializeBadges;
-(void)checkVersion;
-(int)loadDataFromDisk;
-(void)saveDataToDisk;

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
-(void)adminSaveTagUpdateInfo;
-(void)adminResetAllStixOrders;

-(void)decrementStixCount:(NSString*)stixStringID;
-(void)incrementStixCount:(NSString*)stixStringID;
-(void)incrementStixCount:(NSString *)stixStringID byNumber:(int)increment;
-(Tag*) getTagWithID:(int)tagID;

-(void) Parse_subscribeToChannel:(NSString*) channel;
-(void) Parse_sendBadgedNotification:(NSString*)message OfType:(int)type toChannel:(NSString*) channel withTag:(NSNumber*)tagID orGiftStix:(NSString*)giftStixStringID;
-(void) Parse_unsubscribeFromAll;
-(void)handleNotificationBookmarks:(bool)doJump withMessage:(NSString*)message;
-(void)showAllAlerts;
-(void)reloadAllCarousels;
-(void)rewardStix;
-(void)rewardBux;
-(void)rewardLocation;
-(void)didGetKumulosSubcategories:(NSMutableArray*)theResults;
-(void)logMetricTimeInApp;
-(void)checkConsistency;
-(void)updateBuxCountFromKumulos;
-(void)didDismissSecondaryView;
// former store methods
-(void)updateBuxCount;
-(void)didGetStixFromStore:(NSString*)stixStringID;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UIViewController * emptyViewController;
@property (nonatomic, retain) RaisedCenterTabBarController *tabBarController;
@property (nonatomic, retain) TagViewController *tagViewController;
//@property (nonatomic, retain) FeedViewController *feedController;
@property (nonatomic, retain) VerticalFeedController *feedController;
@property (nonatomic, retain) ProfileViewController *profileController;
@property (nonatomic, retain) FriendsViewController *friendController;
@property (nonatomic, retain) ExploreViewController *exploreController;
@property (nonatomic, retain) FacebookLoginController * loginSplashController;
@property (nonatomic, assign) struct UserInfo * myUserInfo;
@property (nonatomic, assign) UIViewController * lastViewController;
@property (nonatomic, retain) NSMutableArray * allTags;
@property (nonatomic, retain) NSDate * timeStampOfMostRecentTag;
@property (nonatomic, retain) NSMutableDictionary * allUserPhotos;
@property (nonatomic, retain) NSMutableDictionary * allStix;
@property (nonatomic, retain) NSMutableDictionary * allStixOrder;
@property (nonatomic, retain) NSMutableSet * allFriends;
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

