//
//  GiftStixTableController.m
//  Stixx
//
//  Created by Bobby Ren on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GiftStixTableController.h"

@implementation GiftStixTableController

@synthesize delegate;

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
    
    int total = [BadgeView totalStixTypes]-2;
    allGiftStixCounts = [[NSMutableArray alloc] initWithCapacity:total];
    allStixStringIDs = [[NSMutableArray alloc] initWithCapacity:total];
    for (int stixType=0; stixType<[BadgeView totalStixTypes]; stixType++)
    {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:stixType];
        int count = 0; //[self.delegate getStixCount:stixStringID];
        if ([stixStringID isEqualToString:@"FIRE"] || [stixStringID isEqualToString:@"ICE"])
        {
            count = -1;
        }
        [allGiftStixCounts addObject:[NSNumber numberWithInt:count]];
        [allStixStringIDs addObject:stixStringID];
        
        //NSLog(@"GiftStix: allStixStringIDs %d = %@ count %d\n", stixType, stixStringID, count);
    }
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

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
    // update stix counts each time
}

-(void)reloadStixCounts {
    for (int stixType=0; stixType < [BadgeView totalStixTypes]; stixType++)
    {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:stixType];
        if ([stixStringID isEqualToString:@"FIRE"] || [stixStringID isEqualToString:@"ICE"]) 
        {
            continue;
        }
        int count = [self.delegate getStixCount:stixStringID];
        [allGiftStixCounts replaceObjectAtIndex:stixType withObject:[NSNumber numberWithInt:count]];
        //NSLog(@"GiftStix: allStixStringIDs %d = %@ count %d\n", stixType, stixStringID, count);
    }
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
    int triplets = ([allGiftStixCounts count] / 3) + 1; // number of groups of 3
    return triplets;
}


-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 115;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    GiftStixTableCell *cell = (GiftStixTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GiftStixTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    for (int x=0; x<3; x++) {
        [cell removeCellItemAtPosition:x];
    }
    
    // Configure the cell...
    
    //int count = [[allStix objectAtIndex:type-2] intValue];//[self.delegate getStixCount:type];
    //NSString * stixDesc = [stixDescriptors objectAtIndex:type];
    //NSString * cellLabel = [NSString stringWithFormat:@"%@: %d", stixDesc, count];
    //[[cell textLabel] setText:cellLabel];
   
    int x = 0;
    int y = [indexPath row];
    for (int stixType = y*3; stixType < y*3+3; stixType++) {
        if (stixType >= [allStixStringIDs count])
            continue;        
        
        NSString * stixStringID = [allStixStringIDs objectAtIndex:stixType];

        //if ([stixStringID isEqualToString:@"FIRE"] || [stixStringID isEqualToString:@"ICE"])
        //    continue;
        
        UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
                 
        int count = [[allGiftStixCounts objectAtIndex:stixType] intValue];
        [cell addCellItem:stix atPosition:x];
        if (count != -1)
            [cell addCellLabel:[NSString stringWithFormat:@"%d", count] atPosition:x];
        [stix release];
        NSLog(@"Row %d position %d type %d %@ count %d\n", y, x, stixType, stixStringID, count);
        x++;
    }    
    
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

@end
