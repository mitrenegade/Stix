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
@synthesize tagUsername;
@synthesize commentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    feedItem = nil;
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view setFrame:CGRectMake(160, 0, 320, 480)];
}

-(void)initDetailViewWithTag:(Tag*)tag {
    //NSLog(@"DetailView: Creating stix view of size %f %f", tag.image.size.width, tag.image.size.height);
    
    tagID = [tag.tagID intValue];
#if 0
    CGRect frame = CGRectMake(3, 3, 314, 282);
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:YES];
    [stixView setIsPeelable:NO];
    [stixView initializeWithImage:tag.image];
    [stixView populateWithAuxStixFromTag:tag];
    [stixView setDelegate:self];
    //[self.view addSubview:stixView];    
#else
    [self initFeedItemWithTag:tag];
#endif
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
        //[stixView release];
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

-(NSString*)getTimestampStringForIndex:(int)index {
    NSDate * date = [timestamps objectAtIndex:index];
    NSString * timeStampString = [Tag getTimeLabelFromTimestamp:date];
    return timeStampString;
}

-(UIImage *)getPhotoForIndex:(int)index {
    return [self.delegate getUserPhotoForUsername:[names objectAtIndex:index]]; //[photos objectForKey:[names objectAtIndex:index]];
}

-(UIImage *)getUserPhotoForUsername:(NSString *)username {
    return [self.delegate getUserPhotoForUsername:username];
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
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,46 + headerView.frame.size.height,320,320)];
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
    if (timestamps)
        [timestamps release];
    //if (photos)
        //[photos release];
    
    names = [[NSMutableArray alloc] init];
    comments = [[NSMutableArray alloc] init];
    stixStringIDs = [[NSMutableArray alloc] init];
    timestamps = [[NSMutableArray alloc] init];
    //photos = [[NSMutableDictionary alloc] init];
    
    [self.view addSubview:headerView];

    if (commentsTable)
    {
        [commentsTable.view removeFromSuperview];
        [commentsTable release];
    }
    commentsTable = [[CommentFeedTableController alloc] init];
    [commentsTable.view setFrame:CGRectMake(0, feedItem.view.frame.size.height, 320, 0)];
    [commentsTable setDelegate:self];
    //[commentsTable configureRowsWithHeight:18 dividerVisible:NO fontSize:12 fontNameColor:[UIColor colorWithRed:153/255.0 green:51.0/255.0 blue:0.0 alpha:1.0] fontTextColor:[UIColor blackColor]];
    
#if 0
    [scrollView setContentSize:CGSizeMake(320, stixView.frame.size.height + commentsTable.view.frame.size.height + 5)];
    [scrollView addSubview:stixView];
    [scrollView addSubview:commentsTable.view];
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    [k getAllHistoryWithTagID:tagID];
#else
    NSLog(@"DetailView: header start %f height %f feedItem start %f height %f commentsTable start %f height %f scrollView start %f height %f", headerView.frame.origin.y, headerView.frame.size.height, feedItem.view.frame.origin.y, feedItem.view.frame.size.height, commentsTable.view.frame.origin.y, commentsTable.view.frame.size.height, scrollView.frame.origin.y, scrollView.frame.size.height);
    int feedHeight = feedItem.view.frame.size.height;
    int tableHeight = commentsTable.rowHeight * [names count];
    NSLog(@"DetailView: Setting scroll contentSize to %d %d", 320, feedHeight+ tableHeight+5);
    [scrollView setContentSize:CGSizeMake(320, feedHeight + tableHeight + 5)];
    [scrollView addSubview:feedItem.view];
    [scrollView addSubview:commentsTable.view];
