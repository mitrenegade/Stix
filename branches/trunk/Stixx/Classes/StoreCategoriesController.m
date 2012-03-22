//
//  StoreCategoriesController.m
//  Stixx
//
//  Created by Bobby Ren on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StoreCategoriesController.h"

static UIImageView * blankAccessoryView;

@implementation StoreCategoriesController

@synthesize delegate;

#define TOP_LABEL_TAG 1001
#define BOTTOM_LABEL_TAG 1002

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
    stixContentViews = [[NSMutableDictionary alloc] init];
    stixTopLabels = [[NSMutableDictionary alloc] init];
    stixBottomLabels = [[NSMutableDictionary alloc] init];

    // from http://cocoawithlove.com/2009/04/easy-custom-uitableview-drawing.html
    //
    // Change the properties of the imageView and tableView (these could be set
    // in interface builder instead).
    //
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 65;
    self.tableView.backgroundColor = [UIColor clearColor];    
    
    blankAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"120_bank.png"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //[blankAccessoryView release];
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

//-(void)addSubcategory:(NSString *)string {
//    [subcategories addObject:string];
//}

-(void)addSubcategoriesFromArray:(NSMutableArray *)subarray {
    [subcategories addObjectsFromArray:subarray];
}

-(void)updateTableButtons:(NSMutableArray *)stixArray withHasList:(NSMutableArray *)hasStix{
    for (int i=0; i<[stixArray count]; i++) {
        NSString * stixStringID = [stixArray objectAtIndex:i];
        
        UIButton * buttonGetStix = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * buttonImg;
        if ([[hasStix objectAtIndex:i] boolValue] == YES) {
            buttonImg = [UIImage imageNamed:@"check.png"];            
        }
        else
        {
            buttonImg = [UIImage imageNamed:@"btn_addstix.png"];
            [buttonGetStix addTarget:self action:@selector(didClickGetStix:event:) forControlEvents:UIControlEventTouchUpInside];
        }
        CGRect frame = CGRectMake(0.0, 0.0, buttonImg.size.width, buttonImg.size.height);
        [buttonGetStix setFrame:frame];
        [buttonGetStix setBackgroundImage:buttonImg forState:UIControlStateNormal];
        buttonGetStix.backgroundColor = [UIColor clearColor];
        
        //NSLog(@"Changing button for %@ to %@", stixStringID, [[hasStix objectAtIndex:i] boolValue]?@"Check":@"AddStix");
        [stixStringButtons setValue:buttonGetStix forKey:stixStringID];
    }
}

-(void)addStixFromArray:(NSMutableArray *)stixArray withHasList:(NSMutableArray *)hasStix {
    [stixStringIDs addObjectsFromArray:stixArray];
    
    // create button once for each stix
    for (int i=0; i<[stixArray count]; i++) {
        NSString * stixStringID = [stixArray objectAtIndex:i];
        
        UIButton * buttonGetStix = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * buttonImg;
        if ([[hasStix objectAtIndex:i] boolValue] == YES) {
            buttonImg = [UIImage imageNamed:@"check.png"];            
        }
        else
        {
            buttonImg = [UIImage imageNamed:@"btn_addstix.png"];
            [buttonGetStix addTarget:self action:@selector(didClickGetStix:event:) forControlEvents:UIControlEventTouchUpInside];
        }
        CGRect frame = CGRectMake(0.0, 0.0, buttonImg.size.width, buttonImg.size.height);
        [buttonGetStix setFrame:frame];
        [buttonGetStix setBackgroundImage:buttonImg forState:UIControlStateNormal];
        buttonGetStix.backgroundColor = [UIColor clearColor];
        
        [stixStringButtons setValue:buttonGetStix forKey:stixStringID];
        
        UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,60)];
        UILabel * topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        UILabel * bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 200, 20)];
        [contentView setBackgroundColor:[UIColor blackColor]];
        [topLabel setBackgroundColor:[UIColor redColor]];
        [bottomLabel setBackgroundColor:[UIColor blueColor]];
        [contentView addSubview:topLabel];
        [contentView addSubview:bottomLabel];
        [stixContentViews setValue:contentView forKey:stixStringID];
        [stixTopLabels setValue:topLabel forKey:stixStringID];
        [stixBottomLabels setValue:bottomLabel forKey:stixStringID];
        
        [topLabel release]; // MRC
        [bottomLabel release];
        [contentView release];
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
    int total=[stixStringIDs count] + [subcategories count]; 
    if (total < 3) 
        total = 4;
    else if (total > 3) 
        total+=2;
    return total;
}


