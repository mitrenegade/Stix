//
//  StixxAppDelegate.h
//  Stixx
//
//  Created by Bobby Ren on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define USING_KIIP 0
#define USING_FACEBOOK 1
#define USING_MKSTOREKIT 1

#import <UIKit/UIKit.h>
#import "GlobalHeaders.h"
#import "TagViewController.h"
#import "ProfileViewController.h"
#import "ExploreViewController.h"
#import "Kumulos.h"
#import "Tag.h"
#import "BadgeView.h"
#import "RaisedCenterTabBarController.h"
//#import "LoadingViewController.h"
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
#import "Appirater.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ShareController.h"
#import "VerticalFeedController.h"
#import "FriendSuggestionController.h"
#import "FlurryAnalytics.h"
#import "StixPanelView.h"
#import "StixEditorViewController.h"
#import "Admin.h"
#import "NewsletterViewController.h"
#import "AROverlayViewController.h"

#import "SHK.h" // sharekit
#import "SHKConfiguration.h"
#import "MySHKConfigurator.h"
#import "SHKSharer.h"

#if USING_FACEBOOK
//#import "FBConnect.h"
#import "FacebookHelper.h"
#endif
#if USING_MKSTOREKIT
#import "MKStoreKitConfigs.h"
#import "MKStoreManager.h"
#import "MKStoreObserver.h"
#endif

struct UserInfo {
//    NSString * username;
//    UIImage * userphoto;
//    NSString * email;
//    NSString * facebookString;
    //int usertagtotal;
    //int bux;
    int firstTimeUserStage;
    int userID;
    int hasPhoto;

    // user info
//    bool isFirstTimeUser;
//    bool hasAccessedStore;
};

@interface StixxAppDelegate : NSObject <TagViewDelegate, UIImagePickerControllerDelegate, UITabBarControllerDelegate, ProfileViewDelegate, KumulosDelegate, ExploreViewDelegate, RaisedCenterTabBarControllerDelegate, FeedbackViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, VerticalFeedDelegate, KumulosHelperDelegate, ASIHTTPRequestDelegate, UserTagAggregatorDelegate, UserProfileViewDelegate, StixAnimationDelegate, FacebookHelperDelegate, FacebookLoginDelegate, UIApplicationDelegate, ShareControllerDelegate, FriendSuggestionDelegate, StixEditorDelegate, StixPanelPurchaseDelegate, NewsletterViewDelegate, UIWebViewDelegate, DetailViewDelegate, CommentViewDelegate> {
    
    UIWindow *window;
    
    UIViewController * rootController;
    UINavigationController * nav;
    
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
    FriendSuggestionController * friendSuggestionController;
    NewsletterViewController * newsController;
    
    UIViewController * __weak lastViewController;

    bool loggedIn;
    bool isLoggingIn;
    struct UserInfo * myUserInfo;
    NSString * myUserInfo_username;
    UIImage * myUserInfo_userphoto;
    NSString * myUserInfo_email;
    NSString * myUserInfo_facebookString;

    bool stixViewsLoadedFromDisk;
    bool fbLoginIsJoin;
    
    NSMutableDictionary * allStix;
    NSMutableDictionary * allStixOrder;
    //NSMutableSet * allFriends;
    NSMutableSet * allFollowers;
    NSMutableSet * allFollowing;
    NSMutableArray * allTags;
    NSMutableDictionary * allCommentCounts;
    
    
    //Tag * newestTag;
    NSDate * timeStampOfMostRecentTag;
    int idOfNewestTagOnServer;
    int idOfOldestTagOnServer;
    int idOfNewestTagReceived;
    int idOfOldestTagReceived;
    int idOfLastTagChecked;
    int idOfCurrentTag; // current tag being displayed
    int jumpPendingTagID;
    
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
    //int shareMethod; // 0 = facebook, 1 = email

    BOOL isDisplayingShareSheet;
    BOOL isDisplayingBuxMenu;
    
    int buyBuxPurchaseAmount;
    UIImageView * buxPurchaseMenu;
    NSMutableArray * buxPurchaseButtons;
    UIButton * buttonBuxPurchaseClose;
    BOOL isShowingBuxPurchaseMenu;
    
    NSMutableDictionary * allUsers;
    int idOfMostRecentUser;
    NSMutableSet * featuredUsers;
    
    IBOutlet UITextField * loadingMessage;

    NSData * notificationDeviceToken; // if nil, not ready to register yet
    int notificationBookmarkType;
    NSNumber * notificationTagID;
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
    
    BOOL mkStoreKitSuccess; // hack
    FeedbackViewController * feedbackController;
    
    // share services
    ShareController * shareController;
    BOOL newPixDidClickShare;
    BOOL newPixDidFinishUpload;
    
    NSMutableSet * Parse_subscribedChannels;
    
    BOOL didGetFollowingLists;
    BOOL didStartFirstTimeMessage; // didLoginWithUsername can be called twice, and if firstTimeMessage is called twice it will cause a bug where the arrow doesn't go away
    BOOL isShowingFriendSuggestions; // prevents firstTimeMessage arrow from being shown if friendSuggestions shown
    BOOL didDismissFriendSuggestions; // prevents friend suggestions from repopping up
    BOOL didGetAllUsers;
    
