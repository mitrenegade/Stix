//
//  StixView.m
//  Stixx
//
//  Created by Bobby Ren on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StixView.h"

@implementation StixView

@synthesize stix;
@synthesize stixCount;
@synthesize interactionAllowed;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        interactionAllowed = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)initializeWithImage:(UIImage*)imageData andStix:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y {
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:imageData];
    [self addSubview:imageView];
    [imageView release];
    
    stix = [BadgeView getBadgeWithStixStringID:stixStringID];
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float centerX = x;
    float centerY = y;
    NSLog(@"StixView creating %@ stix to %d %d in image of size %f %f", stixStringID, x, y, self.frame.size.width, self.frame.size.height);
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = imageData.size;
	CGSize targetSize = self.frame.size;
	
    imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    centerX *= imageScale;
    centerY *= imageScale;
    //NSLog(@"Scaling badge of %f %f in image %f %f down to %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, imageData.size.width, imageData.size.height, stixFrameScaled.size.width, stixFrameScaled.size.height, imageView.frame.size.width, imageView.frame.size.height); 
    [stix setFrame:stixFrameScaled];
    [stix setCenter:CGPointMake(centerX, centerY)];
    [self addSubview:stix];
    
    if ([stixStringID isEqualToString:@"FIRE"] || [stixStringID isEqualToString:@"ICE"]) {
        
        CGRect labelFrame = stix.frame;
        stixCount = [[OutlineLabel alloc] initWithFrame:labelFrame];
        labelFrame = stixCount.frame; // changing center should change origin but not width
        //[stixCount setFont:[UIFont fontWithName:@"Helvetica Bold" size:5]]; does nothing
        if ([stixStringID isEqualToString:@"FIRE"])
            [stixCount setTextAttributesForBadgeType:0];
        if ([stixStringID isEqualToString:@"ICE"])
            [stixCount setTextAttributesForBadgeType:1];
        [stixCount drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
        [stixCount setText:[NSString stringWithFormat:@"%d", count]];
        [self addSubview:stixCount];
//        [stixCount release];
    }
}

-(void)populateWithAuxStix:(NSMutableArray *)auxStix atLocations:(NSMutableArray *)auxLocations {
    for (int i=0; i<[auxStix count]; i++) {
        NSString * stixStringID = [auxStix objectAtIndex:i];
        CGPoint location = [[auxLocations objectAtIndex:i] CGPointValue];
        
        UIImageView * auxStix = [BadgeView getBadgeWithStixStringID:stixStringID];
        //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
        float centerX = location.x;
        float centerY = location.y;
        
        // scale stix and label down to 270x270 which is the size of the feedViewItem
        CGRect stixFrameScaled = auxStix.frame;
        stixFrameScaled.origin.x *= imageScale;
        stixFrameScaled.origin.y *= imageScale;
        stixFrameScaled.size.width *= imageScale;
        stixFrameScaled.size.height *= imageScale;
        centerX *= imageScale;
        centerY *= imageScale;
        //NSLog(@"FeedItemView: Scaling badge of %f %f at %f %f in image %f %f down to %f %f at %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, centerX / imageScale, centerY / imageScale, imageData.size.width, imageData.size.height, stixFrameScaled.size.width, stixFrameScaled.size.height, centerX, centerY, imageView.frame.size.width, imageView.frame.size.height); 
        [auxStix setFrame:stixFrameScaled];
        [auxStix setCenter:CGPointMake(centerX, centerY)];
        [self addSubview:auxStix];
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionAllowed == NO) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self];
	drag = 0;
    
    CGRect frame = stix.frame;
    int left = frame.origin.x;
    int right = frame.origin.x + frame.size.width;
    int top = frame.origin.y;
    int bottom = frame.origin.y + frame.size.height;
    if (location.x > left && location.x < right && 
        location.y > top && location.y < bottom)
    {
        drag = 1;
    }
    
    // point where finger clicked badge
    offset_x = (location.x - stix.center.x);
    offset_y = (location.y - stix.center.y);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionAllowed == NO) {
        [super touchesMoved:touches withEvent:event];
        return;
    }

	if (drag == 1)
	{
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:self];
		// update frame of dragged badge, also scale
		//float scale = 1; // do not change scale while dragging
		if (!drag)
			return;
        
		float centerX = location.x - offset_x;
		float centerY = location.y - offset_y;
        stix.center = CGPointMake(centerX, centerY);
        if (stixCount != nil)
            stixCount.center = CGPointMake(centerX - [BadgeView getOutlineOffsetX:0], centerY - [BadgeView getOutlineOffsetX:0]);
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionAllowed == NO) {
        [super touchesEnded:touches withEvent:event];
        return;
    }

	if (drag == 1)
	{
        drag = 0;
	}
}

@end