-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
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
        UIImageView * divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_divider.png"]];
        [cell.contentView addSubview:divider]; 
        UILabel * topLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 5, 170, 40)];
        UILabel * bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 38, 170, 20)];
		topLabel.textColor = [UIColor colorWithRed:102/255.0 green:0.0 blue:0.0 alpha:1.0];
		topLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont labelFontSize]];
		bottomLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		bottomLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont labelFontSize] - 2];
        //NSLog(@"%@", [UIFont fontNamesForFamilyName:@"Helvetica"]);
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [topLabel setBackgroundColor:[UIColor clearColor]];
        [bottomLabel setBackgroundColor:[UIColor clearColor]];
        topLabel.tag = TOP_LABEL_TAG;
        bottomLabel.tag = BOTTOM_LABEL_TAG;
        [cell.contentView addSubview:topLabel];
        [cell.contentView addSubview:bottomLabel];
        /*
		UILabel * bottomLabel =
        [[UILabel alloc]
          initWithFrame:
          CGRectMake(0,10,cell.textLabel.frame.size.width, cell.textLabel.frame.size.height)];
        [bottomLabel setText:@"5 Bux"];
		//[cell.contentView addSubview:bottomLabel];
        [cell addSubview:bottomLabel];
        */
        [cell addSubview:cell.contentView];
        [divider release];
        [topLabel release];
        [bottomLabel release];
        
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
        [bgimage release]; // MRC
        
        [cell.imageView setImage:[UIImage imageNamed:@"120_blank.png"]];
        
        [cell.textLabel setText:[subcategoryName uppercaseString]];
        cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // clear labels if cell was previously used as a Stix cell
        UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
        UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
        [topLabel setText:nil];
        [bottomLabel setText:nil];
        
    }
    else if (y < [subcategories count] + [stixStringIDs count] ) {         
        // CATEGORY_TYPE_STIX
        NSString * stixStringID = [stixStringIDs objectAtIndex:y - [subcategories count]];
        NSString * stixStringDescriptor = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        
        UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
        [stix setFrame:CGRectMake(0,0,50,50)];
        
        UIImageView * bgimage = [[UIImageView alloc] init];
        [bgimage setBackgroundColor:[UIColor blackColor]];
        if (y % 2 == 0)
            [bgimage setAlpha:.3];
        else
            [bgimage setAlpha:.15];
        [cell setBackgroundView:bgimage];
        [bgimage release]; // MRC
        
        UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
        UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
        [topLabel setText:[stixStringDescriptor uppercaseString]];
        [bottomLabel setText:@"5 BUX"];

        [cell.imageView setImage:stix.image];
        cell.accessoryView = [stixStringButtons objectForKey:stixStringID];
		cell.accessoryType = UITableViewCellAccessoryNone;
        
        // clear text if cell was previously used as a subcategory
        [cell.textLabel setText:nil];
        
        [stix release];
    }
    else
    {
        // FILLER
        UIImageView * bgimage = [[UIImageView alloc] init];
        [bgimage setBackgroundColor:[UIColor blackColor]];
        if (y % 2 == 0)
            [bgimage setAlpha:.3];
        else
            [bgimage setAlpha:.15];
        [cell setBackgroundView:bgimage];
        [bgimage release];
        
        [cell.textLabel setText:nil];
        UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
        UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
        [topLabel setText:nil];
        [bottomLabel setText:nil];
        [cell.imageView setImage:[UIImage imageNamed:@"120_blank.png"]];
        cell.accessoryView = blankAccessoryView;      
        cell.accessoryType = UITableViewCellAccessoryNone;
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
//	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    int i = [indexPath row];
    if (i < [subcategories count]) {
        [self.delegate didSelectRow:i]; 
    } 
    else if (i < [subcategories count] + [stixStringIDs count]) {
        //NSString * stixStringID = [stixStringIDs objectAtIndex:i - [subcategories count]];
        //[self.delegate didClickGetStix:stixStringID];
        //UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];   
        NSString * stixStringID = [stixStringIDs objectAtIndex:(i - [subcategories count])];
        NSString * stixStringDescriptor = [[BadgeView getStixDescriptorForStixStringID:stixStringID] uppercaseString];   
        UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
        if ([stixStringDescriptor length] > 15) { // hack: to display full string
            if (cell.accessoryView == nil ) {
                cell.accessoryView = [stixStringButtons objectForKey:stixStringID];   
                CGRect frame = topLabel.frame;
                frame.size.width -= cell.accessoryView.frame.size.width;
                [topLabel setFrame:frame];
                [topLabel setText:stixStringDescriptor];
            } else {
                CGRect frame = topLabel.frame;
                frame.size.width += cell.accessoryView.frame.size.width;
                [topLabel setFrame:frame];
                [topLabel setText:stixStringDescriptor];
                cell.accessoryView = nil;
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    int i = [indexPath row];
    if (i >= [subcategories count] && i < [subcategories count] + [stixStringIDs count]) {
        UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSString * stixStringID = [stixStringIDs objectAtIndex:(i - [subcategories count])];
        NSString * stixStringDescriptor = [[BadgeView getStixDescriptorForStixStringID:stixStringID] uppercaseString];
        if ([stixStringDescriptor length] > 15) {
            if (cell.accessoryView == nil) {
                UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
                cell.accessoryView = [stixStringButtons objectForKey:stixStringID];   
                CGRect frame = topLabel.frame;
                frame.size.width -= cell.accessoryView.frame.size.width;
                [topLabel setFrame:frame];
                [topLabel setText:stixStringDescriptor];
            }
        }
    }
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
        
        UITableView * tableView = (UITableView *) self.tableView;
        UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];  
        CGRect frame = [[cell imageView] frame];
        CGRect cellframe = [cell frame];
        CGRect tableframe = [tableView frame];
        frame.origin.x = frame.origin.x + cellframe.origin.x + tableframe.origin.x;
        frame.origin.y = frame.origin.y + cellframe.origin.y + tableframe.origin.y;
        [self.delegate didClickGetStix:stixStringID withFrame:frame];
    }
}
-(void)didGetStix:(NSString*)stixStringID {
    UIButton * button = [stixStringButtons objectForKey:stixStringID];
    UIImage * buttonImg = [UIImage imageNamed:@"check.png"];
    [button setBackgroundImage:buttonImg forState:UIControlStateNormal];
    [button removeTarget:self action:@selector(didClickGetStix:event:) forControlEvents:UIControlEventAllEvents];        

}

@end
