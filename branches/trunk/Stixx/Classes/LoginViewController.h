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

@protocol LoginViewDelegate
- (void)didSelectUsername:(NSString *)name withResults:(NSArray *) theResults;
@optional
-(void)shouldShowButtons;
@end

@interface LoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, KumulosDelegate, UINavigationControllerDelegate> {
    LoadingAnimationView * activityIndicator;
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonLogin;
    IBOutlet UIButton * buttonBack;
    NSMutableArray * inputFields;
    Kumulos * k;
    NSObject<LoginViewDelegate> * __unsafe_unretained delegate;
}

@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) IBOutlet UIButton * buttonLogin;
@property (nonatomic) NSMutableArray * inputFields;
@property (nonatomic) Kumulos * k;
@property (nonatomic, unsafe_unretained) NSObject<LoginViewDelegate> *delegate;
@property (nonatomic) IBOutlet UIButton * buttonBack;

-(IBAction)didClickLogin:(id)sender;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(IBAction)didClickBackButton:(id)sender;

@end
