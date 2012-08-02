//
//  ProfileViewController.h
//  Stixx
//
//  Created by Bobby Ren on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendSearchTableViewController.h"
#import "Kumulos.h"
#import "StixAnimation.h"
#import "LoadingAnimationView.h"
#import "FriendSearchResultsController.h"
#import "FacebookHelper.h"
#import <AddressBook/AddressBook.h>
#import "FriendServicesViewController.h"
#import "UserProfileViewController.h"

@protocol ProfileViewDelegate
-(NSMutableSet*)getFollowingList;
-(BOOL)isFollowing:(NSString*)name;
-(NSMutableArray*)getAllUserFacebookStrings;
-(NSString*)getUsername;
-(NSString*)getFacebookString;
-(int)getUserID;
-(NSString*)getNameForFacebookString:(NSString*)facebookString;
-(UIImage*)getUserPhotoForUsername:(NSString*)username;

-(void)searchFriendsOnStix;
-(void)searchFriendsByFacebook;

-(int)getFirstTimeUserStage;
-(void)advanceFirstTimeUserMessage;
-(BOOL)isLoggedIn;
-(void)didClickInviteButton;

-(NSMutableDictionary*)getAllUsers;
-(NSMutableArray*)getAllUserEmails;
-(NSMutableArray*)getAllUserNames;

-(void)setFollowing:(NSString*)username toState:(BOOL)isFollowing;
-(void)didClickInviteButtonByFacebook:(NSString*)username withFacebookString:(NSString*)facebookString;

-(void)shouldDisplayUserPage:(NSString*)username;
//-(void)shouldCloseUserPage;
-(void)didClickFeedbackButton:(NSString*)fromView;
@end

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FriendSearchTableDelegate, KumulosDelegate, StixAnimationDelegate, FriendSearchResultsDelegate, UINavigationControllerDelegate, FriendServicesDelegate, UIScrollViewDelegate, TwitterHelperDelegate, UIWebViewDelegate>
{
    UIScrollView * scrollView;
    
    UITableView * buttonsTableView;
    FriendSearchTableViewController * friendsTableView;
    //FriendSearchResultsController * searchResultsController;

    // friend suggestion controller
    NSMutableArray * suggestedFriends;
    NSMutableArray * suggestedFeatured;
    NSMutableArray * suggestedFeaturedDesc;
    NSMutableDictionary * userPhotos;
    Kumulos * k;
    
    NSMutableArray * buttonNames;
    NSMutableArray * buttonIcons;
    
    NSMutableArray * headerViews;

    BOOL showPointer;
    BOOL didGetFacebookFriends;
    BOOL didGetFeaturedUsers;
    BOOL isSearching;
    BOOL didGetTwitterFriends;
    
    // facebook friends
    NSMutableArray * allFacebookFriendNames;
    NSMutableArray * allFacebookFriendStrings;
    
    // contact friends
    NSMutableArray * allContacts;
    
    // twitter friends
    BOOL waitingForTwitterLogin;
    NSMutableArray * allTwitterFriendNames;
    NSMutableArray * allTwitterFriendScreennames;
    NSMutableArray * allTwitterFriendStrings;
    
    NSObject<ProfileViewDelegate> * __unsafe_unretained delegate;
    LoadingAnimationView * activityIndicator;
    
    //SearchByNameController * searchByNameController;
    
    //UINavigationController * navController;
    FriendServicesViewController * servicesController;
    UIImagePickerController * __unsafe_unretained camera;
    UIWebView * webView;
    
    
}

@property (nonatomic, unsafe_unretained) NSObject<ProfileViewDelegate> * delegate;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) FriendServicesViewController * servicesController;
@property (nonatomic) UIScrollView * scrollView;
@property (nonatomic, unsafe_unretained) UIImagePickerController * camera;
@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) IBOutlet UIButton * buttonAbout;
@property (nonatomic, retain) IBOutlet UIButton * buttonBack;

-(IBAction)didClickFeedbackButton:(id)sender;
-(IBAction)didClickAboutButton:(id)sender;
-(void)didGetFacebookFriends:(NSArray*)facebookFriendArray;
-(void)didConnectToFacebook;
-(void)didCancelFacebookConnect;
-(void)didLogin;
-(void)doPointerAnimation;
-(IBAction)closeTOS;
-(void)reloadSuggestions;
@end
