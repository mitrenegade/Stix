//
//  SearchByNameController.m
//  Stixx
//
//  Created by Bobby Ren on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchByNameController.h"
#import <AddressBook/AddressBook.h>
#import "QuartzCore/QuartzCore.h"
#define TOP_LABEL_TAG 1001
#define BOTTOM_LABEL_TAG 1002
#define ROW_HEIGHT 70

@interface SearchByNameController ()

@end

@implementation SearchByNameController

@synthesize delegate;
@synthesize searchBar, tableView;

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

    [searchBar setBarStyle:UIBarStyleBlack];
    tableView.showsVerticalScrollIndicator = NO;
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
-(void) initSearchResultLists {
    if (!searchFriendName) {
        searchFriendName = [[NSMutableArray alloc] init];
        searchFriendEmail = [[NSMutableArray alloc] init];
        searchFriendID = [[NSMutableArray alloc] init];
        searchFriendIsStix = [[NSMutableArray alloc] init]; // whether they are using Stix already
    }
    [searchFriendName removeAllObjects];
    [searchFriendEmail removeAllObjects];
    [searchFriendID removeAllObjects];
    [searchFriendIsStix removeAllObjects];
}

-(void)hideSearchBar {
    [searchBar setHidden:YES];
    [searchResultsController.view setFrame:CGRectMake(0, 44, 320, 480)];
}
-(void)showSearchBar {
    [searchBar setHidden:NO];
    [searchResultsController.view setFrame:CGRectMake(0, 88, 320, 480-108)];
    [searchBar setPlaceholder:@"Search by name, email, etc"];
}
#pragma mark search by name
-(void)populateNameSearchResults {
    
    [self initSearchResultLists];
    [self showSearchBar];
    [searchBar becomeFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    [self initSearchResultLists];
    
    [searchBar resignFirstResponder];
    
    [searchResultsController.tableView reloadData];
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
        if ([name isEqualToString:[delegate getUsername]])
            continue;
        [searchFriendName addObject:name];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
    }
    [searchResultsController.tableView reloadData];
    //[self stopActivityIndicator];
    return;
}

/*** results of facebook search from delegate ***/

-(void)populateFacebookSearchResults:(NSMutableArray*)allFacebookFriendNames andFacebookStrings:(NSMutableArray*)allFacebookFriendStrings {
    // second part is for the facebook friend search results controller
    if (resultType != RESULTS_SEARCH_FACEBOOK)
        return;    
    
    [self initSearchResultLists];
    
    NSMutableArray * searchFriendNotStixName = [[NSMutableArray alloc] init];
    NSMutableArray * searchFriendNotStixID = [[NSMutableArray alloc] init];
    NSMutableArray * searchFriendNotStix = [[NSMutableArray alloc] init];
    
    //    for (NSMutableDictionary * d in facebookFriendArray) {
    NSMutableArray * allFacebookStrings = [delegate getAllUserFacebookStrings];
    for (int i=0; i<[allFacebookFriendNames count]; i++) {
        NSString * _facebookString = [allFacebookFriendStrings objectAtIndex:i];
        NSString * _facebookName = [allFacebookFriendNames objectAtIndex:i];
        //NSLog(@"i %d Facebook name: %@ facebook string: %@", i, _facebookName, _facebookString);
        if ([allFacebookStrings containsObject:_facebookString]) {
            [searchFriendName addObject:_facebookName];
            [searchFriendID addObject:_facebookString];
            [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
        } else {
            [searchFriendNotStixName addObject:_facebookName];
            [searchFriendNotStixID addObject:_facebookString];
            [searchFriendNotStix addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    NSLog(@"Friends on stix %d friends not on stix %d", [searchFriendName count], [searchFriendNotStixName count]);
    [searchFriendName addObjectsFromArray:searchFriendNotStixName];
    [searchFriendID addObjectsFromArray:searchFriendNotStixID];
    [searchFriendIsStix addObjectsFromArray:searchFriendNotStix];

    [tableView reloadData];
}

-(void)populateContactSearchResults {
    if (resultType != RESULTS_SEARCH_CONTACTS)
        return;
    
    NSMutableArray * contactResults = [self collectFriendsFromContactList];
    
    [self initSearchResultLists];
    
    NSMutableDictionary * allUsers = [delegate getAllUsers];
    NSMutableArray * allUserEmails = [delegate getAllUserEmails];
    NSMutableArray * allUserNames = [delegate getAllUserNames];
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
    
    //[self stopActivityIndicator];
    [tableView reloadData];
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
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(ref,kABPersonFirstNameProperty);
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(ref,kABPersonLastNameProperty);
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
            
            //NSLog(@"Contact list: %@ %@ email %@", firstName, lastName, strEmail_old);
        }
        if (ABMultiValueGetCount(emails) == 0) {
            //NSLog(@"Contact list: %@ %@ email NONE", firstName, lastName);
        }
        [myContact setObject:arEmail forKey:@"email"];
        [myContact setObject:@"" forKey:@"id"];
        [myAddressBook addObject:myContact];
        CFRelease(emails);
    }
    CFRelease(people);
    CFRelease(addressBook);
    return myAddressBook;
}

#pragma mark tableViewdelegate

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numRows = [searchFriendName count];
    NSLog(@"FriendSearchResults: numRows %d", numRows);
    return numRows;
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
    NSString * username = [searchFriendName objectAtIndex:y]; //[delegate getUsernameForUser: y];
    [topLabel setText:username];
    [bottomLabel setText:[searchFriendEmail objectAtIndex:y]]; //[self.delegate getUserEmailForUser: y]];
    
    for (UIView * subview in cell.imageView.subviews) {
        [subview removeFromSuperview];
    }
    UIImage * userPhoto = [delegate getUserPhotoForUsername:username];
    //cell.imageView = userPhoto; //addSubview:userPhoto];
    [cell.imageView setImage:userPhoto];
    
    /*
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
     */

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
    //[delegate didClickAddFriendButton:sender.tag];
    NSString * name = [searchFriendName objectAtIndex:sender.tag];
    NSLog(@"Clicked add friend button %d: adding %@!", sender.tag, name);
    //[delegate addFriendFromList:sender.tag];
}
-(void)didRemoveFriend:(UIButton*)sender {
    NSLog(@"Clicked remove friend button %d!", sender.tag);
    //NSString * name = [delegate getUsernameForUser:sender.tag];
    //[delegate didClickAddFriendButton:sender.tag];
    //[delegate addFriendFromList:sender.tag];
}
-(void)didInviteFriend:(UIButton*)sender {
    NSLog(@"Clicked invite friend button %d!", sender.tag);
    //NSString * name = [delegate getUsernameForUser:sender.tag];
    //[delegate didClickAddFriendButton:sender.tag];
    //[delegate addFriendFromList:sender.tag];
}

@end
