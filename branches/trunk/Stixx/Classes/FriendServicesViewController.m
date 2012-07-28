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

#define USE_SORTED 1

@interface FriendServicesViewController ()

@end

@implementation FriendServicesViewController

@synthesize delegate;
@synthesize logo, buttonBack;
@synthesize searchBar;
@synthesize tableView;
@synthesize mode;
@synthesize stixUsersController;

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
    
    [tableView setFrame:CGRectMake(0, 45, 320, 200)];
    [tableView.layer setCornerRadius:10];
    [tableView setDelegate:self];
    [tableView setBackgroundColor:[UIColor clearColor]];

    buttonNames = [[NSMutableArray alloc] initWithObjects:@"Facebook Friends", @"Twitter Friends", @"Contact List", nil];
    buttonIcons = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"icon_share_facebook"], [UIImage imageNamed:@"icon_share_twitter"], [UIImage imageNamed:@"icon_contactlist"], nil];

    stixUsersController = [[StixUsersViewController alloc] init];
    [stixUsersController setDelegate:self];
    [self.view addSubview:stixUsersController.view];
    [stixUsersController.view setHidden:YES];
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

#pragma mark activityindicator
-(void)startActivityIndicatorLarge {
    if (!activityIndicatorLarge) {
        activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 220, 90, 90)];
        [self.view addSubview:activityIndicatorLarge];
    }
    [activityIndicatorLarge startCompleteAnimation];
}

