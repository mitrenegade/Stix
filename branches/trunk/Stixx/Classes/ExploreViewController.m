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
//@synthesize labelBuxCount;
#if HAS_PROFILE_BUTTON
@synthesize buttonProfile;
#endif
@synthesize tabBarController;
@synthesize galleryUsername;
@synthesize detailController;
@synthesize tagToRemix;
@synthesize stixEditorController;

#define EXPLORE_COL 3
#define EXPLORE_ROW 2

static NSMutableSet * retainedDetailControllers;

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

-(void)detailViewNeedsRetainForDelegateCall:(DetailViewController *)_detailController {
//-(void)detailViewNeedsRetainForDelegateCall:(DetailViewController*)_detailController {
    // comes from stixViews
    if (!retainedDetailControllers) 
        retainedDetailControllers = [[NSMutableSet alloc] init];
    NSLog(@"ExploreView: retaining detail view with username %@", [_detailController tagUsername]);
    [retainedDetailControllers addObject:_detailController];
}

-(void)detailViewDoneWithAsynchronousDelegateCall {
    NSLog(@"ExploreView: releasing detail view with username %@", [detailController tagUsername]);
    [retainedDetailControllers removeObject:detailController];
}

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
    placeholderViews = [[NSMutableDictionary alloc] init];
    isShowingPlaceholderView = [[NSMutableDictionary alloc] init];
    
    newRandomTags = [[NSMutableDictionary alloc] init];
    indexPointer = 0;
    pendingContentCount = 0;
    [self initializeTable];
    
    [self.view addSubview:activityIndicator];
    //DetailViewController = [[DetailViewController alloc] init];
    isZooming = NO;
    //[self forceReloadAll];

    exploreModeButtons = [[NSMutableArray alloc] init];
    
    UIButton * buttonPopular = [[UIButton alloc] init];
    [buttonPopular setImage:[UIImage imageNamed:@"txt_popular"] forState:UIControlStateNormal];
    [buttonPopular setImage:[UIImage imageNamed:@"txt_popular_on"] forState:UIControlStateSelected];
    [buttonPopular setFrame:CGRectMake(20, 50, 84, 26)];
    [buttonPopular addTarget:self action:@selector(setExploreMode:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPopular setTag:EXPLORE_POPULAR];
    [self.view addSubview:buttonPopular];

    UIButton * buttonRecent = [[UIButton alloc] init];
    [buttonRecent setImage:[UIImage imageNamed:@"recent"] forState:UIControlStateNormal];
    [buttonRecent setImage:[UIImage imageNamed:@"recent_on"] forState:UIControlStateSelected];
    [buttonRecent setFrame:CGRectMake(118, 50, 84, 26)];
    [buttonRecent addTarget:self action:@selector(setExploreMode:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRecent setTag:EXPLORE_RECENT];
    [self.view addSubview:buttonRecent];

    UIButton * buttonRandom = [[UIButton alloc] init];
    [buttonRandom setImage:[UIImage imageNamed:@"random"] forState:UIControlStateNormal];
    [buttonRandom setImage:[UIImage imageNamed:@"random_on"] forState:UIControlStateSelected];
    [buttonRandom setFrame:CGRectMake(216, 50, 84, 26)];
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

#if HAS_PROFILE_BUTTON
-(IBAction)didClickProfileButton:(id)sender {
    [self.delegate didOpenProfileView];
}
#endif

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
    int total = [allTagIDs count];
    //NSLog(@"allTagIDs has %d items, returning %d rows", total, total/numColumns);
    return total / numColumns;
}

-(void)createPlaceholderViewForStixView:(StixView*)cview andKey:(NSNumber*)key {
#if 1
    UIImageView * placeholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_emptypic.png"]];
    [placeholderView setCenter:cview.center];
    LoadingAnimationView * loadingAnimation = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [loadingAnimation setCenter:cview.center];
    [loadingAnimation startCompleteAnimation];
    [placeholderView addSubview:loadingAnimation];
    [placeholderViews setObject:placeholderView forKey:key];
#else
    // doesn't work - frame is wrong
    if (placeholderViewGlobal)
        return;
    placeholderViewGlobal = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_emptypic.png"]];
    [placeholderViewGlobal setCenter:cview.center];
    LoadingAnimationView * loadingAnimation = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [loadingAnimation setCenter:cview.center];
    [loadingAnimation startCompleteAnimation];
    [placeholderViewGlobal addSubview:loadingAnimation];
#endif
}

-(UIView*)viewForItemAtIndex:(int)index
{    
    // for now, display images of friends, six to a page
    NSNumber * key = [NSNumber numberWithInt:index];
    
    if (index >= [allTagIDs count])
        return nil;
    
    if ([allTagIDs objectAtIndex:index] != [NSNull null]) {
        NSNumber * tagID = [allTagIDs objectAtIndex:index]; 
        NSLog(@"ViewItemAtIndex: %d tagid %d", index, [tagID intValue]);
    }
    if ([contentViews objectForKey:key] == nil) {
        //UIImageView * cview = [[UIImageView alloc] initWithImage:tag.image];
        if ([allTagIDs objectAtIndex:index] != [NSNull null]) {
            NSLog(@"Creating contentView for index %d with tagID %d", index, [[allTagIDs objectAtIndex:index] intValue]); 
        }
        else {
            NSLog(@"Creating contentView for index %d with NULL", index); 
        }
        int contentWidth = [tableController getContentWidth];
        int targetWidth = contentWidth;
        int targetHeight = PIX_HEIGHT * targetWidth / PIX_WIDTH    ; //tagImageSize.height * scale;
        CGRect frame = CGRectMake(0, 0, targetWidth, targetHeight);
        StixView * cview = [[StixView alloc] initWithFrame:frame];
        [cview setInteractionAllowed:YES];
        [cview setIsPeelable:NO];
        [cview setDelegate:self];

        // populate with tags
        if ([allTagIDs objectAtIndex:index] != [NSNull null]) {
            NSNumber * tagID = [allTagIDs objectAtIndex:index];
            Tag * tag = [allTags objectForKey:tagID];
            [cview initializeWithImage:tag.image andStixLayer:tag.stixLayer];

            // sometimes requests just fail and never show up
            [cview populateWithAuxStixFromTag:tag];
        }
        if (![isShowingPlaceholderView objectForKey:key]) {
            cview.isShowingPlaceholder = YES;
            [isShowingPlaceholderView setObject:[NSNumber numberWithBool:YES] forKey:key];//tagID];

            [self createPlaceholderViewForStixView:cview andKey:key];
        }
        else {
            cview.isShowingPlaceholder = [[isShowingPlaceholderView objectForKey:key/*tagID*/] boolValue];
        }
        [contentViews setObject:cview forKey:key];
    }
    StixView * cview = [contentViews objectForKey:key];
    if (cview.isShowingPlaceholder) {
        UIView * placeholder = [placeholderViews objectForKey:key];
        /*
        if (placeholder == nil) {
            // shouldn't go here!
            NSLog(@"Placeholder is nil! contentID %d tag %d", [key intValue], [tagID intValue]);
            [self createPlaceholderViewForStixView:cview andKey:key andTagID:tagID];
        }
         */
        return placeholder;
        //return placeholderViewGlobal;
    }
    return [contentViews objectForKey:key];
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
                [k getPixByPopularityWithNumPix:[NSNumber numberWithInt:numPix]];
                for (int i=0; i<numPix; i++)
                    [allTagIDs addObject:[NSNull null]];
                pendingContentCount += numPix;
                NSLog(@"Pending content count: %d", pendingContentCount);
            }
            else {
                NSLog(@"No need!");
            }
            break;
            
        case EXPLORE_RECENT:
            if (row == -1) {
                // load initial row(s)
                NSDate * now = [NSDate date]; // now
                //[k getUpdatedPixByTimeWithTimeUpdated:now andNumPix:[NSNumber numberWithInt:numColumns * 5]];
                int numPix = numColumns * 5;
                [k getPixByRecentWithTimeCreated:now andNumPix:[NSNumber numberWithInt:numPix]];
                for (int i=0; i<numPix; i++)
                    [allTagIDs addObject:[NSNull null]];
                pendingContentCount += numPix;
            }
            else {
                if (indexPointer > 0)
                //if ([allTagIDs lastObject] != [NSNull null])
                {
                    NSNumber * tagID = [allTagIDs objectAtIndex:indexPointer-1];
                    Tag * tag = [allTags objectForKey:tagID];
                    NSDate * lastUpdated = [tag.timestamp dateByAddingTimeInterval:-1];
                    //[k getUpdatedPixByTimeWithTimeUpdated:lastUpdated andNumPix:[NSNumber numberWithInt:numColumns * 5]];
                    int numPix = numColumns * 5;
                    [k getPixByRecentWithTimeCreated:lastUpdated andNumPix:[NSNumber numberWithInt:numPix]];
                    for (int i=0; i<numColumns * 5; i++)
                        [allTagIDs addObject:[NSNull null]];
                    pendingContentCount += numColumns * 5;
                }
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
                [allTagIDs addObject:[NSNull null]];
            }
        }
        default:
            break;
    }
    [tableController.tableView reloadData];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getPixByPopularityDidCompleteWithResult:(NSArray *)theResults {
    if (exploreMode != EXPLORE_POPULAR)
        return;
    
    NSLog(@"Received %d popular results", [theResults count]);

    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];
        Tag * newtag = [Tag getTagFromDictionary:d];
        //[allTagIDs addObject:newtag.tagID]; // save in order 
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
        [self fakeDidGetAuxiliaryStixOfTagWithID:newtag.tagID];
