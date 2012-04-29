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
-(UIImage*)getUserPhotoForUser:(int)index;
-(NSString*)getUserEmailForUser:(int)index;
-(NSString*)getFacebookIDForUser:(int)index;
//-(BOOL)isFollowingUser:(int)index;
-(int)getFollowingUserStatus:(int)index;
-(int)getNumOfUsers;
-(void)didClickAddFriendButton:(int)index;
-(void)didSelectUserProfile:(int)index;
@end

@interface FriendSearchResultsController : UITableViewController 

@property ( nonatomic) NSMutableDictionary * userPhotos;
//@property (retain, nonatomic) NSMutableArray * usernames;
//@property (retain, nonatomic) NSMutableDictionary * userEmails;
@property ( nonatomic) NSMutableDictionary * userButtons;

@property ( nonatomic) NSObject<FriendSearchResultsDelegate> * delegate;

@end
