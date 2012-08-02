//
//  ProfileViewController.m
//  Stixx
//
//  Created by Bobby Ren on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileViewController

@synthesize delegate;
@synthesize activityIndicator;
@synthesize servicesController;
@synthesize scrollView;
//@synthesize buttonAbout, buttonFeedback, buttonBack;
@synthesize camera;

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
    buttonsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300) style:UITableViewStyleGrouped];
    [buttonsTableView setDelegate:self];
    [buttonsTableView setDataSource:self];    
    [buttonsTableView.layer setCornerRadius:10];
    [buttonsTableView setBackgroundColor:[UIColor clearColor]];
    [buttonsTableView setScrollEnabled:NO];

    friendsTableView = [[FriendSearchTableViewController alloc] init];
    [friendsTableView setShowAccessoryButton:YES];
    [friendsTableView setDelegate:self];
    [friendsTableView.view setFrame:CGRectMake(0, 220, 320, 190)];
    [friendsTableView.view setBackgroundColor:[UIColor clearColor]];
    [friendsTableView.tableView setScrollEnabled:NO];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, OFFSET_NAVBAR, 320, 480-OFFSET_NAVBAR-40)];
    [scrollView addSubview:buttonsTableView];
    [scrollView addSubview:friendsTableView.view];
    [scrollView setDelegate:self];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:scrollView];

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 9, 25, 25)];
    [self.view addSubview:activityIndicator];

    [self initializeButtons];
    [self initializeSuggestions];
    [self initializeContactList];
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

-(void)startActivityIndicator {
    //[logo setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    //[logo setHidden:NO];
}
#pragma mark data objects for friends
-(void)initializeHeaderViews {
    if (!headerViews) {
        headerViews = [[NSMutableArray alloc] init];
        for (int i=0; i<SUGGESTIONS_SECTION_MAX; i++) {
            [headerViews addObject:[NSNull null]];
            //NSLog(@"Headerview %d = null!", i);
        }
    }
    UIImageView * featuredHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, HEADER_HEIGHT)];
    [featuredHeader setImage:[UIImage imageNamed:@"header_featuredstixsters@2x.png"]];
    /*
    if ([suggestedFeatured count] == 0) {
        [featuredHeader setFrame:CGRectMake(0, 0, 320, 1)];
    }
     */
    [headerViews replaceObjectAtIndex:SUGGESTIONS_SECTION_FEATURED withObject:featuredHeader];
    UIImageView * friendHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, HEADER_HEIGHT)];
    [friendHeader setImage:[UIImage imageNamed:@"header_friendsonstix@2x.png"]];
    /*
    if ([suggestedFriends count] == 0) {
        [friendHeader setFrame:CGRectMake(0, 0, 320, 1)];
    }
     */
    [headerViews replaceObjectAtIndex:SUGGESTIONS_SECTION_FRIENDS withObject:friendHeader];
    /*
    NSLog(@"After initializing header views: %d sections", [headerViews count]);
    if ([headerViews objectAtIndex:0] == [NSNull null])
        NSLog(@"HeaderView 0 = null!");
    if ([headerViews objectAtIndex:1] == [NSNull null])
        NSLog(@"HeaderView 1 = null!");
    */
    int totalFriends = [suggestedFriends count] + [suggestedFeatured count];
    int newHeight = ROW_HEIGHT * (totalFriends) + HEADER_HEIGHT * [headerViews count];
    [friendsTableView.view setFrame:CGRectMake(friendsTableView.view.frame.origin.x, friendsTableView.view.frame.origin.y, friendsTableView.view.frame.size.width, newHeight)];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, friendsTableView.view.frame.origin.y + friendsTableView.view.frame.size.height)];
    if (totalFriends > 2)
        [scrollView setScrollEnabled:YES];
    else {
        [scrollView setScrollEnabled:NO];
    }
    if ([suggestedFriends count] + [suggestedFeatured count] > 0) {
        [friendsTableView.view setHidden:NO];
    } else {
        [friendsTableView.view setHidden:YES];
    }
    [friendsTableView.tableView reloadData];
}

-(void)reloadSuggestions {
    [self initializeSuggestions];
}

