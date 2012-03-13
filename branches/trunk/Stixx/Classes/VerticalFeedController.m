//
//  VerticalFeedController.m
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//

#import "VerticalFeedController.h"

@implementation VerticalFeedController

@synthesize feedItems;
@synthesize headerViews;
@synthesize carouselView;
@synthesize delegate;
@synthesize activityIndicator; // initially is active
@synthesize userPhotos;
@synthesize allTags;
@synthesize tableController;
@synthesize lastPageViewed;
@synthesize commentView;
@synthesize buttonFeedback;
@synthesize camera;
//@synthesize buttonShowCarousel;
//@synthesize carouselTab;
@synthesize tabBarController;
//@synthesize stixSelected;
@synthesize bitlyHelper;

-(id)init
{
	self = [super initWithNibName:@"VerticalFeedController" bundle:nil];
	
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

-(void)initializeTable
{
    // We need to do some setup once the view is visible. This will only be done once.
    // Position and size the scrollview. It will be centered in the view.    
    CGRect frame = CGRectMake(0,44, 320, 380);
    tableController = [[FeedTableController alloc] init];
    [tableController.view setFrame:frame];
    [tableController.view setBackgroundColor:[UIColor clearColor]];
    tableController.delegate = self;
    [self.view insertSubview:tableController.view belowSubview:self.buttonFeedback];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    lastPageViewed = 0;
    
    //[self initializeScrollWithPageSize:CGSizeMake(FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)];
    [self initializeTable];
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(10, 11, 25, 25)];
    [self.view addSubview:activityIndicator];
    
    //zoomViewController = [[ZoomViewController alloc] init];
    
    // array to retain each FeedItemViewController as it is created so its callback
    // for the button can be used
    feedItems = [[NSMutableDictionary alloc] init]; 
    headerViews = [[NSMutableDictionary alloc] init];
    
    [activityIndicator startCompleteAnimation];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self configureCarouselView];
    [self.carouselView carouselTabDismiss:NO];
}

-(void)configureCarouselView {
    // claim carousel for self
    NSLog(@"ConfigureCarouselView by VerticalFeedController");
    [self setCarouselView:[CarouselView sharedCarouselView]];
    [carouselView setDelegate:self];
    [carouselView setDismissedTabY:373-20];
    [carouselView setExpandedTabY:5-20];
    [carouselView setAllowTap:YES];
    //[carouselView removeFromSuperview];
    [self.view insertSubview:carouselView aboveSubview:tableController.view];
    [carouselView setUnderlay:tableController.view];
    //[carouselView carouselTabDismiss:NO];
    [carouselView resetBadgeLocations];
}

- (void)viewWillAppear:(BOOL)animated
{
	//[imageView setImage:[[ImageCache sharedImageCache] imageForKey:@"newImage"]];
	[super viewWillAppear:animated];
    
    //[self.delegate checkForUpdateTags];
    
    self.allTags = [self.delegate getTags];
    self.userPhotos = [self.delegate getUserPhotos]; 
    NSLog(@"Loaded %d tags and %d users", [self.allTags count], [self.userPhotos count]);
    
    //[tableController populateScrollPagesAtPage:lastPageViewed];
    [tableController setContentPageIDs:allTags];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //[self configureCarouselView];
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
    activityIndicator = nil;
    
    [carouselView release];
    carouselView = nil;
    [tableController release];
    tableController = nil;
    
    [super viewDidUnload];
}


- (void)dealloc 
{
	[allTags release];
    
    [activityIndicator release];
    activityIndicator = nil;
    
    [carouselView release];
    carouselView = nil;
    
    [super dealloc];
}

/******* badge view delegate ******/
-(void)didTapStix:(UIImageView *)badge ofType:(NSString *)stixStringID {
    //[self.carouselView carouselTabDismissWithStix:badge];
    if ([allTags count]==0) {
        [carouselView resetBadgeLocations];
        [carouselView carouselTabDismiss:YES];
        return;        
    }
    //[self.carouselView carouselTabDismiss:NO];
    [self.carouselView setStixSelected:stixStringID];
    CGPoint center = self.view.center;
    center.y -= tableController.view.frame.origin.y; // remove tableController offset
    [badge setCenter:center];
    int section = [tableController getCurrentSectionAtPoint:center];
    lastPageViewed = section;
    [self didDropStixByTap:badge ofType:stixStringID];
}

-(void)didDropStixByTap:(UIImageView *) badge ofType:(NSString*)stixStringID {
    // tap inside the feed to add a stix
    Tag * tag = [allTags objectAtIndex:lastPageViewed]; // lastPageViewed set by didTapStix
    [self addAuxStix:badge ofType:stixStringID toTag:tag];
}

