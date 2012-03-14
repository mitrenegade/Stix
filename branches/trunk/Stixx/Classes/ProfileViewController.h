//
//  ProfileViewController.h
//  ARKitDemo
//
//  Created by Administrator on 7/11/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "Kumulos.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import "LoginViewController.h"
#import "BadgeView.h"
#import "FriendsViewController.h"
#import "KumulosData.h"
#import "FriendSearchViewController.h"

#define DEFAULT_STIX_COUNT 2

@protocol ProfileViewDelegate

- (void)checkForUpdatePhotos;
- (void)didLoginWithUsername:(NSString*)username andPhoto:(UIImage*)photo andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary *)stixOrder andFriendsList:(NSMutableSet*)friendsList;
-(void)didLogout;
-(NSMutableDictionary *)getUserPhotos;
- (NSString *)getUsername;
- (UIImage *)getUserPhoto;
- (int)getUserTagTotal;
- (bool)isLoggedIn;
- (void)didChangeUserphoto:(UIImage*)photo;

-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;
-(NSMutableSet*)getFriendsList;
-(void)didCreateBadgeView:(UIView *) newBadgeView;

-(void)didClickFeedbackButton:(NSString*)fromView;
-(void)didSendGiftStix:(NSString*)stixStringID toUsername:(NSString*)friendName;

-(void)didPressAdminEasterEgg:(NSString*)view;
-(void)didClickChangePhoto;

-(void)didClickInviteButton;
-(void)didDismissSecondaryView;
-(void)closeProfileView;

@end

@interface ProfileViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, KumulosDelegate, UINavigationControllerDelegate, /*LoginViewDelegate, */FriendsViewDelegate, UITextFieldDelegate>{
    
    IBOutlet UIButton * logoutScreenButton;
    IBOutlet UIButton * stixCountButton; // custom button but no clicking
    IBOutlet UIButton * friendCountButton; 
    
    IBOutlet UIButton * photoButton;
    IBOutlet UILabel * nameLabel;
    IBOutlet UIButton * buttonInstructions;
    
    //LoginViewController * loginController;
    FriendsViewController * friendController;
    
    NSObject<ProfileViewDelegate> *delegate;
    Kumulos * k;
    bool friendViewIsDisplayed;
    
    UIImagePickerController * camera;
}

@property (nonatomic, retain) IBOutlet UIButton * logoutScreenButton;
@property (nonatomic, retain) IBOutlet UIButton * stixCountButton;
@property (nonatomic, retain) IBOutlet UIButton * friendCountButton;
@property (nonatomic, assign) NSObject<ProfileViewDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) IBOutlet UIButton * photoButton;
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
//@property (nonatomic, retain) LoginViewController * loginController;
@property (nonatomic, retain) FriendsViewController * friendController;
@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, assign) UIImagePickerController * camera;
@property (nonatomic, retain) IBOutlet UIButton * findFriendsButton;

-(IBAction)didClickLogoutButton:(id)sender;
-(IBAction)changePhoto:(id)sender;
-(void)takeProfilePicture;
-(IBAction)closeInstructions:(id)sender;
-(void)loginWithUsername:(NSString *)name;
-(void)updateFriendCount;
-(void)updatePixCount;
-(IBAction)adminStixButtonPressed:(id)sender; // hack: for debug/admin mode
-(IBAction)showLogoutScreen:(id)sender;
-(IBAction)friendCountButtonClicked:(id)sender;
-(IBAction)stixCountButtonClicked:(id)sender;
// utils
-(void)administratorModeResetAllStix;

-(IBAction)findFriendsClicked:(id)sender;
-(IBAction)didClickBackButton:(id)sender;
-(IBAction)feedbackButtonClicked:(id)sender;
-(IBAction)inviteButtonClicked:(id)sender;
@end
