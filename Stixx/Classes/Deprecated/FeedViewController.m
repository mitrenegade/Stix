///
//  FeedViewController.m
//  Stixx
//
//  Created by Administrator on 7/25/11.
//  Copyright 2011 Neroh. All rights reserved.
//
//  TODO: 
//  load from StixxAppDelegate.allTags when viewDidLoad is called
//  load from kumulos only on refresh - add pulldown to refresh allTags structure
//  save to kumulos if internet is available
//  change name for tags by current user to login name if logged in
//  correctly display title and subtitle
// save id of last feed viewed and start there
// load only a certain number of feeds
// fast browse of feeds
// add indicator while loading from kumulos

#import "FeedViewController.h"

@implementation FeedViewController

@synthesize feedItems;
//@synthesize badgeView;
@synthesize carouselView;
@synthesize nameLabel;
@synthesize delegate;
@synthesize activityIndicator; // initially is active
@synthesize userPhotos;
@synthesize allTags;
@synthesize scrollView;
@synthesize lastPageViewed;
@synthesize zoomViewController;
@synthesize commentView;
@synthesize buttonFeedback;
@synthesize camera;

-(id)init
{
	self = [super initWithNibName:@"FeedViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"Feed"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_feed.png"];
	[tbi setImage:i];
    
    lastPageViewed = -1;
    
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    lastPageViewed = 0;
    
    [self initializeScrollWithPageSize:CGSizeMake(FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)];
    scrollView.isLazy = YES;
//    [self.view addSubview:scrollView];
    [self.view insertSubview:scrollView belowSubview:[self buttonFeedback]];
    
	/****** init badge view ******/
    [self createCarouselView];
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(10, 11, 25, 25)];
    [self.view addSubview:activityIndicator];
    
    //zoomViewController = [[ZoomViewController alloc] init];
    
    // array to retain each FeedItemViewController as it is created so its callback
    // for the button can be used
    feedItems = [[NSMutableDictionary alloc] init]; 
}

-(void)createCarouselView {
    if (carouselView != nil && [carouselView isKindOfClass:[CarouselView class]]) {
        [carouselView clearAllViews];
        [carouselView release];
    }
    carouselView = [[CarouselView alloc] initWithFrame:self.view.frame];
    carouselView.delegate = self;
    [carouselView setDismissedTabY:380];
    [carouselView initCarouselWithFrame:CGRectMake(0,carouselView.dismissedTabY,320,SHELF_STIX_SIZE)];
    
    [self.view insertSubview:carouselView aboveSubview:scrollView];
    [carouselView setUnderlay:scrollView];
    [delegate didCreateBadgeView:carouselView];
}

