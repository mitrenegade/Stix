#import "TagViewController.h"

#define VIEWPORT_WIDTH_RADIANS .5
#define VIEWPORT_HEIGHT_RADIANS .7392

@implementation TagViewController

@synthesize delegate;
@synthesize badgeView;
@synthesize cameraController;
@synthesize arViewController;
@synthesize rectView;
@synthesize buttonInstructions;

- (id)init {
	
		// does not do anything - nib does not contain extra buttons etc
		[super initWithNibName:@"TagViewController" bundle:nil];
				
		// create tab bar item to become a tab view
		UITabBarItem *tbi = [self tabBarItem];
		
		// give it a label
		[tbi setTitle:@"Stix"];
		
		// add an image
		//UIImage * i = [UIImage imageNamed:@"tab_location.png"];
		//[tbi setImage:i];
    return self;
}

-(void)viewDidLoad {
	[super viewDidLoad];

	/****** init badge view ******/
	badgeView = [[BadgeView alloc] initWithFrame:self.view.frame];
    badgeView.delegate = self;
    [badgeView setUnderlay:buttonInstructions];
    [delegate didCreateBadgeView:badgeView];
    
    /****** init AR view ******/
    arViewController = [[ARViewController alloc] init];
	CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:42.369182 longitude:-71.080427];
	arViewController.scaleViewsBasedOnDistance = YES;
	arViewController.minimumScaleFactor = .5;
	arViewController.rotateViewsBasedOnPerspective = NO;
	arViewController.centerLocation = newCenter;
	[newCenter release];

	/***** create camera controller *****/
	NSLog(@"Initializing camera.");
	cameraController = [[BTLFullScreenCameraController alloc] init];
	[cameraController setOverlayController:self];
	
	// hierarchy of tagView overlays:
	// 1. self.view = overlayView = blank;
    // 1.5 overlayView.subView = apertureView - camera aperture (overlay.png)
	// 2. overlayView.subView = badgeController.view
	// 3. badgeController.subView = arViewController.view
    // 4. arViewController.view
	// 6. we don't want to set tabBar.subView because it goes to other views
	
    //overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    //UIImageView * apertureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay.png"]];
	[badgeView addSubview:arViewController.view];
    //[apertureView addSubview:badgeController.view];
	//[overlayView addSubview:apertureView];
	//self.view = overlayView;
    [self.view addSubview:badgeView];
    
}

// called by main delegate to add tabBarView to camera overlay
- (void)setCameraOverlayView:(UIView *)cameraOverlayView
{
    [cameraController setCameraOverlayView:cameraOverlayView];
}

