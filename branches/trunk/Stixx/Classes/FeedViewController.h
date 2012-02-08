//
//  FeedViewController.h
//  ARKitDemo
//
//  Created by Administrator on 8/17/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagViewController.h"
#import "FeedItemViewController.h"
#import "PagedScrollView.h"
#import "CarouselView.h"
#import "ZoomViewController.h"
#import "LoadingAnimationView.h"
#import "CommentViewController.h"
#import "AuxStixViewController.h"

#define FEED_ITEM_WIDTH 275
#define FEED_ITEM_HEIGHT 300

@protocol FeedViewDelegate

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
-(void)didAddStixToPix:(Tag *)tag withStixStringID:(NSString*)stixStringID withLocation:(CGPoint)location withScale:(float)scale withRotation:(float)rotation;
-(void)didCreateBadgeView:(UIView*)newBadgeView;
-(int)getCommentCount:(int)tagID;

-(void)didPerformPeelableAction:(int)action forTagWithIndex:(int)tagIndex forAuxStix:(int)index;
-(void)didClickFeedbackButton:(NSString*)fromView;
-(void)didDismissSecondaryView;

-(void)didPressAdminEasterEgg:(NSString*)view;
@end

@interface FeedViewController : UIViewController<PagedScrollViewDelegate, BadgeViewDelegate, ZoomViewDelegate, FeedItemViewDelegate, CommentViewDelegate, AuxStixViewControllerDelegate> {
    
	NSMutableDictionary * feedItems;
    //BadgeView * badgeView;
    CarouselView * carouselView;
    ZoomViewController * zoomViewController;
    CommentViewController * commentView;
    
    UIImagePickerController * camera;
    
    LoadingAnimationView * activityIndicator;
    
    IBOutlet UILabel * nameLabel;
    IBOutlet UIButton * buttonFeedback;
    
    NSObject<FeedViewDelegate> * delegate;
    
    NSMutableDictionary *userPhotos;
    
    NSMutableArray * allTags;
    PagedScrollView *scrollView;	
    int lastPageViewed;
    int lastContentOffset;
}
@property (nonatomic, retain) NSMutableDictionary * feedItems;
//@property (nonatomic, retain) BadgeView *badgeView;
@property (nonatomic, retain) CarouselView * carouselView;
@property (nonatomic, retain) NSMutableArray *allTags;
@property (nonatomic, retain) PagedScrollView *scrollView;
@property (nonatomic, assign) NSObject<FeedViewDelegate> * delegate;
@property (nonatomic, retain) NSMutableDictionary * userPhotos;
@property (nonatomic, retain) IBOutlet UILabel * nameLabel;
@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, assign) int lastPageViewed;
@property (nonatomic, retain) ZoomViewController * zoomViewController;
@property (nonatomic, retain) CommentViewController * commentView;
@property (nonatomic, retain) UIImagePickerController * camera;

-(void)forceUpdateCommentCount:(int)tagID;
-(void)createCarouselView;
-(void)reloadCarouselView;
-(void)reloadCurrentPage;
-(IBAction)feedbackButtonClicked:(id)sender;
-(IBAction)didClickJumpButton:(id)sender;
-(void)jumpToPageWithTagID:(int)tagID;
-(void)openCommentForPageWithTagID:(NSNumber*)tagID;
-(IBAction)adminStixButtonPressed:(id)sender;
@end



