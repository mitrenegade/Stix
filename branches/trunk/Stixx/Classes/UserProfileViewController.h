//
//  ProfileViewController.h
//  ARKitDemo
//
//  Created by Administrator on 7/11/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kumulos.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import "BadgeView.h"
#import "KumulosData.h"
#import "FriendSearchResultsController.h"
#import "SMWebRequest.h"
#import "SMXMLDocument.h"
#import "LoadingAnimationView.h"
#import <AddressBook/AddressBook.h>
#import "UserGalleryController.h"
#import "DetailViewController.h"
#import "StixAnimation.h"
#import "ColumnTableController.h"
#import "FriendSearchResultsController.h"

@protocol UserProfileViewDelegate

-(NSString*)getUsername; // asks for username for the App user
- (UIImage *)getUserPhotoForUsername:(NSString*)username;
-(NSMutableSet*)getFollowingList;

-(void)shouldCloseUserPage;
-(void)shouldDisplayUserPage:(NSString*)username;
-(void)setFollowing:(NSString *)friendName toState:(BOOL)shouldFollow;

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;
@end

@interface UserProfileViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, KumulosDelegate, UINavigationControllerDelegate, FriendSearchResultsDelegate, UITextFieldDelegate, UISearchBarDelegate, UserGalleryDelegate, ColumnTableControllerDelegate, KumulosDelegate, StixViewDelegate, DetailViewDelegate, StixAnimationDelegate, UIActionSheetDelegate>{
    
    Kumulos * k;
    IBOutlet UIButton * logo;
        
    int userHistoryCount;
    int userCommentCount;
    
    // for gallery
    NSMutableArray * allTagIDs; // ordered in descending order
    NSMutableDictionary * allTags; // key: allTagID
    NSMutableDictionary * contentViews; // generated views: key: row/column index of table
    int numColumns;
    
    int dismissAnimation;
    
    BOOL isSearching;
    BOOL isDisplayingFollowLists;
    NSMutableArray * searchFriendName;
    NSMutableArray * searchFriendEmail;
    NSMutableArray * searchFriendFacebookID;
    NSMutableArray * searchFriendIsStix;
    
    NSMutableSet * allFollowers;
    NSMutableSet * allFollowing;
}

@property (nonatomic, retain) UIImageView * photoButton;
@property (nonatomic, retain) UIButton * buttonAddFriend;
@property (nonatomic, retain) UILabel * nameLabel;
@property (nonatomic, copy) NSString * lastUsername;
@property (nonatomic, assign) NSObject<UserProfileViewDelegate> *delegate;
@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, copy) NSString * username;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, retain) UIButton * bgFollowers;
@property (nonatomic, retain) UIButton * bgFollowing;
@property (nonatomic, retain) OutlineLabel * myFollowersCount;
@property (nonatomic, retain) OutlineLabel * myFollowingCount;
@property (nonatomic, retain) OutlineLabel * myFollowersLabel;
@property (nonatomic, retain) OutlineLabel * myFollowingLabel;
@property (nonatomic, retain) OutlineLabel * myPixCount;
@property (nonatomic, retain) OutlineLabel * myStixCount;
@property (nonatomic, retain) OutlineLabel * myPixLabel;
@property (nonatomic, retain) OutlineLabel * myStixLabel;
@property (nonatomic, retain) ColumnTableController * pixTableController;
@property (nonatomic, retain) UIView * headerView;
@property (nonatomic, retain) DetailViewController * detailController;
@property (nonatomic, retain) FriendSearchResultsController * searchResultsController;

-(void)populateUserInfo;
-(void)populateFollowCounts;
-(void)updateFollowCounts;
-(void)updateStixCounts;
-(IBAction)didClickAddFriendButton:(id)sender;
-(void)forceReloadAll;
-(void)populateFollowersList;
-(void)populateFollowingList;
-(void)toggleMyButtons:(BOOL)show;

@end
