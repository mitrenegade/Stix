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
//@synthesize labelCommentBG;
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

-(void)initStixView:(Tag*)tag {
    NSString * myStixStringID = tag.stixStringID;
    int count = tag.badgeCount;
    float centerX = tag.badge_x;
    float centerY = tag.badge_y;
    float scale = tag.stixScale;
    float rotation = tag.stixRotation;
    
    // hack: backwards compatibility
    if (scale == 0)
        scale = 1;
    
    NSLog(@"AuxStix: Creating stix view of size %f %f, with badge at %f %f", tag.image.size.width, tag.image.size.height, centerX, centerY);
    
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:NO];
    [stixView setIsPeelable:NO];
    [stixView initializeWithImage:tag.image andStix:myStixStringID withCount:count atLocationX:centerX andLocationY:centerY andScale:scale andRotation:rotation];
    [stixView populateWithAuxStixFromTag:tag];
    [self.view insertSubview:stixView belowSubview:imageView];    
}

-(void)setStixUsingTag:(Tag *) tag {
    
#if 1
    [self initStixView:tag];
#else
    float item_width = imageView.frame.size.width;
    float item_height = imageView.frame.size.height;
    
    stix = [BadgeView getBadgeWithStixStringID:tag.stixStringID];
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
/*
-(void)setLocation:(NSString *)location {
    [labelLocationString setText:location];
    if ([location length] == 0) {
        //[labelLocationString setHidden:YES];
        //CGRect newFrame = [labelCommentBG frame];
        //newFrame.size.height = 51;
        //[labelCommentBG setFrame:newFrame];
        //[labelComment setFrame:newFrame];
    }
    else {
        [labelLocationString setHidden:NO];
        //CGRect newFrame = [labelCommentBG frame];
        //newFrame.size.height = 29;
        //[labelCommentBG setFrame:newFrame];        
        //[labelComment setFrame:newFrame];
    }
}
*/

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
    //[labelCommentBG release];
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
