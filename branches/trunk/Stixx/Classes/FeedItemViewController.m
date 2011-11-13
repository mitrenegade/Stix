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
        num = (int) interval;
        unit = @"sec ago";
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
    
    NSLog(@"Loading feed item with name %@ comment %@", labelName.text, labelComment.text);
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
