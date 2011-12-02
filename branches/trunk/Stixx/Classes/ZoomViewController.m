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
@synthesize stix;
@synthesize stixCount;
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
-(void)setStixUsingTag:(Tag *) tag {
    float item_width = imageView.frame.size.width;
    float item_height = imageView.frame.size.height;
    
     stix = [[BadgeView getBadgeOfType:tag.badgeType] retain];
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float originX = tag.badge_x;
    float originY = tag.badge_y;
    NSLog(@"Adding badge to %d %d in image of size %f %f", tag.badge_x, tag.badge_y, item_width, item_height);
    stix.frame = CGRectMake(originX, originY, stix.frame.size.width, stix.frame.size.height);
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = CGSizeMake(300, 300);
	CGSize targetSize = CGSizeMake(item_width, item_height);
	
	float imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    NSLog(@"Scaling badge of %f %f in image %f %f down to %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, 300.0, 300.0, stixFrameScaled.size.width, stixFrameScaled.size.height, item_width, item_height); 
    [stix setFrame:stixFrameScaled];
    
    CGRect labelFrame = stix.frame;
    stixCount = [[OutlineLabel alloc] initWithFrame:labelFrame];
    stixCount.center = CGPointMake(stixCount.center.x + OUTLINELABEL_X_OFFSET * imageScale, stixCount.center.y + OUTLINELABEL_Y_OFFSET * imageScale);
    labelFrame = stixCount.frame; // changing center should change origin but not width
    //[stixCount setFont:[UIFont fontWithName:@"Helvetica Bold" size:5]]; does nothing
    [stixCount setTextAttributesForBadgeType:tag.badgeType];
    [stixCount drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
    [stixCount setText:[NSString stringWithFormat:@"%d", tag.badgeCount]];
    [imageView addSubview:stix];
    [imageView addSubview:stixCount];

    // do not release stix
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
    [self.stix removeFromSuperview];
    [stix release];
    [self.stixCount removeFromSuperview];
    [stixCount release];
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
    [labelCommentBG release];
    [labelLocationString release];
    [stix release];
    [stixCount release];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
