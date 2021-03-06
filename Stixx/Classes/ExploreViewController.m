//
//  ExploreViewController.m
//  Stixx
//
//  Created by Bobby Ren on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExploreViewController.h"

@implementation ExploreViewController
@synthesize tableController;
@synthesize delegate;
@synthesize activityIndicator;
#if HAS_PROFILE_BUTTON
@synthesize buttonProfile;
#endif
@synthesize tabBarController;
@synthesize galleryUsername;
//@synthesize detailController;
@synthesize tagToRemix;
//@synthesize stixEditorController;

#define EXPLORE_COL 3
#define EXPLORE_ROW 2

static int lastRequest;


-(void)needsRetainForDelegateCall {
    // comes from stixViews
    /*
    if (!retainedDetailControllers) 
        retainedDetailControllers = [[NSMutableSet alloc] init];
    [retainedDetailControllers addObject:detailController];
     */
}

-(void)doneWithAsynchronousDelegateCall {
    //[retainedDetailControllers removeObject:detailController];
}

-(id)init
{
	self = [super initWithNibName:@"ExploreViewController" bundle:nil];
	
    k = nil;
    k = [[Kumulos alloc]init];
    [k setDelegate:self];    

    bHasView = NO;
    bHasTable = NO;
    bShowedTable = NO;
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X + 30, 9, 25, 25)];

    return self;
    
}
-(void)viewDidLoad {
    [super viewDidLoad];
    
    allTagIDs = [[NSMutableArray alloc] init];
    allTags = [[NSMutableDictionary alloc] init];
    contentViews = [[NSMutableDictionary alloc] init];
    //placeholderViews = [[NSMutableDictionary alloc] init];
    isShowingPlaceholderView = [[NSMutableDictionary alloc] init];
    
    newRandomTags = [[NSMutableDictionary alloc] init];
    indexPointer = 0;
    pendingContentCount = 0;
    [self initializeTable];
    
    [self.view addSubview:activityIndicator];

    exploreModeButtons = [[NSMutableArray alloc] init];
    
    UIButton * buttonPopular = [[UIButton alloc] init];
    [buttonPopular setImage:[UIImage imageNamed:@"txt_popular"] forState:UIControlStateNormal];
    [buttonPopular setImage:[UIImage imageNamed:@"txt_popular_on"] forState:UIControlStateSelected];
    [buttonPopular setFrame:CGRectMake(20, OFFSET_NAVBAR + 6, 84, 26)];
    [buttonPopular addTarget:self action:@selector(setExploreMode:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPopular setTag:EXPLORE_POPULAR];
    [self.view addSubview:buttonPopular];

    UIButton * buttonRecent = [[UIButton alloc] init];
    [buttonRecent setImage:[UIImage imageNamed:@"recent"] forState:UIControlStateNormal];
    [buttonRecent setImage:[UIImage imageNamed:@"recent_on"] forState:UIControlStateSelected];
    [buttonRecent setFrame:CGRectMake(118, OFFSET_NAVBAR + 6, 84, 26)];
    [buttonRecent addTarget:self action:@selector(setExploreMode:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRecent setTag:EXPLORE_RECENT];
    [self.view addSubview:buttonRecent];

    UIButton * buttonRandom = [[UIButton alloc] init];
    [buttonRandom setImage:[UIImage imageNamed:@"random"] forState:UIControlStateNormal];
    [buttonRandom setImage:[UIImage imageNamed:@"random_on"] forState:UIControlStateSelected];
    [buttonRandom setFrame:CGRectMake(216, OFFSET_NAVBAR + 6, 84, 26)];
    [buttonRandom addTarget:self action:@selector(setExploreMode:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRandom setTag:EXPLORE_RANDOM];
    [self.view addSubview:buttonRandom];
    
    [exploreModeButtons addObject:buttonPopular];
    [exploreModeButtons addObject:buttonRecent];
    [exploreModeButtons addObject:buttonRandom];
    [self setExploreMode:buttonPopular];
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
        UIButton * modeButton = [exploreModeButtons objectAtIndex:i];
        [modeButton setSelected:NO];
        NSLog(@"Index: %d tag: %d mode: %d", i, [modeButton tag], button.tag);
        if (button.tag == [modeButton tag])
            [[exploreModeButtons objectAtIndex:i] setSelected:YES];
    }
    
    exploreMode = [button tag];
    [self forceReloadAll];
    
#if USING_FLURRY
    if (didInitialSetExploreMode && !IS_ADMIN_USER([delegate getUsername])) {
        NSString * modeString;
        if (exploreMode == EXPLORE_POPULAR) 
            modeString = @"Popular";
        else if (exploreMode == EXPLORE_RECENT) 
            modeString = @"Recent";
        else if (exploreMode == EXPLORE_RANDOM)
            modeString = @"Random";
        [FlurryAnalytics logEvent:@"ChangeExploreMode" withParameters:[NSDictionary dictionaryWithObject:modeString forKey:@"Mode"]];
    }
    didInitialSetExploreMode = YES;
#endif
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
    CGRect frame = CGRectMake(0,OFFSET_NAVBAR+40, 320, 480-(OFFSET_NAVBAR+40)-40);
    tableController = [[ColumnTableController alloc] init];
    [tableController.view setFrame:frame];
    [tableController.view setBackgroundColor:[UIColor clearColor]];
    tableController.delegate = self;
    numColumns = EXPLORE_COL;
    [tableController setNumberOfColumns:numColumns andBorder:4];
    if (bHasView) {
        NSLog(@"HasView and HasTable! ShowedTable!");
#if HAS_PROFILE_BUTTON
        [self.view insertSubview:tableController.view belowSubview:self.buttonProfile];
#endif
        bShowedTable = YES;
    }
    else {
        NSLog(@"NoHasView and HasTable!");
        bHasTable = YES;
        bShowedTable = NO;
    }
}

-(int)numberOfRows {
    float total = [allTagIDs count];
    //NSLog(@"allTagIDs has %f items, returning %f rows", total, total/numColumns);
    return total / numColumns;
}

-(UIImageView *)createPlaceholderViewTemporaryAtPoint:(CGPoint)center {
    UIImageView * placeholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_emptypic.png"]];
    [placeholderView setCenter:center];
    LoadingAnimationView * loadingAnimation = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [loadingAnimation setCenter:center];
    [loadingAnimation startCompleteAnimation];
    [placeholderView addSubview:loadingAnimation];
    return placeholderView;
}

-(UIView*)viewForItemAtIndex:(int)index
{    
    // for now, display images of friends, six to a page
    NSNumber * key = [NSNumber numberWithInt:index];
    
    if (index >= [allTagIDs count])
        return nil;
    
    int contentWidth = [tableController getContentWidth];
    int targetWidth = contentWidth;
    int targetHeight = PIX_HEIGHT * targetWidth / PIX_WIDTH    ; //tagImageSize.height * scale;
    CGRect frame = CGRectMake(0, 0, targetWidth, targetHeight);

    id tagID = [allTagIDs objectAtIndex:index];
    id tagItem = [allTags objectForKey:tagID];
    UIView * contentView = [contentViews objectForKey:tagID];
    if (contentView)
        return contentView;
    if (tagItem != nil && ([tagItem class] == [Tag class]) ) {
        //UIImageView * cview = [[UIImageView alloc] initWithImage:tag.image];
        StixView * cview = [[StixView alloc] initWithFrame:frame];
        [cview setInteractionAllowed:YES];
        [cview setIsPeelable:NO];
        [cview setDelegate:self];

        // populate with tags
        NSNumber * tagID = [allTagIDs objectAtIndex:index];
        Tag * tag = [allTags objectForKey:tagID];
        [cview initializeWithImage:tag.image andStixLayer:tag.stixLayer];
        
        // sometimes requests just fail and never show up
        [cview populateWithAuxStixFromTag:tag];
        [contentViews setObject:cview forKey:tagID];
        return cview;
    }
    else {
        NSLog(@"Creating placeholder for key/index %@", key);
        CGPoint center = frame.origin;
        center.x += frame.size.width / 2;
        center.y += frame.size.height / 2;
        return [self createPlaceholderViewTemporaryAtPoint:center];
    }
    return nil;
}

-(void)didReachLastRow {
    if (exploreMode != EXPLORE_POPULAR) {
        [self loadContentPastRow:[self numberOfRows]];
    }
}

-(void)loadContentPastRow:(int)row {
    if (pendingContentCount > 0) {
        NSLog(@"Trying to load past row %d: still waiting on %d pending contents", row, pendingContentCount);
        return;
    }
    
    NSLog(@"Loading row %d of total %d for gallery", row, [self numberOfRows]); 
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
    switch (exploreMode) {
        case EXPLORE_POPULAR:
            if (row == -1) {
                int numPix = numColumns * 8;
                [allTagIDs removeAllObjects];
                [allTags removeAllObjects];
                NSDate * twoWeeksAgo = [[NSDate date] dateByAddingTimeInterval:-3600*24*14];
                lastDate = twoWeeksAgo;
                
                // first make placeholder views
                for (int i=0; i<numPix; i++)
                    [allTagIDs addObject:[NSNull null]];
                [tableController.tableView reloadData]; // needed to update number of rows
                pendingContentCount += numPix;
                NSLog(@"Pending content count: %d", pendingContentCount);
                
                // then make requests for content
#if 1 && ADMIN_TESTING_MODE
                NSLog(@"**** ADMIN MODE **** ExploreView:loadContentPastRow skipping actual call");
#else
                [k getPopularPixInTimeRangeWithTimeStart:twoWeeksAgo andTimeEnd:[NSDate date] andNumPix:[NSNumber numberWithInt:numPix]];
#endif
            }
            else {
                NSLog(@"No need!");
            }
            break;
            
        case EXPLORE_RECENT:
            if (row == -1) {
                // load initial row(s)
                NSDate * now = [NSDate date]; // now
                int numPix = numColumns * 5;
                
                // start index of request for the next batch
                int requestIndex = [allTagIDs count];
                
                // first create placeholder views
                for (int i=0; i<numPix; i++) {
                    int indexTag = [allTagIDs count];
                    [allTagIDs addObject:[NSNumber numberWithInt:indexTag]];//[NSNull null]];
                }
                [tableController.tableView reloadData];
                pendingContentCount += numPix;
                NSLog(@"Pending content count: %d", pendingContentCount);

                // next make requests for content
                lastRequest = requestIndex;
#if 0 && ADMIN_TESTING_MODE
                NSLog(@"**** ADMIN TESTING MODE **** fakeGetPixByRecent");
//                [self fakeGetRecentPixAtRequestIndex:requestIndex];
                [self performSelector:@selector(fakeGetRecentPixAtRequestIndex:) withObject:self afterDelay:5];
#else
                [k getPixByRecentWithTimeCreated:now andNumPix:[NSNumber numberWithInt:numPix]];
#endif
            }
            else {
                if (indexPointer > 0)
                //if ([allTagIDs lastObject] != [NSNull null])
                {
                    NSNumber * tagID = [allTagIDs objectAtIndex:indexPointer-1];
                    Tag * tag = [allTags objectForKey:tagID];
                    NSDate * lastUpdated = [tag.timestamp dateByAddingTimeInterval:-1];
                    int numPix = numColumns * 5;
                    
                    // start index of request for the next batch
                    int requestIndex = [allTagIDs count];
                    
                    // first create placeholder views/update table
                    for (int i=0; i<numColumns * 5; i++) {
                        int indexTag = [allTagIDs count];
                        [allTagIDs addObject:[NSNumber numberWithInt:indexTag]];
                    }
                    [tableController.tableView reloadData];
                    pendingContentCount += numColumns * 5;
                    NSLog(@"Pending content count: %d", pendingContentCount);
                    
                    // then make request for content
                    lastRequest = requestIndex;
#if 0 && ADMIN_TESTING_MODE
                    NSLog(@"**** ADMIN TESTING MODE **** fakeGetPixByRecent");
                    //                [self fakeGetRecentPixAtRequestIndex:requestIndex];
                    [self performSelector:@selector(fakeGetRecentPixAtRequestIndex:) withObject:self afterDelay:5];
#else
                    [k getPixByRecentWithTimeCreated:lastUpdated andNumPix:[NSNumber numberWithInt:numPix]];
#endif
                }
            }
            break;
            
        case EXPLORE_RANDOM: {
            // load 3 rows at a time
            [newRandomTags removeAllObjects];
            int maxID = [delegate getNewestTagID];
            newRandomTagsTargetCount = numColumns * 5;
            // first make placeholder views
            for (int i=0; i<newRandomTagsTargetCount; i++) {
                NSInteger num = arc4random() % maxID;
                [allTagIDs addObject:[NSNull null]];
            }
            [tableController.tableView reloadData];
            
            // then make requests for content
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

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getPopularPixInTimeRangeDidCompleteWithResult:(NSArray *)theResults {
    if (exploreMode != EXPLORE_POPULAR)
        return;
    
    NSLog(@"Received %d popular results", [theResults count]);
    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];
        Tag * newtag = [Tag getTagFromDictionary:d];
        if ([allTags objectForKey:newtag.tagID] == nil) {
            [allTagIDs replaceObjectAtIndex:indexPointer++ withObject:newtag.tagID];
            [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary        
            NSLog(@"Adding tag %d", [newtag.tagID intValue]);
        }
        // even though we don't have aux stix, we need this to switch out of the placeholder
#if 0
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newtag.tagID, nil]; 
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        [kh execute:@"getAuxiliaryStixOfTag" withParams:params withCallback:@selector(khCallback_didGetAuxiliaryStixOfTag:) withDelegate:self];
#else
        //[self fakeDidGetAuxiliaryStixOfTagWithID:newtag.tagID];
#endif
        pendingContentCount--;
        if (pendingContentCount <= 0) {
            //pendingContentCount = 0;
            // we've received more than enough
            break;
        }        
    }
    if (pendingContentCount > 0) {
        NSDate * twoWeeksAgo = [lastDate dateByAddingTimeInterval:-3600*24*14];
        [k getPopularPixInTimeRangeWithTimeStart:twoWeeksAgo andTimeEnd:lastDate andNumPix:[NSNumber numberWithInt:numColumns * 5]];
        lastDate = twoWeeksAgo;
    }
    if ([theResults count]>0)
        [tableController dataSourceDidFinishLoadingNewData];
    [self stopActivityIndicator];
    //[activityIndicator stopCompleteAnimation];
}

-(void)fakeGetRecentPixAtRequestIndex:(int)startIndex {
    startIndex = lastRequest;
    int number = numColumns * 5;
    for (int i=0; i<number; i++) {
        int newindex = startIndex + i;
        Tag * newtag = [[Tag alloc] init];
        newtag.tagID = [NSNumber numberWithInt:newindex];
        [newtag setImage:[UIImage imageNamed:@"nav_back"]];
        
        [allTagIDs replaceObjectAtIndex:newindex withObject:newtag.tagID];
        [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary        
        //[self fakeDidGetAuxiliaryStixOfTagWithID:newtag.tagID];
        
        indexPointer++;
        
        // don't know why this happens but sometimes it does!
        pendingContentCount--;
        if (pendingContentCount < 0)
            pendingContentCount = 0;
        
    }
    [tableController.tableView reloadData];
    [tableController dataSourceDidFinishLoadingNewData];
    [self stopActivityIndicator];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getPixByRecentDidCompleteWithResult:(NSArray *)theResults {
    if (exploreMode != EXPLORE_RECENT)
        return;
    
    int startIndex = lastRequest;
    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];
        int newindex = startIndex + i;

        Tag * newtag = [Tag getTagFromDictionary:d];
        [allTagIDs replaceObjectAtIndex:newindex withObject:newtag.tagID];
        [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary        
//        [self fakeDidGetAuxiliaryStixOfTagWithID:newtag.tagID];

        indexPointer++;

        // don't know why this happens but sometimes it does!
        pendingContentCount--;
        if (pendingContentCount < 0)
            pendingContentCount = 0;

        //NSLog(@"Explore recent tags: Downloaded tag ID %d at position %d pending content: %d allTagIDs %d allTags %d", [newtag.tagID intValue], [allTagIDs count], pendingContentCount, [allTagIDs count], [allTags count]);
    }
    [tableController.tableView reloadData];
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
            if ([allTags objectForKey:newtag.tagID] == nil) {
                [allTagIDs replaceObjectAtIndex:indexPointer++ withObject:newtag.tagID];
                [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary
            }
            
            // new system of auxiliary stix: request from auxiliaryStixes table
            NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newtag.tagID, nil]; 
            KumulosHelper * kh = [[KumulosHelper alloc] init];
            [kh execute:@"getAuxiliaryStixOfTag" withParams:params withCallback:@selector(khCallback_didGetAuxiliaryStixOfTag:) withDelegate:self];
            
            pendingContentCount--;
            if (pendingContentCount <= 0)
                pendingContentCount = 0;            
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
    //[placeholderViews removeAllObjects];
    [isShowingPlaceholderView removeAllObjects];
    pendingContentCount = 0;
    indexPointer = 0;
    [self.tableController.tableView reloadData];
    [self loadContentPastRow:-1];
    //isZooming = NO;
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
}

-(void)didPullToRefresh {
    [self forceReloadAll];
}

/************** DetailView ***********/
-(void)didTouchInStixView:(StixView *)stixViewTouched {
//    if ([DetailViewController openingDetailView])
//        return;
//    [DetailViewController lockOpen];
    
    NSNumber * tagID = stixViewTouched.tagID;
    Tag * tag = [allTags objectForKey:tagID];
#if 0
    detailController = [[DetailViewController alloc] init];
    [detailController setDelegate:self];    
    [detailController initDetailViewWithTag:tag];
    CGRect frameOffscreen = CGRectMake(-320,0,320,480);
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:detailController.view];
    [detailController.view setFrame:frameOffscreen];
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    //openDetailAnimation = [animation doSlide:detailController.view inView:self.view toFrame:frameOnscreen forTime:.25];
    [animation doViewTransition:detailController.view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished) {
        [DetailViewController unlockOpen];
    }];
#else
    [delegate shouldDisplayDetailViewWithTag:tag];
#endif
    
#if !USING_FLURRY
    NSString * metricName = @"ExplorePix";
    //NSString * metricData = [NSString stringWithFormat:@"User: %@ ExploreType: %@", [self getUsername], exploreMode == EXPLORE_RECENT?@"Recent":@"Random"];
    //[k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:0];
    [k addMetricWithDescription:metricName andUsername:[delegate getUsername] andStringValue:exploreMode == EXPLORE_RECENT?@"Recent":@"Random" andIntegerValue:[tagID intValue]];
#else
    if (!IS_ADMIN_USER([self getUsername]))
        [FlurryAnalytics logEvent:@"ExplorePix" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", exploreMode == EXPLORE_RECENT?@"Recent":@"Random", @"ExploreMode", tagID, @"tagID", nil]];
#endif
}

-(void)shouldDisplayUserPage:(NSString *)username {
    // close detailView first - click came from here
#if 0
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = detailController.view.frame;
    frameOffscreen.origin.x -= 330;
    
    [animation doViewTransition:detailController.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [detailController.view removeFromSuperview];
        [delegate shouldDisplayUserPage:username];
    }];
#else
    
#endif
}
//-(void)shouldCloseUserPage {
//    [delegate shouldCloseUserPage];
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
    [delegate pauseAggregation];
    
#if HAS_PROFILE_BUTTON
    UIImage * photo = [delegate getUserPhotoForUsername:[delegate getUsername]];
    if ([[delegate getUsername] isEqualToString:@"anonymous"]) {
        photo = [UIImage imageNamed:@"nav_profilebutton.png"];
    }
    [buttonProfile setImage:photo forState:UIControlStateNormal];
    [buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [buttonProfile.layer setBorderWidth:1];
#endif
    // if we opened detail controller, then switched to a different tab, then switched back, unlock it
    //if (detailController)
    //    detailController = nil;
    //[DetailViewController unlockOpen]; 
    if (bHasTable && !bShowedTable) {
        NSLog(@"HasView and HadTable! ShowedTable!");
#if HAS_PROFILE_BUTTON
        [self.view insertSubview:tableController.view belowSubview:self.buttonProfile];
#else
        [self.view addSubview:tableController.view];
#endif
        bShowedTable = YES;
    }
    else {
        NSLog(@"HasView! NoHasTable!");
    }
    if (bHasView == NO) {
        //[self forceReloadAll];
    }
    bHasView = YES;
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
}

-(UIImage*)getUserPhotoForUsername:(NSString *)username {
    return [self.delegate getUserPhotoForUsername:username];
}

#pragma kumulosHelper callback
-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    [self performSelector:callback withObject:params afterDelay:0];
}

-(void)viewDidUnload {
    
    activityIndicator = nil;

    [super viewDidUnload];
}

@end
