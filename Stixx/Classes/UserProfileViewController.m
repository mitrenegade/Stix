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
@synthesize myFollowersCount, myFollowersLabel, myFollowingCount, myFollowingLabel;
@synthesize photoButton, nameLabel, buttonAddFriend;
@synthesize pixTableController;
@synthesize headerView;
//@synthesize detailController;
@synthesize lastUsername;
//@synthesize searchResultsController;
@synthesize scrollView;

-(id)init
{
	self = [super initWithNibName:@"UserProfileViewController" bundle:nil];
	
    k = nil;
    k = [[Kumulos alloc]init];
    [k setDelegate:self];    

    UIImage * backImage = [UIImage imageNamed:@"nav_back"];
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(didClickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    UIImageView * logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [self.navigationItem setTitleView:logo];
    
    return self;
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 9, 25, 25)];
    [self.view addSubview:activityIndicator];

    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    [headerView setBackgroundColor:[UIColor clearColor]];

    // user gallery
    allTagIDs = [[NSMutableArray alloc] init];
    allTags = [[NSMutableDictionary alloc] init];
    contentViews = [[NSMutableDictionary alloc] init];
    isShowingPlaceholderView = [[NSMutableDictionary alloc] init];
    placeholderViews = [[NSMutableDictionary alloc] init];
    
    nameLabel = [[UILabel alloc] init];
    photoButton = [[UIButton alloc] init];
    [photoButton addTarget:self action:@selector(didClickPhotoButton) forControlEvents:UIControlEventTouchUpInside];
    buttonAddFriend = [[UIButton alloc] init];//buttonWithType:UIButtonTypeCustom];
    bgFollowing = [UIButton buttonWithType:UIButtonTypeCustom];
    [bgFollowing addTarget:self action:@selector(didClickFollowingButton) forControlEvents:UIControlEventTouchUpInside];
    bgFollowers = [UIButton buttonWithType:UIButtonTypeCustom];
    [bgFollowers addTarget:self action:@selector(didClickFollowersButton) forControlEvents:UIControlEventTouchUpInside];

    myFollowingCount = [[OutlineLabel alloc] initWithFrame:CGRectMake(105, 100-44, 99, 40)];
    myFollowingLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(105, 133-44, 99, 15)];
    myFollowersCount = [[OutlineLabel alloc] initWithFrame:CGRectMake(210, 100-44, 99, 40)];
    myFollowersLabel = [[OutlineLabel alloc] initWithFrame:CGRectMake(210, 133-44, 99, 15)];

    //searchResultsController = nil;
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

    indexPointer = 0;
    pendingContentCount = 0;
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
    //NSLog(@"%s: ActivityIndicator stopped after timeout!", __func__);
}

-(IBAction)didClickBackButton:(id)sender {
        [self.navigationController popViewControllerAnimated:YES];        
}

-(UIImage*)getUserPhotoForUsername:(NSString*)name
{
    return [self.delegate getUserPhotoForUsername:name];
}

-(BOOL)didGetAllUsers {
    return [delegate didGetAllUsers];
}

/**** friendsViewControllerDelegate ****/
-(NSString*)getUsername {
    NSLog(@"Current username for app: %@", [delegate getUsername]);
    return [delegate getUsername];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!pixTableController) {
        pixTableController = [[ColumnTableController alloc] init];
        [pixTableController.view setBackgroundColor:[UIColor clearColor]];
        pixTableController.delegate = self;
//        [pixTableController setHasHeaderRow:YES];
        numColumns = 3;
        [pixTableController setNumberOfColumns:numColumns andBorder:4];
    }
    
    indexPointer = 0;
    pendingContentCount = 0;
    
    [self populateUserInfo];
    [self populateFollowCounts];
    //[self updateStixCounts];
    
    NSLog(@"User Page appearing: name %@ last time name was: %@", username, lastUsername);
    if (![lastUsername isEqualToString:username]) {
        pendingContentCount = 0;
        [self forceReloadAll];
        [self setLastUsername:username];
    }
    [pixTableController.tableView setContentOffset:CGPointMake(0, 0)];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, OFFSET_NAVBAR, 320, 480-OFFSET_NAVBAR)];
    [scrollView addSubview:pixTableController.view];
    [scrollView addSubview:headerView];
    [scrollView setDelegate:self];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:scrollView];
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
    nameLabel = nil;
    photoButton = nil;
    buttonAddFriend = nil;
    
    [super viewDidUnload];
}

