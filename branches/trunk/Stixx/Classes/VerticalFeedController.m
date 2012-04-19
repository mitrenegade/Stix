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

@synthesize carouselView;
@synthesize delegate;
@synthesize activityIndicator; // initially is active
@synthesize activityIndicatorLarge;
@synthesize feedItems;
@synthesize headerViews;
@synthesize allTags;
@synthesize allTagsDisplayed;
@synthesize tableController;
@synthesize lastPageViewed;
@synthesize commentView;
//@synthesize buttonFeedback;
@synthesize camera;
//@synthesize buttonShowCarousel;
//@synthesize carouselTab;
@synthesize tabBarController;
//@synthesize stixSelected;
@synthesize buttonProfile;
@synthesize labelBuxCount;
@synthesize statusMessage;
@synthesize newestTagIDDisplayed;

-(id)init
{
	self = [super initWithNibName:@"VerticalFeedController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	//[tbi setTitle:@"Feed"];
	
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
    [self.view insertSubview:tableController.view belowSubview:self.buttonProfile];
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

-(void) viewDidLoad {
    [super viewDidLoad];
    lastPageViewed = 0;

    //[self initializeScrollWithPageSize:CGSizeMake(FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)];
    [self initializeTable];

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 11, 25, 25)];
    [self.view addSubview:activityIndicator];
    
    UIButton * buttonBux = [[UIButton alloc] initWithFrame:CGRectMake(6, 7, 84, 33)];
    [buttonBux setImage:[UIImage imageNamed:@"bux_count.png"] forState:UIControlStateNormal];
    [buttonBux addTarget:self action:@selector(didClickMoreBuxButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view insertSubview:buttonBux belowSubview:tableController.view];
    
    CGRect labelFrame = CGRectMake(25, 5, 58, 38);
    labelBuxCount = [[OutlineLabel alloc] initWithFrame:labelFrame];
    [labelBuxCount setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [labelBuxCount drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
    [labelBuxCount setText:[NSString stringWithFormat:@"%d", 0]];
    [labelBuxCount setTextAlignment:UITextAlignmentCenter];
    [self.view insertSubview:labelBuxCount belowSubview:tableController.view];
    
    // array to retain each FeedItemViewController as it is created so its callback
    // for the button can be used
    feedItems = [[NSMutableDictionary alloc] init]; 
    headerViews = [[NSMutableDictionary alloc] init];
    feedSectionHeights = [[NSMutableDictionary alloc] init];
    
    [self startActivityIndicator];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self configureCarouselView];
    [self.carouselView carouselTabDismiss:NO];

    [buttonBux release];
    [labelBuxCount release];
    
    [statusMessage setHidden:YES];

    backgroundQueue = dispatch_queue_create("com.Neroh.Stix.stixApp.feedController.bgQueue", NULL);
}

-(void)configureCarouselView {
    // claim carousel for self
    NSLog(@"ConfigureCarouselView by VerticalFeedController");
    [self setCarouselView:[CarouselView sharedCarouselView]];
    [carouselView setDelegate:self];
    [carouselView setDismissedTabY:375-STATUS_BAR_SHIFT];
    [carouselView setExpandedTabY:5-STATUS_BAR_SHIFT];
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
    
    [self populateAllTagsDisplayed];
    [tableController.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //[self configureCarouselView];
	[super viewDidAppear:animated];
    [labelBuxCount setText:[NSString stringWithFormat:@"%d", [delegate getBuxCount]]];
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
    if ([allTagsDisplayed count]==0) {
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
    Tag * tag = [allTagsDisplayed objectAtIndex:lastPageViewed]; // lastPageViewed set by didTapStix
    [self addAuxStix:badge ofType:stixStringID toTag:tag];
}

-(void)didDropStixByDrag:(UIImageView *) badge ofType:(NSString*)stixStringID {
    if ([allTagsDisplayed count]==0) {
        [carouselView resetBadgeLocations];
        [carouselView carouselTabDismiss:YES];
        return;
    }
    CGPoint locationInSection = [tableController getContentPoint:badge.center inSection:lastPageViewed];
    locationInSection.y -= tableController.view.frame.origin.y; // remove tableController offset
    [badge setCenter:locationInSection];
    NSLog(@"VerticalFeedController: didDropStixByDrag: section found %d locationInSection origin %f %f center %f %f size %f %f", lastPageViewed, badge.frame.origin.x, badge.frame.origin.y, badge.center.x, badge.center.y, badge.frame.size.width, badge.frame.size.height);
    Tag * tag = [allTagsDisplayed objectAtIndex:lastPageViewed]; // lastPageViewed set by didDropStix
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
    //[carouselView setExpandedTabY:5-STATUS_BAR_SHIFT]; // hack: a bit lower
    //[carouselView setDismissedTabY:375-STATUS_BAR_SHIFT];
    //[auxView.carouselView carouselTabExpand:NO];
    [auxView.carouselView carouselTabDismiss:YES];
    //[auxView.carouselView.scrollView setContentOffset:carouselView.scrollView.contentOffset];
    //[auxView didTapStix:badge ofType:stixStringID]; // simulate pressing of that stix
}

-(void)didAddDescriptor:(NSString *)descriptor andComment:(NSString *)comment andLocation:(NSString *)location {
    Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:lastPageViewed];   
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
    
    Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:lastPageViewed];   
    [delegate didAddStixToPix:t withStixStringID:stixStringID withLocation:location withTransform:transform];
    //    NSLog(@"Now tag id %d: %@ stix count is %d. User has %d left", [t.tagID intValue], badgeTypeStr, t.badgeCount, [delegate getStixCount:type]);
    
    [carouselView resetBadgeLocations];
    [self reloadCurrentPage];    
}

-(void)didCancelAddStix {
    // hack a way to remove view over camera; formerly dismissModalViewController
    [self configureCarouselView];
    //
    NSLog(@"Is carousel showing? %d", [carouselView isShowingCarousel]);
    //[carouselView carouselTabExpand:NO];
    [carouselView carouselTabDismiss:YES];
    [delegate didDismissSecondaryView];
    
    if ([delegate getFirstTimeUserStage] == FIRSTTIME_MESSAGE_02) {
        //[tabBarController displayFirstTimeUserProgress:FIRSTTIME_MESSAGE_02];
        [tabBarController toggleFirstTimePointer:YES atStage:FIRSTTIME_MESSAGE_02];
    }
}

-(int)getStixCount:(NSString*)stixStringID {
    return [delegate getStixCount:stixStringID];
}
-(int)getStixOrder:(NSString*)stixStringID {
    return [delegate getStixOrder:stixStringID];
}
-(int)getBuxCount {
    return [delegate getBuxCount];
}

-(void)didStartDrag {
    [carouselView carouselTabDismiss:YES];
}

-(void)didPurchaseStixFromCarousel:(NSString *)stixStringID {
    [self.delegate didPurchaseStixFromCarousel:stixStringID];
}

/*********** FeedTableView functions *******/

-(int)getHeightForSection:(int)index {
    Tag * tag = [allTagsDisplayed objectAtIndex:index];
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
    //NSLog(@"GetHeightForSection: item at row %d: ID %d comments %d view %x frame %f %f %f %f feedSectionHeight %d", index, [tag.tagID intValue], [feedItem commentCount], feedItem.view, feedItem.view.frame.origin.x, feedItem.view.frame.origin.y, feedItem.view.frame.size.width, feedItem.view.frame.size.height, [[feedSectionHeights objectForKey:tag.tagID] intValue]);
    int feedItemHeight = feedItem.view.frame.size.height;
    /*
    if (![delegate isFollowing:tag.username]) {
        NSLog(@"Unfollowing %@ means removing feed item at section %d", tag.username, index);
        feedItemHeight = 0;
    }
     */
    // HACK: feedItem should not be dynamically changing
    if (feedItemHeight != CONTENT_HEIGHT)
        feedItemHeight = CONTENT_HEIGHT;
    return feedItemHeight+5;
}

-(int)heightForHeaderInSection:(int)index {
    int headerHeight = HEADER_HEIGHT;
    /*
     Tag * tag = [allTagsDisplayed objectAtIndex:index];
     if (![delegate isFollowing:tag.username]) {
        NSLog(@"Unfollowing %@ means removing feed item at section %d", tag.username, index);
        headerHeight = 0;
    }
     */
    return headerHeight;
}

-(Tag *) tagAtIndex:(int)index {
    return [allTagsDisplayed objectAtIndex:index];
}

-(UIView*)viewForItemWithTagID:(NSNumber*)tagID {
    return [feedItems objectForKey:tagID];
}

-(void)didClickUserPhoto:(UIButton*)button {
    Tag * tag = [allTagsDisplayed objectAtIndex:button.tag];
    NSLog(@"Clicked on user photo %d in feed for user %@", button.tag, tag.username);
    [self shouldDisplayUserPage:tag.username];
}

-(UIView*)headerForSection:(int)index {
    //index = index - 1;
    Tag * tag = [allTagsDisplayed objectAtIndex:index];
    UIView * headerView = [headerViews objectForKey:tag.tagID];
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        [headerView setBackgroundColor:[UIColor blackColor]];
        [headerView setAlpha:.75];
        
        UIImage * photo = [[[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:tag.username]] autorelease];
        //UIImageView * photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(3, 5, 30, 30)] autorelease];
        UIButton * photoView = [[[UIButton alloc] initWithFrame:CGRectMake(3, 5, 30, 30)] autorelease];
		[photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photoView.layer setBorderWidth: 2.0];
        [photoView setImage:photo forState:UIControlStateNormal];
        [photoView setTag:index];
        [photoView addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:photoView];
        
        UILabel * nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(45, 0, 260, 30)] autorelease];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [nameLabel setText:tag.username];
        [headerView addSubview:nameLabel];
        
       // UIbutton * nameButton [[[UIButton alloc] initWithFrame:CGRectMake(45, 0, 260, 30)] autorelease];
        //[nameLabel setTag:index];
        //[nameButton addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel * locLabel = [[[UILabel alloc] initWithFrame:CGRectMake(45, 25, 260, 15)] autorelease];
        [locLabel setBackgroundColor:[UIColor clearColor]];
        [locLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0 alpha:1]];
        [locLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
        [locLabel setText:tag.locationString];
        [headerView addSubview:locLabel];    
        
        UILabel * timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(260, 5, 60, 20)] autorelease];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setTextColor:[UIColor whiteColor]];
        [timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:9]];
        [timeLabel setText:[Tag getTimeLabelFromTimestamp:tag.timestamp]];
        [headerView addSubview:timeLabel];
        
        [headerViews setObject:headerView forKey:tag.tagID];
        [headerView autorelease];
    }
    return [headerViews objectForKey:tag.tagID]; // MRC
}