-(void)didDropStixByDrag:(UIImageView *) badge ofType:(NSString*)stixStringID {
    if ([allTags count]==0) {
        [carouselView resetBadgeLocations];
        [carouselView carouselTabDismiss:YES];
        return;
    }
    CGPoint locationInSection = [tableController getContentPoint:badge.center inSection:lastPageViewed];
    locationInSection.y -= tableController.view.frame.origin.y; // remove tableController offset
    [badge setCenter:locationInSection];
    NSLog(@"VerticalFeedController: didDropStixByDrag: section found %d locationInSection origin %f %f center %f %f size %f %f", lastPageViewed, badge.frame.origin.x, badge.frame.origin.y, badge.center.x, badge.center.y, badge.frame.size.width, badge.frame.size.height);
    Tag * tag = [allTags objectAtIndex:lastPageViewed]; // lastPageViewed set by didDropStix
    [self addAuxStix:badge ofType:stixStringID toTag:tag];
}

-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID {
    // comes here through carousel delegate
    // the frame of the badge is in the carousel frame
    // contains no information about which feedItem it was
    [self.carouselView carouselTabDismiss:YES];
    
    CGPoint center = badge.center;
    CGRect frame = badge.frame;
    // this was for drag and drop 
    //center.y -= tableController.view.frame.origin.y;
    int section = [tableController getCurrentSectionAtPoint:center];
    lastPageViewed = section;
    NSLog(@"VerticalFeedController: didDropStix center %f %f size %f %f section %d", center.x,center.y, frame.size.width, frame.size.height, section);
    [self didDropStixByDrag:badge ofType:stixStringID];
}

-(void)addAuxStix:(UIImageView *) badge ofType:(NSString*)stixStringID toTag:(Tag*) tag{ 
    // HACK: will be changed soon if we have an addStix button
    
    // input badge should have frame within the tag's frame
    //if ([allTags count] == 0) {
    if (tag == nil) {
        // nothing loaded yet
        [carouselView resetBadgeLocations];
        return;
    }
    //allTags = [self.delegate getTags];
    //Tag * t = (Tag*) [allTags objectAtIndex:lastPageViewed];   
    
    //NSLog(@"Dropped new %@ stix onto tag %d: id %d auxStix %d lastStix %@", stixStringID, lastPageViewed, [t.tagID intValue], [t.auxStixStringIDs count], [t.auxStixStringIDs objectAtIndex:[t.auxStixStringIDs count]-1]);
    
    // scale stix frame back to full 300x275 size
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
    
    NSLog(@"VerticalFeedController: added stix of size %f %f at origin %f %f center %f %f (whole window's frame) in view %f %f\n", badge.frame.size.width, badge.frame.size.height, badge.frame.origin.x, badge.frame.origin.y, badge.center.x, badge.center.y, feedItem.imageView.frame.size.width, feedItem.imageView.frame.size.height);
    
	//CGRect stixFrameScaled = badge.frame;
    //CGRect tableFrame = tableController.view.frame;
    //CGRect imageViewFrame = feedItem.imageView.frame;
    float centerx = badge.center.x - feedItemViewOffset.x; // small mismatch between placement
    float centery = badge.center.y - feedItemViewOffset.y;
    CGPoint location = CGPointMake(centerx, centery); 
    [badge setCenter:location];

    AddStixViewController * auxView = [[AddStixViewController alloc] init];
    
    // hack a way to display view over camera; formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [auxView.view setFrame:frameShifted];
    [self.camera setCameraOverlayView:auxView.view];
    
    auxView.delegate = self;
    [auxView initStixView:tag];
    //[auxView addNewAuxStix:badge ofType:stixStringID atLocation:location];
    [auxView addStixToStixView:stixStringID atLocation:location];
    //[auxView toggleCarouselView:NO];
    [auxView configureCarouselView];
    [carouselView setExpandedTabY:5-20]; // hack: a bit lower
    [carouselView setDismissedTabY:373-STATUS_BAR_SHIFT];
    //[auxView.carouselView carouselTabExpand:NO];
    [auxView.carouselView carouselTabDismiss:YES];
    //[auxView.carouselView.scrollView setContentOffset:carouselView.scrollView.contentOffset];
    //[auxView didTapStix:badge ofType:stixStringID]; // simulate pressing of that stix
}

