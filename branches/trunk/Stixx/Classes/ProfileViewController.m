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
    discoverLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [discoverLabel setImage:[UIImage imageNamed:@"txt_discover.png"] forState:UIControlStateNormal];
    [discoverLabel setFrame:CGRectMake(0, 20, 320, 25)];
    [bottomBackground addSubview:discoverLabel];
    
    buttonContacts = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonContacts setFrame:CGRectMake(20, 60, 85, 100)];
    [buttonContacts setImage:[UIImage imageNamed:@"graphic_contacts.png"] forState:UIControlStateNormal];
    [buttonContacts addTarget:self action:@selector(didClickButtonContacts) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:buttonContacts];
//    [buttonContacts release];

    buttonFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonFacebook setFrame:CGRectMake(120, 60, 85, 100)];
    [buttonFacebook setImage:[UIImage imageNamed:@"graphic_facebook.png"] forState:UIControlStateNormal];
    [buttonFacebook addTarget:self action:@selector(didClickButtonFacebook) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:buttonFacebook];
//    [buttonFacebook release];

    buttonName = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonName setFrame:CGRectMake(220, 60, 85, 100)];
    [buttonName setImage:[UIImage imageNamed:@"graphic_findbyname.png"] forState:UIControlStateNormal];
    [buttonName addTarget:self action:@selector(didClickButtonByName) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:buttonName];
//    [buttonName release];
    
    myPixBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_pixadded.png"]];
    [myPixBG setFrame:CGRectMake(16, 170, 285, 106)];
    [bottomBackground addSubview:myPixBG];
    
    buttonMyPix = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonMyPix setFrame:CGRectMake(20, 170, 280, 50)];
    [buttonMyPix addTarget:self action:@selector(didClickButtonMyPix) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:buttonMyPix];
//    [buttonMyPix release];

    buttonStixAdded = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonStixAdded setFrame:CGRectMake(20, 225, 280, 50)];
    [buttonStixAdded addTarget:self action:@selector(didClickButtonStixAdded) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:buttonStixAdded];
//    [buttonStixAdded release];
    showMyButtons = YES;
}

-(void)toggleMyButtons:(BOOL)show {
    showMyButtons = show;
    [discoverLabel setHidden:!showMyButtons];
    [buttonContacts setHidden:!showMyButtons];
    [buttonFacebook setHidden:!showMyButtons];
    [buttonName setHidden:!showMyButtons];
    [myPixBG setHidden:!showMyButtons];
    [buttonMyPix setHidden:!showMyButtons];
    [buttonStixAdded setHidden:!showMyButtons];
    
    if (show) {
        // showing main view, so dismiss any other views
        [searchResultsController.view removeFromSuperview];
    }
}

#pragma mark myProfile button responders

-(void)didClickButtonFacebook {
    NSLog(@"Button find friends by Facebook!");
    [self.delegate searchFriendsByFacebook];
    [self startActivityIndicator];
}
-(void)didClickButtonContacts {
    NSLog(@"Button find friends by Contacts!");
    /*
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Search by Contacts"];
    [alert setMessage:@"Search for friends by contact list coming soon."];
    [alert show];
    [alert release];
     */
    [self populateContactSearchResults];
}
-(void)didClickButtonByName {
    NSLog(@"Button find friends by Name!");
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Search by Name"];
    [alert setMessage:@"Search for friends by name coming soon."];
    [alert show];
    [alert release];
}
-(void)didClickButtonMyPix {
    NSLog(@"Button show my pix!");    
}
-(void)didClickButtonStixAdded {
    NSLog(@"Button stix added!");
}
-(IBAction)didClickBackButton:(id)sender {
    [self.delegate closeProfileView];
    
    // reset views
    [self toggleMyButtons:YES];
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

/*
- (IBAction)findFriendsClicked:(id)sender {
    FriendSearchViewController * friendSearchViewController = [[FriendSearchViewController alloc] init];
    [self.view addSubview:friendSearchViewController.view];
}
 */

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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"Set config namelabel as %@", username);
    
    if (1) //[delegate isLoggedIn])
    {
        NSLog(@"Profile view appearing with username: %@", [delegate getUsername]);
        //[k getUserWithUsername:[delegate getUsername]];
        [nameLabel setText:[delegate getUsername]];
        [photoButton setImage:[delegate getUserPhoto] forState:UIControlStateNormal];
        [photoButton setBackgroundColor:[UIColor blackColor]];
    }    
    
    [self updateFollowCounts];
    //[self updatePixCount];
    [self updateFollowCount];
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
    [myFollowingCount setTextColor:[UIColor yellowColor]];
    [myFollowingCount setOutlineColor:[UIColor blackColor]];    
    [myFollowingCount setTextAlignment:UITextAlignmentCenter];
    [myFollowingCount setFontSize:25];

    myFollowingLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(110, 133, 99, 15)];
    [myFollowingLabel setTextColor:[UIColor whiteColor]];
    [myFollowingLabel setOutlineColor:[UIColor blackColor]];  
    [myFollowingLabel setText:@"FOLLOWING"];
    [myFollowingLabel setTextAlignment:UITextAlignmentCenter];
    [myFollowingLabel setFontSize:8];

    myFollowersCount = [[OutlineLabel alloc] initWithFrame:CGRectMake(212, 100, 99, 40)];
    [myFollowersCount setTextColor:[UIColor yellowColor]];
    [myFollowersCount setOutlineColor:[UIColor blackColor]];        
    [myFollowersCount setTextAlignment:UITextAlignmentCenter];
    [myFollowersCount setFontSize:25];
    
    myFollowersLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(212, 133, 99, 15)];
    [myFollowersLabel setTextColor:[UIColor whiteColor]];
    [myFollowersLabel setOutlineColor:[UIColor blackColor]];    
    [myFollowersLabel setText:@"FOLLOWERS"];
    [myFollowersLabel setTextAlignment:UITextAlignmentCenter];
    [myFollowersLabel setFontSize:8];
    
    [self.view addSubview:myFollowingLabel];
    [self.view addSubview:myFollowersLabel];
    [self.view addSubview:myFollowingCount];
    [self.view addSubview:myFollowersCount];
    
    [self updateFollowCounts];
}