-(UIView*)reloadViewForItemAtIndex:(int)index {
    // todo: reloadData only once for a batch of reloadViewForItem - maybe after requesting content from aggregator
    if (index > [allTagsDisplayed count]-1) {
        index = [allTagsDisplayed count]-1;
        NSLog(@"Here! Trying to reload index beyond allTagsDisplayed. Changing index to %d", index);    
    }
    Tag * tag = [allTagsDisplayed objectAtIndex:index];
    NSLog(@"ReloadViewForItemAtIndex: %d - tag %d", index, [[tag tagID] intValue]);

    VerticalFeedItemController * feedItem = [[VerticalFeedItemController alloc] init]; // do not autorelease
    [feedItem setDelegate:self];
    
    NSString * name = tag.username;
    NSString * descriptor = tag.descriptor;
    NSString * comment = tag.comment;
    NSString * locationString = tag.locationString;
    
    // if no longer following but still in feed
    /*
    if (![delegate isFollowing:name]) {
        [feedItem.view setFrame:CGRectMake(0, 0, 320, 0)];
        [feedItems setObject:feedItem forKey:tag.tagID];
        [self.tableController.tableView reloadData];
        [tableController dataSourceDidFinishLoadingNewData];
        [self stopActivityIndicator];
        return feedItem.view;
    }
     */
    [feedItem.view setCenter:CGPointMake(160, feedItem.view.center.y+3)];
    [feedItem.view setBackgroundColor:[UIColor clearColor]];
    [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString];// andWithImage:image];
    //[feedItem.view setFrame:CGRectMake(0, 0, FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)]; 
    //[carouselView setSizeOfStixContext:feedItem.imageView.frame.size.width];
    UIImage * photo = [[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:name]];
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
    if (0) { //shouldExpand) {
        NSMutableDictionary * theResults = [self.delegate getCommentHistoriesForTag:tag];
        //NSMutableDictionary * theResults = [commentHistories objectForKey:tag.tagID];
        if (theResults != nil) {
            NSMutableArray * names = [[NSMutableArray alloc] init];
            NSMutableArray * comments = [[NSMutableArray alloc] init];
            NSMutableArray * stixStringIDs = [[NSMutableArray alloc] init];
            NSLog(@"Comment histories for feed item with tagID %d has %d elements", [tag.tagID intValue], [theResults count]);
            //int ct = 0;
            for (NSMutableDictionary * d in theResults) {
                NSString * name = [d valueForKey:@"username"];
                NSString * comment = [d valueForKey:@"comment"];
                NSString * stixStringID = [d valueForKey:@"stixStringID"];
                if ([stixStringID length] == 0)
                {
                    // backwards compatibility
                    stixStringID = @"COMMENT";
                }
#if SHOW_COMMENTS_ONLY
                if (![stixStringID isEqualToString:@"COMMENT"])
                    continue;
#endif
                [names addObject:name];
                [comments addObject:comment];
                [stixStringIDs addObject:stixStringID];
            }
            //[feedItem populateCommentsWithNames:names andComments:comments andStixStringIDs:stixStringIDs];
            [names release];
            [comments release];
            [stixStringIDs release];
        }
    }
    
    // this object must be retained so that the button actions can be used
    [feedItems setObject:feedItem forKey:tag.tagID];
    
    [self.tableController.tableView reloadData];
    [tableController dataSourceDidFinishLoadingNewData];
    [self stopActivityIndicator];
    //[self.activityIndicator stopCompleteAnimation];
    [feedSectionHeights setObject:[NSNumber numberWithInt:feedItem.view.frame.size.height] forKey:tag.tagID];
//    [feedItem autorelease];
    return feedItem.view;
}

