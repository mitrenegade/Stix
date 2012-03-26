//
//  LoginViewController.h
//  KickedIntoShape
//
//  Created by Administrator on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kumulos.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "BadgeView.h"
#import "LoadingAnimationView.h"
#import "KumulosData.h"
#import "FacebookLoginHelper.h"

#define NEW_USER_BUX 50

@protocol LoginViewDelegate

- (void)didSelectUsername:(NSString *)name withResults:(NSArray *) theResults;
- (void)didCancelLogin;
-(FacebookLoginHelper*)getFacebookHelper;
-(void)doFacebookLoginOrJoin:(BOOL)bJoin;
@end

@interface LoginViewController : UIViewController <UITextFieldDelegate, KumulosDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UITextField * loginName;
    IBOutlet UITextField * loginPassword;
    IBOutlet UITextField * loginEmail;
    IBOutlet UIImageView * loginNameBG;
    IBOutlet UIImageView * loginPasswordBG;
    IBOutlet UIImageView * loginEmailBG;
    IBOutlet UIButton * addPhoto;
    IBOutlet UIButton * loginButton;
    IBOutlet UIButton * joinButton;
    IBOutlet UIButton * cancelButton;
    int facebookID;
    LoadingAnimationView * activityIndicator;

    UIImage * newUserImage;
    bool newUserImageSet;
    
	id<LoginViewDelegate, NSObject> delegate;
    
    bool bJoinOrLogin; // 0 for join, 1 for login
    
    Kumulos * k;
}

@property (nonatomic, retain) IBOutlet UITextField * loginName;
@property (nonatomic, retain) IBOutlet UITextField * loginPassword;
@property (nonatomic, retain) IBOutlet UITextField * loginEmail;
//@property (nonatomic, retain) IBOutlet UIImageView * loginEmailBG;
@property (nonatomic, retain) IBOutlet UIButton * addPhoto;
@property (nonatomic, retain) IBOutlet UIButton * loginButton;
@property (nonatomic, retain) IBOutlet UIButton * joinButton;
@property (nonatomic, retain) IBOutlet UIButton * facebookButton;
@property (nonatomic, retain) IBOutlet UIButton * cancelButton;
@property (nonatomic, assign) id<LoginViewDelegate, NSObject> delegate;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, assign) bool bJoinOrLogin; 
@property (nonatomic, retain) UIImage * userImage;
@property (nonatomic, assign) FacebookLoginHelper * fbHelper;
@property (nonatomic, assign) int facebookID;
- (IBAction)loginButtonPressed:(id)sender; 
- (IBAction)joinButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)addPhotoPressed:(id)sender;
-(void)addUser;
-(void)doLogin;
-(IBAction)didClickFacebookButton:(id)sender;
-(void)didGetFacebookName:(NSString*)name andEmail:(NSString*)email andID:(int)facebookID;

-(void)continueLogin;
-(void)continueJoin;

@end
