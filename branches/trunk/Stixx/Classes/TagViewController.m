#import "TagViewController.h"

#define VIEWPORT_WIDTH_RADIANS .5
#define VIEWPORT_HEIGHT_RADIANS .7392

@interface TagViewController ()
// private member variable
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@implementation TagViewController

@synthesize delegate;
@synthesize rectView;
@synthesize buttonInstructions;
@synthesize badgeView;
@synthesize aperture;
@synthesize cameraDeviceButton;
@synthesize flashModeButton;
//@synthesize buttonClose;
@synthesize buttonTakePicture;
@synthesize buttonImport;
@synthesize cameraTag;

@synthesize captureManager;
//@synthesize scanningLabel;

- (id)init {
	
    self = [super initWithNibName:@"TagViewController" bundle:nil];
    {
    }
    return self;
}
-(void) viewDidLoad {
    [super viewDidLoad];
    [self setCaptureManager:[[CaptureSessionManager alloc] init]];
    int flashMode = [captureManager initializeCamera];
    [self updateCameraControlButtons:flashMode];
    
	CGRect layerRect = [[[self view] layer] bounds];
	[[[self captureManager] previewLayer] setBounds:layerRect];
	[[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [[self.view layer] insertSublayer:[self.captureManager previewLayer] below: [self.aperture layer]];
//    [[self.view layer] insertSublayer:[self.captureManager previewLayer] below: [buttonTakePicture layer]];
/*    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 120, 30)];
    [self setScanningLabel:tempLabel];
	[scanningLabel setBackgroundColor:[UIColor clearColor]];
	[scanningLabel setFont:[UIFont fontWithName:@"Courier" size: 18.0]];
	[scanningLabel setTextColor:[UIColor redColor]]; 
	[scanningLabel setText:@"Scanning..."];
    [scanningLabel setHidden:YES];
	[[self view] addSubview:scanningLabel];	
*/    
    // add a notification for completion of capture
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCaptureImage) name:kImageCapturedSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureImageDidFail:) name:kImageCaptureFailed object:nil];
    
    [self startCamera];
}

-(void)startCamera {
    captureManager.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    [[captureManager captureSession] startRunning];
}

