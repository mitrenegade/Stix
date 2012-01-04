//
//  BadgeView.m
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "BadgeView.h"

static NSMutableDictionary * stixDescriptors = nil;
static NSMutableArray * stixStringIDs = nil;
static NSMutableDictionary * stixViews = nil;
static NSMutableDictionary * stixLikelihood = nil;
static NSMutableArray * pool = nil;
static int totalStixTypes = 0;

@implementation BadgeView

@synthesize delegate;
@synthesize underlay;
@synthesize showStixCounts;
@synthesize badgesLarge;
@synthesize shelf;
@synthesize selectedStixStringID;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
    if (totalStixTypes == 0)
        NSLog(@"***** ERROR! BadgeView Stix Types not yet initialized! *****");
  
    shelf = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf.png"]];
    shelf.frame = CGRectMake(0, 390, 320, 30);
    [self addSubview:shelf];
    
    showStixCounts = YES;
    
    // Populate all stix structures - used by BadgeView, CarouselView
    badges = [[NSMutableArray alloc] init];
    badgeLocations = [[NSMutableArray alloc] init];
    badgesLarge = [[NSMutableArray alloc] init];
    labels = [[NSMutableArray alloc] init];
    for (int i=0; i<totalStixTypes; i++)
    {
        NSString * stixStringID = [stixStringIDs objectAtIndex:i];
        UIImageView * badgeLarge = [BadgeView getLargeBadgeWithStixStringID:stixStringID];
        [badgesLarge addObject:badgeLarge];
        UIImageView * badge = [BadgeView getBadgeWithStixStringID:stixStringID];
        [badges addObject:badge];
        [badgeLocations addObject:[NSValue valueWithCGRect:badge.frame]];

        OutlineLabel * label = [[OutlineLabel alloc] initWithFrame:badge.frame];
        [label setCenter:CGPointMake(badge.center.x+[BadgeView getOutlineOffsetX:i], badge.center.y+[BadgeView getOutlineOffsetY:i])];
        [label setTextAttributesForBadgeType:i];
        [label drawTextInRect:CGRectMake(0,0, badge.frame.size.width, badge.frame.size.height)];
        [labels addObject:label];
        [label release];
    }
    
 	return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"BadgeView" owner:self options:nil];
    //[self addSubview:self];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self];//touch.view];
	drag = 0;
    
    if ([self.delegate respondsToSelector:@selector(didStartDrag)]) 
        [self.delegate performSelector:@selector(didStartDrag)];
	
	// find which icon is being dragged
	unsigned numEls = 2; // for badgeView, only use first two// [badges count];
	while (numEls--)
	{
		UIImageView * badge = [badges objectAtIndex:numEls];
		CGRect frame = badge.frame;
        if (CGRectContainsPoint(frame, location))
		{
			badgeTouched = badge;
			drag = 1;
			badgeSelect = numEls; // index into badgesLarge and badgeLocations arrays
            selectedStixStringID = [stixStringIDs objectAtIndex:numEls];
            [[labels objectAtIndex:numEls] removeFromSuperview];
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
		badgeTouchedLarge = [BadgeView getLargeBadgeWithStixStringID:selectedStixStringID]; 
        float centerX = badgeTouched.center.x; 
		float centerY = badgeTouched.center.y; 
        
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
    [super touchesBegan: touches withEvent: event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//[self touchesBegan:touches withEvent:event];
	if (drag == 1)
	{
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:self];

		//NSLog(@"Dragging to %f %f", location.x, location.y);

		// update frame of dragged badge, also scale
		if (badgeTouched == nil)
			return;
		float centerX = location.x - offset_from_center_X;
		float centerY = location.y - offset_from_center_Y;
        badgeTouched.center = CGPointMake(centerX, centerY);
	}
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (drag == 1)
	{
		if (badgeTouched != nil)
		{
			CGRect originalFrame = [[badgeLocations objectAtIndex:badgeSelect] CGRectValue];
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
            [self.delegate didDropStix:badgeTouched ofType:selectedStixStringID];
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
    for (int i=0; i<totalStixTypes; i++)
    {
        UIImageView * badge = [badges objectAtIndex:i];
        [badge removeFromSuperview];
    }
    int numStix = 2; // badgeView always only shows two stix
    for (int i=0; i<numStix; i++)
    {
        UIImageView * badge = [badges objectAtIndex:i];
        // for views that only show the action stix, just position for two stix
        int y = 375;
        
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
    drag = 0;
}

-(void)updateStixCounts {
    // Not used
    for (int i=0; i<2; i++) {
        int ct = [self.delegate getStixCount:[stixStringIDs objectAtIndex:i]];
        if (ct > -1)
        {
            OutlineLabel * label = [labels objectAtIndex:i];
            [label removeFromSuperview];
            [label setText:[NSString stringWithFormat:@"%d", ct]];
            [self addSubview:label];
        }
    }
}

+(NSString *) stixDescriptorForStixStringID:(NSString *)stixStringID {
    return [stixDescriptors objectForKey:stixStringID];
}

+(void)InitializeStixTypes:(NSArray*)stixStringIDsFromKumulos {
    if (stixStringIDs)
    {
        [stixStringIDs release];
        stixStringIDs = nil;
    }
    stixStringIDs = [[NSMutableArray alloc] initWithCapacity:[stixStringIDsFromKumulos count]];
    for (NSMutableDictionary * d in stixStringIDsFromKumulos) {
        NSString * stixStringID = [d valueForKey:@"stixStringID"];
        [stixStringIDs addObject:stixStringID];
    }
    totalStixTypes = [stixStringIDs count];
}

+(void)InitializeStixViews:(NSArray*)stixViewsFromKumulos {
    if (stixViews) {
        [stixViews release];
        stixViews = nil;
    }
    if (stixDescriptors) {
        [stixDescriptors release];
        stixDescriptors = nil;
    }
    if (stixLikelihood)
    {
        [stixLikelihood release];
        stixLikelihood = nil;
    }
    if (pool)
    {
        [pool release];
        pool = nil;
    }
    stixViews = [[NSMutableDictionary alloc] initWithCapacity:[stixViewsFromKumulos count]];
    stixDescriptors = [[NSMutableDictionary alloc] initWithCapacity:[stixViewsFromKumulos count]];
    stixLikelihood = [[NSMutableDictionary alloc] initWithCapacity:[stixViewsFromKumulos count]];
    for (NSMutableDictionary * d in stixViewsFromKumulos) {
        NSString * stixStringID = [d valueForKey:@"stixStringID"];
        NSString * descriptor = [d valueForKey:@"stixDescriptor"];
        NSNumber * likelihood = [d valueForKey:@"likelihood"];
        NSData * dataPNG = [d valueForKey:@"dataPNG"];
        UIImage * img = [[UIImage alloc] initWithData:dataPNG];
        UIImageView * stix = [[UIImageView alloc] initWithImage:img];
        [stixViews setObject:stix forKey:stixStringID];
        [stixDescriptors setObject:descriptor forKey:stixStringID];
        [stixLikelihood setObject:likelihood forKey:stixStringID];
        [img release];
        [stix release];
    }
}
+(int)totalStixTypes {
    return totalStixTypes;
}

+(NSString*) stringIDOfStix:(int)type {
    if (!stixStringIDs) {
        return nil;
    }
    return [stixStringIDs objectAtIndex:type];
}
+(NSArray*) stixStringIDs {
    return stixStringIDs;
}

+(UIImageView *) getBadgeWithStixStringID:(NSString*)stixStringID {
    // returns a half size image view
    UIImageView * stix = [BadgeView getLargeBadgeWithStixStringID:stixStringID];
    if (stix == nil)
        return nil;
    // create smaller size for actual badgeView
    stix.frame = CGRectMake(0, 0, stix.frame.size.width * .65, stix.frame.size.height*.65); // resize badges to "small size"
    return stix;
}

+(UIImageView *) getLargeBadgeWithStixStringID:(NSString*)stixStringID {
    // returns a half size image view
    //NSLog(@"Loading large badge with string ID %@\n", stixStringID);
    UIImageView * stix = [[UIImageView alloc] initWithImage:[[stixViews objectForKey:stixStringID] image]];
    return stix; //[stix autorelease];
}

+(NSString*)getStixStringIDAtIndex:(int)index {
    return [stixStringIDs objectAtIndex:index]; 
}

+(NSMutableDictionary *)generateDefaultStix {
    NSMutableDictionary * stixCounts = [[NSMutableDictionary alloc] initWithCapacity:[BadgeView totalStixTypes]];
    for (int i=0; i<2; i++)
        [stixCounts setObject:[NSNumber numberWithInt:-1] forKey:[stixStringIDs objectAtIndex:i]];
    for (int i=2; i<[BadgeView totalStixTypes]; i++)
        [stixCounts setObject:[NSNumber numberWithInt:0] forKey:[stixStringIDs objectAtIndex:i]];
    return stixCounts; //[stixCounts autorelease];
}

+(NSString*)getRandomStixStringID {
    if (pool == nil) {
        // accumulate all likelihoods
        pool = [[NSMutableArray alloc] init];
        for (int i=0; i<[self totalStixTypes]; i++) {
            NSString * stixStringID = [self getStixStringIDAtIndex:i];
            int likelihood = [[stixLikelihood objectForKey:stixStringID] intValue];
            for (int j=0; j<likelihood; j++) {
                [pool addObject:stixStringID];
            }
        }
    }
    
    int total = [pool count];
    NSInteger num = arc4random() % total;
    NSLog(@"Random stix string id: choosing from 0 to %d: result %d\n", total-1, num);
    return [pool objectAtIndex:num];
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
    
    [shelf release];
    shelf = nil;
    
    [badges release];
    badges = nil;
    [badgesLarge release];
    badgesLarge = nil;
    [badgeLocations release];
    badgeLocations = nil;
    [labels release];
    labels = nil;
}

@end
