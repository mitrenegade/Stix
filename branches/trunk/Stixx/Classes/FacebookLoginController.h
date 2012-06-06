//
//  FacebookLoginController.h
//  Stixx
//
//  Created by Bobby Ren on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "LoginViewController.h"
#import "LoadingAnimationView.h"
#import "KumulosData.h"
#import "Kumulos.h"
#import "BadgeView.h"
#import "KumulosHelper.h"

#define NEW_USER_BUX 100

@protocol FacebookLoginDelegate <NSObject>
-(void)didDismissSecondaryView;
-(void)doFacebookLogin;
- (void)didLoginFromSplashScreenWithUsername:(NSString*)username andPhoto:(UIImage*)photo andEmail:(NSString*)email andFacebookID:(NSNumber*)facebookID andUserID:(NSNumber*)userID andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary*) stixOrder isFirstTimeUser:(BOOL)firstTime;
-(void)didAddNewUserWithResult:(NSArray*)theResults;
@end

@interface FacebookLoginController : UIViewController <KumulosDelegate, KumulosHelperDelegate>
{
    BOOL isFirstTimeUser;
}

@property (nonatomic) IBOutlet UIButton * loginButton;
//@property (nonatomic, retain) LoginViewController * loginController;
@property (nonatomic, unsafe_unretained) NSObject<FacebookLoginDelegate> *delegate;
//@property (nonatomic, assign) UIImagePickerController * camera;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic, copy) NSString * facebookName;
@property (nonatomic, copy) NSString * facebookEmail;
@property (nonatomic, assign) int facebookID;
@property (nonatomic) Kumulos * k;

-(IBAction)didClickJoinButton:(id)sender;
-(void)didGetFacebookName:(NSString*)name andEmail:(NSString*)email andID:(int)facebookID;
-(void)addUser;
-(void)loginUser;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;

@end
