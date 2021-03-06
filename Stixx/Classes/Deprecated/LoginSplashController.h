//
//  LoginSplashController.h
//  Stixx
//
//  Created by Bobby Ren on 11/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "BadgeView.h"
#import "KumulosData.h"

@protocol LoginSplashDelegate 

//- (void) doJoin;
//- (void) doAddUser;
-(void)didLogout; // if cancel is pressed - goes back to splash screen
-(void)didDismissSecondaryView;
-(FacebookLoginHelper*)getFacebookHelper;
//-(void)doFacebookLoginOrJoin:(BOOL)bJoin;

- (void)didLoginFromSplashScreenWithUsername:(NSString*)username andPhoto:(UIImage*)photo andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary*) stixOrder andFriendsList:(NSMutableSet*)friendsList isFirstTimeUser:(BOOL)firstTime;

@end

@interface LoginSplashController : UIViewController <LoginViewDelegate>
{
    IBOutlet UIButton * loginButton;
    IBOutlet UIButton * joinButton;
    NSObject<LoginSplashDelegate> *delegate;
    
    LoginViewController * loginController;
    
    UIImagePickerController * camera;
}

@property (nonatomic, retain) IBOutlet UIButton * loginButton;
@property (nonatomic, retain) IBOutlet UIButton * joinButton;
@property (nonatomic, retain) LoginViewController * loginController;
@property (nonatomic, assign) NSObject<LoginSplashDelegate> *delegate;
@property (nonatomic, assign) UIImagePickerController * camera;

-(IBAction)didClickJoinButton:(id)sender;
-(IBAction)didClickLoginButton:(id)sender;
-(void)didGetFacebookName:(NSString*)name andEmail:(NSString*)email andID:(id)facebookID;
@end
