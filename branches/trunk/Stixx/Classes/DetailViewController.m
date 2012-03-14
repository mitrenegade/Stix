//
//  DetailViewController.m
//  Stixx
//
//  Created by Bobby Ren on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

//@synthesize labelComment;
//@synthesize labelLocationString;
@synthesize delegate;
@synthesize stixView;
@synthesize activityIndicator;
@synthesize logo;

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

-(void)initDetailViewWithTag:(Tag*)tag {
    //NSLog(@"DetailView: Creating stix view of size %f %f", tag.image.size.width, tag.image.size.height);
    
    //CGRect frame = CGRectMake(3, 65, 314, 282);
    CGRect frame = CGRectMake(3, 3, 314, 282);
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:YES];
    [stixView setIsPeelable:NO];
    [stixView initializeWithImage:tag.image];
    [stixView populateWithAuxStixFromTag:tag];
    [stixView setDelegate:self];
    //[self.view addSubview:stixView];    
    tagID = [tag.tagID intValue];
    
    [self headerFromTag:tag];
}

// StixViewDelegate
-(void)didTouchInStixView:(StixView *)stixViewTouched {
    /*
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = CGRectMake(3+320, 0, 320, 480);
    animationID[1] = [animation doSlide:self.view inView:self.view toFrame:frameOffscreen forTime:.5];
     */
}

-(void)didFinishAnimation:(int)animID withCanvas:(UIView *)canvas {
    if (animID == animationID[1]) {
        [stixView release];
        [delegate didDismissZoom];
    }
}

-(void)startActivityIndicator {
    [logo setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    [logo setHidden:NO];
}

/*** commentFeedTableDelegate ***/

-(NSString* )getNameForIndex:(int)index {
    return [names objectAtIndex:index];
}

-(NSString *)getCommentForIndex:(int)index {
    return [comments objectAtIndex:index];
}

-(NSString*)getStixStringIDForIndex:(int)index {
    NSString* type = [stixStringIDs objectAtIndex:index];
    if ([type length] == 0) 
        type = @"COMMENT";
    return type;
}

-(int)getCount {
    return [names count];
}

-(IBAction)didPressBackButton:(id)sender {    
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = CGRectMake(3+320, 0, 320, 480);
    animationID[1] = [animation doSlide:self.view inView:self.view toFrame:frameOffscreen forTime:.5];
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
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,46 + headerView.frame.size.height,320,340)];
    [self.view addSubview:scrollView];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.directionalLockEnabled = NO; // only allow vertical or horizontal scroll
    //[scrollView setDelegate:self];
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(150, 11, 25, 25)];
    
    if (names)
        [names release];
    if (comments)
        [comments release];
    if (stixStringIDs)
        [stixStringIDs release];
    names = [[NSMutableArray alloc] init];
    comments = [[NSMutableArray alloc] init];
    stixStringIDs = [[NSMutableArray alloc] init];
    
    if (commentsTable)
    {
        [commentsTable.view removeFromSuperview];
        [commentsTable release];
    }
    commentsTable = [[CommentFeedTableController alloc] init];
    [commentsTable.view setFrame:CGRectMake(0, 290, 320, 280)];
    [commentsTable setDelegate:self];
    
    [self.view addSubview:headerView];
    [scrollView setContentSize:CGSizeMake(320, stixView.frame.size.height + commentsTable.view.frame.size.height + 5)];
    [scrollView addSubview:stixView];
    [scrollView addSubview:commentsTable.view];
    
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    [k getAllHistoryWithTagID:tagID];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllHistoryDidCompleteWithResult:(NSArray*)theResults {
    
    for (NSMutableDictionary * d in theResults) {        
        NSString * name = [d valueForKey:@"username"];
        NSString * comment = [d valueForKey:@"comment"];
        NSString * stixStringID = [d valueForKey:@"stixStringID"];
        if ([stixStringID length] == 0)
        {
            // backwards compatibility
            stixStringID = @"COMMENT";
        }
        
        [names addObject:name];
        [comments addObject:comment];
        [stixStringIDs addObject:stixStringID];
    }
    [commentsTable.tableView reloadData];

    // resize scrollview
    [commentsTable.view setFrame:CGRectMake(0, 290, 320, 70 * [names count])];
    [scrollView setContentSize:CGSizeMake(320, stixView.frame.size.height + commentsTable.view.frame.size.height + 5)];
    [self stopActivityIndicator];
}

-(void)headerFromTag:(Tag*) tag{
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 40)];
    [headerView setBackgroundColor:[UIColor blackColor]];
    [headerView setAlpha:.75];
    
    UIImage * photo = [self.delegate getUserPhotoForUsername:tag.username];
    UIImageView * photoView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
    [photoView setImage:photo];
    [headerView addSubview:photoView];
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 260, 30)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setTextColor:[UIColor whiteColor]];
    [nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [nameLabel setText:tag.username];
    [headerView addSubview:nameLabel];
    
    UILabel * locLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 25, 260, 15)];
    [locLabel setBackgroundColor:[UIColor clearColor]];
    [locLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0 alpha:1]];
    [locLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    [locLabel setText:tag.locationString];
    [headerView addSubview:locLabel];    
    
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 5, 60, 20)];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor whiteColor]];
    [timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:9]];
    [timeLabel setText:[Tag getTimeLabelFromTimestamp:tag.timestamp]];
    [headerView addSubview:timeLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //[imageView release];
    //[labelComment release];
    //[labelLocationString release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [scrollView release];
    [commentsTable release];
    [stixView release];
    [headerView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
