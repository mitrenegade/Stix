//
//  UserProfileViewController.m
//
//  Created by Administrator on 7/11/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "UserProfileViewController.h"

@implementation UserProfileViewController

@synthesize delegate;
@synthesize k;
@synthesize username;
@synthesize activityIndicator;
@synthesize bgFollowers, bgFollowing;
@synthesize myPixCount, myPixLabel, myStixCount, myStixLabel;
@synthesize myFollowersCount, myFollowersLabel, myFollowingCount, myFollowingLabel;
@synthesize photoButton, nameLabel, buttonAddFriend;
@synthesize pixTableController;
@synthesize headerView;
@synthesize detailController;
@synthesize lastUsername;
@synthesize searchResultsController;
-(id)init
{
	self = [super initWithNibName:@"UserProfileViewController" bundle:nil];
	
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
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 9, 25, 25)];
    [self.view addSubview:activityIndicator];

    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    [headerView setBackgroundColor:[UIColor clearColor]];

    // user gallery
    allTagIDs = [[NSMutableArray alloc] init];
    allTags = [[NSMutableDictionary alloc] init];
    contentViews = [[NSMutableDictionary alloc] init];
    
    nameLabel = [[UILabel alloc] init];
    photoButton = [[UIButton alloc] init];
    buttonAddFriend = [[UIButton alloc] init];//buttonWithType:UIButtonTypeCustom];
    bgFollowing = [UIButton buttonWithType:UIButtonTypeCustom];
    [bgFollowing addTarget:self action:@selector(buttonFollowingClicked) forControlEvents:UIControlEventTouchUpInside];
    bgFollowers = [UIButton buttonWithType:UIButtonTypeCustom];
    [bgFollowers addTarget:self action:@selector(buttonFollowersClicked) forControlEvents:UIControlEventTouchUpInside];

    myFollowingCount = [[OutlineLabel alloc] initWithFrame:CGRectMake(105, 100-44, 99, 40)];
    myFollowingLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(105, 133-44, 99, 15)];
    myFollowersCount = [[OutlineLabel alloc] initWithFrame:CGRectMake(210, 100-44, 99, 40)];
    myFollowersLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(210, 133-44, 99, 15)];

    /*
    myPixCount = [[OutlineLabel alloc] initWithFrame:CGRectMake(10, 160-44, 50, 35)];
    myPixLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(60, 170-44, 20, 20)];
    myStixCount = [[OutlineLabel alloc] initWithFrame:CGRectMake(80, 160-44, 50, 35)];
    myStixLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(130, 170-44, 25, 20)];
     */
    searchResultsController = nil;
    allFollowers = [[NSMutableSet alloc] init];
    allFollowing = [[NSMutableSet alloc] init];

    [self.headerView addSubview:nameLabel];
    [self.headerView addSubview:photoButton];
    [self.headerView addSubview:buttonAddFriend];
    
    [self.headerView addSubview:bgFollowing];
    [self.headerView addSubview:bgFollowers];    
    
    [self.headerView addSubview:myFollowingLabel];
    [self.headerView addSubview:myFollowersLabel];
    [self.headerView addSubview:myFollowingCount];
    [self.headerView addSubview:myFollowersCount];

    [self toggleMyButtons:YES];
}

-(void)toggleMyButtons:(BOOL)show {
    [nameLabel setHidden:!show];
    [photoButton setHidden:!show];
    [buttonAddFriend setHidden:!show];

    [bgFollowing setHidden:!show];
    [bgFollowers setHidden:!show];

    [myFollowersCount setHidden:!show];
    [myFollowersLabel setHidden:!show];
    [myFollowingCount setHidden:!show];
    [myFollowingLabel setHidden:!show];
    
    [pixTableController.view setHidden:!show];
}

-(void)startActivityIndicator {
    //[logo setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
    [self performSelector:@selector(stopActivityIndicatorAfterTimeout) withObject:nil afterDelay:10];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    //[logo setHidden:NO];
}
-(void)stopActivityIndicatorAfterTimeout {
    [self stopActivityIndicator];
    NSLog(@"%s: ActivityIndicator stopped after timeout!", __func__);
}

