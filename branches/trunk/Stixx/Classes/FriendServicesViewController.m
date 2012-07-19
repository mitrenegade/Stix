//
//  FriendServicesViewController.m
//  Stixx
//
//  Created by Bobby Ren on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendServicesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "StixAnimation.h"

@interface FriendServicesViewController ()

@end

@implementation FriendServicesViewController

@synthesize delegate;
@synthesize logo, buttonBack;
@synthesize searchBar;
@synthesize tableView;
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
    
    [tableView setFrame:CGRectMake(0, 40, 320, 200)];
    [tableView.layer setCornerRadius:10];
    [tableView setDelegate:self];
    [tableView setBackgroundColor:[UIColor clearColor]];

    buttonNames = [[NSMutableArray alloc] initWithObjects:@"Facebook Friends", @"Twitter Friends", @"Contact List", nil];
    buttonIcons = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"icon_share_facebook"], [UIImage imageNamed:@"icon_share_twitter"], [UIImage imageNamed:@"icon_contactlist"], nil];
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (mode == PROFILE_SEARCHMODE_FIND) {
        [searchBar setHidden:YES];
        [tableView setHidden:NO];
        [logo setImage:[UIImage imageNamed:@"txt_findfriends"]];
        [logo setFrame:CGRectMake(108, 12, 105, 25)];
    }
    else if (mode == PROFILE_SEARCHMODE_INVITE) {
        [searchBar setHidden:YES];
        [tableView setHidden:NO];
        [logo setImage:[UIImage imageNamed:@"txt_invitefriends"]];
        [logo setFrame:CGRectMake(103, 12, 115, 25)];
    }
    else if (mode == PROFILE_SEARCHMODE_SEARCHBAR) {
        [logo setImage:[UIImage imageNamed:@"logo"]];
        [logo setFrame:CGRectMake(131, 2, 59, 38)];
        [searchBar setHidden:NO];
        [tableView setHidden:YES];
        [searchBar setPlaceholder:@"Search by name, email, etc"];
        [searchBar setDelegate:self];
        [searchBar becomeFirstResponder];
    }
}

#pragma mark tableView delegate functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 1;
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell.backgroundView setAlpha:.5];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // Configure the cell...
    int section = [indexPath section];
    int index = [indexPath row];
    
    [cell.textLabel setText:[buttonNames objectAtIndex:index]];
    [cell.imageView setImage:[buttonIcons objectAtIndex:index]];
    [cell.imageView setFrame:CGRectMake(3, 3, 25, 25)];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    int service = indexPath.row;
    if (mode == PROFILE_SEARCHMODE_FIND)
        [self findFriendsForService:service];
    else if (mode == PROFILE_SEARCHMODE_INVITE) 
        [self inviteFriendsForService:service];
}

