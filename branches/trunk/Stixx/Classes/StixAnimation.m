//
//  StixAnimation.m
//  Stixx
//
//  Created by Bobby Ren on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StixAnimation.h"
#import "QuartzCore/QuartzCore.h"

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
                    }
     ];
    return myAnimationID; // when we initialize the animation give it an id
}

-(int)doJump:(UIView *)canvas inView:(UIView*) view forDistance:(int)pixels forTime:(float)time {
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

-(int)doSlide:(UIView *)canvas inView:(UIView*)view toFrame:(CGRect)frameEnd forTime:(float)time {
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

-(void)doFadeOut:(UIView *)canvas forTime:(float)time withCompletion:(void (^)(BOOL))_completion {
    // same as doFade but with no delegate calls
    [canvas setAlpha:1];
    animationID++;
    [UIView animateWithDuration:time
                          delay:0
                        options: UIViewAnimationCurveEaseIn 
                     animations: ^ { 
                         [canvas setAlpha:0];
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

-(void)doSpinHelper:(UIView *)canvas forTime:(float)time atAngle:(float)radians withCompletion:(void (^)(BOOL))_completion {
    float timeDelta = .05;
    float radianDelta = M_PI*2*timeDelta;
    if (time < timeDelta) {
        CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI*2 * time);
        [UIView animateWithDuration:time
                              delay:0
                            options: UIViewAnimationCurveLinear 
                         animations: ^ { 
                             [canvas setTransform:rot];
                         } 
                         completion:_completion];
    }
    else {
        CGAffineTransform rot1 = CGAffineTransformMakeRotation(radianDelta + radians);
        [UIView animateWithDuration:timeDelta
                              delay:0
                            options: UIViewAnimationCurveLinear 
                         animations: ^ { 
                             [canvas setTransform:rot1];
                         } 
                         completion:^(BOOL finished) {
                             //[self doSpinHelper:canvas forTime:time-.1 atRadius:radians withCompletion:_completion];
                             [self doSpinHelper:canvas forTime:time-timeDelta atAngle:radians+radianDelta withCompletion:_completion];
                         }
         ];
    }
}
-(void)doSpin:(UIView *)canvas forTime:(float)time withCompletion:(void (^)(BOOL))_completion {
    // same as doFade but with no delegate calls
    animationID++;
    // we want a full rotation every second
    // so the total radians to rotate through for a period of time is
    // time * 6.28
#if 1
    [self doSpinHelper:canvas forTime:time atAngle:0 withCompletion:_completion];
#else
    CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animation];
    theAnimation.values = [NSArray arrayWithObjects:
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,0,1)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.13, 0,0,1)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(6.26, 0,0,1)],
                           nil];
    theAnimation.cumulative = YES;
    theAnimation.duration = time;
    theAnimation.repeatCount = 0;
    theAnimation.removedOnCompletion = YES;
    
    theAnimation.timingFunctions = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], 
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                    nil
                                    ];
    [canvas.layer addAnimation:theAnimation forKey:@"transform"];
#endif
}

-(void)doBounce:(UIView *)canvas inView:(UIView*)view forDistance:(int)pixels forTime:(float)time {
    [view addSubview:canvas];
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
                                              [canvas removeFromSuperview];
                                              [self doBounce:canvas inView:view forDistance:pixels forTime:time];
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