-(IBAction)didClickBackButton:(id)sender {
    if (isDisplayingFollowLists) {
        [searchResultsController.view removeFromSuperview];
        [self toggleMyButtons:YES];
        isDisplayingFollowLists = NO;
    }
    else
        [delegate shouldCloseUserPage];
}

-(UIImage*)getUserPhotoForUsername:(NSString*)name
{return [self.delegate getUserPhotoForUsername:name];}

/**** friendsViewControllerDelegate ****/
-(NSString*)getUsername {return username;}
-(int)getStixCount:(NSString*)stixStringID {return [delegate getStixCount:stixStringID];}
-(int)getStixOrder:(NSString*)stixStringID;
{
    return [self.delegate getStixOrder:stixStringID];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!pixTableController) {
        CGRect frame = CGRectMake(0,44, 320, 460-44);
        pixTableController = [[ColumnTableController alloc] init];
        [pixTableController.view setFrame:frame];
        [pixTableController.view setBackgroundColor:[UIColor clearColor]];
        pixTableController.delegate = self;
        [pixTableController setHasHeaderRow:YES];
        numColumns = 3;
        [pixTableController setNumberOfColumns:numColumns andBorder:4];
    }
    
    [self populateUserInfo];
    [self populateFollowCounts];
    //[self updateStixCounts];
    
    NSLog(@"User Page appearing: name %@ last time name was: %@", username, lastUsername);
    if (![lastUsername isEqualToString:username]) {
        [self forceReloadAll];
        [self setLastUsername:username];
    }
    [pixTableController.tableView setContentOffset:CGPointMake(0, 0)];
    [pixTableController.view removeFromSuperview];
    [self.view addSubview:pixTableController.view];
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
    [buttonAddFriend release];
    buttonAddFriend = nil;
    
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
    [buttonAddFriend release];
    buttonAddFriend = nil;
    [super dealloc];
}

#pragma mark Init

