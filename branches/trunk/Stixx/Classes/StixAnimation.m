//
//  StixAnimation.m
//  Stixx
//
//  Created by Bobby Ren on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StixAnimation.h"

@implementation StixAnimation

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// TODO: return to delegate with didFinishAnimation
static int animationID = 1;

-(int)doDownwardFade:(UIView *)canvas inView:(UIView*)view forDistance:(int)pixels forTime:(float)time {
    //[canvas retain];
    [view addSubview:canvas];
    //[self addSubview:canvas];
    int myAnimationID = animationID++;
    int centerX = canvas.center.x; //canvas.frame.origin.x + canvas.frame.size.width/2;
    int centerY = canvas.center.y + pixels; //canvas.frame
    CGPoint endPoint = CGPointMake(centerX, centerY); 

    [UIView animateWithDuration:time
                          delay:0
//    [UIView transitionWithView:canvas 
//                      duration:time
                       options:UIViewAnimationCurveEaseOut //UIViewAnimationTransitionNone 
                    animations: ^ { 
                        [canvas setCenter:endPoint];
                        [canvas setAlpha:0];
                    } 
                    completion:^(BOOL finished) { 
                        [self.delegate didFinishAnimation:myAnimationID withCanvas:canvas];
                        //[canvas release];
                    }
     ];
    return myAnimationID; // when we initialize the animation give it an id
}

-(int)doJump:(UIView *)canvas inView:(UIView*) view forDistance:(int)pixels forTime:(float)time {
    [canvas retain];
    [view addSubview:canvas];
    int myAnimationID = animationID++;
    int centerX = canvas.center.x;
    int centerY = canvas.center.y - pixels;
    CGPoint endPoint = CGPointMake(centerX, centerY); 
//    [UIView transitionWithView:canvas 
//                      duration:time/2
    [UIView animateWithDuration:time/2
                          delay:0
                       options:UIViewAnimationTransitionNone 
                    animations: ^ { 
                        [canvas setCenter:endPoint];
                    } 
                    completion:^(BOOL finished) { 
                        int centerX = canvas.center.x; 
                        int centerY = canvas.center.y + pixels;
                        CGPoint endPoint = CGPointMake(centerX, centerY); 
//                        [UIView transitionWithView:canvas 
//                                          duration:time/2
                        [UIView animateWithDuration:time/2
                                              delay:0
                                           options:UIViewAnimationTransitionNone 
                                        animations: ^ { 
                                            [canvas setCenter:endPoint];
                                        } 
                                        completion:^(BOOL finished) { 
                                            [self.delegate didFinishAnimation:myAnimationID withCanvas:canvas];
                                        }
                         ];    
                    }
     ];
    return myAnimationID;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
