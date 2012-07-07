//
//  SignupViewController.h
//  Stixx
//
//  Created by Bobby Ren on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "Kumulos.h"
#import "FlurryAnalytics.h"
#import "UIImage+Resize.h"
#import "GlobalHeaders.h"

enum tag_labels {
    TAG_EMAIL,
    TAG_USERNAME,
    TAG_PASSWORD,
    TAG_PASSWORD2,
    TAG_PICTURE
};

@protocol SignupViewDelegate <NSObject>
- (void)didLoginFromEmailSignup:(NSString*)username andPhoto:(UIImage*)photo andEmail:(NSString*)email andUserID:(NSNumber*)userID;
-(void)showAlert:(NSString*)alertMessage;
-(void)shouldDismissSecondaryViewWithTransition:(UIView*)viewToDismiss;
@end
    
@interface SignupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, KumulosDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    LoadingAnimationView * activityIndicator;
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonSignup;
    NSMutableArray * inputFields;
    BOOL didChangePhoto;
    IBOutlet UIButton * buttonBack;
    Kumulos * k;
    NSObject<SignupViewDelegate> * __unsafe_unretained delegate;
}

@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) NSMutableDictionary * inputViews;
@property (nonatomic) IBOutlet UIButton * buttonSignup;
@property (nonatomic) NSMutableArray * inputFields;
@property (nonatomic) Kumulos * k;
@property (nonatomic, unsafe_unretained) NSObject<SignupViewDelegate> *delegate;
@property (nonatomic) UIImagePickerController * camera;
@property (nonatomic) IBOutlet UIButton * buttonBack;

-(IBAction)didClickSignup:(id)sender;
-(IBAction)didClickPhoto:(id)sender;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(IBAction)didClickBackButton:(id)sender;
@end