-(void)populateUserInfo {
    NSLog(@"Profile view appearing with username: %@", username);
    [nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFrame:CGRectMake(115, 68-44, 132, 33)];
    [nameLabel setText:username];

    [photoButton setFrame:CGRectMake(5, 58-44, 90, 90)];
    [photoButton setBackgroundColor:[UIColor blackColor]];
    [photoButton setImage:[delegate getUserPhotoForUsername:username] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(didClickAddFriendButton:) forControlEvents:UIControlEventTouchUpInside];

    [buttonAddFriend setFrame:CGRectMake(100, 160-44, 120, 60)];
    [buttonAddFriend setBackgroundColor:[UIColor clearColor]];
    if ([[delegate getFollowingList] containsObject:username]) { 
        [buttonAddFriend setImage:[UIImage imageNamed:@"btn_following.png"] forState:UIControlStateNormal];
    }
    else
    {
        [buttonAddFriend setImage:[UIImage imageNamed:@"btn_follow.png"] forState:UIControlStateNormal];
    }
    [buttonAddFriend addTarget:self action:@selector(didClickAddFriendButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgFollowing setFrame:CGRectMake(105, 103-44, 99, 45)];
    [bgFollowing setBackgroundImage:[UIImage imageNamed:@"dark_cell.png"] forState:UIControlStateNormal];

    [bgFollowers setFrame:CGRectMake(210, 103-44, 99, 45)];
    [bgFollowers setBackgroundImage:[UIImage imageNamed:@"dark_cell.png"] forState:UIControlStateNormal];
}
-(void)populateFollowCounts {
    [myFollowingCount setTextColor:[UIColor colorWithRed:255/255 green:204/255.0 blue:102/255.0 alpha:1]];
    [myFollowingCount setOutlineColor:[UIColor blackColor]];    
    [myFollowingCount setTextAlignment:UITextAlignmentCenter];
    [myFollowingCount setFontSize:25];
    
    [myFollowingLabel setTextColor:[UIColor whiteColor]];
    [myFollowingLabel setOutlineColor:[UIColor blackColor]];  
    [myFollowingLabel setText:@"FOLLOWING"];
    [myFollowingLabel setTextAlignment:UITextAlignmentCenter];
    [myFollowingLabel setFontSize:10];
    
    [myFollowersCount setTextColor:[UIColor colorWithRed:255/255 green:204/255.0 blue:102/255.0 alpha:1]];
    [myFollowersCount setOutlineColor:[UIColor blackColor]];        
    [myFollowersCount setTextAlignment:UITextAlignmentCenter];
    [myFollowersCount setFontSize:25];
    
    [myFollowersLabel setTextColor:[UIColor whiteColor]];
    [myFollowersLabel setOutlineColor:[UIColor blackColor]];    
    [myFollowersLabel setText:@"FOLLOWERS"];
    [myFollowersLabel setTextAlignment:UITextAlignmentCenter];
    [myFollowersLabel setFontSize:10];
    
    [self updateFollowCounts];
}

-(void)updateFollowCounts {
    [k getFollowersOfUserWithFollowsUser:username];
    [k getFollowListWithUsername:username]; 
}

-(void)updateStixCounts {
    [myPixCount setTextColor:[UIColor colorWithRed:255/255 green:204/255.0 blue:102/255.0 alpha:1]];
    [myPixCount setOutlineColor:[UIColor blackColor]];    
    [myPixCount setTextAlignment:UITextAlignmentCenter];
    [myPixCount setFontSize:20];
    
    [myPixLabel setTextColor:[UIColor whiteColor]];
    [myPixLabel setOutlineColor:[UIColor blackColor]];  
    [myPixLabel setText:@"PIX"];
    [myPixLabel setTextAlignment:UITextAlignmentCenter];
    [myPixLabel setFontSize:10];
    
    [myStixCount setTextColor:[UIColor colorWithRed:255/255 green:204/255.0 blue:102/255.0 alpha:1]];
    [myStixCount setOutlineColor:[UIColor blackColor]];        
    [myStixCount setTextAlignment:UITextAlignmentCenter];
    [myStixCount setFontSize:20];
    
    [myStixLabel setTextColor:[UIColor whiteColor]];
    [myStixLabel setOutlineColor:[UIColor blackColor]];    
    [myStixLabel setText:@"STIX"];
    [myStixLabel setTextAlignment:UITextAlignmentCenter];
    [myStixLabel setFontSize:10];
    
    userHistoryCount = -1;
    userCommentCount = -1;
    //[myPixCount setText:[NSString stringWithFormat:@"%d",0]];
    //[myStixCount setText:[NSString stringWithFormat:@"%d",0]];
    [k getCommentCountForUserWithUsername:username andStixStringID:@"COMMENT"];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getCommentCountForUserDidCompleteWithResult:(NSNumber *)aggregateResult {
    userCommentCount = [aggregateResult intValue];
    if (userCommentCount != -1) {
        [myStixCount setText:[NSString stringWithFormat:@"%d", userCommentCount]];
    }
    [k getHistoryCountForUserWithUsername:username];    
}
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getHistoryCountForUserDidCompleteWithResult:(NSNumber *)aggregateResult {
    userHistoryCount = [aggregateResult intValue];
    if (userCommentCount != -1) {
        [myPixCount setText:[NSString stringWithFormat:@"%d", userHistoryCount - userCommentCount]];
    }
    /*
    CGRect frame = [myPixCount frame];
    frame.size.width = [myPixCount.text length] * 20;
    [myPixCount setFrame:frame];
    
    frame = myPixLabel.frame;
    frame.origin.x = myPixCount.frame.size.width + myPixCount.frame.origin.x + 3;
    [myPixLabel setFrame:frame];
    
    frame = [myStixCount frame];
    frame.size.width = [myStixCount.text length] * 20;
    frame.origin.x = myPixLabel.frame.size.width + myPixLabel.frame.origin.x + 3;
    [myStixCount setFrame:frame];
    
    frame = myStixLabel.frame;
    frame.origin.x = myStixCount.frame.size.width + myStixCount.frame.origin.x + 3;
    [myStixCount setFrame:frame];
     */
}

-(IBAction)didClickAddFriendButton:(id)sender {
    NSLog(@"Add friend button clicked!");
    if ([[delegate getFollowingList] containsObject:username]) { 
        [delegate setFollowing:username toState:NO];
        [buttonAddFriend setImage:[UIImage imageNamed:@"btn_follow.png"] forState:UIControlStateNormal];
    }
    else
    {
        [delegate setFollowing:username toState:YES];
        [buttonAddFriend setImage:[UIImage imageNamed:@"btn_following.png"] forState:UIControlStateNormal];
    }
}

-(void)didSelectUserProfile:(int)index {
    NSString * new_username = [self getUsernameForUser:index];
    if ([new_username isEqualToString:[delegate getUsername]]) {
        [self didClickBackButton:nil];
        [delegate shouldDisplayUserPage:[delegate getUsername]];
    }
    else {
//        [delegate shouldCloseUserPage];
//        [delegate shouldDisplayUserPage:new_username];
        [searchResultsController.view removeFromSuperview];
        isDisplayingFollowLists = NO;
        [self toggleMyButtons:YES];
        [self setUsername:new_username];
        [self viewDidAppear:YES];
    }
}

#pragma mark FriendSearchResultsDelegate
-(NSString*)getUsernameForUser:(int)index {
    return [searchFriendName objectAtIndex:index];
}
-(UIImage*)getUserPhotoForUser:(int)index {
    NSString * friendName = [searchFriendName objectAtIndex:index];
    UIImage * userPhoto = [delegate getUserPhotoForUsername:friendName];
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
    if ([friendName isEqualToString:[delegate getUsername]])
        return -2;
    return [[delegate getFollowingList] containsObject:friendName];
}

-(int)getNumOfUsers {
    return [searchFriendName count];
}

#pragma UserGalleryDelegate
-(void)uploadImage:(NSData*)png withShareMethod:(int)buttonIndex
{
//    [self.delegate uploadImage:png withShareMethod:buttonIndex];
}
-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID {
//    [self.delegate didAddCommentWithTagID:tagID andUsername:name andComment:comment andStixStringID:stixStringID];
}
-(UIImage*)getUserPhotoForgallery {return [self.delegate getUserPhotoForUsername:username];}

#pragma mark ColumnTableController delegate
/*
-(UIView*)headerForSection:(NSInteger)section {
    return headerView;  
}

-(int)heightForHeader {
    return 160;
}
 */
-(int)numberOfRows {
    double total = [allTagIDs count];
    //NSLog(@"allTagIDs has %d items", total);
    return ceil(total / numColumns) + 1;
}

-(UIView*)viewForItemAtIndex:(int)index
{    
    if (index >= [allTagIDs count])
        return nil;
  
    NSNumber * key = [NSNumber numberWithInt:index-1];
    if (index < numColumns) {
        if (index == 0) return headerView;
        return nil;
    }
    else if ([contentViews objectForKey:key] == nil) {
        NSNumber * tagID = [allTagIDs objectAtIndex:index];
        Tag * tag = [allTags objectForKey:tagID];
        
        //UIImageView * cview = [[UIImageView alloc] initWithImage:tag.image];
        
        int contentWidth = [pixTableController getContentWidth];
        int targetWidth = contentWidth;
        int targetHeight = 282 * targetWidth / 314.0    ; //tagImageSize.height * scale;
        CGRect frame = CGRectMake(0, 0, targetWidth, targetHeight);
        NSLog(@"Index: %d frame: %@", index, frame);

        StixView * cview = [[StixView alloc] initWithFrame:frame];
        [cview setInteractionAllowed:YES];
        [cview setIsPeelable:NO];
        [cview setDelegate:self];
        [cview initializeWithImage:tag.image];
        [cview populateWithAuxStixFromTag:tag];
        [contentViews setObject:cview forKey:key];
        [cview release];
    }
    return [contentViews objectForKey:key];
}

-(void)loadContentPastRow:(int)row {
    NSLog(@"Loading row %d of total %d for gallery of user %@", row, [self numberOfRows], username);
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
    if (row == -1 || row == 0) {
        // load initial row(s)
        NSDate * now = [NSDate date]; // now
        [k getUserPixByTimeWithUsername:username andLastUpdated:now andNumRequested:[NSNumber numberWithInt:(numColumns*5)]];
    }
    else {
        NSNumber * tagID = [allTagIDs lastObject];
        Tag * tag = [allTags objectForKey:tagID];
        NSDate * lastUpdated = [tag.timestamp dateByAddingTimeInterval:-1];
        NSLog(@"lastUpdated: %@", lastUpdated);
        [k getUserPixByTimeWithUsername:username andLastUpdated:lastUpdated andNumRequested:[NSNumber numberWithInt:(numColumns*3)]];
    }
}

-(void)forceReloadAll {    
    [allTags removeAllObjects];
    [allTagIDs removeAllObjects];
    [contentViews removeAllObjects];
    [pixTableController.tableView reloadData];
    [self loadContentPastRow:-1];
    //isZooming = NO;
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
}

-(void)didPullToRefresh {
    [self forceReloadAll];
    [self updateFollowCounts];
    [self updateStixCounts];
}

#pragma mark KumulosDelegate functions
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPixByTimeDidCompleteWithResult:(NSArray *)theResults {
    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];
        Tag * newtag = [Tag getTagFromDictionary:d];
        [allTagIDs addObject:newtag.tagID]; // save in order 
        //NSLog(@"Explore recent tags: Downloaded tag ID %d at position %d", [newtag.tagID intValue], [allTagIDs count]);
        [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary
    }
    if ([theResults count]>0)
        [pixTableController dataSourceDidFinishLoadingNewData];
    [self stopActivityIndicator];
}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas {
}

#pragma mark DetailView 
/************** DetailView ***********/
-(void)didTouchInStixView:(StixView *)stixViewTouched {
    if ([DetailViewController openingDetailView])
        return;
    [DetailViewController lockOpen];    
    
    NSNumber * tagID = stixViewTouched.tagID;
    Tag * tag = [allTags objectForKey:tagID];
    detailController = [[DetailViewController alloc] init];
    [detailController setDelegate:self];    
    [detailController initDetailViewWithTag:tag];
    CGRect frameOffscreen = CGRectMake(-320,0,320,480);
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:detailController.view];
    [detailController setScrollHeight:370];
    [detailController.view setFrame:frameOffscreen];
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doSlide:detailController.view inView:self.view toFrame:frameOnscreen forTime:.5];
}