-(void)stopActivityIndicatorLarge {
    if (activityIndicatorLarge) {
        [activityIndicatorLarge setHidden:YES];
        [activityIndicatorLarge stopCompleteAnimation];
        [activityIndicatorLarge removeFromSuperview];
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
    if (mode == PROFILE_SEARCHMODE_FIND)
        return 3;
    if (mode == PROFILE_SEARCHMODE_INVITE)
        return 2;
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
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    // Configure the cell...
    int section = [indexPath section];
    int index = [indexPath row];
    
    [cell.textLabel setText:[buttonNames objectAtIndex:index]];
#if 0
    [cell.imageView setImage:[buttonIcons objectAtIndex:index]];
#else
    UIImage * photo = [buttonIcons objectAtIndex:index];
    CGSize newSize = CGSizeMake(ROW_HEIGHT, ROW_HEIGHT);
    UIGraphicsBeginImageContext(newSize);
    [photo drawInRect:CGRectMake(3, 4, ROW_HEIGHT-8, ROW_HEIGHT-8)];	
    
    UIImage* userPhoto = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();	
    [cell.imageView setImage:userPhoto];    
#endif
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
    service = indexPath.row;
    
    if (service == PROFILE_SERVICE_TWITTER) {
        TwitterHelper * twHelper = [[TwitterHelper alloc] init];
        if ([twHelper isAuthorized]) {
            [self startActivityIndicatorLarge];
            if ([delegate hasTwitterFriends]) {
                if (mode == PROFILE_SEARCHMODE_FIND)
                    [self findFriendsForService:[NSNumber numberWithInt:service]];
                else if (mode == PROFILE_SEARCHMODE_INVITE) 
                    [self inviteFriendsForService:[NSNumber numberWithInt:service]];
            }
            else {
                [twHelper setHelperDelegate:self];
                [twHelper getMyCredentials];
                waitingForTwitter = YES;
            }
        }
        else {
            NSLog(@"twitter not authorized, doing initial!");
            [SHK setRootViewController:self];
            [twHelper setHelperDelegate:self];
            [twHelper doInitialConnect]; //WithCallback:@selector(didInitialTwitterLogin:) withParams:[NSNumber numberWithInt:service]];
            waitingForTwitter = YES;
        }
    }
    else {
        if ([[FacebookHelper sharedFacebookHelper] facebookHasSession]) {
            if (mode == PROFILE_SEARCHMODE_FIND)
                [self findFriendsForService:[NSNumber numberWithInt:service]];
            else if (mode == PROFILE_SEARCHMODE_INVITE) 
                [self inviteFriendsForService:[NSNumber numberWithInt:service]];
        }
        else {
            [self startActivityIndicatorLarge];
            waitingForFacebook = YES;
            int newlogin = [[FacebookHelper sharedFacebookHelper] facebookLoginForShare];
            if (newlogin == 0) {
                // already logged in - continue process
                [[FacebookHelper sharedFacebookHelper] getFacebookInfo];
            }   
        }
    }
    [tableView reloadData];
}

-(void)findFriendsForService:(NSNumber*)_service {
    service = [_service intValue];
    NSLog(@"Find friends from service %d on Stix", service);
    [self initSearchResultLists];

    // facebook friends
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
                if ([_facebookName isEqualToString:[delegate getUsername]] || [_facebookString isEqualToString:[delegate getFacebookString]])
                    continue;
#if USE_SORTED
                int newIndex = [self insertNameSorted:_facebookName];
                [searchFriendID insertObject:_facebookString atIndex:newIndex];
                [searchFriendIsStix insertObject:[NSNumber numberWithBool:YES] atIndex:newIndex];
#else
                [searchFriendName addObject:_facebookName];
                [searchFriendID addObject:_facebookString];
                [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
#endif
            }
        }
        [self finishPopulateStixUsersView];
    }
    else if (service == PROFILE_SERVICE_TWITTER) {
        TwitterHelper * twHelper = [[TwitterHelper alloc] init];
        if ([twHelper isAuthorized]) {
            NSLog(@"Already logged in! was waitingForTwitter: %d", waitingForTwitter);
            NSMutableArray * allUsernames = [delegate getAllUserNames];
            
            NSMutableArray * allTwitterFriendNames = [delegate getAllTwitterFriendNames];
            NSMutableArray * allTwitterFriendScreennames = [delegate getAllTwitterFriendScreennames];
            for (int i=0; i<[allTwitterFriendNames count]; i++) {
                BOOL found = NO;
                NSString * _username = [allTwitterFriendNames objectAtIndex:i];
                NSString * screenname = [allTwitterFriendScreennames objectAtIndex:i];
                // only need friends who are already on list
                if ([_username isEqualToString:[delegate getUsername]] || [screenname isEqualToString:[delegate getUsername]])
                    continue;
                if ([allUsernames containsObject:_username] || [allUsernames containsObject:screenname]) {
#if USE_SORTED
                    int newIndex = [self insertNameSorted:_username];
                    [searchFriendScreenname insertObject:screenname atIndex:newIndex];
                    [searchFriendIsStix insertObject:[NSNumber numberWithBool:YES] atIndex:newIndex];
#else
                    [searchFriendName addObject:_username];
                    [searchFriendScreenname addObject:screenname];
                    [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
#endif
                    found = YES;
                }
                NSLog(@"i %d real name: %@ screenname: %@ found: %d", i, _username, screenname, found);
            }
            waitingForTwitter = NO;
            [self finishPopulateStixUsersView];
        }
        else {
            if (waitingForTwitter)
                return;
            NSLog(@"Should not come here! Twitter should get initialized!");
            [SHK setRootViewController:self];
            [twHelper setHelperDelegate:self];
            [twHelper doInitialConnect]; //WithCallback:@selector(didInitialTwitterLogin:) withParams:[NSNumber numberWithInt:service]];
            waitingForTwitter = YES;
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
            if ([cName isEqualToString:[delegate getUsername]])
                continue;
            
            // search by full name
            if ([allUsers objectForKey:cName] != nil) {
                NSString * cEmail = [[allUsers objectForKey:cName] objectForKey:@"email"];
                //NSLog(@"Friends from contact found by name: %@ withEmail %@", cName, cEmail);
#if USE_SORTED
                int newIndex = [self insertNameSorted:cName];
                [searchFriendEmail insertObject:cEmail atIndex:newIndex];
                [searchFriendID insertObject:cID atIndex:newIndex];
                [searchFriendIsStix insertObject:[NSNumber numberWithBool:YES] atIndex:newIndex];
#else
                [searchFriendName addObject:cName];
                [searchFriendEmail addObject:cEmail]; 
                [searchFriendID addObject:cID];
                [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]]; // only displays members in contact who are already on Stix because we have no facebookString to contact them
#endif
            }
            else {
                // search by email(s)
                for (NSMutableDictionary * e in arEmail) {
                    NSString * cEmail = [e objectForKey:@"strEmail_old"];
                    if ([allUserEmails containsObject:cEmail]) {
                        int index = [allUserEmails indexOfObject:cEmail];
                        cName = [allUserNames objectAtIndex:index];
                        //NSLog(@"Friends from contact found from email: %@ name %@", cEmail, cName);
#if USE_SORTED
                        int newIndex = [self insertNameSorted:cName];
                        [searchFriendEmail insertObject:cEmail atIndex:newIndex];
                        [searchFriendID insertObject:cID atIndex:newIndex];
                        [searchFriendIsStix insertObject:[NSNumber numberWithBool:YES] atIndex:newIndex];
#else
                        [searchFriendName addObject:cName];
                        [searchFriendEmail addObject:cEmail]; 
                        [searchFriendID addObject:cID];
                        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]]; // only displays members in contact who are already on Stix because we have no facebookString to contact them
#endif
                        break;
                    }        
                }
            }
        }
        [self finishPopulateStixUsersView];
    } // end populate contact search results
