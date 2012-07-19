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
#import "UserGalleryController.h"
//#import "SearchByNameController.h"
#import <AddressBook/AddressBook.h>
#import "FriendServicesViewController.h"
@protocol ProfileViewDelegate
-(NSMutableSet*)getFollowingList;
-(BOOL)isFollowing:(NSString*)name;
-(NSMutableArray*)getAllUserFacebookStrings;
-(NSString*)getUsername;
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
-(void)shouldCloseUserPage;
@end

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FriendSearchTableDelegate, KumulosDelegate, StixAnimationDelegate, FriendSearchResultsDelegate, UserGalleryDelegate, UINavigationControllerDelegate, FriendServicesDelegate, UIScrollViewDelegate>
{
    IBOutlet UIScrollView * scrollView;
    
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

    BOOL waitingForFacebookLogin;
    
    BOOL showPointer;
    BOOL didGetFacebookFriends;
    BOOL didGetFeaturedUsers;
    BOOL isSearching;
    
    // facebook friends
    NSMutableArray * allFacebookFriendNames;
    NSMutableArray * allFacebookFriendStrings;
    
    // contact friends
    NSMutableArray * allContacts;
    
    NSObject<ProfileViewDelegate> * __unsafe_unretained delegate;
    LoadingAnimationView * activityIndicator;
    
    //SearchByNameController * searchByNameController;
    
    //UINavigationController * navController;
    FriendServicesViewController * servicesController;
}

@property (nonatomic, unsafe_unretained) NSObject<ProfileViewDelegate> * delegate;
@property (nonatomic) LoadingAnimationView * activityIndicator;
//@property (nonatomic) IBOutlet UITableView * buttonsTableView;
@property (nonatomic) FriendServicesViewController * servicesController;
@property (nonatomic) IBOutlet UIScrollView * scrollView;

-(void)didGetFacebookFriends:(NSArray*)facebookFriendArray;
-(void)didLoginToFacebook;
-(void)didCancelFacebookLogin;
-(void)didLogin;
-(void)doPointerAnimation;

@end
