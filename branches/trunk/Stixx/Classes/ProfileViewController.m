//
//  ProfileViewController.m
//  ARKitDemo
//
//  Created by Administrator on 7/11/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "ProfileViewController.h"

@implementation ProfileViewController

//@synthesize logoutScreenButton;
//@synthesize friendCountButton;
//@synthesize stixCountButton;
@synthesize delegate;
@synthesize nameLabel;
@synthesize photoButton;
//@synthesize friendController;
@synthesize k;
@synthesize activityIndicator;
@synthesize searchResultsController;
@synthesize bgFollowers, bgFollowing;
@synthesize searchBar;
@synthesize bottomBackground;
@synthesize myFollowersCount, myFollowersLabel, myFollowingCount, myFollowingLabel;
@synthesize myPixCount, myPixLabel, myStixCount, myStixLabel;
//@synthesize followersCount, followingCount;

-(id)init
{
	self = [super initWithNibName:@"ProfileViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"Profile"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_me.png"];
	[tbi setImage:i];
    
    k = nil;
    k = [[Kumulos alloc]init];
    [k setDelegate:self];    
    //isLoggedIn = NO;
    return self;
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
	if (k == nil)
    {
        k = [[Kumulos alloc]init];
        [k setDelegate:self];    
    }
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(150, 9, 25, 25)];
    [self.view addSubview:activityIndicator];
    
    // populate with followers profile
    [self populateFollowCounts];
    
    // populate with self profile
    [self populateWithMyButtons];
    
    searchResultsController = nil;
}

-(void)startActivityIndicator {
    [logo setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    [logo setHidden:NO];
}

#pragma mark initialization functions

-(void)populateWithMyButtons {
    bottomBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textured_background.png"]];
    [bottomBackground setFrame:CGRectMake(0, 160, 320, 320)];
    [self.view addSubview:bottomBackground];
    
    discoverLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [discoverLabel setImage:[UIImage imageNamed:@"txt_discover.png"] forState:UIControlStateNormal];
    [discoverLabel setFrame:CGRectMake(0, 20+160, 320, 25)];
    [self.view addSubview:discoverLabel];
    
    buttonContacts = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonContacts setFrame:CGRectMake(20, 60+160, 85, 100)];
    [buttonContacts setImage:[UIImage imageNamed:@"graphic_contacts.png"] forState:UIControlStateNormal];
    [buttonContacts addTarget:self action:@selector(didClickButtonContacts) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonContacts];
//    [buttonContacts release];

    buttonFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonFacebook setFrame:CGRectMake(120, 60+160, 85, 100)];
    [buttonFacebook setImage:[UIImage imageNamed:@"graphic_facebook.png"] forState:UIControlStateNormal];
    [buttonFacebook addTarget:self action:@selector(didClickButtonFacebook) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonFacebook];
//    [buttonFacebook release];

    buttonName = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonName setFrame:CGRectMake(220, 60+160, 85, 100)];
    [buttonName setImage:[UIImage imageNamed:@"graphic_findbyname.png"] forState:UIControlStateNormal];
    [buttonName addTarget:self action:@selector(didClickButtonByName) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonName];
//    [buttonName release];
    
    //myPixBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_mypix.png"]];
    //[myPixBG setFrame:CGRectMake(0, 170+200, 320, 60)];
    //[self.view addSubview:myPixBG];
    
    buttonMyPix = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonMyPix setFrame:CGRectMake(15, 170+180, 288, 60)];
    [buttonMyPix setImage:[UIImage imageNamed:@"btn_mypix.png"] forState:UIControlStateNormal];
    [buttonMyPix addTarget:self action:@selector(didClickButtonMyPix) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonMyPix];
//    [buttonMyPix release];

    /*
    buttonStixAdded = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonStixAdded setFrame:CGRectMake(20, 225+160, 280, 50)];
    [buttonStixAdded addTarget:self action:@selector(didClickButtonStixAdded) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonStixAdded];
//    [buttonStixAdded release];
     */
    showMyButtons = YES;
}

