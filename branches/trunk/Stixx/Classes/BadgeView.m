//
//  BadgeView.m
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "BadgeView.h"

@implementation BadgeView

@synthesize delegate;
@synthesize underlay;
//@synthesize badgeFire, badgeIce, shelf;
@synthesize labelFire, labelIce;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
  
    // load self from NIB
#if 0
    [[NSBundle mainBundle] loadNibNamed:@"BadgeView" owner:self options:nil];
    //[self addSubview:self];
#else
    UIImageView * shelf = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf.png"]] autorelease];
    shelf.frame = CGRectMake(0, 381, 320, 30);
    UIImageView * badgeFire = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fire.png"]] autorelease];
    badgeFire.frame = CGRectMake(94, 329, 42, 67);
    UIImageView * badgeIce = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ice.png"]] autorelease];
    badgeIce.frame = CGRectMake(181, 329, 42, 67);
    [self addSubview:shelf];
    [self addSubview:badgeFire];
    [self addSubview:badgeIce];
    
    labelFire = nil;
    labelIce = nil;
    
#endif
    badges = [[NSMutableArray alloc] init];//initWithObjects:badgeFire, badgeComment, nil];
    [badges addObject:badgeFire];
    [badges addObject:badgeIce];
    //[badges addObject:badgeComment];
    
    badgeLocations = [[NSMutableArray alloc] init];
    badgesLarge = [[NSMutableArray alloc] init];
    badgesShadow = [[NSMutableArray alloc] init];
    
    UIImageView * fireLarge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fire_big.png"]];
    UIImageView * iceLarge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ice_big.png"]];
    //UIImageView * fireShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fire_shadow.png"]];
    //UIImageView * iceShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ice_shadow.png"]];
    
    [badgesLarge addObject:fireLarge];
    [badgesLarge addObject:iceLarge];
    //[badgesShadow addObject:fireShadow];
    //[badgesShadow addObject:iceShadow];
    
    [fireLarge release];
    [iceLarge release];
    //[fireShadow release];
    //[iceShadow release];
    CGRect labelFrame = CGRectMake(94+15, 329+20, 42, 67);
    labelFire = [[OutlineLabel alloc] initWithFrame:labelFrame];
    [labelFire drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
    labelFrame = CGRectMake(181+15, 329+20, 42, 67);
    labelIce = [[OutlineLabel alloc] initWithFrame:labelFrame];
    [labelIce drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
    labels = [[NSMutableArray alloc] init];
    [labels addObject:labelFire];
    [labels addObject:labelIce];
    //[self addSubview:labelFire];
    //[self addSubview:labelIce];
    
    unsigned numEls = [badges count];
    while (numEls--)
    {
        UIImageView * badge = [badges objectAtIndex:numEls];
        //badge.frame = CGRectMake(BADGE_X_START + (BADGE_FRAME_WIDTH + BADGE_X_BORDER) * numEls, BADGE_Y_START, BADGE_FRAME_WIDTH, BADGE_FRAME_HEIGHT);
        //		 [badgeLocations insertObject:[NSValue valueWithCGRect:badge.frame] atIndex:numEls+1];
        [badgeLocations insertObject:[NSValue valueWithCGRect:badge.frame] atIndex:0];
    }
 	return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"BadgeView" owner:self options:nil];
    //[self addSubview:self];
}

