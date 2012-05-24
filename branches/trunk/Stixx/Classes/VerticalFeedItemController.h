//
//  VerticalFeedItemController.h
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//
//  FeedViewController.h
//  ARKitDemo
//
//  Created by Administrator on 8/17/11.
//  Copyright 2011 Neroh. All rights reserved.
//
//
//  VerticalFeedItemController.h
//  ARKitDemo
//
//  Created by Administrator on 9/13/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"
#import "BadgeView.h"
#import "OutlineLabel.h"
#import "StixView.h"
#import "Kumulos.h"
#import "CommentFeedTableController.h"
#import "LoadingAnimationView.h"
#import "StixAnimation.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "FacebookHelper.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#define CONTENT_HEIGHT 320
#define HOSTNAME @"stix.herokuapp.com"

@class VerticalFeedItemController;

@protocol VerticalFeedItemDelegate 

-(void)displayCommentsOfTag:(int)tagID andName:(NSString*)nameString;

// forward from StixView
-(NSString*)getUsername;
-(NSString*)getUsernameOfApp;
//-(void)didRequestStixFromKumulos:(NSString*)stixStringID withFeedItem:(VerticalFeedItemController*)feedItem;
-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;
@optional
-(void)didPerformPeelableAction:(int)action forAuxStix:(int)index;
-(void)didClickAtLocation:(CGPoint)location withFeedItem:(VerticalFeedItemController *)feedItem;

-(void)didPressShareButtonForFeedItem:(VerticalFeedItemController *)feedItem;
-(void)sharePixDialogDidFinish;
-(void)sharePixDialogDidFail:(int)errorType;

-(void)didReceiveMemoryWarningForFeedItem:(VerticalFeedItemController*)feedItem;
-(void)didClickReloadButtonForFeedItem:(VerticalFeedItemController *)feedItem;

-(void)didClickLikeButton:(int)type withTagID:(int)tagID;
-(void)didDisplayLikeToolbar:(VerticalFeedItemController *)feedItem;
@end


@interface VerticalFeedItemController : UIViewController <StixViewDelegate,/*CommentFeedTableDelegate,*/ KumulosDelegate, UIActionSheetDelegate, ASIHTTPRequestDelegate, StixAnimationDelegate, UIGestureRecognizerDelegate>{
    
	IBOutlet UILabel * labelName;
    //    IBOutlet UILabel * labelDescriptorBG; // needed for opacity trick
    IBOutlet UIImageView * labelDescriptorBG;
	IBOutlet UILabel * labelDescriptor;
    IBOutlet UILabel * labelComment;
	IBOutlet UILabel * labelTime;
    IBOutlet UILabel * labelLocationString;
    IBOutlet UILabel * labelCommentCount;
	IBOutlet UIImageView * imageView;
    StixView * stixView;
    IBOutlet UIImageView * userPhotoView;
    IBOutlet UIButton * addCommentButton;
    IBOutlet UIButton * shareButton;
    //IBOutlet UIButton * seeAllCommentsButton;
    
    NSObject<VerticalFeedItemDelegate> * __unsafe_unretained delegate;    
    NSObject<VerticalFeedItemDelegate> * __strong delegatePointer;
    
    NSString * nameString;
    NSString * descriptorString;
    NSString * commentString;
    NSString * locationString;
    UIImage * imageData;
    UIImageView * locationIcon;
    int commentCount;
    Tag * tag; // do save the tag in case we need to repopulate the stix
    int tagID;
    
    int shareMethod;
    
    BOOL isExpanded; // whether or not to show comments
    CommentFeedTableController * commentsTable;
//    NSMutableArray * names;
//    NSMutableArray * comments;
//    NSMutableArray * stixStringIDs;
    Kumulos * k;

    UIImageView * placeholderView;
    UIImageView * reloadView;
    UIImageView * reloadMessage;
    UIImageView * reloadMessage2;
    UIButton * reloadButton;
    BOOL tapStartsReloading;
    
    BOOL isDisplayingLikeToolbar;
    UIButton * likeIconSmiles;
    UIButton * likeIconLove;
    UIButton * likeIconWink;
    UIButton * likeIconShocked;
    UIButton * likeIconComment;
    UIImageView * likeToolbarBg;
}
@property ( nonatomic) IBOutlet UILabel * labelName;
@property ( nonatomic) IBOutlet UILabel * labelComment;
@property ( nonatomic) IBOutlet UILabel * labelCommentCount;
@property ( nonatomic) IBOutlet UILabel * labelDescriptor;
@property ( nonatomic) IBOutlet UIImageView * labelDescriptorBG;
@property ( nonatomic) IBOutlet UILabel * labelTime;
@property ( nonatomic) IBOutlet UILabel * labelLocationString;
@property (nonatomic) IBOutlet UIImageView * imageView;
@property (nonatomic) IBOutlet UIImageView * userPhotoView;
@property (nonatomic) IBOutlet UIImageView * locationIcon;
@property (nonatomic) NSString * nameString;
@property (nonatomic) NSString * commentString;
@property (nonatomic) UIImage * imageData;
@property (nonatomic) IBOutlet UIButton * addCommentButton;
@property (nonatomic) IBOutlet UIButton * shareButton;
@property (nonatomic, assign) int tagID;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, unsafe_unretained) NSObject<VerticalFeedItemDelegate> * delegate;   
@property (nonatomic) StixView * stixView;
@property (nonatomic) UIImageView * reloadView;
@property (nonatomic) UIImageView * reloadMessage;
@property (nonatomic) UIImageView * reloadMessage2;
@property (nonatomic) UIButton * reloadButton;
//@property (nonatomic, retain) IBOutlet UIButton * seeAllCommentsButton;

-(void)populateWithName:(NSString *)name andWithDescriptor:(NSString*)descriptor andWithComment:(NSString*)comment andWithLocationString:(NSString*)location;
-(void)populateWithUserPhoto:(UIImage*)photo;
-(void)populateWithTimestamp:(NSDate *)timestamp;
-(void)populateWithCommentCount:(int)count;
//-(void)populateCommentsWithNames:(NSMutableArray*)allNames andComments:(NSMutableArray*)allComments andStixStringIDs:(NSMutableArray*)allStixStringIDs;

-(void)initStixView:(Tag*)tag;
-(void)initReloadView; // start the spin
-(void)displayReloadView; // only display view

-(IBAction)didPressAddCommentButton:(id)sender;
-(IBAction)didPressShareButton:(id)sender;
-(IBAction)didPressSeeAllCommentsButton:(id)sender;

// sharing 
-(void)didClickShareViaFacebook;
-(void)didClickShareViaEmail;
-(void)uploadImage:(NSData *)dataPNG;

-(void)togglePlaceholderView:(BOOL)showPlaceholder;
-(void)likeToolbarHide:(int)selected;

@end


