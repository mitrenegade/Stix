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
//#import "DetailViewController.h"
#import "LoadingAnimationView.h"
#import "StixView.h"
#import "StixAnimation.h"
#import "OutlineLabel.h"
#import "ProfileViewController.h"
#import "RaisedCenterTabBarController.h"
#import "KumulosHelper.h"
#import "GlobalHeaders.h"
#import "FlurryAnalytics.h"

@protocol ExploreViewDelegate
-(UIImage*)getUserPhotoForUsername:(NSString *)username;

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;

-(int)getNewestTagID;
-(NSString*)getUsername;

-(void)shouldDisplayUserPage:(NSString*)username;

-(void)pauseAggregation;
-(void)shouldDisplayDetailViewWithTag:(Tag*)tag;
@end

enum {
    EXPLORE_RANDOM = 0,
    EXPLORE_RECENT,
    EXPLORE_POPULAR,
    EXPLORE_MODE_MAX
};

@interface ExploreViewController : UIViewController <ColumnTableControllerDelegate, KumulosDelegate, StixViewDelegate, StixAnimationDelegate, UIActionSheetDelegate, UIAlertViewDelegate, KumulosHelperDelegate> 
{
    int exploreMode;
    int numColumns;
    
    ColumnTableController * tableController;
    NSObject<ExploreViewDelegate> * __unsafe_unretained delegate;
    
#if HAS_PROFILE_BUTTON
    IBOutlet UIButton * buttonProfile;
#endif
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
    //bool isZooming; // prevent hits when zooming
    
    //DetailViewController * detailController;
    NSString * galleryUsername;
        
    IBOutlet UIImageView * logo;
    int openDetailAnimation;
    
    int shareActionSheetTagID;
    
    NSMutableArray * exploreModeButtons;
    
    int pendingContentCount; // prevents multiple rows from being loaded because our latest tag is not set yet
    
    Kumulos * k;
    
    Tag * tagToRemix;
    
    BOOL bHasView;
    BOOL bHasTable;
    BOOL bShowedTable;
    BOOL didInitialSetExploreMode;
    int indexPointer; // pointer to location in allTagIDs currently being populated with a random tag
    NSDate * lastDate;
}

@property (nonatomic) ColumnTableController * tableController;
@property (nonatomic, unsafe_unretained) NSObject<ExploreViewDelegate> * delegate;
@property (nonatomic) LoadingAnimationView * activityIndicator;
#if HAS_PROFILE_BUTTON
@property (nonatomic) IBOutlet UIButton * buttonProfile;
#endif
@property (nonatomic, weak) RaisedCenterTabBarController * tabBarController;
@property (nonatomic, copy) NSString * galleryUsername;
@property (nonatomic) Tag * tagToRemix;
//-(void)getTagWithID:(int)id;
//-(IBAction)feedbackButtonClicked:(id)sender;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(void)initializeTable;
-(void)forceReloadAll;
#if HAS_PROFILE_BUTTON
-(IBAction)didClickProfileButton:(id)sender;
#endif
-(void) setExploreMode:(UIButton*)button;
-(void)fakeDidGetAuxiliaryStixOfTagWithID:(NSNumber*)tagID;
@end
