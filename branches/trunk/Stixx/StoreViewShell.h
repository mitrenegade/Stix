//
//  StoreViewShell.h
//  Stixx
//
//  Created by Bobby Ren on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"

@interface StoreViewShell : UIViewController
{
    // a shell just to fill out the tb bar of the delegate
    
    // all these are sent through delegate
    UIViewController * lastController;
    UIImagePickerController * camera;
    StoreViewController * storeViewController;
}
@property (nonatomic, assign) UIViewController * lastController;
@property (nonatomic, assign) UIImagePickerController * camera; // for setting overlays
@property (nonatomic, assign) StoreViewController * storeViewController;
@end

