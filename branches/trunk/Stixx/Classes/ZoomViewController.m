//
//  ZoomViewController.m
//  Stixx
//
//  Created by Bobby Ren on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZoomViewController.h"

@implementation ZoomViewController

//@synthesize labelComment;
//@synthesize labelLocationString;
@synthesize delegate;
@synthesize stixView;

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
    [self.view setFrame:CGRectMake(160, 0, 320, 480)];
}

-(void)initStixView:(Tag*)tag {
    //NSLog(@"ZoomView: Creating stix view of size %f %f", tag.image.size.width, tag.image.size.height);
    
    CGRect frame = CGRectMake(3, 65, 314, 282);
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:YES];
    [stixView setIsPeelable:NO];
    [stixView initializeWithImage:tag.image];
    [stixView populateWithAuxStixFromTag:tag];
    [stixView setDelegate:self];
    [self.view addSubview:stixView];    
}

// StixViewDelegate
-(void)didTouchInStixView:(StixView *)stixViewTouched {
    //[stixView removeFromSuperview];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    //CGRect frameOffscreen = CGRectMake(3+320, 65, 314, 282);
    //animationID[1] = [animation doSlide:stixView inView:self.view toFrame:frameOffscreen forTime:.75];
    CGRect frameOffscreen = CGRectMake(3+320, 0, 320, 480);
    animationID[1] = [animation doSlide:self.view inView:self.view toFrame:frameOffscreen forTime:.5];
}

-(void)didFinishAnimation:(int)animID withCanvas:(UIView *)canvas {
    if (animID == animationID[1]) {
        [stixView release];
        [delegate didDismissZoom];
    }
}

//-(void)setLabel:(NSString *)label {
//    [labelComment setText:label];
//}

/*
-(IBAction)didPressBackButton:(id)sender {    
    [stixView removeFromSuperview];
    [stixView release];
    [delegate didDismissZoom];
}
 */

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
    
    //[imageView release];
    //[labelComment release];
    //[labelLocationString release];
    [stixView release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
