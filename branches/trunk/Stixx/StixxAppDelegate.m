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
@synthesize configController;
@synthesize friendController;
@synthesize username;
@synthesize userphoto;
@synthesize lastViewController;
@synthesize allTags;
@synthesize timeStampOfMostRecentTag;
@synthesize allUserPhotos;
@synthesize k;

// INIT code
- (void)applicationDidFinishLaunching:(UIApplication *)application {  
    
    //username = [[NSString alloc] init];
    //username = @"Not logged in";
    NSLog(@"Name: %@", username);
    loggedIn = NO;
    
    k = [[Kumulos alloc]init];
    [k setDelegate:self];
    
	tabBarController = [[UITabBarController alloc] init];
    
    allTags = [[NSMutableArray alloc] init];
    allUserPhotos = [[NSMutableDictionary alloc] init];
    
	/***** create first view controller: the TagViewController *****/
 	tagViewController = [[TagViewController alloc] init];
	tagViewController.delegate = self;
	[tagViewController setCameraOverlayView:[tabBarController view]]; // allows camera to have the tabBar navigation as well as the badge/aperture/3d overlay
    
	NSString *path = [self coordinateArrayPath];
	NSLog(@"Trying to load from path %@", path);
    username = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!username)
    {
        username = @"anonymous";
        loggedIn = NO;
        NSLog(@"Nobody logged in!");
    }
    else
    {
        loggedIn = YES;
    }
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
    //[exploreController setDelegate:self];
	
	/***** create friends feed *****/
	friendController = [[FriendsViewController alloc] init];
    //	friendController.tagViewController = tagViewController;
    friendController.delegate = self;
	
	/***** create config view *****/
	configController = [[ConfigViewController alloc] init];
    [configController setUsernameLabel:username];
    configController.delegate = self;
    if (loggedIn)
        [configController loginWithUsername:username];
    
	/***** add view controllers to tab controller, and add tab to window *****/
	NSArray * viewControllers = [NSArray arrayWithObjects: feedController, exploreController, tagViewController, friendController, configController, nil];	
	[tabBarController setViewControllers:viewControllers];
	[tabBarController setDelegate:self];
    
    lastViewController = feedController;
    [window addSubview:[tabBarController view]];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
    
    // force login
    if (!loggedIn)
    {
        [self showAlertWithTitle:@"Welcome!" andMessage:@"Because this is your first time, please login or create an account!" andButton:@"ok"];
        LoginViewController * loginController = [[[LoginViewController alloc] init] autorelease];
        loginController.delegate = self;
        [loginController.cancelButton setTitle:@"Later" forState:UIControlStateNormal];
        [configController presentModalViewController:loginController animated:YES];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (lastViewController == tagViewController)
    {
        [tagViewController dismissModalViewControllerAnimated:NO];
    }
    if (lastViewController == friendController) // if we leave friend controller, start an update for next time
    {
        [self checkForUpdatePhotos];
    }
	[viewController viewWillAppear:TRUE];
    lastViewController = viewController;
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
    NSData * img = UIImagePNGRepresentation([newTag image]);
    int x = [[newTag badge_x] intValue];
    int y = [[newTag badge_y] intValue];
    
    NSMutableData *theData;
    NSKeyedArchiver *encoder;
    theData = [NSMutableData data];
    encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
	[encoder encodeObject:newTag.coordinate forKey:@"coordinate"];
    [encoder finishEncoding];
    [k addTagWithUsername:newTag.username andComment:newTag.comment andImage:img andBadge_x:x andBadge_y:y andTagCoordinate:(NSData*)theData];
    
    [encoder release];    
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addTagDidCompleteWithResult:(NSNumber*)newRecordID
{
    [newestTag setTagID:newRecordID];
    //[allTags addObject:newestTag];
    bool added = [self addTagWithCheck:newestTag withID:[newRecordID intValue]];
    if (added)
        NSLog(@"Added new record to kumulos: tag id %d", [newRecordID intValue]);
    else
        NSLog(@"Error! New record has duplicate tag id: %d", [newRecordID intValue]);
}

-(Tag*)getTagFromDictionary:(NSMutableDictionary *)d {
    // 
    
    NSString * name = [d valueForKey:@"username"];
    NSString * comment = [d valueForKey:@"comment"];
    UIImage * image = [[UIImage alloc] initWithData:[d valueForKey:@"image"]];
    int badge_x = [[d valueForKey:@"badge_x"] intValue];
    int badge_y = [[d valueForKey:@"badge_y"] intValue];
    NSMutableData *theData = (NSMutableData*)[d valueForKey:@"tagCoordinate"];
    NSKeyedUnarchiver *decoder;
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
    ARCoordinate * coordinate = [decoder decodeObjectForKey:@"coordinate"];
    [decoder finishDecoding];
    [decoder release];    
    Tag * tag = [tagViewController createTagWithName:name andComment:comment andImage:image andBadge_X:badge_x andBadge_Y:badge_y andCoordinate:coordinate];
    tag.tagID = [d valueForKey:@"allTagID"];
    //tag.timestring = [d valueForKey:@"timeCreated"];
    tag.timestamp = [d valueForKey:@"timeCreated"];
    [image release];
    return tag;
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
        Tag * tag = [self getTagFromDictionary:d];
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
    NSLog(@"loaded %d tags from kumulos", [theResults count]);
    
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
    else
        NSLog(@"Duplicate call to getNewerTagsThanID: id %d", tagID);
}

-(void)getOlderTagsThanID:(int)tagID {
    if (pageOfLastOlderTagsRequest != tagID) {
        pageOfLastOlderTagsRequest = tagID;
        [feedController setIndicatorWithID:1 animated:YES];
        [k getAllTagsWithIDLessThanWithAllTagID:tagID andNumTags:[NSNumber numberWithInt:TAG_LOAD_WINDOW]];
    }
    else
        NSLog(@"Duplicate call to getOlderTagsThanID: id %d", tagID);
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDGreaterThanDidCompleteWithResult:(NSArray *)theResults {
    bool didAddTag = NO;
    int totalAdded = 0;
    // tags with IDs greater than idOfCurrentTag should go to the head of the array allTags
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [self getTagFromDictionary:d];
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
        NSLog(@"Added %d tags with id greater than current id at page %d", totalAdded, feedController.lastPageViewed);
    }
    [feedController setIndicatorWithID:0 animated:NO];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDLessThanDidCompleteWithResult:(NSArray *)theResults {
    bool didAddTag = NO;
    int totalAdded = 0;
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [self getTagFromDictionary:d];
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
        NSLog(@"Added %d tags with id less than current id at page %d", totalAdded, feedController.lastPageViewed);
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
    NSLog(@"loaded %d new friends from kumulos", [theResults count]);
}

-(NSMutableDictionary * )getUserPhotos {
    return allUserPhotos;
}

/**** ConfigViewController and login functions ****/

- (NSString *)coordinateArrayPath
{	
    return pathInDocumentDirectory(@"StixxUserData.data");
}

// LoginViewDelegate
- (void)loginSuccessfulWithName:(NSString *)name {
    username = name;
    [feedController setUsernameLabel:username];
    [configController setUsernameLabel:username]; // must be done in case viewWillAppear is called in configController with old username
    //if (photo)
    //[configController setPhoto:photo];
    [configController loginWithUsername:name];
    loggedIn = YES;
}

- (NSString*)getCurrentUsername {
    if (loggedIn == YES)
        return username;
    return @"anonymous";
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
    if (lastViewController == configController)
        NSLog(@"Kumulos error in configController: %@ - probably failed while trying to call userLogin", theError);
}

- (void)dealloc {
	
	//NEW COMMENT!
    [k release];
    [window release];
    [super dealloc];
}


@end