#if 0
    [stixUsersController.tableView reloadData];
#else
#endif
}

-(void)didInitialLoginForTwitter {
    // start activity indicator running
    // do not show stix users view controller yet
    // ask twitter for credentials
#if 0
    TwitterHelper * twHelper = [[TwitterHelper alloc] init];
    [twHelper setHelperDelegate:self];
    [twHelper getMyCredentials];
    [self startActivityIndicatorLarge];
#else
    TwitterHelper * twHelper = [[TwitterHelper alloc] init];
    if ([twHelper isAuthorized]) { // needs to do this to renew token?
        [self startActivityIndicatorLarge];
        [twHelper setHelperDelegate:self];
        [twHelper getMyCredentials];
        waitingForTwitter = YES;
    }
    else 
        NSLog(@"After login still not working!");
#endif
    
}

-(void)didInitialLoginForFacebook {
    if (waitingForFacebook) {
        [[FacebookHelper sharedFacebookHelper] requestFacebookFriends];
    }
}

-(void)didCancelFacebookConnect {
    [self stopActivityIndicatorLarge];
    if (waitingForFacebook) {
        waitingForFacebook = NO;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Connect" message:@"Facebook connect cancelled! Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)didGetFacebookFriends {
    if (waitingForFacebook) {
        waitingForFacebook = NO;
        [self stopActivityIndicatorLarge];
        
        if (mode == PROFILE_SEARCHMODE_FIND)
            [self findFriendsForService:[NSNumber numberWithInt:service]];
        else if (mode == PROFILE_SEARCHMODE_INVITE) 
            [self inviteFriendsForService:[NSNumber numberWithInt:service]];
    }
}

-(void)inviteFriendsForService:(NSNumber*)_service {
    service = [_service intValue];
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
            if ([_facebookName isEqualToString:[delegate getUsername]])
                continue;
            //NSLog(@"i %d Facebook name: %@ facebook string: %@", i, _facebookName, _facebookString);
            // ONLY display friends NOT on stix
            if (![allFacebookStrings containsObject:_facebookString]) {
#if USE_SORTED
                int newIndex = [self insertNameSorted:_facebookName];
                [searchFriendID insertObject:_facebookString atIndex:newIndex];
                [searchFriendIsStix insertObject:[NSNumber numberWithBool:NO] atIndex:newIndex];
#else
                [searchFriendName addObject:_facebookName];
                [searchFriendID addObject:_facebookString];
                [searchFriendIsStix addObject:[NSNumber numberWithBool:NO]];
#endif
            }
        }
        [self finishPopulateStixUsersView];
    }
    else if (service == PROFILE_SERVICE_TWITTER) {
        TwitterHelper * twHelper = [[TwitterHelper alloc] init];
        if ([twHelper isAuthorized]) {
            NSLog(@"Already logged in! was waitingForTwitter: %d", waitingForTwitter);
            NSMutableArray * allUsernames = [delegate getAllUserNames];
            
            NSMutableArray * allTwitterFriendNames = [delegate getAllTwitterFriendNames];
            NSMutableArray * allTwitterFriendScreennames = [delegate getAllTwitterFriendScreennames];
            for (int i=0; i<[allTwitterFriendNames count]; i++) {
                BOOL found = YES;
                NSString * _username = [allTwitterFriendNames objectAtIndex:i];
                NSString * screenname = [allTwitterFriendScreennames objectAtIndex:i];
                if ([_username isEqualToString:[delegate getUsername]] || [screenname isEqualToString:[delegate getUsername]])
                    continue;
                //NSLog(@"i %d Facebook name: %@ facebook string: %@", i, _facebookName, _facebookString);
                // only need friends who are already on list
                if (![allUsernames containsObject:_username] && ![allUsernames containsObject:screenname]) {
#if USE_SORTED
                    int newIndex = [self insertNameSorted:_username];
                    [searchFriendScreenname insertObject:screenname atIndex:newIndex];
                    [searchFriendIsStix insertObject:[NSNumber numberWithBool:YES] atIndex:newIndex];
#else
                    [searchFriendName addObject:_username];
                    [searchFriendScreenname addObject:screenname];
                    //                    [searchFriendID addObject:allTwitterFriendStrings];
                    [searchFriendIsStix addObject:[NSNumber numberWithBool:NO]];
#endif
                    found = NO;
                }
                NSLog(@"i %d real name: %@ screenname: %@ found: %d", i, _username, screenname, found);
            }
            waitingForTwitter = NO;
            [self finishPopulateStixUsersView];
        }
        else {
            if (waitingForTwitter)
                return;
            NSLog(@"Should not come here! Twitter should get initialized!");
            [SHK setRootViewController:self];
            [twHelper setHelperDelegate:self];
            //[twHelper doInitialConnectWithCallback:@selector(findFriendsForService:) withParams:[NSNumber numberWithInt:service]];
            waitingForTwitter = YES;
        }        
    }
    else if (service == PROFILE_SERVICE_CONTACTS) {
        // todo: call up apple's contact guestbook 
        // give option to either email or text the people
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Invite" message:@"Contact list invite not implemented yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
#if 0
    [stixUsersController.tableView reloadData];
#else
#endif
}

