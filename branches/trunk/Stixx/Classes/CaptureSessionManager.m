#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+Resize.h"

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImage, stillImageOutput;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]] autorelease]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
}

- (AVCaptureDevice *)frontFacingCameraIfAvailable  
{  
    //  look at all the video devices and get the first one that's on the front  
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];  
    AVCaptureDevice *captureDevice = nil;  
    for (AVCaptureDevice *device in videoDevices)  
    {  
        if (device.position == AVCaptureDevicePositionFront)  
        {  
            captureDevice = device;  
            break;  
        }  
    }  
    
    //  couldn't find one on the front, so just get the default video device.  
    if ( ! captureDevice)  
    {  
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];  
    }  
    return captureDevice;  
}
- (AVCaptureDevice *)backCamera  
{  
    //  look at all the video devices and get the first one that's on the front  
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];  
    AVCaptureDevice *captureDevice = nil;  
    for (AVCaptureDevice *device in videoDevices)  
    {  
        if (device.position == AVCaptureDevicePositionBack)  
        {  
            captureDevice = device;  
            break;  
        }  
    }  
    
    //  couldn't find one on the front, so just get the default video device.  
    if ( ! captureDevice)  
    {  
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];  
    }  
    
    return captureDevice;  
}  

- (void)addStillImageOutput 
{
    [self setStillImageOutput:[[[AVCaptureStillImageOutput alloc] init] autorelease]];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { 
            break; 
        }
    }
    
    [[self captureSession] addOutput:[self stillImageOutput]];
}

- (void)captureStillImage
{  
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { 
            break; 
        }
	}
    
	NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection 
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) { 
                                                             if (error != nil) {
                                                                 NSLog(@"Error: %@", [error description]);
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kImageCaptureFailed object:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[error code]] forKey:@"code"]];
                                                                 // todo: this doesn't set the dictionary to userinfo
                                                                 return;
                                                             }
                                                             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                             if (exifAttachments) {
                                                                 NSLog(@"attachements: %@", exifAttachments);
                                                             } else { 
                                                                 NSLog(@"no attachments");
                                                             }
                                                             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];    
                                                             UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                             
                                                             [self setStillImage:image];
                                                             [image release];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
                                                         }];
}

- (void)dealloc {

	[[self captureSession] stopRunning];

	[previewLayer release], previewLayer = nil;
	[captureSession release], captureSession = nil;
    [stillImage release]; stillImage = nil;
    [stillImageOutput release]; stillImageOutput = nil;
	[super dealloc];
}

-(void)switchDevices {
    [captureSession beginConfiguration];
#if 0
    if (isFront) {
        if ([captureSession.inputs containsObject:videoInputFront])
            [captureSession removeInput:videoInputFront];
        [captureSession addInput:videoInputBack];
    }
    else {
        if ([captureSession.inputs containsObject:videoInputBack])
            [captureSession removeInput:videoInputBack];
        [captureSession addInput:videoInputFront];
    }
    isFront = !isFront;
#else
    isFront = !isFront;
    AVCaptureDevice *captureDevice;  
    if(isFront == true){  
        captureDevice = [self frontFacingCameraIfAvailable];  
    } else {  
        captureDevice = [self backCamera];  
        
    }  
    for (AVCaptureInput * oldInput in [captureSession inputs])
        [captureSession removeInput:oldInput];
    
    AVCaptureInput * captureInput = [AVCaptureDeviceInput   
                    deviceInputWithDevice:captureDevice   
                    error:nil];   
    [captureSession addInput:captureInput];
#endif
    [captureSession commitConfiguration];
}

-(int)toggleFlash {
//    [captureSession beginConfiguration];
    int oldFlashMode = flashMode;
    flashMode++;
    if (flashMode == 3)
        flashMode = 0;
    AVCaptureDevice * device = [[captureSession.inputs objectAtIndex:0] device];
    if ([device hasFlash]) {
        NSError * error;
        BOOL locked = [device lockForConfiguration:&error];
        if (locked) {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"ToggleFlash: Could not lock device for configuration: error %@", error.description);
            flashMode = oldFlashMode;
        }
    }
//    [captureSession commitConfiguration];
    return flashMode;
}

-(int)initializeCamera {
//    [self createVideoInputFront];
//    [self createVideoInputBack];
    [self addVideoPreviewLayer];
    [self addStillImageOutput];
    isFront = 1;
    flashMode = AVCaptureFlashModeOn; // 1
    [self switchDevices]; // set to front device / add to video input
    return [self toggleFlash]; // set to autoflash
}

-(int)getMirrored {
    NSLog(@"mirrored %d orientation %d", [previewLayer isMirrored]);
    return [previewLayer isMirrored];
}
@end
