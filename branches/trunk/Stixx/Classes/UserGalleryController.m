//
//  UserGalleryController.m
//  Stixx
//
//  Created by Bobby Ren on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserGalleryController.h"

@implementation UserGalleryController

@synthesize username;
@synthesize delegate;
@synthesize k;
@synthesize activityIndicator;
@synthesize pixTableController;
@synthesize headerView;
@synthesize detailController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    allTagIDs = [[NSMutableArray alloc] init];
    allTags = [[NSMutableDictionary alloc] init];
    contentViews = [[NSMutableDictionary alloc] init];
    placeholderViews = [[NSMutableDictionary alloc] init];
    isShowingPlaceholderView = [[NSMutableDictionary alloc] init];
    
    pendingContentCount = 0;

    if (!pixTableController) {
        CGRect frame = CGRectMake(0,44, 320, 460-44);
        pixTableController = [[ColumnTableController alloc] init];
        [pixTableController.view setFrame:frame];
        [pixTableController.view setBackgroundColor:[UIColor clearColor]];
        pixTableController.delegate = self;
        numColumns = 3;
        [pixTableController setNumberOfColumns:numColumns andBorder:4];
        [self.view addSubview:pixTableController.view];
    }
    k = [[Kumulos alloc] init];
    [k setDelegate:self];

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 9, 25, 25)];
    [self.view addSubview:activityIndicator];
    [self forceReloadAll];
    
#if USING_FLURRY == 1
    if (!IS_ADMIN_USER([self getUsername]))
        [FlurryAnalytics logPageView];
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    headerView = nil;
    pixTableController = nil;
    k = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark ColumnTableController delegate

-(UIView*)headerForSection:(NSInteger)section {
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        [headerView setBackgroundColor:[UIColor blackColor]];
        [headerView setAlpha:.75];
        
        UIImage * photo = [delegate getUserPhotoForUsername:username];
        UIImageView * photoView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 5, 30, 30)];
        [photoView setImage:photo];
        [headerView addSubview:photoView];
        
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 260, 30)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [nameLabel setText:username];
        [headerView addSubview:nameLabel];
    }
    return headerView;  
}

-(int)heightForHeader {
    return 40;
}

-(int)numberOfRows {
    double total = [allTagIDs count];
    //NSLog(@"allTagIDs has %d items", total);
    return ceil(total / numColumns);
}

-(void)createPlaceholderViewForStixView:(StixView*)cview andKey:(NSNumber*)key andTagID:(NSNumber*)tagID{
#if 1
    UIImageView * placeholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_emptypic.png"]];
    [placeholderView setCenter:cview.center];
    LoadingAnimationView * loadingAnimation = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [loadingAnimation setCenter:cview.center];
    [loadingAnimation startCompleteAnimation];
    [placeholderView addSubview:loadingAnimation];
    [placeholderViews setObject:placeholderView forKey:key];
#else
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

    NSNumber * tagID = [allTagIDs objectAtIndex:index];
    //NSLog(@"ViewItemAtIndex: %d tagid %d", index, [tagID intValue]);

    if ([contentViews objectForKey:key] == nil) {
        Tag * tag = [allTags objectForKey:tagID];
        
        //UIImageView * cview = [[UIImageView alloc] initWithImage:tag.image];
        
        int contentWidth = [pixTableController getContentWidth];
        int targetWidth = contentWidth;
        int targetHeight = PIX_HEIGHT * targetWidth / PIX_WIDTH    ; //tagImageSize.height * scale;
        CGRect frame = CGRectMake(0, 0, targetWidth, targetHeight);
        StixView * cview = [[StixView alloc] initWithFrame:frame];
        [cview setInteractionAllowed:YES];
        [cview setIsPeelable:NO];
        [cview setDelegate:self];
        [cview initializeWithImage:tag.image andStixLayer:tag.stixLayer];
        // sometimes requests just fail and never show up
        [cview populateWithAuxStixFromTag:tag];
        if (![isShowingPlaceholderView objectForKey:tagID]) {
            cview.isShowingPlaceholder = YES;
            [isShowingPlaceholderView setObject:[NSNumber numberWithBool:YES] forKey:tagID];
            
            [self createPlaceholderViewForStixView:cview andKey:key andTagID:tagID];
        }
        else {
            cview.isShowingPlaceholder = [[isShowingPlaceholderView objectForKey:tagID] boolValue];
        }
        [contentViews setObject:cview forKey:key];    
    }
    StixView * cview = [contentViews objectForKey:key];
    if (cview.isShowingPlaceholder)
        return [placeholderViews objectForKey:key];
        //return placeholderViewGlobal;
    return [contentViews objectForKey:key];
}

