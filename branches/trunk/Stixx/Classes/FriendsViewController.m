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
@synthesize userPhotoFrames;
@synthesize delegate;
@synthesize buttonInstructions;
@synthesize buttonBack;
@synthesize carouselView;
@synthesize activityIndicator;
@synthesize scrollView;
@synthesize friendPages;
@synthesize currentProfile;
@synthesize userProfileController;

#define FRIENDS_COL 3
#define FRIENDS_ROW 2

-(id)init
{
	self = [super initWithNibName:@"FriendsViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"Friends"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_friends.png"];
	[tbi setImage:i];

//    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 140, 80, 80)];
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(10, 11, 25, 25)];

    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
	/****** init badge view ******/
	carouselView = [[CarouselView alloc] initWithFrame:self.view.frame];
    carouselView.delegate = self;
    [carouselView initCarouselWithFrame:CGRectMake(SHELF_STIX_X, SHELF_STIX_Y, 320, SHELF_STIX_SIZE)];
    
    [self initializeScrollWithPageSize:CGSizeMake(300, 400)];
    scrollView.isLazy = NO;
    [delegate didCreateBadgeView:carouselView];
  
    // add badgeView and scrollView as subviews of feedview; set underlay
    // important: in the beginning, buttonInstructions is the underlay for badgeView which means
    // any touch events get fowarded to buttonInstructions, as long as it is above the view 
    // for the scrollview
    [self.view insertSubview:scrollView belowSubview:buttonInstructions];
    [self.view insertSubview:carouselView aboveSubview:scrollView];
    [carouselView setUnderlay:buttonInstructions];
    [carouselView setHidden:YES];

    if (activityIndicator == nil)
        activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 140, 80, 80)];
    [self.view addSubview:activityIndicator];

    userPhotoFrames = [[NSMutableDictionary alloc] init];
    friendPages = [[NSMutableArray alloc] init];
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
    [carouselView release];
    carouselView = nil;
    [scrollView release];
    scrollView = nil;
    [userPhotoFrames release];
    userPhotoFrames = nil;
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
    [carouselView resetBadgeLocations];    
}

- (void)viewDidAppear:(BOOL)animated {
    [carouselView resetBadgeLocations];    
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
    [carouselView setHidden:NO];
    [carouselView setUnderlay:scrollView];
}

/******* badge view delegate ******/
-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID {
    CGPoint location = badge.center;
    location.x += scrollView.contentOffset.x;
    NSString * friendName = nil;
    NSEnumerator *e = [userPhotoFrames keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        CGRect frame = [[userPhotoFrames objectForKey:key] CGRectValue];
        if (CGRectContainsPoint(frame, location)){
            friendName = key;
            break;
        }
    }
    if (friendName != nil)
        [self.delegate didSendGiftStix:stixStringID toUsername:friendName];
    [carouselView resetBadgeLocations];
}

-(int)getStixCount:(NSString*)stixStringID {
    return [self.delegate getStixCount:stixStringID];
}
-(int)getStixOrder:(NSString*)stixStringID;
{
    return [self.delegate getStixOrder:stixStringID];
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
    // display images of friends, six to a page
    if ([friendPages count] < index+1 || [friendPages objectAtIndex:index] == nil)
    {
        UIView * friendPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];

        int x = 0;
        int y = 0;
        //for (id key in userPhotos) {
        int items_per_page = FRIENDS_COL * FRIENDS_ROW;
        int start_index = index * items_per_page;
        int end_index = start_index + items_per_page - 1;
        //NSLog(@"Creating friend page %d with indices %d-%d", index, start_index, end_index);
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

                // remember the frame
                CGRect scrollFrame = friendView.frame;
                scrollFrame.origin.x += index * friendPageView.frame.size.width;
                [userPhotoFrames setObject:[NSValue valueWithCGRect:scrollFrame] forKey:key];

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
        //[friendPages replaceObjectAtIndex:index withObject:friendPageView];        
        [friendPages addObject:friendPageView];
        return [friendPageView autorelease];
    }
    else
    {
        UIView * friendPageView = [friendPages objectAtIndex:index];
        return friendPageView;
    }
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
    //NSString * friendName = nil;
    NSEnumerator *e = [userPhotoFrames keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        CGRect frame = [[userPhotoFrames objectForKey:key] CGRectValue];
        if (CGRectContainsPoint(frame, location)){
            currentProfile = key;
            userProfileController = [[UserProfileViewController alloc] init];
            [userProfileController setDelegate:self];
            [self.view addSubview:userProfileController.view];
            
            // must add to subview before changing name/photo
            [userProfileController setUsername:currentProfile];
            UIImage * photo = [[UIImage alloc] initWithData:[userPhotos objectForKey:currentProfile]];
            [userProfileController setPhoto:[photo autorelease]];
            //friendName = key;
            break;
        }
    }
}

/**** userprofile view delegate ****/
- (int)getUserTagTotal {return 0;}

-(void)didDismissUserProfileView {
    [userProfileController.view removeFromSuperview];
    [userProfileController release];
    userProfileController = nil;
}
@end
