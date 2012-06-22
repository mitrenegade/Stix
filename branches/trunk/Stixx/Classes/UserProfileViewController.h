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
#import "KumulosHelper.h"
#import "FlurryAnalytics.h"
#import "GlobalHeaders.h"

@protocol UserProfileViewDelegate

-(NSString*)getUsername; // asks for username for the App user
- (UIImage *)getUserPhotoForUsername:(NSString*)username;
-(NSMutableSet*)getFollowingList;

-(void)shouldCloseUserPage;
-(void)shouldDisplayUserPage:(NSString*)username;
-(void)setFollowing:(NSString *)friendName toState:(BOOL)shouldFollow;

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;
-(NSMutableDictionary *) getUserPhotos;
-(void)didClickRemixFromDetailViewWithTag:(Tag*)tagToRemix;
@end

@interface UserProfileViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, KumulosDelegate, UINavigationControllerDelegate, FriendSearchResultsDelegate, UITextFieldDelegate, UISearchBarDelegate, UserGalleryDelegate, ColumnTableControllerDelegate, KumulosDelegate, StixViewDelegate, DetailViewDelegate, StixAnimationDelegate, UIActionSheetDelegate, KumulosHelperDelegate>{
    
    Kumulos * k;
    IBOutlet UIButton * logo;
        
    int userHistoryCount;
    int userCommentCount;
    
    // for gallery
    NSMutableArray * allTagIDs; // ordered in descending order
    NSMutableDictionary * allTags; // key: allTagID
    NSMutableDictionary * contentViews; // generated views: key: row/column index of table
    NSMutableDictionary * placeholderViews;
    NSMutableDictionary * isShowingPlaceholderView;
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
    
    int pendingContentCount;
}

@property (nonatomic) UIImageView * photoButton;
@property (nonatomic) UIButton * buttonAddFriend;
@property (nonatomic) UILabel * nameLabel;
@property (nonatomic, copy) NSString * lastUsername;
@property (nonatomic, unsafe_unretained) NSObject<UserProfileViewDelegate> *delegate;
@property (nonatomic) Kumulos * k;
@property (nonatomic, copy) NSString * username;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) UIButton * bgFollowers;
@property (nonatomic) UIButton * bgFollowing;
@property (nonatomic) OutlineLabel * myFollowersCount;
@property (nonatomic) OutlineLabel * myFollowingCount;
@property (nonatomic) OutlineLabel * myFollowersLabel;
@property (nonatomic) OutlineLabel * myFollowingLabel;
@property (nonatomic) OutlineLabel * myPixCount;
@property (nonatomic) OutlineLabel * myStixCount;
@property (nonatomic) OutlineLabel * myPixLabel;
@property (nonatomic) OutlineLabel * myStixLabel;
@property (nonatomic) ColumnTableController * pixTableController;
@property (nonatomic) UIView * headerView;
@property (nonatomic) DetailViewController * detailController;
@property (nonatomic) FriendSearchResultsController * searchResultsController;

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