-(UIImage * )composeImage:(UIImage *) baseImage withOverlay:(UIImage *) overlayImage;
{

	CGRect scaledFrame; 
	CGFloat offsetX = baseImage.size.width / 10;
	CGFloat offsetY = baseImage.size.height / 10;
	scaledFrame.size.width = baseImage.size.width + offsetX * 2;
	scaledFrame.size.height = baseImage.size.height + offsetY * 2;
	CGSize targetSize = CGSizeMake(scaledFrame.size.width, scaledFrame.size.height);	
	
	UIGraphicsBeginImageContext(targetSize);	
	[baseImage drawInRect:CGRectMake(0, 0, baseImage.size.width, baseImage.size.height)];	
	[overlayImage drawInRect:CGRectMake(offsetX, offsetY, overlayImage.size.width, overlayImage.size.height)];	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();																					
	return result;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self];//touch.view];
	drag = 0;
    
    if ([self.delegate respondsToSelector:@selector(didStartDrag)]) 
        [self.delegate performSelector:@selector(didStartDrag)];
	
	// find which icon is being dragged
	unsigned numEls = [badges count];
	while (numEls--)
	{
		UIImageView * badge = [badges objectAtIndex:numEls];
		CGRect frame = badge.frame;
		int left = frame.origin.x;
		int right = frame.origin.x + frame.size.width;
		int top = frame.origin.y;
		int bottom = frame.origin.y + frame.size.height;
		//NSLog(@"Badge %d: left right top bottom { %d %d %d %d} touch: %f %f", numEls, left, right, top, bottom, location.x, location.y);
		if (location.x > left && location.x < right && 
				location.y > top && location.y < bottom)
		{
			badgeTouched = badge;
			drag = 1;
			badgeSelect = numEls;
            [[labels objectAtIndex:badgeSelect] removeFromSuperview];
			break;
		}
	}
	if (drag == 0)
	{
		//NSLog(@"No badge dragged");
        // pass event to nextResponder, which is first the controller, then the view's superview
	}
	else
	{
		badgeTouched.contentMode = UIViewContentModeScaleAspectFit; // allow scaling based on frame
		badgeTouchedLarge = [badgesLarge objectAtIndex:badgeSelect];
		CGRect frameStart = badgeTouched.frame;
		CGRect frameEnd = badgeTouchedLarge.frame;
		int centerX = (frameStart.origin.x + frameStart.size.width/2);
		int centerY = (frameStart.origin.y + frameStart.size.height/2);
		
		frameEnd.origin.x = centerX - frameEnd.size.width / 2;
		frameEnd.origin.y = centerY - frameEnd.size.height / 2;
		
		offset_from_center_X = (location.x - centerX);
		offset_from_center_Y = (location.y - centerY);
		
		badgeTouchedLarge.frame = frameEnd;
		
		// animate a scaling transition
		[UIView 
		 animateWithDuration:0.2
		 delay:0 
		 options:UIViewAnimationCurveEaseOut
		 animations:^{
			 badgeTouched.frame = frameEnd;
		 }
		 completion:^(BOOL finished){
			 badgeTouched.hidden = NO;
		 }
		 ];
		
		//NSLog(@"Dragging badge %d", badgeSelect);
		
	}
	//fire.center = location;
	//NSLog(@"Location: %f %f", location.x, location.y);
    [super touchesBegan: touches withEvent: event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//[self touchesBegan:touches withEvent:event];
	if (drag == 1)
	{
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:self];//touch.view];

		//NSLog(@"Dragging to %f %f", location.x, location.y);

		// update frame of dragged badge, also scale
		float scale = 1; // do not change scale while dragging
		if (badgeTouched == nil)
			return;
		CGRect frame = badgeTouched.frame;
		int width = frame.size.width * scale;
		int height = frame.size.height * scale;
		int centerX = location.x - offset_from_center_X;
		int centerY = location.y - offset_from_center_Y;
		frame.origin.x = centerX - width / 2;
		frame.origin.y = centerY - height / 2;
		frame.size.width = width;
		frame.size.height = height;
		badgeTouched.frame = frame;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (drag == 1)
	{
		if (badgeTouched != nil)
		{
			CGRect originalFrame = [[badges objectAtIndex:badgeSelect] frame];
			CGRect frame = badgeTouched.frame;
			int width = originalFrame.size.width;
			int height = originalFrame.size.height;
			int centerX = frame.origin.x + frame.size.width / 2;
			int centerY = frame.origin.y + frame.size.height / 2;
			frame.origin.x = centerX - width/2;
			frame.origin.y = centerY - width/2;
			frame.size.width = width;
			frame.size.height = height;
			
			//NSLog(@"Badge released with frame origin at %f %f", frame.origin.x, frame.origin.y);
			
			// animate a scaling transition
			[UIView 
			 animateWithDuration:0.2
			 delay:0 
			 options:UIViewAnimationCurveEaseOut
			 animations:^{
				 badgeTouched.frame = frame;
			 }
			 completion:^(BOOL finished){
				 badgeTouched.hidden = NO;
			 }
			 ];
			
			// tells delegate to do necessary things such as take a photo
			//if ([self.delegate respondsToSelector:@selector(didDropStix:)]) {
				//[self.delegate performSelector:@selector(didDropStix: withObject:badgeTouched withObject:badgeSelect)];
            [self.delegate didDropStix:badgeTouched ofType:badgeSelect];
			//}	
		}
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // badgeView should only respond to touch events if we are touching the badges. otherwise,
    // foward the event to the underlay of badgeController, which is a sibling/same level view controller
    // that is also a subview of badgeController's superview
    //
    // for example:
    // badgeView
    //   ^                  scrollView
    //   |                      ^
    //   |                      |
    //    ---- feedView --------
    // this specifically makes badgeView call hitTest on scrollView; scrollView must be set
    // as an underlay of badgeController by feedView when the subviews are laid out
    
    UIView * result;
    if (self.underlay)
        result = [self.underlay hitTest:point withEvent:event];
    else 
        result = [super hitTest:point withEvent:event];
    
	unsigned numEls = [badges count];
	while (numEls--)
	{
		UIImageView * badge = [badges objectAtIndex:numEls];        
        CGPoint buttonPoint = [badge convertPoint:point fromView:self];
        if ([badge pointInside:buttonPoint withEvent:event])
            return self; // if touch event is on a badge, then have badgeView process it
    }
    
    // if the touch was not on one of the badges, either return the known underlay or just
    // return self which means the hit is not passed downwards to anything else
    return result;
}

-(void)resetBadgeLocations {
	
	unsigned numEls = [badges count];
	while (numEls--)
	{
		UIImageView * badge = [badges objectAtIndex:numEls];
        [badge removeFromSuperview];
        if ([delegate getStixCount:numEls] < 1)
            [badge setAlpha:.25];
        else
            [badge setAlpha:1];
		badge.frame = [[badgeLocations objectAtIndex:numEls] CGRectValue];
        [self addSubview:badge];
	}
    [self updateStixCounts];
    drag = 0;
}

-(void)updateStixCounts {
    int countFire = [self.delegate getStixCount:BADGE_TYPE_FIRE];
    if (countFire > -1)
    {
        [labelFire removeFromSuperview];
        [labelFire setText:[NSString stringWithFormat:@"%d", countFire]];
        [self addSubview:labelFire];
    }
    int countIce = [self.delegate getStixCount:BADGE_TYPE_ICE];
    if (countIce > -1)
    {
        [labelIce removeFromSuperview];
        [labelIce setText:[NSString stringWithFormat:@"%d", countIce]];
        [self addSubview:labelIce];
    }
}

+(UIImageView *) getBadgeOfType:(int)type {
    // returns a half size image view
    if (type == BADGE_TYPE_FIRE)
    {
        UIImageView * badgeFire = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fire.png"]] autorelease];
        badgeFire.frame = CGRectMake(0, 0, 42, 67);
        return badgeFire;
    }
    else if (type == BADGE_TYPE_ICE)
    {
        UIImageView * badgeIce = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ice.png"]] autorelease];
        badgeIce.frame = CGRectMake(0, 0, 42, 67);
        return badgeIce;
    }
    else return nil;
}
-(int)getOppositeBadgeType:(int)type {
    if (type == BADGE_TYPE_FIRE)
        return BADGE_TYPE_ICE;
    else
        return BADGE_TYPE_FIRE;
}


- (void)dealloc {
	[super dealloc];
}

@end