-(void)findFriendsForService:(int)service {
    NSLog(@"Find friends from service %d on Stix", service);
    [self initSearchResultLists];

    // currently facebook only
    if (service == PROFILE_SERVICE_FACEBOOK) {
        NSMutableArray * allFacebookStrings = [delegate getAllUserFacebookStrings];
        NSMutableArray * allFacebookFriendStrings = [delegate getAllFacebookFriendStrings];
        NSMutableArray * allFacebookFriendNames = [delegate getAllFacebookFriendNames];
        for (int i=0; i<[allFacebookFriendStrings count]; i++) {
            NSString * _facebookString = [allFacebookFriendStrings objectAtIndex:i];
            NSString * _facebookName = [allFacebookFriendNames objectAtIndex:i];
            //NSLog(@"i %d Facebook name: %@ facebook string: %@", i, _facebookName, _facebookString);
            // only need friends who are already on list
            if ([allFacebookStrings containsObject:_facebookString]) {
                [searchFriendName addObject:_facebookName];
                [searchFriendID addObject:_facebookString];
                [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
            }
        }
    }
    else if (service == PROFILE_SERVICE_CONTACTS) {
        // populate contact search results
        NSMutableDictionary * allUsers = [delegate getAllUsers];
        NSMutableArray * allUserEmails = [delegate getAllUserEmails];
        NSMutableArray * allUserNames = [delegate getAllUserNames];
        NSMutableArray * allContacts = [delegate getAllContacts];
        for (NSMutableDictionary * d in allContacts) {
            //NSLog(@"Contact: %@", d);
            NSString * cName = [d valueForKey:@"name"];
            NSArray * arEmail = [d valueForKey:@"email"];
            NSString * cID = [d valueForKey:@"id"];
            
            // search by full name
            if ([allUsers objectForKey:cName] != nil) {
                NSString * cEmail = [[allUsers objectForKey:cName] objectForKey:@"email"];
                //NSLog(@"Friends from contact found by name: %@ withEmail %@", cName, cEmail);
                [searchFriendName addObject:cName];
                [searchFriendEmail addObject:cEmail]; 
                [searchFriendID addObject:cID];
                [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]]; // only displays members in contact who are already on Stix because we have no facebookString to contact them
            }
            else {
                // search by email(s)
                for (NSMutableDictionary * e in arEmail) {
                    NSString * cEmail = [e objectForKey:@"strEmail_old"];
                    if ([allUserEmails containsObject:cEmail]) {
                        int index = [allUserEmails indexOfObject:cEmail];
                        cName = [allUserNames objectAtIndex:index];
                        //NSLog(@"Friends from contact found from email: %@ name %@", cEmail, cName);
                        [searchFriendName addObject:cName];
                        [searchFriendEmail addObject:cEmail]; 
                        [searchFriendID addObject:cID];
                        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]]; // only displays members in contact who are already on Stix because we have no facebookString to contact them
                        break;
                    }        
                }
            }
        }
    } // end populate contact search results
    [tableView reloadData];
}