-(void)loadContentPastRow:(int)row {
    if (pendingContentCount > 0) {
        NSLog(@"Trying to load past row %d: still waiting on %d pending contents", row, pendingContentCount);
        return;
    }
    //NSLog(@"Loading row %d of total %d for gallery of user %@", row, [self numberOfRows], username);
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
    lastRowRequest = row;
    if (row == -1) {
        // load initial row(s)
        NSDate * now = [NSDate date]; // now
        //[k getUserPixByTimeWithUsername:username andLastUpdated:now andNumRequested:[NSNumber numberWithInt:(numColumns*5)]];
        [k getUserPixByUpdateTimeWithUsername:username andTimeUpdated:now andNumRequested:[NSNumber numberWithInt:(numColumns*5)]];
        pendingContentCount += numColumns * 5;
    }
    else {
        NSNumber * tagID = [allTagIDs lastObject];
        Tag * tag = [allTags objectForKey:tagID];
        NSDate * lastUpdated = [tag.timestamp dateByAddingTimeInterval:-1];
        //[k getUserPixByTimeWithUsername:username andLastUpdated:lastUpdated andNumRequested:[NSNumber numberWithInt:(numColumns*3)]];
        [k getUserPixByUpdateTimeWithUsername:username andTimeUpdated:lastUpdated andNumRequested:[NSNumber numberWithInt:(numColumns*3)]];
        pendingContentCount += numColumns * 3;
        //NSLog(@"lastUpdated: %@ pendingCount: %d lastRowRequest: %d", lastUpdated, pendingContentCount, lastRowRequest);
        // debug
        /*
        if ([allTagIDs count] > 5) {
            for (int i=0; i<5; i++) {
                NSNumber * tagID = [allTagIDs objectAtIndex:[allTagIDs count]-i-1];
                Tag * tag = [allTags objectForKey:tagID];
                NSDate * timestamp = [tag.timestamp dateByAddingTimeInterval:-1];
                NSLog(@"Last %d tag in allTags: tagID %d timestamp %@", i, [tag.tagID intValue], timestamp);
            }
            NSLog(@"Total: %d", [allTagIDs count]);
        }
         */
    }
}

-(void)didPullToRefresh {
    [self forceReloadAll];
}

#pragma mark KumulosDelegate functions
//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPixByTimeDidCompleteWithResult:(NSArray *)theResults {
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPixByUpdateTimeDidCompleteWithResult:(NSArray *)theResults {
    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];
        Tag * newtag = [Tag getTagFromDictionary:d];
        [allTagIDs addObject:newtag.tagID]; // save in order 
        //NSLog(@"Explore recent tags: Downloaded tag ID %d at position %d", [newtag.tagID intValue], [allTagIDs count]);
        [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary

        // new system of auxiliary stix: request from auxiliaryStixes table
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newtag.tagID, nil]; 
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        [kh execute:@"getAuxiliaryStixOfTag" withParams:params withCallback:@selector(khCallback_didGetAuxiliaryStixOfTag:) withDelegate:self];
        
        pendingContentCount--;
        if (pendingContentCount <= 0)
            pendingContentCount = 0;            

        //NSLog(@"MyUserGallery recent tags: Downloaded tag ID %d at position %d pending content: %d allTagIDs %d allTags %d", [newtag.tagID intValue], [allTagIDs count], pendingContentCount, [allTagIDs count], [allTags count]);
}
    if ([theResults count]>0)
        [pixTableController dataSourceDidFinishLoadingNewData];
    [self stopActivityIndicator];
}

