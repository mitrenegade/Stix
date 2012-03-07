//
//  FriendSearchResultsController.m
//  Stixx
//
//  Created by Irene Chen on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendSearchResultsController.h"

#define TOP_LABEL_TAG 1001
#define BOTTOM_LABEL_TAG 1002

@implementation FriendSearchResultsController

@synthesize userPhotos, usernames, userEmails, userButtons;
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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.delegate getNumOfUsers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
    // CATEGORY_TYPE_STIX
    
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
    NSString * username = [self.delegate getUsernameForUser: y];
    [topLabel setText:username];
    [bottomLabel setText:[self.delegate getUserEmailForUser: y]];
    
    [cell.imageView setImage:[self.delegate getUserPhotoForUser: y]];
    
    if ([userButtons objectForKey:username] == nil) {
        UIButton * addFriendButton = [[UIButton alloc] init]; 
        [addFriendButton setImage:[UIImage imageNamed:@"btn_addstix.png"] forState:normal];             
        UIButton * alreadyFriendedButton = [[UIButton alloc] init];
        [alreadyFriendedButton setImage:[UIImage imageNamed:@"check.png"] forState:normal];
        NSMutableArray * buttonArray = [[NSMutableArray alloc] initWithObjects:addFriendButton,alreadyFriendedButton, nil];
        [userButtons setObject:buttonArray forKey:username];
    }
    
    if ([self.delegate isFriendOfUser: y]) {
        NSMutableArray * buttonArray = [userButtons objectForKey:username];
        cell.accessoryView = [buttonArray objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {  
        NSMutableArray * buttonArray = [userButtons objectForKey:username];
        cell.accessoryView = [buttonArray objectAtIndex:1];
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
}

@end