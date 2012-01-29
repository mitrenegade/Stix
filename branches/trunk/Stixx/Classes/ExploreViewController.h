//
//  ExploreViewController.h
//  Stixx
//
//  Created by Bobby Ren on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "PagedScrollView.h"
#import "Kumulos.h"
#import "Tag.h"
#import "ZoomViewController.h"
#import "LoadingAnimationView.h"
#import "CarouselView.h"
#import "StixView.h"

@protocol ExploreViewDelegate
-(int)getStixCount:(NSString*)stixStringID;
-(void)didCreateBadgeView:(UIView*)newBadgeView;
-(void)didClickFeedbackButton:(NSString*)fromView;
@end

@interface ExploreViewController : UIViewController <BadgeViewDelegate, PagedScrollViewDelegate, KumulosDelegate, ZoomViewDelegate> 
{
    CarouselView * carouselView; 
    PagedScrollView *scrollView;	
    NSObject<ExploreViewDelegate> * delegate;
    ZoomViewController * zoomViewController;
    CGRect zoomFrame;
    UIImageView * zoomView;
    bool isZooming; // prevent hits when zooming
    
    IBOutlet UIButton * buttonFeedback;
    
    NSMutableArray * allTagIDs;
    NSMutableArray * allTags;
    
    LoadingAnimationView * activityIndicator;
    
    StixView * stixView; // the view that is clicked for zoom
    
    int lastContentOffset;
    
    Kumulos * k;
}

@property (nonatomic, retain) CarouselView * carouselView;
@property (nonatomic, retain) PagedScrollView *scrollView;
@property (nonatomic, assign) NSObject<ExploreViewDelegate> * delegate;
@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) NSMutableArray * allTagIDs; 
@property (nonatomic, retain) NSMutableArray * allTags; 
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;

- (IBAction)refreshUpdates:(id)sender;
-(void)getTagWithID:(int)id;
-(void)createCarouselView;
-(void)reloadCarouselView;
-(IBAction)feedbackButtonClicked:(id)sender;

@end
