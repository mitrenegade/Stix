//
//  CreateFacebookUsernameController.h
//  Stixx
//
//  Created by Bobby Ren on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kumulos.h"
#import "LoadingAnimationView.h"

@protocol CreateFacebookUsernameDelegate
-(void)didAddFacebookUsername:(NSString *)fbUsername andPhoto:(NSData*)photoData;
-(void)showAlert:(NSString*)alertMessage;
-(void)shouldDismissSecondaryViewWithTransition:(UIView*)viewToDismiss;
-(void)shouldShowButtons;
@end

@interface CreateFacebookUsernameController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, KumulosDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    LoadingAnimationView * activityIndicator;
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonLogin;
    NSMutableArray * inputFields;
    IBOutlet UIButton * buttonBack;
    UIImage * userphoto;
    NSString * initialFacebookName;
    Kumulos * k;
    NSObject<CreateFacebookUsernameDelegate> * __unsafe_unretained delegate;
    BOOL didChangePhoto;
}

@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) IBOutlet UIButton * buttonLogin;
@property (nonatomic) NSMutableArray * inputFields;
@property (nonatomic) Kumulos * k;
@property (nonatomic, unsafe_unretained) NSObject<CreateFacebookUsernameDelegate> *delegate;
@property (nonatomic) UIImagePickerController * camera;
@property (nonatomic) IBOutlet UIButton * buttonBack;
@property (nonatomic) UIImage * userphoto;
@property (nonatomic) NSString * facebookString;
@property (nonatomic) NSString * initialFacebookName;

-(IBAction)didClickPhoto:(id)sender;
-(IBAction)didClickLogin:(id)sender;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(IBAction)didClickBackButton:(id)sender;

@end