-(void)inviteFriendsForService:(int)service {
    NSLog(@"Invite friends from service %d not already on Stix", service);
    [self initSearchResultLists];
    
    // currently facebook only
    if (service == PROFILE_SERVICE_FACEBOOK) {
        NSMutableArray * allFacebookStrings = [delegate getAllUserFacebookStrings];
        NSMutableArray * allFacebookFriendStrings = [delegate getAllFacebookFriendStrings];
        NSMutableArray * allFacebookFriendNames = [delegate getAllFacebookFriendNames];
        for (int i=0; i<[allFacebookFriendStrings count]; i++) {
            NSString * _facebookString = [allFacebookFriendStrings objectAtIndex:i];
            NSString * _facebookName = [allFacebookFriendNames objectAtIndex:i];
            //NSLog(@"i %d Facebook name: %@ facebook string: %@", i, _facebookName, _facebookString);
            // ONLY display friends NOT on stix
            if (![allFacebookStrings containsObject:_facebookString]) {
                [searchFriendName addObject:_facebookName];
                [searchFriendID addObject:_facebookString];
                [searchFriendIsStix addObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
    else if (service == PROFILE_SERVICE_CONTACTS) {
        // todo: call up apple's contact guestbook 
        // give option to either email or text the people
    }
    [tableView reloadData];
}

-(IBAction)didClickBackButton:(id)sender {
    //    [self.navigationController popViewControllerAnimated:YES];
    //    [delegate shouldCloseFriendServices];
    [self.view removeFromSuperview];
}

-(void) initSearchResultLists {
    if (!searchFriendName) {
        searchFriendName = [[NSMutableArray alloc] init];
        searchFriendEmail = [[NSMutableArray alloc] init];
        searchFriendID = [[NSMutableArray alloc] init];
        searchFriendPhone = [[NSMutableArray alloc] init];
        searchFriendIsStix = [[NSMutableArray alloc] init]; // whether they are using Stix already
    }
    [searchFriendName removeAllObjects];
    [searchFriendEmail removeAllObjects];
    [searchFriendID removeAllObjects];
    [searchFriendIsStix removeAllObjects];
    [searchFriendPhone removeAllObjects];
    
    if (!stixUsersController) {
        stixUsersController = [[StixUsersViewController alloc] init];
        [stixUsersController setDelegate:self];
    }
    [self.view addSubview:stixUsersController.view];
    [stixUsersController setLogoWithMode:mode];
}

#pragma mark search bar

-(void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    [self initSearchResultLists];
    
    [searchBar resignFirstResponder];
    
    //    [self startActivityIndicator];
    NSLog(@"Query: %@", [_searchBar text]);
    NSArray *query = [[_searchBar text] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // NSMutableArray * allUserEmails = [self.delegate getAllUserEmails];
    NSMutableArray * allUserNames = [delegate getAllUserNames];
    NSMutableArray * allUserFacebookStrings = [delegate getAllUserFacebookStrings];
    
    NSLog(@"Searching for facebookString");
    // see if searching for facebook String - probably will not happen
    BOOL isFacebookString = [allUserFacebookStrings containsObject:[_searchBar text]];
    if (isFacebookString) {
        int index = [allUserFacebookStrings indexOfObject:[_searchBar text]];
        [searchFriendName addObject:[allUserNames objectAtIndex:index]];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
        [stixUsersController.tableView reloadData];
        return;
    }
    
    NSMutableSet * namesResults = [[NSMutableSet alloc] init];
    for (int i=0; i<[query count]; i++) {
        NSString * term = [[query objectAtIndex:i] lowercaseString];
        if (term == nil)
            continue;
        
        NSLog(@"Searching query element: %@", term);
        for (int j=0; j<[allUserNames count]; j++) {
            NSRange namePos = [[[allUserNames objectAtIndex:j] lowercaseString] rangeOfString:term];
            //NSRange emailPos = [[[allUserEmails objectAtIndex:j] lowercaseString] rangeOfString:term];
            if (namePos.location != NSNotFound) {
                [namesResults addObject:[allUserNames objectAtIndex:j]];
            }
        }
    }
    NSLog(@"Populating search results: %d names", [namesResults count]);
    for (NSString * name in namesResults) {
        if ([name isEqualToString:[delegate getUsername]])
            continue;
        [searchFriendName addObject:name];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
    }
    [stixUsersController.tableView reloadData];
    //[self stopActivityIndicator];
    return;
}

#pragma mark StixUsersViewDelegate

-(NSString*)getUsernameForUserAtIndex:(int)index {
    return [searchFriendName objectAtIndex:index];
}

-(NSString*)getUserEmailForUserAtIndex:(int)index {
    return [searchFriendEmail objectAtIndex:index];
}
-(UIImage*)getUserPhotoForUserAtIndex:(int)index {
    NSString * friendName = [searchFriendName objectAtIndex:index];
    UIImage * userPhoto = [delegate getUserPhotoForUsername:friendName];
    return userPhoto;
}

-(NSString*)getIDForUser:(int)index {
    return [searchFriendID objectAtIndex:index];
}

-(int)getFollowingUserStatus:(int)index {
    if (![[searchFriendIsStix objectAtIndex:index] boolValue])
        return -1; // not stix: invite
    
    NSString * friendName = [searchFriendName objectAtIndex:index];
    if ([friendName isEqualToString:[delegate getUsername]])
        return -2; // self - no button
    return [delegate isFollowing:friendName];
}

-(UIImage*)getUserPhotoForUsername:(NSString *)name {
    //UIImage * userPhoto = [UIImage imageWithData:[[delegate getUserPhotos] objectForKey:name]];
    UIImage * userPhoto = [delegate getUserPhotoForUsername:name];
    return userPhoto;
}

-(int)getNumOfUsers {
    return [searchFriendName count];
}

-(void)followUserAtIndex:(int)index {
    NSString * name = [searchFriendName objectAtIndex:index];
    [delegate followUser:name];
    [stixUsersController.tableView reloadData];
}
-(void)unfollowUserAtIndex:(int)index {
    NSString * name = [searchFriendName objectAtIndex:index];
    [delegate unfollowUser:name];
    [stixUsersController.tableView reloadData];
}
-(void)inviteUserAtIndex:(int)index {
    NSString * name = [searchFriendName objectAtIndex:index];
    [delegate inviteUser:name];
}

-(void)followAllUsers {
    for (int i=0; i<[searchFriendName count]; i++) {
        NSString * name = [searchFriendName objectAtIndex:i];
        [delegate followUser:name];
    }
    [stixUsersController.tableView reloadData];
}

@end
