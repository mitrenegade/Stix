//
//  StixxAppDelegate.h
//  Stixx
//
//  Created by Bobby Ren on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TagViewController.h"
#import "FeedViewController.h"
#import "ProfileViewController.h"
#import "FriendsViewController.h"
#import "TagDescriptorController.h"
#import "ExploreViewController.h"
#import "Kumulos.h"
#import "Tag.h"
#import "ARCoordinate.h"
#import "BadgeView.h"
#import "RaisedCenterTabBarController.h"
#import "LoginSplashController.h"
#import "MyStixViewController.h"
#import "LoadingViewController.h"
#import "FeedbackViewController.h"
#import <Parse/Parse.h>

enum notification_bookmarks {
    NB_NEWSTIX = 0,
    NB_NEWCOMMENT,
    NB_NEWGIFT,
    NB_PEELACTION,
    NB_UPDATECAROUSEL
};

@interface StixxAppDelegate : NSObject <UIApplicationDelegate, TagViewDelegate, UIImagePickerControllerDelegate, UITabBarControllerDelegate, ProfileViewDelegate, FeedViewDelegate, KumulosDelegate, FriendsViewDelegate, ExploreViewDelegate, RaisedCenterTabBarControllerDelegate, LoginSplashDelegate, MyStixViewDelegate, FeedbackViewDelegate> {
    UIWindow *window;
    
	RaisedCenterTabBarController * tabBarController; // tab bar for maintaining multiple views
	//UITabBarController * tabBarController; 	TagViewController * tagViewController;
	FeedViewController *feedController;
	FriendsViewController *friendController;
	ProfileViewController *profileController;
    ExploreViewController * exploreController;
    LoginSplashController * loginSplashController;
    MyStixViewController * myStixController;
//    LoadingViewController * loadingController;
    
    UIViewController * lastViewController;
    CarouselView * lastCarouselView;

    bool loggedIn;
    bool isLoggingIn;
    NSString * username;
    UIImage * userphoto;
    int usertagtotal;
    
    NSMutableDictionary * allStix;
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
    float updatingAuxScale;
    float updatingAuxRotation;
    
    // hack: for peelable stix actions
    bool isUpdatingPeelableStix;
    int updatingPeelableTagIndex;
    int updatingPeelableTagID;
    int updatingPeelableAuxStixIndex;
    int updatingPeelableAction;
    
    NSMutableDictionary * allUserPhotos;
    int idOfMostRecentUser;
    
    IBOutlet UITextField * loadingMessage;
    
    int notificationBookmarkType;
    int notificationTagID;
    NSString * notificationTargetChannel;
    bool updatingNotifiedTagDoJump;
    bool isUpdatingNotifiedTag;
    NSString * notificationGiftStixStringID;
    
    NSMutableArray * alertQueue;
    
    Kumulos* k;
}

- (void)showAlertWithTitle:(NSString *) title andMessage:(NSString*)message andButton:(NSString*)buttonTitle andOtherButton:(NSString*)otherButtonTitle;
-(NSString*)coordinateArrayPath; // calls FileHelpers.m to create path
-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID;
-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID overwrite:(bool)bOverwrite;
-(void)updateCommentCount:(int)tagID;
-(void)continueInit;
-(void)adminUpdateAllStixCountsToZero;
-(void)adminIncrementAllStixCounts;
-(void)updateUserTagTotal;

-(void)decrementStixCount:(NSString*)stixStringID;
-(void)incrementStixCount:(NSString*)stixStringID;
-(Tag*) getTagWithID:(int)tagID;

-(void) Parse_subscribeToChannel:(NSString*) channel;
//-(void) Parse_sendNotification:(NSString*) message toChannel:(NSString*) channel;
//-(void) Parse_sendBadgedNotification:(NSString*)message toChannel:(NSString*) channel;
//-(void) Parse_sendBadgedNotification:(NSString*)message toChannel:(NSString*) channel withTag:(Tag*)tag;
-(void) Parse_sendBadgedNotification:(NSString*)message OfType:(int)type toChannel:(NSString*) channel withTag:(Tag*)tag orGiftStix:(NSString*)giftStixStringID;
-(void)handleNotificationBookmarks:(bool)doJump;
-(void)showAllAlerts;
-(void)reloadAllCarousels;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RaisedCenterTabBarController *tabBarController;
//@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet TagViewController *tagViewController;
@property (nonatomic, retain) FeedViewController *feedController;
@property (nonatomic, retain) ProfileViewController *profileController;
@property (nonatomic, retain) FriendsViewController *friendController;
@property (nonatomic, retain) ExploreViewController *exploreController;
@property (nonatomic, retain) LoginSplashController * loginSplashController;
@property (nonatomic, retain) MyStixViewController * myStixController;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) UIImage * userphoto;
@property (nonatomic, assign) int usertagtotal;
@property (nonatomic, assign) UIViewController * lastViewController;
@property (nonatomic, retain) NSMutableArray * allTags;
@property (nonatomic, retain) NSDate * timeStampOfMostRecentTag;
@property (nonatomic, retain) NSMutableDictionary * allUserPhotos;
@property (nonatomic, retain) NSMutableDictionary * allStix;
@property (nonatomic, assign) CarouselView * lastCarouselView;
@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, retain) NSMutableDictionary * allCommentCounts;
@property (nonatomic, retain) NSMutableArray * allCarouselViews;
@property (nonatomic, retain) IBOutlet UITextField * loadingMessage;
@property (nonatomic, retain) NSMutableArray * alertQueue;
@end

