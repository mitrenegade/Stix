//
//  ConfigViewController.h
//  ARKitDemo
//
//  Created by Administrator on 7/11/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "Kumulos.h"
#import "UIImage+RoundedCorner.h"

@protocol ConfigViewDelegate

- (void)checkForUpdatePhotos;

@end

@interface ConfigViewController : UIViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, KumulosDelegate, UINavigationControllerDelegate>{

    UIButton * loginScreenButton;
    NSObject<ConfigViewDelegate> *delegate;
    
    IBOutlet UILabel * nameLabel;
    NSString * username;
    
    IBOutlet UIButton * photoButton;
    //UIImage * photo;
    
    IBOutlet UIImageView * photoView;
    bool isLoggedIn;
    
    IBOutlet UIButton * buttonInstructions;
    
}

@property (nonatomic, retain) IBOutlet UIButton * loginScreenButton;
@property (nonatomic, assign) NSObject<ConfigViewDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) NSString * username;
//@property (nonatomic, retain) UIImage * photo;
@property (nonatomic, retain) IBOutlet UIButton * photoButton;
@property (nonatomic, assign) bool isLoggedIn;
@property (nonatomic, retain) IBOutlet UIImageView * photoView;
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
- (IBAction)showLoginScreen:(id)sender;
//-(IBAction)resetAllTagData:(id)sender;
-(IBAction)changePhoto:(id)sender;
-(void)setUsernameLabel:(NSString *)name;
-(void)takeProfilePicture;
-(void)loginWithUsername:(NSString *)name;
-(IBAction)closeInstructions:(id)sender;

@end
