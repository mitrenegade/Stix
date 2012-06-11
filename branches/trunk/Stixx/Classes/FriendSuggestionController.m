//
//  FriendSuggestionController.m
//  Stixx
//
//  Created by Bobby Ren on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendSuggestionController.h"

#define TOP_LABEL_TAG 1001
#define BOTTOM_LABEL_TAG 1002
#define ROW_HEIGHT 45
#define PICTURE_HEIGHT 33

@implementation FriendSuggestionController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        k = [[Kumulos alloc] init];
        [k setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#if USING_FLURRY
    [FlurryAnalytics logPageView];
#endif
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

-(void)initializeHeaderViews {
    if (!headerViews)
        headerViews = [[NSMutableArray alloc] init];
    UIImageView * friendHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    [friendHeader setImage:[UIImage imageNamed:@"header_friendsonstix@2x.png"]];
    UIImageView * featuredHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    [featuredHeader setImage:[UIImage imageNamed:@"header_featuredstixsters@2x.png"]];
    [headerViews addObject:featuredHeader];
    [headerViews addObject:friendHeader];
}

-(void)initializeSuggestions {
    friends = [[NSMutableArray alloc] init];
    featured = [[NSMutableArray alloc] init];
    featuredDesc = [[NSMutableArray alloc] init];
    userPhotos = [[NSMutableDictionary alloc] init];

    didGetFeaturedUsers = NO;
    didGetFacebookFriends = NO;
    [k getFeaturedUsers];
    [delegate searchFriendsByFacebook];
        
    [self initializeHeaderViews];
    isEditing = NO;
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
#if 0
    UIImageView * bgimage = [[UIImageView alloc] init];
    [bgimage setBackgroundColor:[UIColor blackColor]];
    if (index % 2 == 0)
        [bgimage setAlpha:.3];
    else
        [bgimage setAlpha:.15];
    [cell setBackgroundView:bgimage];
#endif
    
    NSString * username;
    if (section == SUGGESTIONS_SECTION_FRIENDS) {
        // Friends
        if (index > [friends count])
            [cell.textLabel setText:@"NIL"];
        else {
            username = [friends objectAtIndex:index];
            UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
            UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
            [topLabel setText:[friends objectAtIndex:index]];
            [topLabel setFrame:CGRectMake(55, 5, 170, 35)]; // bottom label doesn't exist; set topLabel in middle of cell
            [bottomLabel setText:@""];
        }
    }
    else if (section == SUGGESTIONS_SECTION_FEATURED) {
        // Featured
        if (index > [featured count])
            [cell.textLabel setText:@"NIL"];
        else {
            UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
            UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
            username = [featured objectAtIndex: index];
            NSString * desc = [featuredDesc objectAtIndex:index];
            [topLabel setText:username];
            [bottomLabel setText:desc];
            [topLabel setFrame:CGRectMake(55, 5, 170, 25)]; // bottom label exists so set topLabel higher
        }
    }
    
    // photo
    if ([userPhotos objectForKey:username] == nil) {
        UIImage * photo = [delegate getUserPhotoForUsername:username];
        if (!photo)
            photo = [UIImage imageNamed:@"graphic_nopic.png"];
        CGSize newSize = CGSizeMake(ROW_HEIGHT, ROW_HEIGHT);
        UIGraphicsBeginImageContext(newSize);
        [photo drawInRect:CGRectMake(5, 6, PICTURE_HEIGHT, PICTURE_HEIGHT)];	
        
        // add border
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, 1);
        CGContextSetRGBStrokeColor(ctx, 0,0,0, 1.000);
        
        CGRect borderRect = CGRectMake(5, 6, PICTURE_HEIGHT, PICTURE_HEIGHT);
        CGContextStrokeRect(ctx, borderRect);
        
        UIImage* imageView = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();	
        [userPhotos setObject:imageView forKey:username];
    }
    for (UIView * subview in cell.imageView.subviews) {
        [subview removeFromSuperview];
    }
    UIImage * userPhoto = [userPhotos objectForKey:username];
    [cell.imageView setImage:userPhoto];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return SUGGESTIONS_SECTION_MAX;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == SUGGESTIONS_SECTION_FRIENDS) {
        NSLog(@"Number of rows for Friends section: %d", [friends count]);
        return [friends count];
    }
    else if (section == SUGGESTIONS_SECTION_FEATURED) {
        NSLog(@"Number of rows for Featured section: %d", [featured count]);
        return [featured count];
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section < [headerViews count])
        return [headerViews objectAtIndex:section];
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

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath section];
    int row = [indexPath row];
    NSLog(@"Deleting row at section %d index %d", section, row);
    
    if (section == SUGGESTIONS_SECTION_FRIENDS) {
        [friends removeObjectAtIndex:row];
    }
    else if (section == SUGGESTIONS_SECTION_FEATURED) {
        [featured removeObjectAtIndex:row];
        [featuredDesc removeObjectAtIndex:row];
    }
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [tableView reloadData];
}

