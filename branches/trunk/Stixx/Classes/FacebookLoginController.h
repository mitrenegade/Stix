//
//  FacebookLoginController.h
//  Stixx
//
//  Created by Bobby Ren on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "LoadingAnimationView.h"
#import "KumulosData.h"
#import "Kumulos.h"
#import "BadgeView.h"
#import "KumulosHelper.h"
#import "SignupViewController.h"
#import "CreateFacebookUsernameController.h"
#import "GlobalHeaders.h"
#import "StixAnimation.h"
#import "FacebookHelper.h"

#define NEW_USER_BUX 100

@protocol FacebookLoginDelegate <NSObject>
-(void)didDismissSecondaryView;
-(void)doFacebookLogin;
- (void)didLoginFromSplashScreenWithUsername:(NSString*)username andPhoto:(UIImage*)photo andEmail:(NSString*)email andFacebookString:(NSString*)facebookString andUserID:(NSNumber*)userID andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary*) stixOrder isFirstTimeUser:(BOOL)firstTime;
-(void)didAddNewUserWithResult:(NSArray*)theResults;
@end

@interface FacebookLoginController : UIViewController <KumulosDelegate, KumulosHelperDelegate, SignupViewDelegate, LoginViewDelegate, CreateFacebookUsernameDelegate>
{
    BOOL isFirstTimeUser;
}

@property (nonatomic) IBOutlet UIButton * loginButton;
@property (nonatomic) IBOutlet UIButton * signInButton;
@property (nonatomic) IBOutlet UIButton * signUpButton;
@property (nonatomic, unsafe_unretained) NSObject<FacebookLoginDelegate> *delegate;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic, copy) NSString * facebookName;
@property (nonatomic, copy) NSString * facebookEmail;
@property (nonatomic) NSString* facebookString;
@property (nonatomic) Kumulos * k;
@property (nonatomic) UINavigationController * navController;
@property (nonatomic, assign) UIImagePickerController * camera;
@property (nonatomic) NSString * usersFacebookUsername;
@property (nonatomic) NSData * usersFacebookPhotoData;
@property (nonatomic) SignupViewController * signupController;
@property (nonatomic) LoginViewController * loginController;
@property (nonatomic) CreateFacebookUsernameController * usernameController;

-(IBAction)didClickFacebookLoginButton:(id)sender;
-(void)didGetFacebookName:(NSString*)name andEmail:(NSString*)email andFacebookString:(NSString*)facebookString;
-(void)addUser;
-(void)loginUser;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;

// new login functions
-(IBAction)didClickSignIn:(id)sender;
-(IBAction)didClickSignUp:(id)sender;
-(void)shouldShowButtons;
@end
