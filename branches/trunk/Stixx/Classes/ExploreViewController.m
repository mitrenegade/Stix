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
@synthesize labelBuxCount;
@synthesize buttonProfile;
@synthesize tabBarController;
@synthesize galleryUsername;
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

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 9, 25, 25)];

    return self;
    
}
-(void)viewDidLoad {
    [super viewDidLoad];
    
    allTagIDs = [[NSMutableArray alloc] init];
    allTags = [[NSMutableDictionary alloc] init];
    contentViews = [[NSMutableDictionary alloc] init];
    placeholderViews = [[NSMutableDictionary alloc] init];
    
    newRandomTags = [[NSMutableDictionary alloc] init];
    
    [self initializeTable];
    
    [self.view addSubview:activityIndicator];
    //DetailViewController = [[DetailViewController alloc] init];
    isZooming = NO;
    [self forceReloadAll];

    exploreModeButtons = [[NSMutableArray alloc] init];
    UIButton * buttonRecent = [[UIButton alloc] init];
    [buttonRecent setImage:[UIImage imageNamed:@"recent.png"] forState:UIControlStateNormal];
    [buttonRecent setImage:[UIImage imageNamed:@"recent_on.png"] forState:UIControlStateSelected];
    [buttonRecent setFrame:CGRectMake(30, 50, 130, 30)];
    [buttonRecent addTarget:self action:@selector(setExploreMode:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRecent setTag:EXPLORE_RECENT];
    [self.view addSubview:buttonRecent];

    UIButton * buttonRandom = [[UIButton alloc] init];
    [buttonRandom setImage:[UIImage imageNamed:@"random.png"] forState:UIControlStateNormal];
    [buttonRandom setImage:[UIImage imageNamed:@"random_on.png"] forState:UIControlStateSelected];
    [buttonRandom setFrame:CGRectMake(150, 50, 130, 30)];
    [buttonRandom addTarget:self action:@selector(setExploreMode:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRandom setTag:EXPLORE_RANDOM];
    [self.view addSubview:buttonRandom];
    
    [exploreModeButtons addObject:buttonRecent];
    [exploreModeButtons addObject:buttonRandom];
    [self setExploreMode:buttonRecent];
    [buttonRecent release];
    [buttonRandom release];

    UIButton * buttonBux = [[[UIButton alloc] initWithFrame:CGRectMake(6, 7, 84, 33)] autorelease];
    [buttonBux setImage:[UIImage imageNamed:@"bux_count.png"] forState:UIControlStateNormal];
    [buttonBux addTarget:self action:@selector(didClickMoreBuxButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:buttonBux belowSubview:tableController.view];
    
    CGRect labelFrame = CGRectMake(25, 5, 58, 38);
    labelBuxCount = [[[OutlineLabel alloc] initWithFrame:labelFrame] autorelease];
    [labelBuxCount setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [labelBuxCount drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
    [labelBuxCount setText:[NSString stringWithFormat:@"%d", 0]];
    [self.view insertSubview:labelBuxCount belowSubview:buttonProfile];

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

-(void) setExploreMode:(UIButton*)button{
    for (int i=0; i<[exploreModeButtons count]; i++){
        [[exploreModeButtons objectAtIndex:i] setSelected:NO];
        NSLog(@"Index: %d tag: %d mode: %d", i, [[exploreModeButtons objectAtIndex:i] tag], button.tag);
        if (button.tag == [[exploreModeButtons objectAtIndex:i] tag])
            [[exploreModeButtons objectAtIndex:i] setSelected:YES];
    }
    
    exploreMode = [button tag];
    [self forceReloadAll];
}

-(IBAction)didClickProfileButton:(id)sender {
    [self.delegate didOpenProfileView];
}

- (void) sliderValueChanged:(UISlider *)sender {  
    int value = [sender value];
    [self.tableController setNumberOfColumns:value andBorder:4];
    [self.tableController.tableView reloadData];
}

-(NSString*)getUsername {
    return [delegate getUsername];
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
    //NSLog(@"allTagIDs has %d items", total);
    return total / numColumns;
}

-(UIView*)viewForItemAtIndex:(int)index
{    
    // for now, display images of friends, six to a page
    NSNumber * key = [NSNumber numberWithInt:index];
    
    if (index >= [allTagIDs count])
        return nil;
    
    if ([contentViews objectForKey:key] == nil) {
        NSNumber * tagID = [allTagIDs objectAtIndex:index];
        Tag * tag = [allTags objectForKey:tagID];
        
        //UIImageView * cview = [[UIImageView alloc] initWithImage:tag.image];
        
        int contentWidth = [tableController getContentWidth];
        int targetWidth = contentWidth;
        int targetHeight = 282 * targetWidth / 314.0    ; //tagImageSize.height * scale;
        CGRect frame = CGRectMake(0, 0, targetWidth, targetHeight);
        StixView * cview = [[StixView alloc] initWithFrame:frame];
        [cview setInteractionAllowed:YES];
        [cview setIsPeelable:NO];
        [cview setDelegate:self];
        [cview initializeWithImage:tag.image];
#if 0
        int canShow = [cview populateWithAuxStixFromTag:tag];
        if (canShow) {
            cview.isShowingPlaceholder = NO;
        }
        else {
            UIImageView * placeholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_emptypic.png"]];
            [placeholderView setCenter:cview.center];
            cview.isShowingPlaceholder = YES;
            [placeholderViews setObject:placeholderView forKey:key];
            [placeholderView release];
        }
#else
        // sometimes requests just fail and never show up
        [cview populateWithAuxStixFromTag:tag];
        cview.isShowingPlaceholder = NO;
#endif
        [contentViews setObject:cview forKey:key];
        [cview release];
    }
    StixView * cview = [contentViews objectForKey:key];
    if (cview.isShowingPlaceholder)
        return [placeholderViews objectForKey:key];
    return [contentViews objectForKey:key];
}

-(void)loadContentPastRow:(int)row {
    NSLog(@"Loading row %d of total %d for gallery", row, [self numberOfRows]); 
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
    switch (exploreMode) {
        case EXPLORE_RECENT:
            if (row == -1) {
                // load initial row(s)
                NSDate * now = [NSDate date]; // now
                [k getUpdatedPixByTimeWithTimeUpdated:now andNumPix:[NSNumber numberWithInt:numColumns * 5]];
            }
            else {
                NSNumber * tagID = [allTagIDs lastObject];
                Tag * tag = [allTags objectForKey:tagID];
                NSDate * lastUpdated = [tag.timestamp dateByAddingTimeInterval:-1];
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
        //NSLog(@"Explore recent tags: Downloaded tag ID %d at position %d", [newtag.tagID intValue], [allTagIDs count]);
        [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary
    }
    if ([theResults count]>0)
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
        if ([newRandomTags count]>0)
            [tableController dataSourceDidFinishLoadingNewData];
        [self stopActivityIndicator];
        //[activityIndicator stopCompleteAnimation];
    }
}

-(void)forceReloadAll {    
    [allTags removeAllObjects];
    [allTagIDs removeAllObjects];
    [contentViews removeAllObjects];
    [placeholderViews removeAllObjects];
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
    if ([DetailViewController openingDetailView])
        return;
    [DetailViewController lockOpen];
    
    NSNumber * tagID = stixViewTouched.tagID;
    Tag * tag = [allTags objectForKey:tagID];
    detailController = [[DetailViewController alloc] init];
    [detailController setDelegate:self];    
    [detailController initDetailViewWithTag:tag];
    CGRect frameOffscreen = CGRectMake(-320,0,320,480);
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:detailController.view];
    [detailController.view setFrame:frameOffscreen];
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    openDetailAnimation = [animation doSlide:detailController.view inView:self.view toFrame:frameOnscreen forTime:.5];
    
    NSString * metricName = @"ExplorePix";
    //NSString * metricData = [NSString stringWithFormat:@"User: %@ ExploreType: %@", [self getUsername], exploreMode == EXPLORE_RECENT?@"Recent":@"Random"];
    //[k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:0];
    [k addMetricWithDescription:metricName andUsername:[delegate getUsername] andStringValue:exploreMode == EXPLORE_RECENT?@"Recent":@"Random" andIntegerValue:[tagID intValue]];
}

-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID {
    [self.delegate didAddCommentWithTagID:tagID andUsername:name andComment:comment andStixStringID:stixStringID];
}

-(void)didDismissZoom {
    isZooming = NO;
    //[carouselView setUnderlay:scrollView];
    if (detailController) {
        [detailController.view removeFromSuperview];
        [detailController release];
        detailController = nil;
    }
}

#pragma mark UserGalleryDelegate

/*
 -(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas {
 if (animationID == openDetailAnimation) {
 [DetailViewController unlockOpen];
 }
 }
 */

-(void)shouldDisplayUserPage:(NSString *)username {
    // close detailView first - click came from here
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = detailController.view.frame;
    frameOffscreen.origin.x -= 330;
    
    [animation doViewTransition:detailController.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [detailController.view removeFromSuperview];
        [delegate shouldDisplayUserPage:username];
    }];
}
-(void)shouldCloseUserPage {
    [delegate shouldCloseUserPage];
}

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID {
    //NSLog(@"VerticalFeedItemController calling delegate didReceiveRequestedStixView");
    // send through to StixAppDelegate to save to defaults
    [delegate didReceiveRequestedStixViewFromKumulos:stixStringID];
}

-(void)didReceiveAllRequestedMissingStix:(StixView *)stixView {
    [stixView removeFromSuperview];
    for (int i=0; i<[contentViews count]; i++) {
        StixView * cview = [contentViews objectForKey:[NSNumber numberWithInt:i]];
        if ([cview stixViewID] == [stixView stixViewID]) {
            NSLog(@"ExploreView: didReceiveAllRequestedMissingStix for stixView %d at index %d", [stixView stixViewID], i);
            [contentViews removeObjectForKey:[NSNumber numberWithInt:i]];
            [self.tableController.tableView reloadData];
            break;
        }
    }
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

    UIImage * photo = [delegate getUserPhotoForUsername:[delegate getUsername]];
    [buttonProfile setImage:photo forState:UIControlStateNormal];
    [buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [buttonProfile.layer setBorderWidth:1];
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

#pragma mark bux instructions
-(void)didClickMoreBuxButton:(id)sender {
    [delegate didShowBuxInstructions];
}

-(void)viewDidUnload {
    
    //[carouselView release];
    //carouselView = nil;
    [k release];
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
