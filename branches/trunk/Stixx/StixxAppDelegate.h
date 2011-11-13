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
#import "ConfigViewController.h"
#import "FriendsViewController.h"
#import "TagDescriptorController.h"
#import "ExploreViewController.h"
#import "Kumulos.h"
#import "Tag.h"
#import "ARCoordinate.h"
#import "LoginViewController.h"

@interface StixxAppDelegate : NSObject <UIApplicationDelegate, TagViewDelegate, UIImagePickerControllerDelegate, UITabBarControllerDelegate, ConfigViewDelegate, FeedViewDelegate, KumulosDelegate, FriendsViewDelegate, LoginViewDelegate> {
    UIWindow *window;
    
	UITabBarController * tabBarController; // tab bar for maintaining multiple views
	TagViewController * tagViewController;
	FeedViewController *feedController;
	FriendsViewController *friendController;
	ConfigViewController *configController;
    ExploreViewController * exploreController;
    
    UIViewController * lastViewController;

    bool loggedIn;
    NSString * username;
    UIImage * userphoto;

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
-(Tag *) getTagFromDictionary:(NSMutableDictionary*)d;
-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet TagViewController *tagViewController;
@property (nonatomic, retain) FeedViewController *feedController;
@property (nonatomic, retain) ConfigViewController *configController;
@property (nonatomic, retain) FriendsViewController *friendController;
@property (nonatomic, retain) ExploreViewController *exploreController;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) UIImage * userphoto;
@property (nonatomic, assign) UIViewController * lastViewController;
@property (nonatomic, retain) NSMutableArray * allTags;
@property (nonatomic, retain) NSDate * timeStampOfMostRecentTag;
@property (nonatomic, retain) NSMutableDictionary * allUserPhotos;
@property (nonatomic, retain) Kumulos * k;
@end