-(UIView*)viewForItemAtIndex:(int)index
{	        
    //index = index - 1;
    Tag * tag = [allTagsDisplayed objectAtIndex:index];
    NSLog(@"ViewForItemAtIndex: %d - tag %d", index, [[tag tagID] intValue]);
    VerticalFeedItemController * feedItem = nil;
    if (tag.tagID)
        feedItem = [feedItems objectForKey:tag.tagID];
    
    if (!feedItem) {
        feedItem = [[VerticalFeedItemController alloc] init]; // do not autorelease until we no longer need it as a delegate
        [feedItem setDelegate:self];
            
        NSString * name = tag.username;
        NSString * descriptor = tag.descriptor;
        NSString * comment = tag.comment;
        NSString * locationString = tag.locationString;
        
        [feedItem.view setCenter:CGPointMake(160, feedItem.view.center.y+3)];
        feedItemViewOffset = feedItem.view.frame.origin; // same offset
        [feedItem.view setBackgroundColor:[UIColor clearColor]];
        [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString];// andWithImage:image];
#if 0
        [feedItem togglePlaceholderView:YES];
        dispatch_async(backgroundQueue, ^{
#endif
            //[feedItem.view setFrame:CGRectMake(0, 0, FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)]; 
            //[carouselView setSizeOfStixContext:feedItem.imageView.frame.size.width];
            UIImage * photo = [[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:name]];
            if (photo)
            {
                //NSLog(@"User %@ has photo of size %f %f\n", name, photo.size.width, photo.size.height);
                [feedItem populateWithUserPhoto:photo];
                [photo autorelease]; // MRC
            }
            //NSLog(@"ViewForItem NEW: feedItem ID %d index %d size %f", [tag.tagID intValue], index, feedItem.view.frame.size.height);
            // add timestamp
            [feedItem populateWithTimestamp:tag.timestamp];
            // add badge and counts
            [feedItem initStixView:tag];
            if (tag.tagID) {
                feedItem.tagID = [tag.tagID intValue];
                int count = [self.delegate getCommentCount:feedItem.tagID];
                [feedItem populateWithCommentCount:count];
                
                // populate comments for this tag
                NSMutableArray * param = [[NSMutableArray alloc] init];
                [param addObject:tag.tagID];
                [param autorelease];
                KumulosHelper * kh = [[KumulosHelper alloc] init];
                [kh execute:@"getCommentHistory" withParams:param withCallback:@selector(didGetCommentHistoryWithResults:) withDelegate:self];
            }
            
            // this object must be retained so that the button actions can be used
            if (tag.tagID)
                [feedItems setObject:feedItem forKey:tag.tagID];
            
#if 0
            dispatch_async(dispatch_get_main_queue(), ^{
                [feedItem togglePlaceholderView:NO];
            });
        });
#endif
    } 
    else {
        // see what the dimensions were saved previously
        //NSLog(@"ViewForItem EXISTS:  feedItem ID %d index %d view %x height: %f ", feedItem.tagID, index, feedItem.view, feedItem.view.frame.size.height);
    }
    //NSLog(@"ViewForItem: feedItem ID %d index %d view %x frame %f %f %f %f", feedItem.tagID, index, feedItem.view, feedItem.view.frame.origin.x, feedItem.view.frame.origin.y, feedItem.view.frame.size.width, feedItem.view.frame.size.height);
    //[feedSectionHeights setObject:[NSNumber numberWithInt:feedItem.view.frame.size.height] forKey:tag.tagID];
    return feedItem.view;
}

