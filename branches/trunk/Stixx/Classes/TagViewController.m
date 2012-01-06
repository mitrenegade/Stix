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
@synthesize overlayView;
@synthesize camera;
@synthesize descriptorIsOpen;
@synthesize descriptorController;
@synthesize needToShowCamera;
@synthesize aperture;
@synthesize cameraDeviceButton;
@synthesize flashModeButton;

- (id)init {
	
		// does not do anything - nib does not contain extra buttons etc
		self = [super initWithNibName:@"TagViewController" bundle:nil];
				
		// create tab bar item to become a tab view
		UITabBarItem *tbi = [self tabBarItem];
		
		// give it a label
		[tbi setTitle:@"Stix"];
		
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
    descriptorIsOpen = NO;
    needToShowCamera = YES;
    
	/***** create camera controller *****/
	NSLog(@"Initializing camera.");
#if 0
	cameraController = [[BTLFullScreenCameraController alloc] init];
	[cameraController setOverlayController:self];
#else
    camera = [[UIImagePickerController alloc] init];
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.showsCameraControls = NO;
    camera.navigationBarHidden = YES;
    camera.toolbarHidden = YES; // prevents bottom bar from being displayed
    camera.allowsEditing = NO;
    camera.wantsFullScreenLayout = NO;
    camera.delegate = self;
    camera.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    
#endif
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

-(void)loadView {
    // instead of calling [super loadView], which doesn’t account for a hidden status bar, create an unclipped view here
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGRect screenBounds = CGRectMake(0, 20, screenSize.width, screenSize.height);
    
    NoClipModalView *sView = [[NoClipModalView alloc] initWithFrame:screenBounds]; 
    
    self.view = sView; 
    buttonInstructions = [[UIButton alloc] initWithFrame:CGRectMake(19,200, 283, 37)];
    [buttonInstructions setFrame:CGRectMake(19,200, 283, 37)];
    [buttonInstructions setBackgroundImage:[UIImage imageNamed:@"instruction_box.png"] forState:UIControlStateNormal];
    [buttonInstructions setTitle:@"Drag Stix here to take a picture!" forState:UIControlStateNormal];
    [buttonInstructions addTarget:self action:@selector(closeInstructions:) forControlEvents:UIControlEventTouchUpInside];
    rectView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 90, 300, 275)];
    [rectView setFrame:CGRectMake(10, 90, 300, 275)];
    //[rectView setBackgroundColor:[UIColor redColor]];
    aperture = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay.png"]];
    [aperture setAlpha:0.8];
    [self.view addSubview:buttonInstructions];
    [self.view addSubview:rectView];
    [self.view addSubview:aperture];
    
    flashModeButton = [[UIButton alloc] initWithFrame:CGRectMake(20,45, 120, 37)];
    [flashModeButton setBackgroundColor:[UIColor grayColor]];
    [flashModeButton addTarget:self action:@selector(toggleFlashMode:) forControlEvents:UIControlEventTouchUpInside];
    cameraDeviceButton = [[UIButton alloc] initWithFrame:CGRectMake(180,45, 120, 37)];
    [cameraDeviceButton setBackgroundColor:[UIColor grayColor]];
    [cameraDeviceButton addTarget:self action:@selector(toggleCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cameraDeviceButton];
    [self.view addSubview:flashModeButton];
    [sView release];
    
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
    // to set the correct underlay:
    // if no underlay is set, the hittest order is carouselView->badgeView->self.view
    // but badgeView will incorrectly toggle a hit because it contains badgeFrames
    // so we make carouselView return its underlay to skip badgeView. If the underlay is
    // another subview in self.view's subview, it will then cause hittest to traverse
    // all of self.view's subviews after carouselView natually, thus enabling all other buttons
    // and touch interactions
    [carouselView setUnderlay:flashModeButton];
    [carouselView initCarouselWithFrame:CGRectMake(SHELF_STIX_X,SHELF_STIX_Y,320,SHELF_STIX_SIZE)];
    
    [carouselView addSubview:arViewController.view];
    [self.view addSubview:carouselView];
    [delegate didCreateBadgeView:carouselView];
}

