//
//  StoreViewShell.m
//  Stixx
//
//  Created by Bobby Ren on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreViewShell.h"

@implementation StoreViewShell

@synthesize lastController;
@synthesize storeViewController;
@synthesize camera;

-(id)init {
    self = [super initWithNibName:@"StoreViewShell" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"Mall"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_mystix.png"];
	[tbi setImage:i];
    lastController = nil;
    return self;   
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated {
    // hack a way to display view over camera; formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, 20, 320, 480);
    [storeViewController.view setFrame:frameShifted];
#if !TARGET_IPHONE_SIMULATOR
    [self.camera setCameraOverlayView:storeViewController.view];
#endif
}

@end
