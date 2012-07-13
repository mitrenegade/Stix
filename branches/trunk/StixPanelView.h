//
//  StixPanelView.h
//  Stixx
//
//  Created by Bobby Ren on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KumulosHelper.h"
#import "GlobalHeaders.h"
#import "LoadingAnimationView.h"
#import "StixAnimation.h"

#define SHELF_STIX_SIZE 70
#define SHELF_HEIGHT 300
#define USE_VERTICAL_GESTURE 0
#define STIX_PER_ROW 4
#define SHELF_SCROLL_OFFSET_FROM_TOP 108
#define SHELF_LOWER_FROM_TOP 0
#define NUM_STIX_FOR_BORDER 0 // put an empty stix on the edge of the content so stix isn't always at the very edge of the screen

@protocol StixPanelDelegate <NSObject>

-(void)didTapStixOfType:(NSString*)stixStringID;
-(void)didDismissCarouselTab;
-(void)didExpandCarouselTab;

@end

@protocol StixPanelPurchaseDelegate <NSObject>

-(BOOL)shouldPurchasePremiumPack:(NSString*)stixPackName usingStixStringID:(NSString*)stixStringID;

@end

@interface StixPanelView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray * badges;
	NSMutableArray * badgeLocations; // original frame of each badge

	NSObject<StixPanelDelegate> *__unsafe_unretained delegate;
	NSObject<StixPanelPurchaseDelegate> *__unsafe_unretained delegatePurchase;

	UIView * __weak underlay; // pointer to a sibling view of the badgeView owned by its superview's controller - for hitTest

    NSMutableArray * stixStringIDs;
    NSMutableDictionary * stixDescriptors;
    NSMutableDictionary * stixViews;
    NSMutableDictionary * stixCategories; // key: category name value: array of stixStringIDs
    int totalStixTypes;
    
    UIScrollView * stixScroll;
    UIScrollView * categoryScroll;
    
    // arrays of the stix that appear in the carousel
    NSMutableDictionary * allCarouselStixFrames;
    NSMutableDictionary * allCarouselStixViews;
    NSMutableDictionary * allCarouselStixStringIDsAtFrame;
    NSMutableSet * premiumPacksPurchased;
    NSMutableDictionary * premiumPurchaseButtons;
    
    UIButton * buttonShowCarousel;
    UIView * carouselTab;
    UIImageView * tabImage;
    BOOL isShowingCarousel;
    NSString * stixSelected;
    int shelfCategory;
    CGRect scrollFrameRegular;
    CGRect scrollFramePremium;
    
    int tabAnimationIDDismiss;
    int tabAnimationIDExpand;
    
    NSMutableArray * buttonCategories;
    NSMutableArray * buttonCategoriesSelected;
    NSMutableArray * buttonCategoriesNotSelected;
    
    LoadingAnimationView * activityIndicatorLarge;
    BOOL isPromptingPremiumPurchase;
}

@property (nonatomic, unsafe_unretained) NSObject<StixPanelDelegate> *delegate;
@property (nonatomic, unsafe_unretained) NSObject<StixPanelPurchaseDelegate> *delegatePurchase;
@property (nonatomic, weak) UIView * underlay;

@property (nonatomic) UIScrollView * stixScroll;
@property (nonatomic) UIScrollView * categoryScroll;

@property (nonatomic) NSMutableArray * stixStringIDs;
@property (nonatomic) NSMutableDictionary * stixDescriptors;
@property (nonatomic) NSMutableDictionary * stixViews;
@property (nonatomic) NSMutableDictionary * stixCategories; // key: category name value: array of stixStringIDs
@property (nonatomic) int totalStixTypes;
@property (nonatomic) UIButton * buttonShowCarousel;
@property (nonatomic) NSMutableArray * buttonCategories;
@property (nonatomic) NSMutableArray * buttonCategoriesSelected;
@property (nonatomic) NSMutableArray * buttonCategoriesNotSelected;
@property (nonatomic) UIView * carouselTab;
@property (nonatomic) NSString * stixSelected;
@property (nonatomic, assign) int dismissedTabY;
@property (nonatomic, assign) int expandedTabY;
@property (nonatomic, assign) BOOL isShowingCarousel;

/*** make a singleton class ***/
+(StixPanelView*)sharedStixPanelView;

-(void)InitializeDefaultStixTypes;
-(void)InitializePremiumStixTypes;
-(void)initCarouselWithFrame:(CGRect)frame; // private function
-(void)reloadAllStix;
-(void)reloadAllStixWithFrame:(CGRect)frame;

// categories
-(NSString*)getCurrentCategory;
-(NSMutableArray *) getStixForCategory:(NSString*)categoryName;

// individual stix calls
-(NSString*)getStixStringIDAtIndex:(int)index;
-(UIImageView *) getStixWithStixStringID:(NSString*)stixStringID;
-(NSString *)getStixDescriptorForStixStringID:(NSString*)stixStringID;

// premium
-(void)unlockPremiumPack:(NSString*)stixPackName usingStixStringID:(NSString*)stixStringID;
-(BOOL)isPremiumStix:(NSString*)stixStringID;
-(BOOL)isPremiumStixPurchased:(NSString*)stixStringID;

// carousel tab/panel
-(void)carouselTabExpand:(BOOL)doAnimation;
-(void)carouselTabDismiss:(BOOL)doAnimation;
-(void)toggleShowPanel;

@end
