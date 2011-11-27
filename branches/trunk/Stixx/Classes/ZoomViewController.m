//
//  ZoomViewController.m
//  Stixx
//
//  Created by Bobby Ren on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZoomViewController.h"

@implementation ZoomViewController

@synthesize imageView;
@synthesize labelComment;
@synthesize labelCommentBG;
@synthesize labelLocationString;
@synthesize delegate;
//@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)forceImageAppear:(UIImage*)img {
    [imageView setImage:img forState:UIControlStateNormal];
}
-(void)setLabel:(NSString *)label {
    [labelComment setText:label];
}
-(void)setLocation:(NSString *)location {
    [labelLocationString setText:location];
    if ([location length] == 0) {
        [labelLocationString setHidden:YES];
        CGRect newFrame = [labelCommentBG frame];
        newFrame.size.height = 51;
        [labelCommentBG setFrame:newFrame];
        [labelComment setFrame:newFrame];
    }
}

-(IBAction)didPressBackButton:(id)sender {
    [delegate didDismissZoom];
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

@end
