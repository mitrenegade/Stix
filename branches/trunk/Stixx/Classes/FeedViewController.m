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

@synthesize feedItemViewController;
@synthesize badgeView;
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
-(id)init
{
	[super initWithNibName:@"FeedViewController" bundle:nil];
	
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
    
	/****** init badge view ******/
	badgeView = [[BadgeView alloc] initWithFrame:self.view.frame];
    badgeView.delegate = self;
    [self initializeScrollWithPageSize:CGSizeMake(280, 320)];
    scrollView.isLazy = YES;
    [delegate didCreateBadgeView:badgeView];

    // add badgeView and scrollView as subviews of feedview; set underlay
    [self.view addSubview:scrollView];
    [self.view insertSubview:badgeView aboveSubview:scrollView];
    [badgeView setUnderlay:scrollView];
    [badgeView setShowRewardStix:NO];
    
    activityIndicatorCenter = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 140, 80, 80)];
    [self.view addSubview:activityIndicatorCenter];
    
    zoomViewController = [[ZoomViewController alloc] init];
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
#if 0
    if (animate)
    {
        // no need to reanimate center indicator
        if (which==0)
        {
            [activityIndicatorLeft setHidden:NO];
            [activityIndicatorLeft startAnimating];
        }
        else
        {
            [activityIndicatorRight setHidden:NO];
            [activityIndicatorRight startAnimating];
        }
    }
    else // stop all indicators
    {
        //[activityIndicatorCenter setHidden:YES];
        //[activityIndicatorCenter stopAnimating];
        [activityIndicatorLeft setHidden:YES];
        [activityIndicatorLeft stopAnimating];
        [activityIndicatorRight setHidden:YES];
        [activityIndicatorRight stopAnimating];
    }
#endif
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
    [badgeView resetBadgeLocations];  
    NSLog(@"Feed view's Badge controller frame: %f %f %f %f\n", badgeView.frame.origin.x, badgeView.frame.origin.y, badgeView.frame.size.width, badgeView.frame.size.height);
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
    //[scrollView clearNonvisiblePages];
}

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

    [badgeView release];
    badgeView = nil;
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

    [badgeView release];
    badgeView = nil;
    [scrollView release];
    scrollView = nil;

    [super dealloc];
}

/******* badge view delegate ******/
-(void)didDropStix:(UIImageView *)badge ofType:(int)type {
    // increment stix count for given feed item
    Tag * t = (Tag*) [allTags objectAtIndex:lastPageViewed];

    if ([delegate getStixCount:type] < 1)
    {
        if ([delegate isLoggedIn] == NO)
        {     
            UIAlertView* alert = [[UIAlertView alloc]init];
            [alert addButtonWithTitle:@"Ok I'll go log in now"];
            [alert setTitle:@"Not logged in"];
            [alert setMessage:[NSString stringWithFormat:@"You have no stix because you are not logged in!"]];
            [alert show];
            [alert release];
        }
        else
        {
            NSString * badgeTypeStr;
            if (type == BADGE_TYPE_FIRE)
                badgeTypeStr = @"Fire";
            else
                badgeTypeStr = @"Ice";

            UIAlertView* alert = [[UIAlertView alloc]init];
            [alert addButtonWithTitle:@"I take it back"];
            [alert setTitle:@"Insufficient stix"];
            [alert setMessage:[NSString stringWithFormat:@"You have run out of %@ stix!", badgeTypeStr]];
            [alert show];
            [alert release];
        }
        [badgeView resetBadgeLocations];
        return;
    }
   
    if ([t badgeType] != BADGE_TYPE_FIRE && [t badgeType] != BADGE_TYPE_ICE) {        
        NSString * badgeTypeStr;
        if (type == BADGE_TYPE_FIRE)
            badgeTypeStr = @"Fire";
        else
            badgeTypeStr = @"Ice";
        UIAlertView* alert = [[UIAlertView alloc]init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setTitle:@"Beta Version"];
        [alert setMessage:[NSString stringWithFormat:@"Sorry, you cannot add stix to this Pix! Try adding your %@ to another picture.", badgeTypeStr]];
        [alert show];
        [alert release];
        [badgeView resetBadgeLocations];
        return;
    }
        
    
    NSString * badgeTypeStr;
    if ([t badgeType] == BADGE_TYPE_FIRE)
        badgeTypeStr = @"Fire";
    else
        badgeTypeStr = @"Ice";
    NSLog(@"Current tag id %d by %@: %@ stix count was %d", [t.tagID intValue], t.username, badgeTypeStr, t.badgeCount);
    [delegate didAddStixToTag:t withType:type];
    //NSLog(@"After decrement: %d (delegate says %d)", ret, [delegate getStixCount:type]);
    //if ([t.username isEqualToString:[delegate getUsername]] == NO) {
    //    [delegate incrementStixCount:type forUser:t.username];
        //[delegate decrementStixCount:type forUser:[delegate getUsername]];        
    //}
    
    NSLog(@"Now tag id %d: %@ stix count is %d. User has %d left", [t.tagID intValue], badgeTypeStr, t.badgeCount, [delegate getStixCount:type]);
    [badgeView resetBadgeLocations];
    [scrollView reloadPage:lastPageViewed];
    
}
-(int)getStixCount:(int)stix_type {
    return [self.delegate getStixCount:stix_type];
}
-(int)getStixLevel {
    return [self.delegate getStixLevel];
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
    //NSLog(@"Index: %d reverse_index: %d", index, reverse_index);
    Tag * tag = [[allTags objectAtIndex:index] retain];
    
    NSString * name = tag.username;
    NSString * comment = tag.comment;
    NSString * locationString = tag.locationString;
    UIImage * image = tag.image;
    
    NSLog(@"Creating feed item at index %d: name %@ comment %@ image dims %f %f\n", index, name, comment, image.size.width, image.size.height);
    
    FeedItemViewController * feedItem = [[[FeedItemViewController alloc] init] autorelease];
    [feedItem populateWithName:name andWithComment:comment andWithLocationString:locationString andWithImage:image];
    [feedItem.view setFrame:CGRectMake(0, 0, 280, 320)]; 
    UIImage * photo = [[UIImage alloc] initWithData:[userPhotos objectForKey:name]];
    if (photo)
    {
        //NSLog(@"User %@ has photo of size %f %f\n", name, photo.size.width, photo.size.height);
        [feedItem populateWithUserPhoto:photo];
        [photo release];
    }
    // add timestamp
    [feedItem populateWithTimestamp:tag.timestamp];
    // add badge and counts
    [feedItem populateWithBadge:tag.badgeType withCount:tag.badgeCount atLocationX:tag.badge_x andLocationY:tag.badge_y];
    NSLog(@"Adding badge at location %d %d", tag.badge_x,tag. badge_y);
    [tag release];
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

@end

