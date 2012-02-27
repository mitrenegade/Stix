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
//@synthesize overlayView;
@synthesize camera;
@synthesize descriptorIsOpen;
@synthesize descriptorController;
@synthesize needToShowCamera;
@synthesize aperture;
@synthesize cameraDeviceButton;
@synthesize flashModeButton;
@synthesize buttonClose;
@synthesize buttonZoomIn;
@synthesize buttonZoomOut;

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
    camera = [[UIImagePickerController alloc] init];
    camera.delegate = self;
    camera.navigationBarHidden = YES;
    camera.toolbarHidden = YES; // prevents bottom bar from being displayed
    camera.allowsEditing = NO;
    camera.wantsFullScreenLayout = NO;
#if !TARGET_IPHONE_SIMULATOR
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.showsCameraControls = NO;
    camera.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;    
#else
    camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
#if 1
    [super loadView];
#else
    // instead of calling [super loadView], which doesn’t account for a hidden status bar, create an unclipped view here
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGRect screenBounds = CGRectMake(0, 20, screenSize.width, screenSize.height);
    
    NoClipModalView *sView = [[NoClipModalView alloc] initWithFrame:screenBounds]; 
    
    self.view = sView; 
    int shift = 20;
    rectView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 74+shift, 300, 275)];
    //[rectView setBackgroundColor:[UIColor redColor]];
    aperture = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay.png"]];
    [aperture setFrame:CGRectMake(0, shift, 320, 480)];
    [self.view addSubview:buttonInstructions];
    [self.view addSubview:rectView];
    [self.view addSubview:aperture];
    
    flashModeButton = [[UIButton alloc] initWithFrame:CGRectMake(90, 3+shift, 60, 60)];
    [flashModeButton addTarget:self action:@selector(toggleFlashMode:) forControlEvents:UIControlEventTouchUpInside];
    [flashModeButton setBackgroundColor:[UIColor clearColor]];

    cameraDeviceButton = [[UIButton alloc] initWithFrame:CGRectMake(170,3+shift, 60, 60)];
    [cameraDeviceButton addTarget:self action:@selector(toggleCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    [cameraDeviceButton setImage:[UIImage imageNamed:@"switch_camera.png"] forState:UIControlStateNormal];
    [cameraDeviceButton setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:cameraDeviceButton];
    [self.view addSubview:flashModeButton];
/*
    buttonFeedback = [[UIButton alloc] init];
    [buttonFeedback setFrame:CGRectMake(240,13+shift, 80, 40)];
    [buttonFeedback setImage:[UIImage imageNamed:@"nav_feedback.png"] forState:UIControlStateNormal];
    [buttonFeedback addTarget:self action:@selector(feedbackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonFeedback];
*/    
    [sView release];
#endif
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
//    [carouselView setUnderlay:flashModeButton];
    [carouselView initCarouselWithFrame:CGRectMake(SHELF_STIX_X,SHELF_STIX_Y+60,320,SHELF_STIX_SIZE)];
    //[carouselView toggleHideShelf:YES];
    [carouselView setAllowTap:YES];
    [carouselView setTapDefaultOffset:CGPointMake(carouselView.frame.origin.x - self.aperture.center.x, carouselView.frame.origin.y - self.aperture.center.y)];
    
    [carouselView addSubview:arViewController.view];
//    [self.view insertSubview:carouselView belowSubview:buttonClose];
    [self.view insertSubview:carouselView belowSubview:camera.view];
//    [self.view addSubview:carouselView];
//    [self.view insertSubview:carouselView atIndex:[[self.view subviews] count]];
//    [self.view insertSubview:carouselView atIndex:0];
    [delegate didCreateBadgeView:carouselView];
}

-(void)reloadCarouselView {
    // hack: if carouselView is not scrolling, it is being eclipsed by the tabbar
    [[self carouselView] reloadAllStixWithFrame:CGRectMake(SHELF_STIX_X,SHELF_STIX_Y+60,320,SHELF_STIX_SIZE)];
    // HACK: make sure carouselView doesn't prevent other buttons from being touched
    // this is different because of the weird camera layer that doesn't exist in others (feedView, exploreView)
    [[self carouselView] removeFromSuperview];    
    [self.buttonClose removeFromSuperview];
    [self.flashModeButton removeFromSuperview];
    [self.cameraDeviceButton removeFromSuperview];
    [self.buttonZoomIn removeFromSuperview];
    [self.buttonZoomOut removeFromSuperview];
    [self.view addSubview:carouselView];
    [self.view addSubview:buttonClose];
    [self.view addSubview:flashModeButton];
    [self.view addSubview:cameraDeviceButton];
    [self.view addSubview:buttonZoomIn];
    [self.view addSubview:buttonZoomOut];
}

// called by main delegate to add tabBarView to camera overlay
- (void)setCameraOverlayView:(UIView *)cameraOverlayView
{
//    [self setOverlayView:cameraOverlayView];
    @try {
#if !TARGET_IPHONE_SIMULATOR
        [camera setCameraOverlayView:cameraOverlayView];
#endif
    }
    @catch (NSException* exception) {
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [buttonZoomIn setHidden:YES];
    [buttonZoomOut setHidden:YES];
/*    
    NSLog(@"RectView has frame: %f %f %f %f\n", rectView.frame.origin.x, rectView.frame.origin.y, rectView.frame.size.width, rectView.frame.size.height);
 */    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

    //CGRect viewFrame = rectView.frame;
    //CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    // hack: because status bar is hidden, our "origin.y" is -20
    //viewFrame.origin.y = viewFrame.origin.y + statusFrame.size.height;
#if !TARGET_IPHONE_SIMULATOR
    if (descriptorIsOpen == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        needToShowCamera = NO;
    }
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
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	//[overlayView release];
	//overlayView = nil;
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
-(void)didTapStix:(UIImageView *)badge ofType:(NSString *)stixStringID {
    // remove from scrollView and onto carouselView
    [badge setCenter:rectView.center];
    CGRect frame = badge.frame;
    [self.carouselView addSubview:badge];
    [self didDropStix:badge ofType:stixStringID];
}
-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID{
    [[self camera] takePicture];
    //[badge removeFromSuperview];
    badgeFrame = badge.frame;
    // save frame of badge relative to cropped image
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    badgeFrame.origin.x = badgeFrame.origin.x - rectView.frame.origin.x;
    badgeFrame.origin.y = badgeFrame.origin.y - rectView.frame.origin.y;// + statusFrame.size.height;    
    selectedStixStringID = stixStringID;
}

-(int)getStixCount:(NSString*)stixStringID {
    return [self.delegate getStixCount:stixStringID];
}

-(int)getStixOrder:(NSString*)stixStringID;
{
    return [self.delegate getStixOrder:stixStringID];
}

-(void)didStartDrag {
    [self.buttonInstructions setHidden:YES];
}

- (void)cameraDidTakePicture:(id)sender {
	// called by BTLFullScreenCameraController
	// set a title
    descriptorIsOpen = YES; // prevent camera from reanimating on viewDidAppear
    needToShowCamera = NO; // still not need to show camera
	// prompt for label: use TagDescriptorController
	descriptorController = [[TagDescriptorController alloc] init];
    
    [descriptorController setDelegate:self];
    [descriptorController setBadgeFrame:badgeFrame];
    [descriptorController setStixStringID:selectedStixStringID];
#if !TARGET_IPHONE_SIMULATOR
    // hack a way to display view over camera; formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [descriptorController.view setFrame:frameShifted];
    [self.camera setCameraOverlayView:descriptorController.view];
#endif
}

- (void)clearTags {
    [arViewController removeAllCoordinates];
}

-(void)didCancelAddDescriptor {
    [carouselView resetBadgeLocations];
    
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    //[self.camera dismissModalViewControllerAnimated:YES];
    [self.camera setCameraOverlayView:self.view];
    needToShowCamera = YES;
    descriptorIsOpen = NO;
    [self viewDidAppear:NO];    
}

-(void)didAddDescriptor:(NSString*)descriptor andComment:(NSString*)comment andLocation:(NSString *)location andStixCenter:(CGPoint)center /*andScale:(float)stixScale andRotation:(float)stixRotation */andTransform:(CGAffineTransform)transform
{
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
        /*
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"MMM dd"]; //NSDateFormatterShortStyle];
        desc = [formatter stringFromDate:now];
        com = @"";
         */
        desc = @"";
        com = @"";
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
    NSLog(@"TagViewController: Badge frame added at %f %f and image size at %f %f", center.x, center.y, image.size.width, image.size.height);
    [tag addImage:image];
    [tag addARCoordinate:newCoord];
    [tag addStix:selectedStixStringID withLocation:center /*withScale:stixScale withRotation:stixRotation*/ withTransform:transform withPeelable:NO];
    // backwards compatibility
    [tag setAuxScales:[[[NSMutableArray alloc] initWithCapacity:[tag.auxStixStringIDs count]] autorelease]];
    [tag setAuxRotations:[[[NSMutableArray alloc] initWithCapacity:[tag.auxStixStringIDs count]] autorelease]];
    for (int i=0; i<[tag.auxStixStringIDs count]; i++) {
        [tag.auxScales addObject:[NSNumber numberWithFloat:1]];
        [tag.auxRotations addObject:[NSNumber numberWithFloat:0]];
    }
    [image release];
    [self.delegate didCreateNewPix:tag];
    [tag release];
    
    [carouselView resetBadgeLocations];
    
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
    if (1) {
        CGSize newsize = CGSizeMake(1000, 2592*1000/1936.0);
        
        // scale to convert base image from 1936x2592 to 320x428 - iphone size
        float baseScale2 =  newsize.width / baseImage.size.width;
        CGRect scaledFrameImage2 = CGRectMake(0, 0, baseImage.size.width * baseScale2, baseImage.size.height * baseScale2);
        UIGraphicsBeginImageContext(newsize);
        [baseImage drawInRect:scaledFrameImage2];	
        UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();	
        // save edited image to photo album
        CGRect frame = [self.rectView frame];
        float scale2 = 1000 / frame.size.width;
        frame.size.width *= scale2;
        frame.size.height *= scale2;
        
        frame.origin.x *= scale2;
        frame.origin.y *= scale2;
        UIImage * cropped = [result croppedImage:frame];
        UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil); // write to photo album
        
    }
    CGSize screenContext = CGSizeMake(320, 2592*320/1936.0);
	
    // scale to convert base image from 1936x2592 to 320x428 - iphone size
	float baseScale =  screenContext.width / baseImage.size.width;
	CGRect scaledFrameImage = CGRectMake(0, 0, baseImage.size.width * baseScale, baseImage.size.height * baseScale);
    
	UIGraphicsBeginImageContext(screenContext);	
	[baseImage drawInRect:scaledFrameImage];	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	

    // save edited image to photo album
    UIImage * cropped = [result croppedImage:[self.rectView frame]];
    //UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil); // write to photo album    
    
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
            //[flashModeButton setTitle:@"Auto Flash" forState:UIControlStateNormal];
            [flashModeButton setImage:[UIImage imageNamed:@"flash_auto.png"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            //[flashModeButton setTitle:@"Flash On" forState:UIControlStateNormal];
            [flashModeButton setImage:[UIImage imageNamed:@"flash.png"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOff:
            //[flashModeButton setTitle:@"Flash Off" forState:UIControlStateNormal];
            [flashModeButton setImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    /*
    switch (camera.cameraDevice) {
        case UIImagePickerControllerCameraDeviceFront:
            //[cameraDeviceButton setTitle:@"Switch to Rear" forState:UIControlStateNormal];
            [cameraDeviceButton setImage:[UIImage imageNamed:@"flash_auto.png"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraDeviceRear:
            //[cameraDeviceButton setTitle:@"Switch to Front" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
     */
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

-(IBAction)feedbackButtonClicked:(id)sender {
    [self.delegate didClickFeedbackButton:@"Tag view"];
}

-(IBAction)didClickCloseButton:(id)sender {
    [self.delegate didDismissSecondaryView];
}

-(IBAction)didClickZoomIn:(id)sender {
}

-(IBAction)didClickZoomOut:(id)sender {
    
}

#pragma mark -


@end
