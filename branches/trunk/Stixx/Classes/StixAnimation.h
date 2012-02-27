//
//  StixAnimation.h
//  Stixx
//
//  Created by Bobby Ren on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StixAnimationDelegate <NSObject>

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView*)canvas;

@end

@interface StixAnimation : UIView {
    NSObject<StixAnimationDelegate> * delegate;
}
@property (nonatomic, assign) NSObject<StixAnimationDelegate> * delegate;

-(int)doDownwardFade:(UIView *)canvas inView:(UIView*)view forDistance:(int)pixels forTime:(float)time;
-(int)doJump:(UIView *)canvas inView:(UIView*) view forDistance:(int)pixels forTime:(float)time;
@end