-(void)didAddDescriptor:(NSString *)descriptor andComment:(NSString *)comment andLocation:(NSString *)location {
    Tag * t = (Tag*) [allTags objectAtIndex:lastPageViewed];   
    if ([descriptor length] > 0) {
        NSString * name = [self.delegate getUsername];
        [self.delegate didAddCommentWithTagID:[t.tagID intValue] andUsername:name andComment:descriptor andStixStringID:@"COMMENT"];
        //        [self didAddNewComment:descriptor withTagID:[t.tagID intValue]];
    }
}

-(void)didAddStixWithStixStringID:(NSString *)stixStringID withLocation:(CGPoint)location withTransform:(CGAffineTransform)transform {
    // hack a way to remove view over camera; formerly dismissModalViewController
    [self.delegate didDismissSecondaryView];
    [self configureCarouselView];
    [self.carouselView carouselTabDismiss:YES];
    
    Tag * t = (Tag*) [allTags objectAtIndex:lastPageViewed];   
    [delegate didAddStixToPix:t withStixStringID:stixStringID withLocation:location withTransform:transform];
    //    NSLog(@"Now tag id %d: %@ stix count is %d. User has %d left", [t.tagID intValue], badgeTypeStr, t.badgeCount, [delegate getStixCount:type]);
    
    [carouselView resetBadgeLocations];
    [self reloadCurrentPage];    
}

-(void)didCancelAddStix {
    // hack a way to remove view over camera; formerly dismissModalViewController
    [self configureCarouselView];
    NSLog(@"Is carousel showing? %d", [carouselView isShowingCarousel]);
    //[carouselView carouselTabExpand:NO];
    [carouselView carouselTabDismiss:YES];
    [self.delegate didDismissSecondaryView];
}

-(int)getStixCount:(NSString*)stixStringID {
    return [self.delegate getStixCount:stixStringID];
}
-(int)getStixOrder:(NSString*)stixStringID {
    return [self.delegate getStixOrder:stixStringID];
}
-(int)getBuxCount {
    return [self.delegate getBuxCount];
}

-(void)didStartDrag {
    [self.carouselView carouselTabDismiss:YES];
}

-(void)didPurchaseStixFromCarousel:(NSString *)stixStringID {
    [self.delegate didPurchaseStixFromCarousel:stixStringID];
}

/*********** FeedTableView functions *******/

-(Tag *) tagAtIndex:(int)index {
    return [allTags objectAtIndex:index];
}

-(UIView*)viewForItemWithTagID:(NSNumber*)tagID {
    return [feedItems objectForKey:tagID];
}

-(UIView*)headerForSection:(int)index {
    if (0) //index == 0) 
    {
        // return stix header
        if (!stixHeader) {
            stixHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            UIImageView * bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_bar.png"]];
            [stixHeader addSubview:bg];
            [bg release];
            UIImageView * logo = [[UIImageView alloc] initWithFrame:CGRectMake(131, 3, 59, 38)];
            [logo setImage:[UIImage imageNamed:@"logo.png"]];
            [stixHeader addSubview:logo];
            [logo release];
            UIButton * feedbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(230, 5, 80, 40)];
            [feedbackBtn setImage:[UIImage imageNamed:@"nav_feedback.png"] forState:UIControlStateNormal];
            [feedbackBtn addTarget:self action:@selector(didClickFeedbackButton:) forControlEvents:UIControlEventTouchUpInside];
            [stixHeader addSubview:feedbackBtn];
            [feedbackBtn release];
        }
        return stixHeader;
    }
    else
    {
        //index = index - 1;
        Tag * tag = [allTags objectAtIndex:index];
        UIView * headerView = [headerViews objectForKey:tag.tagID];
        if (!headerView) {
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            [headerView setBackgroundColor:[UIColor blackColor]];
            [headerView setAlpha:.75];
            
            UIImage * photo = [[UIImage alloc] initWithData:[userPhotos objectForKey:tag.username]];
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
            [timeLabel setText:[VerticalFeedItemController getTimeLabelFromTimestamp:tag.timestamp]];
            [headerView addSubview:timeLabel];
            
            [headerViews setObject:headerView forKey:tag.tagID];
        }
        return headerView;
    }
}

-(UIView*)reloadViewForItemAtIndex:(int)index {
    Tag * tag = [allTags objectAtIndex:index];
    VerticalFeedItemController * feedItem = [[[VerticalFeedItemController alloc] init] autorelease];
    [feedItem setDelegate:self];
    
    NSString * name = tag.username;
    NSString * descriptor = tag.descriptor;
    NSString * comment = tag.comment;
    NSString * locationString = tag.locationString;
    
    [feedItem.view setCenter:CGPointMake(160, feedItem.view.center.y+3)];
    [feedItem.view setBackgroundColor:[UIColor clearColor]];
    [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString];// andWithImage:image];
    //[feedItem.view setFrame:CGRectMake(0, 0, FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)]; 
    //[carouselView setSizeOfStixContext:feedItem.imageView.frame.size.width];
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
    
    [self.tableController.tableView reloadData];
    [tableController dataSourceDidFinishLoadingNewData];
    [self.activityIndicator stopCompleteAnimation];
    return feedItem.view;
}

