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
    
    bool showGiftStix;
}

//@property (nonatomic, assign) NSObject<CarouselViewDelegate> *delegate;
@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, assign) int carouselHeight;
@property (nonatomic, assign) bool showGiftStix;

-(void)toggleShelf:(bool)isHidden;
-(void)initCarouselWithFrame:(CGRect)frame;
-(void)reloadAllStix;
-(void)reloadAllStixWithFrame:(CGRect)frame;
-(void)clearAllViews;
-(void)vibe:(id)sender;
@end
