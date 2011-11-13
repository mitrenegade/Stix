//
//  BTLFullScreenCameraController.m
//
//  Created by P. Mark Anderson on 8/6/2009.
//  Copyright (c) 2009 Bordertown Labs, LLC.
//  
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "BTLFullScreenCameraController.h"
#include <QuartzCore/QuartzCore.h>

#define CAMERA_SCALAR 1.12412 // scalar = (480 / (2048 / 480))
//#define CAMERA_SCALAR .8

@implementation BTLFullScreenCameraController

@synthesize statusLabel, overlayController;
@synthesize addedOverlay;
@synthesize ROI;
- (id)init {
  if (self = [super init]) {
#if !TARGET_IPHONE_SIMULATOR
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.showsCameraControls = NO;
    self.navigationBarHidden = YES;
    self.toolbarHidden = YES; // prevents bottom bar from being displayed
    self.allowsEditing = NO;
    self.wantsFullScreenLayout = NO;
    //self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, CAMERA_SCALAR, CAMERA_SCALAR);    		
#endif
		
		if ([self.overlayController respondsToSelector:@selector(initStatusMessage)]) {
			[self.overlayController performSelector:@selector(initStatusMessage)];
		} else {
			[self initStatusMessage];
		}	
      
      self.ROI = CGRectMake(0, 0, 320, 480); // default ROI
  }
  return self;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];	

}
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
}
-(void)viewDidUnload{
	[super viewDidUnload];
}

+ (BOOL)isAvailable {
  return [self isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)displayModalWithController:(UIViewController*)controller animated:(BOOL)animated {
  [controller presentModalViewController:self animated:animated];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated {
  [self.overlayController dismissModalViewControllerAnimated:animated];
}

- (void)takePicture {
	if ([self.overlayController respondsToSelector:@selector(cameraWillTakePicture:)]) {
		[self.overlayController performSelector:@selector(cameraWillTakePicture:) withObject:self];
	}
	
	self.delegate = self;
	[self showStatusMessage:@"Taking photo..."];

	[super takePicture];
}

- (UIImage*)addOverlayToBaseImage:(UIImage*)baseImage {
	// add only the selected badge to the base image
	UIImage *overlayImage = [addedOverlay image];
    CGSize addedOverlayContext = CGSizeMake(320, 480);
	CGSize targetSize = CGSizeMake(ROI.size.width, ROI.size.height);	//250, 250
	
	float baseScale =  targetSize.width / baseImage.size.width;
    float overlayScale =  targetSize.width / addedOverlayContext.width;

	CGRect scaledFrameOverlay = addedOverlay.frame;
	scaledFrameOverlay.origin.x = scaledFrameOverlay.origin.x * overlayScale;
	scaledFrameOverlay.origin.y = scaledFrameOverlay.origin.y * overlayScale;
	scaledFrameOverlay.size.width = scaledFrameOverlay.size.width * overlayScale;
	scaledFrameOverlay.size.height = scaledFrameOverlay.size.height * overlayScale;
	
    // we want to scale as well as crop. The width of the full screen camera is 320x480,
    // and the cropped region is stored in ROI.

	CGRect scaledFrameImage = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
	scaledFrameImage.origin.x = scaledFrameImage.origin.x * baseScale;
	scaledFrameImage.origin.y = scaledFrameImage.origin.y * baseScale;
	scaledFrameImage.size.width = scaledFrameImage.size.width * baseScale;
	scaledFrameImage.size.height = scaledFrameImage.size.height * baseScale;

	UIGraphicsBeginImageContext(targetSize);	
	[baseImage drawInRect:scaledFrameImage];	
	[overlayImage drawInRect:scaledFrameOverlay];	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
    	
    UIImage * cropped = [result croppedImage:ROI];
    UIImage * rounded = [cropped roundedCornerImage:5 borderSize:0];

    // save both original image and edited image to photo album
    UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil); // write to photo album
    UIImageWriteToSavedPhotosAlbum(rounded, nil, nil, nil); // write to photo album

	[self showStatusMessage:@"addOverlayToBaseImage done"];
	return rounded;	
}

- (void)adjustLandscapePhoto:(UIImage*)image {
	// TODO: maybe use this for something
	NSLog(@"camera image: %f x %f", image.size.width, image.size.height);

	switch (image.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			// portrait
			NSLog(@"portrait");
			break;
		default:
			// landscape
			NSLog(@"landscape");
			break;
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self showStatusMessage:@"Saving photo..."];
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
	
	[self saveComposite:baseImage];
}

- (void)saveComposite:(UIImage*)baseImage {
	// save composite
	UIImage *compositeImage = [self addOverlayToBaseImage:baseImage];
    [self hideStatusMessage];

	[self showStatusMessage:@"Done finish picking media; saved to image cache"];

	// hack: use the image cache in the easy way - just cache one image each time
	if ([[ImageCache sharedImageCache] imageForKey:@"newImage"])
		[[ImageCache sharedImageCache] deleteImageForKey:@"newImage"];
	[[ImageCache sharedImageCache] setImage:compositeImage forKey:@"newImage"];
	
	[self hideStatusMessage];
	
	if ([self.overlayController respondsToSelector:@selector(cameraDidTakePicture:)]) {
		[self.overlayController performSelector:@selector(cameraDidTakePicture:) withObject:self];
	}
	
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary*)info {
	[self showStatusMessage:@"Did finish saving with error!"];
}

- (void)initStatusMessage {
    /*
	self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
	self.statusLabel.textAlignment = UITextAlignmentCenter;
	self.statusLabel.adjustsFontSizeToFitWidth = YES;
	self.statusLabel.backgroundColor = [UIColor clearColor];
	self.statusLabel.textColor = [UIColor whiteColor];
	self.statusLabel.shadowOffset = CGSizeMake(0, -1);  
	self.statusLabel.shadowColor = [UIColor blackColor];  
	self.statusLabel.hidden = YES;
	[self.view addSubview:self.statusLabel];
     */
}


- (void)hideStatusMessage {
	if ([self.overlayController respondsToSelector:@selector(hideStatusMessage)]) {
		[self.overlayController performSelector:@selector(hideStatusMessage)];
	} else {
		self.statusLabel.hidden = YES;
	}
}

- (void)showStatusMessage:(NSString*)message {
	if ([self.overlayController respondsToSelector:@selector(showStatusMessage:)]) {
		[self.overlayController performSelector:@selector(showStatusMessage) withObject:message];
	} else {
		self.statusLabel.text = message;
		self.statusLabel.hidden = NO;
		[self.view bringSubviewToFront:self.statusLabel];
		
	}
}

- (void)writeImageToDocuments:(UIImage*)image {
	NSData *png = UIImagePNGRepresentation(image);
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSError *error = nil;
	[png writeToFile:[documentsDirectory stringByAppendingPathComponent:@"image.png"] options:NSAtomicWrite error:&error];
}

- (BOOL)canBecomeFirstResponder { return YES; }

- (void)dealloc {
	[overlayController release];
	[statusLabel release];
  [super dealloc];
	
}


@end
