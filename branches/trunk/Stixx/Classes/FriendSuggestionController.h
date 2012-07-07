//
//  FriendSuggestionController.h
//  Stixx
//
//  Created by Bobby Ren on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kumulos.h"
#import "GlobalHeaders.h"
#import "FlurryAnalytics.h"

enum {
    SUGGESTIONS_SECTION_FEATURED = 0,
    SUGGESTIONS_SECTION_FRIENDS = 1,
    SUGGESTIONS_SECTION_MAX
};

@protocol FriendSuggestionDelegate <NSObject>

-(void)searchFriendsOnStix;
-(NSMutableArray*)getAllUserFacebookStrings;
-(void)shouldCloseFriendSuggestionControllerWithNames:(NSArray*)addedFriends;
-(UIImage*)getUserPhotoForUsername:(NSString *)username;
-(void)friendSuggestionControllerFinishedLoading:(int)totalSuggestions;
-(NSMutableSet*)getFollowingList;
-(NSString*)getUsername;
-(NSString*)getNameForFacebookString:(NSString*)_facebookString;
@end

@interface FriendSuggestionController : UIViewController  <UITableViewDelegate, UITableViewDataSource, KumulosDelegate>
{    
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonEdit;
    IBOutlet UIButton * buttonNext;

    // debug
    IBOutlet UIButton * refresh;
    
    NSMutableArray * friends;
    NSMutableArray * friendsIDs;
    NSMutableArray * featured;
    NSMutableArray * featuredDesc;
    NSMutableDictionary * userPhotos;
    Kumulos * k;
    
    NSObject<FriendSuggestionDelegate>* __unsafe_unretained delegate;
    
    NSMutableArray * headerViews;
    
    BOOL didGetFeaturedUsers;
    BOOL didGetFacebookFriends;
    BOOL isEditing;
}
@property (nonatomic, unsafe_unretained) NSObject<FriendSuggestionDelegate> *delegate;
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) IBOutlet UIButton * buttonEdit;
@property (nonatomic) IBOutlet UIButton * buttonNext;
@property (nonatomic) IBOutlet UIButton * refresh;

-(IBAction)didClickButtonEdit:(id)sender;
-(IBAction)didClickButtonNext:(id)sender;
-(void)populateFacebookSearchResults:(NSArray*)facebookFriendArray;
-(void)initializeSuggestions;
-(IBAction)didClickButtonRefresh:(id)sender;
-(void)refreshUserPhotos;
@end