-(IBAction)didClickBackButton:(id)sender {
    //    [self.navigationController popViewControllerAnimated:YES];
    //    [delegate shouldCloseFriendServices];
    [self.view removeFromSuperview];
}

-(void) initSearchResultLists {
    NSLog(@"Doing initSearchResults");
    if (!searchFriendName) {
        searchFriendName = [[NSMutableArray alloc] init];
        searchFriendEmail = [[NSMutableArray alloc] init];
        searchFriendID = [[NSMutableArray alloc] init];
        searchFriendPhone = [[NSMutableArray alloc] init];
        searchFriendScreenname = [[NSMutableArray alloc] init];
        searchFriendIsStix = [[NSMutableArray alloc] init]; // whether they are using Stix already
    }
    [searchFriendName removeAllObjects];
    [searchFriendEmail removeAllObjects];
    [searchFriendID removeAllObjects];
    [searchFriendIsStix removeAllObjects];
    [searchFriendScreenname removeAllObjects];
    [searchFriendPhone removeAllObjects];
    [self.view addSubview:stixUsersController.view];
//    [stixUsersController.view setHidden:YES];
}

-(void)finishPopulateStixUsersView {
    NSLog(@"FinishPopulatingStixUsersView: showing users results with mode %d and %d users: view %x", mode, [searchFriendName count], stixUsersController.view);
    [self stopActivityIndicatorLarge];
    NSLog(@"Mode: %d", mode);
    [stixUsersController setLogoWithMode:mode];
    [stixUsersController.tableView reloadData];
    [stixUsersController.view setHidden:NO];
}