-(void)initializeSuggestions {
    suggestedFriends = [[NSMutableArray alloc] init];
    suggestedFeatured = [[NSMutableArray alloc] init];
    suggestedFeaturedDesc = [[NSMutableArray alloc] init];
    userPhotos = [[NSMutableDictionary alloc] init];
    
    didGetFeaturedUsers = NO;
    didGetFacebookFriends = NO;
    [k getFeaturedUsers];
    [delegate searchFriendsOnStix];
    
    [self initializeHeaderViews];
    //isEditing = NO;
    [friendsTableView.view setHidden:YES];
    /*
    [buttonsTableView setBackgroundColor:[UIColor greenColor]];
    [friendsTableView.view setBackgroundColor:[UIColor redColor]];
    [scrollView setBackgroundColor:[UIColor blueColor]];
     */
}

#pragma mark address book search for contacts
#pragma mark ABAddressBook functions
-(void)initializeContactList
{
    if (allContacts == nil) {
        allContacts = [[NSMutableArray alloc] init];
    }
    [allContacts removeAllObjects];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people  = ABAddressBookCopyArrayOfAllPeople(addressBook);
    for(int i = 0;i<ABAddressBookGetPersonCount(addressBook);i++)
    {
        NSMutableDictionary *myContact = [[NSMutableDictionary alloc] init];
        
        // Get First name, Last name, Prefix, Suffix, Job title 
        ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(ref,kABPersonFirstNameProperty);
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(ref,kABPersonLastNameProperty);
//        NSString *phone = (__bridge_transfer NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty);
//        NSString *email = (__bridge_transfer NSString*)ABRecordCopyValue(ref, kABPersonEmailProperty);
        if (firstName == nil) 
            [myContact setObject:[NSString stringWithFormat:@"%@", lastName] forKey:@"name"];
        else if (lastName == nil)
            [myContact setObject:[NSString stringWithFormat:@"%@", firstName] forKey:@"name"];
        else
            [myContact setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        
//        NSLog(@"Phone: %@ Email: %@", phone, email);
        // extract email
        ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
        NSMutableArray *arEmail = [[NSMutableArray alloc] init];
        NSString * email;
        for(CFIndex idx = 0; idx < ABMultiValueGetCount(emails); idx++)
        {
            CFStringRef emailRef = ABMultiValueCopyValueAtIndex(emails, idx);
            CFStringRef labelRef = ABMultiValueCopyLabelAtIndex (emails, idx);
            NSString *strLbl = (__bridge_transfer NSString*) ABAddressBookCopyLocalizedLabel (labelRef);
            //CFRelease(labelRef);
            //[(NSString*)tmp release];
            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
            // arc conversion
            [temp setObject:(__bridge_transfer NSString*)emailRef forKey:@"strEmail_old"];
            [temp setObject:strLbl forKey:@"strLbl"];
            [arEmail addObject:temp];
            //CFRelease(emailRef);
            email = (__bridge_transfer NSString*)emailRef;
            
            //NSLog(@"Contact list: %@ %@ email %@", firstName, lastName, strEmail_old);
        }
        if (ABMultiValueGetCount(emails) == 0) {
            //NSLog(@"Contact list: %@ %@ email NONE", firstName, lastName);
        }
        else {
            // add array of emails
            [myContact setObject:arEmail forKey:@"email"];
        }
        /*
        // extract phone
        ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        NSMutableArray *arPhone = [[NSMutableArray alloc] init];
        NSString * phone;
        for(CFIndex idx = 0; idx < ABMultiValueGetCount(phones); idx++)
        {
            CFStringRef phoneRef = ABMultiValueCopyValueAtIndex(phones, idx);
            CFStringRef labelRef = ABMultiValueCopyLabelAtIndex (phones, idx);
            NSString *strLbl = (__bridge_transfer NSString*) ABAddressBookCopyLocalizedLabel (labelRef);
            //CFRelease(labelRef);
            //[(NSString*)tmp release];
            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
            // arc conversion
            [temp setObject:(__bridge_transfer NSString*)phoneRef forKey:@"strPhone_old"];
            [temp setObject:strLbl forKey:@"strLbl"];
            [arEmail addObject:temp];
            //CFRelease(emailRef);
            phone = (__bridge_transfer NSString*)phoneRef;
            //NSLog(@"Contact list: %@ %@ email %@", firstName, lastName, strEmail_old);
        }
        if (ABMultiValueGetCount(phones) == 0) {
            //NSLog(@"Contact list: %@ %@ email NONE", firstName, lastName);
        }
        else {
            [myContact setObject:phone forKey:@"phone"];
        }
         */
        [myContact setObject:@"" forKey:@"id"];
        [allContacts addObject:myContact];
        CFRelease(emails);
        //CFRelease(phones);
        //NSLog(@"name: %@ %@ phone: %@ email %@", firstName, lastName, phone, email);
    }
    CFRelease(people);
    //CFRelease(addressBook);
}

-(void)didGetFacebookFriends:(NSArray*)facebookFriendArray {
    // facebook request has returned list of user friends
    // - populate suggested friends list
    [activityIndicator stopCompleteAnimation];
    
    if (allFacebookFriendNames == nil) {
        allFacebookFriendNames = [[NSMutableArray alloc] init];
        allFacebookFriendStrings = [[NSMutableArray alloc] init];
    }
    else {
        [allFacebookFriendNames removeAllObjects];
        [allFacebookFriendStrings removeAllObjects];
    }
    
    // first part is for the friend suggestion controller
    [suggestedFriends removeAllObjects];
    NSMutableSet * alreadyFollowing = [delegate getFollowingList];
    NSLog(@"Already following: %d people", [alreadyFollowing count]);
    NSMutableArray * allFacebookStrings = [delegate getAllUserFacebookStrings];
    NSLog(@"AllFacebookStrings %d", [allFacebookStrings count]);
    for (NSMutableDictionary * d in facebookFriendArray) {
        NSString * _facebookString = [d valueForKey:@"id"];
        NSString * _facebookName = [d valueForKey:@"name"];
        
        // save info for later
        [allFacebookFriendNames addObject:_facebookName];
        [allFacebookFriendStrings addObject:_facebookString];
        
        if ([alreadyFollowing containsObject:_facebookName]) {
            //NSLog(@"Already following %@", _facebookName);
            continue; // skip those already following
        }
        if ([_facebookName isEqualToString:[delegate getUsername]])
            continue; // skip self
        if ([allFacebookStrings containsObject:_facebookString]) {
            NSString * stixName = [delegate getNameForFacebookString:_facebookString];
            [suggestedFriends addObject:stixName];
            NSLog(@"Adding facebook friend already on stix: %@ with id %@ and stix name %@ now friends count %d", _facebookName, _facebookString, stixName, [suggestedFriends count]);
        }
    }
    
    NSLog(@"Loaded %d new Facebook friends already on Stix, %d featured", [suggestedFriends count], [suggestedFeatured count]);
    // filter out existing friends, if any
    if ([suggestedFeatured count] > 0) {
        for (NSString * name in suggestedFeatured) {
            if ([suggestedFriends containsObject:name])
                NSLog(@"Removing friend name %@ because featured contains it: %d", name, [suggestedFeatured count]);
                [suggestedFriends removeObject:name];
        }
    }
    if ([suggestedFriends count] > 0) {
        [self initializeHeaderViews]; // reload in case initializeHeaderViews was called before this appeared
    }
    didGetFacebookFriends = YES;
    if (didGetFeaturedUsers && [suggestedFeatured count] + [suggestedFriends count] == 0) {
        //[friendsTableView.view removeFromSuperview];
        [friendsTableView.view setHidden:YES];
    } 
    else {
        [friendsTableView.tableView reloadData];
    }
    
    [servicesController didGetFacebookFriends];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFeaturedUsersDidCompleteWithResult:(NSArray *)theResults {
    
    if ([theResults count] == 0)
        return;
    
    [suggestedFeatured removeAllObjects];
    
    NSMutableSet * alreadyFollowing = [delegate getFollowingList];
    
    for (NSMutableDictionary * d in theResults) {
        NSString * username = [d objectForKey:@"username"];
        if ([alreadyFollowing containsObject:username])
            continue;
        if ([username isEqualToString:[delegate getUsername]])
            continue;
        [suggestedFeatured addObject:username];
        NSString * desc = [d objectForKey:@"description"];
        [suggestedFeaturedDesc addObject:desc];
    }
    
    NSLog(@"Loaded %d Featured friends", [suggestedFeatured count]);
    
    didGetFeaturedUsers = YES;
    // filter out existing friends, if any
    if ([suggestedFriends count] > 0) {
        for (NSString * name in suggestedFeatured) {
            if ([suggestedFriends containsObject:name])
                [suggestedFriends removeObject:name];
        }
    }
    if ([suggestedFeatured count] > 0) {
        [self initializeHeaderViews]; // reload in case initializeHeaderViews was called before this appeared
    }
    if (didGetFacebookFriends && [suggestedFeatured count] + [suggestedFriends count] == 0) {
//        [friendsTableView.view removeFromSuperview];
        [friendsTableView.view setHidden:YES];
    } 
    else {
        [friendsTableView.tableView reloadData];
    }
}

-(void)didGetTwitterFriends:(NSArray*)friendArray {
    // from FriendServicesViewController or ShareController
    if (allTwitterFriendNames == nil) {
        allTwitterFriendNames = [[NSMutableArray alloc] init];
        allTwitterFriendScreennames = [[NSMutableArray alloc] init];
        allTwitterFriendStrings = [[NSMutableArray alloc] init];
    }
    else {
        [allTwitterFriendNames removeAllObjects];
        [allTwitterFriendScreennames removeAllObjects];
        [allTwitterFriendStrings removeAllObjects];
    }
    
    for (NSMutableDictionary * d in friendArray) {
        NSString * twitterString = [d objectForKey:@"id_str"];
        NSString * name = [d objectForKey:@"name"];
        NSString * screenname = [d objectForKey:@"screen_name"];
        NSLog(@"Adding twitter user %@ with screenname %@", name, screenname);
        // if needed in future
        NSString * profile_image_url = [d objectForKey:@"profile_image_url"];         
        [allTwitterFriendNames addObject:name];
        [allTwitterFriendScreennames addObject:screenname]; // people may use same screenname for twitter and stix
        [allTwitterFriendStrings addObject:twitterString];
    }
    didGetTwitterFriends = YES;
}


#pragma mark FriendSearchTableDelegate 
-(int)friendsCount {
    if (!didGetFacebookFriends)
        return 0;
    return [suggestedFriends count];
}
-(int)featuredCount {
    if (!didGetFeaturedUsers)
        return 0;
    return [suggestedFeatured count];
}
-(NSString*)getFriendAtIndex:(int)index {
    if (index >= [suggestedFriends count])
        return nil;
    return [suggestedFriends objectAtIndex:index];
}
-(NSString*)getFeaturedAtIndex:(int)index {
    if (index >= [suggestedFeatured count])
        return nil;
    return [suggestedFeatured objectAtIndex:index];
}
-(NSString*)getFeaturedDescriptorAtIndex:(int)index {
    if (index >= [suggestedFeaturedDesc count])
        return nil;
    return [suggestedFeaturedDesc objectAtIndex:index];
}

-(int)numberOfSections {
    return [headerViews count];
}
-(UIView*)headerViewForSection:(int)section {
    return [headerViews objectAtIndex:section];
}

-(void)removeFriendAtRow:(int)row {
    // unlike FriendSuggestionController, friends here get removed from the list when they are added/followed
    [self followUser:[suggestedFriends objectAtIndex:row]];

    if (row < [suggestedFriends count])
        [suggestedFriends removeObjectAtIndex:row];
    if ([suggestedFriends count] == 0)
        [self initializeHeaderViews];
    
}
-(void)removeFeaturedAtRow:(int)row {
    // unlike FriendSuggestionController, friends here get removed from the list when they are added/followed
    [self followUser:[suggestedFeatured objectAtIndex:row]];
    
    if (row < [suggestedFeatured count]) {
        [suggestedFeatured removeObjectAtIndex:row];
        [suggestedFeaturedDesc removeObjectAtIndex:row];
    }
    if ([suggestedFeatured count] == 0)
        [self initializeHeaderViews];
    
}
-(void)removeFriendsHeader {
    //[headerViews removeObjectAtIndex:SUGGESTIONS_SECTION_FRIENDS];
}

#pragma mark tableViewDelegate for buttons

-(void)initializeButtons {
    
    buttonNames = [[NSMutableArray alloc] initWithObjects:@"Invite Friends", @"Find Friends", @"Search by Name", @"View My Pix", nil];
    buttonIcons = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"icon_profile_invitefriends"], [UIImage imageNamed:@"icon_profile_findfriends"], [UIImage imageNamed:@"icon_profile_searchbyname"], [UIImage imageNamed:@"icon_profile_pix"], nil];
    
    /*
    navController = [[UINavigationController alloc] init];
    [navController setDelegate:self];
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [navController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar"] forBarMetrics:UIBarMetricsDefault]; 
     */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 3;
    return 1;
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
    
    if (section == 1) {
        index = index + 3; // 3 indices already in section 0
    }
    [cell.textLabel setText:[buttonNames objectAtIndex:index]];
#if 0
    [cell.imageView setImage:[buttonIcons objectAtIndex:index]];
#else
    UIImage * photo = [buttonIcons objectAtIndex:index];
    CGSize newSize = CGSizeMake(ROW_HEIGHT, ROW_HEIGHT);
    UIGraphicsBeginImageContext(newSize);
    [photo drawInRect:CGRectMake(5, 6, PICTURE_HEIGHT, PICTURE_HEIGHT)];	
    
    UIImage* userPhoto = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();	
    [cell.imageView setImage:userPhoto];    
#endif
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return ROW_HEIGHT_PROFILE;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
#if SHOW_ARROW
    if ([delegate getFirstTimeUserStage] == 3) {
        showPointer = NO;
        [delegate advanceFirstTimeUserMessage];
    }
#endif
    if (isSearching)
        return;
    if (![delegate isLoggedIn])
        return;
    /*
    if (searchByNameController == nil) {
        searchByNameController = [[SearchByNameController alloc] init];
        [searchByNameController setDelegate:self];
    }
    [self.view addSubview:searchByNameController.view];
    */
    
    // MY PIX
    if (indexPath.section == 1) {
        // MY PIX
        if (![delegate isLoggedIn])
            return;
        NSLog(@"Button show my pix!");
        //[self shouldDisplayUserPage:[delegate getUsername]];
        [self viewMyPix];
    }
    else if (indexPath.row == 0) {
        //[navController pushViewController:servicesController animated:YES];
        //[self presentModalViewController:navController animated:YES];
        [self showInviteFriends];
    }
    else if (indexPath.row == 1) {
        [self showFindFriends];
    }
    else if (indexPath.row == 2) {
        [self showSearchFriends];
    }
    [tableView reloadData];
}

