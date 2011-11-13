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
@synthesize username;
@synthesize nameLabel;
@synthesize delegate;
@synthesize activityIndicatorCenter; // initially is active
@synthesize activityIndicatorLeft;
@synthesize activityIndicatorRight;
@synthesize userPhotos;
@synthesize allTags;
@synthesize scrollView;
@synthesize lastPageViewed;

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
    
    lastPageViewed = 0;
    
	/****** init badge view ******/
	badgeView = [[BadgeView alloc] initWithFrame:self.view.frame];
    badgeView.delegate = self;
    [self initializeScrollWithPageSize:CGSizeMake(240, 320)];
    scrollView.isLazy = YES;

    // add badgeView and scrollView as subviews of feedview; set underlay
    [self.view addSubview:scrollView];
    [self.view insertSubview:badgeView aboveSubview:scrollView];
    [badgeView setUnderlay:scrollView];
    
	return self;
}

- (void)setIndicatorWithID:(int)which animated:(BOOL)animate {
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
        [activityIndicatorCenter setHidden:YES];
        [activityIndicatorCenter stopAnimating];
        [activityIndicatorLeft setHidden:YES];
        [activityIndicatorLeft stopAnimating];
        [activityIndicatorRight setHidden:YES];
        [activityIndicatorRight stopAnimating];
    }
}

-(void)setUsernameLabel:(NSString *)name {
    [self setUsername:name];
    //[self.nameLabel setText:name];
}

- (void)viewWillAppear:(BOOL)animated
{
	//[imageView setImage:[[ImageCache sharedImageCache] imageForKey:@"newImage"]];
	[super viewWillAppear:animated];
    
    //[self.delegate checkForUpdateTags];

    self.allTags = [self.delegate getTags];
    [scrollView populateScrollPagesAtPage:lastPageViewed];
    
    self.userPhotos = [self.delegate getUserPhotos]; 
    NSLog(@"Loaded %d tags and %d users", [self.allTags count], [self.userPhotos count]);
    //[self.nameLabel setText:username];
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
	
    [scrollView clearNonvisiblePages];
}

- (void)viewDidUnload {
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
}


- (void)dealloc 
{
	[scrollView release];
	[allTags release];
    [username release];    
	[scrollView release];
    [super dealloc];
}

/******* badge view delegate ******/
-(void)addTag:(UIImageView *)badge {
    
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
	// Note that the images are actually smaller than the image view frame, each image
	// is 210x280. Images are centered and because they are smaller than the actual 
	// view it creates a padding between each image. 
	//CGRect imageViewFrame = CGRectMake(0.0f, 0.0f, 240, 320);
	
    //NSLog(@"Index: %d reverse_index: %d", index, reverse_index);
    Tag * tag = [[allTags objectAtIndex:index] retain];
    
    NSString * name = tag.username;
    NSString * comment = tag.comment;
    UIImage * image = tag.image;
    
    NSLog(@"Creating feed item at index %d: name %@ comment %@ image dims %f %f\n", index, name, comment, image.size.width, image.size.height);
    
    FeedItemViewController * feedItem = [[[FeedItemViewController alloc] init] autorelease];
    [feedItem populateWithName:name andWithComment:comment andWithImage:image];
    [feedItem.view setFrame:CGRectMake(0, 0, 240, 280)]; 
    UIImage * photo = [[UIImage alloc] initWithData:[userPhotos objectForKey:name]];
    if (photo)
    {
        NSLog(@"User %@ has photo of size %f %f\n", name, photo.size.width, photo.size.height);
        [feedItem populateWithUserPhoto:photo];
        [photo release];
    }
    // add timestamp
    [feedItem populateWithTimestamp:tag.timestamp];
    [tag release];
    return feedItem.view;
}

-(void)updateScrollPagesAtPage:(int)page {
    NSLog(@"UpdateScrollPagesAtPage %d: AllTags currently has %d elements", page, [allTags count]);
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
        
        lastPageViewed = page;

        // Load the visible and neighbouring pages 
        if (page>=0)
            [psv loadPage:page-1]; // if we are at page=0, this is a pull to refresh
        [psv loadPage:page];
        [psv loadPage:page+1];
    }
}

@end

