//
//  CreateHandleController.h
//  Stixx
//
//  Created by Bobby Ren on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kumulos.h"
#import "LoadingAnimationView.h"

@protocol CreateHandleControllerDelegate
-(void)didAddHandle:(NSString *)handle andPhoto:(NSData*)photoData;
-(void)showAlert:(NSString*)alertMessage;
-(void)shouldShowButtons;
@end

@interface CreateHandleController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, KumulosDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    LoadingAnimationView * activityIndicator;
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonLogin;
    NSMutableArray * inputFields;
    IBOutlet UIButton * buttonBack;
    UIImage * userphoto;
    Kumulos * k;
    NSObject<CreateHandleControllerDelegate> * __unsafe_unretained delegate;
    BOOL didChangePhoto;

    NSString * initialName;
    NSString * facebookString;
    NSString * twitterString;
}

@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) IBOutlet UIButton * buttonLogin;
@property (nonatomic) NSMutableArray * inputFields;
@property (nonatomic) Kumulos * k;
@property (nonatomic, unsafe_unretained) NSObject<CreateHandleControllerDelegate> *delegate;
@property (nonatomic) UIImagePickerController * camera;
@property (nonatomic) IBOutlet UIButton * buttonBack;
@property (nonatomic) UIImage * userphoto;
@property (nonatomic) NSString * facebookString;
@property (nonatomic) NSString * twitterString;
@property (nonatomic) NSString * initialName;

-(IBAction)didClickPhoto:(id)sender;
-(IBAction)didClickLogin:(id)sender;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(IBAction)didClickBackButton:(id)sender;

@end