-(void)doPointerAnimation {
    //showPointer = YES;
#if SHOW_ARROW
    UIImage * pointerImg = [UIImage imageNamed:@"orange_arrow.png"];
    CGRect canvasFrame = CGRectMake(160-pointerImg.size.width/2, 20, pointerImg.size.width, pointerImg.size.height);
    UIView * pointerCanvas = [[UIView alloc] initWithFrame:canvasFrame];
    UIButton * pointer = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, pointerImg.size.width, pointerImg.size.height)];
    [pointer setImage:pointerImg forState:UIControlStateNormal];
    [pointer addTarget:self action:@selector(didClickPointer) forControlEvents:UIControlEventTouchUpInside];
    //UIImageView * pointer = [[UIImageView alloc] initWithImage:pointerImg];
    //pointer.transform = CGAffineTransformMakeRotation(3.141592);
    [pointerCanvas addSubview:pointer];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    [animation doJump:pointerCanvas inView:self.view forDistance:20 forTime:1];
#endif
}

-(IBAction)inviteButtonClicked:(id)sender {
    [delegate didClickInviteButton];
}

#pragma mark FriendSearchResultsDelegate

-(NSString*)getUsername {
    return [delegate getUsername];
}

-(NSString*)getFacebookString {
    return [delegate getFacebookString];
}

