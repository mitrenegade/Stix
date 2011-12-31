#import "TagViewController.h"

#define VIEWPORT_WIDTH_RADIANS .5
#define VIEWPORT_HEIGHT_RADIANS .7392

@implementation TagViewController

@synthesize delegate;
@synthesize carouselView;
@synthesize cameraController;
@synthesize arViewController;
@synthesize rectView;
@synthesize buttonInstructions;
@synthesize badgeView;

- (id)init {
	
		// does not do anything - nib does not contain extra buttons etc
		[super initWithNibName:@"TagViewController" bundle:nil];
				
		// create tab bar item to become a tab view
		UITabBarItem *tbi = [self tabBarItem];
		
		// give it a label
		[tbi setTitle:@"Stix"];
		
		// add an image
//		UIImage * i = [UIImage imageNamed:@"tab_location.png"];
//		[tbi setImage:i];
//    return self;
//}

//-(void)viewDidLoad {
//	[super viewDidLoad];
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
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    /****** init badge view ******/
    [self createCarouselView];
#if 0
    badgeView = [[BadgeView alloc] initWithFrame:self.view.frame];
    badgeView.delegate = self;
    [badgeView setUnderlay:buttonInstructions];
    [badgeView setShowStixCounts:NO]; // do not show or change stix counts
    [delegate didCreateBadgeView:badgeView];
	[badgeView addSubview:arViewController.view];
    [self.view addSubview:badgeView];
#endif
}

-(void)createCarouselView {
    if (carouselView != nil && [carouselView isKindOfClass:[CarouselView class]]) {
        [carouselView clearAllViews];
        [carouselView release];
    }
    carouselView = [[CarouselView alloc] initWithFrame:self.view.frame];
    carouselView.delegate = self;
    [carouselView setUnderlay:buttonInstructions];
    [carouselView initCarouselWithFrame:CGRectMake(0,320,320,90)];
    
    [carouselView addSubview:arViewController.view];
    [self.view addSubview:carouselView];
    [delegate didCreateBadgeView:carouselView];
}

-(void)reloadCarouselView {
    [[self carouselView] reloadAllStixWithFrame:CGRectMake(0,320,320,90)];
    [[self carouselView] removeFromSuperview];
    [self.view addSubview:carouselView];
}

// called by main delegate to add tabBarView to camera overlay
- (void)setCameraOverlayView:(UIView *)cameraOverlayView
{
    @try {
        [cameraController setCameraOverlayView:cameraOverlayView];
    }
    @catch (NSException* exception) {
    }
}

- (void)viewDidAppear:(BOOL)animated {
#if !TARGET_IPHONE_SIMULATOR
/*    
    NSLog(@"RectView has frame: %f %f %f %f\n", rectView.frame.origin.x, rectView.frame.origin.y, rectView.frame.size.width, rectView.frame.size.height);
 */    
    CGRect viewFrame = rectView.frame;
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    // hack: because status bar is hidden, our "origin.y" is -20
    viewFrame.origin.y = viewFrame.origin.y + statusFrame.size.height;
    [cameraController setROI:viewFrame];
	[self presentModalViewController:self.cameraController animated:animated];
#endif
    [carouselView resetBadgeLocations];
    
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
    rectView = nil;
    //[buttonInstructions release];
    //buttonInstructions = nil;
    
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
-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID{
	// first, set the camera controller to have the badge as an additional UIImageView
	[[self cameraController] setAddedOverlay:badge];
	// take a picture
	[[self cameraController] takePicture];
    badgeFrame = badge.frame;
    // save frame of badge relative to cropped image
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    badgeFrame.origin.x = badgeFrame.origin.x - cameraController.ROI.origin.x;
    badgeFrame.origin.y = badgeFrame.origin.y - cameraController.ROI.origin.y + statusFrame.size.height;
    selectedStixStringID = stixStringID;
}

-(int)getStixCount:(NSString*)stixStringID {
    return [self.delegate getStixCount:stixStringID];
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
    [descriptorController setStixStringID:selectedStixStringID];
#if TARGET_IPHONE_SIMULATOR
    [self presentModalViewController:descriptorController animated:YES];
#else
    [self.cameraController presentModalViewController:descriptorController animated:YES];
#endif
}

- (void)clearTags {
    [arViewController removeAllCoordinates];
}

/* TagDescriptorDelegate functions - newer implementation of tagging and commenting */
-(void)didAddDescriptor:(NSString*)descriptor andComment:(NSString*)comment andLocation:(NSString *)location andStixCenter:(CGPoint)center
{
    [self.cameraController dismissModalViewControllerAnimated:YES];
    ARCoordinate * newCoord;
    NSString * desc = descriptor;
    NSString * com = comment;
    NSString * loc = location;

    NSLog(@"Entered: '%@' for description, '%@' for comment, and '%@' for location", descriptor, comment, location);
	if ([descriptor length] > 0)
	{
        //desc = [NSString stringWithFormat:@"%@ @ %@", descriptor, location];
        desc = descriptor;
	}
    else if ([descriptor length] == 0 && [comment length] > 0)
    {
        desc = comment;
    }
    else if ([descriptor length] == 0 && [comment length] == 0)
    {
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"MMM dd"]; //NSDateFormatterShortStyle];
        desc = [formatter stringFromDate:now];
        com = @"";
    }
    newCoord = [arViewController createCoordinateWithLabel:desc];
    
    // check if user is logged in
#if 1
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
#endif
    // create Tag
    NSString * username = [self.delegate getUsername];
    if ([delegate isLoggedIn] == NO)
    {
        username = @"anonymous";
    }
    Tag * tag = [[Tag alloc] init]; 
    [tag addUsername:username andDescriptor:desc andComment:com andLocationString:loc];
    UIImage * image = [[[ImageCache sharedImageCache] imageForKey:@"newImage"] retain];
    if ([delegate isLoggedIn] == NO)
    {
        [image release];
        image = [[UIImage imageNamed:@"graphic_nouser.png"] retain];
    }
    int x = center.x;
    int y = center.y;
    NSLog(@"TagViewController: Badge frame added at %d %d and image size at %f %f", x, y, image.size.width, image.size.height);
    [tag addImage:image];
    [tag addMainStixOfType:selectedStixStringID andCount:1 atLocationX:x andLocationY:y];
    [tag addARCoordinate:newCoord];
    // add empty aux
    tag.auxStixStringIDs = [[NSMutableArray alloc] init];
    tag.auxLocations = [[NSMutableArray alloc] init];
    [image release];
    [self.delegate tagViewDidAddTag:tag];
    [tag release];
    
    [carouselView resetBadgeLocations];
    
    //[username release];
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