#endif
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllHistoryDidCompleteWithResult:(NSArray*)theResults {
    
    //NSNumber * tagID;
    trueCommentCount = 0;
    for (NSMutableDictionary * d in theResults) {    
        tagID = [[d valueForKey:@"tagID"] intValue];
        NSString * name = [d valueForKey:@"username"];
        NSString * comment = [d valueForKey:@"comment"];
        NSString * stixStringID = [d valueForKey:@"stixStringID"];
        NSDate * timestamp = [d valueForKey:@"timeCreated"];
        if ([stixStringID length] == 0)
        {
            // backwards compatibility
            stixStringID = @"COMMENT";
        }
        
        if ([stixStringID isEqualToString:@"COMMENT"])
            trueCommentCount++;
#if SHOW_COMMENTS_ONLY
        if (![stixStringID isEqualToString:@"COMMENT"])
            continue;
#endif
        [names addObject:name];
        [comments addObject:comment];
        [stixStringIDs addObject:stixStringID];
        [timestamps addObject:timestamp];
        //[photos setObject:[self.delegate getUserPhotoForUsername:name] forKey:name];
    }
    [commentsTable.tableView reloadData];
    
    NSLog(@"DetailView: getAllHistoryDidComplete for tag %d", tagID);
    NSLog(@"DetailView: loaded %d displayable comments", [names count]);

    // resize scrollview
    int feedHeight = feedItem.view.frame.size.height;
    int tableHeight = commentsTable.rowHeight * [names count];
    NSLog(@"DetailView: Resizing commentsTable to start %d height %d", feedHeight, tableHeight);
    NSLog(@"DetailView: Resizing scroll contentSize to %d %d", 320, feedHeight+ tableHeight+5);
    [commentsTable.view setFrame:CGRectMake(0, feedHeight, 320, tableHeight)];
    [scrollView setContentSize:CGSizeMake(320, feedHeight + tableHeight + 5)];
    [self stopActivityIndicator];

    // update comment count
    [feedItem populateWithCommentCount:trueCommentCount];
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

-(void)initFeedItemWithTag:(Tag*)tag
{
    if (feedItem) {
        [feedItem.view removeFromSuperview];
        [feedItem release];        
    }
    
    feedItem = [[VerticalFeedItemController alloc] init];
    [feedItem setDelegate:self];
    
    NSString * name = tag.username;
    NSString * descriptor = tag.descriptor;
    NSString * comment = tag.comment;
    NSString * locationString = tag.locationString;
    
    [self setTagUsername:name];
    
    [feedItem.view setCenter:CGPointMake(160, feedItem.view.center.y)];
    [feedItem.view setBackgroundColor:[UIColor clearColor]];
    [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString];// andWithImage:image];
    [feedItem populateWithTimestamp:tag.timestamp];
    // add badge and counts
    [feedItem initStixView:tag];
    feedItem.tagID = [tag.tagID intValue];
    
#if 0
    // populate comments for this tag
    NSMutableArray * param = [[NSMutableArray alloc] init];
    [param addObject:tag.tagID];
    [[KumulosHelper sharedKumulosHelper] execute:@"getCommentHistory" withParams:param withCallback:@selector(didGetCommentHistoryWithResults:) withDelegate:self];
#else
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    [k getAllHistoryWithTagID:feedItem.tagID];
    NSLog(@"DetailView: calling getAllHistory for tag %d", feedItem.tagID);
#endif
}

/*** feedItem delegate ***/
-(NSString*)getUsername {
    return [self.delegate getUsername];
}

-(NSString*)getTagUsername {
    return tagUsername;
}

-(void)displayCommentsOfTag:(int)_tagID andName:(NSString *)nameString{
    assert( _tagID == tagID );
    if (commentView == nil) {
        commentView = [[CommentViewController alloc] init];
        [commentView setDelegate:self];
    }
    [commentView initCommentViewWithTagID:tagID andNameString:nameString];
    //[commentView setTagID:tagID];
    //[commentView setNameString:nameString];
    
    // hack a way to display view over camera; formerly presentModalViewController
    [self.view addSubview:commentView.view];
}

-(void)didAddNewComment:(NSString *)newComment withTagID:(int)_tagID{
    assert (_tagID == tagID);
    NSString * name = [self.delegate getUsername];
    //int tagID = [commentView tagID];
    if ([newComment length] > 0) {
        [self.delegate didAddCommentWithTagID:_tagID andUsername:name andComment:newComment andStixStringID:@"COMMENT"];
        // reload all comments - clear old ones
        [names removeAllObjects];
        [comments removeAllObjects];
        [stixStringIDs removeAllObjects];
        [timestamps removeAllObjects];
        [k getAllHistoryWithTagID:feedItem.tagID];
    }
    [self didCloseComments];
}

-(void)didCloseComments {
    [commentView.view removeFromSuperview];
}

-(void)sharePix:(int)tag_id {
    [self.delegate sharePix:tag_id];
}

@end