-(int)getUserID {
    return [delegate getUserID];
}

-(BOOL)isFollowing:(NSString*)name {
    return [delegate isFollowing:name];
}
-(UIImage*)getUserPhotoForUsername:(NSString *)name {
      UIImage * userPhoto = [delegate getUserPhotoForUsername:name];
    return userPhoto;
}

//-(int)getNumOfUsers {
//    return [searchFriendName count];
//}

// ALL users

-(NSMutableDictionary*)getAllUsers {
    return [delegate getAllUsers];
}

-(NSMutableArray*)getAllUserNames {
    return [delegate getAllUserNames];
}
-(NSMutableArray*)getAllUserFacebookStrings {
    return [delegate getAllUserFacebookStrings];
}
-(NSMutableArray*)getAllUserEmails {
    return [delegate getAllUserEmails];
}

// all contacts from contact list
-(NSMutableArray*)getAllContacts {
    return allContacts;
}

// FRIENDS only

-(NSMutableArray*)getAllFacebookFriendNames {
    return allFacebookFriendNames;
}

-(NSMutableArray*)getAllFacebookFriendStrings {
    return allFacebookFriendStrings;
}

// twitter friends
-(NSMutableArray*)getAllTwitterFriendNames {
    return allTwitterFriendNames;
}

-(NSMutableArray*)getAllTwitterFriendScreennames {
    return allTwitterFriendScreennames;
}

