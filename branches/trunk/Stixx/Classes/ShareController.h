//
//  ShareController.h
//  Stixx
//
//  Created by Bobby Ren on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "LoadingAnimationView.h"
#import "SHK.h"
#import "SHKConfiguration.h"

#define HOSTNAME @"stix.herokuapp.com"

@protocol ShareControllerDelegate <NSObject>

-(void)connectService:(NSString*)service;
-(BOOL)shareServiceIsConnected:(NSString*)service;
-(BOOL)shareServiceIsSharing:(NSString*)service;
-(void)shareServiceDidToggle:(NSString*)service;
-(void)shouldCloseShareController:(BOOL)didClickDone;
-(NSString*)getUsername;

@optional
-(void)sharePixDialogDidFinish;
-(void)sharePixDialogDidFail:(int)errorType;

@end

@interface MySHKConfigurator:DefaultSHKConfigurator    
@end

@interface ShareController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ASIHTTPRequestDelegate>
{
    IBOutlet UIButton * backButton;
    IBOutlet UIButton * doneButton;
    IBOutlet UITextField * caption;
    IBOutlet UITableView * tableView;
    
    // Sharing/social networks
    NSMutableArray * names;
    NSMutableDictionary * icons;
    NSMutableDictionary * connectButtons;
    NSMutableDictionary * toggles;

	NSObject<ShareControllerDelegate> *__unsafe_unretained delegate;
    
    int uploadingImageLock;
    NSString * shareURL;
    NSString * shareImageURL;
    NSString * shareCaption;
    NSData * PNG;
    LoadingAnimationView * activityIndicatorLarge;

}
@property (nonatomic) IBOutlet UIButton * backButton;
@property (nonatomic) IBOutlet UIButton * doneButton;
@property (nonatomic) IBOutlet UITextField * caption;
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic, unsafe_unretained) NSObject<ShareControllerDelegate> *delegate;
@property (nonatomic) NSString * shareURL;
@property (nonatomic) NSString * shareImageURL;
@property (nonatomic) NSString * shareCaption;
@property (nonatomic) NSData * PNG;

-(IBAction) didClickBackButton:(id)sender;
-(IBAction) didClickDoneButton:(id)sender;
-(void)didConnectService:(NSString*)name;
-(void)initializeServices;
-(int)numberOfServices;
-(void)uploadImage:(NSData *)dataPNG;
-(BOOL)isUploading;
-(void)doShareKit;
@end
