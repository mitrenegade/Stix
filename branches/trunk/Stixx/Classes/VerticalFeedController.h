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
//#import "CarouselView.h"
#import "LoadingAnimationView.h"
#import "CommentViewController.h"
#import "AddStixViewController.h"
#import "RaisedCenterTabBarController.h"
#import "KumulosHelper.h"
//#import "BTBitlyHelper.h"
#import "ProfileViewController.h"
#import "OutlineLabel.h"
#import "KumulosHelper.h"
#import "UserProfileViewController.h"
#import "StixAnimation.h"
#import "StixEditorViewController.h"

#define FEED_ITEM_WIDTH 275
#define FEED_ITEM_HEIGHT 300

@protocol VerticalFeedDelegate

-(NSMutableArray *)getTags;
- (NSString*)getUsername;
//-(void)checkForUpdateTags;
-(void)checkForUpdatePhotos;
-(NSMutableDictionary *)getUserPhotos;
-(void)getNewerTagsThanID:(int)tagID;
-(void)getOlderTagsThanID:(int)tagID;
-(void)didAddCommentFromDetailViewController:(DetailViewController*)detailViewController withTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID;
-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID overwrite:(bool)bOverwrite;

- (bool) isLoggedIn;
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;
-(int)getBuxCount;
-(void)didAddStixToPix:(Tag *)tag withStixStringID:(NSString*)stixStringID withLocation:(CGPoint)location /*withScale:(float)scale withRotation:(float)rotation */withTransform:(CGAffineTransform)transform;
-(void)didCreateBadgeView:(UIView*)newBadgeView;
-(int)getCommentCount:(int)tagID;

-(void)didPerformPeelableAction:(int)action forTagWithID:(int)tagID forAuxStix:(int)index;
-(void)didClickFeedbackButton:(NSString*)fromView;
-(void)didDismissSecondaryView;

-(void)didPressAdminEasterEgg:(NSString*)view;

-(void)didPurchaseStixFromCarousel:(NSString*)stixStringID;
//-(BOOL)shouldPurchasePremiumPack:(NSString*)stixPackName;
-(void)didOpenProfileView;
-(NSMutableSet*)getFollowingList;

-(NSMutableDictionary *)getCommentHistoriesForTag:(Tag*)tag;
-(BOOL)isFollowing:(NSString*)name;

-(void)shouldDisplayUserPage:(NSString*)name;
-(void)shouldCloseUserPage;

-(void)checkAggregatorStatus; // debug
-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;

-(int)getFirstTimeUserStage;
-(void)agitateFirstTimePointer;
-(void)advanceFirstTimeUserMessage; // only called by cancel add stix - for convenience

-(void)setFollowing:(NSString *)friendName toState:(BOOL)shouldFollow;
-(void)didDisplayShareSheet;
-(void)didCloseShareSheet;
-(void)didShowBuxInstructions;
-(void)didCloseBuxInstructions;
-(BOOL)isDisplayingShareSheet;
-(BOOL)isShowingBuxInstructions;
-(UIImage*)getUserPhotoForUsername:(NSString*)name;

-(BOOL)isDisplayingShareSheet;
-(BOOL)isShowingBuxInstructions;

-(void)getFirstTags; // called if no tags exist

-(void)didReloadPendingPix:(Tag*)tag;
-(void)pendingTagDidHaveAuxiliaryStix:(Tag*)pendingTag withNewTagID:(int)tagID;
-(void)doParallelNewPixShare:(Tag*)_tag;

-(void)didRemixNewPix:(Tag*)cameraTag remixMode:(int)remixMode;

// check for first time user state
-(BOOL)canClickRemixButton; // test user stage
-(BOOL)canClickNotesButton;
-(void)didClickRemixButton; // advance user stage
-(void)didCloseEditorFromFeedController; // advance user stage
@end

@interface VerticalFeedController : UIViewController<VerticalFeedItemDelegate, BadgeViewDelegate, FeedTableControllerDelegate, CommentViewDelegate, AddStixViewControllerDelegate, KumulosHelperDelegate, KumulosHelperDelegate, UIActionSheetDelegate, UIAlertViewDelegate, StixAnimationDelegate, StixEditorDelegate, UIActionSheetDelegate> {
    
    NSMutableArray * allTags;
    NSMutableArray * allTagsPending;
    NSMutableArray * allTagsDisplayed;
    NSMutableArray * firstTimeArrows;
    UIView * firstTimeArrowCanvas[2];
    
    NSMutableSet * deallocatedIndices;
    
    NSMutableDictionary * feedSectionHeights;
    CommentViewController * commentView;
    
    UIImagePickerController * camera;
    
    LoadingAnimationView * activityIndicator;
    LoadingAnimationView * activityIndicatorLarge;
    
