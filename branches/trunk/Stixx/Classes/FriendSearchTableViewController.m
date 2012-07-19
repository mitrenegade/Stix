//
//  FriendSearchTableViewController.m
//  Stixx
//
//  Created by Bobby Ren on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendSearchTableViewController.h"

@interface FriendSearchTableViewController ()

@end

@implementation FriendSearchTableViewController
@synthesize delegate;
@synthesize showAccessoryButton;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)startEditing {
    [self.tableView setEditing:YES animated:YES];
}
-(void)stopEditing {
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark - Table view data source

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc] init];
        cell.selectedBackgroundView = [[UIImageView alloc] init];
        
		//cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setHighlightedTextColor:[cell.textLabel textColor]];
        cell.textLabel.numberOfLines = 1;
        UIImageView * divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_divider.png"]];
        CGRect dFrame = divider.frame;
        dFrame.size.width +=50;
        dFrame.origin.x -= 50;
        [divider setFrame:dFrame];
        [cell.contentView addSubview:divider]; 
        UILabel * topLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 170, 40)];
        UILabel * bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 23, 170, 20)];
		topLabel.textColor = [UIColor blackColor]; //[UIColor colorWithRed:102/255.0 green:0.0 blue:0.0 alpha:1.0];
		topLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont labelFontSize]-4];
		bottomLabel.textColor = [UIColor blackColor]; //[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		bottomLabel.font = [UIFont fontWithName:@"Helvetica" size:[UIFont labelFontSize] - 7];
        //NSLog(@"%@", [UIFont fontNamesForFamilyName:@"Helvetica"]);
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [topLabel setBackgroundColor:[UIColor clearColor]];
        [bottomLabel setBackgroundColor:[UIColor clearColor]];
        topLabel.tag = TOP_LABEL_TAG;
        bottomLabel.tag = BOTTOM_LABEL_TAG;
        [cell.contentView addSubview:topLabel];
        [cell.contentView addSubview:bottomLabel];
        [cell addSubview:cell.contentView];
    }
    
    // Configure the cell...
    int section = [indexPath section];
    int index = [indexPath row];
    
    NSString * username;
    if (section == SUGGESTIONS_SECTION_FRIENDS) {
        // Friends
        if (index > [delegate friendsCount])
            [cell.textLabel setText:@"NIL"];
        else {
            username = [delegate getFriendAtIndex:index];
            UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
            UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
            [topLabel setText:username];
            [topLabel setFrame:CGRectMake(55, 5, 170, 35)]; // bottom label doesn't exist; set topLabel in middle of cell
            [bottomLabel setText:@""];
        }
    }
    else if (section == SUGGESTIONS_SECTION_FEATURED) {
        // Featured
        if (index > [delegate featuredCount])
            [cell.textLabel setText:@"NIL"];
        else {
            UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
            UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
            username = [delegate getFeaturedAtIndex:index];
            NSString * desc = [delegate getFeaturedDescriptorAtIndex:index];
            [topLabel setText:username];
            [bottomLabel setText:desc];
            [topLabel setFrame:CGRectMake(55, 5, 170, 25)]; // bottom label exists so set topLabel higher
        }
    }
    
    // photo
    for (UIView * subview in cell.imageView.subviews) {
        [subview removeFromSuperview];
    }
    UIImage * photo = [delegate getUserPhotoForUsername:username];
    CGSize newSize = CGSizeMake(ROW_HEIGHT, ROW_HEIGHT);
    UIGraphicsBeginImageContext(newSize);
    [photo drawInRect:CGRectMake(5, 6, PICTURE_HEIGHT, PICTURE_HEIGHT)];	
    
    // add border
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1);
    CGContextSetRGBStrokeColor(ctx, 0,0,0, 1.000);
    
    CGRect borderRect = CGRectMake(5, 6, PICTURE_HEIGHT, PICTURE_HEIGHT);
    CGContextStrokeRect(ctx, borderRect);
    
    UIImage* userPhoto = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();	
    [cell.imageView setImage:userPhoto];
    
    if (showAccessoryButton) {
        UIImageView * addFriendButton = [[UIImageView alloc] initWithFrame:CGRectMake(-5, 0, 91, 30)];
        [addFriendButton setImage:[UIImage imageNamed:@"btn_follow"]];// forState:UIControlStateNormal];
//        [addFriendButton addTarget:self action:@selector(didClickAddFriend:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = addFriendButton;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // hack: assume that featured header always exists and is at index 0
    //int ret = SUGGESTIONS_SECTION_MAX;
    //if ([friends count] == 0)
    int ret = [delegate numberOfSections]; 
    //        ret = 1;
    NSLog(@"Returning number of sections: %d", ret);
    return ret;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == SUGGESTIONS_SECTION_FRIENDS) {
        NSLog(@"Number of rows for Friends section: %d", [delegate friendsCount] );
        return [delegate friendsCount];
    }
    else if (section == SUGGESTIONS_SECTION_FEATURED) {
        NSLog(@"Number of rows for Featured section: %d", [delegate featuredCount]);
        return [delegate featuredCount];
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section < [delegate numberOfSections])
        return [delegate headerViewForSection:section];
    return nil;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath section];
    int row = [indexPath row];
    NSLog(@"Deleting row at section %d index %d", section, row);
    
    if (section == SUGGESTIONS_SECTION_FRIENDS) {
        [delegate removeFriendAtRow:row];
    }
    else if (section == SUGGESTIONS_SECTION_FEATURED) {
        [delegate removeFeaturedAtRow:row];
    }
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if (section == SUGGESTIONS_SECTION_FRIENDS && [delegate friendsCount] == 0){
        [delegate removeFriendsHeader];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:SUGGESTIONS_SECTION_FRIENDS] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //if ([delegate friendsCount] == 0 && [delegate featuredCount] == 0) {
    //    [self didClickButtonNext:nil];
    //}
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
     */
    
    if (showAccessoryButton) {
        [delegate didSelectFriendSearchIndexPath:indexPath];
    }
}

@end
