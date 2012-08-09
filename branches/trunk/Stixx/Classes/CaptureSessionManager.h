#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"
#define kImageCaptureFailed @"imageCaptureFailed"

@interface CaptureSessionManager : NSObject {
    AVCaptureDeviceInput *videoInputFront;
    AVCaptureDeviceInput *videoInputBack;
    BOOL isFront;
    int flashMode;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;

-(int)initializeCamera;
-(void)captureStillImage;
-(int)getMirrored;

-(void)switchDevices;
-(int)toggleFlash;
@end
