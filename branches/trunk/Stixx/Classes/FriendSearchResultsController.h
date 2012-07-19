//
//  FriendSearchResultsController.h
//  Stixx
//
//  Created by Irene Chen on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendSearchResultsDelegate 
@optional
-(NSString*)getUsernameForUser:(int)index;
-(UIImage*)getUserPhotoForUserAtIndex:(int)index;
-(NSString*)getUserEmailForUser:(int)index;
-(NSString*)getFacebookStringForUser:(int)index;
//-(BOOL)isFollowingUser:(int)index;
-(int)getFollowingUserStatus:(int)index;
-(int)getNumOfUsers;
//-(void)didClickAddFriendButton:(int)index; // for that single button to add friend of this profile
-(void)didSelectUserProfile:(int)index;
-(void)addFriendFromList:(int)index; // for friends in list
@end

@interface FriendSearchResultsController : UITableViewController 
{
}
@property ( nonatomic) NSMutableDictionary * userPhotos;
//@property (retain, nonatomic) NSMutableArray * usernames;
//@property (retain, nonatomic) NSMutableDictionary * userEmails;
@property ( nonatomic) NSMutableDictionary * userButtons;

@property ( nonatomic) NSObject<FriendSearchResultsDelegate> * delegate;

@end
