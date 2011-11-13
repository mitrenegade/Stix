//
//  ARKViewController.h
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageCache.h"
#import "BTLFullScreenCameraController.h"
#import "TagDescriptorController.h"
#import "BadgeView.h"
#import "ARViewController.h"
#import "Tag.h"
#import "ARCoordinate.h"

#define BINOCS_TAG 99
#define BINOCS_BUTTON_TAG 100

@protocol TagViewDelegate

- (NSString *)getCurrentUsername;
- (void) addTag:(Tag*)newTag;

@optional
- (void) failedToAddCoordinateOfTag:(Tag*)tag;

@end


@interface TagViewController : UIViewController <BadgeViewDelegate, UIAlertViewDelegate, TagDescriptorDelegate, ARViewDelegate> {
	
	// layers of UIViewControllers
	BadgeView * badgeView; // for dragging and releasing badge
	BTLFullScreenCameraController *cameraController; // for viewing through camera
	ARViewController *arViewController; // for saving and displaying coordinates
    
	NSObject<TagViewDelegate> *delegate;
	UIView *overlayView;
    CGRect badgeFrame;
    
    IBOutlet UIImageView * rectView; // exists purely to give us the coordinates of the aperture
}

// sets a reference to a cameraController created outside in order to use modal view
- (void)cameraDidTakePicture:(id)sender;
- (void)clearTags;
- (Tag*)createTagWithName:(NSString*)name andComment:(NSString*)comment andImage:(UIImage*)image andBadge_X:(int)badge_x andBadge_Y:(int)badge_y andCoordinate:(ARCoordinate*)coordinate;
- (void)addCoordinateOfTag:(Tag *) tag;
- (void)setCameraOverlayView:(UIView *)cameraOverlayView;

@property (nonatomic, retain) BadgeView *badgeView;
@property (nonatomic, retain) BTLFullScreenCameraController *cameraController;
@property (nonatomic, retain) ARViewController *arViewController;
@property (nonatomic, assign) NSObject<TagViewDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UIImageView * rectView;
@end
