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

-(NSMutableDictionary *)getUserPhotos;
- (NSString *)getUsername;
- (UIImage *)getUserPhoto;
//- (int)getUserTagTotal;
- (bool)isLoggedIn;
- (void)didChangeUserphoto:(UIImage*)photo;
-(NSMutableDictionary*)getAllUsers;
-(NSMutableArray*)getAllUserFacebookIDs;
-(NSMutableArray*)getAllUserEmails;
-(NSMutableArray*)getAllUserNames;
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;
-(NSMutableSet*)getFollowingList;
-(NSMutableSet*)getFollowerList;
-(void)didCreateBadgeView:(UIView *) newBadgeView;
-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;

-(void)didClickFeedbackButton:(NSString*)fromView;
-(void)didSendGiftStix:(NSString*)stixStringID toUsername:(NSString*)friendName;

-(void)didPressAdminEasterEgg:(NSString*)view;
-(void)didClickChangePhoto;

-(void)didClickInviteButton;
-(void)didDismissSecondaryView;
-(void)closeProfileView;
-(void)shouldDisplayUserPage:(NSString *)name;
-(void)shouldCloseUserPage;
-(void)needFacebookLogin;

-(void)searchFriendsByFacebook;

-(void)setFollowing:(NSString *)friendName toState:(BOOL)shouldFollow;
-(void)uploadImage:(NSData*)dataPNG withShareMethod:(int)method;
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID;
-(void)didClickInviteButtonByFacebook:(NSString*)username withFacebookID:(NSString*)fbID;

-(int)getFirstTimeUserStage;
-(void)advanceFirstTimeUserMessage;
@end

@interface ProfileViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, KumulosDelegate, UINavigationControllerDelegate, FriendSearchResultsDelegate, UITextFieldDelegate, UISearchBarDelegate, UserGalleryDelegate, StixAnimationDelegate, UIActionSheetDelegate, UIWebViewDelegate>{
    
    //IBOutlet UIButton * logoutScreenButton;
    //IBOutlet UIButton * stixCountButton; // custom button but no clicking
    //IBOutlet UIButton * friendCountButton; 
    
    IBOutlet UIButton * photoButton;
    IBOutlet UILabel * nameLabel;
    //IBOutlet UIButton * buttonInstructions;
    
    //LoginViewController * loginController;
    //FriendsViewController * friendController;
    
    NSObject<ProfileViewDelegate> *__unsafe_unretained delegate;
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
    
    UIWebView * tosView;
    
    int userHistoryCount;
    int userCommentCount;
    
    NSMutableArray * searchFriendName;
    NSMutableArray * searchFriendEmail;
    NSMutableArray * searchFriendFacebookID;
    NSMutableArray * searchFriendIsStix;
    
    int dismissAnimation;
    BOOL showPointer;
}

@property (nonatomic, unsafe_unretained) NSObject<ProfileViewDelegate> *delegate;
@property (nonatomic) IBOutlet UILabel * nameLabel;
@property (nonatomic) IBOutlet UIButton * photoButton;
@property (nonatomic) IBOutlet UIButton * bgFollowers;
@property (nonatomic) IBOutlet UIButton * bgFollowing;
@property (nonatomic) Kumulos * k;
@property (nonatomic) UIImageView * bottomBackground;
@property (nonatomic) OutlineLabel * myFollowersCount;
@property (nonatomic) OutlineLabel * myFollowingCount;
@property (nonatomic) OutlineLabel * myFollowersLabel;
@property (nonatomic) OutlineLabel * myFollowingLabel;
@property (nonatomic) OutlineLabel * myPixCount;
@property (nonatomic) OutlineLabel * myStixCount;
@property (nonatomic) OutlineLabel * myPixLabel;
@property (nonatomic) OutlineLabel * myStixLabel;
@property (nonatomic) FriendSearchResultsController * searchResultsController;
@property (nonatomic) UISearchBar * searchBar;
@property (nonatomic) LoadingAnimationView * activityIndicator;

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
-(IBAction)aboutButtonClicked:(id)sender;
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
-(void)doPointerAnimation;

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
