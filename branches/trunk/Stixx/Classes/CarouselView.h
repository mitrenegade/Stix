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

@interface CarouselView : UIView <UIScrollViewDelegate>{
	NSMutableArray * stixArray;
	
    int carouselHeight;
    int stixLevel;
	//NSObject<CarouselViewDelegate> *delegate;
    
    UIScrollView * scrollView;
}

//@property (nonatomic, assign) NSObject<CarouselViewDelegate> *delegate;
@property (nonatomic, retain) NSMutableArray * stixArray; // access allowed
@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, assign) int carouselHeight;
@property (nonatomic, assign) int stixLevel;

-(void)initWithStixLevel:(int)level;

@end
