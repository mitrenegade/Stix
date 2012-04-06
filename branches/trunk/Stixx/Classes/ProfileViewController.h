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
#import "StixAnimation.h"

#define DEFAULT_STIX_COUNT 2

enum {
    RESULTS_SEARCH_CONTACTS = 0,
    RESULTS_SEARCH_FACEBOOK,
    RESULTS_SEARCH_NAME,
    RESULTS_FOLLOWING_LIST,
    RESULTS_FOLLOWERS_LIST
};

@protocol ProfileViewDelegate

- (void)checkForUpdatePhotos;
- (void)didLoginWithUsername:(NSString*)username andPhoto:(UIImage*)photo andEmail:(NSString*)email andFacebookID:(NSNumber*)facebookID andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary *)stixOrder;
-(void)didLogout;
-(NSMutableDictionary *)getUserPhotos;
- (NSString *)getUsername;
- (UIImage *)getUserPhoto;
- (int)getUserTagTotal;
- (bool)isLoggedIn;
- (void)didChangeUserphoto:(UIImage*)photo;
-(NSMutableDictionary*)getAllUsers;
-(NSMutableArray*)getAllUserFacebookIDs;
-(NSMutableArray*)getAllUserEmails;
-(NSMutableArray*)getAllUserNames;
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;
//-(NSMutableSet*)getFriendsList;
-(NSMutableSet*)getFollowingList;
-(NSMutableSet*)getFollowerList;
-(void)didCreateBadgeView:(UIView *) newBadgeView;

-(void)didClickFeedbackButton:(NSString*)fromView;
-(void)didSendGiftStix:(NSString*)stixStringID toUsername:(NSString*)friendName;

-(void)didPressAdminEasterEgg:(NSString*)view;
-(void)didClickChangePhoto;

-(void)didClickInviteButton;
-(void)didDismissSecondaryView;
-(void)closeProfileView;
-(void)needFacebookLogin;

-(void)searchFriendsByFacebook;

-(void)setFollowing:(NSString *)friendName toState:(BOOL)shouldFollow;
-(void)uploadImage:(NSData*)dataPNG withShareMethod:(int)method;
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID;
-(void)didClickInviteButtonByFacebook:(NSString*)username withFacebookID:(NSString*)fbID;
@end

@interface ProfileViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, KumulosDelegate, UINavigationControllerDelegate, FriendSearchResultsDelegate, UITextFieldDelegate, UISearchBarDelegate, UserGalleryDelegate, StixAnimationDelegate>{
    
    //IBOutlet UIButton * logoutScreenButton;
    //IBOutlet UIButton * stixCountButton; // custom button but no clicking
    //IBOutlet UIButton * friendCountButton; 
    
    IBOutlet UIButton * photoButton;
    IBOutlet UILabel * nameLabel;
    //IBOutlet UIButton * buttonInstructions;
    
    //LoginViewController * loginController;
    //FriendsViewController * friendController;
    
    NSObject<ProfileViewDelegate> *delegate;
    Kumulos * k;
//    bool friendViewIsDisplayed;
    IBOutlet UIButton * logo;
    
//    UIImagePickerController * camera;

    // myButtons - displayed for current user's profile
    bool showMyButtons;
    bool isSearching;
    int resultType;
    UIButton * discoverLabel;
    UIButton * buttonContacts;
    UIButton * buttonFacebook;
    UIButton * buttonName;
    UIButton * buttonMyPix;
    UIButton * buttonStixAdded;
    UIImageView * myPixBG;
    
    int userHistoryCount;
    int userCommentCount;
    
    NSMutableArray * searchFriendName;
    NSMutableArray * searchFriendEmail;
    NSMutableArray * searchFriendFacebookID;
    NSMutableArray * searchFriendIsStix;
    
    int dismissAnimation;
}

@property (nonatomic, assign) NSObject<ProfileViewDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) IBOutlet UIButton * photoButton;
@property (nonatomic, retain) IBOutlet UIButton * bgFollowers;
@property (nonatomic, retain) IBOutlet UIButton * bgFollowing;
@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, retain) UIImageView * bottomBackground;
@property (nonatomic, retain) OutlineLabel * myFollowersCount;
@property (nonatomic, retain) OutlineLabel * myFollowingCount;
@property (nonatomic, retain) OutlineLabel * myFollowersLabel;
@property (nonatomic, retain) OutlineLabel * myFollowingLabel;
@property (nonatomic, retain) OutlineLabel * myPixCount;
@property (nonatomic, retain) OutlineLabel * myStixCount;
@property (nonatomic, retain) OutlineLabel * myPixLabel;
@property (nonatomic, retain) OutlineLabel * myStixLabel;
@property (nonatomic, retain) FriendSearchResultsController * searchResultsController;
@property (nonatomic, retain) UISearchBar * searchBar;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;

//@property (nonatomic, retain) IBOutlet UIButton * logoutScreenButton;
//@property (nonatomic, retain) IBOutlet UIButton * stixCountButton;
//@property (nonatomic, retain) IBOutlet UIButton * friendCountButton;
//@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
//@property (nonatomic, retain) LoginViewController * loginController;
//@property (nonatomic, retain) FriendsViewController * friendController;
//@property (nonatomic, assign) UIImagePickerController * camera;

-(IBAction)changePhoto:(id)sender;
-(void)takeProfilePicture;
-(void)updatePixCount;
-(IBAction)adminStixButtonPressed:(id)sender; // hack: for debug/admin mode
// utils
-(IBAction)didClickBackButton:(id)sender;
-(IBAction)feedbackButtonClicked:(id)sender;
-(IBAction)inviteButtonClicked:(id)sender;
-(IBAction)buttonFollowingClicked:(id)sender;
-(IBAction)buttonFollowersClicked:(id)sender;

-(void)populateWithMyButtons;
-(void)toggleMyButtons:(BOOL)show;
-(void)toggleMyInfo:(BOOL)show;
-(void)populateFollowCounts;
-(void)updateFollowCounts;
-(void)populateFacebookSearchResults:(NSArray*)facebookFriendArray;
-(void)populateContactSearchResults;
-(NSMutableArray*)collectFriendsFromContactList;
-(void)populateNameSearchResults;
-(void)populateFollowingList;
-(void)populateFollowersList;

// deprecated
/*
 -(IBAction)showLogoutScreen:(id)sender;
-(IBAction)didClickLogoutButton:(id)sender;
-(IBAction)closeInstructions:(id)sender;
-(void)loginWithUsername:(NSString *)name;
-(IBAction)friendCountButtonClicked:(id)sender;
-(IBAction)stixCountButtonClicked:(id)sender;
-(IBAction)findFriendsClicked:(id)sender;
 */
@end
