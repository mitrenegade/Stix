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
-(void)sharePix:(int)tagID;
-(NSString*)getUsername;
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID;
@end

@interface DetailViewController : UIViewController <StixViewDelegate, StixAnimationDelegate, CommentFeedTableDelegate, KumulosDelegate, VerticalFeedItemDelegate, CommentViewDelegate>

{
    //    IBOutlet UILabel * labelComment;
    //    IBOutlet UILabel * labelLocationString;
    CommentFeedTableController * commentsTable;
	NSObject<DetailViewDelegate> *delegate;
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
}
//@property (nonatomic, retain) IBOutlet UILabel * labelComment;
//@property (nonatomic, retain) IBOutlet UILabel * labelLocationString;
@property (nonatomic, assign) NSObject<DetailViewDelegate> *delegate;
@property (nonatomic, retain) StixView * stixView;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView * logo;
@property (nonatomic, retain) NSString * tagUsername;
@property (nonatomic, retain) CommentViewController * commentView;

-(IBAction)didPressBackButton:(id)sender;
-(void)initDetailViewWithTag:(Tag *)tag;
-(void)headerFromTag:(Tag*) tag;
-(void)initFeedItemWithTag:(Tag*)tag;

@end