-(UIImage*)getUserPhotoForUsername:(NSString *)username {
    return [delegate getUserPhotoForUsername:username];
}

-(void)didGetCommentHistoryWithResults:(NSMutableArray*)theResults {
    if ([theResults count] == 0)
        return;
    NSMutableArray * kumulosResults = [theResults objectAtIndex:0];
    if ([kumulosResults count] == 0)
        return;
    NSMutableDictionary * d = [kumulosResults objectAtIndex:0];
    NSNumber * tagID = [d objectForKey:@"tagID"];
    //NSLog(@"Adding comment history from kumulos: %d results for tag %d", [kumulosResults count], [tagID intValue]);
    //[commentHistories setObject:kumulosResults forKey:tagID];
    // expand feedview to display all comments
    // hack: to test expanding comments
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * tag = [allTagsDisplayed objectAtIndex:i];
        if ([tag.tagID intValue] == [tagID intValue]) {
            //NSLog(@"Displaying comments of tagID %d on page %d", [tag.tagID intValue], i);
            //[self reloadViewForItemAtIndex:i];
            return;
        }
    }
}

-(void)jumpToPageWithTagID:(int)tagID {
    // find position of tag in allTagsDisplayed
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * t = [allTagsDisplayed objectAtIndex:i];
        if ([t.tagID intValue] == tagID) {
            //[self reloadViewForItemAtIndex:i];
            NSLog(@"JumpToPageWithTagID: %d Target row: %d", tagID, i);
            NSIndexPath * targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            [tableController.tableView scrollToRowAtIndexPath:targetIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

-(IBAction)didClickJumpButton:(id)sender {
    // jumps to top
    NSIndexPath * targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableController.tableView scrollToRowAtIndexPath:targetIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(IBAction)didClickProfileButton:(id)sender {
    if ([delegate isShowingBuxInstructions])
        return;
    if ([delegate isDisplayingShareSheet])
        return;
    
    [self.delegate didOpenProfileView];
}

-(void)didPullToRefresh {
    [self updateScrollPagesAtPage:-1];
    [delegate checkAggregatorStatus];
    [self checkForUpdatedStix];
}

-(void)updateScrollPagesAtPage:(int)page {
    NSLog(@"VerticalFeedController: UpdateScrollPagesAtPage %d: AllTags currently has %d elements", page, [allTagsDisplayed count]);
    if ([self numberOfSections] > 0) {
        if (page < 0 + LAZY_LOAD_BOUNDARY) { // trying to find a more recent tag
            Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:0];
            int tagid = [t.tagID intValue];
            [self startActivityIndicator];
            [delegate getNewerTagsThanID:tagid];            
        }
        if (page >= [self numberOfSections] - LAZY_LOAD_BOUNDARY) { // trying to load an earlier tag
            Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:[self numberOfSections]-1];
            int tagid = [t.tagID intValue];
            [self startActivityIndicator];
            [delegate getOlderTagsThanID:tagid];
        }
    }
    else
    {
        NSLog(@"what's taking so long? sections %d tags %d feedItems %d", [self numberOfSections], [self itemCount], [feedItems count]);
        // no tags are loaded, just get the first few
        [delegate checkAggregatorStatus];
        [delegate getNewerTagsThanID:-1];        
        // should not come here!
        //NSLog(@"Error! allTags was never seeded!");
        //[self.delegate checkForUpdateTags];
        //[activityIndicator startCompleteAnimation];
        //[self startActivityIndicator];
    }
}

-(void)reloadPage:(int)page {
    // forces scrollview to clear view at lastPageViewed, forces self to recreate FeedItem at lastPageViewed, assumes updated allTags from the app delegate
    int section = page;
    [self populateAllTagsDisplayed];
    //[activityIndicator startCompleteAnimation];
    [self startActivityIndicator];
    if (section>[allTagsDisplayed count])
        section = 0;
    [self reloadViewForItemAtIndex:section];
}

-(void)reloadCurrentPage {
    // forces scrollview to clear view at lastPageViewed, forces self to recreate FeedItem at lastPageViewed, assumes updated allTags from the app delegate
    int section = [tableController getCurrentSectionAtPoint:CGPointMake(160, 240)];
    [self populateAllTagsDisplayed];
    //[activityIndicator startCompleteAnimation];
    [self startActivityIndicator];
    if (section>[allTagsDisplayed count])
        section = 0;
    [self reloadViewForItemAtIndex:section];
}

-(void)forceReloadWholeTableZOMG {
    NSLog(@"Calling forceReloadWholeTable - ZOMG!");
    
    int index = 0;
    for (int i=0; i<[[self.view subviews] count]; i++) {
        if ([[self.view subviews] objectAtIndex:i] == tableController.view) {
            index = i;
        }
    }
    [tableController.view removeFromSuperview];
    [tableController.tableView reloadData];
    [self.view insertSubview:tableController.view atIndex:index];
}

-(void)followListsDidChange {
    [self populateAllTagsDisplayed];
    [self forceReloadWholeTableZOMG];
    NSLog(@"After unfollowing user, there are %d tags on display.", [allTagsDisplayed count]);
}

-(void)populateAllTagsDisplayed {
    // allTags contains all tags that have been downloaded from the server
    // allTagsDisplayed contains only the tags that belong to the following list
    newestTagIDDisplayed = -1;
    self.allTags = [self.delegate getTags];
    if (!allTagsDisplayed)
        allTagsDisplayed = [[NSMutableArray alloc] init];
    [allTagsDisplayed removeAllObjects];
    NSMutableSet * followingSet = [delegate getFollowingList];
    NSMutableSet * followingSetWithMe = [[NSMutableSet alloc] initWithSet:followingSet];
    if ([delegate isLoggedIn]) {
        [followingSetWithMe addObject:[self getUsername]];
        for (int i=0; i<[allTags count]; i++) {
            Tag * tag = [allTags objectAtIndex:i];
            NSString * name = tag.username;
            if ([followingSetWithMe containsObject:name]) {
                [allTagsDisplayed addObject:tag];
                if ([tag.tagID intValue] > newestTagIDDisplayed)
                    newestTagIDDisplayed = [tag.tagID intValue];
            }            
            else {
                NSLog(@"Skipping tag %d with username %@", [tag.tagID intValue], tag.username);
                [feedItems removeObjectForKey:tag.tagID];
            }
        }
    }
    else
    {
        // display all tags
        [allTagsDisplayed addObjectsFromArray:allTags];
    }
    NSLog(@"After populateAllTagsDisplayed, allTagsDisplayed %d allTags %d", [allTagsDisplayed count], [allTags count]);
    [followingSetWithMe release];
}

-(void)addTagForDisplay:(Tag *)tag {
    // add newly created tag so it appears in the feed
    // create temporary tag id and timestamps
    tag.tagID = [NSNumber numberWithInt:-1]; // temp
    tag.timestamp = [NSDate date];
    [allTagsDisplayed insertObject:tag atIndex:0];
    [self forceReloadWholeTableZOMG];
}

-(void)finishedCheckingForNewData:(bool)updated {
    [tableController dataSourceDidFinishLoadingNewData];
    if (updated)
        [self reloadViewForItemAtIndex:0];
    //[tableController setContentPageIDs:allTags];
    [self stopActivityIndicator];
    //[self.activityIndicator stopCompleteAnimation];
}

-(int)itemCount
{
	// Return the total number of pages that exist, including unfollowed pages
	return [self.allTags count];
}

-(int)numberOfSections {
    return [self.allTagsDisplayed count];
}

-(void)forceUpdateCommentCount:(int)tagID {
    // this function is called after StixxAppDelegate has retrieved the comment
    // count from kumulos and inserted it into the allCommentCounts array
    
    //for (int i=0; i<[feedItems count]; i++) {
    VerticalFeedItemController * curr = [feedItems objectForKey:[NSNumber numberWithInt:tagID]];
    [curr populateWithCommentCount:[self.delegate getCommentCount:tagID]];
    
//    [scrollView reloadPage:lastPageViewed];
}

/************** FeedItemDelegate ***********/
// comes from feedItem instead of carousel
-(void)didClickAtLocation:(CGPoint)location withFeedItem:(VerticalFeedItemController *)feedItem {
    // location is the click location inside feeditem's frame
    
    NSLog(@"VerticalFeedController: Click on table at position %f %f with tagID %d\n", location.x, location.y, feedItem.tagID);

    CGPoint locationInStixView = location;
    //locationInStixView.x -= feedItem.stixView.frame.origin.x;
    //locationInStixView.y -= feedItem.stixView.frame.origin.y;
    int peelableFound = [[feedItem stixView] findPeelableStixAtLocation:locationInStixView];
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * tag = [allTagsDisplayed objectAtIndex:i];
        if ([tag.tagID intValue] == feedItem.tagID) {
            lastPageViewed = i;
            break;            
        }
    }
}

/*** verticalfeedItemDelegate ****/
-(void)displayCommentsOfTag:(int)tagID andName:(NSString *)nameString{
    if ([delegate getFirstTimeUserStage] < FIRSTTIME_DONE) {
        [delegate agitateFirstTimePointer];
        return;
    }
    if ([delegate isDisplayingShareSheet])
        return;
    if ([delegate isShowingBuxInstructions])
        return;
    
    if (commentView == nil) {
        commentView = [[CommentViewController alloc] init];
        [commentView setDelegate:self];
    }
    [commentView initCommentViewWithTagID:tagID andNameString:nameString];
    //[commentView setTagID:tagID];
    //[commentView setNameString:nameString];
    
#if 0
    // hack a way to display view over camera; formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [commentView.view setFrame:frameShifted];
    [self.camera setCameraOverlayView:commentView.view];
#else
    // hack a way to display feedback view over camera: formerly presentModalViewController
    CGRect frameOffscreen = CGRectMake(-320, 0, 320, 480);
    [self.view addSubview:commentView.view];
    [commentView.view setFrame:frameOffscreen];
    
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:commentView.view toFrame:frameOnscreen forTime:.5 withCompletion:^(BOOL finished){
        [animation release];
    }];
    
    // must force viewDidAppear because it doesn't happen when it's offscreen?
    [commentView viewDidAppear:YES];     
#endif
}

