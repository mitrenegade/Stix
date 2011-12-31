//
//  StixxAppDelegate.m
//  Stixx
//
//  Created by Bobby Ren on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//
//  StixxAppDelegate.m
//  Stixx
//
//  Created by Zac White on 8/1/09.		
//  Copyright Zac White 2009. All rights reserved.
//


#import "StixxAppDelegate.h"
#import <MapKit/MapKit.h>
#import "FileHelpers.h"

#define START_ID 100
#define TAG_LOAD_WINDOW 3 // load this many tags before or after current tag

@implementation StixxAppDelegate

@synthesize window;
@synthesize tagViewController;
@synthesize exploreController;
@synthesize tabBarController;
@synthesize feedController;
@synthesize profileController;
@synthesize friendController;
@synthesize loginSplashController;
@synthesize myStixController;
@synthesize username;
@synthesize userphoto;
@synthesize usertagtotal;
@synthesize lastViewController;
@synthesize allTags;
@synthesize timeStampOfMostRecentTag;
@synthesize allUserPhotos;
@synthesize allStix;
@synthesize k;
@synthesize lastCarouselView;
@synthesize allCommentCounts;
@synthesize loadingController;

static const int levels[6] = {0,0,5,10,15,20};
static int init=0;

// INIT code
- (void)applicationDidFinishLaunching:(UIApplication *)application {  
    
    k = [[Kumulos alloc]init];
    [k setDelegate:self];

    // Override point for customization after application launch
    loadingController = [[LoadingViewController alloc] init];
    [window addSubview:loadingController.view];
    [loadingController setMessage:@"Connecting to Stix server..."];
    
    [window makeKeyAndVisible];
    
    [k getAllStixTypes];
    [k getAllStixViews];    
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllStixTypesDidCompleteWithResult:(NSArray *)theResults {     
    // initialize stix types for all badge views
    [BadgeView InitializeStixTypes:theResults];
    init++;
    if (init == 2) {
        [self continueInit];
    }
}


- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllStixViewsDidCompleteWithResult:(NSArray *)theResults {
    [BadgeView InitializeStixViews:theResults];
    init++;
    if (init == 2) {
        [self continueInit];
    }
}

-(void) continueInit {

    //[self adminUpdateAllStixCountsToZero];

#if 1
	tabBarController = [[RaisedCenterTabBarController alloc] init];
    tabBarController.myDelegate = self;
#else
	tabBarController = [[UITabBarController alloc] init];
#endif
    allTags = [[NSMutableArray alloc] init];
    allUserPhotos = [[NSMutableDictionary alloc] init];
    allStix = [[NSMutableDictionary alloc] init];
    allCommentCounts = [[NSMutableDictionary alloc] init];
    
	/***** create first view controller: the TagViewController *****/
    [loadingController.view removeFromSuperview]; // doesnt work
    [loadingController release];
    loadingController = [[LoadingViewController alloc] init];
    [window addSubview:loadingController.view];
    [loadingController setMessage:@"Initializing camera..."];

  	tagViewController = [[TagViewController alloc] init];
	tagViewController.delegate = self;
	[tagViewController setCameraOverlayView:[tabBarController view]]; // allows camera to have the tabBar navigation as well as the badge/aperture/3d overlay
    
    //timeStampOfMostRecentTag = [[NSDate alloc] init];
    idOfNewestTagOnServer = -1;
    idOfOldestTagOnServer = 99999;
    idOfNewestTagReceived = -1; // nothing received yet
    idOfOldestTagReceived = 99999;
    idOfCurrentTag = -1;
    idOfLastTagChecked = -1;
    idOfMostRecentUser = -1;
    pageOfLastNewerTagsRequest = -1;
    pageOfLastOlderTagsRequest = -1;
    [self checkForUpdateTags];
#if 1
	/***** create feed view *****/
    [loadingController.view removeFromSuperview];
    [loadingController release];
    loadingController = [[LoadingViewController alloc] init];
    [window addSubview:loadingController.view];
    [loadingController setMessage:@"Loading feed..."];

	feedController = [[FeedViewController alloc] init];
    [feedController setDelegate:self];
    //[feedController setIndicator:YES];
    feedController.allTags = allTags;
#endif
    
#if 1
    /***** create explore view *****/
    exploreController = [[ExploreViewController alloc] init];
    exploreController.delegate = self;
	
	/***** create friends feed *****/
    [loadingController.view removeFromSuperview];
    [loadingController release];
    loadingController = [[LoadingViewController alloc] init];
    [window addSubview:loadingController.view];
    [loadingController setMessage:@"Contacting friends.."];

	friendController = [[FriendsViewController alloc] init];
    //	friendController.tagViewController = tagViewController;
    friendController.delegate = self;
    [self checkForUpdatePhotos];
    
    /***** create mystix view *****/
    myStixController = [[MyStixViewController alloc] init];
    myStixController.delegate = self;

	/***** create config view *****/
	profileController = [[ProfileViewController alloc] init];
    profileController.delegate = self;
    [profileController setFriendController:friendController];
#endif
    
    loginSplashController = nil;
    NSString *path = [self coordinateArrayPath];
	NSLog(@"Trying to load from path %@", path);
    username = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    userphoto = nil;
    loggedIn = NO;
    isLoggingIn = NO;
    if (!username || [username length] == 0)
    {
        // force login
        loginSplashController = [[LoginSplashController alloc] init];
        [loginSplashController setDelegate:self];
        isLoggingIn = YES;
        loggedIn = NO;
    }
    else
    {
        NSLog(@"Loggin in as %@", username);
        [loadingController.view removeFromSuperview];
        [loadingController release];
        loadingController = [[LoadingViewController alloc] init];
        [window addSubview:loadingController.view];
        [loadingController setMessage:[NSString stringWithFormat:@"Logging in as %@...", username]];
        [profileController loginWithUsername:username];
    }   
	/***** add view controllers to tab controller, and add tab to window *****/
	NSArray * viewControllers = [NSArray arrayWithObjects: feedController, exploreController, tagViewController, myStixController, profileController, nil];
    //NSArray * viewControllers = [NSArray arrayWithObjects: exploreController, feedController, tagViewController, myStixController, profileController, nil];
    [tabBarController setViewControllers:viewControllers];
	[tabBarController setDelegate:self];
    
    lastViewController = feedController;
    lastCarouselView = feedController.carouselView;
    [loadingController.view removeFromSuperview];
    [window addSubview:[tabBarController view]];
    
    [tabBarController addCenterButtonWithImage:[UIImage imageNamed:@"tab_addstix.png"] highlightImage:nil];
	
    if (isLoggingIn == YES && loggedIn == NO)
    {
        [tabBarController presentModalViewController:loginSplashController animated:NO];
        isLoggingIn = NO;
    }
    
    /* add administration calls here */
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (lastViewController == tagViewController)
    {
        [tagViewController dismissModalViewControllerAnimated:NO];
        lastCarouselView = [tagViewController carouselView];
    }
    if (lastViewController == friendController) // if we leave friend controller, start an update for next time
    {
        [self checkForUpdatePhotos];
        lastCarouselView = [friendController carouselView];
    }
    if (lastViewController == feedController)
    {
        lastCarouselView = [feedController carouselView];
    }
    if (lastViewController == exploreController)
    {
        lastCarouselView = [exploreController carouselView];
    }
	[viewController viewWillAppear:TRUE];
    lastViewController = viewController;
}

// RaisedCenterTabBarController delegate 
-(void)didPressCenterButton {
    // when center button is pressed, programmatically send the tab bar that command
    [tabBarController setSelectedIndex:2];
    lastViewController = tagViewController;
    [tagViewController viewWillAppear:TRUE];
}

- (void)applicationWillTerminate:(UIApplication *)application
{	// Get full path of possession archive 
	NSString *path = [self coordinateArrayPath];
    
	//NSLog(@"Saving coordinate array to path %@", path);
	// Get the possession list 
	//NSMutableArray *tempLocationArray = [tagViewController getCoordinates];
	// Archive possession list to file
	//[NSKeyedArchiver archiveRootObject:tempLocationArray toFile:path]; 
    
    // archive username
    [NSKeyedArchiver archiveRootObject:username toFile:path];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{	// Get full path of possession archive 
	//NSLog(@"Saving coordinate array to path %@", path);
	// Get the possession list 
	//NSMutableArray *tempLocationArray = [tagViewController getCoordinates];
	// Archive possession list to file
	//[NSKeyedArchiver archiveRootObject:tempLocationArray toFile:path]; 
    
    // archive username
	NSString *path = [self coordinateArrayPath];
    NSLog(@"Logging out and saving username %@", username);
    [NSKeyedArchiver archiveRootObject:username toFile:path];
}

/**** loading and adding of stix from kumulos ****/

-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID{
    // adds a tag to allTags, if its id doesn't already exist
    // add Tag to the correct position in allTags - used if we have delayed loading
    // newID is needed if tag.ID doesn't exist yet
    bool added = NO;
    bool alreadyExists = NO;
    int i;
    tag.tagID = [NSNumber numberWithInt:newID];
    for (i=0; i<[allTags count]; i++)
    {
        Tag * currtag = (Tag*) [allTags objectAtIndex:i];
        int tagID = [currtag.tagID intValue];
        if (newID == tagID)
        {
            // already exists, break
            alreadyExists = YES;
            break;
        }
        else if (newID>tagID) // allTags should start at a high tagID (most recent) and go to a lower tagID (oldest)
        {
            [tagViewController addCoordinateOfTag:tag];
            [allTags insertObject:tag atIndex:i];
            [self getCommentCount:newID]; // store comment count for this tag
            //[tag release];
            added = YES;
            if (newID > idOfNewestTagReceived)
                idOfNewestTagReceived = newID;
            if (newID < idOfOldestTagReceived)
                idOfOldestTagReceived = newID;
            break;
        }
    }
    if (!added && !alreadyExists)
    {
        [tagViewController addCoordinateOfTag:tag];
        [allTags insertObject:tag atIndex:i];
        //[tag release];
        if (newID > idOfNewestTagReceived)
            idOfNewestTagReceived = newID;
        if (newID < idOfOldestTagReceived)
            idOfOldestTagReceived = newID;
        added = YES;
    }
    return added;
}

-(void)tagViewDidAddTag:(Tag *)newTag {
    // when adding a tag, we add it to both our local tag structure, and to kumulos database
    //[allTags addObject:newTag];
    newestTag = [newTag retain];
    
    [k setDelegate:self];
    NSData * theImgData = UIImageJPEGRepresentation([newTag image], .8); //UIImagePNGRepresentation([newTag image]);
    
    // this must match Tag.m:getTagFromDictionary
    NSMutableData *theCoordData;
    NSKeyedArchiver *encoder;
    theCoordData = [NSMutableData data];
    encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theCoordData];
	[encoder encodeObject:newTag.coordinate forKey:@"coordinate"];
    [encoder finishEncoding];
    [encoder release];
    
    // this must match Tag.m:getTagFromDictionary
    NSMutableData *theAuxStixData;
    theAuxStixData = [NSMutableData data];
    encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theAuxStixData];
	[encoder encodeObject:newTag.auxLocations forKey:@"auxLocations"];
	[encoder encodeObject:newTag.auxStixStringIDs forKey:@"auxStixStringIDs"];
    [encoder finishEncoding];
    [encoder release];

    [k newPixWithUsername:newTag.username andDescriptor:newTag.descriptor andComment:newTag.comment andLocationString:newTag.locationString andImage:theImgData andBadge_x:newTag.badge_x andBadge_y:newTag.badge_y andScore:newTag.badgeCount andStixStringID:newTag.stixStringID andTagCoordinate:theCoordData andAuxStix:theAuxStixData];
    //[k addNewStixWithUsername:username andComment:newTag.comment andLocationString:newTag.locationString andImage:img andBadge_x:x andBadge_y:y andTagCoordinate:theCoordData andType:type andScore:count];    
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation newPixDidCompleteWithResult:(NSNumber *)newRecordID {
    [newestTag setTagID:newRecordID];
    [newestTag setTimestamp:[NSDate date]]; // set a temporary date because we are adding newestTag that does not have a kumulos timestamp
    //[allTags addObject:newestTag];
    bool added = [self addTagWithCheck:newestTag withID:[newRecordID intValue]];
    if (added)
        NSLog(@"Added new record to kumulos: tag id %d", [newRecordID intValue]);
    else
        NSLog(@"Error! New record has duplicate tag id: %d", [newRecordID intValue]);
    
    // update usertagtotal
    usertagtotal += 1;
    [k updateTotalTagsWithUsername:username andTotalTags:usertagtotal];
}

#if 0
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addNewStixDidCompleteWithResult:(NSNumber*)newRecordID
{
    [newestTag setTagID:newRecordID];
    [newestTag setTimestamp:[NSDate date]]; // set a temporary date because we are adding newestTag that does not have a kumulos timestamp
    //[allTags addObject:newestTag];
    bool added = [self addTagWithCheck:newestTag withID:[newRecordID intValue]];
    if (added)
        NSLog(@"Added new record to kumulos: tag id %d", [newRecordID intValue]);
    else
        NSLog(@"Error! New record has duplicate tag id: %d", [newRecordID intValue]);
    
#if 0
    // do not do this - we still cannot get rid of the damn camera view along the top.
    // dismissModalViewControllerAnimated doesn't seem to work here...but it does work
    // if we switch tab bars and didSelectViewController is called
    [tagViewController dismissModalViewControllerAnimated:NO];
    [tabBarController setSelectedIndex:0]; // go automatically to feedview
    lastViewController = feedController;
    [feedController viewWillAppear:TRUE];
#endif

#if 1 // create empty stixCounts for different stix types
    NSMutableData *theStixData;
    NSKeyedArchiver *encoder2;
    theStixData = [NSMutableData data];
    encoder2 = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theStixData];
	[encoder2 encodeObject:newestTag.stixCounts forKey:@"stixCounts"];
    [encoder2 finishEncoding];
    [k updatePixWithStixCountsWithAllTagID:[newestTag.tagID intValue] andStixCounts:theStixData];
    [k updatePixWithDescriptorWithAllTagID:[newestTag.tagID intValue] andDescriptor:newestTag.descriptor];
    [encoder2 release];  
#endif

    // update usertagtotal
    usertagtotal += 1;
    [k updateTotalTagsWithUsername:username andTotalTags:usertagtotal];
        
    // add comment to history
    //[k addHistoryToPixWithTagID:[newestTag.tagID intValue] andUsername:newestTag.username andComment:newestTag.comment andBadgeType:newestTag.badgeType];
    // update comment count
    //[self updateCommentCount:[tag.tagID intValue]];

}
#endif

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateTotalTagsDidCompleteWithResult:(NSNumber*)affectedRows {
    NSLog(@"Updated user tag totals: affect rows %d\n", [affectedRows intValue]);
    [profileController updatePixCount];
}

