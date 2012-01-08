//
//  FeedItemViewController.m
//  ARKitDemo
//
//  Created by Administrator on 9/13/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "FeedItemViewController.h"

@implementation FeedItemViewController


@synthesize labelName;
@synthesize labelComment;
@synthesize labelDescriptor;
@synthesize labelTime;
@synthesize labelDescriptorBG;
@synthesize labelLocationString;
@synthesize imageView;
@synthesize nameString, commentString, imageData;
@synthesize userPhotoView;
@synthesize addCommentButton;
@synthesize tagID;
@synthesize delegate;
@synthesize commentCount;
@synthesize stixView;
@synthesize locationIcon;
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

-(id)init
{
	// call superclass's initializer
	self = [super initWithNibName:@"FeedItemViewController" bundle:nil];
    
    //nameString = [NSString alloc];
    //commentString = [NSString alloc];
    //imageData = [UIImage alloc];
    
    return self;
}

-(void)populateWithName:(NSString *)name andWithDescriptor:(NSString *)descriptor andWithComment:(NSString *)comment andWithLocationString:(NSString*)location {// andWithImage:(UIImage*)image {
    //NSLog(@"--PopulateWithName: %@ descriptor %@ comment %@ location %@ image of size %f %f\n", name, descriptor, comment, location, image.size.width, image.size.height);
    
    nameString = name;
    descriptorString = descriptor;
    commentString = comment;
    if (descriptor == nil || [descriptor length] == 0) {
        descriptorString = comment;
        commentString = nil;
    }
    //imageData = image;
    locationString = location;
}

-(void)populateWithUserPhoto:(UIImage*)photo {
    if (photo){
        [userPhotoView setImage:photo];
        [userPhotoView setBackgroundColor:[UIColor blackColor]];
    }
}

-(void)initStixView:(Tag*)tag {
    imageData = tag.image;
    NSString * myStixStringID = tag.stixStringID;
    int count = tag.badgeCount;
    float centerX = tag.badge_x;
    float centerY = tag.badge_y;
    
    NSLog(@"AuxStix: Creating stix view of size %f %f, with badge at %f %f", imageData.size.width, imageData.size.height, centerX, centerY);
    
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView initializeWithImage:imageData andStix:myStixStringID withCount:count atLocationX:centerX andLocationY:centerY];
    [stixView populateWithAuxStix:tag.auxStixStringIDs withLocations:tag.auxLocations withScales:tag.auxScales withRotations:tag.auxRotations];
    [self.view insertSubview:stixView belowSubview:imageView];
    [stixView setInteractionAllowed:NO]; // no dragging of stix already in stixView
    
}

/*
-(void)populateWithBadge:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y {
#if 0
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView initializeWithImage:imageData andStix:stixStringID withCount:count atLocationX:x andLocationY:y];
    [self.view addSubview:stixView];
#else
    UIImageView * stix = [BadgeView getBadgeWithStixStringID:stixStringID];
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float centerX = x;
    float centerY = y;
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = imageData.size;
	CGSize targetSize = imageView.frame.size;
	
	float imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    centerX *= imageScale;
    centerY *= imageScale;
    NSLog(@"FeedItemView: Scaling badge of %f %f at %f %f in image %f %f down to %f %f at %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, centerX / imageScale, centerY / imageScale, imageData.size.width, imageData.size.height, stixFrameScaled.size.width, stixFrameScaled.size.height, centerX, centerY, imageView.frame.size.width, imageView.frame.size.height); 
    [stix setFrame:stixFrameScaled];
    [stix setCenter:CGPointMake(centerX, centerY)];
    [imageView addSubview:stix];
    
    if ([stixStringID isEqualToString:@"FIRE"] || [stixStringID isEqualToString:@"ICE"]) {
        
        CGRect labelFrame = stix.frame;
        OutlineLabel * stixCount = [[OutlineLabel alloc] initWithFrame:labelFrame];
        [stixCount setCenter:CGPointMake(stixCount.center.x+[BadgeView getOutlineOffsetX:0], stixCount.center.y+[BadgeView getOutlineOffsetY:0])];
        labelFrame = stixCount.frame; // changing center should change origin but not width
        //[stixCount setFont:[UIFont fontWithName:@"Helvetica Bold" size:5]]; does nothing
        if ([stixStringID isEqualToString:@"FIRE"])
            [stixCount setTextAttributesForBadgeType:0];
        if ([stixStringID isEqualToString:@"ICE"])
            [stixCount setTextAttributesForBadgeType:1];
        [stixCount drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
        [stixCount setText:[NSString stringWithFormat:@"%d", count]];
        [imageView addSubview:stixCount];
        [stixCount release];
    }
#endif
}
*/

