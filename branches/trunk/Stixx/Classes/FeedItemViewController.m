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

-(void)populateWithName:(NSString *)name andWithComment:(NSString *)comment andWithImage:(UIImage*)image {
    //NSLog(@"creating feedItemController with name %@ comment %@ image of size %f %f\n", name, comment, image.size.width, image.size.height);
    
    nameString = name;
    commentString = comment;
    imageData = image; //[image croppedImage:CGRectMake(5, 5, image.size.width-5, image.size.height-5)];
}

-(void)populateWithUserPhoto:(UIImage*)photo {
    if (photo){
        [userPhotoView setImage:photo];
    }
}

-(void)populateWithBadge:(int)type withCount:(int)count atLocationX:(int)x andLocationY:(int)y {
    UIImageView * stix = [[BadgeView getBadgeOfType:type] retain];
    float originX = x; //imageView.frame.origin.x + x;
    float originY = y + 20; // STATUS_BAR_SHIFT HACK //imageView.frame.origin.y + y;
    NSLog(@"Adding badge to %d %d in image of size %f %f", x, y, imageView.frame.size.width, imageView.frame.size.height);
    CGSize originalSize = imageData.size;
	CGSize targetSize = imageView.frame.size;
	
	float imageScale =  targetSize.width / originalSize.width;
    
	CGRect scaledFrameOverlay = stix.frame;
	scaledFrameOverlay.origin.x = originX * imageScale;
	scaledFrameOverlay.origin.y = originY * imageScale;
	scaledFrameOverlay.size.width = scaledFrameOverlay.size.width * imageScale;
	scaledFrameOverlay.size.height = scaledFrameOverlay.size.height * imageScale;

    NSLog(@"Scaling badge of %f %f in image %f %f down to %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, imageData.size.width, imageData.size.height, scaledFrameOverlay.size.width, scaledFrameOverlay.size.height, imageView.frame.size.width, imageView.frame.size.height); 

    [stix setFrame:scaledFrameOverlay];
    CGRect stixFrame = CGRectMake(scaledFrameOverlay.origin.x+10, scaledFrameOverlay.origin.y+25, 20, 20);
    OutlineLabel * stixCount = [[OutlineLabel alloc] initWithFrame:stixFrame];
    [stixCount drawTextInRect:CGRectMake(0,0, stixFrame.size.width, stixFrame.size.height)];
    [stixCount setText:[NSString stringWithFormat:@"%d", count]];
    [imageView addSubview:stix];
    [imageView addSubview:stixCount];
    
    [stix release];
    [stixCount release];
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
        unit = @"< 1 min ago";
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
    [labelComment setText:commentString];
    [imageView setImage:imageData];
    
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