- (void)clearTags {
    [allTags removeAllObjects];
    [tagViewController clearTags];
}

/**** FeedViewDelegate ****/

// Checking for new items at the beginning of the list

- (void) checkForUpdateTags {
    int numTags = 1;
    NSNumber * number = [[NSNumber alloc] initWithInt:numTags];
    //[k getLastTagTimestampWithNumEls:number];
    [k getLastTagIDWithNumEls:number];
    [number release];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getLastTagIDDidCompleteWithResult:(NSArray*)theResults {
    // NSArray contains one element which is the most recently created element in the database
	for (NSMutableDictionary * d in theResults) {        
        int idnum = [[d valueForKey:@"allTagID"] intValue];
        if (idnum > idOfNewestTagOnServer)//idOfMostRecentTagReceived)
        {
            idOfNewestTagOnServer = idnum;
        }
    }
    
    // now download that tag
    if (idOfLastTagChecked < idOfNewestTagOnServer)
    {
        [k getAllTagsWithIDRangeWithId_min:idOfNewestTagOnServer-1 andId_max:idOfNewestTagOnServer+1];
        idOfLastTagChecked = idOfNewestTagOnServer;
    }
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray *)theResults
{
    bool didAddTag = NO;
    // assume result is ordered by allTagID
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [Tag getTagFromDictionary:d];
        NSLog(@"Tag stringID: %@", tag.stixStringID);
        int new_id = [tag.tagID intValue];
        if (new_id > idOfNewestTagReceived)
        {
            NSLog(@"Changing id of Newest Tag Received from %d to %d", idOfNewestTagReceived, new_id);
            idOfNewestTagReceived = new_id;
        }
        if (new_id < idOfOldestTagReceived)
        {
            NSLog(@"Changing id of Oldest Tag Received from %d to %d", idOfOldestTagReceived, new_id);
            idOfOldestTagReceived = new_id;
        }
        didAddTag = [self addTagWithCheck:tag withID:new_id];
	}
    [feedController setIndicatorWithID:0 animated:NO];
    [feedController setIndicatorWithID:1 animated:NO];
    if (lastViewController == feedController && didAddTag) // if currently viewing feed, force reload
        [lastViewController viewWillAppear:TRUE];
    //NSLog(@"loaded %d tags from kumulos", [theResults count]);
    
}

