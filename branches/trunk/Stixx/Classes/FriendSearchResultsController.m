//
//  FriendSearchResultsController.m
//  Stixx
//
//  Created by Irene Chen on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendSearchResultsController.h"
#import "QuartzCore/QuartzCore.h"
#define TOP_LABEL_TAG 1001
#define BOTTOM_LABEL_TAG 1002
#define ROW_HEIGHT 70

@implementation FriendSearchResultsController

@synthesize userButtons, userPhotos;
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
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    userButtons = [[NSMutableDictionary alloc] init];
    userPhotos = [[NSMutableDictionary alloc] init];
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
    int numRows = [self.delegate getNumOfUsers];
    NSLog(@"FriendSearchResults: numRows %d", numRows);
    return numRows;;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        //cell = [[[StixStoreTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // from http://cocoawithlove.com/2009/04/easy-custom-uitableview-drawing.html
        //
        // Create a background image view.
        //
        cell.backgroundView = [[UIImageView alloc] init];
        cell.selectedBackgroundView = [[UIImageView alloc] init];
        
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
        [cell addSubview:cell.contentView];
        
    }
    
    /*
     else {
     [cell.accessoryView removeFromSuperview];
     [cell.contentView removeFromSuperview];
     }
     */
    
    int y = [indexPath row];
    
    NSLog(@"Cell for row %d", y);
    
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
     // MRC
    
    UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
    UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
    NSString * username = [self.delegate getUsernameForUser: y];
    [topLabel setText:username];
    [bottomLabel setText:[self.delegate getUserEmailForUser: y]];
    
    if ([userPhotos objectForKey:username] == nil) {
        UIImage * photo = [delegate getUserPhotoForUser:y];
        if (!photo)
            photo = [UIImage imageNamed:@"graphic_nopic.png"];
        CGSize newSize = CGSizeMake(ROW_HEIGHT, ROW_HEIGHT);
        UIGraphicsBeginImageContext(newSize);
        [photo drawInRect:CGRectMake(5, 6, ROW_HEIGHT-10, ROW_HEIGHT-10)];	
        
        // add border
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, 2);
        CGContextSetRGBStrokeColor(ctx, 0,0,0, 1.000);
        
        CGRect borderRect = CGRectMake(5, 6, ROW_HEIGHT-10, ROW_HEIGHT-10);
        CGContextStrokeRect(ctx, borderRect);
        
        UIImage* imageView = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();	
        [userPhotos setObject:imageView forKey:username];
    }
    for (UIView * subview in cell.imageView.subviews) {
        [subview removeFromSuperview];
    }
    UIImage * userPhoto = [userPhotos objectForKey:username];
    //cell.imageView = userPhoto; //addSubview:userPhoto];
    [cell.imageView setImage:userPhoto];
    
    if ([userButtons objectForKey:username] == nil) {
        UIButton * addFriendButton = [[UIButton alloc] init]; 
        [addFriendButton setFrame:CGRectMake(0, 0, 70, 70)];
        [addFriendButton setImage:[UIImage imageNamed:@"btn_addstix.png"] forState:UIControlStateNormal];             
        [addFriendButton setTag:y];
        [addFriendButton addTarget:self action:@selector(didAddFriend:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton * alreadyFriendedButton = [[UIButton alloc] init];
        [alreadyFriendedButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        [alreadyFriendedButton setFrame:CGRectMake(0, 0, 70, 70)];
        [alreadyFriendedButton setTag:y];
        [alreadyFriendedButton addTarget:self action:@selector(didRemoveFriend:) forControlEvents:UIControlEventTouchUpInside];

        UIButton * inviteButton = [[UIButton alloc] init]; 
        [inviteButton setFrame:CGRectMake(0, 0, 70, 70)];
        [inviteButton setImage:[UIImage imageNamed:@"graphic_invite.png"] forState:UIControlStateNormal];             
        [inviteButton setTag:y];
        [inviteButton addTarget:self action:@selector(didInviteFriend:) forControlEvents:UIControlEventTouchUpInside];

        NSMutableArray * buttonArray = [[NSMutableArray alloc] initWithObjects:addFriendButton,alreadyFriendedButton, inviteButton, nil];
        [userButtons setObject:buttonArray forKey:username];
    }
    
    NSMutableArray * buttonArray = [userButtons objectForKey:username];
    int userStatus = [delegate getFollowingUserStatus:y];
    if (userStatus == 0) {
        // not following a user that is already on Stix
        cell.accessoryView = [buttonArray objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (userStatus == 1) {
        // already following a user
        cell.accessoryView = [buttonArray objectAtIndex:1];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (userStatus == -1) {
        // user is not a Stix user - invite button
        //NSMutableArray * buttonArray = [userButtons objectForKey:username];
        cell.accessoryView = [buttonArray objectAtIndex:2];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [bottomLabel setText:@"Invite friend to Stix"];
    }
    else if (userStatus == -2) { //self
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([bottomLabel.text length] == 0) {
        [topLabel setFrame:CGRectMake(75, 15, 170, 40)];
    }
    else
        [topLabel setFrame:CGRectMake(75, 5, 170, 40)];

    // Create the label for the top row of text
    //[cell.contentView addSubview:label];
    return cell;
    
}

-(void)didAddFriend:(UIButton*)sender {
    NSLog(@"Clicked add friend button %d!", sender.tag);
    [delegate didClickAddFriendButton:sender.tag];
}
-(void)didRemoveFriend:(UIButton*)sender {
    NSLog(@"Clicked remove friend button %d!", sender.tag);
    [delegate didClickAddFriendButton:sender.tag];
}
-(void)didInviteFriend:(UIButton*)sender {
    NSLog(@"Clicked invite friend button %d!", sender.tag);
    [delegate didClickAddFriendButton:sender.tag];
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
    [delegate didSelectUserProfile:[indexPath row]];
}

@end
