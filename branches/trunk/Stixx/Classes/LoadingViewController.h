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
    UIView * __weak mySuperView;
}

@property (nonatomic) IBOutlet UITextField * loadingMessage;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic, weak) UIView * mySuperView;
-(void)setMessage:(NSString*)message;

@end
