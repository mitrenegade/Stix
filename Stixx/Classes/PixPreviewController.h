//
//  PixPreviewController.h
//  Stixx
//
//  Created by Bobby Ren on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "LoadingAnimationView.h"
#import "GlobalHeaders.h"

@protocol PixPreviewDelegate

-(void)didConfirmPix;
-(void)didCancelPix;

@end

@interface PixPreviewController : UIViewController
{
    IBOutlet UIImageView * imageView;
	IBOutlet UIButton * buttonOK;
	IBOutlet UIButton * buttonCancel;
    IBOutlet UIImageView * aperture;
    LoadingAnimationView * activityIndicatorLarge;
    
    UIImage * image;

	NSObject<PixPreviewDelegate> *__unsafe_unretained delegate;
}

@property (nonatomic) IBOutlet UIImageView * imageView;
@property (nonatomic) IBOutlet UIButton * buttonOK;
@property (nonatomic) IBOutlet UIButton * buttonCancel;
@property (nonatomic, unsafe_unretained) NSObject<PixPreviewDelegate> *delegate;
@property (nonatomic) LoadingAnimationView * activityIndicatorLarge;
@property (nonatomic) UIImage * image;
@property (nonatomic) IBOutlet UIImageView * aperture;

-(IBAction)didClickOK:(id)sender;
-(IBAction)didClickBackButton:(id)sender;
-(void)initWithTag:(Tag*)tag;
-(void)startActivityIndicatorLarge;
-(void)stopActivityIndicatorLarge;
@end
