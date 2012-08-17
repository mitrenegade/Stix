//
//  FriendSuggestionController.m
//  Stixx
//
//  Created by Bobby Ren on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendSuggestionController.h"

@implementation FriendSuggestionController
@synthesize delegate;
@synthesize tableViewController;
@synthesize buttonEdit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIImage * leftImage = [UIImage imageNamed:@"btn_edit"];
        UIButton * leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, leftImage.size.width, leftImage.size.height)];
        [leftButton setImage:leftImage forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(didClickButtonEdit:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [self.navigationItem setLeftBarButtonItem:leftBarButton];
        
        UIImageView * logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"txt_suggested"]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    
#if USING_FLURRY
    if (!IS_ADMIN_USER([delegate getUsername]))
        [FlurryAnalytics logPageView];
#endif

    tableViewController = [[FriendSearchTableViewController alloc] init];
    [tableViewController setDelegate:self];
    [tableViewController.view setFrame:CGRectMake(0, 44, 320, 480-44-40)];
    [tableViewController.view setBackgroundColor:[UIColor clearColor]];
    [self.view insertSubview:tableViewController.view belowSubview:tabGraphic];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
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

-(void)initializeHeaderViews {
    if (!headerViews) {
        headerViews = [[NSMutableArray alloc] init];
        for (int i=0; i<SUGGESTIONS_SECTION_MAX; i++) {
            [headerViews addObject:[NSNull null]];
        }
    }
    UIImageView * featuredHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    [featuredHeader setImage:[UIImage imageNamed:@"header_featuredstixsters@2x.png"]];
    if ([featured count] == 0) {
        [featuredHeader setFrame:CGRectMake(0, 0, 320, 1)];
    }
    [headerViews replaceObjectAtIndex:SUGGESTIONS_SECTION_FEATURED withObject:featuredHeader];
    UIImageView * friendHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    [friendHeader setImage:[UIImage imageNamed:@"header_friendsonstix@2x.png"]];
    if ([friends count] == 0) {
        [friendHeader setFrame:CGRectMake(0, 0, 320, 1)];
    }
    [headerViews replaceObjectAtIndex:SUGGESTIONS_SECTION_FRIENDS withObject:friendHeader];
    NSLog(@"After initializing header views: %d sections", [headerViews count]);
}

-(void)initializeSuggestions {
    friends = [[NSMutableArray alloc] init];
    featured = [[NSMutableArray alloc] init];
    featuredDesc = [[NSMutableArray alloc] init];
    userPhotos = [[NSMutableDictionary alloc] init];

    didGetFeaturedUsers = NO;
    didGetFacebookFriends = NO;
    //[k getFeaturedUsers];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"getFeaturedUsers" withParams:nil withCallback:@selector(khCallback_didGetFeaturedUsers:) withDelegate:self];
    [delegate searchFriendsOnStix];
        
    [self initializeHeaderViews];
    isEditing = NO;
}

-(void)populateFacebookSearchResults:(NSArray*)facebookFriendArray {
//    [self initSearchResultLists];
        
    [friends removeAllObjects];
    //[friendsIDs removeAllObjects];
    NSMutableSet * alreadyFollowing = [delegate getFollowingList];
    
    NSMutableArray * allFacebookStrings = [delegate getAllUserFacebookStrings];
    for (NSMutableDictionary * d in facebookFriendArray) {
        NSString * _facebookString = [d valueForKey:@"id"];
        NSString * _facebookName = [d valueForKey:@"name"];
        if ([alreadyFollowing containsObject:_facebookName])
            continue; // skip those already following
        if ([_facebookName isEqualToString:[delegate getUsername]])
            continue; // skip self
        if ([allFacebookStrings containsObject:_facebookString]) {
            NSString * stixName = [delegate getNameForFacebookString:_facebookString];
            [friends addObject:stixName];
            NSLog(@"Adding facebook friend already on stix: %@ with id %@ and stix name %@", _facebookName, _facebookString, stixName);
        }
    }
    
    NSLog(@"Loaded %d Facebook friends already on Stix, %d featured", [friends count], [featured count]);
    // todo: filter out existing friends, if any
    if ([friends count] > 0) {
        [self initializeHeaderViews]; // reload in case initializeHeaderViews was called before this appeared
    }
    
//    NSLog(@"TableViewController: %x %x", self.tableViewController, self.tableViewController.tableView);
    [self.tableViewController.tableView reloadData];
    // filter out existing friends, if any
    if ([featured count] > 0) {
        for (NSString * name in featured) {
            if ([friends containsObject:name])
                [friends removeObject:name];
        }
    }

    int total = [featured count] + [friends count];
    didGetFacebookFriends = YES;
    if (didGetFeaturedUsers) {
        NSLog(@"***FriendSuggestionController: facebook friends loaded after featured; total suggestions %d", total);
        [delegate friendSuggestionControllerFinishedLoading:total];
    }
    else 
        NSLog(@"***FriendSuggestionController: facebook friends loaded first!");
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFeaturedUsersDidCompleteWithResult:(NSArray *)theResults {
-(void)khCallback_didGetFeaturedUsers:(NSArray*)returnParams {
    NSArray * theResults = [returnParams objectAtIndex:0];
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
    
    [self.tableViewController.tableView reloadData];
    if ([friends count] > 0 && [featured count] > 0) {
        for (NSString * name in featured) {
            if ([friends containsObject:name])
                [friends removeObject:name];
        }
    }

    if ([featured count] == 0) {
        [self initializeHeaderViews];
    }
    didGetFeaturedUsers = YES;
    [delegate didGetFeaturedUsers:theResults];
    int total = [featured count] + [friends count];
    if (didGetFacebookFriends) {
        NSLog(@"***FriendSuggestionController: featured users loaded after facebook; total suggestions %d", total);
        [delegate friendSuggestionControllerFinishedLoading:total];
    }
    else 
        NSLog(@"***FriendSuggestionController: featured users loaded first!");
}

#pragma mark KumulosHelperDelegate
-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    [self performSelector:callback withObject:params afterDelay:0];
}

-(void)kumulosHelperGetFeaturedUsersDidFail {
    NSLog(@"getFeaturedUsers failed!");
    // simulate no users
    // create an empty featured user list
    NSArray * theResults = [NSArray arrayWithObject:nil];
    [self khCallback_didGetFeaturedUsers:[NSArray arrayWithObject:theResults]];
}

-(IBAction)didClickButtonEdit:(id)sender {
    if (!isEditing) {
        [tableViewController startEditing];
        isEditing = YES;
    }
    else {
        [tableViewController stopEditing];
        isEditing = NO;
    }
    
#if USING_FLURRY
    if (!IS_ADMIN_USER([delegate getUsername]))
        [FlurryAnalytics logEvent:@"FriendSuggestionsEdited" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[delegate getUsername], @"username", nil]];
#endif

}

-(void)didDeleteAllEntries {
    [self didClickButtonNext:nil];
}

-(IBAction)didClickButtonNext:(id)sender {
    [friends addObjectsFromArray:featured];
    NSLog(@"FriendSuggestionController: friends and featured together: %d", [friends count]);
    [self.navigationController popViewControllerAnimated:YES];
    [delegate didAddFriendsFromFriendSuggestionController:friends];
}

-(void)refreshUserPhotos {
    [tableViewController.tableView reloadData];
}

#pragma mark FriendSearchTableDelegate
-(int)friendsCount {
    return [friends count];
}
-(int)featuredCount {
    return [featured count];
}
-(NSString*)getFriendAtIndex:(int)index {
    if (index >= [friends count])
        return nil;
    return [friends objectAtIndex:index];
}
-(NSString*)getFeaturedAtIndex:(int)index {
    if (index >= [featured count])
        return nil;
    return [featured objectAtIndex:index];
}
-(NSString*)getFeaturedDescriptorAtIndex:(int)index {
    if (index >= [featuredDesc count])
        return nil;
    return [featuredDesc objectAtIndex:index];
}
-(UIImage *)getUserPhotoForUsername:(NSString *)username {
    // FriendSearchTableViewController resizes the photos
    return [delegate getUserPhotoForUsername:username];
}
-(int)numberOfSections {
    return [headerViews count];
}
-(UIView*)headerViewForSection:(int)section {
    return [headerViews objectAtIndex:section];
}

-(void)removeFriendAtRow:(int)row {
    if (row < [friends count])
        [friends removeObjectAtIndex:row];
    if ([friends count] == 0)
        [self initializeHeaderViews];
}
-(void)removeFeaturedAtRow:(int)row {
    if (row < [featured count]) {
        [featured removeObjectAtIndex:row];
        [featuredDesc removeObjectAtIndex:row];
    }
    if ([featured count] == 0)
        [self initializeHeaderViews];
}
@end

