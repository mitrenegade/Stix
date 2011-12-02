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

#define DEFAULT_STIX_COUNT 2

@protocol ProfileViewDelegate

- (void)checkForUpdatePhotos;
- (void)didLoginWithUsername:(NSString*)username andPhoto:(UIImage*)photo andStix:(NSMutableArray *)stix andTotalTags:(int)total;
-(void)didLogout;
-(NSMutableDictionary *)getUserPhotos;
- (NSString *)getUsername;
- (UIImage *)getUserPhoto;
- (int)getUserTagTotal;
- (bool)isLoggedIn;
-(void)didCancelFirstTimeLogin;
- (void)didChangeUserphoto:(UIImage*)photo;

-(int)getStixCount:(int)stix_type; // forward from BadgeViewDelegate
-(int)incrementStixCount:(int)type forUser:(NSString *)name;
-(int)decrementStixCount:(int)type forUser:(NSString *)name;

@end

@interface ProfileViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, KumulosDelegate, UINavigationControllerDelegate, LoginViewDelegate>{

    IBOutlet UIButton * loginScreenButton; // login if your profile, add as friend if other's profile
    IBOutlet UIButton * logoutScreenButton;
    IBOutlet UIButton * stixCountButton; // custom button but no clicking
    IBOutlet UIButton * friendCountButton; // custom button but no clicking
    NSObject<ProfileViewDelegate> *delegate;
    
    IBOutlet UILabel * nameLabel;
    //NSString * username;
    
    IBOutlet UIButton * photoButton;
    //bool isLoggedIn;
    
    IBOutlet UIButton * buttonInstructions;
    
    LoginViewController * loginController;
    
    //int countFire, countIce;
    
    Kumulos * k;
}

@property (nonatomic, retain) IBOutlet UIButton * loginScreenButton;
@property (nonatomic, retain) IBOutlet UIButton * logoutScreenButton;
@property (nonatomic, retain) IBOutlet UIButton * stixCountButton;
@property (nonatomic, retain) IBOutlet UIButton * friendCountButton;
@property (nonatomic, assign) NSObject<ProfileViewDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
//@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) IBOutlet UIButton * photoButton;
//@property (nonatomic, assign) bool isLoggedIn;
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
/*
@property (nonatomic, retain) IBOutlet UIImageView * badgeFire;
@property (nonatomic, retain) IBOutlet UIImageView * badgeIce;
@property (nonatomic, retain) IBOutlet UILabel * labelFire;
@property (nonatomic, retain) IBOutlet UILabel * labelIce;
 */
//@property (nonatomic, assign) int countFire;
//@property (nonatomic, assign) int countIce;
@property (nonatomic, retain) LoginViewController * loginController;
@property (nonatomic, retain) Kumulos * k;

- (IBAction)showLoginScreen:(id)sender;
-(IBAction)changePhoto:(id)sender;
-(void)takeProfilePicture;
-(IBAction)closeInstructions:(id)sender;
-(void)firstTimeLogin;
-(void)loginWithUsername:(NSString *)name;
-(void)updateFriendCount;
-(void)updateStixCount;
-(IBAction)adminStixButtonPressed:(id)sender; // hack: for debug/admin mode
-(IBAction)showLogoutScreen:(id)sender;

// utils
-(void)administratorModeResetAllStix;
-(NSMutableData * ) arrayToData:(NSMutableArray *) dict;
-(NSMutableArray *) dataToArray:(NSMutableData *) data; 

@end
