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
#import "FriendSearchTableViewController.h"
#import "LoadingAnimationView.h"
#import "KumulosHelper.h"

@protocol FriendSuggestionDelegate <NSObject>

-(void)searchFriendsOnStix;
-(NSMutableArray*)getAllUserFacebookStrings;
-(void)shouldCloseFriendSuggestionControllerWithNames:(NSArray*)addedFriends;
-(UIImage*)getUserPhotoForUsername:(NSString *)username;
-(void)friendSuggestionControllerFinishedLoading:(int)totalSuggestions;
-(NSMutableSet*)getFollowingList;
-(NSString*)getUsername;
-(NSString*)getNameForFacebookString:(NSString*)_facebookString;
-(void)didGetFeaturedUsers:(NSArray*)featured;
@end

@interface FriendSuggestionController : UIViewController  <FriendSearchTableDelegate, KumulosDelegate, KumulosHelperDelegate>
{    
    NSObject<FriendSuggestionDelegate>* __unsafe_unretained delegate;
    
    FriendSearchTableViewController * tableViewController;
    IBOutlet UIButton * buttonEdit;
    IBOutlet UIButton * buttonNext;
    IBOutlet UIImageView * tabGraphic;

    // debug
    IBOutlet UIButton * refresh;
    
    NSMutableArray * friends;
    NSMutableArray * friendsIDs;
    NSMutableArray * featured;
    NSMutableArray * featuredDesc;
    NSMutableDictionary * userPhotos;
    Kumulos * k;
    
    LoadingAnimationView * activityIndicatorLarge;
    
    NSMutableArray * headerViews;
    
    BOOL didGetFeaturedUsers;
    BOOL didGetFacebookFriends;
    BOOL isEditing;
}
@property (nonatomic, unsafe_unretained) NSObject<FriendSuggestionDelegate> *delegate;
@property (nonatomic) FriendSearchTableViewController * tableViewController;
@property (nonatomic) IBOutlet UIButton * buttonEdit;
@property (nonatomic) IBOutlet UIButton * buttonNext;
@property (nonatomic) IBOutlet UIButton * refresh;

-(void)startActivityIndicatorLarge;
-(void)stopActivityIndicatorLarge;

-(IBAction)didClickButtonEdit:(id)sender;
-(IBAction)didClickButtonNext:(id)sender;
-(void)populateFacebookSearchResults:(NSArray*)facebookFriendArray;
-(void)initializeSuggestions;
-(IBAction)didClickButtonRefresh:(id)sender;
-(void)refreshUserPhotos;
@end