-(void)stopCamera {
    [[captureManager captureSession] stopRunning];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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

#pragma mark TagViewController camera controls
-(void)updateCameraControlButtons:(int)cameraFlashMode {
    switch (cameraFlashMode) {
        case AVCaptureFlashModeAuto:
            [flashModeButton setImage:[UIImage imageNamed:@"flash_auto.png"] forState:UIControlStateNormal];
            break;
        case AVCaptureFlashModeOn:
            [flashModeButton setImage:[UIImage imageNamed:@"flash.png"] forState:UIControlStateNormal];
            break;
        case AVCaptureFlashModeOff:
            [flashModeButton setImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

-(IBAction)toggleFlashMode:(id)sender {
    int flashMode = [captureManager toggleFlash];
    [self updateCameraControlButtons:flashMode];
}

-(IBAction)toggleCameraDevice:(id)sender {
    [captureManager switchDevices];
}

-(IBAction)feedbackButtonClicked:(id)sender {
    [self.delegate didClickFeedbackButton:@"Tag view"];
}

-(void)didClickCloseButton:(id)sender {
    if ([delegate getFirstTimeUserStage] == 0) {
        // advance to next
        // this is to make the users/developers not have to take a picture each time
        if ([[delegate getFollowingList] count] > 0)
            [delegate advanceFirstTimeUserMessage];
        // if no followers, force them to take a photo so they can remix it
        else 
            [delegate redisplayFirstTimeUserMessage01];
    }
    //[delegate didDismissSecondaryView];
    [self.navigationController popViewControllerAnimated:YES]; // close self
    [delegate didCloseTagView];
}

-(IBAction)didClickTakePicture:(id)sender {
    NSLog(@"PhotoAlbumOpened: %d", photoAlbumOpened);
    if (isCapturing)
        return;
    
//    [[self scanningLabel] setHidden:NO];
    [[self captureManager] captureStillImage];
    isCapturing = YES;
}

-(IBAction)didClickImport:(id)sender {
    NSLog(@"PhotoAlbumOpened: %d", photoAlbumOpened);
    
    UIImagePickerController * album = [[UIImagePickerController alloc] init];
    album.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; ////SavedPhotosAlbum;
    album.allowsEditing = NO;
    album.delegate = self;
    photoAlbumOpened = YES;
    [self presentModalViewController:album animated:YES];
}

- (void)didCaptureImage 
{
//    [[self scanningLabel] setHidden:YES];
    UIImage * originalImage = [self.captureManager stillImage];
    
    [self didTakePhoto:originalImage];
}

-(void)captureImageDidFail:(NSNotification*)notification {
    if ([[notification.userInfo objectForKey:@"code"] intValue] == -11801) {
        NSLog(@"Code=-11801 Cannot Complete Action UserInfo=0xe8b2480 {NSLocalizedRecoverySuggestion=Try again later., NSLocalizedDescription=Cannot Complete Action");
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Error!" message:@"Image couldn't be captured" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
//        [[self scanningLabel] setHidden:YES];
    }
}

#pragma mark camera - imagepickercontroller delegate - only for photo album

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // only used for photoalbum
    if (photoAlbumOpened) {
        [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
        [self dismissModalViewControllerAnimated:YES];
    }
	UIImage * originalPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self didTakePhoto:originalPhoto];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissModalViewControllerAnimated:YES];
    photoAlbumOpened = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
}

-(void)didTakePhoto:(UIImage*)originalPhoto{
	UIImage *baseImage = originalPhoto;
	if (baseImage == nil) return;
    //UIImageOrientation or = [baseImage imageOrientation];
    // orientation 3 is normal (vertical) camera use, orientation 0 is landscape mode
    UIImageOrientation or = [UIDevice currentDevice].orientation;
    // 1 = vertical/normal
    // 2 = upside down
    // 3 = landscape left
    // 4 = landscape right
    BOOL landscape = (or >= 3 && !photoAlbumOpened);
    NSLog(@"or: %d photoAlbum: %d landscape %d", or, photoAlbumOpened, landscape);
    UIImage * result2;
    UIImage * scaled;
    CGRect croppedFrame;
    
    float original_height = baseImage.size.height;
    float original_width = baseImage.size.width;
    
    // for AVCapture, there is no automatic rotation for landscape.
    // the raw image is 720x1280.
    // we want an image at 320x(480+)
    
//    if (!landscape) {
        float scaled_width = 320;
        float scaled_height = original_height/original_width*320;
        scaled = [originalPhoto resizedImage:CGSizeMake(scaled_width, scaled_height) interpolationQuality:kCGInterpolationHigh];
        float offset = (scaled_height - 480)/2;
        NSLog(@"scaledWidth %f scaledHeight %f offset %f", scaled_width, scaled_height, offset);
        // target_height is smaller than scaled_height so we only take the middle
        croppedFrame = CGRectMake(0, offset, 320, 480);
    /*
    }
    else {
        float scaled_height = 320;
        float scaled_width = original_width/original_height*320;
        scaled = [originalPhoto resizedImage:CGSizeMake(scaled_width, scaled_height) interpolationQuality:kCGInterpolationHigh];
        float offset = (scaled_width - 480)/2;
        NSLog(@"scaledWidth %f scaledHeight %f offset %f", scaled_width, scaled_height, offset);
        // target_height is smaller than scaled_height so we only take the middle
        croppedFrame = CGRectMake(offset, 0, 320, 480);
    }
     */
        
    result2 = [scaled croppedImage:croppedFrame];

    // rotate
    UIImage * result;
    if (or == 0 || or == 5)
        or = 1; // somehow invalid orientation. just treat as regular one
    if (photoAlbumOpened)
        result = result2;
    else
        result = [self rotateImage:result2 withCurrentOrientation:or];
    
    // crop to camera view size - 314 x 282
    // baseImage should be 320x428 - crop the middle 314x282
    int target_width = self.rectView.frame.size.width;
    int target_height = self.rectView.frame.size.height;
    UIImage * cropped = nil;
    int minHeight = self.rectView.frame.origin.y + self.rectView.frame.size.height;
    int minWidth = self.rectView.frame.origin.x + self.rectView.frame.size.width;
    NSLog(@"target_width target_height %d %d result width result height %f %F", target_width, target_height, result.size.width, result.size.height);
    
    if ((or == 1 && result.size.height > minHeight) || (landscape && result.size.width > minWidth)) {
        // if resized image has height greater than the bottom of the crop frame
        CGRect targetFrame = [self.rectView frame];
        if (landscape) { // hack: loaded images from photo album will be or=0 even if they were taken normally
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
        float xdiff = result.size.width - target_width;
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


//    UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil); 

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
#if !TARGET_IPHONE_SIMULATOR
    PixPreviewController * previewController = [[PixPreviewController alloc] init];
    [previewController setDelegate:self];
    [previewController setImage:cropped];
    [self.navigationController pushViewController:previewController animated:YES];
#endif
    
    isCapturing = NO;
    photoAlbumOpened = NO;
}

#pragma mark PixPreview delegate
-(void)didConfirmPix {
    UIImage * baseImage = [[ImageCache sharedImageCache] imageForKey:@"originalImage"];
    if (baseImage == nil) return;
    UIImageOrientation or = [baseImage imageOrientation];
    // orientation 3 is normal camera use, orientation 0 is landscape mode
    
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
    else {
        [cameraTag setHighResImage:baseImage];
    }
    
    [self.navigationController popViewControllerAnimated:NO];
    [delegate didCloseTagView];
    [delegate didConfirmNewPix:cameraTag];
}

-(void)didCancelPix {
    //    [self.camera setCameraOverlayView:self.view];
    [self.navigationController popViewControllerAnimated:YES];
    //    [self viewDidAppear:NO];    
}
-(UIImage *)rotateImage:(UIImage *)image withCurrentOrientation:(int)orient  
{  
    int kMaxResolution = 320; // Or whatever  
    
    CGImageRef imgRef = image.CGImage;  
    
    CGFloat width = CGImageGetWidth(imgRef);  
    CGFloat height = CGImageGetHeight(imgRef);  
    
    CGAffineTransform transform = CGAffineTransformIdentity;  
    CGRect bounds = CGRectMake(0, 0, width, height);  
    
    CGFloat scaleRatio = 1; //bounds.size.width / width;  
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
    CGFloat boundHeight;  
    switch(orient) {  
            
        case 1: // up
            transform = CGAffineTransformIdentity;  
            /*
            if ([self.captureManager getMirrored]) {
                transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);  
                transform = CGAffineTransformScale(transform, -1.0, 1.0);  
            }*/
            break;  
        case 2: // down  
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);  
            transform = CGAffineTransformRotate(transform, M_PI);  
            if ([self.captureManager getMirrored]) {
//                transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);  
//                transform = CGAffineTransformScale(transform, 1.0, -1.0);  
            }
            break;  
            
        case 3: // left 
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);  
            if (![self.captureManager getMirrored]) {
                transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
            } else {
                transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
                transform = CGAffineTransformTranslate(transform, -imageSize.width, -imageSize.height);
            }
            break;  
            
        case 4: // right 
            boundHeight = bounds.size.height;  
            bounds.size.height = bounds.size.width;  
            bounds.size.width = boundHeight;  
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);  
            if (![self.captureManager getMirrored]) {
                transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
            } else {
                transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
                transform = CGAffineTransformTranslate(transform, -imageSize.width, -imageSize.height);
            }
            break;  
            
        default:  
//            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation: %d", orient];  
            transform = CGAffineTransformIdentity;  
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Error!" message:[NSString stringWithFormat:@"Invalid orientation: %d", orient] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
             */
            break;            
    }  
    
    UIGraphicsBeginImageContext(bounds.size);  
    
    CGContextRef context = UIGraphicsGetCurrentContext();  
    
    if (orient == 3 || orient == 4) {   // landscape
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);  
//        if (![captureManager getMirrored])
            CGContextTranslateCTM(context, -height, 0);  
    }  
    else {  
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);  
        CGContextTranslateCTM(context, 0, -height);  
    }  
    
    CGContextConcatCTM(context, transform);  
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);  
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
    
    return imageCopy;  
}  

@end