-(void)shouldDisplayUserPage:(NSString*)_username {
    NSLog(@"Multilayered display of profile view about to happen from UserProfileView!");
    // close detailView first - click came from here
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = detailController.view.frame;
    frameOffscreen.origin.x -= 330;
    
    [animation doViewTransition:detailController.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [detailController.view removeFromSuperview];
        [delegate shouldDisplayUserPage:_username];
    }];
}

-(void)didDismissZoom {
    //isZooming = NO;
    //[carouselView setUnderlay:scrollView];
    [detailController.view removeFromSuperview];
    [detailController release];
    detailController = nil;
}

#pragma mark stixview request delegates

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID {
    //NSLog(@"VerticalFeedItemController calling delegate didReceiveRequestedStixView");
    // send through to StixAppDelegate to save to defaults
    [delegate didReceiveRequestedStixViewFromKumulos:stixStringID];
}

-(void)didReceiveAllRequestedMissingStix:(StixView *)stixView {
    [stixView removeFromSuperview];
    for (int i=0; i<[contentViews count]; i++) {
        StixView * cview = [contentViews objectForKey:[NSNumber numberWithInt:i]];
        if ([cview stixViewID] == [stixView stixViewID]) {
            NSLog(@"UserProfileView: didReceiveAllRequestedMissingStix for stixView %d at index %d", [stixView stixViewID], i);
            [contentViews removeObjectForKey:[NSNumber numberWithInt:i]];
            [pixTableController.tableView reloadData];
            break;
        }
    }
}

