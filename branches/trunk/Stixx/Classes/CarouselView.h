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

#define SHELF_STIX_X 0
#define SHELF_STIX_Y 340
#define SHELF_STIX_SIZE 70

@interface CarouselView : BadgeView <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
	
    int carouselHeight;
    //NSObject<CarouselViewDelegate> *delegate;
    
    UIScrollView * scrollView;
    
    // arrays of the stix that appear in the carousel
    NSMutableArray * allCarouselStixFrames;
    NSMutableArray * allCarouselStixViews;
    
    bool allowTap;
    CGPoint tapDefaultOffset; // offset of default location for tap  relative to carouselView frame
    
    bool showGiftStix;
    
    float sizeOfStixContext; // optional ivar that determines stix scaling - normal stix ratio is a stix frame from [BadgeView getBadgeOfStixStringID] inside a 300x275 camera view. sizeOfStixContext replaces the 300 with a width in pixels
}

//@property (nonatomic, assign) NSObject<CarouselViewDelegate> *delegate;
@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, assign) int carouselHeight;
@property (nonatomic, assign) bool showGiftStix;
@property (nonatomic, assign) float sizeOfStixContext;
@property (nonatomic, assign) bool allowTap;
@property (nonatomic, assign) CGPoint tapDefaultOffset;

-(void)toggleHideShelf:(bool)isHidden;
-(void)initCarouselWithFrame:(CGRect)frame;
-(void)reloadAllStix;
-(void)reloadAllStixWithFrame:(CGRect)frame;
-(void)clearAllViews;
-(void)vibe:(id)sender;
@end
