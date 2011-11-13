//
//  LoginViewController.h
//  KickedIntoShape
//
//  Created by Administrator on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kumulos.h"

@protocol LoginViewDelegate

- (void)loginSuccessfulWithName:(NSString *)name;

@end

@interface LoginViewController : UIViewController <UITextFieldDelegate, KumulosDelegate> {
    IBOutlet UITextField * loginName;
    IBOutlet UITextField * loginPassword;
    IBOutlet UIButton * loginButton;
    IBOutlet UIButton * addUserButton;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIActivityIndicatorView * activityIndicator;

	id<LoginViewDelegate, NSObject> delegate;
}

@property (nonatomic, retain) IBOutlet UITextField * loginName;
@property (nonatomic, retain) IBOutlet UITextField * loginPassword;
@property (nonatomic, retain) IBOutlet UIButton * loginButton;
@property (nonatomic, retain) IBOutlet UIButton * addUserButton;
@property (nonatomic, retain) IBOutlet UIButton * cancelButton;
@property (nonatomic, retain) id<LoginViewDelegate, NSObject> delegate;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;

- (IBAction)loginButtonPressed:(id)sender; 
- (IBAction)addUserButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
-(void)addUser;
-(void)doLogin;

@end
