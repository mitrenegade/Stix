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

@protocol ExploreViewDelegate
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;
-(UIImage*)getUserPhotoForUsername:(NSString *)username;
-(void)sharePix:(int)tagID;
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID;
-(void)uploadImage:(NSData*)dataPNG;
-(void)didOpenProfileView;

-(void)didCreateBadgeView:(UIView*)newBadgeView;
//-(void)didClickFeedbackButton:(NSString*)fromView;

-(int)getNewestTagID;
-(int)getBuxCount;
-(NSString*)getUsername;
@end

enum {
    EXPLORE_RANDOM = 0,
    EXPLORE_RECENT,
    EXPLORE_POPULAR,
    EXPLORE_MODE_MAX
};

@interface ExploreViewController : UIViewController <ColumnTableControllerDelegate, KumulosDelegate, DetailViewDelegate, StixViewDelegate, StixAnimationDelegate, UIActionSheetDelegate, UIAlertViewDelegate> 
{
    int exploreMode;
    int numColumns;
    
    ColumnTableController * tableController;
    NSObject<ExploreViewDelegate> * delegate;
    
//    IBOutlet UIButton * buttonFeedback;
    IBOutlet UIButton * buttonProfile;
    LoadingAnimationView * activityIndicator;
    
    // Feed for EXPLORE_RANDOM
    int newRandomTagsTargetCount;
    NSMutableDictionary * newRandomTags;

    // Feed for EXPLORE_RECENT
    NSDate * timestampMostRecent;
    NSMutableArray * allTagIDs; // ordered in descending order
    NSMutableDictionary * allTags; // key: allTagID
    NSMutableDictionary * contentViews; // generated views: key: row/column index of table

    // zoom view...?
    //StixView * stixView; // the view that is clicked for zoom
    //DetailViewController * DetailViewController;
    //CGRect zoomFrame;
    //UIImageView * DetailView;
    bool isZooming; // prevent hits when zooming
    
    DetailViewController * detailController;
        
    OutlineLabel * labelBuxCount;
    IBOutlet UIImageView * logo;
    int animationID;
    
    int shareActionSheetTagID;
    
    Kumulos * k;
}

@property (nonatomic, retain) ColumnTableController * tableController;
@property (nonatomic, assign) NSObject<ExploreViewDelegate> * delegate;
//@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
//@property (nonatomic, retain) UISegmentedControl * segmentedControl;
@property (nonatomic, retain) OutlineLabel * labelBuxCount;
@property (nonatomic, retain) IBOutlet UIButton * buttonProfile;
@property (nonatomic, assign) RaisedCenterTabBarController * tabBarController;
//-(void)getTagWithID:(int)id;
//-(IBAction)feedbackButtonClicked:(id)sender;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
-(void)initializeTable;
-(void)forceReloadAll;
-(IBAction)didClickProfileButton:(id)sender;

@end
