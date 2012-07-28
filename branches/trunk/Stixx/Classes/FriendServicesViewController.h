//
//  FriendServicesViewController.h
//  Stixx
//
//  Created by Bobby Ren on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalHeaders.h"
#import "StixUsersViewController.h"
#import "FacebookHelper.h"
#import "TwitterHelper.h"
#import "LoadingAnimationView.h"

@protocol FriendServicesDelegate <NSObject>

-(void)shouldCloseFriendServices;
-(NSString*)getUsername;
-(NSString*)getFacebookString;
-(int)getUserID;

-(NSMutableDictionary*)getAllUsers;
-(NSMutableArray*)getAllUserNames;
-(NSMutableArray*)getAllUserEmails;
-(NSMutableArray*)getAllUserFacebookStrings;
-(NSMutableArray*)getAllFacebookFriendNames;
-(NSMutableArray*)getAllFacebookFriendStrings;
-(UIImage*)getUserPhotoForUsername:(NSString*)username;
-(BOOL)isFollowing:(NSString*)name;
-(NSMutableArray*)getAllContacts;

-(void)followUser:(NSString*)name;
-(void)unfollowUser:(NSString*)name;
-(void)inviteUser:(NSString*)name withService:(int)service;

-(void)didGetTwitterFriends:(NSArray*)friendArray;
-(NSMutableArray*)getAllTwitterFriendNames;
-(NSMutableArray*)getAllTwitterFriendScreennames;
-(BOOL)hasTwitterFriends;
-(void)reloadSuggestions;

-(void)shouldDisplayUserPage:(NSString*)name;
@end

@interface FriendServicesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, StixUsersViewDelegate, TwitterHelperDelegate, UIAlertViewDelegate, FacebookHelperDelegate>
{
    NSObject<FriendServicesDelegate> * __unsafe_unretained delegate;
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonBack;
    IBOutlet UIImageView * logo;
    NSMutableArray * buttonNames;
    NSMutableArray * buttonIcons;
    
    int mode; // 0 = find, 1 = invite, 2 = search
    int service;
    
    IBOutlet UISearchBar * searchBar;
    StixUsersViewController * stixUsersController;;
    
    NSMutableArray * searchFriendName;
    NSMutableArray * searchFriendEmail;
    NSMutableArray * searchFriendID;
    NSMutableArray * searchFriendIsStix;
    NSMutableArray * searchFriendScreenname; // twitter only, or other services with unique handles
    NSMutableArray * searchFriendPhone; // only for contact list
    
    LoadingAnimationView * activityIndicatorLarge;

    BOOL waitingForTwitter; // find or invite users requested twitter service but twitter was not connected - need to resume populateWithTwitter
    BOOL waitingForFacebook;
}
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic, unsafe_unretained) NSObject<FriendServicesDelegate> * delegate;
@property (nonatomic) IBOutlet UIButton * buttonBack;
@property (nonatomic) IBOutlet UIImageView * logo;
@property (nonatomic) IBOutlet UISearchBar * searchBar;
@property (nonatomic, assign) int mode;
@property (nonatomic) StixUsersViewController * stixUsersController;;


-(void)startActivityIndicatorLarge;
-(void)stopActivityIndicatorLarge;

-(void)initializeForMode:(int)_mode;
-(IBAction)didClickBackButton:(id)sender;

-(void)didInitialLoginForFacebook;
-(void)didGetFacebookFriends;
-(void)didCancelFacebookConnect;
@end
