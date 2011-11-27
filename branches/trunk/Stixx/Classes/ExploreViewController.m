//
//  ExploreViewController.m
//  Stixx
//
//  Created by Bobby Ren on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExploreViewController.h"

@implementation ExploreViewController
@synthesize badgeView;
@synthesize scrollView;
@synthesize delegate;
@synthesize refreshButton;
@synthesize allTagIDs;
@synthesize allTags;

#define EXPLORE_COL 2
#define EXPLORE_ROW 2

-(id)init
{
	[super initWithNibName:@"ExploreViewController" bundle:nil];
	
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

    return self;
    
}
-(void)viewDidLoad {
    [super viewDidLoad];
    
    allTagIDs = [[NSMutableArray alloc] init];
    allTags = [[NSMutableArray alloc] init];
    
	/****** init badge view ******/
	badgeView = [[BadgeView alloc] initWithFrame:self.view.frame];
    badgeView.delegate = self;
    [self initializeScrollWithPageSize:CGSizeMake(300, 400)];
    [badgeView setUnderlay:scrollView];
    [delegate didCreateBadgeView:badgeView];

    [self.view addSubview:scrollView];
    [self.view insertSubview:badgeView aboveSubview:scrollView];
    
    zoomViewController = [[ZoomViewController alloc] init];

    [self forceReloadAll];

//	return self;
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
        Tag * tag = [Tag getTagFromDictionary:d];
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
        NSLog(@"Downloaded and added tag with id %d at index %d\n", [new_id intValue], index);
    }
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getMostRecentlyUpdatedTagDidCompleteWithResult:(NSArray*)theResults {
    int ct = 0;
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [Tag getTagFromDictionary:d];
        int new_id = [tag.tagID intValue];
        NSString * comment = tag.comment;
        NSString * name = tag.username;
        
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
        NSLog(@"Downloaded and added tag with id %d, name %@, comment %@ at index %d\n", new_id, name, comment, index);
    }
 
    [scrollView populateScrollPagesAtPage:0];
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
    int item_height = 140;
    //for (id key in userPhotos) {
    int items_per_page = EXPLORE_COL * EXPLORE_ROW;
    int start_index = index * items_per_page;
    int end_index = start_index + items_per_page - 1;
    NSLog(@"Creating friend page %d with indices %d-%d", index, start_index, end_index);
    int ct = 0;
    for (int i=0; i<[allTags count]; i++) {
        if (ct >= start_index && ct <= end_index) {
            Tag * tag = [allTags objectAtIndex:i];
            
            UIImage * photo = tag.image;
            NSString * comment = tag.comment;
            UIImageView * shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropshadow_140.png"]];
            UIImageView * feedItem = [[UIImageView alloc] initWithImage:photo];
            [feedItem setBackgroundColor:[UIColor blackColor]];
            //NSString * name = tag.username;
            int w = shadow.frame.size.width;
            int h = shadow.frame.size.height;
            shadow.frame = CGRectMake(8 + x * (item_width + 10), 53 + y * (item_height + 10), w, h);
            feedItem.frame = CGRectMake(5 + x * (item_width + 10), 50 + y * (item_height + 10), item_width, item_height);
            /*
            UILabel * commentlabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + x * (item_width + 10), 50 + y * (item_height + 10+20) + item_width-5, item_width, 20)];
            [commentlabel setText:comment];
            [commentlabel setBackgroundColor:[UIColor blackColor]];
            [commentlabel setTextColor:[UIColor whiteColor]];
            [commentlabel setTextAlignment:UITextAlignmentCenter];
             [friendPageView addSubview:commentlabel];
             */
            [exploreItemView addSubview:shadow];
            [exploreItemView addSubview:feedItem];
            [shadow release];
            [feedItem release];
            //[commentlabel release];
            
            NSLog(@"  Adding feed item %d = %@ to position %d %d", ct, comment, x, y);
            
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
        
        // Load the visible and neighbouring pages 
        [psv loadPage:page-1];
        [psv loadPage:page];
        [psv loadPage:page+1];
    }
}

-(void)forceReloadAll {
    //[k clearTagsByRecentUpdates];
    //[k generateTagsByRecentUpdates];

    [allTags removeAllObjects];
    [k getMostRecentlyUpdatedTagWithNumEls:[NSNumber numberWithInt:12]];
    [scrollView clearAllPages];
    
}

/************** FeedZoomView ***********/

-(void)didClickAtLocation:(CGPoint)location {
    // do nothing - forward click to button if necessary
    
    /*
    NSLog(@"Button location %f %f %f %f Click %f %f\n", refreshButton.frame.origin.x, refreshButton.frame.origin.y, refreshButton.frame.size.width, refreshButton.frame.size.height, location.x, location.y);
    if (location.x >= refreshButton.frame.origin.x && location.x <= refreshButton.frame.origin.x + refreshButton.frame.size.width && location.y >= refreshButton.frame.origin.y && location.y <= refreshButton.frame.origin.y + refreshButton.frame.size.height) {
        [self forceReloadAll];
    }
     */
//    [self forceReloadAll];

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
    UIImage * image = tag.image;
    NSString * label = tag.comment;
    NSString * locationString = tag.locationString;
    UIImage * photo = tag.image;
    
    // animate
    zoomView = [[UIImageView alloc] initWithImage:photo];
    int xoffset = 10; // from scrollView width
    int yoffset = 3; // from ??
    zoomView.frame = CGRectMake(xoffset+5 + x * (item_width + 10), yoffset+50 + y * (item_height + 10), item_width, item_height);
    [self.view insertSubview:zoomView aboveSubview:scrollView];
    zoomFrame = zoomView.frame;
    CGRect frameBig = CGRectMake(10, 58, 300, 300); // hard coded from ZoomViewController.xib
    // animate a scaling transition
    [UIView 
     animateWithDuration:.2
     delay:0 
     options:UIViewAnimationCurveEaseOut
     animations:^{
         zoomView.frame = frameBig;
     }
     completion:^(BOOL finished){
         zoomView.hidden = YES;
         [zoomViewController setDelegate:self];
         [self.view insertSubview:zoomViewController.view aboveSubview:scrollView];
         [zoomViewController forceImageAppear:image];
         [zoomViewController setLabel:label];
         [zoomViewController setLocation:locationString];
         [badgeView setUnderlay:zoomViewController.view];
     }
     ];
    
}

-(void)didDismissZoom {
    [zoomViewController.view removeFromSuperview];
#if 1
    // animate
    [zoomView setHidden:NO];

    // animate a scaling transition
    [UIView 
     animateWithDuration:.2
     delay:0 
     options:UIViewAnimationCurveEaseOut
     animations:^{
         zoomView.frame = zoomFrame;
     }
     completion:^(BOOL finished){
         zoomView.hidden = YES;
         [zoomView release];
         [badgeView setUnderlay:scrollView];
     }
     ];
#endif
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [badgeView resetBadgeLocations];    
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/******* badge view delegate ******/
-(void)didDropStix:(UIImageView *)badge ofType:(int)type {
    
}

-(int)getStixCount:(int)stix_type {
    return [self.delegate getStixCount:stix_type];
}

-(void)viewDidUnload {
    
    [badgeView release];
    badgeView = nil;
    [scrollView release];
    scrollView = nil;

    [super viewDidUnload];
}
-(void)dealloc {
    [k release];
    [badgeView release];
    [scrollView release];
    [super dealloc];
}

@end
