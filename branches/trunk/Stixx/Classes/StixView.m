//
//  StixView.m
//  Stixx
//
//  Created by Bobby Ren on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StixView.h"
#import <QuartzCore/QuartzCore.h>

@implementation StixView

@synthesize stix;
@synthesize stixCount;
@synthesize interactionAllowed;
@synthesize stixScale;
@synthesize stixRotation;
@synthesize auxStixViews, auxStixStringIDs;
@synthesize isPeelable;

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

-(void)initializeWithImage:(UIImage*)imageData andStix:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y andScale:(float)scale andRotation:(float)rotation {
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:imageData];
    [self addSubview:imageView];
    [imageView release];
    
    stixScale = scale;
    stixRotation = rotation;
    
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
	stixFrameScaled.size.width *= imageScale * stixScale;
	stixFrameScaled.size.height *= imageScale * stixScale;
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
    
    // add pinch gesture recognizer
    UIPinchGestureRecognizer * myGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureHandler:)];
    [myGestureRecognizer setDelegate:self];
    
    UITapGestureRecognizer * myTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    [myTapRecognizer setNumberOfTapsRequired:2];
    [myTapRecognizer setNumberOfTouchesRequired:1];
    [myTapRecognizer setDelegate:self];

    if (isPeelable)
        [self addGestureRecognizer:myTapRecognizer];
    if (interactionAllowed) {
        [self addGestureRecognizer:myGestureRecognizer];
    }
}

//-(void)populateWithAuxStix:(NSMutableArray *)auxStix withLocations:(NSMutableArray *)auxLocations withScales:(NSMutableArray *)auxScales withRotations:(NSMutableArray *)auxRotations {
-(void)populateWithAuxStixFromTag:(Tag *)tag {
    auxStixStringIDs = tag.auxStixStringIDs;
    NSMutableArray * auxLocations = tag.auxLocations;
    NSMutableArray * auxScales = tag.auxScales;
    NSMutableArray * auxRotations = tag.auxRotations;
    NSMutableArray * auxPeelable = tag.auxPeelable;
    auxStixViews = [[NSMutableArray alloc] init];
    for (int i=0; i<[auxStixStringIDs count]; i++) {
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:i];
        CGPoint location = [[auxLocations objectAtIndex:i] CGPointValue];
        float auxScale, auxRotation;
        // hack: backwards compatibility 
        if ([auxScales count] == [auxStixStringIDs count]) {
            auxScale = [[auxScales objectAtIndex:i] floatValue];
            auxRotation = [[auxRotations objectAtIndex:i] floatValue];
        }
        else
        {
            auxScale = 1;
            auxRotation = 0;
        }
        UIImageView * auxStix = [BadgeView getBadgeWithStixStringID:stixStringID];
        //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
        float centerX = location.x;
        float centerY = location.y;
        
        // scale stix and label down to 270x270 which is the size of the feedViewItem
        CGRect stixFrameScaled = auxStix.frame;
        stixFrameScaled.size.width *= imageScale * auxScale;
        stixFrameScaled.size.height *= imageScale * auxScale;
        centerX *= imageScale;
        centerY *= imageScale;
        //NSLog(@"FeedItemView: Scaling badge of %f %f at %f %f in image %f %f down to %f %f at %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, centerX / imageScale, centerY / imageScale, imageData.size.width, imageData.size.height, stixFrameScaled.size.width, stixFrameScaled.size.height, centerX, centerY, imageView.frame.size.width, imageView.frame.size.height); 
        [auxStix setFrame:stixFrameScaled];
        [auxStix setCenter:CGPointMake(centerX, centerY)];
        
        if (isPeelable) {
            if ([[auxPeelable objectAtIndex:i] boolValue] == YES) {
                // turn this stix into an animated one
#if 0
                [auxStix setAnimationDuration:.5];
                [auxStix setAnimationRepeatCount:0];
                UIImage * img1 = [[auxStix image] copy];
                UIImage * img2 = [UIImage imageNamed:@"120_blank.png"];
                [auxStix setAnimationImages:[NSMutableArray arrayWithObjects:img1,img2, nil]];
                [auxStix startAnimating];
#else
                CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                UIImage * img1 = [[auxStix image] copy];
                UIImage * img2 = [UIImage imageNamed:@"120_blank.png"];
                crossFade.duration = 1.0;
                crossFade.fromValue = (id)(img1.CGImage);
                crossFade.toValue = (id)(img2.CGImage);
                crossFade.repeatCount = 0;
                [auxStix.layer addAnimation:crossFade forKey:@"animateContents"];
                
#endif
            }
        }
        [self addSubview:auxStix];
        NSLog(@"StixView: adding auxStix %@ at center %f %f\n", stixStringID, centerX, centerY);
        
        [auxStixViews addObject:auxStix];
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionAllowed == NO) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    if (isDragging) // will come here if a second finger touches
        return;
    
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self];
	isDragging = 0;
    
    CGRect frame = stix.frame;
    if (CGRectContainsPoint(frame, location))
    {
        isDragging = 1;
    }
    
    // point where finger clicked badge
    offset_x = (location.x - stix.center.x);
    offset_y = (location.y - stix.center.y);
    
    NSLog(@"Touches began: center %f %f touch offset %f %f", stix.center.x, stix.center.y, location.x, location.y);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionAllowed == NO) {
        [super touchesMoved:touches withEvent:event];
        return;
    }

	if (isDragging == 1)
	{
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:self];
		// update frame of dragged badge, also scale
		//float scale = 1; // do not change scale while dragging
        
		float centerX = location.x - offset_x;
		float centerY = location.y - offset_y;
        
        // filter out rogue touches, usually when people are using a pinch
        if (abs(centerX - stix.center.x) > 50 || abs(centerY - stix.center.y) > 50) 
            return;
        
        stix.center = CGPointMake(centerX, centerY);
        if (stixCount != nil)
            stixCount.center = CGPointMake(centerX - [BadgeView getOutlineOffsetX:0], centerY - [BadgeView getOutlineOffsetX:0]);
        NSLog(@"Touches moved: new center %f %f", stix.center.x, stix.center.y);
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionAllowed == NO) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    NSLog(@"Touches ended: new center %f %f", stix.center.x, stix.center.y);

	if (isDragging == 1)
	{
        isDragging = 0;
	}
}

