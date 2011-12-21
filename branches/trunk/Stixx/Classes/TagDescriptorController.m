//
//  TagDescriptorController.m
//  ARKitDemo
//
//  Created by Administrator on 7/18/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "TagDescriptorController.h"

@implementation TagDescriptorController

@synthesize imageView;
@synthesize commentField;
@synthesize commentField2;
@synthesize locationField, locationButton;
@synthesize buttonOK;
@synthesize buttonCancel;
@synthesize delegate;
@synthesize badgeFrame, badgeType;
@synthesize stix;
@synthesize buttonInstructions;

-(id)init
{
	[super initWithNibName:@"TagDescriptorController" bundle:nil];
	return self;
}
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
        // Custom initialization.
//    }
//    return self;
//}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad]; 
    UIImage * tmp = [[ImageCache sharedImageCache] imageForKey:@"newImage"];
	[imageView setImage:tmp];
    NSLog(@"TagDescriptor: Setting imageView to image of dims %f %f with badge at %f %f", tmp.size.width, tmp.size.height, badgeFrame.origin.x, badgeFrame.origin.y); 

    stix = [[self populateWithBadge:badgeType withCount:1 atLocationX:badgeFrame.origin.x andLocationY:badgeFrame.origin.y] retain];    
    [imageView addSubview:stix];
    //[stix release];
    NSLog(@"TagDescriptor: imageView dims %f %f badge at %f %f", imageView.frame.size.width, imageView.frame.size.height, badgeFrame.origin.x, badgeFrame.origin.y);
    
    drag = 0;
    
    [commentField2 setHidden:YES]; // hide for now
    
//#if TARGET_IPHONE_SIMULATOR
    //[locationField addTarget:self action:@selector(locationTextBoxEntered:) forControlEvents:UIControlEventEditingDidBegin]; // added in xib
    locationController = [[LocationHeaderViewController alloc] init];
    [locationController setDelegate:self];
//#endif
}

-(UIImageView *)populateWithBadge:(int)type withCount:(int)count atLocationX:(int)x andLocationY:(int)y {
    float item_width = imageView.frame.size.width;
    float item_height = imageView.frame.size.height;
    
    UIImageView * newstix = [[BadgeView getBadgeOfType:type] retain];
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float originX = x;
    float originY = y;
    NSLog(@"Adding badge to %d %d in image of size %f %f", x, y, item_width, item_height);
    newstix.frame = CGRectMake(originX, originY, newstix.frame.size.width, newstix.frame.size.height);
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = CGSizeMake(300, 300);
	CGSize targetSize = CGSizeMake(item_width, item_height);
	
	float imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = newstix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    NSLog(@"Scaling badge of %f %f in image %f %f down to %f %f in image %f %f", newstix.frame.size.width, newstix.frame.size.height, 300.0, 300.0, stixFrameScaled.size.width, stixFrameScaled.size.height, item_width, item_height); 
    [newstix setFrame:stixFrameScaled];
    
    // change comment field prompt based on stix
    switch (type) {
        case BADGE_TYPE_FIRE:
            [commentField setPlaceholder:@"What's Hot Here?"];
            break;
        case BADGE_TYPE_ICE:
            [commentField setPlaceholder:@"What's Not Hot?"];
            break;
        case BADGE_TYPE_HEART:
            [commentField setPlaceholder:@"What Do You Love?"];
            break;
        case BADGE_TYPE_LEAF:
            [commentField setPlaceholder:@"What's Natural Here?"];
            break;
            
        default:
            break;
    }
    return [newstix autorelease];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[imageView release];
	imageView = nil;
}

- (void)dealloc {
    [super dealloc];
	
	[imageView release];
}

-(IBAction)buttonOKPressed:(id)sender
{
	[self.delegate didAddDescriptor:[commentField text] andComment:[commentField2 text] andLocation:[locationField text] andStixFrame:[stix frame]];
}

-(IBAction)buttonCancelPressed:(id)sender
{
	//[self.delegate didAddDescriptor:nil];
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)locationTextBoxEntered:(id)sender
{   
    [commentField resignFirstResponder];
    [commentField2 resignFirstResponder];
    [locationField resignFirstResponder];
    [self presentModalViewController:locationController animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

/*** LocationHeaderViewControllerDelegate ****/

-(void)didChooseLocation:(NSString *)location {
    NSLog(@"FourSquare locator returned %@\n", location);
    [locationField setText:location];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)didCancelLocation
{
    [self.locationField resignFirstResponder];
	//[self.delegate didAddDescriptor:nil];
}

/*** dragging and resizing badge ***/

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:imageView];
	drag = 0;
    
    [self closeInstructions:nil];
    
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
	//[self touchesBegan:touches withEvent:event];
	if (drag == 1)
	{
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:imageView];
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

-(IBAction)closeInstructions:(id)sender
{
    [buttonInstructions setHidden:YES];
}

@end