-(void)populateFacebookSearchResults:(NSArray*)facebookFriendArray {
//    [self initSearchResultLists];
        
    [friends removeAllObjects];
    //[friendsIDs removeAllObjects];
    NSMutableSet * alreadyFollowing = [delegate getFollowingList];
    
    NSMutableArray * allFacebookIDs = [delegate getAllUserFacebookIDs];
    for (NSMutableDictionary * d in facebookFriendArray) {
        NSString * fbID = [d valueForKey:@"id"];
        NSString * fbName = [d valueForKey:@"name"];
        //NSLog(@"fbID: %@ fbName: %@", fbID, fbName);
        if ([alreadyFollowing containsObject:fbName])
            continue; // skip those already following
        if ([fbName isEqualToString:[delegate getUsername]])
            continue; // skip self
        if ([allFacebookIDs containsObject:fbID]) {
            [friends addObject:fbName];
            //[friendsIDs addObject:fbID];
        }
    }
    
    NSLog(@"Loaded %d Facebook friends already on Stix, %d featured", [friends count], [featured count]);
    // todo: filter out existing friends, if any
    
    //[tableView reloadData];
    int total = [featured count] + [friends count];
    didGetFacebookFriends = YES;
    if (didGetFeaturedUsers)
        [delegate friendSuggestionControllerFinishedLoading:total];
    else 
        NSLog(@"***FriendSuggestionController: facebook friends loaded first!");
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFeaturedUsersDidCompleteWithResult:(NSArray *)theResults {
    
    if ([theResults count] == 0)
        return;
    
    [featured removeAllObjects];

    NSMutableSet * alreadyFollowing = [delegate getFollowingList];
    
    for (NSMutableDictionary * d in theResults) {
        NSString * username = [d objectForKey:@"username"];
        if ([alreadyFollowing containsObject:username])
            continue;
        if ([username isEqualToString:[delegate getUsername]])
            continue;
        [featured addObject:username];
        NSString * desc = [d objectForKey:@"description"];
        [featuredDesc addObject:desc];
    }
    
    NSLog(@"Loaded %d Featured friends", [featured count]);
    
    //[tableView reloadData];
    didGetFeaturedUsers = YES;
    int total = [featured count] + [friends count];
    if (didGetFacebookFriends)
        [delegate friendSuggestionControllerFinishedLoading:total];
    else 
        NSLog(@"***FriendSuggestionController: featured users loaded first!");
}

-(IBAction)didClickButtonEdit:(id)sender {
    if (!isEditing) {
        [tableView setEditing:YES animated:YES];
        isEditing = YES;
    }
    else {
        [tableView setEditing:NO animated:YES];
        isEditing = NO;
    }
    
#if USING_FLURRY
    [FlurryAnalytics logEvent:@"FriendSuggestionsEdited" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[delegate getUsername], @"username", nil]];
#endif

}

-(IBAction)didClickButtonNext:(id)sender {
    [friends addObjectsFromArray:featured];
    for (NSString * name in friends) {
        NSLog(@"FriendSuggestionController: adding friend %@", name);
    }
    [delegate shouldCloseFriendSuggestionControllerWithNames:friends];
}

-(IBAction)didClickButtonRefresh:(id)sender {
    [k getFeaturedUsers];
    [delegate searchFriendsByFacebook];
}
@end
