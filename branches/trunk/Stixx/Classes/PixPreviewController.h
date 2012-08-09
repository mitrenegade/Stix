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

@protocol PixPreviewDelegate

-(void)didConfirmPix;
-(void)didCancelPix;

@end

@interface PixPreviewController : UIViewController
{
    IBOutlet UIImageView * imageView;
	IBOutlet UIButton * buttonOK;
	IBOutlet UIButton * buttonCancel;
    LoadingAnimationView * activityIndicatorLarge;

	NSObject<PixPreviewDelegate> *__unsafe_unretained delegate;
}

@property (nonatomic) IBOutlet UIImageView * imageView;
@property (nonatomic) IBOutlet UIButton * buttonOK;
@property (nonatomic) IBOutlet UIButton * buttonCancel;
@property (nonatomic, unsafe_unretained) NSObject<PixPreviewDelegate> *delegate;
@property (nonatomic) LoadingAnimationView * activityIndicatorLarge;

-(IBAction)didClickOK:(id)sender;
-(IBAction)didClickBackButton:(id)sender;
-(void)initWithTag:(Tag*)tag;
-(void)startActivityIndicatorLarge;
-(void)stopActivityIndicatorLarge;
@end