-(void)toggleMyButtons:(BOOL)show {
    showMyButtons = show;
    [discoverLabel setHidden:!showMyButtons];
    [buttonContacts setHidden:!showMyButtons];
    [buttonFacebook setHidden:!showMyButtons];
    [buttonName setHidden:!showMyButtons];
    //[myPixBG setHidden:!showMyButtons];
    [buttonMyPix setHidden:!showMyButtons];
    //[buttonStixAdded setHidden:!showMyButtons];
    [bottomBackground setHidden:!showMyButtons];
    
    if (show) {
        // showing main view, so dismiss any other views
        //[bottomBackground setFrame:CGRectMake(0, 160, 320, 320)];
        [searchResultsController.view removeFromSuperview];
        if (searchBar) {
            [searchBar removeFromSuperview];
            [searchBar release];
            searchBar = nil;
        }
    }
}
-(void)toggleMyInfo:(BOOL)show {
    [photoButton setHidden:!show];
    [nameLabel setHidden:!show];
    [myFollowersCount setHidden:!show];
    [myFollowersLabel setHidden:!show];
    [myFollowingCount setHidden:!show];
    [myFollowingLabel setHidden:!show];
    [bgFollowers setHidden:!show];
    [bgFollowing setHidden:!show];
}

-(IBAction)buttonFollowingClicked:(id)sender {
    if (isSearching)
        return;
    
    NSLog(@"Following clicked!");
    
    isSearching = YES;
    resultType = RESULTS_FOLLOWING_LIST;
    [self startActivityIndicator];
    [self toggleMyButtons:NO];
    [self toggleMyInfo:NO];
 
    [self populateFollowingList];
}

-(IBAction)buttonFollowersClicked:(id)sender {
    if (isSearching)
        return;
    
    NSLog(@"Followers clicked!");
    
    isSearching = YES;
    resultType = RESULTS_FOLLOWERS_LIST;
    [self startActivityIndicator];
    [self toggleMyButtons:NO];
    [self toggleMyInfo:NO];
    
    [self populateFollowersList];
}

#pragma mark myProfile button responders

-(void)didClickButtonFacebook {
    if (isSearching)
        return;
    
    NSLog(@"Button find friends by Facebook!");
    isSearching = YES;
    resultType = RESULTS_SEARCH_FACEBOOK;
    [self startActivityIndicator];
    [self toggleMyButtons:NO];
    [self toggleMyInfo:NO];

    [self.delegate searchFriendsByFacebook];
}
-(void)didClickButtonContacts {
    if (isSearching)
        return;
    
    NSLog(@"Button find friends by Contacts!");
    isSearching = YES;
    resultType = RESULTS_SEARCH_CONTACTS;
    [self startActivityIndicator];
    [self toggleMyButtons:NO];
    [self toggleMyInfo:NO];

    [self populateContactSearchResults];
}
-(void)didClickButtonByName {
    if (isSearching) 
        return;
    
    NSLog(@"Button find friends by Name!");
    isSearching = YES; 
    resultType = RESULTS_SEARCH_NAME;
    [self toggleMyButtons:NO];
    [self toggleMyInfo:NO];
    
    [self populateNameSearchResults];
}
-(void)didClickButtonMyPix {
    NSLog(@"Button show my pix!");
    UserGalleryController * myGalleryController = [[UserGalleryController alloc] init];
    [myGalleryController setDelegate:self];
    [myGalleryController setUsername:[delegate getUsername]];
    [self.view addSubview:myGalleryController.view];
    [myGalleryController release];
}

-(void)didClickButtonStixAdded {
    NSLog(@"Button stix added!");
}
-(IBAction)didClickBackButton:(id)sender {
    if (showMyButtons) { // myButtons are showing so we are in basic profile view
        [self.delegate closeProfileView];
    }
    else {
        // reset views
        [self toggleMyButtons:YES];
        [self toggleMyInfo:YES];
        isSearching = NO;
    }
}

/***** modifying user photo *******/

- (void)changePhoto:(id)sender {
    [self.delegate didClickChangePhoto];
}