#pragma mark Init

-(void)populateUserInfo {
    NSLog(@"Profile view appearing with username: %@", username);
    [nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFrame:CGRectMake(115, 68-44, 132, 33)];
    [nameLabel setText:username];

    [photoButton setFrame:CGRectMake(5, 58-44, 90, 90)];
    UIImage * userPhoto = [delegate getUserPhotoForUsername:username];
    [photoButton setImage:userPhoto forState:UIControlStateNormal];
    if (!userPhoto)
        [photoButton setImage:[UIImage imageNamed:@"graphic_nopic.png"] forState:UIControlStateNormal];
    [photoButton.layer setBorderWidth:2];

    if (![username isEqualToString:[delegate getUsername]]) {
        [buttonAddFriend setFrame:CGRectMake(85, 160-44, 153, 44)];
        [buttonAddFriend setBackgroundColor:[UIColor clearColor]];
        [buttonAddFriend setHidden:NO];
        if ([[delegate getFollowingList] containsObject:username]) { 
            [buttonAddFriend setImage:[UIImage imageNamed:@"btn_profile_following"] forState:UIControlStateNormal];
        }
        else
        {
            [buttonAddFriend setImage:[UIImage imageNamed:@"btn_profile_follow"] forState:UIControlStateNormal];
        }
        [buttonAddFriend addTarget:self action:@selector(didClickAddFriendButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView setFrame:CGRectMake(0, 0, 320, 160)];
    }
    else {
        [buttonAddFriend setHidden:YES];
        [headerView setFrame:CGRectMake(0, 0, 320, 160-44)];
    }
    float headerHeight = headerView.frame.size.height;
    CGRect frame = CGRectMake(0,headerHeight, 320, 460-44);
    [pixTableController.view setFrame:frame];
    [pixTableController.tableView setScrollEnabled:NO];

    [bgFollowing setFrame:CGRectMake(105, 103-44, 99, 45)];
    [bgFollowing setBackgroundImage:[UIImage imageNamed:@"dark_cell"] forState:UIControlStateNormal];

    [bgFollowers setFrame:CGRectMake(210, 103-44, 99, 45)];
    [bgFollowers setBackgroundImage:[UIImage imageNamed:@"dark_cell"] forState:UIControlStateNormal];
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

-(IBAction)didClickAddFriendButton:(id)sender {
    NSLog(@"Add friend button clicked!");
    if ([[delegate getFollowingList] containsObject:username]) { 
        [delegate setFollowing:username toState:NO];
        [buttonAddFriend setImage:[UIImage imageNamed:@"btn_profile_follow"] forState:UIControlStateNormal];
    }
    else
    {
        [delegate setFollowing:username toState:YES];
        [buttonAddFriend setImage:[UIImage imageNamed:@"btn_profile_following"] forState:UIControlStateNormal];
    }
    // force profile update
    [delegate didChangeFriendsFromUserProfile];
}

-(void)didSelectUserProfile:(int)index {
    NSString * new_username = [self getUsernameForUserAtIndex:index];
    if ([new_username isEqualToString:[delegate getUsername]]) {
        [self didClickBackButton:nil];
    }
    else {
        [delegate shouldDisplayUserPage:new_username];
    }
}

#pragma mark StixUsersViewController
-(int)getNumOfUsers {
    return [searchFriendName count];
}

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
-(int)getFollowingUserStatus:(int)index {
    if (![[searchFriendIsStix objectAtIndex:index] boolValue])
        return -1;
    
    NSString * friendName = [searchFriendName objectAtIndex:index];
    if ([friendName isEqualToString:[delegate getUsername]])
        return -2;
    return [[delegate getFollowingList] containsObject:friendName];
}
-(void)followUserAtIndex:(int)index {
    NSString * name = [self getUsernameForUserAtIndex:index];
    [delegate setFollowing:name toState:YES];
}
-(void)unfollowUserAtIndex:(int)index {
    NSString * name = [self getUsernameForUserAtIndex:index];
    [delegate setFollowing:name toState:NO];
}
-(void)followAllUsers {
    for (int i=0; i<[searchFriendName count]; i++) {
        NSString * name = [searchFriendName objectAtIndex:i];
        if (![[delegate getFollowingList] containsObject:name])
            [self followUserAtIndex:i];
    }
    // TODO: update profile page
    [delegate reloadSuggestionsForOutsideChange];
}
-(void)inviteUserAtIndex:(int)index {
    // no invite here
}
-(void)inviteAllUsers {
    // no invite
}
-(void)switchToInviteMode {
    // nothing
}

-(NSString*)getFacebookStringForUser:(int)index {
    return [searchFriendFacebookString objectAtIndex:index];
}

#pragma mark ColumnTableController delegate
-(int)numberOfRows {
    double total = [allTagIDs count];
    double rows = ceil(total/numColumns);
    //NSLog(@"allTagIDs has %f items, returning %f rows", total, rows);
    return (int)rows;
}

-(void)createPlaceholderViewForStixView:(StixView*)cview andKey:(NSNumber*)key {
    UIImageView * placeholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_emptypic.png"]];
    [placeholderView setCenter:cview.center];
    LoadingAnimationView * loadingAnimation = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [loadingAnimation setCenter:cview.center];
    [loadingAnimation startCompleteAnimation];
    [placeholderView addSubview:loadingAnimation];
    [placeholderViews setObject:placeholderView forKey:key];
}

-(UIView*)viewForItemAtIndex:(int)index
{    
    /*
    int actualIndex = index - numColumns;
    if (index >= [allTagIDs count] + numColumns)
        return nil;
  */
    int actualIndex = index;
    if (index >= [allTagIDs count])
        return nil;
    
    NSNumber * key = [NSNumber numberWithInt:actualIndex];
    /*
    if (index < numColumns) {
        if (index == 0) return headerView;
        return nil;
    }
     */
    //else 
    if ([allTagIDs objectAtIndex:index] != [NSNull null]) {
        NSNumber * tagID = [allTagIDs objectAtIndex:index]; 
        NSLog(@"ViewItemAtIndex: %d tagid %d", index, [tagID intValue]);
    }
    if ([contentViews objectForKey:key] == nil) {
        //UIImageView * cview = [[UIImageView alloc] initWithImage:tag.image];
        if ([allTagIDs objectAtIndex:index] != [NSNull null]) {
            NSLog(@"Creating contentView for index %d with tagID %d", index, [[allTagIDs objectAtIndex:index] intValue]); 
        }
        else {
            NSLog(@"Creating contentView for index %d with NULL", index); 
        }
        int contentWidth = [pixTableController getContentWidth];
        int targetWidth = contentWidth;
        int targetHeight = PIX_HEIGHT * targetWidth / PIX_WIDTH    ; //tagImageSize.height * scale;
        CGRect frame = CGRectMake(0, 0, targetWidth, targetHeight);
        StixView * cview = [[StixView alloc] initWithFrame:frame];
        [cview setInteractionAllowed:YES];
        [cview setIsPeelable:NO];
        [cview setDelegate:self];
        
        // populate with tags
        if ([allTagIDs objectAtIndex:index] != [NSNull null]) {
            NSNumber * tagID = [allTagIDs objectAtIndex:index];
            Tag * tag = [allTags objectForKey:tagID];
            [cview initializeWithImage:tag.image andStixLayer:tag.stixLayer];
            
            // sometimes requests just fail and never show up
            [cview populateWithAuxStixFromTag:tag];
        }
        if (![isShowingPlaceholderView objectForKey:key]) {
            cview.isShowingPlaceholder = YES;
            [isShowingPlaceholderView setObject:[NSNumber numberWithBool:YES] forKey:key];//tagID];
            
            [self createPlaceholderViewForStixView:cview andKey:key];
        }
        else {
            cview.isShowingPlaceholder = [[isShowingPlaceholderView objectForKey:key/*tagID*/] boolValue];
        }
        [contentViews setObject:cview forKey:key];
    }
    StixView * cview = [contentViews objectForKey:key];
    if (cview.isShowingPlaceholder) {
        UIView * placeholder = [placeholderViews objectForKey:key];
        return placeholder;
    }
    return [contentViews objectForKey:key];
}

-(void)loadContentPastRow:(int)row {
    if (pendingContentCount > 0) {
        NSLog(@"Trying to load past row %d: still waiting on %d pending contents", row, pendingContentCount);
        return;
    }
    //NSLog(@"Loading row %d of total %d for gallery of user %@", row, [self numberOfRows], username);
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
    if (row == -1) {// || row == 0) {
        [k getUserPixCountWithUsername:username];
    }
    else {
        NSNumber * tagID = [allTagIDs objectAtIndex:indexPointer-1]; // start at previous index because the last allTagIDs in the array might still be null
        Tag * tag = [allTags objectForKey:tagID];
        NSDate * lastUpdated = [tag.timestamp dateByAddingTimeInterval:-1];
        //NSLog(@"lastUpdated: %@", lastUpdated);
        int numPix = MIN(numColumns*3, maxContentCount - indexPointer);
        NSLog(@"Loading %d more pix, already loaded %d, total %d", numPix, indexPointer, maxContentCount);
        //[k getUserPixByTimeWithUsername:username andLastUpdated:lastUpdated andNumRequested:[NSNumber numberWithInt:numPix]];
        [k getUserPixByTimeCreatedWithUsername:username andTimeCreated:lastUpdated andNumPix:[NSNumber numberWithInt:numPix]];
        for (int i=0; i<numPix; i++)
            [allTagIDs addObject:[NSNull null]];
        pendingContentCount += numPix;
        [self resizeContentSize];
        [pixTableController.tableView reloadData];
    }
}

-(void)forceReloadAll {    
    [allTags removeAllObjects];
    [allTagIDs removeAllObjects];
    [contentViews removeAllObjects];
    [placeholderViews removeAllObjects];
    [isShowingPlaceholderView removeAllObjects];

    pendingContentCount = 0;
    indexPointer = 0;
    [pixTableController.tableView reloadData];
    [self loadContentPastRow:-1];
    [self startActivityIndicator];
}

-(void)didPullToRefresh {
    [self forceReloadAll];
    [self updateFollowCounts];
}

#pragma mark KumulosDelegate functions
//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPixByTimeDidCompleteWithResult:(NSArray *)theResults {
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPixByTimeCreatedDidCompleteWithResult:(NSArray *)theResults {
    NSLog(@"Received %d pix results", [theResults count]);
    // todo: 
    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];
        Tag * newtag = [Tag getTagFromDictionary:d];
        //[allTagIDs addObject:newtag.tagID]; // save in order 
        if ([allTags objectForKey:newtag.tagID] == nil) {
            int newindex = indexPointer++;
            if (newindex < [allTagIDs count]) {
                [allTagIDs replaceObjectAtIndex:newindex withObject:newtag.tagID];
                [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary        
            }
            else {
                [allTagIDs addObject:newtag.tagID];
                [allTags setObject:newtag forKey:newtag.tagID];
            }
        }
        
        // new system of auxiliary stix: request from auxiliaryStixes table
        // even though we don't have aux stix, we need this to switch out of the placeholder
#if 0
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newtag.tagID, nil]; 
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        [kh execute:@"getAuxiliaryStixOfTag" withParams:params withCallback:@selector(khCallback_didGetAuxiliaryStixOfTag:) withDelegate:self];
#else
        [self fakeDidGetAuxiliaryStixOfTagWithID:newtag.tagID];
#endif
        
        // don't know why this happens but sometimes it does!
        pendingContentCount--;
        if (pendingContentCount < 0)
            pendingContentCount = 0;
        
        //NSLog(@"Explore recent tags: Downloaded tag ID %d at position %d pending content: %d allTagIDs %d allTags %d", [newtag.tagID intValue], [allTagIDs count], pendingContentCount, [allTagIDs count], [allTags count]);
    }
    if ([theResults count]>0)
        [pixTableController dataSourceDidFinishLoadingNewData];
    [self stopActivityIndicator];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPixCountDidCompleteWithResult:(NSNumber *)aggregateResult {
    NSLog(@"User has %@ pix", aggregateResult);
    maxContentCount = [aggregateResult intValue];
    // load initial row(s)
    NSDate * now = [NSDate date]; // now
    int numPix = MIN(numColumns * 5, maxContentCount);
//    [k getUserPixByTimeWithUsername:username andLastUpdated:now andNumRequested:[NSNumber numberWithInt:numPix]];
    [k getUserPixByTimeCreatedWithUsername:username andTimeCreated:now andNumPix:[NSNumber numberWithInt:numPix]];
    for (int i=0; i<numPix; i++)
        [allTagIDs addObject:[NSNull null]];
    pendingContentCount += numPix;
    [pixTableController.tableView reloadData];    
}

-(void)fakeDidGetAuxiliaryStixOfTagWithID:(NSNumber *) tagID {
    NSLog(@"FakeDidGetAuxiliaryStix being called to update tag %@", tagID);
    Tag * tag = [allTags objectForKey:tagID];
    if (tag) {
        //[tag populateWithAuxiliaryStix:theResults];
        NSNumber * key = nil;
        for (int i=0; i<[allTagIDs count]; i++) {
            NSNumber * tID = [allTagIDs objectAtIndex:i];
            if (tID == tagID) {
                // remove contentView for a given index. contentViews are indexed by cell number, not by tagID
                key = [NSNumber numberWithInt:i];
                [contentViews removeObjectForKey:key];
                break;
            }
        }
        if (key)
            [isShowingPlaceholderView setObject:[NSNumber numberWithBool:NO] forKey:key];
        [pixTableController.tableView reloadData];
        [self resizeContentSize];
    }
}

-(void)khCallback_didGetAuxiliaryStixOfTag:(NSMutableArray *) returnParams {
    NSNumber * tagID = [returnParams objectAtIndex:0];
    NSMutableArray * theResults = [returnParams objectAtIndex:1];
    
    NSLog(@"Got auxiliary stix of tag %d with %d stix!", [tagID intValue], [theResults count]);
    //    if ([theResults count] > 0) {
    Tag * tag = [allTags objectForKey:tagID];
    if (tag) {
        [tag populateWithAuxiliaryStix:theResults];
        for (int i=0; i<[allTagIDs count]; i++) {
            NSNumber * tID = [allTagIDs objectAtIndex:i];
            if (tID == tagID) {
                // remove contentView for a given index. contentViews are indexed by cell number, not by tagID
                [contentViews removeObjectForKey:[NSNumber numberWithInt:i]];
                break;
            }
        }
        [isShowingPlaceholderView setObject:[NSNumber numberWithBool:NO] forKey:tagID];
        [pixTableController.tableView reloadData];
        return;
    }
}

-(void)resizeContentSize {
    int rows = [self numberOfRows];
    float newHeight = [pixTableController getContentHeight] * rows;
    [pixTableController.view setFrame:CGRectMake(pixTableController.view.frame.origin.x, pixTableController.view.frame.origin.y, pixTableController.view.frame.size.width, newHeight)];
    CGSize newContentSize = CGSizeMake(scrollView.frame.size.width, pixTableController.view.frame.origin.y + pixTableController.view.frame.size.height);
    [scrollView setContentSize:newContentSize];
    if (rows > 3)
        [scrollView setScrollEnabled:YES];
    else {
        [scrollView setScrollEnabled:NO];
    }
    NSLog(@"New user gallery scroll content size: %f %f number of rows %d table height %f", newContentSize.width, newContentSize.height, rows, newHeight);
}

-(void)didReachLastRow {
    // do nothing - this will always be called because the ColumnTable view is resized
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // check if scrollview didReachBottom / didViewLastRow
    float viewOfBottom = [scrollView contentOffset].y + scrollView.frame.size.height;
    NSLog(@"content offset: %f height: %f", [scrollView contentOffset].y, scrollView.frame.size.height);
    float threshold = pixTableController.tableView.frame.origin.y + pixTableController.tableView.frame.size.height - 3 * [pixTableController getContentHeight];
    NSLog(@"Currently viewing content at offset %f, with threshold %f origin %f height %f", viewOfBottom, threshold, pixTableController.tableView.frame.origin.y, pixTableController.tableView.frame.size.height);
    // check to see if we are looking at the content of the last row
    if (threshold < 0)
        return;
    if (viewOfBottom > threshold) {
        [self loadContentPastRow:[self numberOfRows]];
    }
}

#pragma kumulosHelper callback
-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    [self performSelector:callback withObject:params afterDelay:0];
}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas {
}

