//
//  ExploreViewController.m
//  Stixx
//
//  Created by Bobby Ren on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExploreViewController.h"

@implementation ExploreViewController
@synthesize carouselView;
@synthesize scrollView;
@synthesize delegate;
@synthesize buttonFeedback;
@synthesize allTagIDs;
@synthesize allTags;
@synthesize activityIndicator;

#define EXPLORE_COL 2
#define EXPLORE_ROW 2

-(id)init
{
	self = [super initWithNibName:@"ExploreViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"Explore"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_find.png"];
	[tbi setImage:i];
    
    k = nil;
    k = [[Kumulos alloc]init];
    [k setDelegate:self];    

    //activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 140, 80, 80)];
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(10, 11, 25, 25)];

    return self;
    
}
-(void)viewDidLoad {
    [super viewDidLoad];
    
    allTagIDs = [[NSMutableArray alloc] init];
    allTags = [[NSMutableArray alloc] init];
        
    [self initializeScrollWithPageSize:CGSizeMake(300, 400)];
    scrollView.isLazy = NO;
    //[self.view addSubview:scrollView];
    [self.view insertSubview:scrollView belowSubview:[self buttonFeedback]];

    /*** create badgeView ***/
    [self createCarouselView];

    [self.view addSubview:activityIndicator];
    zoomViewController = [[ZoomViewController alloc] init];
    //zoomView = [[UIImageView alloc] init];
    isZooming = NO;
    [self forceReloadAll];

//	return self;
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

-(IBAction)refreshUpdates:(id)sender {
    [self forceReloadAll];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation generateTagsByRecentUpdatesDidCompleteWithResult:(NSArray*)theResults {
    [allTagIDs removeAllObjects];
    [allTagIDs addObjectsFromArray:theResults];
    [allTags removeAllObjects];
    [allTags addObjectsFromArray:theResults];
    NSLog(@"%d recently updated tags added\n", [allTagIDs count]);
    
    for (int i=0; i<4; i++)
        [self getTagWithID:[[allTagIDs objectAtIndex:i] intValue]];
}

-(void)getTagWithID:(int)id {
    [k getAllTagsWithIDRangeWithId_min:id andId_max:id];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray*)theResults {
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [[Tag getTagFromDictionary:d] retain]; // MRC
        id new_id = [d valueForKey:@"allTagID"];

        int index = [allTagIDs indexOfObject:new_id];
        if (index > [allTags count])
        {
            [allTags insertObject:tag atIndex:[new_id intValue]];
        }
        else
        {
            [allTags replaceObjectAtIndex:[new_id intValue] withObject:tag];
        }
        [tag release]; // MRC
        //NSLog(@"Downloaded and added tag with id %d at index %d\n", [new_id intValue], index);
    }
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getMostRecentlyUpdatedTagDidCompleteWithResult:(NSArray*)theResults {
    int ct = 0;
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [[Tag getTagFromDictionary:d] retain]; // MRC
        
        int index = ct;
        if (index >= [allTags count])
        {
            [allTags insertObject:tag atIndex:ct];
        }
        else
        {
            [allTags replaceObjectAtIndex:ct withObject:tag];
        }
        ct++;
        [tag release]; // MRC
        //NSLog(@"Downloaded and added tag with id %d, name %@, comment %@ at index %d\n", new_id, name, comment, index);
    }
 
    [scrollView populateScrollPagesAtPage:0];
    //[activityIndicator setHidden:YES];
    [activityIndicator stopCompleteAnimation];
}
/*********** PagedScrollViewDelegate functions *******/

-(void)initializeScrollWithPageSize:(CGSize) pageSize
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
    // for now, display images of friends, six to a page
    UIView * exploreItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    //[friendPageView setBackgroundColor:[UIColor redColor]];
    int x = 0;
    int y = 0;
    int item_width = 140;
    int item_height = 128;
    //for (id key in userPhotos) {
    int items_per_page = EXPLORE_COL * EXPLORE_ROW;
    int start_index = index * items_per_page;
    int end_index = start_index + items_per_page - 1;
    //NSLog(@"Creating explore page %d with indices %d-%d", index, start_index, end_index);
    int ct = 0;
    for (int i=0; i<[allTags count]; i++) {
        if (ct >= start_index && ct <= end_index) {
            Tag * tag = [allTags objectAtIndex:i];
            
            UIImageView * shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropshadow_140.png"]];
            int w = shadow.frame.size.width;
            int h = shadow.frame.size.height;
            shadow.frame = CGRectMake(8 + x * (item_width + 10), 53 + y * (item_height + 20), w, h);
#if 0
            UIImageView * feedItem = [[UIImageView alloc] initWithImage:photo];
            [feedItem setBackgroundColor:[UIColor blackColor]];
            //NSString * name = tag.username;
            feedItem.frame = CGRectMake(5 + x * (item_width + 10), 50 + y * (item_height + 20), item_width, item_height);            
            UIImageView * stix = [[self populateWithBadge:tag.stixStringID withCount:tag.badgeCount atLocationX:tag.badge_x andLocationY:tag.badge_y] retain];
            [feedItem addSubview:stix];
            [stix release];
            [shadow release];
            [feedItem release];
#else              
            CGRect frame = CGRectMake(5 + x * (item_width + 10), 50 + y * (item_height + 20), item_width, item_height);
            stixView = [[StixView alloc] initWithFrame:frame];
            [stixView setInteractionAllowed:NO];
            [stixView setIsPeelable:NO];
            
            [stixView initializeWithImage:tag.image];
            [stixView populateWithAuxStixFromTag:tag];
            [exploreItemView addSubview:shadow];
            [exploreItemView addSubview:stixView];
            [shadow release];
            [stixView release];
#endif

            //NSLog(@"  Adding feed item %d = %@ to position %d %d", ct, comment, x, y);
            
            x = x + 1;
            if (x==EXPLORE_COL)
            {
                x = 0;
                y = y + 1;
            }
            if (y == EXPLORE_ROW)
                break;            
        }
        ct++;
        if (ct > end_index)
            break;
    }
    return [exploreItemView autorelease];
}