    NSObject<VerticalFeedDelegate> * __unsafe_unretained delegate;
    
    FeedTableController *tableController;	
    int lastPageViewed;
    int lastContentOffset;
    int newestTagIDDisplayed;
    
    int tempTagID;
    
    CGPoint feedItemViewOffset;
    
    UIView * stixHeader;
    UIView * stixHeaderBody;
    
    int currentBuxPurchase;
    
    IBOutlet UIImageView * logo;
    
    //IBOutlet UITextField * statusMessage;
    
    //UserGalleryController * galleryController;
    //UserProfileViewController * userPageController;
    //NSString * galleryUsername;
    
    // stix purchase menu
    int buxAnimationOpen;
    int buxAnimationClose;
    
    // share animation, graphics and actions
    UIImageView * shareSheet;
    UIButton * buttonShareFacebook;
    UIButton * buttonShareEmail;
    UIButton * buttonShareClose;
    int shareMenuOpenAnimation;
    int shareMenuCloseAnimation;
    VerticalFeedItemController * shareFeedItem;
    AddStixViewController * auxView;
    
    RaisedCenterTabBarController * __weak tabBarController;
    
    NSMutableArray * feedItemsWithLikeToolbar;
    StixEditorViewController * stixEditorController;
    Tag * tagToRemix;
    
    BOOL isOpeningProfile;
}
//@property (nonatomic, weak) CarouselView * carouselView;
@property (nonatomic) NSMutableDictionary * feedItems;
@property (nonatomic) NSMutableDictionary * headerViews;
@property (nonatomic) NSMutableDictionary * headerViewsDidLoadPhoto;
@property (nonatomic) NSMutableArray *allTags;
@property (nonatomic) NSMutableArray *allTagsDisplayed;
@property (nonatomic) NSMutableArray * allTagsPending;
@property (nonatomic) FeedTableController *tableController;
@property (nonatomic, unsafe_unretained) NSObject<VerticalFeedDelegate> * delegate;
//@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic) IBOutlet UIButton * buttonProfile;
//@property (nonatomic) OutlineLabel * labelBuxCount;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) LoadingAnimationView * activityIndicatorLarge;
@property (nonatomic, assign) int lastPageViewed;
@property (nonatomic) CommentViewController * commentView;
@property (nonatomic) UIImagePickerController * camera;
@property (nonatomic, weak) RaisedCenterTabBarController * tabBarController;
//@property (nonatomic, retain) NSString * stixSelected;
//@property (nonatomic, copy) NSString * galleryUsername;
//@property (nonatomic) IBOutlet UITextField * statusMessage;
@property (nonatomic, assign) int newestTagIDDisplayed;
@property (nonatomic) IBOutlet UIImageView * logo;
@property (nonatomic) Tag * tagToRemix;

-(void)populateAllTagsDisplayed;
-(void)populateAllTagsDisplayedWithTag:(Tag*)tag;
-(int)addTagForDisplay:(Tag*)tag;
-(void)forceUpdateCommentCount:(int)tagID;
//-(void)configureCarouselView;
-(void)reloadCurrentPage;
-(void)reloadPage:(int)page;
-(void)reloadPageForTagID:(int)tagID;
//-(IBAction)feedbackButtonClicked:(id)sender;
-(IBAction)didClickJumpButton:(id)sender;
-(BOOL)jumpToPageWithTagID:(int)tagID;
-(void)openCommentForPageWithTagID:(NSNumber*)tagID;
-(IBAction)adminStixButtonPressed:(id)sender;
-(UIView*)reloadViewForItemAtIndex:(int)index;
-(void)finishedCheckingForNewData:(bool)updated;
-(void)didDropStixByDrag:(UIImageView *) badge ofType:(NSString*)stixStringID;
//-(void)didDropStixByTap:(UIImageView *) badge ofType:(NSString*)stixStringID;
-(void)addAuxStixOfType:(NSString*)stixStringID toTag:(Tag*)tag;
//- (void) shortenBlastTextUrls:(NSString*)url;
-(IBAction)didClickProfileButton:(id)sender;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(void)followListsDidChange;
-(void)shouldDisplayUserPage:(NSString*)galleryUsername;
-(void)forceReloadWholeTableZOMG;
-(void)didCloseShareSheet;
-(void)finishedCreateNewPix:(Tag*)tag withPendingID:(int)pendingID;
-(void)checkForUpdatedStix;
-(void)updateFeedTimestamps;
-(void)showReloadPendingPix:(Tag*)failedTag;

-(void)startActivityIndicatorLarge;
-(void)stopActivityIndicatorLarge;

-(void)didClickRemixFromDetailView:(Tag*)tag;
-(void)unlockProfile;
@end