-(void)getNewerTagsThanID:(int)tagID {
    // because this gets called multiple times during scrollViewDidScroll, we have to save
    // the last request to try to minimize making duplicate requests
    if (tagID == idOfNewestTagReceived || // we always want to make this request
        pageOfLastNewerTagsRequest != tagID){
        pageOfLastNewerTagsRequest = tagID;
        //[feedController setIndicatorWithID:0 animated:YES];
        [k getAllTagsWithIDGreaterThanWithAllTagID:tagID andNumTags:[NSNumber numberWithInt:TAG_LOAD_WINDOW]];
    }
    else{
        //NSLog(@"Duplicate call to getNewerTagsThanID: id %d", tagID);
    }
}

-(void)getOlderTagsThanID:(int)tagID {
    if (pageOfLastOlderTagsRequest != tagID) {
        pageOfLastOlderTagsRequest = tagID;
        [k getAllTagsWithIDLessThanWithAllTagID:tagID andNumTags:[NSNumber numberWithInt:TAG_LOAD_WINDOW]];
    }
    else{
        //NSLog(@"Duplicate call to getOlderTagsThanID: id %d", tagID);
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDGreaterThanDidCompleteWithResult:(NSArray *)theResults {
    bool didAddTag = NO;
    int totalAdded = 0;
    // tags with IDs greater than idOfCurrentTag should go to the head of the array allTags
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [Tag getTagFromDictionary:d];
        NSLog(@"Tag stringID: %@", tag.stixStringID);
        id key = [d valueForKey:@"allTagID"];
        int new_id = [key intValue];
        if (new_id > idOfNewestTagReceived)
            idOfNewestTagReceived = new_id;
        //[tagViewController addCoordinateOfTag:tag];
        //[allTags setObject:tag forKey:key];
        didAddTag = [self addTagWithCheck:tag withID:new_id]; // insert newest key to head
        if (didAddTag)
            totalAdded = totalAdded+1;
	}
    // force reload of beginning. because of leftward scroll, we should advance the page viewed one to the left.
    // if we've added more than one page, the correct new page number is lastPageViewed+totalAdded-1.
    if (totalAdded>0)
    {
        [feedController.scrollView populateScrollPagesAtPage:feedController.lastPageViewed + totalAdded - 1]; 
        //NSLog(@"Added %d tags with id greater than current id at page %d", totalAdded, feedController.lastPageViewed);
    }
    [feedController setIndicatorWithID:0 animated:NO];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDLessThanDidCompleteWithResult:(NSArray *)theResults {
    bool didAddTag = NO;
    int totalAdded = 0;
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [Tag getTagFromDictionary:d];
        NSLog(@"Tag stringID: %@", tag.stixStringID);
        id key = [d valueForKey:@"allTagID"];
        int new_id = [key intValue];
        if (new_id < idOfOldestTagReceived)
            idOfOldestTagReceived = new_id;
        //[tagViewController addCoordinateOfTag:tag];
        didAddTag = [self addTagWithCheck:tag withID:new_id];
        if (didAddTag)
            totalAdded = totalAdded+1;
    }
    if (totalAdded>0) 
    {
        [feedController.scrollView populateScrollPagesAtPage:feedController.lastPageViewed]; // hack: forced reload of end
        //NSLog(@"Added %d tags with id less than current id at page %d", totalAdded, feedController.lastPageViewed);
    }
    [feedController setIndicatorWithID:1 animated:NO];
}

- (NSMutableArray *) getTags {
    return allTags;
}

-(void)didAddHistoryItemWithTagId:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andBadgeType:(int)type {
    [k addHistoryToPixWithTagID:tagID andUsername:name andComment:comment andBadgeType:type];
    // update comment count
    [self updateCommentCount:tagID];
}

-(int)getCommentCount:(int)tagID {
    NSNumber * commentCount = [allCommentCounts objectForKey:[NSNumber numberWithInt:tagID]];
    if (commentCount == nil)
        [k getAllHistoryWithTagID:tagID];
    else
        return [commentCount intValue];
    
    return 0;
}

-(void)updateCommentCount:(int)tagID {
    // get most recent comment count from kumulos
    [k getAllHistoryWithTagID:tagID];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllHistoryDidCompleteWithResult:(NSArray *)theResults{
    
    if ([theResults count] == 0)
        return;
    
    NSMutableDictionary * d = [theResults objectAtIndex:0];        
    NSNumber * tagID = [d valueForKey:@"tagID"];
    NSNumber * commentCount = [NSNumber numberWithInt:[theResults count]];
    
    [allCommentCounts setObject:commentCount forKey:tagID];

    [feedController forceUpdateCommentCount:[tagID intValue]];
}

/***** FriendViewDelegate ********/
-(void)didDismissFriendView {}; // only used in profileView
-(void) checkForUpdatePhotos {
    if (1) // todo: check for updated users by id
    {
        [friendController setIndicator:YES];
        
        [k getAllUsers];
    }
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults {
    [allUserPhotos removeAllObjects];
    for (NSMutableDictionary * d in theResults) {
        NSString * name = [d valueForKey:@"username"];
        UIImage * photo = [d valueForKey:@"photo"];
        [allUserPhotos setObject:photo forKey:name];
    }
    
    [friendController setIndicator:NO];
    //if (lastViewController == profileController) // if currently viewing friends, force reload
    //{
    //    [lastViewController viewWillAppear:TRUE];
    //}    
    if (lastViewController == profileController)
    {
        [profileController.friendController viewWillAppear:YES];
        [profileController updateFriendCount];
    }
    //NSLog(@"loaded %d new friends from kumulos", [theResults count]);
}

-(NSMutableDictionary * )getUserPhotos {
    return allUserPhotos;
}

/**** LoginSplashController delegate ****/

- (void) didLoginFromSplashScreen {
    [self.tabBarController dismissModalViewControllerAnimated:YES];
    loggedIn = YES; 
}

/**** ProfileViewController and login functions ****/

- (NSString *)coordinateArrayPath
{	
    return pathInDocumentDirectory(@"StixxUserData.data");
}

-(void)didCancelFirstTimeLogin {
    NSLog(@"FirstTimeLogin returned with cancel button");
}

- (void)showAlertWithTitle:(NSString *) title andMessage:(NSString*)message andButton:(NSString*)buttonMsg {
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:buttonMsg];
    [alert setTitle:title];
    [alert setMessage:message];
    [alert show];
    [alert release];
}
- (void) kumulosAPI:(kumulosProxy*)kumulos apiOperation:(KSAPIOperation*)operation didFailWithError:(NSString*)theError {
    //NSLog(@"Kumulos error: %@", theError);
#if 1
    if (lastViewController == feedController) { // currently on feed controller
        NSLog(@"Kumulos error in feedController: %@ - probably failed while trying to check for updated tags", theError);
        [self showAlertWithTitle:@"Error in connection" andMessage:@"Stix encountered an error while connecting." andButton:@"OK"];
    }
    if (lastViewController == tagViewController)
        NSLog(@"Kumulos error in tagViewController: %@", theError);
    if (lastViewController == profileController)
        NSLog(@"Kumulos error in profileController: %@ - probably failed while trying to call userLogin", theError);
#endif
}

- (void)didLoginWithUsername:(NSString *)name andPhoto:(UIImage *)photo andStix:(NSMutableDictionary *)stix andTotalTags:(int)total{
    loggedIn = YES;
    username = [name retain];
    userphoto = [photo retain];
    usertagtotal = total;
    
    NSLog(@"Username %@ with %d pix and image of %f %f", username, usertagtotal, userphoto.size.width, userphoto.size.height);

    NSString *path = [self coordinateArrayPath];
    [NSKeyedArchiver archiveRootObject:username toFile:path];
    
    if (![stix isKindOfClass:[NSMutableDictionary class]]) {
        [stix release];
        stix = [BadgeView generateDefaultStix];
    }
    
    [allStix removeAllObjects];
    NSEnumerator *e = [stix keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        [allStix setObject:[stix objectForKey:key] forKey:key];
        NSLog(@"Adding key %@ value %@", key, [stix objectForKey:key]);
    }
     
    //[allStix addEntriesFromDictionary:stix];
    NSLog(@"Setting delegate name to %@\n", username);
        
    [profileController updatePixCount];

    // DO NOT do this: opening a camera probably means the badgeView belonging to LoginSplashViewer was
    // deleted so now this is invalid. that badgeView does not need badgeLocations anyways
    //if (lastBadgeView)
    //    [lastBadgeView resetBadgeLocations];
    
    //[myStixController forceLoadMyStix];
    
    [feedController reloadCarouselView];
    [exploreController reloadCarouselView];
    //[myStixController reloadCarouselView];
    [tagViewController reloadCarouselView];
}

-(void)didLogout {
    loggedIn = NO;
    username = @"";
    if (userphoto) {
        [userphoto release];
        userphoto = nil;
    }
    usertagtotal = 0;
    [allStix removeAllObjects];
    [profileController updatePixCount];
    if (lastCarouselView)
        [lastCarouselView resetBadgeLocations];
    
    if (loginSplashController == nil) {
        loginSplashController = [[LoginSplashController alloc] init];
        [loginSplashController setDelegate:self];
    }
    [tabBarController presentModalViewController:loginSplashController animated:NO];
}

-(void)didChangeUserphoto:(UIImage *)photo {
    [self setUserphoto:photo];
}

-(int)getStixCount:(NSString*)stixStringID {
    //if (loggedIn)
    if ([stixStringID isEqualToString:@"FIRE"] || [stixStringID isEqualToString:@"ICE"])
        return -1;
    int ret = [[allStix objectForKey:stixStringID] intValue];
    //NSLog(@"Stix count for %@: %d", stixStringID, ret);
    return ret;
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixToUserDidCompleteWithResult:(NSArray*)theResults;
{
    // all debug
    for (NSMutableDictionary * d in theResults)
    {
        NSString * name = [d valueForKey:@"username"];
        NSLog(@"Updated stix counts for user %@", name);
    }    
}

-(void)didAddStixToPix:(Tag *)tag withStixStringID:(NSString*)stixStringID atLocation:(CGPoint)location{
    // find the correct tag in allTags;
    for (Tag* t in allTags) {
        if (t.tagID == tag.tagID)
            NSLog(@"Found tag %d", [t.tagID intValue]);
    }

    if ( ([stixStringID isEqualToString:@"FIRE"] || [stixStringID isEqualToString:@"ICE"]) && 
        ([tag.stixStringID isEqualToString:@"FIRE"] || [tag.stixStringID isEqualToString:@"ICE"]))
    {
        // increment/decrement fire and ice if it is the primary stix; do not change other stix counts
        if ([tag.stixStringID isEqualToString:stixStringID])
            tag.badgeCount++;
        else {
            tag.badgeCount--;
            if (tag.badgeCount < 0) {
                tag.badgeCount = -tag.badgeCount;
                if ([tag.stixStringID isEqualToString:@"FIRE"])
                    tag.stixStringID = @"ICE";
                else
                    tag.stixStringID = @"FIRE";
            }
        }
    }
    else {
        //if adding a gift stix, or adding fire or ice to a gift stix, add to the auxStix
        // array for the tag
        //[tag.auxStixStringIDs addObject:stixStringID];
        //[tag.auxLocations addObject:[NSValue valueWithCGPoint:location]];
        [tag addAuxiliaryStixOfType:stixStringID atLocation:location];
    }

    //[k updateStixWithAllTagID:[tag.tagID intValue] andScore:tag.badgeCount andType:tag.badgeType];
    NSMutableData *theAuxStixData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theAuxStixData];
	[encoder encodeObject:tag.auxLocations forKey:@"auxLocations"];
	[encoder encodeObject:tag.auxStixStringIDs forKey:@"auxStixStringIDs"];
    [encoder finishEncoding];
    [k updatePixWithAllTagID:[tag.tagID intValue] andScore:tag.badgeCount andStixStringID:tag.stixStringID andAuxStix:theAuxStixData];
    
    // update usertagtotal
    usertagtotal += 1;
    [k updateTotalTagsWithUsername:username andTotalTags:usertagtotal];
    
    //[k addHistoryToPixWithTagID:[tag.tagID intValue] andUsername:username andComment:@"" andBadgeType:type];
    [k addCommentToPixWithTagID:[tag.tagID intValue] andUsername:username andComment:@"" andStixStringID:stixStringID];
    
    // update comment count
    [self updateCommentCount:[tag.tagID intValue]];

    NSLog(@"Adding %@ stix to tag with id %d: new count %d.", tag.stixStringID, [tag.tagID intValue], tag.badgeCount);
}

-(NSString *) getUsername {
    if (loggedIn == YES)
    {
        NSLog(@"[delegate getUsername] returning %@", username);
        return username;
    }
    NSLog(@"[delegate getUsername] returning anonymous");
    return @"anonymous";
}

-(UIImage *) getUserPhoto {
    if ([self isLoggedIn] == NO)
        return [UIImage imageNamed:@"graphic_nouser.png"];
    return userphoto;
}

-(int)getUserTagTotal {
    return usertagtotal;
}

-(bool)isLoggedIn {
    return loggedIn;
}

-(void)didCreateBadgeView:(UIView *)newBadgeView {
    if (lastViewController != nil) {
        lastCarouselView = (CarouselView*) newBadgeView;
    }
}

/*** processing stix counts ***/

-(void)getUserInformation {
}

// debug
-(void)adminUpdateAllStixCountsToZero {

    NSMutableDictionary * stix = [[BadgeView generateDefaultStix] retain];   
    NSMutableData * data = [[KumulosData dictionaryToData:stix] retain];
    //[k addStixToUserWithUsername:username andStix:data];
    [k adminAddStixToAllUsersWithStix:data];

}


- (void)dealloc {
	
	//NEW COMMENT!
    [k release];
    [window release];
    [super dealloc];
}

@end
