//
//  StoreCategoriesController.m
//  Stixx
//
//  Created by Bobby Ren on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StoreCategoriesController.h"

@implementation StoreCategoriesController

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
        
    subcategories = [[NSMutableArray alloc] init];
    stixStringIDs = [[NSMutableArray alloc] init];
    stixStringButtons = [[NSMutableDictionary alloc] init];

    // from http://cocoawithlove.com/2009/04/easy-custom-uitableview-drawing.html
    //
    // Change the properties of the imageView and tableView (these could be set
    // in interface builder instead).
    //
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 65;
    self.tableView.backgroundColor = [UIColor clearColor];    
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

-(void)addSubcategory:(NSString *)string {
    [subcategories addObject:string];
}
-(void)addSubcategoriesFromArray:(NSMutableArray *)subarray {
    [subcategories addObjectsFromArray:subarray];
}
-(void)addStix:(NSString *)stixID {
    [stixStringIDs addObject:stixID];
    UIImage * buttonImg = [[UIImage imageNamed:@"btn_addstix.png"] autorelease];
    UIButton * buttonGetStix = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, buttonImg.size.width, buttonImg.size.height);
    [buttonGetStix setFrame:frame];
    [buttonGetStix setBackgroundImage:buttonImg forState:UIControlStateNormal];
    buttonGetStix.backgroundColor = [UIColor clearColor];
    [buttonGetStix addTarget:self action:@selector(didClickGetStix:event:) forControlEvents:UIControlEventTouchUpInside];
    
    [stixStringButtons setValue:buttonGetStix forKey:stixID];
}
-(void)addStixFromArray:(NSMutableArray *)stixArray {
    [stixStringIDs addObjectsFromArray:stixArray];
    
    // create button once for each stix
    for (int i=0; i<[stixArray count]; i++) {
        NSString * stixStringID = [stixArray objectAtIndex:i];
        
        UIImage * buttonImg = [[UIImage imageNamed:@"btn_addstix.png"] autorelease];
        UIButton * buttonGetStix = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, buttonImg.size.width, buttonImg.size.height);
        [buttonGetStix setFrame:frame];
        [buttonGetStix setBackgroundImage:buttonImg forState:UIControlStateNormal];
        buttonGetStix.backgroundColor = [UIColor clearColor];
        [buttonGetStix addTarget:self action:@selector(didClickGetStix:event:) forControlEvents:UIControlEventTouchUpInside];
        
        [stixStringButtons setValue:buttonGetStix forKey:stixStringID];
    }
}
-(int)getTypeForRow:(int)row {
    if (row < [subcategories count]) {
        return CATEGORY_TYPE_SUBCATEGORY;
    }
    else if (row - [subcategories count] < [stixStringIDs count]) {
        return CATEGORY_TYPE_STIX;
    }
    return -1;
}
-(NSString *) getStringForRow:(int)row {
    if (row < [subcategories count]) {
        return [subcategories objectAtIndex:row];
    }
    else if (row - [subcategories count] < [stixStringIDs count]) {
        return [stixStringIDs objectAtIndex:(row - [subcategories count])];
    }
    return nil;
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
    return [stixStringIDs count] + [subcategories count];
}


-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void)didClickGetStix:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	if (indexPath != nil)
	{
        //[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
        int stixIndex = [indexPath row] - [subcategories count];
        NSString * stixStringID = [stixStringIDs objectAtIndex:stixIndex];
        [self.delegate didClickGetStix:stixStringID];
	}
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

		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        UIImageView * divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_divider.png"]];
        [cell.contentView addSubview:divider];
        [cell addSubview:cell.contentView];
        [divider release];
    }
    /*
    else {
        [cell.accessoryView removeFromSuperview];
        [cell.contentView removeFromSuperview];
    }
     */
    
    int y = [indexPath row];

    //UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(80,0,180,60)];
    //label.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
    //label.highlightedTextColor = label.textColor;//[UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
    //[label setBackgroundColor:[UIColor clearColor]];
    if (y < [subcategories count]) {  
        // CATEGORY_TYPE_SUBCATEGORY 
        NSString * subcategoryName = [subcategories objectAtIndex:y];
        //[label setText:subcategoryName];
		//label.font = [UIFont systemFontOfSize:15];
        
        //UIImageView * categoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"120_fire.png"]];
        UIImageView * bgimage = [[UIImageView alloc] init];
        [bgimage setBackgroundColor:[UIColor blackColor]];
        if (y % 2 == 0)
            [bgimage setAlpha:.3];
        else
            [bgimage setAlpha:.15];
        [cell setBackgroundView:bgimage];

        [cell.imageView setImage:[UIImage imageNamed:@"120_fire.png"]];
        [cell.imageView setAlpha:.5];

        [cell.textLabel setText:subcategoryName];
        cell.accessoryView = nil;
}
    else {         
        // CATEGORY_TYPE_STIX
        NSString * stixStringID = [stixStringIDs objectAtIndex:y - [subcategories count]];
        NSString * stixStringDescriptor = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        
        UIImageView * stix = [BadgeView getBadgeWithStixStringID:stixStringID];
        [stix setFrame:CGRectMake(0,0,50,50)];
        
        UIImageView * bgimage = [[UIImageView alloc] init];
        [bgimage setBackgroundColor:[UIColor blackColor]];
        if (y % 2 == 0)
            [bgimage setAlpha:.3];
        else
            [bgimage setAlpha:.15];
        [cell setBackgroundView:bgimage];
        
        //[label setText:stixStringDescriptor];
		//label.font = [UIFont systemFontOfSize:12];
        [cell.textLabel setText:stixStringDescriptor];

        //cell.image = stix.image;
        [cell.imageView setImage:stix.image];
        [cell.imageView setAlpha:.5];
        //if (!cell.imageView)
        //   NSLog(@"cell.imageview dne!");
        cell.accessoryView = [stixStringButtons objectForKey:stixStringID];
        
    }
    // Create the label for the top row of text
    //[cell.contentView addSubview:label];
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
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    int i = [indexPath row];
    if (i < [subcategories count]) {
        [self.delegate didSelectRow:i]; 
    } 
    else {
        //NSString * stixStringID = [stixStringIDs objectAtIndex:i - [subcategories count]];
        //[self.delegate didClickGetStix:stixStringID];
    }
}

@end
