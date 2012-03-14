//
//  VerticalFeedItemController.m
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//
//  VerticalFeedItemController.m
//  ARKitDemo
//
//  Created by Administrator on 9/13/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "VerticalFeedItemController.h"

@implementation VerticalFeedItemController

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
@synthesize shareButton;
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
	self = [super initWithNibName:@"VerticalFeedItemController" bundle:nil];
    
    //nameString = [NSString alloc];
    //commentString = [NSString alloc];
    //imageData = [UIImage alloc];
    
    return self;
}

-(void)populateWithName:(NSString *)name andWithDescriptor:(NSString *)descriptor andWithComment:(NSString *)comment andWithLocationString:(NSString*)location {// andWithImage:(UIImage*)image {
    NSLog(@"--PopulateWithName: %@ descriptor %@ comment %@ location %@\n", name, descriptor, comment, location);
    
    nameString = name;
    descriptorString = descriptor;
    commentString = comment;
    if (descriptor == nil || [descriptor length] == 0) {
        if (comment == nil || [comment length] == 0) {
            [labelDescriptorBG setHidden:YES];
            descriptorString = nil;
            commentString = nil;
        } 
        else {
            descriptorString = comment;
            commentString = nil;
        }
    }
    //imageData = image;
    locationString = location;
}

-(void)populateWithUserPhoto:(UIImage*)photo {
    if (photo){
        [photo retain];
        [userPhotoView setImage:photo];
        [userPhotoView setBackgroundColor:[UIColor blackColor]];
        [photo release];
    }
}

-(void)initStixView:(Tag*)tag {
    imageData = tag.image;
    
    //NSLog(@"VerticalFeedItem: Creating stix view of size %f %f", imageData.size.width, imageData.size.height);
    
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:NO];
    [stixView setIsPeelable:YES];
    [stixView setDelegate:self];
    [stixView initializeWithImage:imageData];
    [stixView populateWithAuxStixFromTag:tag];
    [self.view insertSubview:stixView belowSubview:imageView];
    //[stixView setInteractionAllowed:NO]; // no dragging of stix already in stixView
    
}

+(NSString*) getTimeLabelFromTimestamp:(NSDate*) timestamp {
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
    
    NSString * timeLabel;
    if (num > 0)
        timeLabel = [NSString stringWithFormat:@"%d %@", num, unit];
    else
        timeLabel = [NSString stringWithFormat:@"%@", unit];
    return timeLabel;
}

-(void)populateWithTimestamp:(NSDate *)timestamp {    
    [labelTime setText:[VerticalFeedItemController getTimeLabelFromTimestamp:timestamp]];
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

-(IBAction)didPressShareButton:(id)sender {
    [self.delegate sharePix:tagID];
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
        if ([descriptorString length] != 0) {
            [labelDescriptor setFrame:CGRectMake(labelDescriptor.frame.origin.x, labelDescriptor.frame.origin.y, labelDescriptor.frame.size.width, 46)]; // combined heights
            //[labelDescriptorBG setFrame:CGRectMake(labelDescriptorBG.frame.origin.x, labelDescriptorBG.frame.origin.y, labelDescriptorBG.frame.size.width, 46)];
            [labelComment setHidden:YES];
        }
        else {
            [labelDescriptor setHidden:YES];
            [labelComment setHidden:YES];
            [labelDescriptorBG setHidden:YES];
        }
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

/* StixViewDelegate */
-(NSString*)getUsername {
    return [self.delegate getUsername];
}

-(void)didAttachStix:(int)index {
    // 1 = attach
    [self.delegate didPerformPeelableAction:1 forAuxStix:index];
}

-(void)didPeelStix:(int)index {
    // 0 = peel
    // show peel animation
    [stixView doPeelAnimationForStix:index];
}

-(void)peelAnimationDidCompleteForStix:(int)index {
    [self.delegate didPerformPeelableAction:0 forAuxStix:index];
}


/******** process clicks *******/
/*
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	int drag = 0;    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	int drag = 1;
}
 */
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//if (drag != 1)
	{
        UITouch *touch = [[event allTouches] anyObject];	
        CGPoint location = [touch locationInView:self.view];
        [self.delegate didClickAtLocation:location withFeedItem:self];
    }
}

@end
