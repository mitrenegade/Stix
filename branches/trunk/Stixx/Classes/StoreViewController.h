//
//  StoreViewController.h
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "StoreCategoriesController.h"
#import "CarouselView.h"
#import "CoverflowViewController.h"
#import "Kumulos.h"
#import "UIImage+Resize.h"
#import "LoadingAnimationView.h"

@protocol StoreViewDelegate

- (NSString*)getUsername;

// forward from BadgeViewDelegate
-(int)getStixCount:(NSString*)stixStringID;
-(void)didCreateBadgeView:(UIView*)newBadgeView;
-(void)didClickFeedbackButton:(NSString*)fromView;
-(void)didClickGetStix:(NSString*)stixStringID;
@end

@interface StoreViewController : UIViewController <BadgeViewDelegate, StoreCategoriesControllerDelegate, CoverflowViewControllerDelegate, KumulosDelegate> {
    //BadgeView * badgeView;
    
    Kumulos * k;
    
    IBOutlet UIButton * buttonFeedback;
    IBOutlet UIButton * buttonBack;
    
    //StoreCategoriesController * tableController;
    CoverflowViewController * coverflowController;
    
    NSObject<StoreViewDelegate> * delegate;
    
    NSMutableArray * categories;
    NSMutableArray * filenames;
    NSMutableDictionary * subcategories; // dictionary of arrays
    NSMutableDictionary * tables; // dictionary of table views
    
    StoreCategoriesController * currTableController;
    
    int categoryLevel; // 0 if looking at main category table, 1 if looking at subcategory table
    int categorySelected;
    
    LoadingAnimationView * activityIndicator;
}

@property (nonatomic, assign) NSObject<StoreViewDelegate> * delegate;
@property (nonatomic, retain) IBOutlet UIButton * buttonBack;
//@property (nonatomic, retain) StoreCategoriesController * tableController;
@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) CoverflowViewController * coverflowController;
@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, retain) NSDate * lastUpdate;

-(IBAction)didClickBackButton:(id)sender;
-(IBAction)feedbackButtonClicked:(id)sender;
-(int)addCategory:(NSString*)categoryName withFilename:(NSString*)filename;
-(int)addSubcategory:(NSString*)subcategoryName toCategory:(NSString*)categoryName;
-(void)populateCoverflow;
-(StoreCategoriesController *)populateTableForCategory:(NSString*)category;
@end
