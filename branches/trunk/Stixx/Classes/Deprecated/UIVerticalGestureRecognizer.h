//
//  UIVerticalGestureRecognizer.h
//  Stixx
//
//  Created by Bobby Ren on 12/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIKit/UIGestureRecognizerSubclass.h"

@interface UIVerticalGestureRecognizer : UIGestureRecognizer
{
    CGPoint firstTouch;
    CGPoint translation;
    CGPoint currTouch;
    bool isDrag;
    bool isDown;
    int dragCt;
}

-(CGPoint)translation;
-(CGPoint)firstTouch;
-(CGPoint)currTouch;
@end
