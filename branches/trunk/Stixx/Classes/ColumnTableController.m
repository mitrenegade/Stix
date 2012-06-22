//
//  ColumnTableController.m
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColumnTableController.h"

@implementation ColumnTableController

@synthesize delegate;

#if USE_PULL_TO_REFRESH
@synthesize reloading=_reloading;
@synthesize refreshHeaderView;
@synthesize hasHeaderRow;
#endif

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        hasHeaderRow = NO;
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

#if USE_PULL_TO_REFRESH
    if (refreshHeaderView == nil) {
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
        refreshHeaderView.backgroundColor = [UIColor colorWithWhite:0 alpha:.85]; //[UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        refreshHeaderView.bottomBorderThickness = 1.0;
        [self.tableView addSubview:refreshHeaderView];
        self.tableView.showsVerticalScrollIndicator = YES;
    }
#endif
    cellDictionary = [[NSMutableDictionary alloc] init];
}

-(void)setNumberOfColumns:(int)columns andBorder:(int)border {
    numColumns = columns;
    borderWidth = border;
    int frameWidth = self.tableView.frame.size.width;
    if (numColumns == 2) {
        columnPadding = 4;
        columnWidth = (frameWidth - 2 * borderWidth - columnPadding) / 2;
    }
    if (numColumns == 3) {
        columnPadding = 3;
        columnWidth = (frameWidth - 2 * borderWidth - columnPadding * 2) / 3;
    }
    columnHeight = PIX_HEIGHT / PIX_WIDTH * columnWidth;
}
-(int)getContentWidth {
    return columnWidth;
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [delegate numberOfRows];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(headerForSection:)])
        return [self.delegate headerForSection:section];
    else 
        return nil;
}
- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(heightForHeader)])
        return [self.delegate heightForHeader];
    else
        return 0;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (hasHeaderRow && [indexPath row] == 0)
        return 180;
    return columnHeight + columnPadding;
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
        //cell.backgroundView = [[[UIImageView alloc] init] autorelease];
        //cell.selectedBackgroundView = [[[UIImageView alloc] init] autorelease];
        
		//cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setHighlightedTextColor:[cell.textLabel textColor]];
        cell.textLabel.numberOfLines = 1;
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor blackColor]];
    }
    /*
     else {
     [cell.accessoryView removeFromSuperview];
     [cell.contentView removeFromSuperview];
     }
     */
    int row = [indexPath row];
    //NSLog(@"Column table: populating row %d", row);
    if ([self hasHeaderRow]) {
        if (row == 0) {
            // row 0 is header
            CGRect frame = CGRectMake(borderWidth, columnPadding, tableView.frame.size.width - 2*columnPadding, 160);
            NSNumber * cellColumnKey = [NSNumber numberWithInt:(cell.hash*10)];// finds unique identifier for position in this cell
            UIView * cellOldView = [cellDictionary objectForKey:cellColumnKey];         
            if (cellOldView != nil) 
                [cellOldView removeFromSuperview];
            UIView * elementView = [self.delegate viewForItemAtIndex:row * numColumns]; 
            if (elementView != nil) {
                [elementView setFrame:frame];
//                [elementView setBackgroundColor:[UIColor greenColor]];
                [cell addSubview:elementView];
                [cellDictionary setObject:elementView forKey:cellColumnKey];
            }
            for (int col=1; col<numColumns; col++) {
                NSNumber * cellColumnKey = [NSNumber numberWithInt:(cell.hash*10 + col)];// finds unique identifier for position in this cell
                UIView * cellOldView = [cellDictionary objectForKey:cellColumnKey];         
                if (cellOldView != nil) 
                    [cellOldView removeFromSuperview];
            }
        }
        else
        {   
            // other rows are normal
            for (int col=0; col<numColumns; col++) {
                CGRect frame = CGRectMake(borderWidth + (columnWidth + columnPadding) * col, columnPadding, columnWidth, columnHeight);
                NSNumber * cellColumnKey = [NSNumber numberWithInt:(cell.hash*10+col)];// finds unique identifier for position in this cell
                UIView * cellOldView = [cellDictionary objectForKey:cellColumnKey];         
                if (cellOldView != nil) 
                    [cellOldView removeFromSuperview];
                UIView * elementView = [delegate viewForItemAtIndex:row * numColumns + col]; 
                if (elementView != nil) {
                    [elementView setFrame:frame];
                    [cell addSubview:elementView];
                    [cellDictionary setObject:elementView forKey:cellColumnKey];
                }
            }
        }        
    }
    else
    {
        // all rows are normal
        
        for (int col=0; col<numColumns; col++) {
            CGRect frame = CGRectMake(borderWidth + (columnWidth + columnPadding) * col, columnPadding, columnWidth, columnHeight);
            NSNumber * cellColumnKey = [NSNumber numberWithInt:(cell.hash*10+col)];// finds unique identifier for position in this cell
            UIView * cellOldView = [cellDictionary objectForKey:cellColumnKey];         
            if (cellOldView != nil) 
                [cellOldView removeFromSuperview];
            UIView * elementView = [self.delegate viewForItemAtIndex:row * numColumns + col]; 
            if (elementView != nil) {
                [elementView setFrame:frame];
                [cell addSubview:elementView];
                [cellDictionary setObject:elementView forKey:cellColumnKey];
            }
        }
    }
    if (row == [self.delegate numberOfRows] - 3 || row == [self.delegate numberOfRows]-1)
        [self.delegate loadContentPastRow:[self.delegate numberOfRows]];

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

#if USE_PULL_TO_REFRESH
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
	}
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
        //[delegate didPullToRefreshDoActivityIndicator];
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

    [self.tableView reloadData];
    if (_reloading) {
    	[UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];
        
        [refreshHeaderView setState:EGOOPullRefreshNormal];

    }
	_reloading = NO;
}

- (void) reloadTableViewDataSource
{
    [self.delegate didPullToRefresh];
}
#endif

@end
