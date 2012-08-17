//
//  FriendSearchTableViewController.h
//  Stixx
//
//  Created by Bobby Ren on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  table-only view of friends/featured list, like FriendSuggestionController but no header
// currently only used by ProfileViewController

#import <UIKit/UIKit.h>
#import "GlobalHeaders.h"

#define ROW_HEIGHT 45
#define HEADER_HEIGHT 24
#define TOP_LABEL_TAG 1001
#define BOTTOM_LABEL_TAG 1002
#define PICTURE_HEIGHT 33

@protocol FriendSearchTableDelegate <NSObject>
-(int)friendsCount;
-(int)featuredCount;
-(NSString*)getFriendAtIndex:(int)index;
-(NSString*)getFeaturedAtIndex:(int)index;
-(NSString*)getFeaturedDescriptorAtIndex:(int)index;
-(UIImage*)getUserPhotoForUsername:(NSString*)username;
-(int)numberOfSections;
-(UIView*)headerViewForSection:(int)section;
-(void)removeFriendAtRow:(int)row;
-(void)removeFeaturedAtRow:(int)row;
-(void)didSelectFriendSearchIndexPath:(NSIndexPath*)indexPath;
@optional
-(void)didDeleteAllEntries;
-(void)shouldDisplayUserPage:(NSString*)name;
@end
@interface FriendSearchTableViewController : UITableViewController
{
    NSObject<FriendSearchTableDelegate> * __unsafe_unretained delegate;
    BOOL showAccessoryButton;
}

@property (nonatomic, unsafe_unretained) NSObject<FriendSearchTableDelegate> * delegate;
@property (nonatomic, assign) BOOL showAccessoryButton;
-(void)startEditing;
-(void)stopEditing;
@end
