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

@protocol LoginSplashDelegate 

//- (void) doJoin;
//- (void) doAddUser;
- (void) didLoginFromSplashScreen;
-(void)didLogout; // if cancel is pressed - goes back to splash screen

- (void)didLoginWithUsername:(NSString*)username andPhoto:(UIImage*)photo andStix:(NSMutableArray *)stix andTotalTags:(int)total;

@end

@interface LoginSplashController : UIViewController <LoginViewDelegate>
{
    IBOutlet UIButton * loginButton;
    IBOutlet UIButton * joinButton;
    NSObject<LoginSplashDelegate> *delegate;
    
    LoginViewController * loginController;
}

@property (nonatomic, retain) IBOutlet UIButton * loginButton;
@property (nonatomic, retain) IBOutlet UIButton * joinButton;
@property (nonatomic, retain) LoginViewController * loginController;
@property (nonatomic, assign) NSObject<LoginSplashDelegate> *delegate;

-(IBAction)didClickJoinButton:(id)sender;
-(IBAction)didClickLoginButton:(id)sender;

@end
