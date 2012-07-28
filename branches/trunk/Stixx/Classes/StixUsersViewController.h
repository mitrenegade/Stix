//
//  StixUsersViewController.h
//  Stixx
//
//  Created by Bobby Ren on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// used only by FriendServicesViewController

#import <UIKit/UIKit.h>
#import "GlobalHeaders.h"

#define ROW_HEIGHT 45
#define TOP_LABEL_TAG 1001
#define BOTTOM_LABEL_TAG 1002

@protocol StixUsersViewDelegate <NSObject>

-(int)getNumOfUsers;
-(NSString*)getUsernameForUserAtIndex:(int)index;
-(UIImage*)getUserPhotoForUserAtIndex:(int)index;
-(NSString*)getUserEmailForUserAtIndex:(int)index;
//-(NSString*)getFacebookStringForUserAtIndex:(int)index;
//-(BOOL)isFollowingUser:(int)index;
-(int)getFollowingUserStatus:(int)index;
/*
-(void)followUser:(NSString*)name;
-(void)unfollowUser:(NSString*)name;
-(void)inviteUser:(NSString*)name;
 */
-(void)followUserAtIndex:(int)index;
-(void)unfollowUserAtIndex:(int)index;
-(void)inviteUserAtIndex:(int)index;
-(void)followAllUsers;
-(void)inviteAllUsers;

-(void)shouldDisplayUserPage:(NSString*)name;
-(void)switchToInviteMode;
@end

@interface StixUsersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSObject<StixUsersViewDelegate> * __unsafe_unretained delegate;
    IBOutlet UIButton * buttonBack;
    IBOutlet UIButton * buttonAll;
    IBOutlet UIImageView * logo;
    IBOutlet UITableView * tableView;
    
    IBOutlet UILabel * noFriendsLabel;
    IBOutlet UIButton * noFriendsButton;
    
    NSMutableDictionary * userButtons;
    NSMutableDictionary * userPhotos;

    int mode;
}
@property (nonatomic) IBOutlet UIButton * buttonBack;
@property (nonatomic) IBOutlet UIButton * buttonAll;
@property (nonatomic) IBOutlet UIImageView * logo;
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) IBOutlet UILabel * noFriendsLabel;
@property (nonatomic) IBOutlet UIButton * noFriendsButton;
@property (nonatomic, unsafe_unretained) NSObject<StixUsersViewDelegate> * delegate;
@property (nonatomic) NSMutableDictionary * userButtons;
@property (nonatomic) NSMutableDictionary * userPhotos;
@property (nonatomic, assign) int mode;

-(IBAction)didClickBackButton:(id)sender;
-(IBAction)didClickAllButton:(id)sender;
-(IBAction)goToInvite;
-(void)setLogoWithMode:(int)_mode;
@end
