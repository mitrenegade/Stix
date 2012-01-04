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
@synthesize activityIndicatorCenter; // initially is active
@synthesize activityIndicatorLeft;
@synthesize activityIndicatorRight;
@synthesize userPhotos;
@synthesize allTags;
@synthesize scrollView;
@synthesize lastPageViewed;
@synthesize zoomViewController;
@synthesize commentView;

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
    
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    lastPageViewed = 0;
    
    [self initializeScrollWithPageSize:CGSizeMake(FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)];
    scrollView.isLazy = YES;
    [self.view addSubview:scrollView];
    
	/****** init badge view ******/
    [self createCarouselView];
    
    activityIndicatorCenter = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 140, 80, 80)];
    [self.view addSubview:activityIndicatorCenter];
    
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
    [carouselView initCarouselWithFrame:CGRectMake(SHELF_STIX_X,SHELF_STIX_Y,320,SHELF_STIX_SIZE)];
    
    [self.view insertSubview:carouselView aboveSubview:scrollView];
    [carouselView setUnderlay:scrollView];
    [delegate didCreateBadgeView:carouselView];
}

-(void)reloadCarouselView {
    [[self carouselView] reloadAllStixWithFrame:CGRectMake(SHELF_STIX_X,SHELF_STIX_Y,320,SHELF_STIX_SIZE)];
    [[self carouselView] removeFromSuperview];
    [self.view insertSubview:carouselView aboveSubview:scrollView];
}

- (void)setIndicatorWithID:(int)which animated:(BOOL)animate {
    if (animate)
    {
        //[activityIndicatorCenter setHidden:NO];
        [activityIndicatorCenter startCompleteAnimation];
    }
    else
        [activityIndicatorCenter stopCompleteAnimation];
        //[activityIndicatorCenter setHidden:YES];
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
    [activityIndicatorCenter release];
    [activityIndicatorLeft release];
    [activityIndicatorRight release];
    [nameLabel release];
    
    activityIndicatorCenter = nil;
    activityIndicatorLeft = nil;
    activityIndicatorRight = nil;
    nameLabel = nil;

    [carouselView release];
    carouselView = nil;
    [scrollView release];
    scrollView = nil;

    [super viewDidUnload];
}


- (void)dealloc 
{
	[scrollView release];
	[allTags release];
	[scrollView release];
    [activityIndicatorCenter release];
    [activityIndicatorLeft release];
    [activityIndicatorRight release];
    [nameLabel release];
    
    activityIndicatorCenter = nil;
    activityIndicatorLeft = nil;
    activityIndicatorRight = nil;
    nameLabel = nil;

    [carouselView release];
    carouselView = nil;
    [scrollView release];
    scrollView = nil;

    [super dealloc];
}

