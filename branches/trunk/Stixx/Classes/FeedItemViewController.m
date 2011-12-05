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
@synthesize labelTime;
@synthesize labelCommentBG;
@synthesize labelLocationString;
@synthesize imageView;
@synthesize nameString, commentString, imageData;
@synthesize userPhotoView;

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
	[super initWithNibName:@"FeedItemViewController" bundle:nil];
    
    //nameString = [NSString alloc];
    //commentString = [NSString alloc];
    //imageData = [UIImage alloc];
    
    return self;
}

-(void)populateWithName:(NSString *)name andWithComment:(NSString *)comment andWithLocationString:(NSString*)location andWithImage:(UIImage*)image {
    //NSLog(@"creating feedItemController with name %@ comment %@ image of size %f %f\n", name, comment, image.size.width, image.size.height);
    
    nameString = name;
    commentString = comment;
    imageData = image; //[image croppedImage:CGRectMake(5, 5, image.size.width-5, image.size.height-5)];
    locationString = location;
}

-(void)populateWithUserPhoto:(UIImage*)photo {
    if (photo){
        [userPhotoView setImage:photo];
        [userPhotoView setBackgroundColor:[UIColor blackColor]];
    }
}

-(void)populateWithBadge:(int)type withCount:(int)count atLocationX:(int)x andLocationY:(int)y {
    UIImageView * stix = [[BadgeView getBadgeOfType:type] retain];
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float originX = x;
    float originY = y;
    NSLog(@"Adding badge to %d %d in image of size %f %f", x, y, imageView.frame.size.width, imageView.frame.size.height);
    stix.frame = CGRectMake(originX, originY, stix.frame.size.width, stix.frame.size.height);
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = imageData.size;
	CGSize targetSize = imageView.frame.size;
	
	float imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    NSLog(@"Scaling badge of %f %f in image %f %f down to %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, imageData.size.width, imageData.size.height, stixFrameScaled.size.width, stixFrameScaled.size.height, imageView.frame.size.width, imageView.frame.size.height); 
    [stix setFrame:stixFrameScaled];
    [imageView addSubview:stix];
    
    if (type == BADGE_TYPE_FIRE || type == BADGE_TYPE_ICE) {
        
        CGRect labelFrame = stix.frame;
        OutlineLabel * stixCount = [[OutlineLabel alloc] initWithFrame:labelFrame];
        stixCount.center = CGPointMake(stixCount.center.x + [BadgeView getOutlineOffsetX:type] * imageScale, stixCount.center.y + [BadgeView getOutlineOffsetY:type] * imageScale);
        labelFrame = stixCount.frame; // changing center should change origin but not width
        //[stixCount setFont:[UIFont fontWithName:@"Helvetica Bold" size:5]]; does nothing
        [stixCount setTextAttributesForBadgeType:type];
        [stixCount drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
        [stixCount setText:[NSString stringWithFormat:@"%d", count]];
        [imageView addSubview:stixCount];
        [stixCount release];
    }    
    [stix release];
}

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

- (void)dealloc
{
    [super dealloc];
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
    [labelComment setTextColor:textColor];
    [labelComment setText:commentString];
    [imageView setImage:imageData];
    [labelLocationString setText:locationString];
    if ([locationString length] == 0) {
        [labelComment setFrame:CGRectMake(labelComment.frame.origin.x, labelComment.frame.origin.y, labelComment.frame.size.width, 46)]; // combined heights
        [labelCommentBG setFrame:CGRectMake(labelCommentBG.frame.origin.x, labelCommentBG.frame.origin.y, labelCommentBG.frame.size.width, 46)];
        [labelLocationString setHidden:YES];
    }
    //NSLog(@"Loading feed item with name %@ comment %@ and imageView %f %f with image Data size %f %f", labelName.text, labelComment.text, imageView.frame.size.width, imageView.frame.size.height, imageData.size.width, imageData.size.height);
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