#if 0
- (void) shortenBlastTextUrls:(NSString*)url{
    
    /*
    // Create bit.ly helper if nil
    if (self.bitlyHelper == nil) {
        self.bitlyHelper = [[[BTBitlyHelper alloc] init] autorelease];
        self.bitlyHelper.delegate = self;
    }
    
    [self.bitlyHelper shortenURLSInText:url];
     */
}
- (void) BTBitlyShortUrl: (NSString *) shortUrl receivedForOriginalUrl: (NSString *) originalUrl{
    NSLog(@"URL %@ shortened to %@", originalUrl, shortUrl);
}
- (void) BTBitlyQueueStartedProcessing {}
- (void) BTBitlyQueueFinishedProcessing {}

#endif

-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    [self performSelector:callback withObject:params afterDelay:0];
}

// hack: forced display of comment page
-(void)openCommentForPageWithTagID:(NSNumber*)tagID {
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tagID];
    if (feedItem != nil) {
        [feedItem didPressAddCommentButton:self];
        for (int i=0; i<[allTagsDisplayed count]; i++) {
            Tag * tag = [allTagsDisplayed objectAtIndex:i];
            if ([tag.tagID intValue] == [tagID intValue]) {
                lastPageViewed = i;
            }
        }
    }
}

/*** CommentViewDelegate ***/
-(void)didCloseComments {
    // hack a way to remove view over camera; formerly dismissModalViewController
#if 0
    [self.delegate didDismissSecondaryView]; // same as aux view
#else
    StixAnimation * animation = [[StixAnimation alloc] init];
    CGRect frameOffscreen = commentView.view.frame;
    
    frameOffscreen.origin.x -= 330;
    [animation doViewTransition:commentView.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [commentView.view removeFromSuperview];
        [animation release];
    }];
