//
//  CommentFeedTableController.m
//  Stixx
//
//  Created by Bobby Ren on 12/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentFeedTableController.h"
#import <QuartzCore/QuartzCore.h>

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
    //NSLog(@"row height for comment index %d: %d", [indexPath row], rowHeight);
    return [self.delegate getRowHeightForRow:[indexPath row]];
}

-(float)getHeightForComment:(NSString*)comment forStixStringID:(NSString*)stixStringID {
    // determine the size of the frame that includes multiline comments, taking into account the user name and the timestamp
    NSString * simpleComment = [self simpleCommentString:comment andStixType:stixStringID];
    CGSize commentSize = [simpleComment sizeWithFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:14] constrainedToSize:CGSizeMake(230, 14*4) lineBreakMode:UILineBreakModeWordWrap];
    CGSize minSize = CGSizeMake(230, 24 + commentSize.height + 4 + 12 + 2);
    float minHeight = minSize.height;
    return MAX(minHeight, rowHeight);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 2;
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:fontSize]];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (showDivider)
            [cell addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_divider"]]];
        [cell.textLabel setTextColor:fontTextColor];
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 230, 12)];
        UILabel * commentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 24, 230, 14)];
        UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 42, 230, 12)];
        nameLabel.textColor = fontNameColor;
		nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
		commentTextLabel.textColor = fontTextColor;
		commentTextLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:14];
        [commentTextLabel setNumberOfLines:3];
		timeLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		timeLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [commentTextLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        
        UIButton * photoView = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
		[photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photoView.layer setBorderWidth: 2.0];
        [photoView addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        nameLabel.tag = LEFT_LABEL_TAG;
        commentTextLabel.tag = RIGHT_LABEL_TAG;
        timeLabel.tag = TIME_LABEL_TAG;
        photoView.tag = PHOTO_TAG; // + [indexPath row];
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:commentTextLabel];
        [cell.contentView addSubview:timeLabel];
        [cell.contentView addSubview:photoView];
        [cell addSubview:cell.contentView];
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
        NSString * name = [delegate getNameForIndex:index];
        NSString * comment = [delegate getCommentForIndex:index];
        NSString * stixStringID = [delegate getStixStringIDForIndex:index];
        NSString * timeStampString = [delegate getTimestampStringForIndex:index];
        UIImage * photo = [delegate getPhotoForIndex:index];
        //NSString * commentLabel = [self commentStringFor:name andComment:comment andStixType:stixStringID];
        // to set one line of text:
        // [cell.textLabel setText:commentLabel];
        // to set multiple lines or different fonts/colors
        UILabel * nameLabel = (UILabel *)[cell viewWithTag:LEFT_LABEL_TAG];
        UILabel * commentTextLabel = (UILabel *)[cell viewWithTag:RIGHT_LABEL_TAG];
        UILabel * timeLabel = (UILabel*)[cell viewWithTag:TIME_LABEL_TAG];
        NSString * simpleComment = [self simpleCommentString:comment andStixType:stixStringID];
        CGSize commentSize = [simpleComment sizeWithFont:[commentTextLabel font] constrainedToSize:CGSizeMake(commentTextLabel.frame.size.width, commentTextLabel.frame.size.height*4) lineBreakMode:UILineBreakModeWordWrap];
        //float commentHeight = [self getHeightForComment:comment forStixStringID:stixStringID];
        [commentTextLabel setFrame:CGRectMake(commentTextLabel.frame.origin.x, commentTextLabel.frame.origin.y, 230, commentSize.height)];
        [timeLabel setFrame:CGRectMake(timeLabel.frame.origin.x, commentTextLabel.frame.origin.y + commentTextLabel.frame.size.height + 4, timeLabel.frame.size.width, timeLabel.frame.size.height)];
        //NSLog(@"adding comment: %@", simpleComment);
        [nameLabel setText:name];
        [commentTextLabel setText:simpleComment];
        [timeLabel setText:timeStampString];
        
        //float minHeight = [self getHeightForComment:comment forStixStringID:stixStringID];//timeLabel.frame.origin.y + timeLabel.frame.size.height + 2;
        //NSLog(@"Row %d needs to be at least this big: %f", [indexPath row], minHeight);

        UIButton * photoView = (UIButton*)[cell viewWithTag:PHOTO_TAG]; // + index];
        [photoView setImage:photo forState:UIControlStateNormal];
        photoView.titleLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
        photoView.titleLabel.hidden = YES;
        //[photoView setTag:index];
         // MRC
        
        if (![stixStringID isEqualToString:@"COMMENT"] && ![stixStringID isEqualToString:@"PEEL"] && ![stixStringID isEqualToString:@"SHARE"] && ![stixStringID isEqualToString:@"LIKE"] && ![stixStringID isEqualToString:@"REMIX"]) {
            UIImageView * stix = [BadgeView getBadgeWithStixStringID:stixStringID];
            [stix setFrame:CGRectMake(10,10,40,40)];
            cell.accessoryView = stix;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        //else if ([stixStringID isEqualToString:@"LIKE_SMILES"] || [stixStringID isEqualToString:@"LIKE_LOVE"] || [stixStringID isEqualToString:@"LIKE_WINK"] || [stixStringID isEqualToString:@"LIKE_SHOCKED"]) {
        else if ([stixStringID isEqualToString:@"LIKE"]) {
            UIImageView * stix = [[UIImageView alloc] init];
            if ([comment isEqualToString:@"LIKE_SMILES"]) 
                [stix setImage:[UIImage imageNamed:@"icon_pix_smiles@2x.png"]];
            if ([comment isEqualToString:@"LIKE_LOVE"]) 
                [stix setImage:[UIImage imageNamed:@"icon_pix_love@2x.png"]];
            if ([comment isEqualToString:@"LIKE_WINK"]) 
                [stix setImage:[UIImage imageNamed:@"icon_pix_wink@2x.png"]];
            if ([comment
                 isEqualToString:@"LIKE_SHOCKED"]) 
                [stix setImage:[UIImage imageNamed:@"icon_pix_shocked@2x.png"]];
            [stix setFrame:CGRectMake(10,10,40,40)];
            cell.accessoryView = stix;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
            cell.accessoryView = nil;
    }
    return cell;
}

-(void)didClickUserPhoto:(UIButton*)button {
    //NSLog(@"Button titleLabel: %@", button.titleLabel.text);
    int row = [button.titleLabel.text intValue]; //[indexPath row]; //button.tag - PHOTO_TAG;
    NSString * name = [delegate getNameForIndex:row];
    NSLog(@"CommentFeedTable: did click on user's photo %d, username = %@", row, name);
    [delegate shouldDisplayUserPage:name];
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
}

-(NSString*)simpleCommentString:(NSString *)comment andStixType:(NSString*)stixStringID {
    
    NSString * str = @"";
    // stixStringID is a type of Stix - deprecated
    if ([comment length] == 0) // add generic descriptor
    {
        NSString * desc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        str = [NSString stringWithFormat:@"Added %@", desc];
    }
    else if ([comment isEqualToString:@"PEEL"]) {
        NSString * desc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
        str = [NSString stringWithFormat:@"Peeled off %@", desc];
    }
    else if ([comment isEqualToString:@"SHARE"]) {
        str = [NSString stringWithFormat:@"Shared this Pix at %@", comment];
    }
    // stixStringID == LIKE
    else if ([comment isEqualToString:@"LIKE_SMILES"]) 
        str = [NSString stringWithFormat:@"Smiled at this Pix"];
    else if ([comment isEqualToString:@"LIKE_LOVE"]) 
        str = [NSString stringWithFormat:@"Loves this Pix"];
    else if ([comment isEqualToString:@"LIKE_WINK"]) 
        str = [NSString stringWithFormat:@"Winked at this Pix"];
    else if ([comment isEqualToString:@"LIKE_SHOCKED"]) 
        str = [NSString stringWithFormat:@"Is shocked by this Pix"];
    else if ([stixStringID isEqualToString:@"REMIX"]) {
        str = comment;
    }
    else // if ([comment isEqualToString:@"COMMENT"]) {
    {
        /* get first char */
        NSString *firstChar = [comment substringToIndex:1];
        str = [[firstChar uppercaseString] stringByAppendingString:[comment substringFromIndex:1]];
        // str = [NSString stringWithFormat:@"%@", comment];
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
