//
//  FriendsViewController.m
//  Stixx
//
//  Created by Bobby Ren on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendsViewController.h"

@implementation FriendsViewController

@synthesize userPhotos;
@synthesize delegate;
@synthesize buttonInstructions;
@synthesize buttonBack;
@synthesize badgeView;
@synthesize activityIndicator;
@synthesize scrollView;

#define FRIENDS_COL 3
#define FRIENDS_ROW 2

-(id)init
{
	[super initWithNibName:@"FriendsViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"Friends"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_friends.png"];
	[tbi setImage:i];

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 140, 80, 80)];

    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
	/****** init badge view ******/
	badgeView = [[BadgeView alloc] initWithFrame:self.view.frame];
    badgeView.delegate = self;
    [self initializeScrollWithPageSize:CGSizeMake(300, 400)];
    scrollView.isLazy = NO;
    [delegate didCreateBadgeView:badgeView];
  
    // add badgeView and scrollView as subviews of feedview; set underlay
    // important: in the beginning, buttonInstructions is the underlay for badgeView which means
    // any touch events get fowarded to buttonInstructions, as long as it is above the view 
    // for the scrollview
    [self.view insertSubview:scrollView belowSubview:buttonInstructions];
    [self.view insertSubview:badgeView aboveSubview:scrollView];
    [badgeView setUnderlay:buttonInstructions];
    [badgeView setHidden:YES];

    [self.view addSubview:activityIndicator];
    //	return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [buttonInstructions release];
    buttonInstructions = nil;
    [activityIndicator release];
    activityIndicator = nil;
    [badgeView release];
    badgeView = nil;
    [scrollView release];
    scrollView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
	//[imageView setImage:[[ImageCache sharedImageCache] imageForKey:@"newImage"]];
	[super viewWillAppear:animated];    

    // do not call checkForUpdatePhotos; it forces a viewWillAppear so we'd end in an infinite loop
    [self forceReloadAll];    
    [badgeView resetBadgeLocations];    
}

- (void)viewDidAppear:(BOOL)animated {
    [badgeView resetBadgeLocations];    
	[super viewDidAppear:animated];
}

- (void)setIndicator:(BOOL)animate {
    if (animate)
    {
        //[activityIndicator setHidden:NO];
        [activityIndicator startCompleteAnimation];
    }
    else
    {
        //[activityIndicator setHidden:YES];
        [activityIndicator stopCompleteAnimation];
    }
}

-(IBAction)backButtonClicked:(id)sender {
    //[self dismissModalViewControllerAnimated:NO];
    [self.view removeFromSuperview];
    [self.delegate didDismissFriendView];
}

-(IBAction)closeInstructions:(id)sender
{
    [buttonInstructions setHidden:YES];
    [badgeView setHidden:NO];
    [badgeView setUnderlay:scrollView];
}

/******* badge view delegate ******/
-(void)didDropStix:(UIImageView *)badge ofType:(int)type {
    [delegate decrementStixCount:type forUser:[delegate getUsername]];
    // todo: increment stix count for this friend
}

-(int)getStixCount:(int)stix_type {
    return [self.delegate getStixCount:stix_type];
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
    UIView * friendPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    //[friendPageView setBackgroundColor:[UIColor redColor]];
    int x = 0;
    int y = 0;
    //for (id key in userPhotos) {
    int items_per_page = FRIENDS_COL * FRIENDS_ROW;
    int start_index = index * items_per_page;
    int end_index = start_index + items_per_page - 1;
    NSLog(@"Creating friend page %d with indices %d-%d", index, start_index, end_index);
    NSEnumerator *e = [userPhotos keyEnumerator];
    id key;
    int ct = 0;
    while (key = [e nextObject]) {
        if (ct >= start_index && ct <= end_index) {
            UIImage * photo = [[UIImage alloc] initWithData:[userPhotos objectForKey:key]];
            UIImageView * friendView = [[UIImageView alloc] initWithImage:photo];
            [friendView setBackgroundColor:[UIColor blackColor]];
            NSString * name = key;
            friendView.frame = CGRectMake(5 + x * (90 + 10), 80 + y * (90 + 10+20), 90, 90);
            UILabel * namelabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + x * (90 + 10), 80 + y * (90 + 10+20) + 85, 90, 20)];
            [namelabel setText:name];
            [namelabel setBackgroundColor:[UIColor blackColor]];
            [namelabel setTextColor:[UIColor whiteColor]];
            [namelabel setTextAlignment:UITextAlignmentCenter];
            [friendPageView addSubview:friendView];
            [friendPageView addSubview:namelabel];
            [photo release];
            [friendView release];
            [namelabel release];
            
            NSLog(@"  Adding friend %d = %@ to position %d %d", ct, name, x, y);
            
            x = x + 1;
            if (x==FRIENDS_COL)
            {
                x = 0;
                y = y + 1;
            }
            if (y == FRIENDS_ROW)
                break;            
        }
        ct++;
        if (ct > end_index)
            break;
    }
    return [friendPageView autorelease];
}

-(int)itemCount
{
	// Return the number of pages we intend to display
    int tot = [self.userPhotos count];
    int per_page = FRIENDS_COL * FRIENDS_ROW;
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
    [scrollView clearAllPages];
    self.userPhotos = [self.delegate getUserPhotos]; 
    [scrollView populateScrollPagesAtPage:0];
}

-(void)didClickAtLocation:(CGPoint)location {
    // do nothing
}

@end
