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
#import "CreateTwitterUsernameController.h"
#import "SignupViewController.h"
#import "LoginViewController.h"
#import "CreateHandleController.h"

@protocol PreviewDelegate <NSObject>
-(int)getNewestTagID;
-(void)doFacebookLogin;
-(void)didConnectToTwitter;
-(void)didLoginToTwitter:(NSDictionary *)results forShareOnly:(BOOL)gotTokenForShare;

- (void)didLoginFromSplashScreenWithUsername:(NSString*)username andPhoto:(UIImage*)photo andEmail:(NSString*)email andFacebookString:(NSString*)facebookString andUserID:(NSNumber*)userID andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary*) stixOrder isFirstTimeUser:(BOOL)firstTime;
@end

@interface PreviewController : UIViewController <ExploreViewDelegate, PreviewLoginDelegate, TwitterHelperDelegate, KumulosDelegate, CreateTwitterUsernameDelegate, SignupViewDelegate, LoginViewDelegate>
{
    NSObject<PreviewDelegate> * __unsafe_unretained delegate;
    IBOutlet UIImageView * barBase;
    IBOutlet UIButton * buttonNext;
    LoadingAnimationView * activityIndicator;
    
    BOOL hasExplore;
    ExploreViewController * exploreController;
    PreviewLoginViewController * loginController;

    // general login
    NSString * username;
    NSString * email;
    NSString * newHandle;
    NSData * newPhotoData;

    // facebook login
    NSString * facebookString;
    
    // twitter login
    NSString * twitterHandle;
    NSString * twitterString;
    
    BOOL isFirstTimeUser;
}

@property (nonatomic, unsafe_unretained) NSObject<PreviewDelegate> * delegate;
@property (nonatomic) IBOutlet UIImageView * barBase;
@property (nonatomic) IBOutlet UIButton * buttonNext;
@property (nonatomic) NSString * newHandle;
@property (nonatomic) NSData * newPhotoData;

-(IBAction)didClickNextButton:(id)sender;
@end
