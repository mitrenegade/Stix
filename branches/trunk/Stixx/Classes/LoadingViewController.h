//
//  LoadingViewController.h
//  Stixx
//
//  Created by Bobby Ren on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"

@interface LoadingViewController : UIViewController
{
    IBOutlet UITextField * loadingMessage;
    LoadingAnimationView * activityIndicator;
    UIView * mySuperView;
}

@property (nonatomic, retain) IBOutlet UITextField * loadingMessage;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, assign) UIView * mySuperView;
-(void)setMessage:(NSString*)message;

@end
