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
-(void)didGetStixFromStore:(NSString*)stixStringID;
-(void)didDismissSecondaryView;
-(int)getBuxCount;
-(void)showNoMoreMoneyMessage;
-(void)didPurchaseBux:(int)buxPurchased;
@end

@interface StoreViewController : UIViewController <BadgeViewDelegate, StoreCategoriesControllerDelegate, CoverflowViewControllerDelegate, KumulosDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    //BadgeView * badgeView;
    
    Kumulos * k;
    
    IBOutlet UIButton * buttonFeedback;
    IBOutlet UIButton * buttonBack;
    
    //StoreCategoriesController * tableController;
    CoverflowViewController * coverflowController;
    
    NSObject<StoreViewDelegate> * delegate;
    
    NSMutableArray * categories;
    NSMutableArray * covers;
    NSMutableDictionary * subcategories; // dictionary of arrays
    NSMutableDictionary * tables; // dictionary of table views
    
    StoreCategoriesController * currTableController;
    
    int categoryLevel; // 0 if looking at main category table, 1 if looking at subcategory table
    int categorySelected;
    
    LoadingAnimationView * activityIndicator;
    
    // bux bar
    IBOutlet UIImageView * buxBarBg;
    IBOutlet UIImageView * buxBar;
    IBOutlet UIButton * buttonMoreBux;
    IBOutlet UIButton * buttonExpressBux;
    
    // bux label
    IBOutlet UILabel * buxCount;
    
    int currentBuxPurchase;
    
    int lastCategorySelected;
}

@property (nonatomic, assign) NSObject<StoreViewDelegate> * delegate;
@property (nonatomic, retain) IBOutlet UIButton * buttonBack;
//@property (nonatomic, retain) StoreCategoriesController * tableController;
@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) CoverflowViewController * coverflowController;
@property (nonatomic, retain) Kumulos * k;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, retain) NSDate * lastUpdate;

@property (nonatomic, retain) IBOutlet UIImageView * buxBarBg;
@property (nonatomic, retain) IBOutlet UIImageView * buxBar;
@property (nonatomic, retain) IBOutlet UIButton * buttonMoreBux;
@property (nonatomic, retain) IBOutlet UIButton * buttonExpressBux;

@property (nonatomic, retain) IBOutlet UILabel * buxCount;

-(IBAction)didClickBackButton:(id)sender;
-(IBAction)feedbackButtonClicked:(id)sender;
-(int)addCategory:(NSString*) categoryName withCoverImage:(UIImage *)coverImage;
-(int)addSubcategory:(NSString*)subcategoryName toCategory:(NSString*)categoryName;
-(void)populateCoverflow;
-(void)updateBuxCount;
-(StoreCategoriesController *)populateTableForCategory:(NSString*)category;
-(void)reloadTables;
-(IBAction)didClickExpressBuxButton:(id)sender;
-(IBAction)didClickMoreBuxButton:(id)sender;
@end