#pragma mark DetailView 
/************** DetailView ***********/
-(void)didTouchInStixView:(StixView *)stixViewTouched {
//    if ([DetailViewController openingDetailView])
//        return;
//    [DetailViewController lockOpen];    
    
    NSNumber * tagID = stixViewTouched.tagID;
    Tag * tag = [allTags objectForKey:tagID];
#if 0
    detailController = [[DetailViewController alloc] init];
    [detailController setDelegate:self];    
    [detailController initDetailViewWithTag:tag];
    CGRect frameOffscreen = CGRectMake(-320,0,320,480);
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:detailController.view];
    [detailController setScrollHeight:370];
    [detailController.view setFrame:frameOffscreen];
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    //[animation doSlide:detailController.view inView:self.view toFrame:frameOnscreen forTime:.25];
    [animation doViewTransition:detailController.view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished) {
    }];
#else
    [delegate shouldDisplayDetailViewWithTag:tag];
#endif

#if USING_FLURRY
    if (!IS_ADMIN_USER([self getUsername]))
        [FlurryAnalytics logEvent:@"DetailViewFromUserGallery" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", tagID, @"tagID", nil]];
#endif
}

-(void)shouldDisplayUserPage:(NSString*)_username {
    NSLog(@"Multilayered display of profile view about to happen from UserProfileView!");
    // close detailView first - click came from comments in detailview
#if 0
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = detailController.view.frame;
    frameOffscreen.origin.x -= 330;
    
    [animation doViewTransition:detailController.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [detailController.view removeFromSuperview];
        [delegate shouldDisplayUserPage:_username];
    }];