-(void)switchToInviteMode {
//    [self didClickBackButton:nil];
//    [delegate switchToInviteMode];
    [self setMode:PROFILE_SEARCHMODE_INVITE];
    [self viewWillAppear:NO];
    [self.tableView reloadData];
}

#pragma mark search bar

-(void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    [self initSearchResultLists];
    
    [searchBar resignFirstResponder];
    
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
#if USE_SORTED
        int newIndex = [self insertNameSorted:[allUserNames objectAtIndex:index]];
        [searchFriendIsStix insertObject:[NSNumber numberWithBool:YES] atIndex:newIndex];
#else
        [searchFriendName addObject:[allUserNames objectAtIndex:index]];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
#endif
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
#if USE_SORTED
        int newIndex = [self insertNameSorted:name];
        [searchFriendIsStix insertObject:[NSNumber numberWithBool:YES] atIndex:newIndex];
#else
        [searchFriendName addObject:name];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
#endif
    }
//    [stixUsersController.tableView reloadData];
    //[self stopActivityIndicator];
    [self finishPopulateStixUsersView];
    return;
}

#pragma mark StixUsersViewDelegate

-(NSString*)getUsernameForUserAtIndex:(int)index {
    if (index < [searchFriendName count])
        return [searchFriendName objectAtIndex:index];
    return @"";
}

-(NSString*)getUserEmailForUserAtIndex:(int)index {
    if (index < [searchFriendEmail count])
        return [searchFriendEmail objectAtIndex:index];
    return @"";
}
-(UIImage*)getUserPhotoForUserAtIndex:(int)index {
    NSString * friendName = [searchFriendName objectAtIndex:index];
    UIImage * userPhoto = [delegate getUserPhotoForUsername:friendName];
    return userPhoto;
}

-(NSString*)getIDForUser:(int)index {
    if (index < [searchFriendID count])
        return [searchFriendID objectAtIndex:index];
    return @"";
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
    [delegate reloadSuggestions];
}
-(void)unfollowUserAtIndex:(int)index {
    NSString * name = [searchFriendName objectAtIndex:index];
    [delegate unfollowUser:name];
    [stixUsersController.tableView reloadData];
    [delegate reloadSuggestions];
}
-(void)inviteUserAtIndex:(int)index {
    NSString * name = [searchFriendName objectAtIndex:index];
    NSString * screen_name = [searchFriendName objectAtIndex:index];
    [delegate inviteUser:name withService:service];
    
    // if twitter invite, we need access to top level view
    if (service == PROFILE_SERVICE_TWITTER) {
        NSLog(@"Invite using twitter");
        TwitterHelper * twHelper = [[TwitterHelper alloc] init];
        [twHelper setHelperDelegate:self];
        [twHelper setCurrentTopViewController:stixUsersController];
        [twHelper sendInviteMessage:name];
    }
}

-(void)followAllUsers {
    for (int i=0; i<[searchFriendName count]; i++) {
        NSString * name = [searchFriendName objectAtIndex:i];
        if (![delegate isFollowing:name])
            [delegate followUser:name];
    }
    [stixUsersController.tableView reloadData];
    [delegate reloadSuggestions];
}
-(void)inviteAllUsers {
    if (service == PROFILE_SERVICE_FACEBOOK) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Invites" message:@"Sorry, I can't invite all of your Facebook friends at once...yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    else if (service == PROFILE_SERVICE_TWITTER) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Invites" message:@"Are you sure you want to send an invite to these people?" delegate:nil cancelButtonTitle:@"Not Now" otherButtonTitles:@"Yes, tweet on!", nil];
        [alertView setTag:1];
        [alertView setDelegate:self];
        [alertView show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        NSLog(@"Button: %d", buttonIndex);
        if (buttonIndex == 1) {
            TwitterHelper * twHelper = [[TwitterHelper alloc] init];
            [twHelper setHelperDelegate:self];
            [twHelper setCurrentTopViewController:stixUsersController];
            NSLog(@"SearchFriendScreenname: %x %d", searchFriendScreenname, [searchFriendScreenname count]);
            [twHelper sendMassInviteMessage:searchFriendScreenname];
        }
    }
}

