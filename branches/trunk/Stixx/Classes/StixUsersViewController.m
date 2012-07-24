//
//  StixUsersViewController.m
//  Stixx
//
//  Created by Bobby Ren on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StixUsersViewController.h"

@interface StixUsersViewController ()

@end

@implementation StixUsersViewController

@synthesize buttonBack, buttonAll;
@synthesize logo;
@synthesize tableView;
@synthesize delegate;
@synthesize userButtons, userPhotos;
@synthesize mode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    userButtons = [[NSMutableDictionary alloc] init];
    userPhotos = [[NSMutableDictionary alloc] init];
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

//-(void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self setLogoWithMode:mode];
//}

-(void)setLogoWithMode:(int)_mode {
    // happens before viewWillAppear
    mode = _mode;
    if (mode == PROFILE_SEARCHMODE_FIND) {
        [logo setImage:[UIImage imageNamed:@"txt_findfriends"]];
        [logo setFrame:CGRectMake(108, 12, 105, 25)];
        [buttonAll setImage:[UIImage imageNamed:@"btn_followall"] forState:UIControlStateNormal];
    }
    else if (mode == PROFILE_SEARCHMODE_INVITE) {
        [logo setImage:[UIImage imageNamed:@"txt_invitefriends"]];
        [logo setFrame:CGRectMake(103, 12, 115, 25)];
        [buttonAll setImage:[UIImage imageNamed:@"btn_inviteall"] forState:UIControlStateNormal];
    }
    else if (mode == PROFILE_SEARCHMODE_SEARCHBAR) {
        [logo setImage:[UIImage imageNamed:@"logo"]];
        [logo setFrame:CGRectMake(131, 2, 59, 38)];
        [buttonAll setImage:[UIImage imageNamed:@"btn_followall"] forState:UIControlStateNormal];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numRows = [delegate getNumOfUsers];
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
        UILabel * topLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 170, 35)];
        //UILabel * bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 38, 170, 20)];
		topLabel.textColor = [UIColor colorWithRed:102/255.0 green:0.0 blue:0.0 alpha:1.0];
		topLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont labelFontSize]];
		//bottomLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		//bottomLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont labelFontSize] - 2];
        //NSLog(@"%@", [UIFont fontNamesForFamilyName:@"Helvetica"]);
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [topLabel setBackgroundColor:[UIColor clearColor]];
        //[bottomLabel setBackgroundColor:[UIColor clearColor]];
        topLabel.tag = TOP_LABEL_TAG;
        //bottomLabel.tag = BOTTOM_LABEL_TAG;
        [cell.contentView addSubview:topLabel];
        //[cell.contentView addSubview:bottomLabel];
        [cell addSubview:cell.contentView];
        
    }
    
    int y = [indexPath row];
    
    NSLog(@"Cell for row %d", y);
    
    UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
    //UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
    NSString * username = [delegate getUsernameForUserAtIndex:y];
    [topLabel setText:username];
    //[bottomLabel setText:[delegate getUserEmailForUserAtIndex:y]];
    
    for (UIView * subview in cell.imageView.subviews) {
        [subview removeFromSuperview];
    }
    if ([userPhotos objectForKey:username] == nil) {
        UIImage * photo = [delegate getUserPhotoForUserAtIndex:y];
        if (!photo)
            photo = [UIImage imageNamed:@"graphic_nopic.png"];
        CGSize newSize = CGSizeMake(ROW_HEIGHT, ROW_HEIGHT);
        UIGraphicsBeginImageContext(newSize);
        [photo drawInRect:CGRectMake(3, 4, ROW_HEIGHT-6, ROW_HEIGHT-6)];	
        
        // add border
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, 1);
        CGContextSetRGBStrokeColor(ctx, 0,0,0, 1.000);
        
        CGRect borderRect = CGRectMake(3, 4, ROW_HEIGHT-6, ROW_HEIGHT-6);
        CGContextStrokeRect(ctx, borderRect);
        
        UIImage* imageView = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();	
        [userPhotos setObject:imageView forKey:username];
    }
    UIImage * userPhoto = [userPhotos objectForKey:username];
    //cell.imageView = userPhoto; //addSubview:userPhoto];
    [cell.imageView setImage:userPhoto];
    
    // the button: if user is not on stix, it is an invite button
    // if user is already on stix and you are not following, then it is a follow button
    // if user is being followed, it should not appear (for now, button doesn't appear)
    
    if ([self.userButtons objectForKey:username] == nil) {
        UIButton * addFriendButton = [[UIButton alloc] init]; 
        [addFriendButton setFrame:CGRectMake(-5, 0, 91, 30)];
        [addFriendButton setImage:[UIImage imageNamed:@"btn_follow"] forState:UIControlStateNormal];             
        [addFriendButton setTag:y];
        [addFriendButton addTarget:self action:@selector(didAddFriend:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton * alreadyFriendedButton = [[UIButton alloc] init];
        [alreadyFriendedButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        [alreadyFriendedButton setFrame:CGRectMake(-5, 0, 70, 70)];
        [alreadyFriendedButton setTag:y];
        [alreadyFriendedButton addTarget:self action:@selector(didRemoveFriend:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton * inviteButton = [[UIButton alloc] init]; 
        [inviteButton setFrame:CGRectMake(-5, 0, 89, 28)];
        [inviteButton setImage:[UIImage imageNamed:@"btn_invite"] forState:UIControlStateNormal];             
        [inviteButton setTag:y];
        [inviteButton addTarget:self action:@selector(didInviteFriend:) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableArray * buttonArray = [[NSMutableArray alloc] initWithObjects:addFriendButton,alreadyFriendedButton, inviteButton, nil];
        [self.userButtons setObject:buttonArray forKey:username];
    }
    
    NSMutableArray * buttonArray = [self.userButtons objectForKey:username];
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
        cell.accessoryView = [buttonArray objectAtIndex:2];
        cell.accessoryType = UITableViewCellAccessoryNone;
        //[bottomLabel setText:@"Invite friend to Stix"];
    }
    else if (userStatus == -2) { //self
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    //if ([bottomLabel.text length] == 0) {
    //    [topLabel setFrame:CGRectMake(75, 15, 170, 40)];
    //}
    //else
    //    [topLabel setFrame:CGRectMake(75, 5, 170, 40)];
    
    // Create the label for the top row of text
    //[cell.contentView addSubview:label];
    return cell;
    
}

-(IBAction)didClickBackButton:(id)sender {
    NSLog(@"Clicked BACK Button!");
    [self.view removeFromSuperview];
}

-(IBAction)didClickAllButton:(id)sender {
    NSLog(@"Clicked ALL button!");
    [self.view removeFromSuperview];
    
    if (mode == PROFILE_SEARCHMODE_FIND) {
        
    }
}

-(void)didAddFriend:(UIButton*)sender {
    //NSString * name = [delegate getUsernameForUserAtIndex:sender.tag];
    //NSLog(@"Clicked add friend button %d: adding %@!", sender.tag, name);
    [delegate followUserAtIndex:sender.tag];
}
-(void)didRemoveFriend:(UIButton*)sender {
    //NSLog(@"Clicked remove friend button %d!", sender.tag);
    //NSString * name = [delegate getUsernameForUserAtIndex:sender.tag];
    [delegate unfollowUserAtIndex:sender.tag];
}
-(void)didInviteFriend:(UIButton*)sender {
    //NSLog(@"Clicked invite friend button %d!", sender.tag);
    //NSString * name = [delegate getUsernameForUserAtIndex:sender.tag];
    [delegate inviteUserAtIndex:sender.tag];
}

@end
