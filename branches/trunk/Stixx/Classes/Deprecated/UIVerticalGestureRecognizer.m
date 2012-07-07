//
//  UIVerticalGestureRecognizer.m
//  Stixx
//
//  Created by Bobby Ren on 12/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
// to create a gesture recognizer, we must implement touch functions to determine 
// what kind of gesture it is.
// 
// this gesture recognizer only recognizes vertical pan/drag motions. on any 
// horizontal motion, swipe, or tap, it will set its state to fail.
// there must be a handler to handle the individual states including fail.
//
// to use this to create a draggable image inside a scrollview, fail on any
// horizontal motions, so those motions are passed to the scrollview for scrolling.
// handle vertical motions so instead of scrolling the uiimageview gets dragged
// out of the scrollview as desired.

#import "UIVerticalGestureRecognizer.h"

@implementation UIVerticalGestureRecognizer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];	
    firstTouch = [touch locationInView:self.view];
    isDrag = NO;
	isDown = YES;
    dragCt = 0;
    
    [super touchesBegan: touches withEvent: event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//[self touchesBegan:touches withEvent:event];
	if (isDown == YES)
	{
        isDrag = YES;
        dragCt++;
    }   
    
    if (dragCt == 3) {
        UITouch * touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:self.view];
        currTouch = location;
        float dx = location.x - firstTouch.x;
        float dy = location.y - firstTouch.y;
        translation.x = dx;
        translation.y = dy;
        if (abs(dx) > abs(dy)) // horizontal motion
        {
            self.state = UIGestureRecognizerStateFailed;
            NSLog(@"Vertical gesture failed");
        }
        else
        {
            self.state = UIGestureRecognizerStateBegan;
            NSLog(@"Vertical gesture began at %f %f in view at %f %f!", location.x, location.y, self.view.frame.origin.x, self.view.frame.origin.y);
        }
    }
    if (dragCt > 3) {
        self.state = UIGestureRecognizerStateChanged;

        UITouch * touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:self.view];
        currTouch = location;
        float dx = location.x - firstTouch.x;
        float dy = location.y - firstTouch.y;
        translation.x = dx;
        translation.y = dy;

        NSLog(@"Vertical gesture continuing at %f %f in view at %f %f!", location.x, location.y, self.view.frame.origin.x, self.view.frame.origin.y);
    }
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isDrag) {
        if (dragCt < 3) {
            self.state = UIGestureRecognizerStateFailed;
        }
        else {
            self.state = UIGestureRecognizerStateEnded;
        }
        isDown = NO;
        isDrag = NO;
        dragCt = 0;
    }
    [super touchesEnded:touches withEvent:event];
}

-(CGPoint)translation {
    return translation;
}
-(CGPoint)firstTouch {
    return firstTouch;
}
-(CGPoint)currTouch {
    return currTouch;
}
@end
