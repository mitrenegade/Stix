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
    [canvas retain];
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
                        [canvas release];
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
                                            [canvas release];
                                        }
                         ];    
                    }
     ];
    return myAnimationID;
}

-(int)doSlide:(UIView *)canvas inView:(UIView*)view toFrame:(CGRect)frameEnd forTime:(float)time {
    [canvas retain];
    // no need to add subview, assume already exists
    //[view addSubview:canvas];
    
    int myAnimationID = animationID++;
    [UIView animateWithDuration:time
                          delay:0
     //    [UIView transitionWithView:canvas 
     //                      duration:time
                        options: UIViewAnimationTransitionNone 
                     animations: ^ { 
                         [canvas setFrame:frameEnd];
                     } 
                     completion:^(BOOL finished) { 
                         if ([delegate respondsToSelector:@selector(didFinishAnimation:withCanvas:)])
                             [self.delegate didFinishAnimation:myAnimationID withCanvas:canvas];
                         [canvas release];
                     }
     ];
    return myAnimationID; // when we initialize the animation give it an id
}

-(void)doViewTransition:(UIView *)canvas toFrame:(CGRect)frameEnd forTime:(float)time withCompletion:(void (^)(BOOL finished))_completion {
    
    animationID++;
    [UIView animateWithDuration:time
                          delay:0
                        options: UIViewAnimationTransitionNone 
                     animations: ^ { 
                         [canvas setFrame:frameEnd];
                     } 
                     completion:_completion
     ];
} 

-(int)doFade:(UIView *)canvas inView:(UIView*)view toAlpha:(float)opacityEnd forTime:(float)time {
    [canvas retain];
    // no need to add subview, assume already exists
    //[view addSubview:canvas];
    
    //[canvas setAlpha:opacityStart];
    int myAnimationID = animationID++;
    [UIView animateWithDuration:time
                          delay:0
                        options: UIViewAnimationTransitionNone 
                     animations: ^ { 
                         [canvas setAlpha:opacityEnd];
                     } 
                     completion:^(BOOL finished) { 
                         [self.delegate didFinishAnimation:myAnimationID withCanvas:canvas];
                         [canvas release];
                     }
     ];
    return myAnimationID; // when we initialize the animation give it an id
}

-(void)doFadeIn:(UIView *)canvas forTime:(float)time withCompletion:(void (^)(BOOL))_completion {
    // same as doFade but with no delegate calls
    [canvas setAlpha:0];
    animationID++;
    [UIView animateWithDuration:time
                          delay:0
                        options: UIViewAnimationCurveEaseIn 
                     animations: ^ { 
                         [canvas setAlpha:1];
                     } 
                     completion:_completion
     ];
}

-(void)doShake:(UIView *)canvas angleInDegrees:(float)deg forTime:(float)time withCompletion:(void (^)(BOOL))_completion {
    // same as doFade but with no delegate calls
    animationID++;
    CGAffineTransform rot = CGAffineTransformMakeRotation(deg / 180 / 3.1415);
    [UIView animateWithDuration:time/4
                          delay:0
                        options: UIViewAnimationCurveEaseIn 
                     animations: ^ { 
                         [canvas setTransform:rot];
                     } 
                     completion:^(BOOL finished) {
                         CGAffineTransform rot = CGAffineTransformMakeRotation(-deg / 180 / 3.1415);
                         [UIView animateWithDuration:time/2
                                               delay:0
                                             options: UIViewAnimationCurveEaseIn 
                                          animations: ^ { 
                                              [canvas setTransform:rot];
                                          } 
                                          completion:^(BOOL finished) {
                                              CGAffineTransform rot = CGAffineTransformMakeRotation(0 / 180 / 3.1415);
                                              [UIView animateWithDuration:time/4
                                                                    delay:0
                                                                  options: UIViewAnimationCurveEaseIn 
                                                               animations: ^ { 
                                                                   [canvas setTransform:rot];
                                                               } 
                                                               completion:
                                                                   _completion
                                               ];
                                          }
                          ];
                     }
     ];
}

-(void)doPulse:(UIView *)canvas forTime:(float)time repeatCount:(int)repeat withCompletion:(void (^)(BOOL))_completion {
    // same as doFade but with no delegate calls
    animationID++;
    [UIView animateWithDuration:time/4
                          delay:time/2
                        options: UIViewAnimationCurveEaseIn 
                     animations: ^ { 
                         [canvas setAlpha:.25];
                     } 
                     completion:^(BOOL finished) {
                         if (repeat == 0) {
                             [UIView animateWithDuration:time/4
                                                   delay:0
                                                 options: UIViewAnimationCurveEaseOut 
                                              animations: ^ { 
                                                  [canvas setAlpha:1];
                                              } 
                                              completion:_completion 
                              ];
                         }
                         else
                             [UIView animateWithDuration:time/4
                                               delay:0
                                             options: UIViewAnimationCurveEaseOut 
                                          animations: ^ { 
                                              [canvas setAlpha:1];
                                          } 
                                          completion:^(BOOL finished) {
                                              if (repeat == -1) {
                                                  [self doPulse:canvas forTime:time repeatCount:repeat withCompletion:_completion];
                                              }
                                              else 
                                                  [self doPulse:canvas forTime:time repeatCount:repeat-1 withCompletion:_completion];
                                          }
                          ];
                     }
     ];
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
