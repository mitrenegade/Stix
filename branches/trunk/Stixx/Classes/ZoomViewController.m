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
@synthesize labelLocationString;
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
}

-(void)initStixView:(Tag*)tag {
    //NSLog(@"ZoomView: Creating stix view of size %f %f", tag.image.size.width, tag.image.size.height);
    
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:NO];
    [stixView setIsPeelable:NO];
    [stixView initializeWithImage:tag.image];
    [stixView populateWithAuxStixFromTag:tag];
    [self.view insertSubview:stixView belowSubview:imageView];    
}

-(void)setStixUsingTag:(Tag *) tag {
    
#if 1
    [self initStixView:tag];
#else
    float item_width = imageView.frame.size.width;
    float item_height = imageView.frame.size.height;
    
    stix = [[BadgeView getBadgeWithStixStringID:tag.stixStringID] retain];
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float centerX = tag.badge_x;
    float centerY = tag.badge_y;
    NSLog(@"Adding badge to %d %d in image of size %f %f", tag.badge_x, tag.badge_y, item_width, item_height);
    stix.frame = CGRectMake(0, 0, stix.frame.size.width, stix.frame.size.height);
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = CGSizeMake(300, 300);
	CGSize targetSize = CGSizeMake(item_width, item_height);
	
	float imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    centerX *= imageScale;
    centerY *= imageScale;
    NSLog(@"Scaling badge of %f %f in image %f %f down to %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, 300.0, 300.0, stixFrameScaled.size.width, stixFrameScaled.size.height, item_width, item_height); 
    [stix setFrame:stixFrameScaled];
    [stix setCenter:CGPointMake(centerX, centerY)];
    [imageView addSubview:stix];
    
    if ([tag.stixStringID isEqualToString:@"FIRE"] || [tag.stixStringID isEqualToString:@"ICE"]) {
        CGRect labelFrame = stix.frame;
        stixCount = [[OutlineLabel alloc] initWithFrame:labelFrame];
        labelFrame = stixCount.frame; // changing center should change origin but not width
        //[stixCount setFont:[UIFont fontWithName:@"Helvetica Bold" size:5]]; does nothing
        [stixCount setTextAttributesForBadgeType:([tag.stixStringID isEqualToString:@"FIRE"]?0:1)];
        [stixCount drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
        [stixCount setText:[NSString stringWithFormat:@"%d", tag.badgeCount]];
        [imageView addSubview:stixCount];
    }
    // do not release stix or stixCount
#endif
}

-(void)forceImageAppear:(UIImage*)img {
    [imageView setImage:img forState:UIControlStateNormal];
}
-(void)setLabel:(NSString *)label {
    [labelComment setText:label];
}

-(IBAction)didPressBackButton:(id)sender {    
    for (int i=0; i<[[stixView auxStixViews] count]; i++)
        [[[stixView auxStixViews] objectAtIndex:i] removeFromSuperview];
    [self.view removeFromSuperview];
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
    
    [imageView release];
    [labelComment release];
    [labelLocationString release];
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
