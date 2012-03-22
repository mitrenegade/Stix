//
//  CommentFeedTableController.m
//  Stixx
//
//  Created by Bobby Ren on 12/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentFeedTableController.h"
#import <QuartzCore/QuartzCore.h>
#define LEFT_LABEL_TAG 1001
#define RIGHT_LABEL_TAG 1002
#define TIME_LABEL_TAG 1003
#define PHOTO_TAG 1004

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
    rowHeight = 60;
    showDivider = YES;
    fontSize = 12;
    [self setFontNameColor:[UIColor colorWithRed:153/255.0 green:51.0/255.0 blue:0.0 alpha:1.0]];
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
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 250, 12)];
        UILabel * commentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 24, 250, 14)];
        UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 42, 250, 12)];
        UIImageView * photoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
		nameLabel.textColor = fontNameColor;
		nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
		commentTextLabel.textColor = fontTextColor;
		commentTextLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:14];
		timeLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		timeLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [commentTextLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photoView.layer setBorderWidth: 2.0];
        nameLabel.tag = LEFT_LABEL_TAG;
        commentTextLabel.tag = RIGHT_LABEL_TAG;
        timeLabel.tag = TIME_LABEL_TAG;
        photoView.tag = PHOTO_TAG;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:commentTextLabel];
        [cell.contentView addSubview:timeLabel];
        [cell.contentView addSubview:photoView];
        [cell addSubview:cell.contentView];
        [nameLabel release];
        [commentTextLabel release];
        [timeLabel release];
        [photoView release];
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
        NSString * timeStampString = [self.delegate getTimestampStringForIndex:index];
        UIImage * photo = [self.delegate getPhotoForIndex:index];
        //NSString * commentLabel = [self commentStringFor:name andComment:comment andStixType:stixStringID];
        // to set one line of text:
        // [cell.textLabel setText:commentLabel];
        // to set multiple lines or different fonts/colors
        UILabel * nameLabel = (UILabel *)[cell viewWithTag:LEFT_LABEL_TAG];
        UILabel * commentTextLabel = (UILabel *)[cell viewWithTag:RIGHT_LABEL_TAG];
        UILabel * timeLabel = (UILabel*)[cell viewWithTag:TIME_LABEL_TAG];
        NSString * simpleComment = [self simpleCommentString:comment andStixType:stixStringID];
        //NSLog(@"adding comment: %@", simpleComment);
        [nameLabel setText:name];
        [commentTextLabel setText:simpleComment];
        [timeLabel setText:timeStampString];

        UIImageView * photoView = (UIImageView*)[cell viewWithTag:PHOTO_TAG];
        [photoView setImage:photo];
        
        if (![stixStringID isEqualToString:@"COMMENT"] && ![stixStringID isEqualToString:@"PEEL"] && ![stixStringID isEqualToString:@"SHARE"]) {
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            [stix setFrame:CGRectMake(10,10,40,40)];
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
        //str = [NSString stringWithFormat:@"%@ said, \"%@\"", name, comment];
        str = [NSString stringWithFormat:@"%@", comment];
    }
    return str;
}

-(NSString*)simpleCommentString:(NSString *)comment andStixType:(NSString*)stixStringID {
    
    NSString * str = @"";
    if ([comment length] == 0) // add generic descriptor
    {
        NSString * desc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        str = [NSString stringWithFormat:@"added a %@", desc];
    }
    else if ([comment isEqualToString:@"PEEL"]) {
        NSString * desc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        str = [NSString stringWithFormat:@"peeled off a %@ to add to their collection", desc];
    }
    else if ([comment isEqualToString:@"SHARE"]) {
        str = [NSString stringWithFormat:@"shared this Pix at %@", comment];
    }
    else
    {
        //str = [NSString stringWithFormat:@"%@ said, \"%@\"", name, comment];
        str = [NSString stringWithFormat:@"%@", comment];
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
