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

@interface StixxAppDelegate : NSObject <UIApplicationDelegate, TagViewDelegate, UIImagePickerControllerDelegate, UITabBarControllerDelegate, ProfileViewDelegate, FeedViewDelegate, KumulosDelegate, FriendsViewDelegate, ExploreViewDelegate, RaisedCenterTabBarControllerDelegate> {
    UIWindow *window;
    
	RaisedCenterTabBarController * tabBarController; // tab bar for maintaining multiple views
	TagViewController * tagViewController;
	FeedViewController *feedController;
	FriendsViewController *friendController;
	ProfileViewController *profileController;
    ExploreViewController * exploreController;
    
    UIViewController * lastViewController;
    BadgeView * lastBadgeView;

    bool loggedIn;
    NSString * username;
    UIImage * userphoto;
    int usertagtotal;

    NSMutableArray * allStix;
    NSMutableArray * allTags;
    
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
    
    NSMutableDictionary * allUserPhotos;
    int idOfMostRecentUser;
    
    Kumulos* k;
}

- (void)showAlertWithTitle:(NSString *) title andMessage:(NSString*)message andButton:(NSString*)buttonMsg;
-(NSString*)coordinateArrayPath; // calls FileHelpers.m to create path
-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RaisedCenterTabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet TagViewController *tagViewController;
@property (nonatomic, retain) FeedViewController *feedController;
@property (nonatomic, retain) ProfileViewController *profileController;
@property (nonatomic, retain) FriendsViewController *friendController;
@property (nonatomic, retain) ExploreViewController *exploreController;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) UIImage * userphoto;
@property (nonatomic, assign) int usertagtotal;
@property (nonatomic, assign) UIViewController * lastViewController;
@property (nonatomic, retain) NSMutableArray * allTags;
@property (nonatomic, retain) NSDate * timeStampOfMostRecentTag;
@property (nonatomic, retain) NSMutableDictionary * allUserPhotos;
@property (nonatomic, retain) NSMutableArray * allStix;
@property (nonatomic, assign) BadgeView * lastBadgeView;
@property (nonatomic, retain) Kumulos * k;
@end