-(int)itemCount
{
	// Return the number of pages we intend to display
    int tot = [allTags count];
    int per_page = EXPLORE_COL * EXPLORE_ROW;
    if (tot % per_page == 0)
        return tot / per_page;
    return tot / per_page + 1;
}

// uiscrollview delegate - pass to PagedScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)sv
{
    if (sv == scrollView) 
    {
        PagedScrollView * psv = (PagedScrollView *)sv;
        int page = [psv currentPage];
        
#if 0
        // Load the visible and neighbouring pages 
#else
        // determine direction, for indicators
        //if (lastContentOffset < scrollView.contentOffset.x) { // right
        //    if (page == [self itemCount] - 1)
        //        [self.activityIndicator setHidden:NO];
        //}
        
        // left scroll to reload
        
        if (lastContentOffset > scrollView.contentOffset.x) { // left 
            if (page == 0)
            {
                //[self.activityIndicator setHidden:NO];   
                [self.activityIndicator startCompleteAnimation];
                [self forceReloadAll];
            }
        }

        [psv loadPage:page-1];
        [psv loadPage:page];
        [psv loadPage:page+1];

#endif
    }
}

-(void)forceReloadAll {
    //[k clearTagsByRecentUpdates];
    //[k generateTagsByRecentUpdates];

    [allTags removeAllObjects];
    [k getMostRecentlyUpdatedTagWithNumEls:[NSNumber numberWithInt:12]];
    [scrollView clearAllPages];
    //[activityIndicator startAnimating];
    //[activityIndicator setHidden:NO];
    isZooming = NO;
    [activityIndicator startCompleteAnimation];
}

/************** FeedZoomView ***********/

