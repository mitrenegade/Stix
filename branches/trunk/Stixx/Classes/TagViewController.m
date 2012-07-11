#import "TagViewController.h"

#define VIEWPORT_WIDTH_RADIANS .5
#define VIEWPORT_HEIGHT_RADIANS .7392

@implementation TagViewController

@synthesize delegate;
//@synthesize arViewController;
@synthesize rectView;
@synthesize buttonInstructions;
@synthesize badgeView;
//@synthesize overlayView;
@synthesize camera;
@synthesize descriptorIsOpen;
@synthesize needToShowCamera;
@synthesize aperture;
@synthesize cameraDeviceButton;
@synthesize flashModeButton;
@synthesize buttonClose;
@synthesize buttonTakePicture;
@synthesize buttonImport;
@synthesize cameraTag;

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
    /*
    arViewController = [[ARViewController alloc] init];
	CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:42.369182 longitude:-71.080427];
	arViewController.scaleViewsBasedOnDistance = YES;
	arViewController.minimumScaleFactor = .5;
	arViewController.rotateViewsBasedOnPerspective = NO;
	arViewController.centerLocation = newCenter;
	[newCenter release];
     */
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
    [super loadView];   
}

-(void) viewDidLoad {
    [super viewDidLoad];

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
    //[buttonZoomIn setHidden:YES];
    //[buttonZoomOut setHidden:YES];
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
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        needToShowCamera = NO;
    }
#endif
    
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

#pragma mark camera - imagepickercontroller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (photoAlbumOpened) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self.camera dismissModalViewControllerAnimated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
	UIImage * originalPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
	UIImage *baseImage = originalPhoto;
	if (baseImage == nil) return;
    UIImageOrientation or = [baseImage imageOrientation];
    // orientation 3 is normal camera use, orientation 0 is landscape mode
	    
    // raw images taken by this camera (with the status bar gone but the nav bar present are 1936x2592 (widthxheight) pix
    // that means the actual image is 320x428.42 on the iphone
    
    int original_height = baseImage.size.height;
    int original_width = baseImage.size.width;
    CGSize screenContext = CGSizeMake(320, original_height*320/original_width);
    if (or == 0 && !photoAlbumOpened)
        screenContext = CGSizeMake(original_width*320/original_height, 320);
	
    // scale to convert base image from 1936x2592 to 320x428 - iphone size
	float baseScale =  screenContext.width / baseImage.size.width;
	CGRect scaledFrameImage = CGRectMake(0, 0, baseImage.size.width * baseScale, baseImage.size.height * baseScale);
    
	UIGraphicsBeginImageContext(screenContext);	
	[baseImage drawInRect:scaledFrameImage];	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	

    // crop to camera view size - 314 x 282
    // baseImage should be 320x428 - crop the middle 314x282
    int target_width = self.rectView.frame.size.width;
    int target_height = self.rectView.frame.size.height;
    UIImage * cropped = nil;
    int minHeight = self.rectView.frame.origin.y + self.rectView.frame.size.height;
    int minWidth = self.rectView.frame.origin.x + self.rectView.frame.size.width;
        
    if ((or == 3 && result.size.height > minHeight) || (or == 0 && !photoAlbumOpened && result.size.width > minWidth)) {
        // if resized image has height greater than the bottom of the crop frame
        CGRect targetFrame = [self.rectView frame];
        if (or == 0 && !photoAlbumOpened) { // hack: loaded images from photo album will be or=0 even if they were taken normally
            int width = targetFrame.size.width;
            int height = targetFrame.size.height;
            int x = targetFrame.origin.y - (width - height)/2; // camera will take a picture that is taller than wide, but we display images that are wider than tall, so we offset the x by half that difference to keep the correct center and aspect ratio
            int y = self.view.frame.size.width - (targetFrame.origin.x + targetFrame.size.width);
            targetFrame = CGRectMake(x, y, width, height);
        }
        cropped = [result croppedImage:targetFrame];
        CGSize resultSize = [cropped size];
        NSLog(@"Cropped image to size %f %f", resultSize.width, resultSize.height);
    }
    else if (result.size.height >= target_height) {
        // resized image has height greater than target height, crop evenly
        int ydiff = result.size.height - target_height;
        CGRect targetFrame = CGRectMake(0, ydiff/2, target_width, target_height);
        cropped = [result croppedImage:targetFrame];
        CGSize resultSize = [cropped size];
        NSLog(@"Cropped image to size %f %f", resultSize.width, resultSize.height);
    }
    else { // (result.size.height < target_height) {
        // if the picture is not tall enough (a wide image from library), crop from left and right evenly
        int new_width = baseImage.size.width/baseImage.size.height*target_height;
        CGRect scaledFrameImage = CGRectMake(0, 0, new_width, target_height);
        
        UIGraphicsBeginImageContext(screenContext);	
        [baseImage drawInRect:scaledFrameImage];	
        UIImage* result2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();	
        int xdiff = new_width - target_width;
        CGRect cropFrame = CGRectMake(xdiff/2, 0, target_width, target_height);
        cropped = [result2 croppedImage:cropFrame];
        CGSize resultSize = [cropped size];
        NSLog(@"Cropped image to size %f %f", resultSize.width, resultSize.height);
    }
    
    CGSize fullSize = CGSizeMake(PIX_WIDTH, PIX_HEIGHT);
    if (cropped)
        cropped = [cropped resizedImage:fullSize interpolationQuality:kCGInterpolationHigh];
	if ([[ImageCache sharedImageCache] imageForKey:@"originalImage"])
		[[ImageCache sharedImageCache] deleteImageForKey:@"originalImage"];
	[[ImageCache sharedImageCache] setImage:originalPhoto forKey:@"originalImage"];

	// set a title
    descriptorIsOpen = YES; // prevent camera from reanimating on viewDidAppear
    needToShowCamera = NO; // still not need to show camera
    
    // create temporary tag with:
    // - username
    // - cropped image
    // 
    // high res image will be added on confirmation
    // stix will be added after that
    cameraTag = [[Tag alloc] init]; 
    [cameraTag addImage:cropped];
    [cameraTag setUsername:[delegate getUsername]];
    [cameraTag setTimestamp:[NSDate date]]; // hack: since we don't reload the tag after creating it, we need to put in a temporary timestamp. next time the tag is actually loaded from kumulos the real one will exist
    
    // prompt for image confirmation
    if (!previewController) {
        previewController = [[PixPreviewController alloc] init];
        [previewController setDelegate:self];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    // hack a way to display view over camera; formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [previewController.view setFrame:frameShifted];
    [self.camera setCameraOverlayView:previewController.view];
#endif
    
    // populate after view has been created
    [previewController initWithTag:cameraTag];
    
    photoAlbumOpened = NO;
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary*)info {
	NSLog(@"Did finish saving with error!");
}