#endif
}

-(void)didAddNewComment:(NSString *)newComment withTagID:(int)tagID{
    NSString * name = [self.delegate getUsername];
    //int tagID = [commentView tagID];
    if ([newComment length] > 0)
        [self.delegate didAddCommentWithTagID:tagID andUsername:name andComment:newComment andStixStringID:@"COMMENT"];
    [self didCloseComments];
}

//-(IBAction)feedbackButtonClicked:(id)sender {
//    [self.delegate didClickFeedbackButton:@"Feed view"];
//}

/*** FeedViewItemDelegate ***/
-(NSString*)getUsername {
    return [delegate getUsername];
}
-(NSString*)getUsernameOfApp {
    return [delegate getUsername];
}

-(void)didPerformPeelableAction:(int)action forAuxStix:(int)index {
    // change local tag structure for immediate display
    Tag * tag = [allTagsDisplayed objectAtIndex:lastPageViewed];
    if (action == 0) {
        // peel stix
        [tag removeStixAtIndex:index];
    }
    else if (action == 1) {
        // attach stix
        [[tag auxPeelable] replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];
        [allTagsDisplayed replaceObjectAtIndex:lastPageViewed withObject:tag];
    }
    //[self reloadCurrentPage];
    
    // tell app delegate to reload tag before altering internal info
    [self.delegate didPerformPeelableAction:action forTagWithIndex:lastPageViewed forAuxStix:index];
}