-(void)didClickAtLocation:(CGPoint)location {

    if (isZooming == YES)
        return;
    
    NSLog(@"Click on page %d at position %f %f\n", [scrollView currentPage], location.x, location.y);
   
    // dumb way to calculate which view we're looking at 
    // but this mirrors the way we populate this page
    int items_per_page = EXPLORE_COL * EXPLORE_ROW;
    int start_index = [scrollView currentPage] * items_per_page;
    int end_index = start_index + items_per_page - 1;
    int x=0;
    int y=0;
    int x0, y0, x1, y1;
    int item_width = 140;
    int item_height = 140;
    int ct;
    int foundid=-1;
    if (start_index >= items_per_page) {
        location.x -= [scrollView currentPage] * 300; // remove offset from scrollview 
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
    
    Tag * tag = [allTags objectAtIndex:ct];
    NSString * label = tag.descriptor;
    NSString * locationString = tag.locationString;
    NSLog(@"Using tag of comment %@ and location %@", label, locationString);
    /*
#if 1
    UIImage * image = tag.image;
    UIImage * photo = tag.image;
    
    // animate
    isZooming = YES;
    [zoomViewController setStixUsingTag:tag];
//    [zoomView setImage:photo];
    int xoffset = 10; // from scrollView width
    int yoffset = 3; // from ??
    zoomView.frame = CGRectMake(xoffset+5 + x * (item_width + 10), yoffset+50 + y * (item_height + 10), item_width, item_height);
    [self.view insertSubview:zoomView aboveSubview:scrollView];
    zoomFrame = zoomView.frame;
#else
    int xoffset = 10; // from scrollView width
    int yoffset = 3; // from ??
    zoomFrame = CGRectMake(xoffset+5 + x * (item_width + 10), yoffset+50 + y * (item_height + 10), item_width, item_height);
    stixView = [[StixView alloc] initWithFrame:zoomFrame];
    [stixView setInteractionAllowed:NO];
    [stixView setIsPeelable:NO];
    int centerX = tag.badge_x; // badgeFrame.origin.x + badgeFrame.size.width / 2;
    int centerY = tag.badge_y; //badgeFrame.origin.y + badgeFrame.size.height / 2;
    [stixView initializeWithImage:tag.image andStix:tag.stixStringID withCount:tag.badgeCount atLocationX:centerX andLocationY:centerY andScale:tag.stixScale andRotation:tag.stixRotation];
    [stixView populateWithAuxStixFromTag:tag];
    [self.view insertSubview:stixView aboveSubview:scrollView];
#endif
    CGRect frameBig = CGRectMake(10, 58, 300, 300); // hard coded from ZoomViewController.xib
    // animate a scaling transition
    NSLog(@"Stix frame before: %f %f %f %f", stixView.frame.origin.x, stixView.frame.origin.y, stixView.frame.size.width, stixView.frame.size.height);
    [UIView 
     animateWithDuration:5
     delay:0 
     options:UIViewAnimationCurveEaseOut
     animations:^{
#if 1
         zoomView.frame = frameBig;
#else
         stixView.frame = frameBig;
#endif
     }
     completion:^(BOOL finished){
#if 1
        zoomView.hidden = YES;
         [zoomViewController setDelegate:self];
         [self.view insertSubview:zoomViewController.view aboveSubview:scrollView];
         //[zoomViewController forceImageAppear:image];
         [zoomViewController setLabel:label];
         //[zoomViewController setLocation:locationString];
         [zoomViewController setStixUsingTag:tag];
         [carouselView setUnderlay:zoomViewController.view];
         isZooming = NO;
#else
         [stixView setHidden:YES];
         [zoomViewController setDelegate:self];
         [self.view insertSubview:zoomViewController.view aboveSubview:scrollView];
         [zoomViewController setLabel:label];
         //[zoomViewController setLocation:locationString];
         [zoomViewController setStixUsingTag:tag];
         [carouselView setUnderlay:zoomViewController.view];
         isZooming = NO;
         NSLog(@"Stix frame after: %f %f %f %f", stixView.frame.origin.x, stixView.frame.origin.y, stixView.frame.size.width, stixView.frame.size.height);
#endif
     }
     ];
     */
    [zoomViewController setDelegate:self];
    [self.view insertSubview:zoomViewController.view aboveSubview:scrollView];
    [zoomViewController setLabel:label];
    [zoomViewController setStixUsingTag:tag];
    [carouselView setUnderlay:zoomViewController.view];
    isZooming = NO;
    
}

-(void)didDismissZoom {
    // animate
    /*
#if 1
    [zoomView setHidden:NO];
#else
    [stixView setHidden:NO];
#endif
    isZooming = YES;

    // animate a scaling transition
    [UIView 
     animateWithDuration:5
     delay:0 
     options:UIViewAnimationCurveEaseOut
     animations:^{
#if 1
         zoomView.frame = zoomFrame;
#else
         stixView.frame = zoomFrame;
#endif
     }
     completion:^(BOOL finished){
#if 1
         [zoomView setHidden:YES];
         [zoomView removeFromSuperview];
#else
         stixView.hidden = YES;
         [stixView removeFromSuperview];
         [stixView release];
#endif
         [carouselView setUnderlay:scrollView];
         isZooming = NO;
     }
     ];
     */
    isZooming = NO;
    [carouselView setUnderlay:scrollView];
    [zoomViewController.view removeFromSuperview];
}

-(IBAction)feedbackButtonClicked:(id)sender {
    [self.delegate didClickFeedbackButton:@"Explore view"];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [carouselView resetBadgeLocations];    
	[super viewDidAppear:animated];
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
    [carouselView resetBadgeLocations];
}

-(int)getStixCount:(NSString*)stixStringID {
    return [self.delegate getStixCount:stixStringID];
}
-(int)getStixOrder:(NSString*)stixStringID;
{
    return [self.delegate getStixOrder:stixStringID];
}

-(void)viewDidUnload {
    
    [carouselView release];
    carouselView = nil;
    [scrollView release];
    scrollView = nil;
    [activityIndicator release];
    activityIndicator = nil;

    [super viewDidUnload];
}
-(void)dealloc {
    [k release];
    [carouselView release];
    [scrollView release];
    [activityIndicator release];
    [super dealloc];
}

@end
