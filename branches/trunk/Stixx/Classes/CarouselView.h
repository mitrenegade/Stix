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
    
    bool allowTap;
    CGPoint tapDefaultOffset; // offset of default location for tap  relative to carouselView frame
    
    bool showGiftStix;
    
    float sizeOfStixContext; // optional ivar that determines stix scaling - normal stix ratio is a stix frame from [BadgeView getBadgeOfStixStringID] inside a 300x275 camera view. sizeOfStixContext replaces the 300 with a width in pixels

    UIButton * buttonShowCarousel;
    UIView * carouselTab;
    int isShowingCarousel;
    NSString * stixSelected;
    NSMutableArray * buttonCategories;
    
    int tabAnimationIDDismiss;
    int tabAnimationIDExpand;
}

//@property (nonatomic, assign) NSObject<CarouselViewDelegate> *delegate;
@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, assign) int carouselHeight;
@property (nonatomic, assign) bool showGiftStix;
@property (nonatomic, assign) float sizeOfStixContext;
@property (nonatomic, assign) bool allowTap;
@property (nonatomic, assign) CGPoint tapDefaultOffset;

@property (nonatomic, retain) UIButton * buttonShowCarousel;
@property (nonatomic, retain) NSMutableArray * buttonStixCategories;
@property (nonatomic, retain) UIView * carouselTab;
@property (nonatomic, retain) NSString * stixSelected;
@property (nonatomic, assign) int dismissedTabY;
@property (nonatomic, assign) int expandedTabY;
@property (nonatomic, assign) int scrollOffsetFromTabTop;

-(void)toggleHideShelf:(bool)isHidden;
-(void)initCarouselWithFrame:(CGRect)frame;
-(void)reloadAllStix;
-(void)reloadAllStixWithFrame:(CGRect)frame;
-(void)clearAllViews;
-(void)vibe:(id)sender;

-(void)carouselTabExpand;
-(void)carouselTabDismiss;
-(void)carouselTabDismiss:(BOOL)doAnimation;
-(void)carouselTabDismissWithStix:(UIImageView*)stix;
-(void)didClickShowCarousel:(id)sender;
-(void)carouselTabDismissRemoveStix;
-(void)setShelfCategory:(UIButton*)button;

@end