#pragma mark PixPreview delegate

-(void)didConfirmPix {
    UIImage * baseImage = [[ImageCache sharedImageCache] imageForKey:@"originalImage"];
    if (baseImage == nil) return;
    UIImageOrientation or = [baseImage imageOrientation];
    // orientation 3 is normal camera use, orientation 0 is landscape mode
    
    // screenContext is the actual size in pixels shown on screen, ie stix pixels are scaled 1x1 to the captured image
    if (!photoAlbumOpened) {
        NSLog(@"Saving high res picture ***********************");
        // save high res version
        int highResWidth = PIX_WIDTH * 2;
        CGSize newsize = CGSizeMake(highResWidth, highResWidth*2592.0/1936.0);
        if (or == 0 && !photoAlbumOpened)
            newsize = CGSizeMake(2592.0/1936.0*highResWidth, highResWidth);
        
        // scale to convert base image from 1936x2592 to 320x428 - iphone size
        float baseScale2 =  newsize.width / baseImage.size.width;
        CGRect scaledFrameImage2 = CGRectMake(0, 0, baseImage.size.width * baseScale2, baseImage.size.height * baseScale2);
        UIGraphicsBeginImageContext(newsize);
        [baseImage drawInRect:scaledFrameImage2];	
        UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();	
        
        // save edited image to photo album
        CGRect frame = [self.rectView frame];
        float scale2 = highResWidth/ frame.size.width;
        frame.size.width *= scale2;
        frame.size.height *= scale2;
        
        frame.origin.x *= scale2;
        frame.origin.y *= scale2;
        [delegate pauseAggregation];
        UIImage * largeImage = [result croppedImage:frame];
        NSLog(@"*******************************Writing to stix album*******************************");
        UIImageWriteToSavedPhotosAlbum(largeImage, nil, nil, nil); 
        [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:largeImage toAlbum:@"Stix Album" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"*******************************Could not write to library: error %@*******************************", [error description]);
                // retry one more time
                [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:largeImage toAlbum:@"Stix Album" withCompletionBlock:^(NSError *error) {
                    if (error!=nil) {
                        NSLog(@"Second attempt to write to library failed: error %@", [error description]);
                    }
                }];
            }
            else {
                NSLog(@"*******************************Wrote to stix album*******************************");
            }
        }];
        // just save to tag
        /*
        if ([[ImageCache sharedImageCache] imageForKey:@"largeImage"])
            [[ImageCache sharedImageCache] deleteImageForKey:@"largeImage"];
        [[ImageCache sharedImageCache] setImage:cropped forKey:@"largeImage"];
         */
        [cameraTag setHighResImage:largeImage];
        NSLog(@"Done saving high res picture *************");
    }
    
    [delegate didConfirmNewPix:cameraTag];
    needToShowCamera = YES;
    descriptorIsOpen = NO;
    [self viewDidAppear:NO];
    [previewController stopActivityIndicatorLarge];
}

-(void)didCancelPix {
    [self.camera setCameraOverlayView:self.view];
    needToShowCamera = YES;
    descriptorIsOpen = NO;
    [self viewDidAppear:NO];    
}

#pragma mark other tagView functions

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
    if ([delegate getFirstTimeUserStage] == 0) {
        // advance to next
        // this is to make the users/developers not have to take a picture each time
        if ([[delegate getFollowingList] count] > 0)
            [delegate advanceFirstTimeUserMessage];
        // if no followers, force them to take a photo so they can remix it
        else 
            [delegate redisplayFirstTimeUserMessage01];
    }
    [delegate didDismissSecondaryView];
}

-(IBAction)didClickTakePicture:(id)sender {
    NSLog(@"PhotoAlbumOpened: %d", photoAlbumOpened);
    if (descriptorIsOpen)
        return;
    [[self camera] takePicture];
}

-(IBAction)didClickImport:(id)sender {
    NSLog(@"PhotoAlbumOpened: %d", photoAlbumOpened);
    if (descriptorIsOpen)
        return;
    
    UIImagePickerController * album = [[UIImagePickerController alloc] init];
    album.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; ////SavedPhotosAlbum;
    album.allowsEditing = NO;
    album.delegate = self;
    photoAlbumOpened = YES;
    [self.camera presentModalViewController:album animated:YES];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self.camera dismissModalViewControllerAnimated:YES];
    photoAlbumOpened = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
