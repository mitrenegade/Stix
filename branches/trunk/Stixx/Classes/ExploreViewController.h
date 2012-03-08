//
//  ExploreViewController.h
//  Stixx
//
//  Created by Bobby Ren on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
//#import "PagedScrollView.h"
#import "ColumnTableController.h"
#import "Kumulos.h"
#import "Tag.h"
#import "ZoomViewController.h"
#import "LoadingAnimationView.h"
//#import "CarouselView.h"
#import "StixView.h"

@protocol ExploreViewDelegate
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;

-(void)didCreateBadgeView:(UIView*)newBadgeView;
-(void)didClickFeedbackButton:(NSString*)fromView;

-(int)getNewestTagID;
@end

enum {
    EXPLORE_RANDOM = 0,
    EXPLORE_RECENT,
    EXPLORE_POPULAR,
    EXPLORE_MODE_MAX
};

@interface ExploreViewController : UIViewController <ColumnTableControllerDelegate, KumulosDelegate, ZoomViewDelegate> 
{
    int exploreMode;
    int numColumns;
    
    ColumnTableController * tableController;
    NSObject<ExploreViewDelegate> * delegate;
    
    IBOutlet UIButton * buttonFeedback;
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
    StixView * stixView; // the view that is clicked for zoom
    ZoomViewController * zoomViewController;
    CGRect zoomFrame;
    UIImageView * zoomView;
    bool isZooming; // prevent hits when zooming
    
    Kumulos * k;
}

//@property (nonatomic, retain) CarouselView * carouselView;
//@property (nonatomic, retain) PagedScrollView *scrollView;
@property (nonatomic, retain) ColumnTableController * tableController;
@property (nonatomic, assign) NSObject<ExploreViewDelegate> * delegate;
@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
//@property (nonatomic, retain) UISegmentedControl * segmentedControl;

//-(void)getTagWithID:(int)id;
//-(void)createCarouselView;
//-(void)reloadCarouselView;
-(IBAction)feedbackButtonClicked:(id)sender;


-(void)initializeTable;
-(void)forceReloadAll;

@end
