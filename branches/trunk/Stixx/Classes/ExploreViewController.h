//
//  ExploreViewController.h
//  Stixx
//
//  Created by Bobby Ren on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "ColumnTableController.h"
#import "Kumulos.h"
#import "Tag.h"
#import "DetailViewController.h"
#import "LoadingAnimationView.h"
//#import "CarouselView.h"
#import "StixView.h"
#import "StixAnimation.h"
#import "OutlineLabel.h"
#import "ProfileViewController.h"
#import "RaisedCenterTabBarController.h"
#import "UserGalleryController.h"
#import "KumulosHelper.h"

@protocol ExploreViewDelegate
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;
-(UIImage*)getUserPhotoForUsername:(NSString *)username;
//-(void)sharePix:(int)tagID;
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID;
-(void)uploadImage:(NSData*)dataPNG withShareMethod:(int)method;
-(void)didOpenProfileView;

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;

-(int)getNewestTagID;
-(int)getBuxCount;
-(NSString*)getUsername;

-(void)shouldDisplayUserPage:(NSString*)username;
-(void)shouldCloseUserPage;
-(void)didShowBuxInstructions;
@end

enum {
    EXPLORE_RANDOM = 0,
    EXPLORE_RECENT,
    EXPLORE_POPULAR,
    EXPLORE_MODE_MAX
};

@interface ExploreViewController : UIViewController <ColumnTableControllerDelegate, KumulosDelegate, DetailViewDelegate, StixViewDelegate, StixAnimationDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UserGalleryDelegate, KumulosHelperDelegate> 
{
    int exploreMode;
    int numColumns;
    
    ColumnTableController * tableController;
    NSObject<ExploreViewDelegate> * __unsafe_unretained delegate;
    
//    IBOutlet UIButton * buttonFeedback;
    IBOutlet UIButton * buttonProfile;
    LoadingAnimationView * activityIndicator;
    LoadingAnimationView * activityIndicatorLarge;
    
    // Feed for EXPLORE_RANDOM
    int newRandomTagsTargetCount;
    NSMutableDictionary * newRandomTags;

    // Feed for EXPLORE_RECENT
    NSDate * timestampMostRecent;
    NSMutableArray * allTagIDs; // ordered in descending order
    NSMutableDictionary * allTags; // key: allTagID
    NSMutableDictionary * contentViews; // generated views: key: row/column index of table
    NSMutableDictionary * placeholderViews; // generated views: key: row/column index of table
    NSMutableDictionary * isShowingPlaceholderView;
    
    UIView * placeholderViewGlobal;

    // zoom view...?
    //StixView * stixView; // the view that is clicked for zoom
    //CGRect zoomFrame;
    //UIImageView * DetailView;
    bool isZooming; // prevent hits when zooming
    
    DetailViewController * detailController;
    UserGalleryController * galleryController;
    NSString * galleryUsername;
        
    OutlineLabel * labelBuxCount;
    IBOutlet UIImageView * logo;
    int openDetailAnimation;
    
    int shareActionSheetTagID;
    
    NSMutableArray * exploreModeButtons;
    
    int pendingContentCount; // prevents multiple rows from being loaded because our latest tag is not set yet
    
    Kumulos * k;
}

@property (nonatomic) ColumnTableController * tableController;
@property (nonatomic, unsafe_unretained) NSObject<ExploreViewDelegate> * delegate;
//@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic) LoadingAnimationView * activityIndicator;
//@property (nonatomic, retain) UISegmentedControl * segmentedControl;
@property (nonatomic) OutlineLabel * labelBuxCount;
@property (nonatomic) IBOutlet UIButton * buttonProfile;
@property (nonatomic, weak) RaisedCenterTabBarController * tabBarController;
@property (nonatomic, copy) NSString * galleryUsername;
@property (nonatomic) DetailViewController * detailController;
//-(void)getTagWithID:(int)id;
//-(IBAction)feedbackButtonClicked:(id)sender;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(void)initializeTable;
-(void)forceReloadAll;
-(IBAction)didClickProfileButton:(id)sender;
-(void) setExploreMode:(UIButton*)button;

@end
