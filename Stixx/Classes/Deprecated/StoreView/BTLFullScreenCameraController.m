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

@implementation BTLFullScreenCameraController

@synthesize overlayController;
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
    self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
#endif
		      
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

    @try {
        [super takePicture];
    }
    @catch (NSException* exception) {
#if TARGET_IPHONE_SIMULATOR
		[self.overlayController performSelector:@selector(cameraDidTakePicture:) withObject:self];
#endif        
        NSLog(@"Take picture failed %@", [exception reason]);
    }
}

- (void)adjustLandscapePhoto:(UIImage*)image {
	// TODO: maybe use this for something
	//NSLog(@"camera image: %f x %f", image.size.width, image.size.height);

	switch (image.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			// portrait
			//NSLog(@"portrait");
			break;
		default:
			// landscape
			//NSLog(@"landscape");
			break;
	}
}

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
	
    [self cropComposite:baseImage];
}

- (void)cropComposite:(UIImage*)baseImage {
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
    
    UIImage * cropped = [result croppedImage:ROI];
    // save edited image to photo album
    UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil); // write to photo album
    
	// hack: use the image cache in the easy way - just cache one image each time
	if ([[ImageCache sharedImageCache] imageForKey:@"newImage"])
		[[ImageCache sharedImageCache] deleteImageForKey:@"newImage"];
	[[ImageCache sharedImageCache] setImage:cropped forKey:@"newImage"];
    
	if ([self.overlayController respondsToSelector:@selector(cameraDidTakePicture:)]) {
		[self.overlayController performSelector:@selector(cameraDidTakePicture:) withObject:self];
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

- (BOOL)canBecomeFirstResponder { return YES; }

- (void)dealloc {
	[overlayController release];
  [super dealloc];
	
}


@end
