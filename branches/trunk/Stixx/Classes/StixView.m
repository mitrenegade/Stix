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
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        interactionAllowed = YES;
    }
    return self;
}

// populates with the image data for the pix
-(void)initializeWithImage:(UIImage*)imageData {
    originalImageSize = imageData.size;
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:imageData];
    [self addSubview:imageView];
    [imageView release];
}

// originally initializeWithImage: withStix:
// this function creates a temporary stix object that can be manipulated
-(void)populateWithStixForManipulation:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y andScale:(float)scale andRotation:(float)rotation {
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    stixScale = scale;
    stixRotation = rotation;
    
    stix = [BadgeView getBadgeWithStixStringID:stixStringID];
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float centerX = x;
    float centerY = y;
    NSLog(@"StixView creating %@ stix to %d %d in image of size %f %f", stixStringID, x, y, self.frame.size.width, self.frame.size.height);
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = originalImageSize;
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
    
    /*
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
     */
    
    // add pinch gesture recognizer
    UIPinchGestureRecognizer * myGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureHandler:)];
    [myGestureRecognizer setDelegate:self];
    
#if 0
    UITapGestureRecognizer * myTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    [myTapRecognizer setNumberOfTapsRequired:2];
    [myTapRecognizer setNumberOfTouchesRequired:1];
    [myTapRecognizer setDelegate:self];

    if (isPeelable)
        [self addGestureRecognizer:myTapRecognizer];
#endif
    
    if (interactionAllowed) {
        [self addGestureRecognizer:myGestureRecognizer];
    }
}

//-(void)populateWithAuxStix:(NSMutableArray *)auxStix withLocations:(NSMutableArray *)auxLocations withScales:(NSMutableArray *)auxScales withRotations:(NSMutableArray *)auxRotations {
-(void)populateWithAuxStixFromTag:(Tag *)tag {
    auxStixStringIDs = tag.auxStixStringIDs;
    NSMutableArray * auxLocations = tag.auxLocations;
    NSMutableArray * auxRotations = tag.auxRotations;
    auxPeelableByUser = [[NSMutableArray alloc] init]; // = tag.auxPeelable;
    auxStixViews = [[NSMutableArray alloc] init];
    auxScales = [[NSMutableArray alloc] init];
    for (int i=0; i<[auxStixStringIDs count]; i++) {
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:i];
        CGPoint location = [[auxLocations objectAtIndex:i] CGPointValue];
        float auxScale, auxRotation;
        // hack: backwards compatibility 
        if ([tag.auxScales count] == [auxStixStringIDs count]) {
            auxScale = [[tag.auxScales objectAtIndex:i] floatValue];
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
        CGSize originalSize = originalImageSize;
        CGSize targetSize = self.frame.size;
        imageScale =  targetSize.width / originalSize.width;

        CGRect stixFrameScaled = auxStix.frame;
        stixFrameScaled.size.width *= imageScale * auxScale;
        stixFrameScaled.size.height *= imageScale * auxScale;
        centerX *= imageScale;
        centerY *= imageScale;
        //NSLog(@"FeedItemView: Scaling badge of %f %f at %f %f in image %f %f down to %f %f at %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, centerX / imageScale, centerY / imageScale, imageData.size.width, imageData.size.height, stixFrameScaled.size.width, stixFrameScaled.size.height, centerX, centerY, imageView.frame.size.width, imageView.frame.size.height); 
        [auxStix setFrame:stixFrameScaled];
        [auxStix setCenter:CGPointMake(centerX, centerY)];
        
        bool isPeelableByUser = NO;
        if (isPeelable) {
            if ([[tag.auxPeelable objectAtIndex:i] boolValue] == YES && [tag.username isEqualToString:[self.delegate getUsername]]) {

                isPeelableByUser = YES;
                // turn this stix into an animated one
                CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                UIImage * img1 = [[auxStix image] copy];
                UIImage * img2 = [UIImage imageNamed:@"120_blank.png"];
                crossFade.duration = 1.0;
                crossFade.fromValue = (id)(img1.CGImage);
                crossFade.toValue = (id)(img2.CGImage);
                crossFade.autoreverses = YES;
                crossFade.repeatCount = HUGE_VALF;
                [auxStix.layer addAnimation:crossFade forKey:@"crossFade"];
            } 
            else {
                isPeelableByUser = NO;
            }
        }
        [self addSubview:auxStix];
        //NSLog(@"StixView: adding %@ auxStix %@ at center %f %f\n", isPeelableByUser?@"peelable":@"attached", stixStringID, centerX, centerY);
        
        [auxStixViews addObject:auxStix];
        [auxScales addObject:[NSNumber numberWithFloat:auxScale]];
        [auxPeelableByUser addObject:[NSNumber numberWithBool:isPeelableByUser]];
    }
}