-(IBAction)adminStixButtonPressed:(id)sender {
    [self.delegate didPressAdminEasterEgg:@"FeedView"];
}

-(void)didDismissCarouselTab {
    /*
    CGRect newFrame = CGRectMake(0, 0, 320, 480);
    [self.tabBarController.view setFrame:newFrame];
     */
    if ([delegate getFirstTimeUserStage] == FIRSTTIME_MESSAGE_02) {
        [tabBarController toggleFirstTimePointer:YES atStage:FIRSTTIME_MESSAGE_02];
    }
}
-(void)didExpandCarouselTab {
    /*
    CGRect newFrame = self.tabBarController.view.frame;
    newFrame.origin.y = 20;
    newFrame.size.height += 80;
    [self.tabBarController.view setFrame:newFrame];
     */
    if ([delegate getFirstTimeUserStage] == FIRSTTIME_MESSAGE_02) {
        [tabBarController toggleFirstTimeInstructions:NO];
        [tabBarController toggleFirstTimePointer:NO atStage:FIRSTTIME_MESSAGE_02];
    }
}


#pragma mark UserGalleryDelegate

-(void)shouldDisplayUserPage:(NSString *)username {
    if ([delegate isShowingBuxInstructions])
        return;
    if ([delegate isDisplayingShareSheet])
        return;
    
    //    [self.delegate shouldDisplayUserPage:username];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = commentView.view.frame;
    frameOffscreen.origin.x -= 330;
    
    [animation doViewTransition:commentView.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [commentView.view removeFromSuperview];
        [delegate shouldDisplayUserPage:username];
    }];
}
-(void)shouldCloseUserPage {
    [delegate shouldCloseUserPage];
}


-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID {
    // send through to StixAppDelegate to save to defaults
    [delegate didReceiveRequestedStixViewFromKumulos:stixStringID];
}

#pragma mark bux instructions
-(BOOL)isShowingBuxInstructions {
    return [delegate isShowingBuxInstructions];
}
-(void)didClickMoreBuxButton:(id)sender {
    [delegate didShowBuxInstructions];
}

#pragma mark share
-(BOOL)isDisplayingShareSheet {
    return [delegate isDisplayingShareSheet];
}
-(void)didCloseShareSheet {
    CGRect frameOutside = CGRectMake(16-320, 22, 289, 380);
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    //shareMenuCloseAnimation = [animation doSlide:shareSheet inView:self.view toFrame:frameOutside forTime:.25];
    [animation doViewTransition:shareSheet toFrame:frameOutside forTime:.5 withCompletion:^(BOOL finished) {
        [self stopActivityIndicator];
        if (shareSheet) {
            [shareSheet release];   
            shareSheet = nil;
            [buttonShareEmail removeFromSuperview];
            [buttonShareFacebook removeFromSuperview];
            [buttonShareClose removeFromSuperview];
            [buttonShareEmail release];
            [buttonShareFacebook release];
            [buttonShareClose release];
            buttonShareClose = nil;
            buttonShareEmail = nil;
            buttonShareFacebook = nil;
        }
    }];
    
}

-(void)didClickCloseShareSheet {
    [self didCloseShareSheet];
    [delegate didCloseShareSheet];
}
-(void)didClickShareViaFacebook {
    [self startActivityIndicator];
    activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
    [self.view addSubview:activityIndicatorLarge];
    [activityIndicatorLarge startCompleteAnimation];
    dispatch_async( dispatch_queue_create("com.Neroh.Stix.FeedController.bgQueue", NULL), ^(void) {
        [shareFeedItem didClickShareViaFacebook];
    });
    [self didCloseShareSheet];
}

-(void)didClickShareViaEmail {
    [self startActivityIndicator];
    dispatch_async( dispatch_queue_create("com.Neroh.Stix.FeedController.bgQueue", NULL), ^(void) {
        [shareFeedItem didClickShareViaEmail];
    });
    [self didCloseShareSheet];
    activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
    [self.view addSubview:activityIndicatorLarge];
    [activityIndicatorLarge startCompleteAnimation];
}

