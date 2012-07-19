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

@protocol FriendServicesDelegate <NSObject>

-(void)shouldCloseFriendServices;
-(NSString*)getUsername;

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
-(void)inviteUser:(NSString*)name;
@end

@interface FriendServicesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, StixUsersViewDelegate>
{
    NSObject<FriendServicesDelegate> * __unsafe_unretained delegate;
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonBack;
    IBOutlet UIImageView * logo;
    NSMutableArray * buttonNames;
    NSMutableArray * buttonIcons;
    
    int mode; // 0 = find, 1 = invite, 2 = search
    
    IBOutlet UISearchBar * searchBar;
    StixUsersViewController * stixUsersController;;
    
    NSMutableArray * searchFriendName;
    NSMutableArray * searchFriendEmail;
    NSMutableArray * searchFriendID;
    NSMutableArray * searchFriendIsStix;
    NSMutableArray * searchFriendPhone; // only for contact list

}
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic, unsafe_unretained) NSObject<FriendServicesDelegate> * delegate;
@property (nonatomic) IBOutlet UIButton * buttonBack;
@property (nonatomic) IBOutlet UIImageView * logo;
@property (nonatomic) IBOutlet UISearchBar * searchBar;
@property (nonatomic, assign) int mode;

-(void)initializeForMode:(int)_mode;
-(IBAction)didClickBackButton:(id)sender;
@end
