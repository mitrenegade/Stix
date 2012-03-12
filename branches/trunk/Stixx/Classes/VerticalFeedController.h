//
//  VerticalFeedController.h
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagViewController.h"
#import "FeedTableController.h"
#import "VerticalFeedItemController.h"
#import "CarouselView.h"
#import "LoadingAnimationView.h"
#import "CommentViewController.h"
//#import "AuxStixViewController.h"
#import "AddStixViewController.h"
#import "RaisedCenterTabBarController.h"
#import "KumulosHelper.h"
#import "StixAnimation.h"

#define FEED_ITEM_WIDTH 275
#define FEED_ITEM_HEIGHT 300

@protocol VerticalFeedDelegate

-(NSMutableArray *)getTags;
- (NSString*)getUsername;
-(void)checkForUpdateTags;
-(void)checkForUpdatePhotos;
-(NSMutableDictionary *)getUserPhotos;
-(void)getNewerTagsThanID:(int)tagID;
-(void)getOlderTagsThanID:(int)tagID;
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID;

- (bool) isLoggedIn;
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;
-(void)didAddStixToPix:(Tag *)tag withStixStringID:(NSString*)stixStringID withLocation:(CGPoint)location /*withScale:(float)scale withRotation:(float)rotation */withTransform:(CGAffineTransform)transform;
-(void)didCreateBadgeView:(UIView*)newBadgeView;
-(int)getCommentCount:(int)tagID;

-(void)didPerformPeelableAction:(int)action forTagWithIndex:(int)tagIndex forAuxStix:(int)index;
-(void)didClickFeedbackButton:(NSString*)fromView;
-(void)didDismissSecondaryView;

-(void)didPressAdminEasterEgg:(NSString*)view;

-(void)didPurchaseStixFromCarousel:(NSString*)stixStringID;
-(int)getBuxCount;
@end

@interface VerticalFeedController : UIViewController<VerticalFeedItemDelegate, BadgeViewDelegate, FeedTableControllerDelegate, CommentViewDelegate, AddStixViewControllerDelegate, KumulosHelperDelegate, StixAnimationDelegate> {
    
	NSMutableDictionary * feedItems;
    NSMutableDictionary * headerViews;
    //BadgeView * badgeView;
    CarouselView * carouselView;
    CommentViewController * commentView;
    
    UIImagePickerController * camera;
    
    LoadingAnimationView * activityIndicator;
    
    IBOutlet UIButton * buttonFeedback;
    
    NSObject<VerticalFeedDelegate> * delegate;
    
    NSMutableDictionary *userPhotos;
    
    NSMutableArray * allTags;
    FeedTableController *tableController;	
    int lastPageViewed;
    int lastContentOffset;
    
    CGPoint feedItemViewOffset;
    
    UIView * stixHeader;
    UIView * stixHeaderBody;
    
//    IBOutlet UIButton * buttonShowCarousel;
//    IBOutlet UIImageView * carouselTab;
//    int isShowingCarousel;
//    NSString * stixSelected;
    
    RaisedCenterTabBarController * tabBarController;
}
@property (nonatomic, retain) NSMutableDictionary * feedItems;
@property (nonatomic, retain) NSMutableDictionary * headerViews;
@property (nonatomic, assign) CarouselView * carouselView;
@property (nonatomic, retain) NSMutableArray *allTags;
@property (nonatomic, retain) FeedTableController *tableController;
@property (nonatomic, assign) NSObject<VerticalFeedDelegate> * delegate;
@property (nonatomic, retain) NSMutableDictionary * userPhotos;
@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, assign) int lastPageViewed;
@property (nonatomic, retain) CommentViewController * commentView;
@property (nonatomic, retain) UIImagePickerController * camera;
//@property (nonatomic, retain) IBOutlet UIButton * buttonShowCarousel;
//@property (nonatomic, retain) IBOutlet UIImageView * carouselTab;
@property (nonatomic, assign) RaisedCenterTabBarController * tabBarController;
//@property (nonatomic, retain) NSString * stixSelected;


-(void)forceUpdateCommentCount:(int)tagID;
-(void)configureCarouselView;
-(void)reloadCurrentPage;
-(IBAction)feedbackButtonClicked:(id)sender;
-(IBAction)didClickJumpButton:(id)sender;
-(void)jumpToPageWithTagID:(int)tagID;
-(void)openCommentForPageWithTagID:(NSNumber*)tagID;
-(IBAction)adminStixButtonPressed:(id)sender;
-(UIView*)reloadViewForItemAtIndex:(int)index;
-(void)finishedCheckingForNewData:(bool)updated;
-(void)didDropStixByDrag:(UIImageView *) badge ofType:(NSString*)stixStringID;
-(void)didDropStixByTap:(UIImageView *) badge ofType:(NSString*)stixStringID;
-(void)addAuxStix:(UIImageView *) badge ofType:(NSString*)stixStringID toTag:(Tag*)tag;
@end