-(void)reloadCarouselView {
    [carouselView setDismissedTabY:380];
    [[self carouselView] reloadAllStixWithFrame:CGRectMake(0,carouselView.dismissedTabY,320,SHELF_STIX_SIZE)];
    [[self carouselView] removeFromSuperview];
    [self.view insertSubview:carouselView aboveSubview:scrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
	//[imageView setImage:[[ImageCache sharedImageCache] imageForKey:@"newImage"]];
	[super viewWillAppear:animated];
    
    //[self.delegate checkForUpdateTags];

    self.allTags = [self.delegate getTags];
    self.userPhotos = [self.delegate getUserPhotos]; 
    NSLog(@"Loaded %d tags and %d users", [self.allTags count], [self.userPhotos count]);

    [scrollView populateScrollPagesAtPage:lastPageViewed];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [carouselView resetBadgeLocations];  
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
    //[scrollView clearNonvisiblePages];
}

//-(void)didClearPage:(int)page {
//    [[feedItems objectAtIndex:page] release];
//}

- (void)viewDidUnload {
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
    [activityIndicator release];
    [nameLabel release];
    
    activityIndicator = nil;

    nameLabel = nil;

    [carouselView release];
    carouselView = nil;
    [scrollView release];
    scrollView = nil;

    [super viewDidUnload];
}


- (void)dealloc 
{
	[allTags release];
    [activityIndicator release];
    [nameLabel release];
    
    activityIndicator = nil;
    nameLabel = nil;

    [carouselView release];
    carouselView = nil;
    [scrollView release];
    scrollView = nil;

    [super dealloc];
}

/******* badge view delegate ******/
-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID {
    // stix dropped onto the image are the correct size relative to the feed image's imageView. That means they are
    // already scaled down to fit correctly in a 250x230 sized pix. the center of the badge is still in full window coordinates
    // so it must be corrected.
    
    // increment stix count for given feed item
    // badge's frame is currently in carouselView space which is the full screen
    
    if ([allTags count] == 0) {
        // nothing loaded yet
        [carouselView resetBadgeLocations];
        return;
    }
    allTags = [self.delegate getTags];
    Tag * t = (Tag*) [allTags objectAtIndex:lastPageViewed];   
    
    NSLog(@"Dropped new %@ stix onto tag %d: id %d auxStix %d lastStix %@", stixStringID, lastPageViewed, [t.tagID intValue], [t.auxStixStringIDs count], [t.auxStixStringIDs objectAtIndex:[t.auxStixStringIDs count]-1]);
    
    // scale stix frame back to full 300x275 size
    FeedItemViewController * feedItem = [feedItems objectForKey:t.tagID];
	float imageScale = 300/feedItem.imageView.frame.size.width; // the user is using the badge size relative to the current view
    
    NSLog(@"FeedView: added stix of size %f %f at location %f %f (whole window's frame) in view %f %f\n", badge.frame.size.width, badge.frame.size.height, badge.center.x, badge.center.y, feedItem.imageView.frame.size.width, feedItem.imageView.frame.size.height);
    
	CGRect stixFrameScaled = badge.frame;
    CGRect scrollFrame = scrollView.frame;
    CGRect imageViewFrame = feedItem.imageView.frame;
    float centerx = badge.center.x - (scrollFrame.origin.x + imageViewFrame.origin.x);
    float centery = badge.center.y - (scrollFrame.origin.y + imageViewFrame.origin.y);
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    [badge setFrame:stixFrameScaled];
    CGPoint location = CGPointMake(centerx * imageScale, centery * imageScale); 
    [badge setCenter:location];
    NSLog(@"Offsetting center by %f %f to %f %f, then scaling to %f %f\n", scrollFrame.origin.x + imageViewFrame.origin.x, scrollFrame.origin.y + imageViewFrame.origin.y, centerx, centery, location.x, location.y);

    // at this point, location and badgeFrame are all relative to feedItem.frame, at full size (300px). NOT QUITE ACCURATE PLACEMENT
    NSLog(@"FeedView: aux stix scaled to size %f %f at location %f %f in view %f %f\n", stixFrameScaled.size.width, stixFrameScaled.size.height, badge.center.x, badge.center.y, feedItem.imageView.frame.size.width*imageScale, feedItem.imageView.frame.size.height*imageScale);
    AuxStixViewController * auxView = [[AuxStixViewController alloc] init];

    // hack a way to display view over camera; formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [auxView.view setFrame:frameShifted];
#if !TARGET_IPHONE_SIMULATOR
    [self.camera setCameraOverlayView:auxView.view];
#endif    
    auxView.delegate = self;
    [auxView initStixView:t];
    [auxView addNewAuxStix:badge ofType:stixStringID atLocation:location];    
}

-(void)didAddAuxStixWithStixStringID:(NSString*)stixStringID withLocation:(CGPoint)location /*withScale:(float)scale withRotation:(float)rotation */withTransform:(CGAffineTransform)transform withComment:(NSString *)comment {

    // hack a way to remove view over camera; formerly dismissModalViewController
    [self.delegate didDismissSecondaryView];
    
    Tag * t = (Tag*) [allTags objectAtIndex:lastPageViewed];   
    [delegate didAddStixToPix:t withStixStringID:stixStringID withLocation:location /*withScale:scale withRotation:rotation*/ withTransform:transform];
    if ([comment length] > 0)
        [self didAddNewComment:comment withTagID:[t.tagID intValue]];

    //    NSLog(@"Now tag id %d: %@ stix count is %d. User has %d left", [t.tagID intValue], badgeTypeStr, t.badgeCount, [delegate getStixCount:type]);
    [carouselView resetBadgeLocations];
    [scrollView reloadPage:lastPageViewed];
}

-(void)didCancelAuxStix {
    // hack a way to remove view over camera; formerly dismissModalViewController
    [self.delegate didDismissSecondaryView];
}

-(int)getStixCount:(NSString*)stixStringID {
    return [self.delegate getStixCount:stixStringID];
}
-(int)getStixOrder:(NSString*)stixStringID {
    return [self.delegate getStixOrder:stixStringID];
}
/*********** PagedScrollViewDelegate functions *******/

-(void)initializeScrollWithPageSize:(CGSize)pageSize
{
    // We need to do some setup once the view is visible. This will only be done once.
    // Position and size the scrollview. It will be centered in the view.    
    CGRect scrollViewRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
    scrollViewRect.origin.x = ((self.view.frame.size.width - pageSize.width) / 2);
    scrollViewRect.origin.y = ((self.view.frame.size.height - pageSize.height) / 2);
    
    scrollView = [[PagedScrollView alloc] initWithFrame:scrollViewRect];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    scrollView.clipsToBounds = NO; // Important, this creates the "preview"
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.myDelegate = self; // needs delegates for both scrolls
    scrollView.delegate = self;
}

 -(UIView*)viewForItemAtIndex:(int)index
{	    
    /*
    for (int j=0; j<[allTags count]; j++) {
        Tag * tt = [allTags objectAtIndex:j];
        NSLog(@"Tag %d id %d descriptor %@\n", j, [tt.tagID intValue], tt.descriptor);
        NSLog(@"  StringID %@", tt.stixStringID);
    }
     */

    Tag * tag = [allTags objectAtIndex:index];
    FeedItemViewController * feedItem = [feedItems objectForKey:tag.tagID];
    if (!feedItem) {
        NSString * name = tag.username;
        NSString * descriptor = tag.descriptor;
        NSString * comment = tag.comment;
        NSString * locationString = tag.locationString;
        //int tagID = [tag.tagID intValue];
        //UIImage * image = tag.image;
        //NSLog(@"Creating feed item %d at index %d: name %@ comment %@ dims %f %f\n", tagID, index, name, comment, image.size.width, image.size.height);
        
        feedItem = [[[FeedItemViewController alloc] init] autorelease];
        [feedItem setDelegate:self];
        [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString];// andWithImage:image];
        [feedItem.view setFrame:CGRectMake(0, 0, FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)]; 
        [carouselView setSizeOfStixContext:feedItem.imageView.frame.size.width];
        UIImage * photo = [[UIImage alloc] initWithData:[userPhotos objectForKey:name]];
        if (photo)
        {
            //NSLog(@"User %@ has photo of size %f %f\n", name, photo.size.width, photo.size.height);
            [feedItem populateWithUserPhoto:photo];
            [photo autorelease]; // MRC
        }
        // add timestamp
        [feedItem populateWithTimestamp:tag.timestamp];
        // add badge and counts
        [feedItem initStixView:tag];
        feedItem.tagID = [tag.tagID intValue];
        int count = [self.delegate getCommentCount:feedItem.tagID];
        [feedItem populateWithCommentCount:count];
        
        // this object must be retained so that the button actions can be used
        [feedItems setObject:feedItem forKey:tag.tagID];
    }
    return feedItem.view;
}

-(void)jumpToPageWithTagID:(int)tagID {
#if 0
    if ([feedItems objectForKey:tagID] == nil) {
        NSLog(@"Feed item does not exist!");
        // todo: load pages there
    }
    else 
#else
    if (1)
#endif
    {
        // find position of tag in allTags
        for (int i=0; i<[allTags count]; i++) {
            Tag * t = [allTags objectAtIndex:i];
            if ([t.tagID intValue] == tagID) {
                [scrollView jumpToPage:i];
            }
        }
    }
}

-(IBAction)didClickJumpButton:(id)sender {
    [scrollView jumpToPage:0];
}

-(void)updateScrollPagesAtPage:(int)page {
    //NSLog(@"UpdateScrollPagesAtPage %d: AllTags currently has %d elements", page, [allTags count]);
    if ([self itemCount] > 0) {
        if (page < 0 + LAZY_LOAD_BOUNDARY) { // trying to find a more recent tag
            Tag * t = (Tag*) [allTags objectAtIndex:0];
            int tagid = [t.tagID intValue];
            [self.delegate getNewerTagsThanID:tagid];            
        }
        if (page >= [self itemCount] - LAZY_LOAD_BOUNDARY) { // trying to load an earlier tag
            Tag * t = (Tag*) [allTags objectAtIndex:[self itemCount]-1];
            int tagid = [t.tagID intValue];
            [self.delegate getOlderTagsThanID:tagid];
        }
    }
    else
    {
        // no tags are loaded, just get the first few
        //[self.delegate getMostRecentTags];        
        // should not come here!
        //NSLog(@"Error! allTags was never seeded!");
        [self.delegate checkForUpdateTags];
        [self.activityIndicator startCompleteAnimation];
    }
}

-(void)reloadCurrentPage {
    // forces scrollview to clear view at lastPageViewed, forces self to recreate FeedItem at lastPageViewed, assumes updated allTags from the app delegate
    self.allTags = [self.delegate getTags];
    [scrollView reloadPage:lastPageViewed];
}

-(int)itemCount
{
	// Return the number of pages we intend to display
	return [self.allTags count];
}

// uiscrollview delegate - pass to PagedScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)sv
{
    if (sv == scrollView) 
    {
        PagedScrollView * psv = (PagedScrollView *)sv;
        int page = [psv currentPage];
        
        // determine direction, for indicators
        if (lastContentOffset < scrollView.contentOffset.x) { // right
            if (page == [self itemCount] - 1)
                [self.activityIndicator startCompleteAnimation];
        }
        else if (lastContentOffset > scrollView.contentOffset.x) { // left 
            if (page == 0)
                [self.activityIndicator startCompleteAnimation];
        }
        
        lastContentOffset = scrollView.contentOffset.x;
        lastPageViewed = page;

        // Load the visible and neighbouring pages 
        if (page>=0)
            [psv loadPage:page-1]; // if we are at page=0, this is a pull to refresh
        [psv loadPage:page];
        [psv loadPage:page+1];
    }
}

-(void)forceReloadAll {
    [scrollView clearAllPages];
}

-(void)forceUpdateCommentCount:(int)tagID {
    // this function is called after StixxAppDelegate has retrieved the comment
    // count from kumulos and inserted it into the allCommentCounts array
    
    //for (int i=0; i<[feedItems count]; i++) {
    FeedItemViewController * curr = [feedItems objectForKey:[NSNumber numberWithInt:tagID]];
    [curr populateWithCommentCount:[self.delegate getCommentCount:tagID]];
    
    [scrollView reloadPage:lastPageViewed];
}

/************** FeedZoomView ***********/
#define DO_ZOOM_VIEW 0
-(void)didClickAtLocation:(CGPoint)location {
    location.x -= scrollView.contentOffset.x;
    NSLog(@"FeedViewController: Click on page %d at position %f %f\n", [scrollView currentPage], location.x, location.y);
    
#if DO_ZOOM_VIEW
    Tag * tag = [allTags objectAtIndex:[scrollView currentPage]];
    UIImage * image = tag.image;
    NSString * label = tag.comment;
    NSString * locationStr = tag.locationString;
   
    [zoomViewController setDelegate:self];
    [self.view insertSubview:zoomViewController.view aboveSubview:badgeView];
    [zoomViewController forceImageAppear:image];
    [zoomViewController setLabel:label];
    [zoomViewController setLocation:locationStr];
#endif
    
    Tag * tag = [allTags objectAtIndex:[scrollView currentPage]];
    CGPoint locationInFeedItem = location;
    //locationInFeedItem.x -= lastContentOffset; // converts to feedItem frame
    
    FeedItemViewController * feedItem = [feedItems objectForKey:tag.tagID];
    CGPoint locationInStixView = locationInFeedItem;
    locationInStixView.x -= feedItem.stixView.frame.origin.x;
    locationInStixView.y -= feedItem.stixView.frame.origin.y;
    [[feedItem stixView] findPeelableStixAtLocation:locationInStixView];
}

-(void)didDismissZoom {
#if DO_ZOOM_VIEW
    [zoomViewController.view removeFromSuperview];
#endif
}

/*** feedItemViewDelegate ****/
-(void)displayCommentsOfTag:(int)tagID andName:(NSString *)nameString{
    if (commentView == nil) {
        commentView = [[CommentViewController alloc] init];
        [commentView setDelegate:self];
    }
    [commentView initCommentViewWithTagID:tagID andNameString:nameString];
    //[commentView setTagID:tagID];
    //[commentView setNameString:nameString];

    // hack a way to display view over camera; formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [commentView.view setFrame:frameShifted];
#if !TARGET_IPHONE_SIMULATOR
    [self.camera setCameraOverlayView:commentView.view];
#endif
}
    
// hack: forced display of comment page
-(void)openCommentForPageWithTagID:(NSNumber*)tagID {
    FeedItemViewController * feedItem = [feedItems objectForKey:tagID];
    if (feedItem != nil)
        [feedItem didPressAddCommentButton:self];
}

/*** CommentViewDelegate ***/
-(void)didCloseComments {
    // hack a way to remove view over camera; formerly dismissModalViewController
    [self.delegate didDismissSecondaryView]; // same as aux view
    //[commentView release];
    //commentView = nil;
}

-(void)didAddNewComment:(NSString *)newComment withTagID:(int)tagID{
    NSString * name = [self.delegate getUsername];
    //int tagID = [commentView tagID];
    if ([newComment length] > 0)
        [self.delegate didAddCommentWithTagID:tagID andUsername:name andComment:newComment andStixStringID:@"COMMENT"];
    [self didCloseComments];
}

-(IBAction)feedbackButtonClicked:(id)sender {
    [self.delegate didClickFeedbackButton:@"Feed view"];
}

/*** FeedViewItemDelegate, forwarded from StixViewDelegate ***/
-(NSString*)getUsername {
    return [self.delegate getUsername];
}

-(void)didPerformPeelableAction:(int)action forAuxStix:(int)index {
    // change local tag structure for immediate display
    Tag * tag = [allTags objectAtIndex:lastPageViewed];
    if (action == 0) {
        // peel stix
        [tag removeStixAtIndex:index];
    }
    else if (action == 1) {
        // attach stix
        [[tag auxPeelable] replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];
        [allTags replaceObjectAtIndex:lastPageViewed withObject:tag];
    }
    //[self reloadCurrentPage];
    
    // tell app delegate to reload tag before altering internal info
    [self.delegate didPerformPeelableAction:action forTagWithIndex:lastPageViewed forAuxStix:index];
}

-(IBAction)adminStixButtonPressed:(id)sender {
    [self.delegate didPressAdminEasterEgg:@"FeedView"];
}
    
@end