-(BOOL)hasTwitterFriends {
    return didGetTwitterFriends;
}

/*
-(void)addFriendFromList:(int)index {
    NSString * username = [self getUsernameForUser:index];
    //NSMutableSet * friendsList = [self.delegate getFriendsList];
    if ([self getFollowingUserStatus:index] == 1) { 
        [delegate setFollowing:username toState:NO];
    }
    else if ([self getFollowingUserStatus:index] == 0)
    {
        [delegate setFollowing:username toState:YES];
    }
    else {
        // invite
        NSString * _facebookString = nil; //[self getIDForUser:index]; 
        [delegate didClickInviteButtonByFacebook:username withFacebookString:_facebookString];
    }
    //[[searchResultsController tableView] reloadData];
}
 */

-(void)followUser:(NSString*)name {
    NSLog(@"Profile: starting to follow name: %@", name);
    if (![delegate isFollowing:name])
        [delegate setFollowing:name toState:YES];
    // todo: if friend lists are changed elsewhere, this needs to be updated
}
-(void)unfollowUser:(NSString*)name {
    if ([delegate isFollowing:name])
        [delegate setFollowing:name toState:NO];
    // todo: if friend lists are changed elsewhere, this needs to be updated
}
-(void)inviteUser:(NSString*)name withService:(int)service{
    // invite
    //NSLog(@"allFacebookFriendNames objects: %d object1: %@ string %@ searching for name %@", [allFacebookFriendNames count], [allFacebookFriendNames objectAtIndex:0], [allFacebookFriendStrings objectAtIndex:0], name);
    if (service == PROFILE_SERVICE_FACEBOOK) {
        if ([allFacebookFriendNames containsObject:name]) {
            int index = [allFacebookFriendNames indexOfObject:name];
            NSLog(@"index: %u", index);
            NSString * _facebookString = [allFacebookFriendStrings objectAtIndex:index];
            [delegate didClickInviteButtonByFacebook:name withFacebookString:_facebookString];
        }
        else {
            NSLog(@"Cannot invite someone without a facebook ID");
        }
    }
    else if (service == PROFILE_SERVICE_TWITTER) {
        NSLog(@"friend services view is taking care of it!");
    }
}

