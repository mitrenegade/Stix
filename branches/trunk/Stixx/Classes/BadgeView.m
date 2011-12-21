//
//  BadgeView.m
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "BadgeView.h"

static NSArray * stixFilenames;
static NSArray * stixDescriptors;

@implementation BadgeView

@synthesize delegate;
@synthesize underlay;
@synthesize  showStixCounts;
@synthesize  showRewardStix;
@synthesize badgesLarge;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
  
    UIImageView * shelf = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf.png"]] autorelease];
    shelf.frame = CGRectMake(0, 381, 320, 30);
    /*
    UIImageView * badgeFire = [BadgeView getBadgeOfType:BADGE_TYPE_FIRE];
    badgeFire.center = CGPointMake(115, 365);
    UIImageView * badgeIce = [BadgeView getBadgeOfType:BADGE_TYPE_ICE]; 
    badgeIce.center = CGPointMake(205, 365);
     */
    //[badgeFire setBackgroundColor:[UIColor blackColor]]; // for debug
    //[badgeIce setBackgroundColor:[UIColor blackColor]];
    [self addSubview:shelf];
    //[self addSubview:badgeFire];
    //[self addSubview:badgeIce];
    
    //labelFire = nil;
    //labelIce = nil;
    
    showStixCounts = YES;
    showRewardStix = YES;
    
    badges = [[NSMutableArray alloc] init];
    badgeLocations = [[NSMutableArray alloc] init];
    badgesLarge = [[NSMutableArray alloc] init];
    labels = [[NSMutableArray alloc] init];
    for (int i=0; i<BADGE_TYPE_MAX; i++)
    {
        UIImageView * badgeLarge = [BadgeView getLargeBadgeOfType:i];
        [badgesLarge addObject:badgeLarge];
        UIImageView * badge = [BadgeView getBadgeOfType:i];
        //badge.center = CGPointMake((320-2*BADGE_SHELF_PADDING)/[delegate getStixLevel]*i + (320-2*BADGE_SHELF_PADDING)/[delegate getStixLevel]/2 + BADGE_SHELF_PADDING, 365);         
        [badges addObject:badge];
        [badgeLocations addObject:[NSValue valueWithCGRect:badge.frame]];

        OutlineLabel * label = [[OutlineLabel alloc] initWithFrame:badge.frame];
        [label setCenter:CGPointMake(badge.center.x+[BadgeView getOutlineOffsetX:i], badge.center.y+[BadgeView getOutlineOffsetY:i])];
        [label setTextAttributesForBadgeType:i];
        [label drawTextInRect:CGRectMake(0,0, badge.frame.size.width, badge.frame.size.height)];
        [labels addObject:label];
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
		badgeTouchedLarge = [BadgeView getLargeBadgeOfType:badgeSelect]; // objectAtIndex:badgeSelect];
		//CGRect frameStart = badgeTouched.frame;
		float centerX = badgeTouched.center.x; //(frameStart.origin.x + frameStart.size.width/2);
		float centerY = badgeTouched.center.y; //(frameStart.origin.y + frameStart.size.height/2);
		
		//frameEnd.origin.x = centerX - frameEnd.size.width / 2;
		//frameEnd.origin.y = centerY - frameEnd.size.height / 2;
        badgeTouchedLarge.center = CGPointMake(centerX, centerY);
		CGRect frameEnd = badgeTouchedLarge.frame;
		
        // point where finger clicked badge
		offset_from_center_X = (location.x - centerX);
		offset_from_center_Y = (location.y - centerY);
		
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
		//float scale = 1; // do not change scale while dragging
		if (badgeTouched == nil)
			return;
        /*
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
         */
		float centerX = location.x - offset_from_center_X;
		float centerY = location.y - offset_from_center_Y;
        badgeTouched.center = CGPointMake(centerX, centerY);
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (drag == 1)
	{
		if (badgeTouched != nil)
		{
			CGRect originalFrame = [[badgeLocations objectAtIndex:badgeSelect] CGRectValue];
			/*
             CGRect frame = badgeTouched.frame;
			 int width = originalFrame.size.width;
			int height = originalFrame.size.height;
            int centerX = frame.origin.x + frame.size.width / 2;
			int centerY = frame.origin.y + frame.size.height / 2;
			frame.origin.x = centerX - width/2;
			frame.origin.y = centerY - width/2;
			frame.size.width = width;
			frame.size.height = height;
			*/
            UIImageView * newFrameView = [[UIImageView alloc] initWithFrame:originalFrame];
            newFrameView.center = CGPointMake(badgeTouched.center.x, badgeTouched.center.y);
            CGRect frame = newFrameView.frame;
            [newFrameView release];
            
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
	
    /*
	unsigned numEls = [badges count];
	while (numEls--)
	{
		UIImageView * badge = [badges objectAtIndex:numEls];
        [badge removeFromSuperview];
        //if ([delegate getStixCount:numEls] < 1 && [self showStixCounts] == YES)
        //    [badge setAlpha:.25];
        //else
            [badge setAlpha:1];
		badge.frame = [[badgeLocations objectAtIndex:numEls] CGRectValue];
        [self addSubview:badge];
	}
 */
    for (int i=0; i<BADGE_TYPE_MAX; i++)
    {
        UIImageView * badge = [badges objectAtIndex:i];
        [badge removeFromSuperview];
        OutlineLabel * label = [[OutlineLabel alloc] initWithFrame:badge.frame];
        [label removeFromSuperview];
    }
    int numStix = [delegate getStixLevel];
    if (showRewardStix == NO)
        numStix = 2;
    for (int i=0; i<numStix; i++)
    {
        UIImageView * badge = [badges objectAtIndex:i];
        // for views that only show the action stix, just position for two stix
        int y = 365;
        if (i == BADGE_TYPE_HEART)
            y = 370;
        
        if (numStix == 2) {
            badge.center = CGPointMake((320-2*80)/numStix*i + (320-2*80)/numStix/2 + 80, y);
        }
        else if (numStix == 3) {
            badge.center = CGPointMake((320-2*50)/numStix*i + (320-2*50)/numStix/2 + 50, y);
        }    
        else if (numStix == 4) {
            badge.center = CGPointMake((320-2*30)/numStix*i + (320-2*30)/numStix/2 + 30, y);
        }    
        [self addSubview:badge];

        /* no labels for stix on shelf */
        /*
        OutlineLabel * label = [[OutlineLabel alloc] initWithFrame:badge.frame];
        [label setCenter:CGPointMake(badge.center.x+[BadgeView getOutlineOffsetX:i], badge.center.y+[BadgeView getOutlineOffsetY:i])];
        [label setTextAttributesForBadgeType:i];
        [label drawTextInRect:CGRectMake(0,0, badge.frame.size.width, badge.frame.size.height)];
        
        [self addSubview:label];
         */
    }
    //[self updateStixCounts];
    drag = 0;
}

-(void)updateStixCounts {
    for (int i=0; i<[delegate getStixLevel]; i++) {
        int ct = [self.delegate getStixCount:i];
        if (ct > -1)
        {
            OutlineLabel * label = [labels objectAtIndex:i];
            if ([self showStixCounts])
                [label removeFromSuperview];
            [label setText:[NSString stringWithFormat:@"%d", ct]];
            if ([self showStixCounts])
                [self addSubview:label];
        }
    }
    /*
    int countFire = [self.delegate getStixCount:BADGE_TYPE_FIRE];
    if (countFire > -1)
    {
        if ([self showStixCounts])
            [labelFire removeFromSuperview];
        [labelFire setText:[NSString stringWithFormat:@"%d", countFire]];
        if ([self showStixCounts])
            [self addSubview:labelFire];
    }
    int countIce = [self.delegate getStixCount:BADGE_TYPE_ICE];
    if (countIce > -1)
    {
        if ([self showStixCounts])
            [labelIce removeFromSuperview];
        [labelIce setText:[NSString stringWithFormat:@"%d", countIce]];
        if ([self showStixCounts])
            [self addSubview:labelIce];
    }
     */
}

+(NSArray *) stixFilenames {
    if (!stixFilenames)
    {
        stixFilenames = [[NSArray alloc] initWithObjects: 
                         @"120_fire.png",
                         @"120_ice.png",
                         @"120_bomb.png",
                         @"120_bulb.png",
                         @"120_deal.png",
                         @"120_eyes.png",
                         @"120_glasses.png",
                         @"120_heart.png",
                         @"120_leaf.png",
                         @"120_lips.png",
                         @"120_partyhat.png",
                         @"120_smile.png",
                         @"120_stache.png",
                         @"120_star.png",
                         @"120_sun.png",
                         nil];
    }
    return stixFilenames;
}

+(NSArray *) stixDescriptors {
    if (!stixDescriptors) {
        stixDescriptors = [[NSArray alloc] initWithObjects: 
                           @"Fire Stix",
                           @"Ice Stix",
                           @"Bomb",
                           @"Light Bulb",
                           @"Good Deal",
                           @"Googley Eyes",
                           @"Funky Glasses",
                           @"Heart",
                           @"Leaf",
                           @"Luscious Lips",
                           @"Party Hat",
                           @"Smile",
                           @"The Stache",
                           @"Gold Star",
                           @"Sunny",
                           nil];
    }
    return stixDescriptors;
}

+(UIImageView *) getBadgeOfType:(int)type {
    // returns a half size image view
    UIImageView * stix = [BadgeView getLargeBadgeOfType:type];
    if (stix == nil)
        return nil;
    // create smaller size for actual badgeView
    stix.frame = CGRectMake(0, 0, stix.frame.size.width * .65, stix.frame.size.height*.65); // resize badges to "small size"
    return stix;
}

+(UIImageView *) getLargeBadgeOfType:(int)type {
    // returns a half size image view
    NSArray * filenames = [BadgeView stixFilenames];
    if (type < [filenames count])
    {
        UIImageView * stix = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[filenames objectAtIndex:type]]] autorelease];
        NSLog(@"Loading large badge from filename %@\n", [filenames objectAtIndex:type]);
        return stix;
    }
    return nil;
}
+(UIImageView *) getEmptyBadgeOfType:(int)type {
    // returns a half size image view
    NSArray * filenames = [BadgeView stixFilenames];
    if (type < [filenames count])
    {
        UIImageView * stix = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[filenames objectAtIndex:type]]] autorelease];
        NSLog(@"Loading empty badge from filename %@\n", [filenames objectAtIndex:type]);
        return stix;
    }
    return nil;
}
-(int)getOppositeBadgeType:(int)type {
    if (type == BADGE_TYPE_FIRE)
        return BADGE_TYPE_ICE;
    else
        return BADGE_TYPE_FIRE;
}

+(NSMutableArray *)generateDefaultStix {
    NSMutableArray * stix = [[[NSMutableArray alloc] init] autorelease];
    for (int i=0; i<BADGE_TYPE_MAX; i++) {
        [stix insertObject:[NSNumber numberWithInt:20 ] atIndex:i];
    }
    return stix;
}

+(int)getOutlineOffsetX:(int)type {

    //const int xoffset[BADGE_TYPE_MAX] = {-5, -5, -2, -5};
    return -5; //xoffset[type];
}
+(int)getOutlineOffsetY:(int)type {
    
    //const int yoffset[BADGE_TYPE_MAX] = {10, 10, 2, 10};
    return 10; //yoffset[type];
}
- (void)dealloc {
	[super dealloc];
}

@end