-(void)reloadCarouselView {
    [[self carouselView] reloadAllStixWithFrame:CGRectMake(SHELF_STIX_X,SHELF_STIX_Y,320,SHELF_STIX_SIZE)];
    [[self carouselView] removeFromSuperview];
    [self.view addSubview:carouselView];
}

// called by main delegate to add tabBarView to camera overlay
- (void)setCameraOverlayView:(UIView *)cameraOverlayView
{
    [self setOverlayView:cameraOverlayView];
    @try {
#if 0
        [cameraController setCameraOverlayView:cameraOverlayView];
#else
        [camera setCameraOverlayView:cameraOverlayView];
#endif
    }
    @catch (NSException* exception) {
    }
}

- (void)viewDidAppear:(BOOL)animated {
#if !TARGET_IPHONE_SIMULATOR
/*    
    NSLog(@"RectView has frame: %f %f %f %f\n", rectView.frame.origin.x, rectView.frame.origin.y, rectView.frame.size.width, rectView.frame.size.height);
 */    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

    CGRect viewFrame = rectView.frame;
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    // hack: because status bar is hidden, our "origin.y" is -20
    viewFrame.origin.y = viewFrame.origin.y + statusFrame.size.height;
#if 0
    [cameraController setROI:viewFrame];
	[self presentModalViewController:self.cameraController animated:animated];
#else
    if (descriptorIsOpen == NO) {
        [self presentModalViewController:self.camera animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        needToShowCamera = NO;
    }
#endif
#endif
    [carouselView resetBadgeLocations];
    //[badgeView resetBadgeLocations];
    
    [self updateCameraControlButtons];
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
#if 0
	// first, set the camera controller to have the badge as an additional UIImageView
	[[self cameraController] setAddedOverlay:badge];
	// take a picture
	[[self cameraController] takePicture];
#else
    [[self camera] takePicture];
#endif
    badgeFrame = badge.frame;
    // save frame of badge relative to cropped image
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
#if 0
    badgeFrame.origin.x = badgeFrame.origin.x - cameraController.ROI.origin.x;
    badgeFrame.origin.y = badgeFrame.origin.y - cameraController.ROI.origin.y + statusFrame.size.height;
#else
    badgeFrame.origin.x = badgeFrame.origin.x - rectView.frame.origin.x;
    badgeFrame.origin.y = badgeFrame.origin.y - rectView.frame.origin.y + statusFrame.size.height;    
#endif
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
#if 0
    [self.cameraController dismissModalViewControllerAnimated:NO]; // dismiss camera
#else
    descriptorIsOpen = YES; // prevent camera from reanimating on viewDidAppear
    [self dismissModalViewControllerAnimated:NO];
    needToShowCamera = NO; // still not need to show camera
#endif
	// prompt for label: use TagDescriptorController
	descriptorController = [[TagDescriptorController alloc] init];
    
    [descriptorController setDelegate:self];
    [descriptorController setBadgeFrame:badgeFrame];
    [descriptorController setStixStringID:selectedStixStringID];
#if TARGET_IPHONE_SIMULATOR
    [self presentModalViewController:descriptorController animated:YES];
#else
#if 0
    [self.camera presentModalViewController:descriptorController animated:YES];
#else
    //[self.view addSubview:descriptorController.view];
    //[self.tabBarController presentModalViewController:descriptorController animated:NO];
    [self presentModalViewController:descriptorController animated:YES];
#endif
#endif
}

- (void)clearTags {
    [arViewController removeAllCoordinates];
}

-(void)didCancelAddDescriptor {
    [carouselView resetBadgeLocations];
    
    [self dismissModalViewControllerAnimated:YES];
    needToShowCamera = YES;
    descriptorIsOpen = NO;
    [self viewDidAppear:NO];    
}
/* TagDescriptorDelegate functions - newer implementation of tagging and commenting */
-(void)didAddDescriptor:(NSString*)descriptor andComment:(NSString*)comment andLocation:(NSString *)location andStixCenter:(CGPoint)center
{
#if 0
    [self.cameraController dismissModalViewControllerAnimated:YES];
#endif
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
    //[descriptorController.view removeFromSuperview];
    //[descriptorController release];
    //[self.tabBarController dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    needToShowCamera = YES;
    descriptorIsOpen = NO;
    [self viewDidAppear:NO];
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

/*** camera delegate ***/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage * originalPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage * editedPhoto = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage * newPhoto; 
    //newPhoto = [UIImage imageNamed:@"friend1.png"];
    if (editedPhoto)
    {
        // shouldn't go here
        newPhoto = editedPhoto;
    }
    else
    {
        newPhoto = originalPhoto;
    }
    
	UIImage *baseImage = newPhoto;//[info objectForKey:UIImagePickerControllerOriginalImage];
	if (baseImage == nil) return;
	
	// save composite
    // raw images taken by this camera (with the status bar gone but the nav bar present are 1936x2592 (widthxheight) pix
    // that means the actual image is 320x428.42 on the iphone
    
    // screenContext is the actual size in pixels shown on screen, ie stix pixels are scaled 1x1 to the captured image
    CGSize screenContext = CGSizeMake(320, 2592*320/1936.0);
	
    // scale to convert base image from 1936x2592 to 320x428 - iphone size
	float baseScale =  screenContext.width / baseImage.size.width;
    
	CGRect scaledFrameImage = CGRectMake(0, 0, baseImage.size.width * baseScale, baseImage.size.height * baseScale);
    
	UIGraphicsBeginImageContext(screenContext);	
	[baseImage drawInRect:scaledFrameImage];	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
    
    UIImage * cropped = [result croppedImage:[self.rectView frame]];
    // save edited image to photo album
    UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil); // write to photo album
    
	// hack: use the image cache in the easy way - just cache one image each time
	if ([[ImageCache sharedImageCache] imageForKey:@"newImage"])
		[[ImageCache sharedImageCache] deleteImageForKey:@"newImage"];
	[[ImageCache sharedImageCache] setImage:cropped forKey:@"newImage"];
    
	if ([self respondsToSelector:@selector(cameraDidTakePicture:)]) {
		[self performSelector:@selector(cameraDidTakePicture:) withObject:self];
	}
	
}
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary*)info {
	NSLog(@"Did finish saving with error!");
}

- (void)writeImageToDocuments:(UIImage*)image {
	NSData *png = UIImagePNGRepresentation(image);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSError *error = nil;
	[png writeToFile:[documentsDirectory stringByAppendingPathComponent:@"image.png"] options:NSAtomicWrite error:&error];
}

-(void)updateCameraControlButtons {
    switch (camera.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeAuto:
            [flashModeButton setTitle:@"Auto Flash" forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            [flashModeButton setTitle:@"Flash On" forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOff:
            [flashModeButton setTitle:@"Flash Off" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    switch (camera.cameraDevice) {
        case UIImagePickerControllerCameraDeviceFront:
            [cameraDeviceButton setTitle:@"Switch to Rear" forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraDeviceRear:
            [cameraDeviceButton setTitle:@"Switch to Front" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

-(IBAction)toggleFlashMode:(id)sender {
    camera.cameraFlashMode++;
    if (camera.cameraFlashMode == 2)
        camera.cameraFlashMode = -1;
    [self updateCameraControlButtons];
}

-(IBAction)toggleCameraDevice:(id)sender {
    if (camera.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        camera.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    else
        camera.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self updateCameraControlButtons];
}

#pragma mark -


@end
