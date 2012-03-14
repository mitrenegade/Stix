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

//#define SHELF_STIX_X 0
//#define SHELF_STIX_Y 340
#define SHELF_STIX_SIZE 70
#define SHELF_HEIGHT 300
#define USE_VERTICAL_GESTURE 0
#define STIX_PER_ROW 4
#define SHELF_SCROLL_OFFSET_FROM_TOP 108
#define NUM_STIX_FOR_BORDER 0 // put an empty stix on the edge of the content so stix isn't always at the very edge of the screen

enum {
    SHELF_CATEGORY_ALL = 0,
    SHELF_CATEGORY_CUTE,
    SHELF_CATEGORY_FACEFUN,
    SHELF_CATEGORY_MAX
};

@interface CarouselView : BadgeView <UIScrollViewDelegate, UIGestureRecognizerDelegate, StixAnimationDelegate>{
	
    int carouselHeight;
    //NSObject<CarouselViewDelegate> *delegate;
    
    UIScrollView * scrollView;
    
    // arrays of the stix that appear in the carousel
    NSMutableDictionary * allCarouselStixFrames;
    NSMutableDictionary * allCarouselStixViews;
    NSMutableDictionary * allCarouselStixStringIDsAtFrame;
    
    bool allowTap;
    //CGPoint tapDefaultOffset; // offset of default location for tap  relative to carouselView frame
    
    UIButton * buttonShowCarousel;
    UIView * carouselTab;
    BOOL isShowingCarousel;
    NSString * stixSelected;
    int shelfCategory;

    int tabAnimationIDDismiss;
    int tabAnimationIDExpand;
}

//@property (nonatomic, assign) NSObject<CarouselViewDelegate> *delegate;
@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, assign) int carouselHeight;
@property (nonatomic, assign) bool allowTap;
//@property (nonatomic, assign) CGPoint tapDefaultOffset;
@property (nonatomic, retain) UIButton * buttonShowCarousel;
@property (nonatomic, retain) NSMutableArray * buttonCategories;
@property (nonatomic, retain) NSMutableArray * buttonCategoriesSelected;
@property (nonatomic, retain) NSMutableArray * buttonCategoriesNotSelected;
@property (nonatomic, retain) UIView * carouselTab;
@property (nonatomic, retain) NSString * stixSelected;
@property (nonatomic, assign) int dismissedTabY;
@property (nonatomic, assign) int expandedTabY;
@property (nonatomic, assign)     BOOL isShowingCarousel;


-(void)initCarouselWithFrame:(CGRect)frame; // private function
-(void)reloadAllStix;
-(void)reloadAllStixWithFrame:(CGRect)frame;
-(void)clearAllViews;
-(void)vibe:(id)sender;

-(void)carouselTabExpand:(BOOL)doAnimation;
-(void)carouselTabDismiss:(BOOL)doAnimation;
-(void)didClickShowCarousel:(id)sender;
-(void)didClickShelfCategory:(id)sender;

/*** make a singleton class ***/
+(CarouselView*)sharedCarouselView;

@end
