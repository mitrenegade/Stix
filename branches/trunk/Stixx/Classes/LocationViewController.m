//
//  LocationViewController.m
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LocationViewController.h"
#import "FourSquareLocator.h"

#define HEADER_HEIGHT 60


@implementation LocationViewController
@synthesize delegate;
@synthesize searchResults;
@synthesize needSearch;
- (id)init {
	
    self = [super init]; // initWithNibName:@"LocationViewController" bundle:nil];
    
    if (self) {
        // Custom initialization
        fsl = [[FourSquareLocator alloc] init];
        [fsl setDelegate:self];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    fsLocationStrings = nil;
    searchResults = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    fsLocationStrings = [[NSMutableArray alloc] init];
//    [fsl query:@""];

    self.clearsSelectionOnViewWillAppear = NO;
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.title = @"Stix's special location search";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;    
    
    searching = NO;
    letUserSelectRow = NO;
    needSearch = YES;
    
    //UIImage * background = [UIImage imageNamed:@"textured_background.png"];
    //[self.tableView.backgroundView = [[UIImageView alloc] initWithImage:background] autorelease];
    //[background release];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [fsLocationStrings removeAllObjects];
    fsLocationStrings = nil;
    
    fsl = nil;

    [self setSearchResults:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [fsl query:@""]; // requery
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
    return [fsLocationStrings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_divider.png"]]];
    }
    
    // Configure the cell...
    NSString * fsLocationStr = [fsLocationStrings objectAtIndex:[indexPath row]];    

    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setFrame:CGRectMake(0, 0, 320, 120)];
    [[cell textLabel] setText:fsLocationStr];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void)getFoursquareVenues:(NSString*)text
{
    // disable normal table functionality
    searching = YES;
    letUserSelectRow = NO;
    self.tableView.scrollEnabled = NO;
    
    // search for given query
    [fsl query:text];
}

-(void)receiveVenueNames:(NSArray *)venueNames andLatLong:(NSArray *)latlong
{
    
    searching = NO;
    letUserSelectRow = YES;
    self.tableView.scrollEnabled = YES;
    
    NSMutableArray * distArray = [[NSMutableArray alloc] init];
    
    if (needSearch) {
        [fsLocationStrings removeAllObjects];
#if 1
        for (int i=0; i<[venueNames count]; i++) {
            int insertIndexTarget = 0;
            double distFromHere = [fsl distanceFromLatLong:[latlong objectAtIndex:i]];
            for (int j=0; j<[distArray count]; j++) {
                double oldDist = [[distArray objectAtIndex:j] doubleValue];
                if (distFromHere < oldDist)
                    insertIndexTarget = j;
                NSLog(@"Comparing object %d with object %d: distance %f vs %f\n", i, j, distFromHere, oldDist);
            }
            [fsLocationStrings insertObject:[venueNames objectAtIndex:i] atIndex:insertIndexTarget];
            [distArray insertObject:[NSNumber numberWithDouble:distFromHere] atIndex:insertIndexTarget];
            NSLog(@"Inserted object at index %d", insertIndexTarget);
        }
#else
        [fsLocationStrings addObjectsFromArray:venueNames];
#endif
        [self.tableView reloadData];
        
        [self.delegate didReceiveSearchResults];
    }
}

-(void)didReceiveConnectionError {
    [self.delegate didReceiveConnectionError];
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
    
    NSString * locationString = [fsLocationStrings objectAtIndex:[indexPath row]];
    NSLog(@"Location string selected: %@", locationString);
    
    [self.delegate didChooseLocation:locationString];
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // overriding this prevents user from selecting anything if searching
    if(letUserSelectRow)
        return indexPath;
    else
        return nil;
}

-(void)clearSearchResults {
    [fsLocationStrings removeAllObjects];
    [self.tableView reloadData];
}

@end