- (void)viewDidAppear:(BOOL)animated {
#if !TARGET_IPHONE_SIMULATOR
/*    
    NSLog(@"RectView has frame: %f %f %f %f\n", rectView.frame.origin.x, rectView.frame.origin.y, rectView.frame.size.width, rectView.frame.size.height);
 */    
    CGRect viewRect = rectView.frame;
    viewRect.origin.y = viewRect.origin.y + STATUS_BAR_SHIFT;
    // hack: cameraController.ROI is used to crop the image, but for some reason croppedImage: doesn't work as we think. the width and height are actually values for max_x and max_y
    viewRect.size.width = viewRect.size.width + viewRect.origin.x;
    viewRect.size.height = viewRect.size.height + viewRect.origin.y;     [cameraController setROI:viewRect];
	[self presentModalViewController:self.cameraController animated:animated];
#endif
    [badgeView resetBadgeLocations];

	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{	
	[super viewWillDisappear:animated];
//#if !TARGET_IPHONE_SIMULATOR
//	[self.cameraController dismissModalViewControllerAnimated:YES];
//#endif
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[overlayView release];
	overlayView = nil;
    [rectView release];
    [buttonInstructions release];
    rectView = nil;
    buttonInstructions = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	
    [super dealloc];
}

// BadgeViewDelegate function
-(void)didDropStix:(UIImageView *)badge ofType:(int)type{
	// first, set the camera controller to have the badge as an additional UIImageView
	[[self cameraController] setAddedOverlay:badge];
	// take a picture
	[[self cameraController] takePicture];
    badgeFrame = badge.frame;
    // save frame of badge relative to cropped image
    badgeFrame.origin.x = badgeFrame.origin.x - cameraController.ROI.origin.x;
    badgeFrame.origin.y = badgeFrame.origin.y - cameraController.ROI.origin.y + STATUS_BAR_SHIFT;
    badgeType = type; // save type for later;
}

-(int)getStixCount:(int)stix_type {
    return [self.delegate getStixCount:stix_type];
}

-(void)didStartDrag {
    [self.buttonInstructions setHidden:YES];
}

- (void)cameraDidTakePicture:(id)sender {
	// called by BTLFullScreenCameraController
	// set a title
    [self.cameraController dismissModalViewControllerAnimated:NO]; // dismiss camera

	// prompt for label: use TagDescriptorController
	TagDescriptorController * descriptorController = [[TagDescriptorController alloc] init];
    
    [descriptorController setDelegate:self];
    [descriptorController setBadgeFrame:badgeFrame];
    [descriptorController setBadgeType:badgeType];
    [self.cameraController presentModalViewController:descriptorController animated:YES];

}

- (void)clearTags {
    [arViewController removeAllCoordinates];
}

/* TagDescriptorDelegate functions - newer implementation of tagging and commenting */
-(void)didAddDescriptor:(NSString*)descriptor andLocation:(NSString *)location
{
    [self.cameraController dismissModalViewControllerAnimated:YES];
    ARCoordinate * newCoord;
    NSString * desc;

    NSLog(@"Entered: '%@' for description and '%@' for location", descriptor, location);
	if ([descriptor length] > 0 && [location length] > 0)
	{
        desc = [NSString stringWithFormat:@"%@ @ %@", descriptor, location];
	}
    else if ([descriptor length] == 0 && [location length] > 0)
    {
        desc = location;
    }
    else if ([descriptor length] > 0 && [location length] == 0)
    {
        desc = descriptor;
    }
    else 
    {
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"MMM dd"]; //NSDateFormatterShortStyle];
        desc = [formatter stringFromDate:now];
    }
    newCoord = [arViewController createCoordinateWithLabel:desc];
    
    // check if user is logged in
    if ([delegate isLoggedIn] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello Anonymous User!"
                                                          message:@"You are not logged in. Please make sure you visit the profile page!"
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    // create Tag
    NSString * username = [[self.delegate getUsername] retain];
    Tag * tag = [[Tag alloc] init]; 
    [tag addUsername:username andComment:desc];
    UIImage * image = [[[ImageCache sharedImageCache] imageForKey:@"newImage"] retain];
    int x = badgeFrame.origin.x;
    int y = badgeFrame.origin.y;
    NSLog(@"Badge frame added at %d %d and image size at %f %f", x, y, image.size.width, image.size.height);
    [tag addImage:image];
    [tag addStixOfType:badgeType andCount:1 atLocationX:x andLocationY:y];
    [tag addARCoordinate:newCoord];
    [image release];
    [self.delegate addTag:tag];
    [tag release];
    
    [delegate decrementStixCount:badgeType forUser:username];
    [badgeView resetBadgeLocations];
    
    [username release];
    // dismiss descriptorController
    [self dismissModalViewControllerAnimated:YES];
    //[self setView:overlayView];
}


- (void)addCoordinateOfTag:(Tag*)tag {
    if (tag.coordinate)
        [arViewController addCoordinate:[tag coordinate]];
    // this error is handled right now by adding a default ARCoordinate
    else
        NSLog(@"Added invalid coordinate for tag: %i", [tag.tagID intValue]);
    //else
    //    [self.delegate failedToAddCoordinateOfTag:tag];
}

// ARViewDelegate
- (void)failedToAddCoordinate {
    
}

-(IBAction)closeInstructions:(id)sender;
{
    [buttonInstructions setHidden:YES];
}


#pragma mark -


@end