-(void)didSelectUserProfile:(int)index {
    NSString * username = [self getUsernameForUser:index];
    if ([username isEqualToString:[delegate getUsername]]) {
        //[self didClickBackButton:nil];
    }
    else {
        //if ([[searchFriendIsStix objectAtIndex:index] boolValue]) {
        [delegate shouldDisplayUserPage:username];
        //}   
    }
}

-(void)shouldDisplayUserPage:(NSString *)name {
    [delegate shouldDisplayUserPage:name];
}

-(void)viewMyPix {
    [self shouldDisplayUserPage:[delegate getUsername]];
}

//-(void)shouldCloseUserPage {
//    [delegate shouldCloseUserPage];
//}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas {
#if SHOW_ARROW
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    if (showPointer)
        [animation doJump:canvas inView:self.view forDistance:20 forTime:1];
    else {
        [canvas removeFromSuperview];
    }
#endif
}

-(void)didLogin {
    NSLog(@"Here!");
}

-(void)didConnectToFacebook {
    // tell friendTableController in case we were waiting
    [servicesController didInitialLoginForFacebook];
}

-(void)didCancelFacebookConnect {
    [servicesController didCancelFacebookConnect];
}

-(void)showInviteFriends {
    servicesController = [[FriendServicesViewController alloc] init];
    [servicesController setMode:PROFILE_SEARCHMODE_INVITE];
    [servicesController setDelegate:self];
#if 0
    CGRect frameOffscreen = CGRectMake(-320, 0, 320, 480);
    [self.tabBarController.view addSubview:servicesController.view];
    [servicesController.view setFrame:frameOffscreen];
    
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:servicesController.view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished){
        // for some reason needs this
        [servicesController viewDidAppear:YES];
    }];