-(void)updateFollowCounts {
    [k getFollowListWithUsername:[delegate getUsername]];
    [k getFollowersOfUserWithFollowsUser:[delegate getUsername]];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFollowersOfUserDidCompleteWithResult:(NSArray *)theResults {
    [myFollowersCount setText:[NSString stringWithFormat:@"%d", [theResults count]]];
    NSLog(@"Updating followers count to %d", [theResults count]);
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFollowListDidCompleteWithResult:(NSArray *)theResults {
    [myFollowingCount setText:[NSString stringWithFormat:@"%d", [theResults count]]];
    NSLog(@"Updating following count to %d", [theResults count]);
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

-(void)updateFollowCount {
    NSMutableSet * followingList = [self.delegate getFollowingList];
    int followingCount = [followingList count];
    [myFollowingCount setText:[NSString stringWithFormat:@"%d", followingCount]];
    NSMutableSet * followerList = [self.delegate getFollowerList];
    int followerCount = [followerList count];
    [myFollowersCount setText:[NSString stringWithFormat:@"%d", followerCount]];
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

/*** results of facebook search from delegate ***/
-(void)populateFacebookSearchResults:(NSArray*)facebookFriendArray {
    [facebookFriendArray retain];
    
    if (searchFriendName) {
        [searchFriendName release];
    }
    if (searchFriendEmail) {
        [searchFriendEmail release];
    }
    if (searchFriendFacebookID) {
        [searchFriendFacebookID release];
    }
    searchFriendName = [[NSMutableArray alloc] init];
    searchFriendEmail = [[NSMutableArray alloc] init];
    searchFriendFacebookID = [[NSMutableArray alloc] init];
    
    //NSMutableDictionary * allUsers = [self.delegate getAllUsers];
    NSMutableArray * allFacebookIDs = [self.delegate getAllUserFacebookIDs];
    for (NSMutableDictionary * d in facebookFriendArray) {
        NSString * fbID = [d valueForKey:@"id"];
        NSString * fbName = [d valueForKey:@"name"];
        //NSLog(@"fbID: %@ fbName: %@", fbID, fbName);
        /*
        if ([fbID intValue] == 705531)
        {
            NSLog(@"Here!");
            for (NSNumber * n in allFacebookIDs) {
                NSLog(@"Number: %d", [n intValue]);
            }
        }
         */
        if ([allFacebookIDs containsObject:fbID]) {
            //NSLog(@"Friends from facebook found as users: id %@ name %@", fbID, fbName);
            [searchFriendName addObject:fbName];
//            [searchFriendEmail addObject:fbEmail]; 
            [searchFriendFacebookID addObject:fbID];
        }        
    }

    if (searchResultsController)
        [searchResultsController release];
    searchResultsController = [[FriendSearchResultsController alloc] init];
    [searchResultsController.view setFrame:CGRectMake(0, 10, 320, 300)];
    [searchResultsController setDelegate:self];
    [bottomBackground addSubview:searchResultsController.view];
    [self toggleMyButtons:NO];
    [self stopActivityIndicator];
}

-(void)populateContactSearchResults {
    NSMutableArray * contactResults = [[self collectFriendsFromContactList] retain];
    
    if (searchFriendName) {
        [searchFriendName release];
    }
    if (searchFriendEmail) {
        [searchFriendEmail release];
    }
    if (searchFriendFacebookID) {
        [searchFriendFacebookID release];
    }
    searchFriendName = [[NSMutableArray alloc] init];
    searchFriendEmail = [[NSMutableArray alloc] init];
    searchFriendFacebookID = [[NSMutableArray alloc] init];
    
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
                    break;
                }        
            }
        }
    }
    [contactResults release];
    
    if (searchResultsController != nil)
        [searchResultsController release];
    searchResultsController = [[FriendSearchResultsController alloc] init];
    [searchResultsController.view setFrame:CGRectMake(0, 10, 320, 300)];
    [searchResultsController setDelegate:self];
    [bottomBackground addSubview:searchResultsController.view];
    [self toggleMyButtons:NO];
    [self stopActivityIndicator];
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
    NSString * friendName = [searchFriendName objectAtIndex:index];
    return [[[delegate getAllUsers] objectForKey:friendName] objectForKey:@"email"];
}
-(NSString*)getFacebookIDForUser:(int)index {
    return [searchFriendFacebookID objectAtIndex:index];
}
-(BOOL)isFollowingUser:(int)index {
    NSString * friendName = [searchFriendName objectAtIndex:index];
    return [[delegate getFollowingList] containsObject:friendName];
}

-(int)getNumOfUsers {
    return [searchFriendName count];
}

-(void)didClickAddFriendButton:(int)index {
    NSString * username = [self getUsernameForUser:index];
    //NSMutableSet * friendsList = [self.delegate getFriendsList];
    if ([self isFollowingUser:index]) { 
        [delegate setFollowing:username toState:NO];
    }
    else
    {
        [delegate setFollowing:username toState:YES];
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
