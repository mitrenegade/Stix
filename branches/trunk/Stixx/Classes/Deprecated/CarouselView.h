//
//  CarouselView.h
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//BadgeView

#import <UIKit/UIKit.h>
#import "OutlineLabel.h"
#import "BadgeView.h"
#import "UIVerticalGestureRecognizer.h"
#import <AudioToolbox/AudioServices.h>
#import "StixAnimation.h"
#import "Kumulos.h"
#import "GlobalHeaders.h"

//#define SHELF_STIX_X 0
//#define SHELF_STIX_Y 340
#define SHELF_STIX_SIZE 70
#define SHELF_HEIGHT 300
#define USE_VERTICAL_GESTURE 0
#define STIX_PER_ROW 4
#define SHELF_SCROLL_OFFSET_FROM_TOP 108
#define SHELF_LOWER_FROM_TOP 0
#define NUM_STIX_FOR_BORDER 0 // put an empty stix on the edge of the content so stix isn't always at the very edge of the screen

@interface CarouselView : BadgeView <UIScrollViewDelegate, UIGestureRecognizerDelegate, StixAnimationDelegate, KumulosDelegate>{
	
    //int carouselHeight;
    //NSObject<CarouselViewDelegate> *delegate;
    
    UIScrollView * stixScroll;
    UIScrollView * categoryScroll;
    
    // arrays of the stix that appear in the carousel
    NSMutableDictionary * allCarouselStixFrames;
    NSMutableDictionary * allCarouselStixViews;
    NSMutableDictionary * allCarouselStixStringIDsAtFrame;
    NSMutableSet * allCarouselMissingStixStringIDs;
    NSMutableDictionary * allCarouselMissingStixStringOpacity;
    NSMutableSet * premiumPacksPurchased;
    NSMutableDictionary * premiumPurchaseButtons;
    
    bool allowTap;
    //CGPoint tapDefaultOffset; // offset of default location for tap  relative to carouselView frame
    
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
    
    Kumulos * k;

}

//@property (nonatomic, assign) NSObject<CarouselViewDelegate> *delegate;
@property (nonatomic) UIScrollView * stixScroll;
@property (nonatomic) UIScrollView * categoryScroll;
//@property (nonatomic, assign) int carouselHeight;
@property (nonatomic, assign) bool allowTap;
//@property (nonatomic, assign) CGPoint tapDefaultOffset;
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
+(CarouselView*)sharedCarouselView;

-(void)initCarouselWithFrame:(CGRect)frame; // private function
-(void)reloadAllStix;
-(void)reloadAllStixWithFrame:(CGRect)frame;
-(void)clearAllViews;
-(void)vibe:(id)sender;

-(void)carouselTabExpand:(BOOL)doAnimation;
-(void)carouselTabDismiss:(BOOL)doAnimation;
-(void)didClickShowCarousel:(id)sender;
-(void)didClickShelfCategory:(id)sender;
-(void)requestStixFromKumulos:(NSString *)stixStringID;
-(int)saveStixDataToDefaultsForStixStringID:(NSString*)stixStringID;

-(void)unlockPremiumPack:(NSString*)stixPackName;
-(BOOL)isPremiumStix:(NSString*)stixStringID;
-(BOOL)isPremiumStixPurchased:(NSString*)stixStringID;
-(NSString*)getCurrentCategory;
@end