-(void)takeProfilePicture {
#if !TARGET_IPHONE_SIMULATOR
    UIImagePickerController * cam = [[UIImagePickerController alloc] init];
    cam.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    cam.allowsEditing = YES;
    cam.delegate = self;
    [self presentModalViewController:cam animated:YES];
#endif
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    //    [[picker parentViewController] dismissModalViewControllerAnimated: YES];    
    //    [picker release];    
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage * originalPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage * editedPhoto = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage * newPhoto; 
    //newPhoto = [UIImage imageNamed:@"friend1.png"];
    if (editedPhoto)
        newPhoto = editedPhoto;
    else
        newPhoto = originalPhoto; 
    
    NSLog(@"Finished picking image: dimensions %f %f", newPhoto.size.width, newPhoto.size.height);
    [self dismissModalViewControllerAnimated:TRUE];
    
    // scale down photo
	CGSize targetSize = CGSizeMake(90, 90);		
    UIImage * result = [newPhoto resizedImage:targetSize interpolationQuality:kCGInterpolationDefault];
    UIImage * rounded = [result roundedCornerImage:0 borderSize:2];
    
    // save to album
    UIImageWriteToSavedPhotosAlbum(rounded, nil, nil, nil); 
    
    //NSData * img = UIImageJPEGRepresentation(rounded, .8);
    NSData * img = UIImagePNGRepresentation(rounded);
    NSLog(@"Adding photo of size %f %f to user %@", rounded.size.width, rounded.size.height, [delegate getUsername]);
    [photoButton setImage:rounded forState:UIControlStateNormal];
    [self.delegate didChangeUserphoto:rounded];
    
    // add to kumulos
    [k addPhotoWithUsername:[delegate getUsername] andPhoto:img];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [picker release];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPhotoDidCompleteWithResult:(NSNumber*)affectedRows;
{
    NSLog(@"Added photo to username %@", [delegate getUsername]);
    
    // force friendView to update photo after we know it is in kumulos
    [self.delegate checkForUpdatePhotos];
}

/*** other actions ****/
/*
-(IBAction)closeInstructions:(id)sender;
{
    [buttonInstructions setHidden:YES];
}
*/
-(IBAction)adminStixButtonPressed:(id)sender
{
    [self.delegate didPressAdminEasterEgg:@"ProfileView"];
}

-(IBAction)feedbackButtonClicked:(id)sender {
    [self.delegate didClickFeedbackButton:@"Profile view"];
}

-(IBAction)inviteButtonClicked:(id)sender {
    [self.delegate didClickInviteButton];
}

/**** friendsViewControllerDelegate ****/
// badgeViewDelegate forwarded from friendsViewDelegate
- (void)checkForUpdatePhotos {[self.delegate checkForUpdatePhotos];}
-(NSMutableDictionary *)getUserPhotos {return [self.delegate getUserPhotos];}
//-(NSMutableSet*)getFriendsList {return [self.delegate getFriendsList];}
-(NSString*)getUsername {return [self.delegate getUsername];}
-(int)getStixCount:(NSString*)stixStringID {return [delegate getStixCount:stixStringID];}
-(int)getStixOrder:(NSString*)stixStringID;
{
    return [self.delegate getStixOrder:stixStringID];
}

-(void)didCreateBadgeView:(UIView*)newBadgeView {[self.delegate didCreateBadgeView:newBadgeView];}

-(void)didSendGiftStix:(NSString *)stixStringID toUsername:(NSString *)friendName {
    [self.delegate didSendGiftStix:stixStringID toUsername:friendName];
}

-(void)viewDidAppear:(BOOL)animated {
    if ([[delegate getUsername] isEqualToString:@"anonymous"]) {
        // needs to try logging in again
        [delegate needFacebookLogin];
    }
    if (1) //[delegate isLoggedIn])
    {
        NSLog(@"Profile view appearing with username: %@", [delegate getUsername]);
        //[k getUserWithUsername:[delegate getUsername]];
        [nameLabel setText:[delegate getUsername]];
        [photoButton setImage:[delegate getUserPhoto] forState:UIControlStateNormal];
        [photoButton setBackgroundColor:[UIColor blackColor]];
    }    
    
    [self updateFollowCounts];
    isSearching = NO;

    //[searchResultsController.view removeFromSuperview];
    [self toggleMyButtons:YES];
    [self toggleMyInfo:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {    
    //[loginScreenButton release];
    //loginScreenButton = nil;
    /*
    [stixCountButton release];
    stixCountButton = nil;
    [friendCountButton release];
    friendCountButton = nil;
     */
    [nameLabel release];
    nameLabel = nil;
    [photoButton release];
    photoButton = nil;
    
    [super viewDidUnload];
}


- (void)dealloc {
    [k release]; 
    //[loginScreenButton release];
    //loginScreenButton = nil;
    /*
    [stixCountButton release];
    stixCountButton = nil;
    [friendCountButton release];
    friendCountButton = nil;
     */
    [nameLabel release];
    nameLabel = nil;
    [photoButton release];
    photoButton = nil;
    [super dealloc];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

-(void)populateFollowCounts {
    myFollowingCount = [[OutlineLabel alloc] initWithFrame:CGRectMake(110, 100, 99, 40)];
    [myFollowingCount setTextColor:[UIColor colorWithRed:255/255 green:204/255.0 blue:102/255.0 alpha:1]];
    [myFollowingCount setOutlineColor:[UIColor blackColor]];    
    [myFollowingCount setTextAlignment:UITextAlignmentCenter];
    [myFollowingCount setFontSize:25];

    myFollowingLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(110, 133, 99, 15)];
    [myFollowingLabel setTextColor:[UIColor whiteColor]];
    [myFollowingLabel setOutlineColor:[UIColor blackColor]];  
    [myFollowingLabel setText:@"FOLLOWING"];
    [myFollowingLabel setTextAlignment:UITextAlignmentCenter];
    [myFollowingLabel setFontSize:10];

    myFollowersCount = [[OutlineLabel alloc] initWithFrame:CGRectMake(212, 100, 99, 40)];
    [myFollowersCount setTextColor:[UIColor colorWithRed:255/255 green:204/255.0 blue:102/255.0 alpha:1]];
    [myFollowersCount setOutlineColor:[UIColor blackColor]];        
    [myFollowersCount setTextAlignment:UITextAlignmentCenter];
    [myFollowersCount setFontSize:25];
    
    myFollowersLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(212, 133, 99, 15)];
    [myFollowersLabel setTextColor:[UIColor whiteColor]];
    [myFollowersLabel setOutlineColor:[UIColor blackColor]];    
    [myFollowersLabel setText:@"FOLLOWERS"];
    [myFollowersLabel setTextAlignment:UITextAlignmentCenter];
    [myFollowersLabel setFontSize:10];
    
    [self.view addSubview:myFollowingLabel];
    [self.view addSubview:myFollowersLabel];
    [self.view addSubview:myFollowingCount];
    [self.view addSubview:myFollowersCount];
    
    [self updateFollowCounts];
}

-(void)updateFollowCounts {
    // uses delegate functions
#if 0
    NSLog(@"UpdateFollowCounts: username %@", [delegate getUsername]);
    NSMutableSet * followerList = [delegate getFollowerList];
    NSMutableSet * followingList = [delegate getFollowingList];
    [myFollowersCount setText:[NSString stringWithFormat:@"%d", [followerList count]]];
    NSLog(@"Updating followers count to %d", [followerList count]);
    [myFollowingCount setText:[NSString stringWithFormat:@"%d", [followingList count]]];
    NSLog(@"Updating following count to %d", [followingList count]);
#else
    NSMutableSet * followingList = [self.delegate getFollowingList];
    int followingCount = [followingList count];
    [myFollowingCount setText:[NSString stringWithFormat:@"%d", followingCount]];
    //NSLog(@"FollowingList: %@", followingList);
    
    NSMutableSet * followerList = [self.delegate getFollowerList];
    int followerCount = [followerList count];
    [myFollowersCount setText:[NSString stringWithFormat:@"%d", followerCount]];
    NSLog(@"FollowerList: %@", followerList);
    //NSLog(@"UpdateFollowCount: updating following count to %d followercount to %d", followingCount, followerCount);
#endif
}

-(void)updatePixCount {
    [k getUserPixCountWithUsername:[delegate getUsername]];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPixCountDidCompleteWithResult:(NSNumber *)aggregateResult {
    [myPixCount setText:[NSString stringWithFormat:@"%d", [aggregateResult intValue]]];
    NSLog(@"Updating myPix count to %d", [aggregateResult intValue]);
}

-(void)updateStixCount {
    userHistoryCount = -1;
    userCommentCount = -1;
    [k getHistoryCountForUserWithUsername:[delegate getUsername]];
    [k getCommentCountForUserWithUsername:[delegate getUsername] andStixStringID:@"COMMENT"];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getHistoryCountForUserDidCompleteWithResult:(NSNumber *)aggregateResult {
    userHistoryCount = [aggregateResult intValue];
    if (userCommentCount != -1) {
        [myStixCount setText:[NSString stringWithFormat:@"%d", userHistoryCount - userCommentCount]];
        NSLog(@"User history count %d - user comment count %d = user stix count %d", userHistoryCount, userCommentCount, userHistoryCount-userCommentCount);
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getCommentCountForUserDidCompleteWithResult:(NSNumber *)aggregateResult {
    userCommentCount = [aggregateResult intValue];
    if (userHistoryCount != -1) {
        [myStixCount setText:[NSString stringWithFormat:@"%d", userHistoryCount - userCommentCount]];
        NSLog(@"User history count %d - user comment count %d = user stix count %d", userHistoryCount, userCommentCount, userHistoryCount-userCommentCount);
    }

}

-(void) initSearchResultLists {
    if (!searchFriendName) {
        searchFriendName = [[NSMutableArray alloc] init];
        searchFriendEmail = [[NSMutableArray alloc] init];
        searchFriendFacebookID = [[NSMutableArray alloc] init];
        searchFriendIsStix = [[NSMutableArray alloc] init]; // whether they are using Stix already
    }
    [searchFriendName removeAllObjects];
    [searchFriendEmail removeAllObjects];
    [searchFriendFacebookID removeAllObjects];
    [searchFriendIsStix removeAllObjects];
}

/*** results of facebook search from delegate ***/
-(void)populateFacebookSearchResults:(NSArray*)facebookFriendArray {
    if (resultType != RESULTS_SEARCH_FACEBOOK)
        return;
    
    [facebookFriendArray retain];

    [self initSearchResultLists];

    NSMutableArray * searchFriendNotStixName = [[NSMutableArray alloc] init];
    NSMutableArray * searchFriendNotStixID = [[NSMutableArray alloc] init];
    NSMutableArray * searchFriendNotStix = [[NSMutableArray alloc] init];
    
    NSMutableArray * allFacebookIDs = [self.delegate getAllUserFacebookIDs];
    for (NSMutableDictionary * d in facebookFriendArray) {
        NSString * fbID = [d valueForKey:@"id"];
        NSString * fbName = [d valueForKey:@"name"];
        //NSLog(@"fbID: %@ fbName: %@", fbID, fbName);
        if ([allFacebookIDs containsObject:fbID]) {
            [searchFriendName addObject:fbName];
            [searchFriendFacebookID addObject:fbID];
            [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
        } else {
            [searchFriendNotStixName addObject:fbName];
            [searchFriendNotStixID addObject:fbID];
            [searchFriendNotStix addObject:[NSNumber numberWithBool:NO]];
        }
    }

    [searchFriendName addObjectsFromArray:searchFriendNotStixName];
    [searchFriendFacebookID addObjectsFromArray:searchFriendNotStixID];
    [searchFriendIsStix addObjectsFromArray:searchFriendNotStix];
    [searchFriendNotStix release];
    [searchFriendNotStixID release];
    
    [self stopActivityIndicator];
    if (isSearching) { 
        // still searching - display results
        // if not searching, we've returned to the previous page so we don't want to display results
        if (searchResultsController) {
            [searchResultsController.view removeFromSuperview];
            [searchResultsController release];
        }
        searchResultsController = [[FriendSearchResultsController alloc] init];
        [searchResultsController.view setFrame:CGRectMake(0, 44, 320, 480-64)];
        [searchResultsController setDelegate:self];
        searchResultsController.tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:searchResultsController.view];
        isSearching = NO;
    }
}

-(void)populateContactSearchResults {
    if (resultType != RESULTS_SEARCH_CONTACTS)
        return;

    NSMutableArray * contactResults = [[self collectFriendsFromContactList] retain];
    
    [self initSearchResultLists];
    
    NSMutableDictionary * allUsers = [self.delegate getAllUsers];
    NSMutableArray * allUserEmails = [self.delegate getAllUserEmails];
    NSMutableArray * allUserNames = [self.delegate getAllUserNames];
    for (NSMutableDictionary * d in contactResults) {
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
            [searchFriendFacebookID addObject:cID];
            [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]]; // only displays members in contact who are already on Stix because we have no facebookID to contact them
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
                    [searchFriendFacebookID addObject:cID];
                    [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]]; // only displays members in contact who are already on Stix because we have no facebookID to contact them
                    break;
                }        
            }
        }
    }
    [contactResults release];
    
    [self stopActivityIndicator];
    if (isSearching) { 
        // still searching - display results
        // if not searching, we've returned to the previous page so we don't want to display results
        if (searchResultsController != nil) {
            [searchResultsController.view removeFromSuperview];
            [searchResultsController release];        
        }
        searchResultsController = [[FriendSearchResultsController alloc] init];
        [searchResultsController.view setFrame:CGRectMake(0, 44, 320, 480-64)];
        [searchResultsController setDelegate:self];
        searchResultsController.tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:searchResultsController.view];
        isSearching = NO;
    }
}

