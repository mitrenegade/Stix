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
        //[self setFont:[UIFont fontWithName:@"Helvetica Bold" size:35]]; does nothing
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
    CGContextSetLineWidth(c, 3);
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

-(void)setTextAttributesForBadgeType:(int)type {
    if (type == HOT_SCHEME) {
        [self setTextColor:[UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1]];
        [self setOutlineColor:[UIColor colorWithRed:102/255.0 green:0 blue:0 alpha:1]];
    }
    else if (type == COLD_SCHEME) {
        [self setTextColor:[UIColor colorWithRed:153/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        [self setOutlineColor:[UIColor colorWithRed:0 green:51/255.0 blue:102/255.0 alpha:1]];        
    }
    else {
        // defaults for now
        [self setTextColor:[UIColor colorWithRed:102/255.0 green:51/255.0 blue:0/255.0 alpha:1]];
        [self setOutlineColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:.8]];        
    }
}


@end