-(void)khCallback_didGetAuxiliaryStixOfTag:(NSMutableArray *) returnParams {
    NSNumber * tagID = [returnParams objectAtIndex:0];
    NSMutableArray * theResults = [returnParams objectAtIndex:1];
    
    NSLog(@"Got auxiliary stix of tag %d with %d stix!", [tagID intValue], [theResults count]);
    //    if ([theResults count] > 0) {
    Tag * tag = [allTags objectForKey:tagID];
    if (tag) {
        [tag populateWithAuxiliaryStix:theResults];
        for (int i=0; i<[allTagIDs count]; i++) {
            NSNumber * tID = [allTagIDs objectAtIndex:i];
            if (tID == tagID) {
                // remove contentView for a given index. contentViews are indexed by cell number, not by tagID
                [contentViews removeObjectForKey:[NSNumber numberWithInt:i]];
                break;
            }
        }
        [isShowingPlaceholderView setObject:[NSNumber numberWithBool:NO] forKey:tagID];
        [pixTableController.tableView reloadData];
        return;
    }
}

#pragma other functions
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

-(void)forceReloadAll {    
    [allTags removeAllObjects];
    [allTagIDs removeAllObjects];
    [contentViews removeAllObjects];
    [placeholderViews removeAllObjects];
    [isShowingPlaceholderView removeAllObjects];
    pendingContentCount = 0;
    [self loadContentPastRow:-1];
    //isZooming = NO;
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
}

-(IBAction)didClickBackButton:(id)sender {
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = self.view.frame;
    frameOffscreen.origin.x -= 330;
    //dismissAnimation = [animation doSlide:self.view inView:self.view toFrame:frameOffscreen forTime:.25];
    [animation doViewTransition:self.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}
-(void)didFinishAnimation:(int)animID withCanvas:(UIView *)canvas {
    if (animID == dismissAnimation) {
        [self.view removeFromSuperview];
    }
}
#pragma mark DetailView 
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
    [detailController setScrollHeight:370];
    [detailController.view setFrame:frameOffscreen];
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doSlide:detailController.view inView:self.view toFrame:frameOnscreen forTime:.25];

#if USING_FLURRY
    if (!IS_ADMIN_USER([self getUsername]))
        [FlurryAnalytics logEvent:@"DetailViewFromMyGallery" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", tagID, @"tagID", nil]];
#endif
}

-(void)shouldDisplayUserPage:(NSString *)name {
    [self didClickBackButton:nil];
    [delegate shouldDisplayUserPage:name];
}

-(void)shouldCloseUserPage {
    [delegate shouldCloseUserPage];
}

-(void)didAddCommentFromDetailViewController:(DetailViewController*)detailViewController withTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID {
    [delegate didAddCommentFromDetailViewController:detailViewController withTagID:tagID andUsername:name andComment:comment andStixStringID:stixStringID];
}

-(void)didDismissZoom {
    [detailController.view removeFromSuperview];
    detailController = nil;
}

-(NSString*)getUsername {
    return username;
}

-(UIImage*)getUserPhotoForUsername:(NSString*)name {
    return [delegate getUserPhotoForUsername:name];
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
            [pixTableController.tableView reloadData];
            break;
        }
    }
}

#pragma kumulosHelper callback
-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    [self performSelector:callback withObject:params afterDelay:0];
}

#pragma mark remix hack
-(void)didClickRemixFromDetailViewWithTag:(Tag*)tagToRemix {
    [DetailViewController unlockOpen];
    [delegate didClickRemixFromDetailViewWithTag:tagToRemix];
}

@end
