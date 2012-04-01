//
//  FriendSearchResultsController.h
//  Stixx
//
//  Created by Irene Chen on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendSearchResultsDelegate 

-(NSString*)getUsernameForUser:(int)index;
-(UIImage*)getUserPhotoForUser:(int)index;
-(NSString*)getUserEmailForUser:(int)index;
-(NSString*)getFacebookIDForUser:(int)index;
//-(BOOL)isFollowingUser:(int)index;
-(int)getFollowingUserStatus:(int)index;
-(int)getNumOfUsers;
-(void)didClickAddFriendButton:(int)index;
@end

@interface FriendSearchResultsController : UITableViewController 

//@property (retain, nonatomic) NSMutableDictionary * userPhotos;
//@property (retain, nonatomic) NSMutableArray * usernames;
//@property (retain, nonatomic) NSMutableDictionary * userEmails;
@property (retain, nonatomic) NSMutableDictionary * userButtons;

@property (retain, nonatomic) NSObject<FriendSearchResultsDelegate> * delegate;

@end
