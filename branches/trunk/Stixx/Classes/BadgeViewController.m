//
//  BadgeViewController.m
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "BadgeViewController.h"

@implementation BadgeViewController

@synthesize delegate;
@synthesize underlay;

-(id)init
{
	// call superclass's initializer
	[super initWithNibName:@"BadgeViewController" bundle:nil];
	return self;
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
	CGPoint location = [touch locationInView:self.view];//touch.view];
	drag = 0;
	
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
		NSLog(@"Badge %d: left right top bottom { %d %d %d %d} touch: %f %f", numEls, left, right, top, bottom, location.x, location.y);
		if (location.x > left && location.x < right && 
				location.y > top && location.y < bottom)
		{
			badgeTouched = badge;
			drag = 1;
			badgeSelect = numEls;
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
		
		NSLog(@"Dragging badge %d", badgeSelect);
		
	}
	//fire.center = location;
	NSLog(@"Location: %f %f", location.x, location.y);
    [super touchesBegan: touches withEvent: event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//[self touchesBegan:touches withEvent:event];
	if (drag == 1)
	{
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:self.view];//touch.view];

		NSLog(@"Dragging to %f %f", location.x, location.y);

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
			
			NSLog(@"badge released");
			
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
			if ([self.delegate respondsToSelector:@selector(addTag:)]) {
				[self.delegate performSelector:@selector(addTag:) withObject:badgeTouched];
				
			}	
		}
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // badgeView should only respond to touch events if we are touching the badges. otherwise,
    // foward the event to the underlay of badgeController, which is a sibling/same level view controller
    // that is also a subview of badgeController's superview
    //
    // for example:
    // badgeViewController
    //   ^                  scrollView
    //   |                      ^
    //   |                      |
    //    ---- feedView --------
    // this specifically makes badgeViewController call hitTest on scrollView; scrollView must be set
    // as an underlay of badgeController by feedView when the subviews are laid out
    
    UIView * result;
    if (self.underlay)
        result = [self.underlay hitTest:point withEvent:event];
    else 
        result = [self.view.superview hitTest:point withEvent:event];
    
	unsigned numEls = [badges count];
	while (numEls--)
	{
		UIImageView * badge = [badges objectAtIndex:numEls];        
        CGPoint buttonPoint = [badge convertPoint:point fromView:self.view];
        if ([badge pointInside:buttonPoint withEvent:event])
            return self.view; // if touch event is on a badge, then have badgeViewController process it
    }
    return result;
}

/*
 // Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically.
 - (void)loadView {
 }
 */

 // Implement viewDidLoad to do additional setup after loading the view.
 - (void)viewDidLoad {
	 [super viewDidLoad];		

	 badges = [[NSMutableArray alloc] init];//initWithObjects:badgeFire, badgeComment, nil];
	 [badges addObject:badgeFire];
	 [badges addObject:badgeIce];
	 //[badges addObject:badgeComment];
	 
	 badgeLocations = [[NSMutableArray alloc] init];
	 badgesLarge = [[NSMutableArray alloc] init];
	 badgesShadow = [[NSMutableArray alloc] init];
	 
	 UIImageView * fireLarge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fire_big.png"]];
	 UIImageView * iceLarge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ice_big.png"]];
	 UIImageView * fireShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fire_shadow.png"]];
	 UIImageView * iceShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ice_shadow.png"]];

	 [badgesLarge addObject:fireLarge];
	 [badgesLarge addObject:iceLarge];
	 [badgesShadow addObject:fireShadow];
	 [badgesShadow addObject:iceShadow];
     
     [fireLarge release];
     [iceLarge release];
     [fireShadow release];
     [iceShadow release];
	 
	 unsigned numEls = [badges count];
	 while (numEls--)
	 {
		 UIImageView * badge = [badges objectAtIndex:numEls];
		 //badge.frame = CGRectMake(BADGE_X_START + (BADGE_FRAME_WIDTH + BADGE_X_BORDER) * numEls, BADGE_Y_START, BADGE_FRAME_WIDTH, BADGE_FRAME_HEIGHT);
//		 [badgeLocations insertObject:[NSValue valueWithCGRect:badge.frame] atIndex:numEls+1];
		 [badgeLocations insertObject:[NSValue valueWithCGRect:badge.frame] atIndex:0];
	 }
 }

-(void)viewDidUnload {
	[self resetBadgeLocations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

-(void)resetBadgeLocations {
	
	unsigned numEls = [badges count];
	while (numEls--)
	{
		UIImageView * badge = [badges objectAtIndex:numEls];
		badge.frame = [[badgeLocations objectAtIndex:numEls] CGRectValue];
	}
    drag = 0;
}

- (void)dealloc {
	[super dealloc];
}

@end
