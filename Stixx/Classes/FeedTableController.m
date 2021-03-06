//
//  FeedTableController.m
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedTableController.h"

@implementation FeedTableController

@synthesize delegate;
@synthesize reloading=_reloading;
@synthesize refreshHeaderView;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];    

    if (refreshHeaderView == nil) {
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
        refreshHeaderView.backgroundColor = [UIColor colorWithWhite:0 alpha:.85]; //[UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        refreshHeaderView.bottomBorderThickness = 1.0;
        [self.tableView addSubview:refreshHeaderView];
        self.tableView.showsVerticalScrollIndicator = YES;
    }
    
    cellDictionary = [[NSMutableDictionary alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //NSLog(@"Getting header for section: %d", section);
    return [self.delegate headerForSection:section];
}
- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //NSLog(@"Getting height for header for section: %d: %d", section, [delegate heightForHeaderInSection:section]);
    return [delegate heightForHeaderInSection:section]; //HEADER_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return [contentPageIDs count];
    return [delegate numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int height = [self.delegate getHeightForSection:([indexPath section])];
    //NSLog(@"GetHeightForSection %d returned %d", [indexPath section], height);
    return height; //CONTENT_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    //StixStoreTableCell *cell = (StixStoreTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[StixStoreTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // from http://cocoawithlove.com/2009/04/easy-custom-uitableview-drawing.html
        //
        // Create a background image view.
        //
        cell.backgroundView = [[UIImageView alloc] init];
        cell.selectedBackgroundView = [[UIImageView alloc] init];
        
		//cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setHighlightedTextColor:[cell.textLabel textColor]];
        cell.textLabel.numberOfLines = 1;
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    /*
     else {
     [cell.accessoryView removeFromSuperview];
     [cell.contentView removeFromSuperview];
     }
     */
    UIView * cellOldView = [cellDictionary objectForKey:[NSNumber numberWithInt:cell.hash]];
    if (cellOldView != nil)
        [cellOldView removeFromSuperview];
    
    int y = [indexPath section];
    //NSLog(@"Vertical Feed Table: Loading row %d total rows %d", y, [delegate numberOfSections]);
    UIView * view;
    view = [delegate viewForItemAtIndex:y];
    //[cell.contentView removeFromSuperview];
    [cell.contentView addSubview:view];
    if (view)
        [cellDictionary setObject:view forKey:[NSNumber numberWithInt:cell.hash]];

    if (y == 0) 
        [delegate updateScrollPagesAtPage:-1];
    
    if (y == [delegate numberOfSections]-1) // last available row reached 
    {
        //NSLog(@"Reached last row in feed");
        [delegate updateScrollPagesAtPage:[delegate numberOfSections]];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
}
/*
-(void)setContentPageIDs:(NSMutableDictionary *) tags {
    // delegate tells the table what views are available
    if (contentPageIDs) {
        [contentPageIDs release];
        contentPageIDs = nil;
    }
    contentPageIDs = [[NSMutableDictionary alloc] init];
    //[contentPageIDs addObjectsFromArray:tags];
    [contentPageIDs addEntriesFromDictionary:tags];
    
    [self.tableView reloadData];
}
 */

-(int)getCurrentSectionAtPoint:(CGPoint) point {
    float offset = self.tableView.contentOffset.y;
    //NSLog(@"GetCurrentSectionAtPoint: %f %f Offset: %f", point.x, point.y, offset);
    point.y += offset;
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: point];
    return [indexPath section];
}
-(CGPoint)getContentPoint:(CGPoint)point inSection:(int)section {
//    int section = [self getCurrentSectionAtPoint:point];
    int originy = section * (HEADER_HEIGHT + CONTENT_HEIGHT) + HEADER_HEIGHT;
    int offsety = self.tableView.contentOffset.y - originy;
    NSLog(@"Originy: %d offsety: %d contentoffset: %f", originy, offsety, self.tableView.contentOffset.y);
    return CGPointMake(point.x, point.y+offsety);
}
-(CGPoint)getPointInTableViewFrame:(CGPoint)point fromPage:(int)section{
    // we get a point that comes from the feedItem's frame
    // we return the location in the current static table's frame
    //int section = [self getCurrentSectionAtPoint:point];
    int originy = section * (HEADER_HEIGHT + CONTENT_HEIGHT) + HEADER_HEIGHT;
    point.y += originy;
    return point;
}

#pragma mark -
#pragma mark ScrollView Callbacks
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
            NSLog(@"ScrollView: EGO refreshHeaderView going to normal");
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
            NSLog(@"ScrollView: EGO refreshHeaderView going to pulling");
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
        /*
        else if (refreshHeaderView.state == EGOOPullRefreshLoading && _reloading) {
            NSLog(@"ScrollView: dragging while reloading: contentOffset %f", scrollView.contentOffset.y);
            // cancel reloading status (reset the position of the refresh header and allow future pulls to initiate a refresh
            if (scrollView.contentOffset.y > 0) {
                _reloading = NO;
                [self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
                [refreshHeaderView setState:EGOOPullRefreshNormal];
                
            }
        }
         */
	}
    
    [delegate feedDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
#if 0
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        //[UIView setAnimationDidStopSelector:@selector(refreshHeaderRestore)];
        [UIView setAnimationDelegate:self];
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
#else
        [delegate didPullToRefreshDoActivityIndicator];
        [refreshHeaderView setState:EGOOPullRefreshLoading];
        [UIView animateWithDuration:.5
                              delay:0
                            options: UIViewAnimationCurveLinear
                         animations:^{
                             [self.tableView setContentInset:UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0)];
                         } 
                         completion:^(BOOL finished){
                             NSLog(@"EGO Refresh view: content inset at 60 - calling reloadTableViewDataSource");
                             [self reloadTableViewDataSource];
                             [UIView animateWithDuration:0.2
                                                   delay:1
                                                 options: UIViewAnimationCurveLinear
                                              animations:^{
                                                  [self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
                                              }
                                              completion:^(BOOL finished) {
                                                  NSLog(@"EGO Refresh view: content inset at 0");
                                                  [refreshHeaderView setState:EGOOPullRefreshNormal];
                                                  _reloading = NO;
                                              }
                              ];
                         }
         ];
#endif
	}
}
#pragma mark -
#pragma mark refreshHeaderView Methods

- (void)dataSourceDidFinishLoadingNewData{
	
    if (1) { //_reloading) {
        _reloading = NO;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];
        
        [refreshHeaderView setState:EGOOPullRefreshNormal];
    }
}
- (void) reloadTableViewDataSource
{
    int pages = [delegate numberOfSections];
    int total = [delegate itemCount];
    NSLog(@"Table pages: %d total tags: %d", pages, total);
    // [self.delegate updateScrollPagesAtPage:-1];
    [delegate didPullToRefresh];
    if ([self.delegate numberOfSections] == 1) {
        NSLog(@"Only one page so far, we should load more!");
        [delegate updateScrollPagesAtPage:[self.delegate numberOfSections]];
    }
}


@end