#endif
        // don't know why this happens but sometimes it does!
        pendingContentCount--;
        if (pendingContentCount < 0)
            pendingContentCount = 0;
        
    }
    if ([theResults count]>0)
        [tableController dataSourceDidFinishLoadingNewData];
    [self stopActivityIndicator];
    //[activityIndicator stopCompleteAnimation];
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUpdatedPixByTimeDidCompleteWithResult:(NSArray *)theResults {
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getPixByRecentDidCompleteWithResult:(NSArray *)theResults {
    if (exploreMode != EXPLORE_RECENT)
        return;
    
    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];
        Tag * newtag = [Tag getTagFromDictionary:d];
        //[allTagIDs addObject:newtag.tagID]; // save in order 
        if ([allTags objectForKey:newtag.tagID] == nil) {
            [allTagIDs replaceObjectAtIndex:indexPointer++ withObject:newtag.tagID];
            [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary        
        }
        
        // new system of auxiliary stix: request from auxiliaryStixes table
        // even though we don't have aux stix, we need this to switch out of the placeholder
#if 0
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newtag.tagID, nil]; 
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        [kh execute:@"getAuxiliaryStixOfTag" withParams:params withCallback:@selector(khCallback_didGetAuxiliaryStixOfTag:) withDelegate:self];
#else
        [self fakeDidGetAuxiliaryStixOfTagWithID:newtag.tagID];
#endif

        // don't know why this happens but sometimes it does!
        pendingContentCount--;
        if (pendingContentCount < 0)
            pendingContentCount = 0;

        //NSLog(@"Explore recent tags: Downloaded tag ID %d at position %d pending content: %d allTagIDs %d allTags %d", [newtag.tagID intValue], [allTagIDs count], pendingContentCount, [allTagIDs count], [allTags count]);
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
            //[allTagIDs addObject:newtag.tagID]; // save in order 
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

-(void)fakeDidGetAuxiliaryStixOfTagWithID:(NSNumber *) tagID {
    NSLog(@"FakeDidGetAuxiliaryStix being called to update tag %@", tagID);
    Tag * tag = [allTags objectForKey:tagID];
    if (tag) {
        //[tag populateWithAuxiliaryStix:theResults];
        NSNumber * key = nil;
        for (int i=0; i<[allTagIDs count]; i++) {
            NSNumber * tID = [allTagIDs objectAtIndex:i];
            if (tID == tagID) {
                // remove contentView for a given index. contentViews are indexed by cell number, not by tagID
                key = [NSNumber numberWithInt:i];
                [contentViews removeObjectForKey:key];
                break;
            }
        }
        if (key)
            [isShowingPlaceholderView setObject:[NSNumber numberWithBool:NO] forKey:key];
        [tableController.tableView reloadData];
    }
}

-(void)khCallback_didGetAuxiliaryStixOfTag:(NSMutableArray *) returnParams {
    NSNumber * tagID = [returnParams objectAtIndex:0];
    NSMutableArray * theResults = [returnParams objectAtIndex:1];
    
    //NSLog(@"Got auxiliary stix of tag %d with %d stix!", [tagID intValue], [theResults count]);
//    if ([theResults count] > 0) {
        Tag * tag = [allTags objectForKey:tagID];
        if (tag) {
            [tag populateWithAuxiliaryStix:theResults];
            NSNumber * key = nil;
            for (int i=0; i<[allTagIDs count]; i++) {
                NSNumber * tID = [allTagIDs objectAtIndex:i];
                if (tID == tagID) {
                    // remove contentView for a given index. contentViews are indexed by cell number, not by tagID
                    key = [NSNumber numberWithInt:i];
                    [contentViews removeObjectForKey:key];
                    break;
                }
            }
            if (key)
                [isShowingPlaceholderView setObject:[NSNumber numberWithBool:NO] forKey:key];
            [tableController.tableView reloadData];
            return;
        }
//    }
}


-(void)forceReloadAll {    
    [allTags removeAllObjects];
    [allTagIDs removeAllObjects];
    [contentViews removeAllObjects];
    [placeholderViews removeAllObjects];
    [isShowingPlaceholderView removeAllObjects];
    pendingContentCount = 0;
    indexPointer = 0;
    [self.tableController.tableView reloadData];
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
    //openDetailAnimation = [animation doSlide:detailController.view inView:self.view toFrame:frameOnscreen forTime:.25];
    [animation doViewTransition:detailController.view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished) {
        [DetailViewController unlockOpen];
    }];
    
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

-(void)didAddCommentFromDetailViewController:(DetailViewController*)detailViewController withTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID {
    [delegate didAddCommentFromDetailViewController:detailViewController withTagID:tagID andUsername:name andComment:comment andStixStringID:stixStringID];
}

-(void)didDismissZoom {
    isZooming = NO;
    if (detailController) {
        [detailController.view removeFromSuperview];
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
    
    [animation doViewTransition:detailController.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
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

#pragma kumulosHelper callback
-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    [self performSelector:callback withObject:params afterDelay:0];
}

-(void)viewDidUnload {
    
    activityIndicator = nil;

    [super viewDidUnload];
}

#pragma mark stix editor
-(void)didClickRemixFromDetailViewWithTag:(Tag*)tag {
    //[delegate didClickRemixFromDetailViewWithTag:tagToRemix];
    [self setTagToRemix:[tag copy]];
    NSLog(@"Did click remix with with tagID %@ by %@, creating tagToRemix with ID %@", tag.tagID, tag.username, tagToRemix.tagID);
    if (tagToRemix.stixLayer) {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to remix?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remixed Photo", @"Original Photo", nil];
        //    [actionSheet showFromRect:CGRectMake(0, 0, 320,480) inView:self.view animated:YES];
        [actionSheet showFromTabBar:tabBarController.tabBar];
    }
    else {
        // close detail view first
        /*
]        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        CGRect frameOffscreen = detailController.view.frame;
        frameOffscreen.origin.x -= 330;
        
        [animation doViewTransition:detailController.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
            [detailController.view removeFromSuperview];
            [DetailViewController unlockOpen];
        }];
         */
        [detailController.view removeFromSuperview];
        [DetailViewController unlockOpen];
        
        // no previous stix exist, automatically choose original mode
        [delegate shouldDisplayStixEditor:[detailController.tag copy] withRemixMode:REMIX_MODE_USEORIGINAL];
    }
    [delegate didClickRemixButton]; // just to advance first time message, metrics, etc
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //    BOOL bUseOriginal = NO;
    int remixMode;
    if (buttonIndex == 0) {
        // remixed photo
        NSLog(@"Button 0");
        remixMode = REMIX_MODE_ADDSTIX;
    }
    else if (buttonIndex == 1) {
        // original photo
        NSLog(@"Button 1");
        remixMode = REMIX_MODE_USEORIGINAL;
    }
    else if (buttonIndex == 2) {
        NSLog(@"Button 2");
        tagToRemix = nil;
        return;
    }
    
    // close detailView first - click came from here
    /*
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = detailController.view.frame;
    frameOffscreen.origin.x -= 330;
    
    [animation doViewTransition:detailController.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [detailController.view removeFromSuperview];
        [DetailViewController unlockOpen];
    }];
*/
    [detailController.view removeFromSuperview];
    [DetailViewController unlockOpen];
    
    [delegate shouldDisplayStixEditor:[detailController.tag copy] withRemixMode:remixMode];
}

// first time message function calls from VerticalFeedItemController that shouldn't be needed here
-(void)didCloseEditor {
    [delegate didDismissSecondaryView];
    //[stixEditorController.view removeFromSuperview];    
}

@end
