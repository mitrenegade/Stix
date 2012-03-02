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
#import "NoClipModalView.h"

#define STATUS_BAR_SHIFT 20 // the distance from the y coordinate of the visible camera and the actual y coordinate in screen - bug/hack!

@protocol TagViewDelegate

- (NSString *)getUsername;
//- (void) tagViewDidAddTag:(Tag*)newTag;
-(void)didCreateNewPix:(Tag*)newTag;
- (bool) isLoggedIn;

-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;
-(void)didCreateBadgeView:(UIView*)newBadgeView;
-(void)didClickFeedbackButton:(NSString*)fromView;
-(void)didDismissSecondaryView;
@end


@interface TagViewController : UIViewController <BadgeViewDelegate, UIAlertViewDelegate, TagDescriptorDelegate, ARViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate > {
	
	// layers of UIViewControllers
	BTLFullScreenCameraController *cameraController; // for viewing through camera
    UIImagePickerController * camera;
	ARViewController *arViewController; // for saving and displaying coordinates
    
	NSObject<TagViewDelegate> *delegate;
//	UIView *overlayView;
    CGRect badgeFrame;

    IBOutlet UIImageView * aperture;
    IBOutlet UIImageView * rectView; // exists purely to give us the coordinates of the aperture
    IBOutlet UIButton * buttonInstructions;
    
    IBOutlet UIButton * flashModeButton;
    IBOutlet UIButton * cameraDeviceButton;
//    IBOutlet UIButton * buttonFeedback;
    
    IBOutlet UIButton * buttonClose;
    //IBOutlet UIButton * buttonZoomIn;
    //IBOutlet UIButton * buttonZoomOut;
    
    IBOutlet UIButton * buttonTakePicture;
    IBOutlet UIButton * buttonImport;
    
    TagDescriptorController * descriptorController;
    bool descriptorIsOpen;
    bool needToShowCamera;
    bool photoAlbumOpened;
    int drag;
}
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
@property (nonatomic, retain) BadgeView * badgeView;
@property (nonatomic, retain) BTLFullScreenCameraController *cameraController;
@property (nonatomic, retain) ARViewController *arViewController;
@property (nonatomic, assign) NSObject<TagViewDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UIImageView * rectView;
//@property (nonatomic, retain) UIView * overlayView;
@property (nonatomic, retain) UIImagePickerController * camera;
@property (nonatomic, assign) bool descriptorIsOpen;
@property (nonatomic, assign) bool needToShowCamera;
@property (nonatomic, retain) TagDescriptorController * descriptorController;
@property (nonatomic, retain) IBOutlet UIImageView * aperture;
@property (nonatomic, retain) IBOutlet UIButton * flashModeButton;
@property (nonatomic, retain) IBOutlet UIButton * cameraDeviceButton;
//@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) IBOutlet UIButton * buttonClose;
@property (nonatomic, retain) IBOutlet UIButton * buttonTakePicture;
@property (nonatomic, retain) IBOutlet UIButton * buttonImport;

// sets a reference to a cameraController created outside in order to use modal view
- (void)cameraDidTakePicture:(id)sender;
- (void)clearTags;
- (void)addCoordinateOfTag:(Tag *) tag;
- (void)setCameraOverlayView:(UIView *)cameraOverlayView;
-(IBAction)closeInstructions:(id)sender;
-(void)updateCameraControlButtons;
-(IBAction)toggleFlashMode:(id)sender;
-(IBAction)toggleCameraDevice:(id)sender;
-(IBAction)feedbackButtonClicked:(id)sender;
-(IBAction)didClickCloseButton:(id)sender;
-(IBAction)didClickTakePicture:(id)sender;
-(IBAction)didClickImport:(id)sender;
@end