#endif
    [delegate shouldDisplayUserPage:_username];
}

#pragma mark stixview request delegates
/*
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
*/
#pragma mark followers and following lists

-(void)didClickFollowingButton {
    if (isSearching)
        return;
    
    NSLog(@"Following clicked!");
    
    isSearching = YES;
    [self startActivityIndicator];
    [self populateFollowingList];
}

-(void)didClickFollowersButton {
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
        searchFriendFacebookString = [[NSMutableArray alloc] init];
        searchFriendIsStix = [[NSMutableArray alloc] init]; // whether they are using Stix already
    }
    [searchFriendName removeAllObjects];
    [searchFriendEmail removeAllObjects];
    [searchFriendFacebookString removeAllObjects];
    [searchFriendIsStix removeAllObjects];
}
-(void)populateFollowingList {
    [self initSearchResultLists];
    
    NSLog(@"Getting follows list from kumulos for username: %@", username);
    for (NSString * following in allFollowing) {
        //NSLog(@"ProfileViewController: followingSet contains %@", following);
        [searchFriendName addObject:following];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
    }
    
    StixUsersViewController * searchResultsController = [[StixUsersViewController alloc] init];
    [searchResultsController setDelegate:self];    
    [self.navigationController pushViewController:searchResultsController animated:YES];
    [searchResultsController.tableView reloadData];
    [self stopActivityIndicator];
    isSearching = NO;
}