#pragma mark FriendSearchResultsDelegate

-(NSString*)getUsernameForUser:(int)index {
    return [searchFriendName objectAtIndex:index];
}
-(UIImage*)getUserPhotoForUser:(int)index {
    NSString * friendName = [searchFriendName objectAtIndex:index];
    UIImage * userPhoto = [UIImage imageWithData:[[delegate getUserPhotos] objectForKey:friendName]];
    return userPhoto;
}
-(NSString*)getUserEmailForUser:(int)index {
    //NSString * friendName = [searchFriendName objectAtIndex:index];
    return @""; //[[[delegate getAllUsers] objectForKey:friendName] objectForKey:@"email"];
}
-(NSString*)getFacebookIDForUser:(int)index {
    return [searchFriendFacebookID objectAtIndex:index];
}
-(int)getFollowingUserStatus:(int)index {
    // if Facebook friend is not on Stix, return -1
    //NSMutableArray * allFacebookIDs = [self.delegate getAllUserFacebookIDs];
    //if (![allFacebookIDs containsObject:[searchFriendFacebookID objectAtIndex:index]])
    if (![[searchFriendIsStix objectAtIndex:index] boolValue])
        return -1;
    
    NSString * friendName = [searchFriendName objectAtIndex:index];
    return [[delegate getFollowingList] containsObject:friendName];
}