-(void)populateWithTimestamp:(NSDate *)timestamp {
    // format timestring
    // from 1 min - 1 hour, display # of minutes since tag
    // from 1 hr to 24 hour, display # of hours since tag
    // beyond that, display date of timestamp
    // format is: 2011-10-27 06:09:28
    
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate * timestamp = [dateFormatter dateFromString:tmp]; //timestring];
    NSDate * now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:timestamp]; // interval is a float of total seconds
    
    int num;
    NSString * unit;
    if (interval < 60)
    {
        //num = (int) interval;
        //unit = @"sec ago";
        num = 0;
        unit = @"Just now";
    }
    else if (interval < 3600)
    {
        num = interval / 60;
        if (num == 1)
            unit = @"min ago";
        else
            unit = @"mins ago";
    }
    else if (interval < 86400)
    {
        num = interval / 3600;
        if (num == 1)
            unit = @"hour ago";
        else
            unit = @"hours ago";
    }
    else //if (interval >= 86400)
    {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"MMM dd"]; //NSDateFormatterShortStyle];
        unit = [dateFormatter stringFromDate:timestamp];
        num = 0;
    }
    
    if (num > 0)
        [labelTime setText:[NSString stringWithFormat:@"%d %@", num, unit]];
    else
        [labelTime setText:[NSString stringWithFormat:@"%@", unit]];
} 

-(void)populateWithCommentCount:(int)count {
    self.commentCount = count;
    if (count == 0)
        [addCommentButton setTitle:[NSString stringWithFormat:@"Add comment", commentCount] forState:UIControlStateNormal];
    else if (count == 1)
        [addCommentButton setTitle:[NSString stringWithFormat:@"%d comment", commentCount] forState:UIControlStateNormal];
    else        
        [addCommentButton setTitle:[NSString stringWithFormat:@"%d comments", commentCount] forState:UIControlStateNormal];
}

- (void)dealloc
{
    [super dealloc];
}

-(IBAction)didPressAddCommentButton:(id)sender {
    [self.delegate displayCommentsOfTag:tagID andName:nameString];
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
    [labelName setText:[NSString stringWithFormat:@"%@", nameString]];
    UIColor * textColor = [UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1.0];
    [labelDescriptor setTextColor:textColor];
    [labelDescriptor setText:descriptorString];
    [labelComment setText:commentString];
    [imageView setImage:imageData];
    [labelLocationString setText:locationString];
    if ([commentString length] == 0) {
        [labelDescriptor setFrame:CGRectMake(labelDescriptor.frame.origin.x, labelDescriptor.frame.origin.y, labelDescriptor.frame.size.width, 46)]; // combined heights
        [labelDescriptorBG setFrame:CGRectMake(labelDescriptorBG.frame.origin.x, labelDescriptorBG.frame.origin.y, labelDescriptorBG.frame.size.width, 46)];
        [labelComment setHidden:YES];
    }
    if ([locationString length] == 0)
        [locationIcon setHidden:YES];
    //NSLog(@"Loading feed item with name %@ comment %@ and imageView %f %f with image Data size %f %f", labelName.text, labelDescriptor.text, imageView.frame.size.width, imageView.frame.size.height, imageData.size.width, imageData.size.height);
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
