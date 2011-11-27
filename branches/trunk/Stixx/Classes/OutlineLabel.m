//
//  OutlineLabel.m
//  Stixx
//
//  Created by Bobby Ren on 11/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OutlineLabel.h"

@implementation OutlineLabel: UILabel

@synthesize outlineColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.shadowOffset = CGSizeMake (1,1);
        self.textColor = [UIColor whiteColor];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOutlineColor:[UIColor blackColor]];
        [self setFont:[UIFont fontWithName:@"Helvetica Bold" size:20]];
        [self setTextAlignment:UITextAlignmentCenter];
        [self setFrame:frame];

    }
    
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    if (c == nil)
        return;
    CGContextSetLineWidth(c, 2);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = [self outlineColor];
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
    
}


@end
