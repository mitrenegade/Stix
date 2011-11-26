//
//  BTLFullScreenCameraController.h
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
    
#import <UIKit/UIKit.h>
#import "ImageCache.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"

@interface BTLFullScreenCameraController : UIImagePickerController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	UIViewController *overlayController;

	UIImageView *addedOverlay; // an extra image sent in by an outside controller to be added to the composite
	
    CGRect ROI; // area in which camera is actually within the aperture; must be set by controller
}

@property (nonatomic, retain) UIViewController *overlayController;
@property (nonatomic, retain) UIImageView *addedOverlay;
@property (nonatomic, assign) CGRect ROI;

+ (BOOL)isAvailable;
- (void)displayModalWithController:(UIViewController*)controller animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;
- (void)takePicture;
- (void)writeImageToDocuments:(UIImage*)image;
- (void)saveComposite:(UIImage*)baseImage;
- (void)cropComposite:(UIImage*)baseImage;
@end
