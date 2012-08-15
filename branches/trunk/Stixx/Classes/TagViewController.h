//
//  ARKViewController.h
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageCache.h"
#import "BadgeView.h"
#import "Tag.h"
#import "UIImage+Alpha.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "PixPreviewController.h"
#import "GlobalHeaders.h"
#import "CaptureSessionManager.h"

@protocol TagViewDelegate

- (NSString *)getUsername;
-(void)didConfirmNewPix:(Tag*)cameraTag;
- (bool) isLoggedIn;

-(void)didCreateBadgeView:(UIView*)newBadgeView;
-(void)didClickFeedbackButton:(NSString*)fromView;
-(void)didDismissSecondaryView;
-(void)pauseAggregation;

-(void)didPurchaseStixFromCarousel:(NSString*)stixStringID;
//-(int)getBuxCount;

-(int)getFirstTimeUserStage;
-(void)advanceFirstTimeUserMessage;
-(void)redisplayFirstTimeUserMessage01;
//-(BOOL)shouldPurchasePremiumPack:(NSString*)stixPackName;
-(NSMutableSet*)getFollowingList;

-(void)didCloseTagView;
@end


@interface TagViewController : UIViewController <BadgeViewDelegate, UIAlertViewDelegate, PixPreviewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	
	// layers of UIViewControllers
	//ARViewController *arViewController; // for saving and displaying coordinates
    
	NSObject<TagViewDelegate> *__unsafe_unretained delegate;
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
    
    Tag * cameraTag;
    
    bool photoAlbumOpened;
    int drag;
    
    BOOL isCapturing;
}
@property (nonatomic) IBOutlet UIButton * buttonInstructions;
@property (nonatomic) BadgeView * badgeView;
@property (nonatomic, unsafe_unretained) NSObject<TagViewDelegate> *delegate;
@property (nonatomic) IBOutlet UIImageView * rectView;
@property (nonatomic, assign) bool descriptorIsOpen;
@property (nonatomic, assign) bool needToShowCamera;
@property (nonatomic) IBOutlet UIImageView * aperture;
@property (nonatomic) IBOutlet UIButton * flashModeButton;
@property (nonatomic) IBOutlet UIButton * cameraDeviceButton;
@property (nonatomic) IBOutlet UIButton * buttonClose;
@property (nonatomic) IBOutlet UIButton * buttonTakePicture;
@property (nonatomic) IBOutlet UIButton * buttonImport;

@property (nonatomic) Tag * cameraTag;

// CaptureSessionManager
@property (retain) CaptureSessionManager *captureManager;
//@property (nonatomic, retain) UILabel *scanningLabel;

// sets a reference to a cameraController created outside in order to use modal view
- (void)cameraDidTakePicture:(id)sender;
- (void)clearTags;
- (void)addCoordinateOfTag:(Tag *) tag;
-(IBAction)closeInstructions:(id)sender;
-(void)updateCameraControlButtons:(int)flashMode;
-(IBAction)toggleFlashMode:(id)sender;
-(IBAction)toggleCameraDevice:(id)sender;
-(IBAction)feedbackButtonClicked:(id)sender;
-(IBAction)didClickCloseButton:(id)sender;
-(IBAction)didClickTakePicture:(id)sender;
-(IBAction)didClickImport:(id)sender;

-(UIImage *)rotateImage:(UIImage *)image withCurrentOrientation:(int)orient;
-(void)startCamera;
-(void)stopCamera;
@end
