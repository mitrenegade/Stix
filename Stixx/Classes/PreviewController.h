//
//  PreviewController.h
//  Stixx
//
//  Created by Bobby Ren on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExploreViewController.h"
#import "PreviewLoginViewController.h"
#import "StixAnimation.h"
#import "LoadingAnimationView.h"
#import "TwitterHelper.h"
#import "Kumulos.h"
#import "SignupViewController.h"
#import "LoginViewController.h"
#import "CreateHandleController.h"
#import "DetailViewController.h"

@protocol PreviewDelegate <NSObject>
-(int)getNewestTagID;
-(void)doFacebookLogin;
-(void)didConnectToTwitter;
-(void)didLoginToTwitter:(NSDictionary *)results forShareOnly:(BOOL)gotTokenForShare;

-(void)didLoginFromSplashScreenWithScreenname:(NSString*)username andPhoto:(UIImage*)photo andEmail:(NSString*)email andFacebookString:(NSString*)facebookString andTwitterString:(NSString*)twitterString andUserID:(NSNumber*)userID isFirstTimeUser:(BOOL)isFirstTimeUser;
@end

@interface PreviewController : UIViewController <ExploreViewDelegate, PreviewLoginDelegate, TwitterHelperDelegate, KumulosDelegate, SignupViewDelegate, LoginViewDelegate, CreateHandleControllerDelegate, DetailViewDelegate>
{
    NSObject<PreviewDelegate> * __unsafe_unretained delegate;
    IBOutlet UIImageView * barBase;
    IBOutlet UIButton * buttonNext;
    LoadingAnimationView * activityIndicator;
    Kumulos * k;
    
    BOOL hasExplore;
    ExploreViewController * exploreController;
    PreviewLoginViewController * loginController;

    // general login
    NSString * username;
    NSString * email;
    NSString * handle;
    NSData * photoData;

    // facebook login
    NSString * facebookString;
    
    // twitter login
    NSString * twitterHandle;
    NSString * twitterString;
    NSString * twitterProfileURL;
    
    BOOL isFirstTimeUser;
    
    DetailViewController * detailController;
}

@property (nonatomic, unsafe_unretained) NSObject<PreviewDelegate> * delegate;
@property (nonatomic) Kumulos * k;
@property (nonatomic) IBOutlet UIImageView * barBase;
@property (nonatomic) IBOutlet UIButton * buttonNext;
@property (nonatomic) NSString * handle;
@property (nonatomic) NSData * photoData;

-(void)didGetFacebookName:(NSString*)name andEmail:(NSString*)email andFacebookString:(NSString*)facebookString;
-(IBAction)didClickNextButton:(id)sender;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
@end