#pragma mark followers and following lists

-(void)buttonFollowingClicked {
    if (isSearching)
        return;
    
    NSLog(@"Following clicked!");
    
    isSearching = YES;
    [self startActivityIndicator];
    [self populateFollowingList];
}

-(void)buttonFollowersClicked {
    if (isSearching)
        return;
    
    NSLog(@"Followers clicked!");
    
    isSearching = YES;
    [self startActivityIndicator];
    [self populateFollowersList];
}

// followers and following
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
-(void)populateFollowingList {
    [self initSearchResultLists];
    
    NSLog(@"Getting follows list from kumulos for username: %@", username);
    if (searchResultsController) {
        [searchResultsController.view removeFromSuperview];
        [searchResultsController release];
    }
    searchResultsController = [[FriendSearchResultsController alloc] init];
    [searchResultsController.view setFrame:CGRectMake(0, 44, 320, 480-64)];
    [searchResultsController setDelegate:self];
    searchResultsController.tableView.showsVerticalScrollIndicator = NO;
    
    [self toggleMyButtons:NO];
    [self.view addSubview:searchResultsController.view];
    isDisplayingFollowLists = YES;
    
    for (NSString * following in allFollowing) {
        NSLog(@"ProfileViewController: followingSet contains %@", following);
        [searchFriendName addObject:following];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
    }
    [searchResultsController.tableView reloadData];
    [self stopActivityIndicator];
    isSearching = NO;
}

