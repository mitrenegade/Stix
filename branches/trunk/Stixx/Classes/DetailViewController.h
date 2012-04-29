//
//  DetailViewController.h
//  Stixx
//
//  Created by Bobby Ren on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "Tag.h"
#import "OutlineLabel.h"
#import "StixView.h"
#import "StixAnimation.h"
#import "CommentFeedTableController.h"
#import "Kumulos.h"
#import "LoadingAnimationView.h"
#import "VerticalFeedItemController.h"
#import "CommentViewController.h"

@protocol DetailViewDelegate

-(void)didDismissZoom;
-(UIImage*)getUserPhotoForUsername:(NSString*)username;
-(NSString*)getUsername;
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID;
-(void)shouldDisplayUserPage:(NSString*)username;
-(void)shouldCloseUserPage;
-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;
@end

@interface DetailViewController : UIViewController <StixViewDelegate, StixAnimationDelegate, CommentFeedTableDelegate, KumulosDelegate, VerticalFeedItemDelegate, CommentViewDelegate>

{
    //    IBOutlet UILabel * labelComment;
    //    IBOutlet UILabel * labelLocationString;
    CommentFeedTableController * commentsTable;
	NSObject<DetailViewDelegate> *__unsafe_unretained delegate;
    StixView * stixView;
    UIView * headerView;
    IBOutlet UIImageView * logo;
    
    UIScrollView * scrollView;
    
    NSMutableArray * names;
    NSMutableArray * comments;
    NSMutableArray * stixStringIDs;
    NSMutableArray * timestamps;
    NSMutableDictionary * photos;
    NSMutableArray * rowHeights;
    int trueCommentCount;
    
    VerticalFeedItemController * feedItem;
    int tagID;
    NSString * tagUsername;
    Kumulos * k;
    
    int animationID[2];
    
    // share animation, graphics and actions
    UIImageView * shareSheet;
    UIButton * buttonShareFacebook;
    UIButton * buttonShareEmail;
    UIButton * buttonShareClose;
    int shareMenuOpenAnimation;
    int shareMenuCloseAnimation;
}
//@property (nonatomic, retain) IBOutlet UILabel * labelComment;
//@property (nonatomic, retain) IBOutlet UILabel * labelLocationString;
@property (nonatomic, unsafe_unretained) NSObject<DetailViewDelegate> *delegate;
@property (nonatomic) StixView * stixView;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) LoadingAnimationView * activityIndicatorLarge;
@property (nonatomic) IBOutlet UIImageView * logo;
@property (nonatomic) NSString * tagUsername;
@property (nonatomic) CommentViewController * commentView;

-(IBAction)didClickBackButton:(id)sender;
-(void)initDetailViewWithTag:(Tag *)tag;
-(void)headerFromTag:(Tag*) tag;
-(void)initFeedItemWithTag:(Tag*)tag;
-(void)setScrollHeight:(int)height;

-(void)didCloseShareSheet;

+(BOOL)openingDetailView;
+(void)lockOpen;
+(void)unlockOpen;
@end