-(void)doubleTapGestureHandler:(UITapGestureRecognizer*) gesture {
    CGPoint location = [gesture locationInView:self];
    for (int i=0; i<[self.auxStixViews count]; i++) {
        CGRect frame = [[auxStixViews objectAtIndex:i] frame];
        NSLog(@"Stix %d at %f %f %f %f", i, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        if (CGRectContainsPoint(frame, location)) {
            NSLog(@"Tapped on stix %d of type %@ at %f %f", i, [auxStixStringIDs objectAtIndex:i], location.x, location.y);
        }
    }
}

-(void)pinchGestureHandler:(UIPinchGestureRecognizer*) gesture {
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        isPinching = YES;
        NSLog(@"StixView: Pinch motion started! scale %f velocity %f", [gesture scale], [gesture velocity]);
        frameBeforeScale = stix.frame;
        CGPoint center = stix.center;
        NSLog(@"Original center: %f %f", center.x, center.y);
    }
    else if ([gesture state] == UIGestureRecognizerStateChanged) {
        //if (isDragging) return;
        NSLog(@"StixView: Pinch changing! scale %f velocity %f", [gesture scale], [gesture velocity]);
        float newscale = [gesture scale];
        if ((stixScale * newscale) > 3)
            return;
        CGPoint center = stix.center;
        NSLog(@"Old center: %f %f", center.x, center.y);
        CGRect stixFrameScaled = frameBeforeScale;
        stixFrameScaled.size.width *= newscale;
        stixFrameScaled.size.height *= newscale;
        stix.frame = stixFrameScaled;
        stix.center = center;
        NSLog(@"New center: %f %f", center.x, center.y);
    }    
    else if ([gesture state] == UIGestureRecognizerStateEnded) {
        //if (isDragging) return;
        stixScale = stixScale * [gesture scale];
        if (stixScale > 3)
            stixScale = 3;
        NSLog(@"Frame scale changed by %f: overall scale %f", [gesture scale], stixScale);
    }
}
@end
