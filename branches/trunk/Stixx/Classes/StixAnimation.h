//
//  StixAnimation.h
//  Stixx
//
//  Created by Bobby Ren on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StixAnimationDelegate <NSObject>
@optional
-(void)didFinishAnimation:(int)animationID withCanvas:(UIView*)canvas;
@end

@interface StixAnimation : UIView {
    NSObject<StixAnimationDelegate> * __unsafe_unretained delegate;
}
@property (nonatomic, unsafe_unretained) NSObject<StixAnimationDelegate> * delegate;

-(int)doDownwardFade:(UIView *)canvas inView:(UIView*)view forDistance:(int)pixels forTime:(float)time;
-(int)doJump:(UIView *)canvas inView:(UIView*) view forDistance:(int)pixels forTime:(float)time;
-(int)doSlide:(UIView *)canvas inView:(UIView*)view toFrame:(CGRect)frameEnd forTime:(float)time ;
-(int)doFade:(UIView *)canvas inView:(UIView*)view toAlpha:(float)opacityEnd forTime:(float)time;

-(void)doViewTransition:(UIView *)canvas toFrame:(CGRect)frameEnd forTime:(float)time withCompletion:(void (^)(BOOL finished))_completion;
-(void)doFadeIn:(UIView*)canvas forTime:(float)time withCompletion:(void (^)(BOOL finished))_completion;
-(void)doFadeOut:(UIView *)canvas forTime:(float)time withCompletion:(void (^)(BOOL))_completion;
-(void)doShake:(UIView *)canvas angleInDegrees:(float)deg forTime:(float)time withCompletion:(void (^)(BOOL))_completion;
-(void)doPulse:(UIView *)canvas forTime:(float)time repeatCount:(int)repeat withCompletion:(void (^)(BOOL))_completion;
-(void)doSpin:(UIView *)canvas forTime:(float)time withCompletion:(void (^)(BOOL))_completion;
-(void)doBounce:(UIView *)canvas inView:(UIView*)view forDistance:(int)pixels forTime:(float)time;
@end