-(UIView*)viewForItemAtIndex:(int)index
{	        
    if (0) //index == 0)
    {
        if (!stixHeaderBody) {
            stixHeaderBody = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
            [stixHeaderBody setBackgroundColor:[UIColor greenColor]];
        }
        return stixHeaderBody;
    }
    else {
        //index = index - 1;
        Tag * tag = [allTags objectAtIndex:index];
        VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
        
        if (!feedItem) {
            feedItem = [[[VerticalFeedItemController alloc] init] autorelease];
            [feedItem setDelegate:self];
            
            NSString * name = tag.username;
            NSString * descriptor = tag.descriptor;
            NSString * comment = tag.comment;
            NSString * locationString = tag.locationString;
            
            [feedItem.view setCenter:CGPointMake(160, feedItem.view.center.y+3)];
            feedItemViewOffset = feedItem.view.frame.origin; // same offset
            [feedItem.view setBackgroundColor:[UIColor clearColor]];
            [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString];// andWithImage:image];
            //[feedItem.view setFrame:CGRectMake(0, 0, FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)]; 
            //[carouselView setSizeOfStixContext:feedItem.imageView.frame.size.width];
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
}

-(void)jumpToPageWithTagID:(int)tagID {
    // find position of tag in allTags
    for (int i=0; i<[allTags count]; i++) {
        Tag * t = [allTags objectAtIndex:i];
        if ([t.tagID intValue] == tagID) {
            [self reloadViewForItemAtIndex:i];
            NSLog(@"TagID: %d Target row: %d", tagID, i);
            NSIndexPath * targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            [tableController.tableView scrollToRowAtIndexPath:targetIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

-(IBAction)didClickJumpButton:(id)sender {
//    [scrollView jumpToPage:0];
}


-(void)updateScrollPagesAtPage:(int)page {
    NSLog(@"VerticalFeedController: UpdateScrollPagesAtPage %d: AllTags currently has %d elements", page, [allTags count]);
    if ([self itemCount] > 0) {
        if (page < 0 + LAZY_LOAD_BOUNDARY) { // trying to find a more recent tag
            Tag * t = (Tag*) [allTags objectAtIndex:0];
            int tagid = [t.tagID intValue];
            [self.activityIndicator startCompleteAnimation];
            [self.delegate getNewerTagsThanID:tagid];            
        }
        if (page >= [self itemCount] - LAZY_LOAD_BOUNDARY) { // trying to load an earlier tag
            Tag * t = (Tag*) [allTags objectAtIndex:[self itemCount]-1];
            int tagid = [t.tagID intValue];
            [self.activityIndicator startCompleteAnimation];
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
    int section = [tableController getCurrentSectionAtPoint:CGPointMake(160, 240)];
    self.allTags = [self.delegate getTags];
    [self.activityIndicator startCompleteAnimation];
    [self reloadViewForItemAtIndex:section];
}

-(void)finishedCheckingForNewData:(bool)updated {
    [tableController dataSourceDidFinishLoadingNewData];
    if (updated)
        [self reloadViewForItemAtIndex:0];
    [tableController setContentPageIDs:allTags];
    [self.activityIndicator stopCompleteAnimation];
}

-(int)itemCount
{
	// Return the number of pages we intend to display
	return [self.allTags count];
}

-(void)forceUpdateCommentCount:(int)tagID {
    // this function is called after StixxAppDelegate has retrieved the comment
    // count from kumulos and inserted it into the allCommentCounts array
    
    //for (int i=0; i<[feedItems count]; i++) {
    VerticalFeedItemController * curr = [feedItems objectForKey:[NSNumber numberWithInt:tagID]];
    [curr populateWithCommentCount:[self.delegate getCommentCount:tagID]];
    
//    [scrollView reloadPage:lastPageViewed];
}

/************** FeedZoomView ***********/
// comes from feedItem instead of carousel
-(void)didClickAtLocation:(CGPoint)location withFeedItem:(VerticalFeedItemController*)feedItem {
    // location is the click location inside feeditem's frame
    
    NSLog(@"VerticalFeedController: Click on table at position %f %f with tagID %d\n", location.x, location.y, feedItem.tagID);

    CGPoint locationInStixView = location;
    //locationInStixView.x -= feedItem.stixView.frame.origin.x;
    //locationInStixView.y -= feedItem.stixView.frame.origin.y;
    int peelableFound = [[feedItem stixView] findPeelableStixAtLocation:locationInStixView];
    for (int i=0; i<[allTags count]; i++) {
        Tag * tag = [allTags objectAtIndex:i];
        if ([tag.tagID intValue] == feedItem.tagID) {
            lastPageViewed = i;
            break;            
        }
    }
    
    // if just a tap, add aux stix
    if (peelableFound == -1) {
        // do not add aux stix
        /*
        if ([carouselView stixSelected] != nil && [self.delegate getStixCount:[carouselView stixSelected]] != 0) {
            UIImageView * stix = [BadgeView getBadgeWithStixStringID:[carouselView stixSelected]];
            //locationInStixView = [tableController getPointInTableViewFrame:locationInStixView fromPage:lastPageViewed];
            //locationInStixView.y += tableController.view.frame.origin.y; // hack: didDropStix takes away tableController's y offset
            [stix setCenter:locationInStixView];
            [self didDropStixByTap:stix ofType:[carouselView stixSelected]];
        }
         */
    }
}

/*** verticalfeedItemDelegate ****/
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
    [self.camera setCameraOverlayView:commentView.view];
}

-(void)didSharePix:(NSMutableArray*)params {
    int newID = [[params objectAtIndex:0] intValue];
    NSLog(@"DidSharePix completed: id %d", newID);
    NSMutableString * encodedURL = [[NSMutableString alloc] init];
    NSString * longURL = [NSString stringWithFormat:@"http://dzy.mit.edu/Stix/Webshared.php?form[sharedPixID]=%d", newID];
    [encodedURL appendString:longURL];
    [encodedURL appendString:@"\%26submit=Submit!"];
    //NSString * encodedURL = (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)longURL,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 );
    //NSString* encodedUrl =[longURL stringByAddingPercentEscapesUsingEncoding:NSHTTP];    
    NSLog(@"longurl %@ encodedURL %@", longURL, encodedURL);
    [self shortenBlastTextUrls:encodedURL];
    
    // todo: add a menu for facebook/twitter/email/save to disk
    // todo: add timeout to provide long url if bitly helper fails
}

-(void)sharePix:(int)tagID {
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Sharing"];
    [alert setMessage:@"Processing Pix for sharing..."];
    [alert show];
    [alert release];

    VerticalFeedItemController * feedItem = [feedItems objectForKey:[NSNumber numberWithInt:tagID]];
#if 0
    UIImage * feedImage = feedItem.imageData; // for now just store original image data
	NSData *png = UIImagePNGRepresentation(feedImage);
#else
    Tag * tag = nil;
    for (int i=0; i<[allTags count]; i++) {
        Tag * t = [allTags objectAtIndex:i];
        if ([t.tagID intValue] == feedItem.tagID)
            tag = [allTags objectAtIndex:i];
    }
    if (tag == nil) 
        return;
    UIImage * result = [tag tagToUIImage];
	NSData *png = UIImagePNGRepresentation(result);
    
    UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil); // write to photo album
#endif
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:png, nil];
    [[KumulosHelper sharedKumulosHelper] execute:@"sharePix" withParams:params withCallback:@selector(didSharePix:) withDelegate:self];

}

- (void) shortenBlastTextUrls:(NSString*)url{
    
    // Create bit.ly helper if nil
    if (self.bitlyHelper == nil) {
        self.bitlyHelper = [[[BTBitlyHelper alloc] init] autorelease];
        self.bitlyHelper.delegate = self;
    }
    
    [self.bitlyHelper shortenURLSInText:url];
}
- (void) BTBitlyShortUrl: (NSString *) shortUrl receivedForOriginalUrl: (NSString *) originalUrl{
    NSLog(@"URL %@ shortened to %@", originalUrl, shortUrl);
}
- (void) BTBitlyQueueStartedProcessing {}
- (void) BTBitlyQueueFinishedProcessing {}

-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    [self performSelector:callback withObject:params afterDelay:0];
}

// hack: forced display of comment page
-(void)openCommentForPageWithTagID:(NSNumber*)tagID {
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tagID];
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

-(void)didDismissCarouselTab {
    CGRect newFrame = CGRectMake(0, 0, 320, 480);
    [self.tabBarController.view setFrame:newFrame];
}

-(void)didExpandCarouselTab {
    CGRect newFrame = self.tabBarController.view.frame;
    newFrame.origin.y = 20;
    newFrame.size.height += 80;
    [self.tabBarController.view setFrame:newFrame];
}

@end

