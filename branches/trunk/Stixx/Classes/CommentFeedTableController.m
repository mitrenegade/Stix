//
//  CommentFeedTableController.m
//  Stixx
//
//  Created by Bobby Ren on 12/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentFeedTableController.h"
#define LEFT_LABEL_TAG 1001
#define RIGHT_LABEL_TAG 1002

@implementation CommentFeedTableController

@synthesize delegate;
@synthesize rowHeight;
@synthesize fontTextColor, fontNameColor;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
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

    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //cellDictionary = [[NSMutableDictionary alloc] init];
    rowHeight = 70;
    showDivider = YES;
    fontSize = 12;
    fontNameColor = [UIColor blackColor];
    fontTextColor = [UIColor blackColor];
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
    return [self.delegate getCount];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.numberOfLines = 2;
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:fontSize]];
        [cell setBackgroundColor:[UIColor clearColor]];
        if (showDivider)
            [cell addSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_divider.png"]] autorelease]];
        [cell.textLabel setTextColor:fontTextColor];
        UILabel * leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 30, rowHeight)];
        UILabel * rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 170, rowHeight)];
		leftLabel.textColor = fontNameColor; //[UIColor colorWithRed:102/255.0 green:0.0 blue:0.0 alpha:1.0];
		leftLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont labelFontSize]];
		rightLabel.textColor = fontTextColor; //[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        //NSArray * fonts = [UIFont fontNamesForFamilyName:@"Helvetica"];
        //for (int i=0; i<[fonts count]; i++){ 
        //    NSLog(@"Font %d = %@", i, [fonts objectAtIndex:i]);
        //}
		rightLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:[UIFont labelFontSize] - 2];
        [leftLabel setBackgroundColor:[UIColor clearColor]];
        [rightLabel setBackgroundColor:[UIColor clearColor]];
        leftLabel.tag = LEFT_LABEL_TAG;
        rightLabel.tag = RIGHT_LABEL_TAG;
        [cell.contentView addSubview:leftLabel];
        [cell.contentView addSubview:rightLabel];
        [cell addSubview:cell.contentView];
        [leftLabel release];
        [rightLabel release];
    }
    
    // Configure the cell...
    int index = [indexPath row];
    /*
    UIView * cellOldView = [cellDictionary objectForKey:[NSNumber numberWithInt:cell.hash]];
    if (cellOldView != nil)
        [cellOldView removeFromSuperview];
    
    UIView * view;
    [cell.contentView addSubview:view];
    [cellDictionary setObject:view forKey:[NSNumber numberWithInt:cell.hash]];
    */
    
    if (index < [self.delegate getCount])
    {
        NSString * name = [self.delegate getNameForIndex:index];
        NSString * comment = [self.delegate getCommentForIndex:index];
        NSString * stixStringID = [self.delegate getStixStringIDForIndex:index];
        NSString * commentLabel = [self commentStringFor:name andComment:comment andStixType:stixStringID];
        // to set one line of text:
        // [cell.textLabel setText:commentLabel];
        // to set multiple lines or different fonts/colors
        UILabel * leftLabel = (UILabel *)[cell viewWithTag:LEFT_LABEL_TAG];
        UILabel * rightLabel = (UILabel *)[cell viewWithTag:RIGHT_LABEL_TAG];
        CGRect frame = leftLabel.frame;
        frame.size.width = [name length] * fontSize;
        [leftLabel setFrame:frame];
        [leftLabel setText:name];
        frame = rightLabel.frame;
        frame.size.width = [comment length] * fontSize;
        frame.origin.x = leftLabel.frame.origin.x + leftLabel.frame.size.width;
        [rightLabel setFrame:frame];
        [rightLabel setText:comment];

        if (![stixStringID isEqualToString:@"COMMENT"] && ![stixStringID isEqualToString:@"PEEL"] && ![stixStringID isEqualToString:@"SHARE"]) {
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            [stix setFrame:CGRectMake(0,0,60,60)];
            cell.accessoryView = stix;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
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
    
-(NSString*)commentStringFor:(NSString *)name andComment:(NSString *)comment andStixType:(NSString*)stixStringID {

    NSString * str = @"";
    if ([comment length] == 0) // add generic descriptor
    {
        NSString * desc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        str = [NSString stringWithFormat:@"%@ added a %@", name, desc];
    }
    else if ([comment isEqualToString:@"PEEL"]) {
        NSString * desc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        str = [NSString stringWithFormat:@"%@ peeled off a %@ to add to their collection", name, desc];
    }
    else if ([comment isEqualToString:@"SHARE"]) {
        str = [NSString stringWithFormat:@"%@ shared this Pix at %@", name, comment];
    }
    else
    {
        str = [NSString stringWithFormat:@"%@ said, \"%@\"", name, comment];
    }
    return str;
}

-(void)configureRowsWithHeight:(int)height dividerVisible:(BOOL)visible fontSize:(int)size fontNameColor:(UIColor*)nameColor fontTextColor:(UIColor*)textColor  {
    rowHeight = height;
    showDivider = visible;
    fontSize = size;
    [self setFontNameColor:nameColor];
    [self setFontTextColor:textColor];
    //[self.tableView reloadData];
}

@end
