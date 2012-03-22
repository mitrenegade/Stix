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
        [refreshHeaderView release];
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
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLog(@"Title for section header %d", section);
    if (section > [contentPageIDs count])
        return nil;
    Tag * tag = [contentPageIDs objectAtIndex:section];
    return [NSString stringWithFormat:@"%d: %@", tag.username, section];
}
 */
/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //return [[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return [NSArray arrayWithObjects:@"One", @"Two", @"Three", @"Four", @"Five", @"Six", nil];
}
*/
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self.delegate headerForSection:section];
}
- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //NSLog(@"Number of sections: %d", [contentPageIDs count]);
    return [contentPageIDs count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
//    return [contentPageIDs count];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int height = [self.delegate getHeightForSection:([indexPath section])];
    // NSLog(@"GetHeightForSection %d returned %d", [indexPath section], height);
    return CONTENT_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    //StixStoreTableCell *cell = (StixStoreTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[StixStoreTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        // from http://cocoawithlove.com/2009/04/easy-custom-uitableview-drawing.html
        //
        // Create a background image view.
        //
        cell.backgroundView = [[[UIImageView alloc] init] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] init] autorelease];
        
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
    //NSLog(@"Vertical Feed Table: Loading row %d", y);
    //NSNumber * tagID = [contentPageIDs objectAtIndex:y];
    UIView * view;
    view = [self.delegate viewForItemAtIndex:y];
    //[cell.contentView removeFromSuperview];
    [cell.contentView addSubview:view];
    [cellDictionary setObject:view forKey:[NSNumber numberWithInt:cell.hash]];
    
    if (y == [contentPageIDs count]-1) // last available row reached 
    {
        [self.delegate updateScrollPagesAtPage:[contentPageIDs count]];
    }
    else if (y == 0) // first row reached - pull for update
    {
        //[self.delegate updateScrollPagesAtPage:-1];
    }    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}
/*
-(void)populatePagesAtPage:(int)currentPage {
    int pageCount = [self.delegate itemCount];
    if (contentPageIDs == nil) {
        contentPageIDs = [[NSMutableArray alloc] initWithCapacity:pageCount];
    }

    // Load the first two pages
    if (currentPage>0)
        [self loadPage:currentPage-1];
    [self loadPage:currentPage];
    if (currentPage<pageCount || pageCount == 1)
        [self loadPage:currentPage+1];
}

-(void)loadPage:(int)page
{
	// loading pages that do not exist - request from delegate
    // populates contentPages with FeedItemViews if they do not already exist
    if ([contentPageIDs count] == 0 || page < LAZY_LOAD_BOUNDARY || page>=[contentPageIDs count]-LAZY_LOAD_BOUNDARY)
    { 
        // page = -1: look for newer data on server
        // page > total pages: look for older data on server - only for delayed load
        [self.delegate updateScrollPagesAtPage:page]; 
    }
	else {
        // Check if the page is already loaded
        NSNumber * tagID = [contentPageIDs objectAtIndex:page];
        UIView *view = [self.delegate viewForItemWithTagID:tagID];
        
        if (view == nil) {
            view = [[self.delegate viewForItemAtIndex:page] retain];
            // does nothing with it
            [view release];
        }
    }
}
*/
-(void)setContentPageIDs:(NSMutableArray *) tags {
    // delegate tells the table what views are available
    if (contentPageIDs) {
        [contentPageIDs release];
        contentPageIDs = nil;
    }
    contentPageIDs = [[NSMutableArray alloc] init];
    /*
    for (int i=0; i<[tags count]; i++) {
        Tag * tag = [tags objectAtIndex:i];
        [contentPageIDs insertObject:tag.tagID atIndex:[contentPageIDs count]];
    }
    */
    [contentPageIDs addObjectsFromArray:tags];
    
    [self.tableView reloadData];
}

-(int)getCurrentSectionAtPoint:(CGPoint) point {
    float offset = self.tableView.contentOffset.y;
    NSLog(@"Point: %f %f Offset: %f", point.x, point.y, offset);
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
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}
#pragma mark -
#pragma mark refreshHeaderView Methods

- (void)dataSourceDidFinishLoadingNewData{
	
    if (_reloading) {
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
    int pages = [contentPageIDs count];
    int totalPages = [self.delegate itemCount];
    NSLog(@"Table pages: %d tags available: %d", pages, totalPages);
    [self.delegate updateScrollPagesAtPage:-1];
    if ([self.delegate itemCount] == 1) {
        NSLog(@"Only one page so far, we should load more!");
        [self.delegate updateScrollPagesAtPage:[self.delegate itemCount]];
    }
}


@end
