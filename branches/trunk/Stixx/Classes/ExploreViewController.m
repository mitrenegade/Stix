//
//  ExploreViewController.m
//  Stixx
//
//  Created by Bobby Ren on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExploreViewController.h"

@implementation ExploreViewController
//@synthesize carouselView;
//@synthesize scrollView;
@synthesize tableController;
@synthesize delegate;
//@synthesize buttonFeedback;
@synthesize activityIndicator;
@synthesize profileController;
@synthesize labelBuxCount;
@synthesize buttonProfile;
//@synthesize segmentedControl;

#define EXPLORE_COL 2
#define EXPLORE_ROW 2

-(id)init
{
	self = [super initWithNibName:@"ExploreViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	//UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	//[tbi setTitle:@"Explore"];
	
	// add an image
	//UIImage * i = [UIImage imageNamed:@"tab_find.png"];
	//[tbi setImage:i];
    
    k = nil;
    k = [[Kumulos alloc]init];
    [k setDelegate:self];    

    //activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 140, 80, 80)];
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(150, 11, 25, 25)];

    return self;
    
}
-(void)viewDidLoad {
    [super viewDidLoad];
    
    allTagIDs = [[NSMutableArray alloc] init];
    allTags = [[NSMutableDictionary alloc] init];
    contentViews = [[NSMutableDictionary alloc] init];
    
    newRandomTags = [[NSMutableDictionary alloc] init];
    
    [self initializeTable];
    
    [self.view addSubview:activityIndicator];
    //DetailViewController = [[DetailViewController alloc] init];
    isZooming = NO;
    [self forceReloadAll];

    NSArray *itemArray = [NSArray arrayWithObjects: @"Random", @"Recent", nil]; //, @"Popular", nil];
    UISegmentedControl * segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    [segmentedControl setFrame:CGRectMake(20,50,280,30)];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = EXPLORE_RANDOM;
    [segmentedControl setEnabled:YES forSegmentAtIndex:EXPLORE_RANDOM];
    [segmentedControl setEnabled:YES forSegmentAtIndex:EXPLORE_RECENT];
    //[segmentedControl setEnabled:NO forSegmentAtIndex:EXPLORE_POPULAR];
    [segmentedControl addTarget:self
	                     action:@selector(setExploreMode:)
	           forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
	[segmentedControl release];
    
    UISlider * slider = [[UISlider alloc] init];
    [slider setFrame:CGRectMake(20, 85, 280, 10)];
    [slider setMinimumValue:2];
    [slider setMaximumValue:6];
    [slider setContinuous:NO];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:slider];
    [slider release];

    UIButton * buttonBux = [[UIButton alloc] initWithFrame:CGRectMake(6, 7, 84, 33)];
    [buttonBux setImage:[UIImage imageNamed:@"bux_count.png"] forState:UIControlStateNormal];
    //[buttonBux addTarget:<#(id)#> action:<#(SEL)#> forControlEvents:<#(UIControlEvents)#>];
    [self.view insertSubview:buttonBux belowSubview:tableController.view];
    CGRect labelFrame = CGRectMake(25, 5, 58, 38);
    labelBuxCount = [[OutlineLabel alloc] initWithFrame:labelFrame];
    [labelBuxCount setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [labelBuxCount drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
    [labelBuxCount setText:[NSString stringWithFormat:@"%d", 0]];
    [self.view insertSubview:labelBuxCount belowSubview:buttonProfile];
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

- (void) setExploreMode:(UISegmentedControl *)sender{
    exploreMode = [sender selectedSegmentIndex];
    [self forceReloadAll];
}

-(IBAction)didClickProfileButton:(id)sender {
    [self.view addSubview:profileController.view];
}

- (void) sliderValueChanged:(UISlider *)sender {  
    int value = [sender value];
    [self.tableController setNumberOfColumns:value andBorder:4];
    [self.tableController.tableView reloadData];
}

/*** table ***/
-(void)initializeTable
{
    // We need to do some setup once the view is visible. This will only be done once.
    // Position and size the scrollview. It will be centered in the view.    
    CGRect frame = CGRectMake(0,85, 320, 340);
    tableController = [[ColumnTableController alloc] init];
    [tableController.view setFrame:frame];
    [tableController.view setBackgroundColor:[UIColor clearColor]];
    tableController.delegate = self;
    numColumns = 2;
    [tableController setNumberOfColumns:numColumns andBorder:4];
    [self.view insertSubview:tableController.view belowSubview:self.buttonProfile];
}

-(int)numberOfRows {
    int total = [allTagIDs count];
    NSLog(@"allTagIDs has %d items", total);
    return total / numColumns;
}

-(UIView*)viewForItemAtIndex:(int)index
{    
    // for now, display images of friends, six to a page
    NSNumber * key = [NSNumber numberWithInt:index];
    
    if ([contentViews objectForKey:key] == nil) {
        NSNumber * tagID = [allTagIDs objectAtIndex:index];
        Tag * tag = [allTags objectForKey:tagID];
        
        //UIImageView * cview = [[UIImageView alloc] initWithImage:tag.image];
        
        int contentWidth = [tableController getContentWidth];
        CGRect frame = CGRectMake(0, 0, contentWidth, contentWidth);
        StixView * cview = [[StixView alloc] initWithFrame:frame];
        [cview setInteractionAllowed:YES];
        [cview setIsPeelable:NO];
        [cview setDelegate:self];
        [cview initializeWithImage:tag.image];
        [cview populateWithAuxStixFromTag:tag];
        [contentViews setObject:cview forKey:key];
        [cview release];
    }
    return [contentViews objectForKey:key];
}

-(void)loadContentPastRow:(int)row {
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
    switch (exploreMode) {
        case EXPLORE_RECENT:
            if (row == -1) {
                // load initial row(s)
                NSDate * now = [NSDate date]; // now
                [k getUpdatedPixByTimeWithTimeUpdated:now andNumPix:[NSNumber numberWithInt:numColumns * 2]];
            }
            else {
                NSNumber * tagID = [allTagIDs objectAtIndex:(row * numColumns + numColumns - 1)];
                Tag * tag = [allTags objectForKey:tagID];
                NSDate * lastUpdated = tag.timestamp;
                [k getUpdatedPixByTimeWithTimeUpdated:lastUpdated andNumPix:[NSNumber numberWithInt:numColumns * 5]];
            }
            break;
            
        case EXPLORE_RANDOM: {
            // load 3 rows at a time
            [newRandomTags removeAllObjects];
            int maxID = [delegate getNewestTagID];
            newRandomTagsTargetCount = numColumns * 5;
            for (int i=0; i<newRandomTagsTargetCount; i++) {
                NSInteger num = arc4random() % maxID;
                // kick off kumulos requests
                [k getAllTagsWithIDRangeWithId_min:num-1 andId_max:num+1];
            }
        }
        default:
            break;
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUpdatedPixByTimeDidCompleteWithResult:(NSArray *)theResults {
    if (exploreMode != EXPLORE_RECENT)
        return;
    
    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];
        Tag * newtag = [Tag getTagFromDictionary:d];
        [allTagIDs addObject:newtag.tagID]; // save in order 
        [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary
    }
    [tableController dataSourceDidFinishLoadingNewData];
    [self stopActivityIndicator];
    //[activityIndicator stopCompleteAnimation];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray *)theResults {
    
    if (exploreMode != EXPLORE_RANDOM)
        return;
    if ([newRandomTags count] >= newRandomTagsTargetCount)
        return;
    
    NSInteger num = arc4random() % [delegate getNewestTagID];
    if ([theResults count] == 0) {
        // that tag doesn't exist in kumulos
        // kick off kumulos requests
        [k getAllTagsWithIDRangeWithId_min:num-1 andId_max:num+1];
        return;
    }
    Tag * tag = [Tag getTagFromDictionary:[theResults objectAtIndex:0]];
    NSNumber * tagID = tag.tagID;
    if ([newRandomTags objectForKey:tagID] == nil) {
        [newRandomTags setObject:tag forKey:tagID];
    }
    else {
        // kick off request again because it already exists
        [k getAllTagsWithIDRangeWithId_min:num-1 andId_max:num+1];
        return;
    }
    
    // populate tags
    if ([newRandomTags count] == newRandomTagsTargetCount) {
        NSEnumerator *e = [newRandomTags keyEnumerator];
        id key;
        while (key = [e nextObject]) {
            Tag * newtag = [newRandomTags objectForKey:key];
            [allTagIDs addObject:newtag.tagID]; // save in order 
            [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary
        }
        [tableController dataSourceDidFinishLoadingNewData];
        [self stopActivityIndicator];
        //[activityIndicator stopCompleteAnimation];
    }
}

-(void)forceReloadAll {    
    [allTags removeAllObjects];
    [allTagIDs removeAllObjects];
    [contentViews removeAllObjects];
    [self loadContentPastRow:-1];
    isZooming = NO;
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
}

-(void)didPullToRefresh {
    [self forceReloadAll];
}

/************** DetailView ***********/
-(void)didTouchInStixView:(StixView *)stixViewTouched {
    NSNumber * tagID = stixViewTouched.tagID;
    Tag * tag = [allTags objectForKey:tagID];
    detailController = [[DetailViewController alloc] init];
    [detailController initDetailViewWithTag:tag];
    [detailController setDelegate:self];    
    CGRect frameOffscreen = CGRectMake(320,0,320,480);
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:detailController.view];
    [detailController.view setFrame:frameOffscreen];
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    animationID = [animation doSlide:detailController.view inView:self.view toFrame:frameOnscreen forTime:.5];
}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas {
    //[self.view addSubview:detailController.view];
}
/*
-(void)didClickAtLocation:(CGPoint)location {

    if (isZooming == YES)
        return;
    
    // dumb way to calculate which view we're looking at 
    // but this mirrors the way we populate this page
    int items_per_page = EXPLORE_COL * EXPLORE_ROW;
    int start_index = 0; //[scrollView currentPage] * items_per_page;
    int end_index = start_index + items_per_page - 1;
    int x=0;
    int y=0;
    int x0, y0, x1, y1;
    int item_width = 140;
    int item_height = 140;
    int ct;
    int foundid=-1;
    if (start_index >= items_per_page) {
        //location.x -= [scrollView currentPage] * 300; // remove offset from scrollview 
    }
    for (ct=0; ct<[allTags count]; ct++) {
        if (ct >= start_index && ct <= end_index) {
            x0 = 5 + x * (item_width + 10);
            y0 = 50 + y * (item_height + 10);
            x1 = x0 + item_width;
            y1 = y0 + item_height;

            if (location.x >= x0 && location.x <= x1 && location.y >= y0 && location.y <= y1) {
                foundid = ct;
                break;
            }

            x = x + 1;
            if (x==EXPLORE_COL)
            {
                x = 0;
                y = y + 1;
            }
            if (y == EXPLORE_ROW)
                break;            
        }
    }

    // no item was clicked
    if (ct >= [allTags count] || foundid == -1)
        return; 
    
    NSNumber * tagID = [allTagIDs objectAtIndex:ct];
    Tag * tag = [allTags objectForKey:tagID];
    NSString * label = tag.descriptor;
    NSString * locationString = tag.locationString;
    NSLog(@"Using tag of comment %@ and location %@", label, locationString);

    [DetailViewController setDelegate:self];
    //[self.view insertSubview:DetailViewController.view aboveSubview:scrollView];
    [DetailViewController setLabel:label];
    [DetailViewController setStixUsingTag:tag];
    isZooming = NO;
    
}
*/
-(void)didDismissZoom {
    isZooming = NO;
    //[carouselView setUnderlay:scrollView];
    [detailController.view removeFromSuperview];
    [detailController release];
}

//-(IBAction)feedbackButtonClicked:(id)sender {
//    [self.delegate didClickFeedbackButton:@"Explore view"];
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    [labelBuxCount setText:[NSString stringWithFormat:@"%d", [delegate getBuxCount]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/******* badge view delegate ******/
-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID {
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Beta Version"];
    [alert setMessage:@"Adding Stix in the Explore view coming soon!"];
    [alert show];
    [alert release];
}

-(int)getStixCount:(NSString*)stixStringID {
    return [self.delegate getStixCount:stixStringID];
}
-(int)getStixOrder:(NSString*)stixStringID;
{
    return [self.delegate getStixOrder:stixStringID];
}
-(UIImage*)getUserPhotoForUsername:(NSString *)username {
    return [self.delegate getUserPhotoForUsername:username];
}

-(void)viewDidUnload {
    
    //[carouselView release];
    //carouselView = nil;
    [activityIndicator release];
    activityIndicator = nil;

    [super viewDidUnload];
}
-(void)dealloc {
    [k release];
    //[carouselView release];
    [activityIndicator release];
    [super dealloc];
}

@end
