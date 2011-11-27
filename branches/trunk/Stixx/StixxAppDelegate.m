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
@synthesize username;
@synthesize userphoto;
@synthesize usertagtotal;
@synthesize lastViewController;
@synthesize allTags;
@synthesize timeStampOfMostRecentTag;
@synthesize allUserPhotos;
@synthesize allStix;
@synthesize k;
@synthesize lastBadgeView;

// INIT code
- (void)applicationDidFinishLaunching:(UIApplication *)application {  
    
    k = [[Kumulos alloc]init];
    [k setDelegate:self];
    
#if 1
	tabBarController = [[RaisedCenterTabBarController alloc] init];
    tabBarController.myDelegate = self;
#else
	tabBarController = [[UITabBarController alloc] init];
#endif
    allTags = [[NSMutableArray alloc] init];
    allUserPhotos = [[NSMutableDictionary alloc] init];
    allStix = [[NSMutableArray alloc] init];
    [allStix insertObject:[NSNumber numberWithInt:0] atIndex:BADGE_TYPE_FIRE];
    [allStix insertObject:[NSNumber numberWithInt:0] atIndex:BADGE_TYPE_ICE];
    
	/***** create first view controller: the TagViewController *****/
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
    [self checkForUpdatePhotos];
    
	/***** create feed view *****/
	feedController = [[FeedViewController alloc] init];
    [feedController setDelegate:self];
    [feedController setUsernameLabel:username];
    //[feedController setIndicator:YES];
    feedController.allTags = allTags;
    
    /***** create explore view *****/
    exploreController = [[ExploreViewController alloc] init];
    exploreController.delegate = self;
	
	/***** create friends feed *****/
	friendController = [[FriendsViewController alloc] init];
    //	friendController.tagViewController = tagViewController;
    friendController.delegate = self;
	
	/***** create config view *****/
	profileController = [[ProfileViewController alloc] init];
    profileController.delegate = self;
    NSString *path = [self coordinateArrayPath];
	NSLog(@"Trying to load from path %@", path);
    username = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    loggedIn = NO;
    if (!username)
    {
        // force login
        [profileController firstTimeLogin];
    }
    else
    {
        NSLog(@"Loggin in as %@", username);
        [profileController loginWithUsername:username];
    }   
	/***** add view controllers to tab controller, and add tab to window *****/
	NSArray * viewControllers = [NSArray arrayWithObjects: feedController, exploreController, tagViewController, friendController, profileController, nil];	
	//NSArray * viewControllers = [NSArray arrayWithObjects: tagViewController, nil];	
	[tabBarController setViewControllers:viewControllers];
	[tabBarController setDelegate:self];
    
    lastViewController = feedController;
    lastBadgeView = feedController.badgeView;
    [window addSubview:[tabBarController view]];
    
    [tabBarController addCenterButtonWithImage:[UIImage imageNamed:@"tab_addstix.png"] highlightImage:nil];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (lastViewController == tagViewController)
    {
        [tagViewController dismissModalViewControllerAnimated:NO];
        lastBadgeView = [tagViewController badgeView];
    }
    if (lastViewController == friendController) // if we leave friend controller, start an update for next time
    {
        [self checkForUpdatePhotos];
        lastBadgeView = [friendController badgeView];
    }
    if (lastViewController == feedController)
    {
        lastBadgeView = [feedController badgeView];
    }
    if (lastViewController == exploreController)
    {
        lastBadgeView = [exploreController badgeView];
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
	NSString *path = [self coordinateArrayPath];
	//NSLog(@"Saving coordinate array to path %@", path);
	// Get the possession list 
	//NSMutableArray *tempLocationArray = [tagViewController getCoordinates];
	// Archive possession list to file
	//[NSKeyedArchiver archiveRootObject:tempLocationArray toFile:path]; 
    
    // archive username
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

-(void)addTag:(Tag *)newTag {
    // when adding a tag, we add it to both our local tag structure, and to kumulos database
    //[allTags addObject:newTag];
    newestTag = [newTag retain];
    
    [k setDelegate:self];
    NSData * img = UIImageJPEGRepresentation([newTag image], .8); //UIImagePNGRepresentation([newTag image]);
    int x = newTag.badge_x;
    int y = newTag.badge_y;
    int type = newTag.badgeType;
    int count = newTag.badgeCount;
    
    NSMutableData *theData;
    NSKeyedArchiver *encoder;
    theData = [NSMutableData data];
    encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	[encoder encodeObject:newTag.coordinate forKey:@"coordinate"];
    [encoder finishEncoding];
    // this is the old kumulos call that didn't include location
    //[k addStixWithUsername:newTag.username andComment:newTag.comment andImage:img andBadge_x:x andBadge_y:y andTagCoordinate:theData andType:type andScore:count];
    [k addNewStixWithUsername:username andComment:newTag.comment andLocationString:newTag.locationString andImage:img andBadge_x:x andBadge_y:y andTagCoordinate:theData andType:type andScore:count];
    [encoder release];  
}

//- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addTagDidCompleteWithResult:(NSNumber*)newRecordID
//- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixDidCompleteWithResult:(NSNumber*)newRecordID
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
    
    // update usertagtotal
    usertagtotal += 1;
    [k updateTotalTagsWithUsername:username andTotalTags:usertagtotal];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateTotalTagsDidCompleteWithResult:(NSNumber*)affectedRows {
    NSLog(@"Updated user tag totals: affect rows %d\n", [affectedRows intValue]);
    [profileController updateStixCount];
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
        Tag * tag = [[Tag getTagFromDictionary:d] retain];
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
        [tag release];
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
        [feedController setIndicatorWithID:0 animated:YES];
        [k getAllTagsWithIDGreaterThanWithAllTagID:tagID andNumTags:[NSNumber numberWithInt:TAG_LOAD_WINDOW]];
    }
    else{
        //NSLog(@"Duplicate call to getNewerTagsThanID: id %d", tagID);
    }
}

-(void)getOlderTagsThanID:(int)tagID {
    if (pageOfLastOlderTagsRequest != tagID) {
        pageOfLastOlderTagsRequest = tagID;
        [feedController setIndicatorWithID:1 animated:YES];
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

// feedView delegate functions
- (NSMutableArray *) getTags {
    return allTags;
}

/***** FriendViewDelegate ********/

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
    if (lastViewController == friendController) // if currently viewing friends, force reload
        [lastViewController viewWillAppear:TRUE];
    
    if (lastViewController == profileController)
    {
        [profileController updateFriendCount];
    }
    //NSLog(@"loaded %d new friends from kumulos", [theResults count]);
}

-(NSMutableDictionary * )getUserPhotos {
    return allUserPhotos;
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
    
    if (lastViewController == feedController) { // currently on feed controller
        NSLog(@"Kumulos error in feedController: %@ - probably failed while trying to check for updated tags", theError);
        [self showAlertWithTitle:@"Error in connection" andMessage:@"Could not access online database. Please reload this page." andButton:@"OK"];
    }
    if (lastViewController == tagViewController)
        NSLog(@"Kumulos error in tagViewController: %@", theError);
    if (lastViewController == profileController)
        NSLog(@"Kumulos error in profileController: %@ - probably failed while trying to call userLogin", theError);
}

- (void)didLoginWithUsername:(NSString *)name andPhoto:(UIImage *)photo andStix:(NSMutableArray *)stix andTotalTags:(int)total{
    [feedController setUsernameLabel:name];
    //[profileController setUsernameLabel:username]; // must be done in case viewWillAppear is called in profileController with old username
    NSLog(@"Setting delegate name to %@", name);
    loggedIn = YES;
    username = name;
    userphoto = [photo retain];
    usertagtotal = total;
    [allStix removeAllObjects];
    [allStix addObjectsFromArray:stix];
        
    // also process
    [k processStixUpdatesWithUsername:name];

    [profileController updateStixCount];
    [lastBadgeView resetBadgeLocations];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation processStixUpdatesDidCompleteWithResult:(NSArray*)theResults {
    
    int changes[2];
    changes[BADGE_TYPE_FIRE] = 0;
    changes[BADGE_TYPE_ICE] = 0;
    for (NSMutableDictionary * d in theResults)
    {
        NSString * name = [d valueForKey:@"username"];
        if ([name isEqualToString:username] == NO)
        {
            NSLog(@"Whoops! Stix Update for wrong user is being processed...fix it!");
            continue;
        }
        int badgeType = [[d valueForKey:@"type"] intValue];
        int changeCt = [[d valueForKey:@"count"] intValue];
        
        changes[badgeType] += changeCt;
    } 
    int ct = [[allStix objectAtIndex:BADGE_TYPE_FIRE] intValue];
    [allStix replaceObjectAtIndex:BADGE_TYPE_FIRE withObject:[NSNumber numberWithInt:ct + changes[BADGE_TYPE_FIRE]]];
    NSLog(@"Changed fire badges from %d to %d\n", ct, ct+changes[BADGE_TYPE_FIRE]);
    ct = [[allStix objectAtIndex:BADGE_TYPE_ICE] intValue];
    [allStix replaceObjectAtIndex:BADGE_TYPE_ICE withObject:[NSNumber numberWithInt:ct + changes[BADGE_TYPE_ICE]]];
    NSLog(@"Changed ice badges from %d to %d\n", ct, ct+changes[BADGE_TYPE_ICE]);
    
    [k addStixToUserWithUsername:username andStix:[profileController arrayToData:allStix]];
    
    [lastBadgeView updateStixCounts];
    [profileController updateStixCount];
}

-(void)didChangeUserphoto:(UIImage *)photo {
    [self setUserphoto:photo];
}

-(int)getStixCount:(int)type {
    //if (loggedIn)
    {
        return [[allStix objectAtIndex:type] intValue];
    }
    return -1;
}

-(int)incrementStixCount:(int)type forUser:(NSString *)name{
    // increment stix count of user
    int ret = -1;
    int ct = 0;
    /*
    if ([name isEqualToString:@"anonymous"])
    {
        int ct = [[allStix objectAtIndex:type] intValue];
        // anonymous users cannot get increases in stix count
        //ct = ct + 1;
        //[allStix replaceObjectAtIndex:type withObject:[NSNumber numberWithInt:ct]];
        ret = ct;
    } 
    else if ([name isEqualToString:username])
     */
    if ([name isEqualToString:username])
    {
        // if the person being incremented is the current user, change allStix first,
        // then submit a stixCountChange to kumulos
        if (type == BADGE_TYPE_FIRE || type == BADGE_TYPE_ICE)
        {
            ct = [[allStix objectAtIndex:type] intValue];
            ct = ct + 1;
            [allStix replaceObjectAtIndex:type withObject:[NSNumber numberWithInt:ct]];
            ret = ct;
#if 0         
            // add to kumulos. todo: also error check
            //NSMutableData * data = [[profileController arrayToData:allStix] retain];
            //[k addStixToUserWithUsername:name andStix:data];
            //[data release];
#endif
            NSLog(@"Increment my %@ stix count for user %@ to %d", type==BADGE_TYPE_FIRE?@"Fire":@"Ice", name, ct);
        }
    }
    if ([name isEqualToString:@"anonymous"] == NO)
        [k addStixUpdateToQueueWithUsername:name andType:type andCount:1];
    return ret;
}

-(int)decrementStixCount:(int)type forUser:(NSString *)name{
    // decrement stix count of user
    int ret = -1;
    int ct = 0;
    /*
    if ([name isEqualToString:@"anonymous"])
    {
        int ct = [[allStix objectAtIndex:type] intValue];
        ct = ct - 1;
        [allStix replaceObjectAtIndex:type withObject:[NSNumber numberWithInt:ct]];
        ret = ct;
    } 
    else if ([name isEqualToString:username])
    */
    if ([name isEqualToString:username])
    {
        if (type == BADGE_TYPE_FIRE || type == BADGE_TYPE_ICE)
        {
            ct = [[allStix objectAtIndex:type] intValue];
            ct = ct - 1;
            [allStix replaceObjectAtIndex:type withObject:[NSNumber numberWithInt:ct]];
            ret = ct;
#if 0  
            // add to kumulos. todo: also error check
            NSMutableData * data = [[profileController arrayToData:allStix] retain];
            [k addStixToUserWithUsername:name andStix:data];
            //[data release]; // do not release data here - must be added to stix
#endif
            NSLog(@"Decrement my %@ stix count for user %@ to %d", type==BADGE_TYPE_FIRE?@"Fire":@"Ice", name, ct);
        }
    }
    if ([name isEqualToString:@"anonymous"] == NO)
        [k addStixUpdateToQueueWithUsername:name andType:type andCount:-1];
    return ret;
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixToUserDidCompleteWithResult:(NSArray*)theResults;
{
    // all debug
    for (NSMutableDictionary * d in theResults)
    {
        NSString * name = [d valueForKey:@"username"];
        NSMutableArray * stix = [profileController dataToArray:[d valueForKey:@"stix"]];
        NSLog(@"Updated stix counts for user %@: %d fire and %d ice", name, [[stix objectAtIndex:BADGE_TYPE_FIRE] intValue],  [[stix objectAtIndex:BADGE_TYPE_ICE] intValue]);
    }    
}


-(void)didAddStixToTag:(Tag *) tag withType:(int)type {
    // find the correct tag in allTags;
    for (Tag* t in allTags) {
        if (t.tagID == tag.tagID)
            NSLog(@"Found tag %d", [t.tagID intValue]);
    }
    if (tag.badgeType == type)
        tag.badgeCount++;
    else {
        tag.badgeCount--;
        if (tag.badgeCount < 0) {
            tag.badgeCount = -tag.badgeCount;
            tag.badgeType = [lastBadgeView getOppositeBadgeType:tag.badgeType];
        }
    }

    // todo: add kumulos:updateStixWithCount
    [k updateStixWithAllTagID:[tag.tagID intValue] andScore:tag.badgeCount andType:tag.badgeType];
    
    NSLog(@"Adding %@ stix to tag with id %d: new count %d.", tag.badgeType == BADGE_TYPE_FIRE?@"Fire":@"Ice", [tag.tagID intValue], tag.badgeCount);
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
    return userphoto;
}

-(int)getUserTagTotal {
    return usertagtotal;
}

-(bool)isLoggedIn {
    return loggedIn;
}

-(UIView*)didCreateBadgeView:(UIView*)newBadgeView; {
    if (lastViewController != nil) {
        lastBadgeView = (BadgeView*) newBadgeView;
    }
    return lastBadgeView;
}

- (void)dealloc {
	
	//NEW COMMENT!
    [k release];
    [window release];
    [super dealloc];
}

@end