    // sync flags for updating stix layers
    // when a new pic is created, createPix is called while the stix layer is being edited
    // when the editor is closed, readyToUploadPendingStixLayer must be set to something other than -1 for
    // the delegate to call upload stix, otherwise it sets hasPendingStixLayerToUpload
    BOOL hasPendingStixLayerToUpload;
    int readyToUploadPendingStixLayer_tagID;
    BOOL addAutomaticFollows; // friendSuggestionController causes the followList to be cleared, so set this to force the automatically followed users to stay in the list
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
-(void) adminSetAllUsersBuxCounts;
-(void)adminEasterEggShowMenu:(NSString*)password;
//-(void)updateUserTagTotal;
//-(void)changeBuxCountByAmount:(int)change;
//-(void)adminSaveFeed;
-(void)adminResetAllStixOrders;

-(void) getTagWithID:(int)tagID;

-(void) Parse_subscribeToChannel:(NSString*) channel;
-(void) Parse_unsubscribeFromChannel:(NSString*)channel;
-(void) Parse_sendBadgedNotification:(NSString*)message OfType:(int)type toChannel:(NSString*) channel withTag:(NSNumber*)tagID;

-(void) Parse_createSubscriptions;
-(void)handleNotificationBookmarks:(bool)doJump withMessage:(NSString*)message;
-(void)showAllAlerts;
-(void)reloadAllCarousels;
//-(void)rewardBux;
//-(void)rewardLocation;
-(void)logMetricTimeInApp;
//-(void)checkConsistency;
//-(void)updateBuxCountFromKumulos;
-(void)didDismissSecondaryView;
// former store methods
//-(void)updateBuxCount;
-(void)didGetStixFromStore:(NSString*)stixStringID;
-(void)didPurchaseBux:(int)buxPurchased;

-(void)hideFirstTimeUserMessage;
-(void)advanceFirstTimeUserMessage;
-(void)agitateFirstTimePointer;
- (void)didLoginWithUsername:(NSString *)name andPhoto:(UIImage *)photo andEmail:(NSString*)email andFacebookString:(NSString*)facebookString andUserID:(NSNumber*)userID andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary *)stixOrder;
-(void)getFirstTags;
-(void)displayShareController;
-(void)uploadImage:(NSData *)dataPNG;
-(void)initializeShareController;

-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID;    
-(void)didAddCommentFromDetailViewController:(DetailViewController*)detailViewController withTag:(Tag*)tag andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID;
-(void)doParallelNewPixShare:(Tag*)_tag;

-(void)loadCachedTags;
-(void)saveCachedTags;

-(void)initializeFriendSuggestionController;

-(void)getFollowListsWithoutAggregation:(NSString*)name;
-(void)getFollowListsForAggregation:(NSString*)name;

//-(void)showTwitterDialog;
-(void)shouldDisplayStixEditor:(Tag*)newTag withRemixMode:(int)remixMode;

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) UIViewController * emptyViewController;
@property (nonatomic) RaisedCenterTabBarController *tabBarController;
@property (nonatomic) TagViewController *tagViewController;
//@property (nonatomic, retain) FeedViewController *feedController;
@property (nonatomic) VerticalFeedController *feedController;
@property (nonatomic) ProfileViewController *profileController;
@property (nonatomic) UserProfileViewController *userProfileController;
//@property (nonatomic, retain) FriendsViewController *friendController;
@property (nonatomic) ExploreViewController *exploreController;
@property (nonatomic) FacebookLoginController * loginSplashController;
@property (nonatomic) FriendSuggestionController * friendSuggestionController;
@property (nonatomic) NewsletterViewController * newsController;
@property (nonatomic) StixEditorViewController * editorController;
@property (nonatomic, assign) struct UserInfo * myUserInfo;
@property (nonatomic, weak) UIViewController * lastViewController;
@property (nonatomic) NSMutableArray * allTags;
@property (nonatomic) NSMutableDictionary * allTagIDs; // fast check for existence of allTags
@property (nonatomic) NSDate * timeStampOfMostRecentTag;
@property (nonatomic) NSMutableDictionary * allUsers;
@property (nonatomic) NSMutableDictionary * allUserPhotos;
@property (nonatomic) NSMutableDictionary * allStix;
@property (nonatomic) NSMutableDictionary * allStixOrder;
//@property (nonatomic, retain) NSMutableSet * allFriends;
@property (nonatomic) NSMutableSet * allFollowers;
@property (nonatomic) NSMutableSet * allFollowing;
@property (nonatomic) NSMutableArray * allUserFacebookStrings;
@property (nonatomic) NSMutableArray * allUserTwitterStrings;
@property (nonatomic) NSMutableArray * allUserEmails;
@property (nonatomic) NSMutableArray * allUserNames;
@property (nonatomic) NSMutableDictionary * allUserIDs;
@property (nonatomic) NSMutableSet * featuredUsers;
@property (nonatomic) Kumulos * k;
@property (nonatomic) NSMutableDictionary * allCommentCounts;
@property (nonatomic) NSMutableDictionary * allCommentHistories;
@property (nonatomic) IBOutlet UITextField * loadingMessage;
@property (nonatomic) NSMutableArray * alertQueue;
@property (nonatomic) UIImagePickerController * camera;
@property (nonatomic) NSDate * metricLogonTime;
@property (nonatomic) NSDate * lastKumulosErrorTimestamp;
@property (nonatomic) FacebookHelper * fbHelper;
@property (nonatomic) Tag * tagToRemix; // saves tag for alertview response

@end

