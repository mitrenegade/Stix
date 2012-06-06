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
//#import "SHK.h"
#import "MySHKConfigurator.h"
#import "SHKSharer.h"
#import "FacebookHelper.h"
#import "Kumulos.h"
#import "FacebookHelper.h"
#import "Tag.h"

#define HOSTNAME @"stix.herokuapp.com"

@protocol ShareControllerDelegate <NSObject>

-(void)shouldCloseShareController:(BOOL)didClickDone;
-(NSString*)getUsername;
-(void)uploadImageFinished;

@optional
-(void)sharePixDialogDidFinish;
-(void)sharePixDialogDidFail:(int)errorType;

@end

@interface ShareController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ASIHTTPRequestDelegate, SHKSharerDelegate>
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
#if 0
    UIImage * image;
    int tagID;
    NSData * PNG;
#else
    Tag * tag;
#endif
    LoadingAnimationView * activityIndicatorLarge;

    NSMutableDictionary * serviceIsConnected;
    NSMutableDictionary * serviceIsSharing;
    
    Kumulos * k;

}
@property (nonatomic) IBOutlet UIButton * backButton;
@property (nonatomic) IBOutlet UIButton * doneButton;
@property (nonatomic) IBOutlet UITextField * caption;
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic, unsafe_unretained) NSObject<ShareControllerDelegate> *delegate;
@property (nonatomic, retain) NSString * shareURL;
@property (nonatomic, retain) NSString * shareImageURL;
@property (nonatomic, retain) NSString * shareCaption;
#if 0
@property (nonatomic, retain) NSData * PNG;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, assign) int tagID;
#else
@property (nonatomic, retain) Tag * tag;
#endif

+(ShareController *) sharedShareController;

-(IBAction) didClickBackButton:(id)sender;
-(IBAction) didClickDoneButton:(id)sender;
-(void)didConnectService:(NSString*)name;
-(void)initializeServices;
-(int)numberOfServices;
-(void)uploadImage:(NSData *)dataPNG;
-(void)startUploadImage:(Tag*)tag withDelegate:(NSObject<ShareControllerDelegate>*)_delegate;
-(BOOL)isUploading;
-(void)doTwitterConnect;
-(void)reloadConnections;
-(void)doSharePix;

/* former delegate functions */
-(void)connectService:(NSString*)service;
-(BOOL)shareServiceIsConnected:(NSString*)service;
-(BOOL)shareServiceIsSharing:(NSString*)service;
-(void)shareServiceDidToggle:(NSString*)service;
-(void)shareServiceShouldShare:(BOOL)doShare forService:(NSString*)service; 
-(void)shareServiceShouldConnect:(BOOL)doConnect forService:(NSString *)service;
@end