-(void)populateFollowersList {
    NSLog(@"Getting follower list from kumulos for username: %@", username);
    
    [self initSearchResultLists];

    for (NSString * follower in allFollowers) {
        [searchFriendName addObject:follower];
        [searchFriendIsStix addObject:[NSNumber numberWithBool:YES]];
    }
    StixUsersViewController * searchResultsController = [[StixUsersViewController alloc] init];
    [searchResultsController setDelegate:self];
    [self.navigationController pushViewController:searchResultsController animated:YES];
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
            //NSLog(@"allFollowing adding %@", friendName);
            [allFollowing addObject:friendName];
        }
    }
    NSLog(@"Get follow list returned: %@ is following %d people", username, [allFollowing count]);
    int followingCount = [allFollowing count];
    NSString * followingString = [NSString stringWithFormat:@"%d", followingCount];
    [myFollowingCount setText:followingString];
}

#pragma mark remix hack
/*
-(void)didClickRemixFromDetailViewWithTag:(Tag*)tagToRemix {
    // close detailView first - click came from here
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = detailController.view.frame;
    frameOffscreen.origin.x -= 330;
    
    [animation doViewTransition:detailController.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [detailController.view removeFromSuperview];
        [delegate didClickRemixFromDetailViewWithTag:tagToRemix];
    }];
}
 */

#pragma mark changing profile photo
-(void)didClickPhotoButton {
    // do not allow other profiles to be clickable
    if (![[delegate getUsername] isEqualToString:[self username]])
        return;
    [delegate didClickChangePhoto];
}

-(void)didChangeUserPhoto:(UIImage *)photo {
    [photoButton setImage:photo forState:UIControlStateNormal];
    [photoButton.layer setBorderWidth:2];
}
@end
