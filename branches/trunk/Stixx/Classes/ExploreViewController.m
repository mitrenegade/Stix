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
@synthesize scrollView, pageSize;

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
	
	/****** init badge view ******/
	badgeView = [[BadgeView alloc] initWithFrame:self.view.frame];
    badgeView.delegate = self;
    [self initializeScroll];
    [badgeView setUnderlay:scrollView];

    [self.view addSubview:scrollView];
    [self.view insertSubview:badgeView aboveSubview:scrollView];

	return self;
}

/**** PagedScrollViewDelegate functions *****/

-(void)initializeScroll
{
    if(1)
    {			  
        // We need to do some setup once the view is visible. This will only be done once.
        // Position and size the scrollview. It will be centered in the view.
        self.pageSize = CGSizeMake(240, 320);
        
        CGRect scrollViewRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
        scrollViewRect.origin.x = ((self.view.frame.size.width - pageSize.width) / 2);
        scrollViewRect.origin.y = ((self.view.frame.size.height - pageSize.height) / 2);
        scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    }
}

-(UIView*)viewForItemAtIndex:(int)index {
    return nil;
}

-(int)itemCount{
    return 0;
}
-(void)updateScrollPagesAtPage:(int)page {
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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
-(void)addTag:(UIImageView *)badge {
    
}

@end
