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
@synthesize activityIndicatorLarge;
@synthesize logo;
@synthesize tagUsername;
@synthesize commentView;

static BOOL openingDetailView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        feedItem = nil;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.view setFrame:CGRectMake(160, 0, 320, 480)];
}

-(void)initDetailViewWithTag:(Tag*)tag {
    //NSLog(@"DetailView: Creating stix view of size %f %f", tag.image.size.width, tag.image.size.height);
    
    tagID = [tag.tagID intValue];
    [self initFeedItemWithTag:tag];
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

-(void)startActivityIndicator {
    //[logo setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
    [self performSelector:@selector(stopActivityIndicatorAfterTimeout) withObject:nil afterDelay:10];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    //[logo setHidden:NO];
}
-(void)stopActivityIndicatorAfterTimeout {
    [self stopActivityIndicator];
    //NSLog(@"%s: ActivityIndicator stopped after timeout!", __func__);
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

-(float)getRowHeightForRow:(int)index {
    if (index > [rowHeights count])
        return 0;
    return [[rowHeights objectAtIndex:index] floatValue];
}

-(UIImage *)getPhotoForIndex:(int)index {
    return [delegate getUserPhotoForUsername:[names objectAtIndex:index]];
}

-(UIImage *)getUserPhotoForUsername:(NSString *)username {
    return [delegate getUserPhotoForUsername:username];
}

-(int)getCount {
    return [names count];
}

-(IBAction)didClickBackButton:(id)sender {    
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = CGRectMake(-3-320, 0, 320, 480);
    animationID[1] = [animation doSlide:self.view inView:self.view toFrame:frameOffscreen forTime:.5];
    [DetailViewController unlockOpen];
}
-(void)didFinishAnimation:(int)animID withCanvas:(UIView *)canvas {
    if (animID == animationID[1]) {
        //[stixView release];
        [delegate didDismissZoom];
        [DetailViewController unlockOpen];
    }
    // share menu
    else if (animID == shareMenuOpenAnimation) {
        [self.view addSubview:buttonShareEmail];
        [self.view addSubview:buttonShareFacebook];
        [self.view addSubview:buttonShareClose];
    }
    else if (animID == shareMenuCloseAnimation) {
        [self stopActivityIndicator];
        if (shareSheet) {
            shareSheet = nil;
            [buttonShareEmail removeFromSuperview];
            [buttonShareFacebook removeFromSuperview];
            [buttonShareClose removeFromSuperview];
            buttonShareClose = nil;
            buttonShareEmail = nil;
            buttonShareFacebook = nil;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

+(BOOL)openingDetailView {
    return openingDetailView;
}
+(void)lockOpen {
    openingDetailView = YES;
}
+(void)unlockOpen {
    openingDetailView = NO;
}

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
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 11, 25, 25)];
    
    
    names = [[NSMutableArray alloc] init];
    comments = [[NSMutableArray alloc] init];
    stixStringIDs = [[NSMutableArray alloc] init];
    timestamps = [[NSMutableArray alloc] init];
    rowHeights = [[NSMutableArray alloc] init];
    
    [self.view addSubview:headerView];

    if (commentsTable)
    {
        [commentsTable.view removeFromSuperview];
    }
    commentsTable = [[CommentFeedTableController alloc] init];
    [commentsTable.view setFrame:CGRectMake(0, feedItem.view.frame.size.height, 320, 0)];
    commentsTable.tableView.scrollEnabled = NO;
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

-(void)setScrollHeight:(int)height {
    //NSLog(@"Before setScrollHeight, feedItem height: %f", feedItem.view.frame.size.height);
    // if we are resizing the scroll, any subviews must be removed or they will resize with it?
    [feedItem.view removeFromSuperview];
    CGRect frame = scrollView.frame;
    frame.size.height = height;
    [scrollView setFrame:frame];
    [scrollView addSubview:feedItem.view];
    //NSLog(@"After setScrollHeight, feedItem height: %f", feedItem.view.frame.size.height);
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
        float height = [commentsTable getHeightForComment:comment forStixStringID: stixStringID];
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
        [rowHeights addObject:[NSNumber numberWithFloat:height]];
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
    UIButton * photoView = [[UIButton alloc] initWithFrame:CGRectMake(3, 5, 30, 30)];
    [photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [photoView.layer setBorderWidth: 2.0];
    [photoView setImage:photo forState:UIControlStateNormal];
    [photoView addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
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
    [param autorelease];
    [[KumulosHelper sharedKumulosHelper] execute:@"getCommentHistory" withParams:param withCallback:@selector(khCallback_didGetCommentHistoryWithResults:) withDelegate:self];
#else
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    [k getAllHistoryWithTagID:feedItem.tagID];
    NSLog(@"DetailView: calling getAllHistory for tag %d", feedItem.tagID);
#endif
}

/*** feedItem delegate ***/
-(NSString*)getUsername {
    NSLog(@"DetailView returning username of tag: %@", tagUsername);
    //return [self.delegate getUsername];
    return tagUsername;
}
-(NSString*)getUsernameOfApp {
    return [delegate getUsername];
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
    NSString * name = [delegate getUsername];
    //int tagID = [commentView tagID];
    if ([newComment length] > 0) {
        [self.delegate didAddCommentWithTagID:_tagID andUsername:name andComment:newComment andStixStringID:@"COMMENT"];
        // reload all comments - clear old ones
        [names removeAllObjects];
        [comments removeAllObjects];
        [stixStringIDs removeAllObjects];
        [timestamps removeAllObjects];
        [rowHeights removeAllObjects];
        [k getAllHistoryWithTagID:feedItem.tagID];
    }
    [self didCloseComments];
}

-(void)didCloseComments {
    [commentView.view removeFromSuperview];
}

//-(void)sharePix:(int)tag_id {
//    [self.delegate sharePix:tag_id];
//}

-(void)didClickUserPhoto:(UIButton*)button {
    NSLog(@"DetailViewController: Clicked user photo for tag: user %@", tagUsername);
    [delegate shouldDisplayUserPage:tagUsername];
    [DetailViewController unlockOpen];
}

-(void)shouldDisplayUserPage:(NSString *)username {
    NSLog(@"Multilayered display of profile view about to happen from DetailViewController!");
    // close comments table first - click came from here
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = commentView.view.frame;
    frameOffscreen.origin.x -= 330;
    
    [animation doViewTransition:commentView.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [commentView.view removeFromSuperview];
        [delegate shouldDisplayUserPage:username];
    }];
    
    // this is effectively a close action, so must unlock detailViewController open lock
    [DetailViewController unlockOpen];
}

-(void)shouldCloseUserPage {
    [delegate shouldCloseUserPage];
}
#pragma mark sharing from VerticalFeedItemDelegate

-(void)didCloseShareSheet {
    CGRect frameOutside = CGRectMake(16-320, 22, 289, 380);
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    shareMenuCloseAnimation = [animation doSlide:shareSheet inView:self.view toFrame:frameOutside forTime:.25];
}

-(void)didClickShareViaFacebook {
    [self startActivityIndicator];
    dispatch_async( dispatch_queue_create("com.Neroh.Stix.FeedController.bgQueue", NULL), ^(void) {
        [feedItem didClickShareViaFacebook];
    });
    [self didCloseShareSheet];
    activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
    [shareSheet addSubview:activityIndicatorLarge];
    [activityIndicatorLarge startCompleteAnimation];
}

-(void)didClickShareViaEmail {
    [self startActivityIndicator];
    dispatch_async( dispatch_queue_create("com.Neroh.Stix.FeedController.bgQueue", NULL), ^(void) {
        [feedItem didClickShareViaEmail];
    });
    [self didCloseShareSheet];
    activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
    [shareSheet addSubview:activityIndicatorLarge];
    [activityIndicatorLarge startCompleteAnimation];
}

-(void)didPressShareButtonForFeedItem:(VerticalFeedItemController *) feedItem {
    CGRect frameInside = CGRectMake(16, 22, 289, 380);
    CGRect frameOutside = CGRectMake(16-320, 22, 289, 380);
    shareSheet = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share_actions.png"]];
    [shareSheet setFrame:frameOutside];
    
    buttonShareFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonShareFacebook setFrame:CGRectMake(68-16, 175-22, 210, 60)];
    [buttonShareFacebook setBackgroundColor:[UIColor clearColor]];
    [buttonShareFacebook addTarget:self action:@selector(didClickShareViaFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    buttonShareEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonShareEmail setFrame:CGRectMake(68-16, 250-22, 210, 60)];
    [buttonShareEmail setBackgroundColor:[UIColor clearColor]];
    [buttonShareEmail addTarget:self action:@selector(didClickShareViaEmail) forControlEvents:UIControlEventTouchUpInside];
    
    buttonShareClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonShareClose setFrame:CGRectMake(270-16, 60-22, 37, 39)];
    [buttonShareClose setBackgroundColor:[UIColor clearColor]];
    [buttonShareClose addTarget:self action:@selector(didCloseShareSheet) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:shareSheet];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    shareMenuOpenAnimation = [animation doSlide:shareSheet inView:self.view toFrame:frameInside forTime:.25];
}

-(void)sharePixDialogDidFinish {
    [self didCloseShareSheet];
    if (activityIndicatorLarge) {
        [activityIndicatorLarge setHidden:YES];
        [activityIndicatorLarge stopCompleteAnimation];
        [activityIndicatorLarge removeFromSuperview];
        activityIndicatorLarge = nil;
    }
}

-(void)didClickAtLocation:(CGPoint)location withFeedItem:(VerticalFeedItemController *)feedItem {
    /* DO NOT allow clicks - will lead to a delegate mess
    // location is the click location inside feeditem's frame
    
    NSLog(@"VerticalFeedController: Click on table at position %f %f with tagID %d\n", location.x, location.y, feedItem.tagID);
    
    CGPoint locationInStixView = location;
    int peelableFound = [[feedItem stixView] findPeelableStixAtLocation:locationInStixView];    
     */
}

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID {
    //NSLog(@"VerticalFeedItemController calling delegate didReceiveRequestedStixView");
    // send through to StixAppDelegate to save to defaults
    [delegate didReceiveRequestedStixViewFromKumulos:stixStringID];
}

-(void)didReceiveAllRequestedMissingStix:(StixView *)stixView {
    // do nothing
}

@end