/******* badge view delegate ******/
-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID {
    // increment stix count for given feed item
    
    if ([allTags count] == 0) {
        // nothing loaded yet
        [carouselView resetBadgeLocations];
        return;
    }
    Tag * t = (Tag*) [allTags objectAtIndex:lastPageViewed];   
    
    // scale stix frame back
    FeedItemViewController * feedItem = [feedItems objectForKey:t.tagID];
	float imageScale =  300 / feedItem.imageView.frame.size.width;
    
	CGRect stixFrameScaled = badge.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    float centerx = badge.center.x;// * imageScale;
    float centery = badge.center.y;// * imageScale;
    CGRect scrollFrame = scrollView.frame;
    CGRect imageViewFrame = feedItem.imageView.frame;
    centerx -= scrollFrame.origin.x + imageViewFrame.origin.x;
    centerx *= imageScale;
    centery -= scrollFrame.origin.y + imageViewFrame.origin.y;
    centery *= imageScale;
    NSLog(@"Offsetting center by %f %f\n", scrollFrame.origin.x + imageViewFrame.origin.x, scrollFrame.origin.y + imageViewFrame.origin.y);

    CGPoint location = CGPointMake(centerx, centery); //badge.frame.origin.x, badge.frame.origin.y);
    [delegate didAddStixToPix:t withStixStringID:stixStringID atLocation:location];
    
//    NSLog(@"Now tag id %d: %@ stix count is %d. User has %d left", [t.tagID intValue], badgeTypeStr, t.badgeCount, [delegate getStixCount:type]);
    [carouselView resetBadgeLocations];
    [scrollView reloadPage:lastPageViewed];
    
}
-(int)getStixCount:(NSString*)stixStringID {
    return [self.delegate getStixCount:stixStringID];
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
    
    NSString * name = tag.username;
    NSString * descriptor = tag.descriptor;
    NSString * comment = tag.comment;
    NSString * locationString = tag.locationString;
    NSString * stixStringID = tag.stixStringID;
    int tagID = [tag.tagID intValue];
    UIImage * image = tag.image;
    NSLog(@"Index: %d tagID: %d", index, tagID);
    
    NSLog(@"Creating feed item %d at index %d: name %@ comment %@ image %@ dims %f %f\n", tagID, index, name, comment, stixStringID, image.size.width, image.size.height);
    
    FeedItemViewController * feedItem = [[[FeedItemViewController alloc] init] autorelease];
    [feedItem setDelegate:self];
    [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString andWithImage:image];
    [feedItem.view setFrame:CGRectMake(0, 0, FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)]; 
    UIImage * photo = [[UIImage alloc] initWithData:[userPhotos objectForKey:name]];
    if (photo)
    {
        //NSLog(@"User %@ has photo of size %f %f\n", name, photo.size.width, photo.size.height);
        [feedItem populateWithUserPhoto:photo];
//        [photo autorelease];
    }
    // add timestamp
    [feedItem populateWithTimestamp:tag.timestamp];
    // add badge and counts
    [feedItem populateWithBadge:tag.stixStringID withCount:tag.badgeCount atLocationX:tag.badge_x andLocationY:tag.badge_y];
    [feedItem populateWithAuxStix:tag.auxStixStringIDs atLocations:tag.auxLocations];
    feedItem.tagID = [tag.tagID intValue];
    int count = [self.delegate getCommentCount:feedItem.tagID];
    if (count == 1)
        [feedItem.addCommentButton setTitle:[NSString stringWithFormat:@"%d comment", count] forState:UIControlStateNormal];
    else        
        [feedItem.addCommentButton setTitle:[NSString stringWithFormat:@"%d comments", count] forState:UIControlStateNormal];
    NSLog(@"FeedViewController: Adding badge at location %d %d in image of %f %f", tag.badge_x,tag. badge_y, image.size.width, image.size.height);
    
    // this object must be retained so that the button actions can be used
    [feedItems setObject:feedItem forKey:tag.tagID];
    
    return feedItem.view;
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
        [self setIndicatorWithID:0 animated:YES];
    }
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
                [self setIndicatorWithID:0 animated:YES];
        }
        else if (lastContentOffset > scrollView.contentOffset.x) { // left 
            if (page == 0)
                [self setIndicatorWithID:0 animated:YES];
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
#if DO_ZOOM_VIEW
    NSLog(@"Click on page %d at position %f %f\n", [scrollView currentPage], location.x, location.y);
    
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
}

-(void)didDismissZoom {
#if DO_ZOOM_VIEW
    [zoomViewController.view removeFromSuperview];
#endif
}

/*** feedItemViewDelegate ****/
-(void)displayCommentsOfTag:(int)tagID andName:(NSString *)nameString{
    commentView = [[CommentViewController alloc] init];
    [commentView setTagID:tagID];
    [commentView setNameString:nameString];
    [commentView setDelegate:self];
    [self presentModalViewController:commentView animated:YES];
}

/*** CommentViewDelegate ***/
-(void)didCloseComments {
    [self dismissModalViewControllerAnimated:YES];
    [commentView release];
    commentView = nil;
}

-(void)didAddNewComment:(NSString *)newComment {
    NSString * name = [self.delegate getUsername];
    int type = -1; //BADGE_TYPE_FIRE; // todo: fix this
    int tagID = [commentView tagID];
    if ([newComment length] > 0)
        [self.delegate didAddHistoryItemWithTagId:tagID andUsername:name andComment:newComment andBadgeType:type];
    [self didCloseComments];
}
@end

