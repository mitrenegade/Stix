//
//  PreviewLoginViewController.h
//  Stixx
//
//  Created by Bobby Ren on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreviewLoginDelegate <NSObject>

-(void)didCancelLogin;
-(void)doFacebookLogin;
-(void)doTwitterLogin;
-(void)doEmailSignup;
@end

@interface PreviewLoginViewController : UIViewController
{
    NSObject<PreviewLoginDelegate> * __unsafe_unretained delegate;
}
@property (nonatomic, unsafe_unretained) NSObject<PreviewLoginDelegate> * delegate;
-(IBAction)didClickFacebook:(id)sender;
-(IBAction)didClickTwitter:(id)sender;
-(IBAction)didClickEmail:(id)sender;
-(IBAction)didClickCancelLogin:(id)sender;
-(IBAction)didClickEmail:(id)sender;
@end