-(void)didPressShareButtonForFeedItem:(VerticalFeedItemController *) feedItem {
    if ([delegate getFirstTimeUserStage] < FIRSTTIME_DONE) {
        [delegate agitateFirstTimePointer];
        return;
    }
    if ([delegate isShowingBuxInstructions])
        return;
    if ([delegate isDisplayingShareSheet])
        return;

    shareFeedItem = feedItem;
    
    CGRect frameInside = CGRectMake(16, 22, 289, 380);
    CGRect frameOutside = CGRectMake(16-320, 22, 289, 380);
    shareSheet = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share_actions.png"]];
    [shareSheet setFrame:frameOutside];
    //UIImageView * shareImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share_actions.png"]];
    //[shareImg setFrame:CGRectMake(16, 22, 289, 380)];
    //[shareSheet addSubview:shareImg];
    //CGRect frameInside = CGRectMake(0, 0, 320, 480);
    //CGRect frameOutside = CGRectMake(-320, 0, 320, 480);
    
    buttonShareFacebook = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [buttonShareFacebook setFrame:CGRectMake(68-16, 175-22, 210, 60)];
    [buttonShareFacebook setBackgroundColor:[UIColor clearColor]];
    [buttonShareFacebook addTarget:self action:@selector(didClickShareViaFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    buttonShareEmail = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [buttonShareEmail setFrame:CGRectMake(68-16, 250-22, 210, 60)];
    [buttonShareEmail setBackgroundColor:[UIColor clearColor]];
    [buttonShareEmail addTarget:self action:@selector(didClickShareViaEmail) forControlEvents:UIControlEventTouchUpInside];
    
    buttonShareClose = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [buttonShareClose setFrame:CGRectMake(270-16, 60-22, 37, 39)];
    [buttonShareClose setBackgroundColor:[UIColor clearColor]];
    [buttonShareClose addTarget:self action:@selector(didClickCloseShareSheet) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:shareSheet];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
//    shareMenuOpenAnimation = [animation doSlide:shareSheet inView:self.view toFrame:frameInside forTime:.25];
    [animation doViewTransition:shareSheet toFrame:frameInside forTime:.5 withCompletion:^(BOOL finished) {
        [self.view addSubview:buttonShareEmail];
        [self.view addSubview:buttonShareFacebook];
        [self.view addSubview:buttonShareClose];
    }];
    
    [delegate didDisplayShareSheet];
}

-(void)sharePixDialogDidFinish {
    [self didCloseShareSheet];
    if (activityIndicatorLarge) {
        [activityIndicatorLarge setHidden:YES];
        [activityIndicatorLarge stopCompleteAnimation];
        [activityIndicatorLarge removeFromSuperview];
        [activityIndicatorLarge release];
        activityIndicatorLarge = nil;
    }
    [delegate didCloseShareSheet];
}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas {
    // share menu
    if (animationID == shareMenuOpenAnimation) {
    }
    else if (animationID == shareMenuCloseAnimation) {
    }
}

-(void)finishedCreateNewPix:(NSNumber*)tagID {
    // force reload
    [self populateAllTagsDisplayed];
    [tableController.tableView reloadData];
   
    NSLog(@"FeedController: finished create new pix: sharing ID %d", [tagID intValue]);
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tagID];
    [self didPressShareButtonForFeedItem:feedItem];
}

-(void)checkForUpdatedStix {
    NSLog(@"Checking for updated stix in 10 most recent tags");
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        if (i >= [allTagsDisplayed count])
            break;
        Tag * tag = [allTagsDisplayed objectAtIndex:i];
        NSLog(@"Checking for updated stix at tag %d", [[tag tagID] intValue]);
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[[NSMutableArray alloc] initWithObjects:tag, tag.tagID, nil] autorelease];
        [kh execute:@"checkForUpdatedStix" withParams:params withCallback:@selector(khCallback_checkForUpdatedStix:) withDelegate:self];        
    }
}

-(void)khCallback_checkForUpdatedStix:(NSMutableArray*)returnParams {
    Tag * tag = [returnParams objectAtIndex:0];
    BOOL needUpdate = NO;
    NSDate * timestamp = tag.timestamp;
    for (int i=1; i<[returnParams count]; i++) {
        NSMutableDictionary * historyItem = [returnParams objectAtIndex:i];
        NSDate * timestampHistory = [historyItem objectForKey:@"timeCreated"];
        if ([timestampHistory compare:timestamp] == NSOrderedDescending)
            needUpdate = YES;
    }
    if (needUpdate) {
        NSLog(@"Tag %d needs to update stix", [[tag tagID] intValue]);
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[[NSMutableArray alloc] initWithObjects:tag.tagID, nil] autorelease];
        [kh execute:@"updateStixForPix" withParams:params withCallback:@selector(khCallback_updateStixForPix:) withDelegate:self];        
    } else {
        NSLog(@"Tag %d does not need to update stix", [[tag tagID] intValue]);
    }
}

-(void)khCallback_updateStixForPix:(NSMutableArray*)returnParams {
    NSNumber * tagID = [returnParams objectAtIndex:0];
    NSLog(@"UpdateStixForPix: %d", [tagID intValue]);
    NSMutableArray * theResults = [returnParams objectAtIndex:1];
    // find the correct tag in allTags;
    if ([theResults count] == 0)
        return;
    Tag * tag = nil;
    for (NSMutableDictionary * d in theResults) {
        Tag * t = [[Tag getTagFromDictionary:d] retain]; // MRC
        if ([t.tagID intValue]== [tagID intValue]) {
            tag = t; // MRC: when we break, t is not released so tag is retaining t
            break;
        }
        [t release];
    }
    if (tag == nil)
        return;
    // find local tag and sync with kumulos tag
    Tag * localTag = nil;
    int index = -1;
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        localTag = [allTagsDisplayed objectAtIndex:i];
        if ([localTag.tagID intValue] == [tagID intValue]) {
            index = i;
            break;
        }
    }
    NSLog(@"UpdateStixForPix: Found tag %d at index %d", [localTag.tagID intValue], index);
    [allTagsDisplayed replaceObjectAtIndex:index withObject:localTag];
    [delegate addTagWithCheck:tag withID:[tag.tagID intValue] overwrite:YES];
//    [self reloadViewForItemAtIndex:index];
//    [self.tableController.tableView reloadData];
    [self reloadPage:index];
}
@end

