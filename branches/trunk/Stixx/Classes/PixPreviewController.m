//
//  PixPreviewController.m
//  Stixx
//
//  Created by Bobby Ren on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PixPreviewController.h"

@implementation PixPreviewController

@synthesize buttonOK, buttonCancel, imageView;
@synthesize delegate;
@synthesize activityIndicatorLarge;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (activityIndicatorLarge)
//        [activityIndicatorLarge stopCompleteAnimation];
        [activityIndicatorLarge removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initWithTag:(Tag*)tag {
    UIImage * imageData = tag.image;
    [imageView setImage:imageData];
}

-(IBAction)didClickOK:(id)sender {
    NSLog(@"PixPreview did click ok **************");
    if (!activityIndicatorLarge) {
        activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
        [self.view addSubview:activityIndicatorLarge];
    }
    [activityIndicatorLarge startCompleteAnimation];
    [delegate performSelector:@selector(didConfirmPix) withObject:delegate afterDelay:0];
    //[delegate didConfirmPix];
}

-(IBAction)didClickCancel:(id)sender {
    [delegate didCancelPix];
}

-(void)startActivityIndicatorLarge {
    [activityIndicatorLarge startCompleteAnimation];
}
-(void)stopActivityIndicatorLarge {
    [activityIndicatorLarge stopCompleteAnimation];
}
@end