-(void)doPeelAnimationForStix:(int)index {
    UIImageView * auxStix = [auxStixViews objectAtIndex:index];
    [auxStix.layer removeAllAnimations];
    CGRect frameLift = auxStix.frame;
    CGPoint center = auxStix.center;
    frameLift.size.width *= 2;
    frameLift.size.height *= 2;
    frameLift.origin.x = center.x - frameLift.size.width / 2;
    frameLift.origin.y = center.y - frameLift.size.height / 2;
    [UIView transitionWithView:auxStix 
                      duration:.5
                       options:UIViewAnimationTransitionNone 
                    animations: ^ { auxStix.frame = frameLift; } 
                    completion: nil
     ];
    CGRect frameDisappear = CGRectMake(160, 300, 5, 5);
    [UIView transitionWithView:auxStix 
                      duration:.5
                       options:UIViewAnimationTransitionNone 
                    animations: ^ { auxStix.frame = frameDisappear; } 
                    completion:^(BOOL finished) { 
                        [auxStix removeFromSuperview]; 
                        [self.delegate peelAnimationDidCompleteForStix:index]; 
                    }
     ]; 
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interactionAllowed == NO) { // skips interaction with stix for dragging
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    if (isDragging) // will come here if a second finger touches
        return;
    
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self];
	isDragging = 0;
    NSLog(@"Touch began at %f %f", location.x, location.y);
    
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
    // do nothing
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

-(bool)isStixPeelable:(int)index {
    bool canBePeeled = [[auxPeelableByUser objectAtIndex:index] boolValue];
    return canBePeeled;
}

-(bool)isForeground:(CGPoint)point inStix:(UIImageView*)selectedStix {
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel, 
                                                 1, 1, 8, 1, NULL,
                                                 kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    UIImage * im = selectedStix.image;
    [im drawAtPoint:CGPointMake(-point.x, -point.y)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGFloat alpha = pixel[0]/255.0;
    BOOL transparent = alpha < 0.9; //0.01;
    NSLog(@"Foreground test: x y %f %f, alpha %f", point.x, point.y, alpha);
    return !transparent;
}

// hack: sent through delegate functions
-(void)didTouchAtLocation:(CGPoint)location {
    if ([self isPeelable]) {

        NSLog(@"Tap detected in stix view at %f %f", location.x, location.y);
        int lastStixView = -1;
        for (int i=0; i<[self.auxStixViews count]; i++) {
            CGRect frame = [[auxStixViews objectAtIndex:i] frame];
            NSLog(@"Stix %d at %f %f %f %f", i, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            if (CGRectContainsPoint(frame, location) && [self isStixPeelable:i]) {
                // also check to see if point has color data or is part of the clear background
                CGPoint locationInFrame = location;
                locationInFrame.x -= frame.origin.x;
                locationInFrame.y -= frame.origin.y;
                // UIImage is always 120x120, so we have to scale the touch from within the current frame to a 120x120 frame
                float scale = 120 / frame.size.width;
                locationInFrame.x *= scale;
                locationInFrame.y *= scale;
                NSLog(@"Tapped in frame <%f %f %f %f> of stix %d of type %@ at %f %f scale %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height, i, [auxStixStringIDs objectAtIndex:i], location.x, location.y, scale);
                if ([self isForeground:locationInFrame inStix:[auxStixViews objectAtIndex:i]]) {
                    lastStixView = i;
                }
            }
        }
        if (lastStixView == -1)
            return;
        
        // display action sheet
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:lastStixView];
        NSString * stixDesc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        NSString * title = [NSString stringWithFormat:@"What do you want to do with your %@", stixDesc];
        stixPeelSelected = lastStixView;
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Peel", @"Stick", /*@"Move", */nil];
        [actionSheet showInView:self];
        [actionSheet release];
    } 
}

//-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
//}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // button index: 0 = "Peel", 1 = "Stick", 2 = "Move", 3 = "Cancel"
    NSLog(@"Button index: %d stixPeelSelected: %d", buttonIndex, stixPeelSelected);
    switch (buttonIndex) {
        case 0: // Peel
            // performing a peel action causes this StixView and its delegate FeedItemView to eventually be deleted/removed. Until that happens and the user interface is correctly populated, do not allow interaction anymore.
            self.isPeelable = NO;
            // remove from delegate's tag structure
            [self.delegate didPeelStix:stixPeelSelected];
            break;
        case 1: // Stick
            self.isPeelable = NO;
            [self.delegate didAttachStix:stixPeelSelected]; // will cause new StixView to be created
            break;
        case 2: // Cancel
            return;
            break;
        default:
            return;
            break;
    }
}


@end
