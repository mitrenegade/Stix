#import "TagViewController.h"

#define VIEWPORT_WIDTH_RADIANS .5
#define VIEWPORT_HEIGHT_RADIANS .7392

@implementation TagViewController

@synthesize delegate;
@synthesize badgeView;
@synthesize cameraController;
@synthesize arViewController;
@synthesize rectView;

- (id)init {
	
		// does not do anything - nib does not contain extra buttons etc
		[super initWithNibName:@"TagViewController" bundle:nil];
				
		// create tab bar item to become a tab view
		UITabBarItem *tbi = [self tabBarItem];
		
		// give it a label
		[tbi setTitle:@"Stix"];
		
		// add an image
		UIImage * i = [UIImage imageNamed:@"tab_location.png"];
		[tbi setImage:i];
		
	/****** init badge view ******/
	badgeView = [[BadgeView alloc] initWithFrame:self.view.frame];
    badgeView.delegate = self;
    
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
    
	return self;
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
    [cameraController setROI:rectView.frame];
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

-(void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[overlayView release];
	overlayView = nil;
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
-(void)addTag:(UIImageView *)badge{
	// first, set the camera controller to have the badge as an additional UIImageView
	[[self cameraController] setAddedOverlay:badge];
	// take a picture
	[[self cameraController] takePicture];
    badgeFrame = badge.frame;
}

- (void)cameraDidTakePicture:(id)sender {
	// called by BTLFullScreenCameraController
	// set a title
    [self.cameraController dismissModalViewControllerAnimated:NO]; // dismiss camera

	// prompt for label: use TagDescriptorController
	TagDescriptorController * descriptorController = [[TagDescriptorController alloc] init];
    
    [descriptorController setDelegate:self];
    [self.cameraController presentModalViewController:descriptorController animated:YES];

}

- (void)clearTags {
    [arViewController removeAllCoordinates];
}

/* TagDescriptorDelegate functions - newer implementation of tagging and commenting */
-(void)didAddDescriptor:(NSString*)descriptor
{
    ARCoordinate * newCoord;
	if (descriptor != nil)
	{
		NSLog(@"Entered: %@ for label text", descriptor);
		
        [self.cameraController dismissModalViewControllerAnimated:YES];
		newCoord = [arViewController createCoordinateWithLabel:descriptor];
	}
    else
    {
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"%A, %B %d, %Y"];
        NSString *theString = [formatter stringFromDate:now];
        [self.cameraController dismissModalViewControllerAnimated:YES];
        newCoord = [arViewController createCoordinateWithLabel:theString];
    }
    
    // create Tag
    NSString * username = [[self.delegate getCurrentUsername] retain];
    Tag * tag = [[Tag alloc] init]; 
    [tag addUsername:username andComment:descriptor];
    UIImage * image = [[[ImageCache sharedImageCache] imageForKey:@"newImage"] retain];
    int x = badgeFrame.origin.x;
    int y = badgeFrame.origin.y;
	[tag addImage:image atLocationX:x andLocationY:y];
    [tag addARCoordinate:newCoord];
    [image release];
    [self.delegate addTag:tag];
    [tag release];
    [username release];
    
	[badgeView resetBadgeLocations];
	
	// dismiss descriptorController
    [self dismissModalViewControllerAnimated:YES];
	//[self setView:overlayView];
}

- (Tag*)createTagWithName:(NSString*)name andComment:(NSString*)comment andImage:(UIImage*)image andBadge_X:(int)badge_x andBadge_Y:(int)badge_y andCoordinate:(ARCoordinate*)coordinate
{
    // simply allocates and creates a tag from given items
    Tag * tag = [[Tag alloc] init]; 
    [tag addUsername:name andComment:comment];
	[tag addImage:image atLocationX:badge_x andLocationY:badge_y];
    [tag addARCoordinate:coordinate];
    [tag autorelease];
    return tag;
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

#pragma mark -


@end