-(int)getNumOfUsers {
    return [searchFriendName count];
}

-(void)didClickAddFriendButton:(int)index {
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
        NSString * fbID = [self getFacebookIDForUser:index];
        [delegate didClickInviteButtonByFacebook:username withFacebookID:fbID];
    }
    [[searchResultsController tableView] reloadData];
}

#pragma mark ABAddressBook functions
-(NSMutableArray*)collectFriendsFromContactList
{
    NSMutableArray * myAddressBook = [[NSMutableArray alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people  = ABAddressBookCopyArrayOfAllPeople(addressBook);
    for(int i = 0;i<ABAddressBookGetPersonCount(addressBook);i++)
    {
        NSMutableDictionary *myContact = [[NSMutableDictionary alloc] init];
        
        // Get First name, Last name, Prefix, Suffix, Job title 
        ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
        NSString *firstName = (NSString *)ABRecordCopyValue(ref,kABPersonFirstNameProperty);
        NSString *lastName = (NSString *)ABRecordCopyValue(ref,kABPersonLastNameProperty);
        //NSString *email = (NSString *)ABRecordCopyValue(ref, kABPersonEmailProperty);

        //[myContact setObject:firstName forKey:@"firstName"];
        //[myContact setObject:lastName forKey:@"lastName"];
        //[myAddressBook setObject:email forKey:@"email"];
        if (firstName == nil) 
            [myContact setObject:[NSString stringWithFormat:@"%@", firstName] forKey:@"name"];
        else if (lastName == nil)
            [myContact setObject:[NSString stringWithFormat:@"%@", firstName] forKey:@"name"];
        else
            [myContact setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        
        ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
        NSMutableArray *arEmail = [[NSMutableArray alloc] init];
        for(CFIndex idx = 0; idx < ABMultiValueGetCount(emails); idx++)
        {
            CFStringRef emailRef = ABMultiValueCopyValueAtIndex(emails, idx);
            NSString *strLbl = (NSString*) ABAddressBookCopyLocalizedLabel (ABMultiValueCopyLabelAtIndex (emails, idx));
            NSString *strEmail_old = (NSString*)emailRef;
            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
            [temp setObject:strEmail_old forKey:@"strEmail_old"];
            [temp setObject:strLbl forKey:@"strLbl"];
            [arEmail addObject:temp];
            [temp release];
            [strLbl release];
            [strEmail_old release];

            //NSLog(@"Contact list: %@ %@ email %@", firstName, lastName, strEmail_old);
        }
        if (ABMultiValueGetCount(emails) == 0) {
            //NSLog(@"Contact list: %@ %@ email NONE", firstName, lastName);
        }
        [myContact setObject:arEmail forKey:@"email"];
        [myContact setObject:@"" forKey:@"id"];
        [arEmail release];
        [myAddressBook addObject:myContact];
        [myContact release];
        [firstName release];
        [lastName release];
    }
    return [myAddressBook autorelease];;
}

#pragma mark search by name
-(void)populateNameSearchResults {
    if (resultType != RESULTS_SEARCH_NAME)
        return;

    [self initSearchResultLists];

    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
    [searchBar setDelegate:self];
    [searchBar setBarStyle:UIBarStyleBlack];
    //[bottomBackground addSubview:searchBar];
    [self.view addSubview:searchBar];
    if (searchResultsController != nil) {
        [searchResultsController.view removeFromSuperview];
        [searchResultsController release];        
    }
    searchResultsController = [[FriendSearchResultsController alloc] init];
    [searchResultsController.view setFrame:CGRectMake(0, 88, 320, 480-108)];
    [searchResultsController setDelegate:self];
    searchResultsController.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:searchResultsController.view];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    if (resultType != RESULTS_SEARCH_NAME)
        return;
    [self initSearchResultLists];

    [searchBar resignFirstResponder];
    
    [searchResultsController.tableView reloadData];
    isSearching = YES;
    [self startActivityIndicator];
    NSLog(@"Query: %@", [_searchBar text]);
    NSArray *query = [[_searchBar text] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   // NSMutableArray * allUserEmails = [self.delegate getAllUserEmails];
    NSMutableArray * allUserNames = [self.delegate getAllUserNames];
    NSMutableArray * allUserFacebookIDs = [self.delegate getAllUserFacebookIDs];

    NSLog(@"Searching for facebookID");
    // see if searching for facebook ID - yea right
    BOOL isFacebookID = [allUserFacebookIDs containsObject:[_searchBar text]];
    if (isFacebookID) {
        int index = [allUserFacebookIDs indexOfObject:[_searchBar text]];
        [searchFriendName addObject:[allUserNames objectAtIndex:index]];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
        [searchResultsController.tableView reloadData];
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
        [searchFriendName addObject:name];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
    }
    [searchResultsController.tableView reloadData];
    [self stopActivityIndicator];
    isSearching = NO;
    return;
}

-(void)populateFollowingList {
    [self initSearchResultLists];
    
    NSLog(@"Getting follows list from kumulos for username: %@", [delegate getUsername]);
    if (searchResultsController) {
        [searchResultsController.view removeFromSuperview];
        [searchResultsController release];
    }
    searchResultsController = [[FriendSearchResultsController alloc] init];
    [searchResultsController.view setFrame:CGRectMake(0, 44, 320, 480-64)];
    [searchResultsController setDelegate:self];
    searchResultsController.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:searchResultsController.view];
    
    if (resultType != RESULTS_FOLLOWING_LIST)
        return;
    
    NSMutableSet * followingSet = [delegate getFollowingList];
    for (NSString * following in followingSet) {
        [searchFriendName addObject:following];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
    }
    [searchResultsController.tableView reloadData];
    [self stopActivityIndicator];
    isSearching = NO;
}

-(void)populateFollowersList {
    NSLog(@"Getting follower list from kumulos for username: %@", [delegate getUsername]);
    
    [self initSearchResultLists];

    if (searchResultsController) {
        [searchResultsController.view removeFromSuperview];
        [searchResultsController release];
    }
    searchResultsController = [[FriendSearchResultsController alloc] init];
    [searchResultsController.view setFrame:CGRectMake(0, 44, 320, 480-64)];
    [searchResultsController setDelegate:self];
    searchResultsController.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:searchResultsController.view];
    
    if (resultType != RESULTS_FOLLOWERS_LIST)
        return;
    
    NSMutableSet * followersSet = [delegate getFollowerList];
    for (NSString * follower in followersSet) {
        [searchFriendName addObject:follower];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
    }
    [searchResultsController.tableView reloadData];
    [self stopActivityIndicator];
    isSearching = NO;
}

#pragma UserGalleryDelegate
-(void)uploadImage:(NSData*)png withShareMethod:(int)buttonIndex
{
    [self.delegate uploadImage:png withShareMethod:buttonIndex];
}
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID {
    [self.delegate didAddCommentWithTagID:tagID andUsername:name andComment:comment andStixStringID:stixStringID];
}
-(UIImage*)getUserPhotoForGallery {return [self.delegate getUserPhoto];}

/*** deprecated functions for old profile view ***/
/*
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Button index: %d", buttonIndex);    
    // 0 = cancel
    // 1 = logout
    if (buttonIndex != [alertView cancelButtonIndex])
        [self showLogoutScreen:nil];
}

// ***** logging in with a username **** 

 -(void)loginWithUsername:(NSString *)name {
 // called by delegate, first time when no data has been loaded from kumulos
 NSLog(@"Trying to login as %@", name);
 if (k == nil) {
 k = [[Kumulos alloc]init];
 [k setDelegate:self];    
 }
 [k getUserWithUsername:name];
 }
 
 // getUserWithUsername in ProfileViewController is a login operation that populates the profile with all the new user's info
 - (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserDidCompleteWithResult:(NSArray*)theResults {
 if ([theResults count] > 0)
 {
 //for (NSMutableDictionary * d in theResults) {
 NSMutableDictionary * d = [theResults objectAtIndex:0];
 NSString * name = [d valueForKey:@"username"];
 //[self didSelectUsername:name withResults:theResults];
 [self.nameLabel setText:name];
 UIImage * newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
 if (newPhoto) {
 [photoButton setImage:newPhoto forState:UIControlStateNormal];
 //NSLog(@"User %@ has photo of dimensions %f %f\n", name, newPhoto.size.width, newPhoto.size.height);
 }
 else
 {
 newPhoto = [[UIImage imageNamed:@"graphic_nouser.png"] retain];
 [photoButton setImage:newPhoto forState:UIControlStateNormal];
 [photoButton setTitle:@"" forState:UIControlStateNormal]; 
 }
 // badge count array
 NSMutableDictionary * stix;
 @try {
 stix = [KumulosData dataToDictionary:[d valueForKey:@"stix"]]; // returns a dictionary whose one element is a dictionary of stix
 }
 @catch (NSException* exception) { 
 NSLog(@"Error! Exception caught while trying to load stix! Error %@", [exception reason]);
 stix = [[BadgeView generateDefaultStix] retain];
 }
 NSLog(@"ProfileViewController: DidLoginWithUsername: %@", name);
 // total Pix count
 int totalTags = [[d valueForKey:@"totalTags"] intValue];
 int bux = [[d valueForKey:@"bux"] intValue];
 
 NSMutableDictionary * auxiliaryData = [[NSMutableDictionary alloc] init];
 NSMutableDictionary * stixOrder = nil;
 //NSMutableSet * friendsList = nil;
 int ret = [KumulosData extractAuxiliaryDataFromUserData:d intoAuxiliaryData:auxiliaryData];
 if (ret == 0) {
 stixOrder = [auxiliaryData objectForKey:@"stixOrder"];
 //friendsList = [auxiliaryData objectForKey:@"friendsList"];
 }
 [delegate didLoginWithUsername:name andPhoto:newPhoto andStix:stix andTotalTags:totalTags andBuxCount:(int)bux andStixOrder:stixOrder];
 [newPhoto release];
 }
 else if ([theResults count] == 0)
 {
 [delegate didLogout]; // force logout
 }
 }
 
 -(IBAction) didClickLogoutButton:(id)sender {
 #if 0
 UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want to log out of account %@?", [delegate getUsername]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Log me out!", nil];
 [actionSheet showInView:self.view];
 [actionSheet release];
 #else
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout"
 message:@"Do you want to log out?"
 delegate:self
 cancelButtonTitle:@"Cancel"
 otherButtonTitles:@"Log me out!", nil];    
 [alert show];
 [alert release];
 #endif
 }

-(IBAction) showLogoutScreen:(id)sender {
    [delegate didLogout];
}
 */

@end