#pragma mark twitterHelperDelegate
-(void)twitterHelperStartedInitialConnect {
    // nothing needs to be done here
}
-(void)twitterHelperDidReturnWithCallback:(SEL)callback andParams:(id)params {
    // will be sent back by twitterHelper 
    NSNumber * _service = params;
    NSLog(@"connecting to twitter from friendServices worked! params: %@", _service);
    [self performSelector:callback withObject:_service afterDelay:0];
}
-(void)twitterHelperDidFailWithRequestType:(NSString *)requestType {
    if ([requestType isEqualToString:@"directMessage"]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Timeout" message:@"Your invite failed due to connectivity issues...please try again later!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [self stopActivityIndicatorLarge];
    }
    else if ([requestType isEqualToString:@"initialConnect"] || [requestType isEqualToString:@"getMyCredentials"]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Timeout" message:@"Twitter is taking too long and can't connect...please try again later!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [self stopActivityIndicatorLarge];
    }
}

-(void)didGetTwitterCredentials:(NSDictionary*)results {
    NSLog(@"Did get twitter credentials: %@", results);
    NSEnumerator * e = [results keyEnumerator];
    for (NSString * key in e)
        NSLog(@"Key: %@ value: %@", key, [results objectForKey:key]);
    NSString * friendsCount = [results objectForKey:@"friends_count"];
    NSString * username = [results objectForKey:@"name"];
    NSString * screenname = [results objectForKey:@"screen_name"];
    NSString * twitterString = [results objectForKey:@"id_str"];
    
    TwitterHelper * twHelper = [[TwitterHelper alloc] init];
    [twHelper setHelperDelegate:self];
    NSLog(@"Trying to get twitter friends for screenname %@", screenname);
    [twHelper getFriendsForUser:screenname];
}

-(void)didGetTwitterFriendsIDs:(NSArray*)friendStrings {
    NSLog(@"Received %d friend IDs: %@", [friendStrings count], friendStrings);
    TwitterHelper * twHelper = [[TwitterHelper alloc] init];
    [twHelper setHelperDelegate:self];
    [twHelper getNamesForIDs:friendStrings];
}

-(void)didGetTwitterFriendsFromIDs:(NSArray*)friendArray {
    NSLog(@"Received %d friend IDs: %@", [friendArray count], friendArray);
    // store this stuff in profileViewController
    [delegate didGetTwitterFriends:friendArray];
    [self stopActivityIndicatorLarge];
    
    if (waitingForTwitter) {
        waitingForTwitter = NO;
        if (mode == PROFILE_SEARCHMODE_FIND) {
            [self findFriendsForService:[NSNumber numberWithInt:PROFILE_SERVICE_TWITTER]];
        }
        else if (mode == PROFILE_SEARCHMODE_INVITE) {
            [self inviteFriendsForService:[NSNumber numberWithInt:PROFILE_SERVICE_TWITTER]];
        }
        [self finishPopulateStixUsersView];
    }
}

-(void)shouldDisplayUserPage:(NSString *)name {
    if (mode == PROFILE_SEARCHMODE_INVITE)
        return;
    [delegate shouldDisplayUserPage:name];
}

-(int)getUserID {
    return [delegate getUserID];
}

-(int)insertNameSorted:(NSString*)name {
    // inserts name into searchFriendName; returns its new index
    id newObject = name;
    NSComparator comparator = ^(id obj1, id obj2) {
        return [obj1 compare: obj2];
    };
    
    NSUInteger newIndex = [searchFriendName indexOfObject:newObject
                                     inSortedRange:(NSRange){0, [searchFriendName count]}
                                           options:NSBinarySearchingInsertionIndex
                                   usingComparator:comparator];
    [searchFriendName insertObject:newObject atIndex:newIndex];
    return newIndex;
}
@end
