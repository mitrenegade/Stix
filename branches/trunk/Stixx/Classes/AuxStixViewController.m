//
//  AuxStixViewController.m
//  Stixx
//
//  Created by Bobby Ren on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AuxStixViewController.h"

@implementation AuxStixViewController

@synthesize imageView;
@synthesize commentField;
@synthesize buttonOK;
@synthesize buttonCancel;
@synthesize delegate;
@synthesize badgeFrame;
@synthesize stixStringID;
@synthesize stix;
@synthesize buttonInstructions;
@synthesize stixView;

-(id)init
{
	// call superclass's initializer
	self = [super initWithNibName:@"AuxStixViewController" bundle:nil];
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initStixView:(Tag*)tag {
    UIImage * imageData = tag.image;
    NSString * myStixStringID = tag.stixStringID;
    int count = tag.badgeCount;
    float centerX = tag.badge_x;
    float centerY = tag.badge_y;
    
    NSLog(@"AuxStix: Creating stix view of size %f %f, with badge at %f %f", imageData.size.width, imageData.size.height, centerX, centerY);

    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView initializeWithImage:imageData andStix:myStixStringID withCount:count atLocationX:centerX andLocationY:centerY];
    [stixView populateWithAuxStix:tag.auxStixStringIDs atLocations:tag.auxLocations];
    [self.view addSubview:stixView];
    [stixView setInteractionAllowed:NO]; // no dragging of stix already in stixView

}

-(void)addNewAuxStix:(UIImageView *)newStix ofType:(NSString *)newStixStringID atLocation:(CGPoint)location {
    badgeFrame = newStix.frame;
    // save frame of badge relative to cropped image
    // stix frame coming in relative to a full size 300x275 view at origin 0,0
	float imageScale =  stixView.frame.size.width / 300;
    NSLog(@"AuxStix: badge of frame %f %f %f %f at location %f %f in view %f %f changed to frame %f %f %f %f at location %f %f in view %f %f\n", badgeFrame.origin.x, badgeFrame.origin.y, badgeFrame.size.width, badgeFrame.size.height, location.x, location.y, 300.0, 300.0, badgeFrame.origin.x * imageScale, badgeFrame.origin.y * imageScale, badgeFrame.size.width * imageScale, badgeFrame.size.height * imageScale, location.x * imageScale, location.y * imageScale, stixView.frame.size.width, stixView.frame.size.height);
    location.x *= imageScale; // scale to fit in stixView
    location.y *= imageScale;
    location.x += stixView.frame.origin.x; // move center into stixView in this view's reference
    location.y += stixView.frame.origin.y;
    badgeFrame.size.width *= imageScale;
    badgeFrame.size.height *= imageScale;
    
    // location is already the point inside stixFrame
    stixStringID = newStixStringID;
    stix = [BadgeView getBadgeWithStixStringID:stixStringID];
    [stix setFrame:badgeFrame];
    [stix setCenter:location];
    [self.view addSubview:stix];
}

/*** dragging and resizing badge ***/

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self.view];
	drag = 0;
    
    [self closeInstructions:nil];
    
    if (CGRectContainsPoint(stix.frame, location))
    {
        drag = 1;
    }
    
    // point where finger clicked badge
    offset_x = (location.x - stix.center.x);
    offset_y = (location.y - stix.center.y);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (drag == 1)
	{
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:self.view];
		// update frame of dragged badge, also scale
		//float scale = 1; // do not change scale while dragging
		if (!drag)
			return;
        
		float centerX = location.x - offset_x;
		float centerY = location.y - offset_y;
        stix.center = CGPointMake(centerX, centerY);
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (drag == 1)
	{
        drag = 0;
	}
}

-(IBAction)buttonOKPressed:(id)sender
{
    // scale stix frame back
	float imageScale =  300 / imageView.frame.size.width;
    
	CGRect stixFrameScaled = stix.frame;
    float centerX = stix.center.x - stixView.frame.origin.x;
    float centerY = stix.center.y - stixView.frame.origin.y;
    centerX *= imageScale;
    centerY *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    //stix.frame = badgeFrame;
    //[stix setCenter:CGPointMake(centerx, centery)];
    NSLog(@"AuxStix: set aux stix of size %f %f at %f %f in image size %f %f\n", stixFrameScaled.size.width, stixFrameScaled.size.height, centerX, centerY, imageView.frame.size.width * imageScale, imageView.frame.size.height * imageScale);
    [delegate didAddAuxStixWithStixStringID:stixStringID atLocation:CGPointMake(centerX, centerY) andComment:[commentField text]];
}

-(IBAction)buttonCancelPressed:(id)sender
{
	//[self.delegate didAddDescriptor:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

-(IBAction)closeInstructions:(id)sender;
{
    [buttonInstructions setHidden:YES];
}

@end