-(void)populateFollowersList {
    NSLog(@"Getting follower list from kumulos for username: %@", username);
    
    [self initSearchResultLists];
    
    if (searchResultsController) {
        [searchResultsController.view removeFromSuperview];
        [searchResultsController release];
    }
    searchResultsController = [[FriendSearchResultsController alloc] init];
    [searchResultsController.view setFrame:CGRectMake(0, 44, 320, 480-64)];
    [searchResultsController setDelegate:self];
    searchResultsController.tableView.showsVerticalScrollIndicator = NO;

    [self toggleMyButtons:NO];
    [self.view addSubview:searchResultsController.view];
    isDisplayingFollowLists = YES;

    for (NSString * follower in allFollowers) {
        [searchFriendName addObject:follower];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
    }
    [searchResultsController.tableView reloadData];
    [self stopActivityIndicator];
    isSearching = NO;
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFollowersOfUserDidCompleteWithResult:(NSArray *)theResults {
    // list of people who follow this user
    // key: friendName value: username
    [allFollowers removeAllObjects];
    for (NSMutableDictionary * d in theResults) {
        NSString * friendName = [d valueForKey:@"username"];
        if (![allFollowers containsObject:friendName])
            [allFollowers addObject:friendName];
    }
    NSLog(@"Get followers returned: %@ has %d followers", username, [allFollowers count]);
    int followerCount = [allFollowers count];
    NSString * followerString = [NSString stringWithFormat:@"%d", followerCount];
    [myFollowersCount setText:followerString];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFollowListDidCompleteWithResult:(NSArray *)theResults {
    // list of people this user is following
    // key: username value: friendName
    [allFollowing removeAllObjects];
    for (NSMutableDictionary * d in theResults) {
        NSString * friendName = [d valueForKey:@"followsUser"];
        if (![allFollowing containsObject:friendName]) {
            NSLog(@"allFollowing adding %@", friendName);
            [allFollowing addObject:friendName];
        }
    }
    NSLog(@"Get follow list returned: %@ is following %d people", username, [allFollowing count]);
    int followingCount = [allFollowing count];
    NSString * followingString = [NSString stringWithFormat:@"%d", followingCount];
    [myFollowingCount setText:followingString];
}



@end
