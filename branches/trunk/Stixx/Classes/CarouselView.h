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

@interface CarouselView : BadgeView <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
	
    int carouselHeight;
    int stixLevel;
	//NSObject<CarouselViewDelegate> *delegate;
    
    UIScrollView * scrollView;
}

//@property (nonatomic, assign) NSObject<CarouselViewDelegate> *delegate;
@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, assign) int carouselHeight;
@property (nonatomic, assign) int stixLevel;

-(void)initWithStixLevel:(int)level;
-(void)toggleShelf:(bool)isVisible;
-(void)setCarouselFrame:(CGRect)frame;
@end