#else
    [self.navigationController pushViewController:servicesController animated:YES];
#endif
}

-(void)showFindFriends {
    servicesController = [[FriendServicesViewController alloc] init];
    [servicesController setMode:PROFILE_SEARCHMODE_FIND];
    [servicesController setDelegate:self];
#if 0
    CGRect frameOffscreen = CGRectMake(-320, 0, 320, 480);
    [self.tabBarController.view addSubview:servicesController.view];
    [servicesController.view setFrame:frameOffscreen];
    
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:servicesController.view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished){
        // for some reason needs this
        [servicesController viewDidAppear:YES];
    }];
#else
//    [self.view addSubview:servicesController.view];
    [self.navigationController pushViewController:servicesController animated:YES];
#endif
}

-(void)showSearchFriends {
    servicesController = [[FriendServicesViewController alloc] init];
    [servicesController setMode:PROFILE_SEARCHMODE_SEARCHBAR];
    [servicesController setDelegate:self];
#if 0
    CGRect frameOffscreen = CGRectMake(-320, 0, 320, 480);
    [self.tabBarController.view addSubview:servicesController.view];
    [servicesController.view setFrame:frameOffscreen];
    
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:servicesController.view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished){
        // for some reason needs this
        [servicesController viewDidAppear:YES];
    }];
#else
    [self.navigationController pushViewController:servicesController animated:YES];
//    [self.view addSubview:servicesController.view];
#endif
}

-(void)didSelectFriendSearchIndexPath:(NSIndexPath *)indexPath {
    int section = indexPath.section;
    int row = indexPath.row;
    NSString * name;
    if (section == 0) {
        // featured
        name = [suggestedFeatured objectAtIndex:row];
        [suggestedFeatured removeObjectAtIndex:row];
    }
    else {
        name = [suggestedFriends objectAtIndex:row];
        [suggestedFriends removeObjectAtIndex:row];
    }
    [self followUser:name];
    
    if ([suggestedFeatured count] == 0 || [suggestedFriends count] == 0) {
        [self initializeHeaderViews];
    }
    if ([suggestedFriends count] + [suggestedFeatured count] == 0) {
        //[friendsTableView.tableView removeFromSuperview];
        [friendsTableView.view setHidden:YES];
    }
    else {
        [friendsTableView.tableView reloadData];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [buttonBack setHidden:YES];
}

-(IBAction)closeTOS {
    CGRect frameOnscreen = CGRectMake(0, 44, 320, 480-44-40);
    CGRect frameOffscreen = CGRectMake(-320, 44, 320, 480-44-40);
//    [buttonFeedback setHidden:NO];
//    [buttonAbout setHidden:NO];
//    [buttonBack setHidden:YES];
    if (webView) {

        [webView setFrame:frameOnscreen];
        StixAnimation * animation = [[StixAnimation alloc] init];
        
        //CGRect frameOffscreen = webView.frame;
        //frameOffscreen.origin.x -= 330;
        [animation doViewTransition:webView toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
            [webView removeFromSuperview];
            webView = nil;
        }];
    }
}

@end
