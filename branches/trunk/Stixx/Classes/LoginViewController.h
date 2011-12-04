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
#import "BadgeView.h" // for generateDefaultStix

@protocol LoginViewDelegate

- (void)didSelectUsername:(NSString *)name withResults:(NSArray *) theResults;
- (void)didCancelLogin;

@optional
//- (NSMutableArray*)generateDefaultStix;

@end

@interface LoginViewController : UIViewController <UITextFieldDelegate, KumulosDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UITextField * loginName;
    IBOutlet UITextField * loginPassword;
    IBOutlet UIButton * addPhoto;
    IBOutlet UIButton * loginButton;
    IBOutlet UIButton * addUserButton;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIActivityIndicatorView * activityIndicator;

    UIImage * newUserImage;
    bool newUserImageSet;
    
	id<LoginViewDelegate, NSObject> delegate;
    
    bool bJoinOrLogin; // 0 for join, 1 for login
}

@property (nonatomic, retain) IBOutlet UITextField * loginName;
@property (nonatomic, retain) IBOutlet UITextField * loginPassword;
@property (nonatomic, retain) IBOutlet UIButton * addPhoto;
@property (nonatomic, retain) IBOutlet UIButton * loginButton;
@property (nonatomic, retain) IBOutlet UIButton * addUserButton;
@property (nonatomic, retain) IBOutlet UIButton * cancelButton;
@property (nonatomic, assign) id<LoginViewDelegate, NSObject> delegate;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic, assign) bool bJoinOrLogin; 
@property (nonatomic, retain) UIImage * newUserImage;

- (IBAction)loginButtonPressed:(id)sender; 
- (IBAction)addUserButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)addPhotoPressed:(id)sender;
-(void)addUser;
-(void)doLogin;

// utilities - is this the right place?
-(NSMutableData * ) arrayToData:(NSMutableArray *) dict;
@end
