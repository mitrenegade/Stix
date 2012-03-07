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
#import "Kiip.h"

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
@synthesize myUserInfo;
@synthesize lastViewController;
@synthesize allTags;
@synthesize timeStampOfMostRecentTag;
@synthesize allUserPhotos;
@synthesize allStix;
@synthesize allStixOrder;
@synthesize allFriends;
@synthesize k;
@synthesize lastCarouselView;
@synthesize allCommentCounts;
@synthesize allCarouselViews;
@synthesize loadingMessage;
@synthesize alertQueue;
@synthesize camera;
@synthesize storeViewController;
@synthesize storeViewShell;
#if USING_FACEBOOK
@synthesize facebook;
#endif
static const int levels[6] = {0,0,5,10,15,20};
static int init=0;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    versionStringStable = @"0.7.6";
    versionStringBeta = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; //@"0.7.7.4";
    
    /*** Kumulos service ***/
    
    k = [[Kumulos alloc]init];
    [k setDelegate:self];
    
    // Override point for customization after application launch
    [loadingMessage setText:@"Connecting to Stix Server..."];
    
    [window makeKeyAndVisible];
    
    myUserInfo = malloc(sizeof(struct UserInfo));

    /*** Parse service ***/
    /*
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    [testObject setObject:@"bar" forKey:@"foo"];
    [testObject save];
    */
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];    
    
    /*** Kiip service ***/
#if USING_KIIP
    // Start and initialize when application starts
    KPManager* manager = [[KPManager alloc] initWithKey:@"4a46c4944e118f390cdd0dd8dd75e2c9" secret:@"ed6b5b8b4060c2d81d8d3b30544b1f3d"];
    // Set the shared instance after initialization
    // to allow easier access of the object throughout the project.
    [KPManager setSharedManager:manager];
    [manager release];
#endif
    
    /*** Facebook service ***/
#if USING_FACEBOOK
    facebook = [[Facebook alloc] initWithAppId:@"191699640937330" andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![facebook isSessionValid]) {
        [facebook authorize:nil];
    }
#endif
    
	/***** create first view controller: the TagViewController *****/
    [loadingMessage setText:@"Initializing camera..."];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    camera = [[UIImagePickerController alloc] init];
    camera.navigationBarHidden = YES;
    camera.toolbarHidden = YES; // prevents bottom bar from being displayed
    camera.allowsEditing = NO;
    camera.wantsFullScreenLayout = NO;
#if !TARGET_IPHONE_SIMULATOR
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto; 
    camera.showsCameraControls = NO;
#else
    camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#endif    
    // create an empty main controller in order to turn on camera
    mainController = [[UIViewController alloc] init];
    [window addSubview:mainController.view];

    /* load stix types, stix views, user info, and check for version */
    
    [self checkVersion];
    stixViewsLoadedFromDisk = [self loadDataFromDisk];
    // to force loading stix data from kumulos, set stixViewsLoadedFromDisk to 0
    //stixViewsLoadedFromDisk = 0;
    if (stixViewsLoadedFromDisk)
        init++;
//    [self initializeBadges];
    [BadgeView InitializeGenericStixTypes];

    [self performSelectorInBackground:@selector(initializeBadges) withObject:nil];
    //[self initializeBadges];
    
	tabBarController = [[RaisedCenterTabBarController alloc] init];
    tabBarController.myDelegate = self;
    
    allTags = [[NSMutableArray alloc] init];
    allUserPhotos = [[NSMutableDictionary alloc] init];
    allStix = [[NSMutableDictionary alloc] init];
    allStixOrder = [[NSMutableDictionary alloc] init];
    allFriends = [[NSMutableSet alloc] init];
    allCommentCounts = [[NSMutableDictionary alloc] init];
    allCarouselViews = [[NSMutableArray alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    [mainController presentModalViewController:camera animated:YES];
#else
    [mainController presentModalViewController:tabBarController animated:YES];
#endif
    // tagView subview is never added to the window but only used as an overlay for camera
  	tagViewController = [[TagViewController alloc] init];
	tagViewController.delegate = self;
    //[window addSubview:tagViewController.view];
    camera.delegate = tagViewController;
    tagViewController.camera = camera;
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tagViewController.view];
#endif
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
    //[loadingMessage setText:@"Loading feed..."];
    
	//feedController = [[FeedViewController alloc] init];
    feedController = [[VerticalFeedController alloc] init];
    [feedController setDelegate:self];
    feedController.allTags = allTags;
    feedController.tabBarController = tabBarController;
    feedController.camera = camera; // hack: in order to present modal controllers that respond 
    
#endif
    
#if 1
    /***** create explore view *****/
    exploreController = [[ExploreViewController alloc] init];
    exploreController.delegate = self;
	
	/***** create friends feed *****/
    //[loadingMessage setText:@"Networking with friends..."];
	friendController = [[FriendsViewController alloc] init];
    friendController.delegate = self;
    [self checkForUpdatePhotos];
    
    /***** create mystix view *****/
    //myStixController = [[MyStixViewController alloc] init];
    //myStixController.delegate = self;
    
    /***** create stixstore view ***/
    //coverflowController = [[CoverflowViewController alloc] init];
    storeViewController = [[StoreViewController alloc] init];
    storeViewController.delegate = self;
    storeViewShell = [[StoreViewShell alloc] init];
    [storeViewShell setCamera:self.camera];
    [storeViewShell setStoreViewController:storeViewController];
    
	/***** create config view *****/
	profileController = [[ProfileViewController alloc] init];
    profileController.delegate = self;
    [profileController setCamera:self.camera];
    [profileController setFriendController:friendController];
#endif
    
    /***** add view controllers to tab controller, and add tab to window *****/
    UIViewController * emptyview = [[UIViewController alloc] init];
    UITabBarItem *tbi = [emptyview tabBarItem];
    [tbi setTitle:@"Stix"];
	NSArray * viewControllers = [NSArray arrayWithObjects: feedController, exploreController, emptyview, storeViewShell, profileController, nil];
    [tabBarController setViewControllers:viewControllers];
	[tabBarController setDelegate:self];
    [emptyview release];
    
    lastViewController = feedController;
    lastCarouselView = feedController.carouselView;
    //[window addSubview:[tagViewController view]];
    //[tagViewController.view addSubview:tabBarController.view];
    //[window addSubview:[tabBarController view]];
    
    [tabBarController addCenterButtonWithImage:[UIImage imageNamed:@"tab_addstix.png"] highlightImage:[UIImage imageNamed:@"tab_addstix_on.png"]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tabBarController.view];
#endif
    
    loginSplashController = [[LoginSplashController alloc] init];
    [loginSplashController setDelegate:self];
    myUserInfo->userphoto = nil;
    myUserInfo->bux = 0;
    myUserInfo->usertagtotal = 0;
    loggedIn = NO;
    isLoggingIn = NO;
    if (!myUserInfo->username || [myUserInfo->username length] == 0)
    {
        NSLog(@"Could not log in: forcing new login screen!");
        // force login
        //        loginSplashController = [[LoginSplashController alloc] init];
        //        [loginSplashController setDelegate:self];
        [loginSplashController setCamera:self.camera];
        isLoggingIn = YES;
        loggedIn = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
        [camera setCameraOverlayView:loginSplashController.view];
#endif
        isLoggingIn = NO;
    }
    else
    {
        NSLog(@"Loggin in as %@", myUserInfo->username);
        //[loadingMessage setText:[NSString stringWithFormat:@"Logging in as %@...", username]];
        [profileController loginWithUsername:myUserInfo->username];
    }   
	
    /* display versioning info */
    if (versionIsOutdated)
    {
        [self showAlertWithTitle:@"Update Available" andMessage:[NSString stringWithFormat:@"This version of Stix (v%@) is out of date. Version %@ is available through TestFlight.", versionStringStable, currVersion] andButton:@"Close" andOtherButton:@"View" andAlertType:ALERTVIEW_UPGRADE];
        
        // register for notifications on update channel
        [self Parse_subscribeToChannel:@"StixUpdates"];
    }
    
    /* add administration calls here */
    
    return YES;
}

/*** Facebook api calls ***/
// Pre 4.2 support
#if USING_FACEBOOK
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}
#endif

/*** Versioning ***/

-(void)checkVersion {
    versionIsOutdated = 0;
    [k getAppInfoWithInfoType:@"version"];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAppInfoDidCompleteWithResult:(NSArray *)theResults {
    if ([theResults count] == 0)
    {
        [k createAppInfoWithInfoType:@"version" andStringInfo:versionStringStable andIntegerInfo:0];
    }
    else {
        NSMutableDictionary * d = [theResults objectAtIndex:0];
        currVersion = [[d valueForKey:@"stringInfo"] copy];
        if (currVersion == nil)
            [k updateAppInfoWithInfoType:@"version" andStringInfo:versionStringStable andIntegerInfo:0];
        else
        {
            NSString * resultTxt = @"EQUAL";
            NSComparisonResult result = [versionStringStable compare:currVersion];
            if (result == NSOrderedDescending) {
                // this version is higher than highest kumulos 
                [k updateAppInfoWithInfoType:@"version" andStringInfo:versionStringStable andIntegerInfo:0];
                resultTxt = @"NEWER";
            }
            else if (result == NSOrderedAscending) {
                // this version is outdated
                versionIsOutdated = 1;
                resultTxt = @"OLDER";
            }
            NSLog(@"Your version: %@ Kumulos version: %@ comparison: %@", versionStringStable, currVersion, resultTxt);
        }
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Tell Parse about the device token.
    [PFPush storeDeviceToken:newDeviceToken];
    // Subscribe to the global broadcast channel.
    [PFPush subscribeToChannelInBackground:@""];
}

-(void)initializeBadges {
    //[BadgeView InitializeGenericStixTypes];
    //[self showAlertWithTitle:@"Initializing badges" andMessage:@"We are checking for new badges. Please be patient" andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];

    // load all stix types from Kumulos - doesn't take much
    [k getAllStixTypes];
    if (!stixViewsLoadedFromDisk)
        [k getAllStixViews];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getStixDataByStixStringIDDidCompleteWithResult:(NSArray *)theResults {
    if ([theResults count] == 0)
        NSLog(@"Could not find a stix data! May be missing in Kumulos.");
    [BadgeView AddStixView:theResults];
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllStixTypesDidCompleteWithResult:(NSArray *)theResults {     
    // initialize stix types for all badge views
    [BadgeView InitializeStixTypes:theResults];
    NSLog(@"All %d Stix types initialized from kumulos!", [BadgeView totalStixTypes]);
    init++;
    if (stixViewsLoadedFromDisk)
    {
        // consolidate all stix types with stix views and load any stixViews that weren't loaded
        NSMutableDictionary * stixViews = [BadgeView GetAllStixViewsForSave];
        NSLog(@"%d views loaded from disk; %d types loaded from Kumulos", [stixViews count], [theResults count]);
        for (int i=0; i<[BadgeView totalStixTypes]; i++) {
            NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
            UIImageView * stixView = [stixViews objectForKey:stixStringID];
            
            if (stixView == nil) {
                [k getStixDataByStixStringIDWithStixStringID:stixStringID];
            }
        }
    }

    if (init >= 2) {
        //[self continueInit];
        [self reloadAllCarousels];
    }
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllStixViewsDidCompleteWithResult:(NSArray *)theResults {
    [BadgeView InitializeStixViews:theResults];
    NSLog(@"All %d Stix data initialized from kumulos!", [theResults count]);
    init++;
    if (init >= 2) {
        [self reloadAllCarousels];
        //[self continueInit];
    }
}
    
- (void) saveDataToDisk {
    NSString * path = [self coordinateArrayPath];
 	
    NSMutableDictionary * rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue: myUserInfo->username forKey:@"username"];

    @try {
        // save stix types that we know about
        NSMutableArray * stixStringIDs = [BadgeView GetAllStixStringIDsForSave];
        NSMutableDictionary * stixViews = [BadgeView GetAllStixViewsForSave];
        NSMutableDictionary * stixDescriptors = [BadgeView GetAllStixDescriptorsForSave];
        NSMutableDictionary * stixLikelihoods = [BadgeView GetAllStixLikelihoodsForSave];
        NSMutableDictionary * stixCategories = [BadgeView GetAllStixCategoriesForSave];
        
        [rootObject setValue:stixStringIDs forKey:@"stixStringIDs"];
        [rootObject setValue:stixViews forKey:@"stixViews"];
        [rootObject setValue:stixDescriptors forKey:@"stixDescriptors"];
        [rootObject setValue:stixLikelihoods forKey:@"stixLikelihoods"];
        [rootObject setValue:stixCategories forKey:@"stixCategories"];
        
        [NSKeyedArchiver archiveRootObject: rootObject toFile: path];
    } 
    @catch (NSException *exception) {
        NSLog(@"SaveDataToDisk encountered an exception! %@", [exception reason]);
    }
}

- (int) loadDataFromDisk {
    // returns 0 if no stixViews loaded, 1 if stixViews were loaded from disk
    NSString     * path         = [self coordinateArrayPath];
    NSDictionary * rootObject;
    
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    // backwards compatibility
    if (![rootObject isKindOfClass:[NSDictionary class]]) {
        myUserInfo->username = nil;
        return 0;
    }
    myUserInfo->username = [[rootObject valueForKey:@"username"] copy];
    
    @try {
        NSMutableArray * stixStringIDs = [rootObject valueForKey:@"stixStringIDs"];
        NSMutableDictionary * stixViews = [rootObject valueForKey:@"stixViews"];
        NSMutableDictionary * stixDescriptors = [rootObject valueForKey:@"stixDescriptors"];
        NSMutableDictionary * stixLikelihoods = [rootObject valueForKey:@"stixLikelihoods"];
        NSMutableDictionary * stixCategories = [rootObject valueForKey:@"stixCategories"];
        
        if (stixViews != nil)
        {
            NSLog(@"Loading %d saved Stix from disk", [stixViews count]);
            [BadgeView InitializeFromDiskWithStixStringIDs:stixStringIDs andStixViews:stixViews andStixDescriptors:stixDescriptors andStixLikelihoods:stixLikelihoods andStixCategories:stixCategories];
            return 1;
        }
        else
            NSLog(@"No Stix were saved to disk!");
        return 0;
    }
    @catch (NSException * exception) {
        NSLog(@"LoadSavedDataFromDisk encountered an exception %@:", [exception reason]);
        return 0;
    }
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (lastViewController == viewController)
        return;
    
    if (viewController == storeViewShell) {
        [storeViewShell setLastController:lastViewController];
            [self.tabBarController toggleFirstTimeInstructions:NO];
            [self.tabBarController toggleStixMallPointer:NO];
            
            //NSMutableDictionary * auxInfo = [[NSMutableDictionary alloc] init];
            //NSNumber * isFirstTimeUser = [NSNumber numberWithBool:myUserInfo->isFirstTimeUser];
            //NSNumber * hasAccessedStore = [NSNumber numberWithBool:myUserInfo->hasAccessedStore];
            //[auxInfo setValue:isFirstTimeUser forKey:@"isFirstTimeUser"];
            //[auxInfo setValue:hasAccessedStore forKey:@"hasAccessedStore"];
            //NSData * auxData = [KumulosData dictionaryToData:auxInfo];
            //[k updateAuxiliaryDataWithUsername:[self getUsername] andAuxiliaryData:auxData];
    }
    
    if (lastViewController == tagViewController)
    {
        [self.tabBarController setButtonStateNormal]; // disable highlighted button
        [tagViewController dismissModalViewControllerAnimated:NO];
        lastCarouselView = [tagViewController.descriptorController carouselView];
        [viewController viewWillAppear:TRUE];
        lastViewController = viewController;
    }
    else if (lastViewController == friendController) // if we leave friend controller, start an update for next time
    {
        [self checkForUpdatePhotos];
        //lastCarouselView = [friendController carouselView];
        [viewController viewWillAppear:TRUE];
        lastViewController = viewController;
    }
    else if (lastViewController == feedController)
    {
        lastCarouselView = [feedController carouselView];
        //[viewController viewWillAppear:TRUE];
        lastViewController = viewController;
    }
    else if (lastViewController == exploreController)
    {
        //lastCarouselView = [exploreController carouselView];
        //[viewController viewWillAppear:TRUE];
        lastViewController = viewController;
    }
    else if (lastViewController == storeViewShell)
    {
        // if we leave storeViewShell
        lastViewController = viewController;
    }
    else if (lastViewController == profileController) 
    {
        lastViewController = viewController;
    }
        
    // enabled highlighted button - not done here
    //if (viewController == tagViewController)
    //    [self.tabBarController setButtonStateSelected];
}

// RaisedCenterTabBarController delegate 
-(void)didPressCenterButton {
    // when center button is pressed, programmatically send the tab bar that command
    [tabBarController setSelectedIndex:2];
    [tabBarController setButtonStateSelected]; // highlight button
#if !TARGET_IPHONE_SIMULATOR
    [self.camera setCameraOverlayView:tagViewController.view];
#endif
}

-(void)didDismissSecondaryView {
    [tabBarController setButtonStateNormal]; // highlight button
    if (lastViewController == feedController) {
        [self.tabBarController setSelectedIndex:0];
    }
    else if (lastViewController == exploreController) {
        [self.tabBarController setSelectedIndex:1];
    }
    else if (lastViewController == storeViewShell) {
        if (storeViewShell.lastController == feedController) {
            [self.tabBarController setSelectedIndex:0];
        }
        else if (storeViewShell.lastController == exploreController) {
            [self.tabBarController setSelectedIndex:1];
        }
        else if (storeViewShell.lastController == profileController) {
            [self.tabBarController setSelectedIndex:4];
        }
        lastViewController = storeViewShell.lastController;
    }
    else if (lastViewController == profileController) {
        [self.tabBarController setSelectedIndex:4];
    }
#if !TARGET_IPHONE_SIMULATOR
    [self.camera setCameraOverlayView:tabBarController.view];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application
{	// Get full path of possession archive 
    if (init == 2) {
        //NSString *path = [self coordinateArrayPath];
        NSLog(@"Logging out and saving username %@", myUserInfo->username);
        [self saveDataToDisk];
    }

#if USING_KIIP
    // End the Kiip session when the app terminates
    [[KPManager sharedManager] endSession];
#endif
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{	// Get full path of possession archive 
    
    // archive username
    if (init == 2) {
        //NSString *path = [self coordinateArrayPath];
        NSLog(@"Logging out and saving username %@", myUserInfo->username);
        [self saveDataToDisk];
    }
    
#if USING_KIIP
    // End the Kiip session when the user leaves the app
    [[KPManager sharedManager] endSession];
#endif
    //[mainController dismissModalViewControllerAnimated:YES]; 
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
#if USING_KIIP
    // Start a Kiip session when the user enters the app
    [[KPManager sharedManager] startSession];
#endif
    /*
    [mainController presentModalViewController:camera animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [camera setCameraOverlayView:tabBarController.view];
     */
    // force some updates to badgeview types
    [self performSelectorInBackground:@selector(initializeBadges) withObject:nil];
    //[self initializeBadges];
}

- (void)application:(UIApplication *)application 
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ([error code] == 3010) {
        NSLog(@"Push notifications don't work in the simulator!");
    } else {
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)dealloc {
	
	//NEW COMMENT!
    [k release];
    [window release];
    free(myUserInfo);
    [super dealloc];
}

/**** loading and adding of stix from kumulos ****/
-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID{
    return [self addTagWithCheck:tag withID:newID overwrite:NO];
}

-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID overwrite:(bool)bOverwrite {
    // adds a tag to allTags, if its id doesn't already exist
    // add Tag to the correct position in allTags - used if we have delayed loading
    // newID is needed if tag.ID doesn't exist yet
    bool added = NO;
    bool alreadyExists = NO;
    int i;
    [tag retain];
    tag.tagID = [NSNumber numberWithInt:newID];
    for (i=0; i<[allTags count]; i++)
    {
        Tag * currtag = (Tag*) [allTags objectAtIndex:i];
        int tagID = [currtag.tagID intValue];
        if (newID == tagID)
        {
            // already exists, break
            alreadyExists = YES;
            [allTags replaceObjectAtIndex:i withObject:tag];
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
    [tag release];
    return added;
}

-(void)didCreateNewPix:(Tag *)newTag {
    // when adding a tag, we add it to both our local tag structure, and to kumulos database
    //[allTags addObject:newTag];

    [self didDismissSecondaryView];
    [tabBarController setSelectedIndex:0];
    
    // this function migrates toward not using the basic stix
    newestTag = [newTag retain];
    
    [k setDelegate:self];
    NSData * theImgData = UIImageJPEGRepresentation([newTag image], .8); 
    UIImage * thumbnail = [[newTag image] resizedImage:CGSizeMake(100, 100) interpolationQuality:kCGInterpolationMedium];
    
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
    //[encoder encodeObject:newTag.auxScales forKey:@"auxScales"]; // deprecated
    //[encoder encodeObject:newTag.auxRotations forKey:@"auxRotations"]; // deprecated
    [encoder encodeObject:newTag.auxTransforms forKey:@"auxTransforms"];
    [encoder encodeObject:newTag.auxPeelable forKey:@"auxPeelable"];
    [encoder finishEncoding];
    [encoder release];
    
    [k createPixWithUsername:newTag.username andDescriptor:newTag.descriptor andComment:newTag.comment andLocationString:newTag.locationString andImage:theImgData andTagCoordinate:theCoordData andAuxStix:theAuxStixData];
    
    NSString * loc = newTag.locationString;
    //NSLog(@"Location: %@", newTag.locationString);
    if ([loc length] > 0)
//        [self updateUserTagTotal];
        [self rewardLocation];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createPixDidCompleteWithResult:(NSNumber *)newRecordID {
    [newestTag setTagID:newRecordID];
    [newestTag setTimestamp:[NSDate date]]; // set a temporary date because we are adding newestTag that does not have a kumulos timestamp
    //[allTags addObject:newestTag];
    bool added = [self addTagWithCheck:newestTag withID:[newRecordID intValue]];
    if (added)
    {
        NSLog(@"Added new record to kumulos: tag id %d", [newRecordID intValue]);
        //[feedController.scrollView populateScrollPagesAtPage:0]; // force update first page
        //[feedController.tableController populateScrollPagesAtPage:0];
        [feedController viewWillAppear:YES];
    }
    else
        NSLog(@"Error! New record has duplicate tag id: %d", [newRecordID intValue]);

    // do not add scale and rotation - all saved in aux stix
    [self updateUserTagTotal];
}

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
    // first, update from kumulos in case other people have added stix
    // to the same pix we are modifying
    {
        // this is called from simply wanting to populate our allTags structure
        bool didAddTag = NO;
        // assume result is ordered by allTagID
        for (NSMutableDictionary * d in theResults) {
            Tag * tag = [[Tag getTagFromDictionary:d] retain]; // MRC
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
        [feedController.activityIndicator stopCompleteAnimation];
        if (lastViewController == feedController && didAddTag) // if currently viewing feed, force reload
            [feedController viewWillAppear:TRUE];
        if (didAddTag)
            [feedController reloadCurrentPage];
        //NSLog(@"loaded %d tags from kumulos", [theResults count]);
        
    }    
    
    // we get here from handleNotificationBookmarks
    if (isUpdatingNotifiedTag) {
        if (updatingNotifiedTagDoJump) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
            [self.camera setCameraOverlayView:tabBarController.view];
#endif
            [tabBarController setSelectedIndex:0];
            [feedController jumpToPageWithTagID:notificationTagID];
        }
        [feedController reloadCurrentPage]; // allTags were already updated
        [self updateCommentCount:notificationTagID];
        if (notificationBookmarkType == NB_NEWCOMMENT) {
            [feedController openCommentForPageWithTagID:[NSNumber numberWithInt:notificationTagID]];
        }
        updatingNotifiedTagDoJump = NO;
        isUpdatingNotifiedTag = NO;
    }
    // we get here from didAddStixToPix
    // so that we can add the new aux stix to the correct auxStix structure
    if (isUpdatingAuxStix) {
        
        // find the correct tag in allTags;
        if ([theResults count] == 0)
            return;
        Tag * tag = nil;
        for (NSMutableDictionary * d in theResults) {
            Tag * t = [[Tag getTagFromDictionary:d] retain]; // MRC
            if ([t.tagID intValue]== updatingAuxTagID) {
                NSLog(@"Found tag %d", [t.tagID intValue]);
                tag = t; // MRC: when we break, t is not released so tag is retaining t
                break;
            }
            [t release];
        }
        if (tag == nil)
            return;
        NSString * stixStringID = updatingAuxStixStringID;

        // only uses these if not fire/ice 
        CGPoint location = updatingAuxLocation;
        //float scale = 1;//updatingAuxScale;
        //float rotation = 0;//updatingAuxRotation;
        CGAffineTransform transform = updatingAuxTransform;
        float peelable = YES;
        if ([tag.username isEqualToString:myUserInfo->username])
            peelable = NO;
        
        // find local tag and sync with kumulos tag
        Tag * localTag = nil;
        for (int i=0; i<[allTags count]; i++) {
            localTag = [allTags objectAtIndex:i];
            if ([localTag.tagID intValue] == updatingAuxTagID)
                break;
        }
        if (localTag == nil) {
            if (tag)
                [tag release];
            return;            
        }
        // FIXME: in case of bad internet connections, updated stix from one user might
        // not make it to kumulos before another user changes it. we have to make
        // updating aux stix a parallel action so that multiple users can operate on 
        // one pix without deleting the other users' progress.
        // this can be done by creating an auxStix table where addition of a stix
        // simply adds to that database instead of adding to a data structure that gets
        // loaded to the pix in allTags
        [tag addStix:stixStringID withLocation:location /*withScale:scale withRotation:rotation */withTransform:transform withPeelable:peelable];
        NSMutableData *theAuxStixData = [NSMutableData data];
        NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theAuxStixData];
        [encoder encodeObject:tag.auxLocations forKey:@"auxLocations"];
        [encoder encodeObject:tag.auxStixStringIDs forKey:@"auxStixStringIDs"];
        [encoder encodeObject:tag.auxScales forKey:@"auxScales"]; // deprecated - keep encoding for backward compatibility
        [encoder encodeObject:tag.auxRotations forKey:@"auxRotations"]; // deprecated
        [encoder encodeObject:tag.auxTransforms forKey:@"auxTransforms"];
        [encoder encodeObject:tag.auxPeelable forKey:@"auxPeelable"];
        [encoder finishEncoding];
        [encoder release];
        
        // update kumulos version of tag with most recent tags
        [k updateStixOfPixWithAllTagID:[tag.tagID intValue] andAuxStix:theAuxStixData];
        // immediately notify
        // if adding to own pix, do not notify or broadcast
        if (![myUserInfo->username isEqualToString:tag.username]) {
            NSString * message = [NSString stringWithFormat:@"%@ added a %@ to your Pix \"%@\"!", myUserInfo->username, [BadgeView getStixDescriptorForStixStringID:stixStringID], tag.descriptor];
            [self Parse_sendBadgedNotification:message OfType:NB_NEWSTIX toChannel:tag.username withTag:tag.tagID orGiftStix:nil];
        }
        // replace old tag in allTags
        [self addTagWithCheck:tag withID:[tag.tagID intValue] overwrite:YES];
        [tag release];
                
        //NSLog(@"Adding %@ stix to tag with id %d: new count %d.", stixStringID, [tag.tagID intValue], [self getStixCount:stixStringID]);
        isUpdatingAuxStix = 0;
        [feedController reloadCurrentPage];
        
    }
    
    // we get here from didPerformPeelableAction
    // so that we can modify the new peelable stix status to the correct tag structure

    if (isUpdatingPeelableStix) {
        
        // find the correct tag in allTags;
        if ([theResults count] == 0)
            return;
        Tag * tag = nil;
        for (NSMutableDictionary * d in theResults) {
            Tag * t = [[Tag getTagFromDictionary:d] retain]; // MRC
            if ([t.tagID intValue]== updatingPeelableTagID) {
                tag = t; // MRC: when we break, t is not released so tag is retaining t
                break;
            }
            [t release]; // MRC
        }
        if (tag == nil)
            return;
        
        // from FeedViewController: changes structure of most recently dowloaded tag
        if (updatingPeelableAction == 0) { // peel stix
            NSString * peeledAuxStixStringID = [[tag removeStixAtIndex:updatingPeelableAuxStixIndex] copy];
            [self incrementStixCount:peeledAuxStixStringID];
#if 0
            [self showAlertWithTitle:@"Peeled a Stix!" andMessage:[NSString stringWithFormat:@"You have peeled off a %@ stix and added it to your collection!", [BadgeView getStixDescriptorForStixStringID:peeledAuxStixStringID]] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
#endif
            NSLog(@"Adding %@ (%@) stix to collection, taken from tag with id %d: new count %d.", peeledAuxStixStringID, [BadgeView getStixDescriptorForStixStringID:peeledAuxStixStringID], [tag.tagID intValue], [self getStixCount:peeledAuxStixStringID]);

            // add to comment log - if comment == @"PEEL" then it is a peel action
            [k addCommentToPixWithTagID:[tag.tagID intValue] andUsername:myUserInfo->username andComment:@"PEEL" andStixStringID:peeledAuxStixStringID];
            
            [peeledAuxStixStringID release];
        }
        else if (updatingPeelableAction == 1) { // attach stix
            [[tag auxPeelable] replaceObjectAtIndex:updatingPeelableAuxStixIndex withObject:[NSNumber numberWithBool:NO]];
        }
        
        // find index in current tags
        updatingPeelableTagIndex = -1;
        for (int i=0; i<[allTags count]; i++) {
            Tag * t = [allTags objectAtIndex:i];
            if ([t.tagID intValue] == updatingPeelableTagID) {
                updatingPeelableTagIndex = i;
                break;
            }
        }        
        [allTags replaceObjectAtIndex:updatingPeelableTagIndex withObject:tag];
        feedController.allTags = allTags;
        [feedController reloadCurrentPage];
        
        NSMutableData *theAuxStixData = [NSMutableData data];
        NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theAuxStixData];
        [encoder encodeObject:tag.auxLocations forKey:@"auxLocations"];
        [encoder encodeObject:tag.auxStixStringIDs forKey:@"auxStixStringIDs"];
        [encoder encodeObject:tag.auxScales forKey:@"auxScales"]; // keep encoding for backward compatibility
        [encoder encodeObject:tag.auxRotations forKey:@"auxRotations"];
        [encoder encodeObject:tag.auxTransforms forKey:@"auxTransforms"];
        [encoder encodeObject:tag.auxPeelable forKey:@"auxPeelable"];
        [encoder finishEncoding];
        [encoder release];
        [k updateStixOfPixWithAllTagID:[tag.tagID intValue] andAuxStix:theAuxStixData];
        // send a notification to update for a peel/stick action, but no need to acknowledge or jump to the tag
        [self Parse_sendBadgedNotification:@"This is an automatic general notification!" OfType:NB_PEELACTION toChannel:@"" withTag:tag.tagID orGiftStix:nil];
        
        [tag release]; // MRC
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updateStixOfPixDidCompleteWithResult:(NSNumber *)affectedRows {
    NSLog(@"Update finally completed");
    isUpdatingPeelableStix = NO;
}

-(void)getNewerTagsThanID:(int)tagID {
    // because this gets called multiple times during scrollViewDidScroll, we have to save
    // the last request to try to minimize making duplicate requests
    if (tagID == idOfNewestTagReceived || // we always want to make this request
        pageOfLastNewerTagsRequest != tagID){
        pageOfLastNewerTagsRequest = tagID;
        [k getAllTagsWithIDGreaterThanWithAllTagID:tagID andNumTags:[NSNumber numberWithInt:TAG_LOAD_WINDOW]];
    }
    else{
        //NSLog(@"Duplicate call to getNewerTagsThanID: id %d", tagID);
    }
}

-(void)getOlderTagsThanID:(int)tagID {
    if (1) { //pageOfLastOlderTagsRequest != tagID) {
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
        Tag * tag = [[Tag getTagFromDictionary:d] retain]; // MRC
        id key = [d valueForKey:@"allTagID"];
        int new_id = [key intValue];
        if (new_id > idOfNewestTagReceived)
            idOfNewestTagReceived = new_id;
        //[tagViewController addCoordinateOfTag:tag];
        //[allTags setObject:tag forKey:key];
        didAddTag = [self addTagWithCheck:tag withID:new_id]; // insert newest key to head
        if (didAddTag)
            totalAdded = totalAdded+1;
        [tag release]; // MRC
	}
    // force reload of beginning. because of leftward scroll, we should advance the page viewed one to the left.
    // if we've added more than one page, the correct new page number is lastPageViewed+totalAdded-1.
    if (totalAdded>0)
    {
        //[feedController.scrollView populateScrollPagesAtPage:feedController.lastPageViewed + totalAdded - 1]; 
        //[feedController viewWillAppear:YES];
        [feedController finishedCheckingForNewData:YES];
    }
    else {
        [feedController finishedCheckingForNewData:NO];
    }
    [feedController.activityIndicator stopCompleteAnimation];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDLessThanDidCompleteWithResult:(NSArray *)theResults {
    bool didAddTag = NO;
    int totalAdded = 0;
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [[Tag getTagFromDictionary:d] retain]; // MRC
        id key = [d valueForKey:@"allTagID"];
        int new_id = [key intValue];
        if (new_id < idOfOldestTagReceived)
            idOfOldestTagReceived = new_id;
        //[tagViewController addCoordinateOfTag:tag];
        didAddTag = [self addTagWithCheck:tag withID:new_id];
        if (didAddTag)
            totalAdded = totalAdded+1;
        [tag release];
    }
    if (totalAdded>0) 
    {
        //[feedController.scrollView populateScrollPagesAtPage:feedController.lastPageViewed]; // hack: forced reload of end
//        [feedController viewWillAppear:YES];
        [feedController finishedCheckingForNewData:YES];
    }
    else
    {
        [feedController finishedCheckingForNewData:NO];
    }
    [feedController.activityIndicator stopCompleteAnimation];
}

- (NSMutableArray *) getTags {
    return allTags;
}

-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID {
    [k addCommentToPixWithTagID:tagID andUsername:name andComment:comment andStixStringID:stixStringID];

    if (![comment isEqualToString:@""]) {
        // actual comment

        // notify
        NSString * message = [NSString stringWithFormat:@"%@ commented on your feed: %@", myUserInfo->username, comment];
        Tag * tag = [self getTagWithID:tagID];
        if (![tag.username isEqualToString:[self getUsername]])
            [self Parse_sendBadgedNotification:message OfType:NB_NEWCOMMENT toChannel:tag.username withTag:tag.tagID orGiftStix:nil];
        // update comment count
        [self updateCommentCount:tagID];
        [self updateUserTagTotal];
    }
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
    int commentCount = 0;
    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];        
        NSString * commentStixStringID = [d valueForKey:@"stixStringID"];
        if ([commentStixStringID length] == 0 || [commentStixStringID isEqualToString:@"COMMENT"]) {
            // stix type is -1 or "COMMENT", so this must be a comment
            NSString * comment = [d valueForKey:@"comment"];
            if ([comment length] > 0) {
                commentCount ++;
            }
        }
        //NSLog(@"Comment %d stix string ID: %@ count %d", i, commentStixStringID, commentCount);
    }
    [allCommentCounts setObject:[NSNumber numberWithInt:commentCount] forKey:tagID];
    [feedController forceUpdateCommentCount:[tagID intValue]];
}

/***** FriendsViewDelegate ********/
-(void)didDismissFriendView {}; // only used in profileView
-(void) checkForUpdatePhotos {
    if (1) // todo: check for updated users by id
    {
        [friendController setIndicator:YES];
        
        [k getAllUsers];
    }
}
-(void)didSendGiftStix:(NSString *)stixStringID toUsername:(NSString *)friendName {
    NSString * message = [NSString stringWithFormat:@"%@ sent you a %@!", myUserInfo->username, [BadgeView getStixDescriptorForStixStringID:stixStringID]];
    [self Parse_sendBadgedNotification:message OfType:NB_NEWGIFT toChannel:friendName withTag:nil orGiftStix:stixStringID];
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

/**** ProfileViewController and login functions ****/

-(void)didClickChangePhoto {
    // we want to open another camera source
    // we have to do it over the existing camera because touch controls don't work if
    // we add a modal view to profileViewController
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
#if 0
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = YES;
    picker.navigationBarHidden = YES;
    picker.toolbarHidden = YES;
    picker.wantsFullScreenLayout = YES;
#else
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#endif
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    // because a modal camera already exists, we must present a modal view over that camera
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [camera presentModalViewController:picker animated:YES];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    //    [[picker parentViewController] dismissModalViewControllerAnimated: YES];    
    //    [picker release];    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [camera dismissModalViewControllerAnimated:TRUE];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tabBarController.view];
#endif
    [tabBarController setSelectedIndex:0];
    [profileController viewWillAppear:YES];
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [camera dismissModalViewControllerAnimated:TRUE];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tabBarController.view];
#endif
    [tabBarController setSelectedIndex:0];
    [profileController viewWillAppear:YES];
    
    // scale down photo
	CGSize targetSize = CGSizeMake(90, 90);		
    UIImage * result = [newPhoto resizedImage:targetSize interpolationQuality:kCGInterpolationDefault];
    UIImage * rounded = [result roundedCornerImage:0 borderSize:2];
    
    // save to album
    UIImageWriteToSavedPhotosAlbum(rounded, nil, nil, nil); 
    
    //NSData * img = UIImageJPEGRepresentation(rounded, .8);
    NSData * img = UIImagePNGRepresentation(rounded);
    [profileController.photoButton setImage:rounded forState:UIControlStateNormal];
    [self didChangeUserphoto:rounded];
    
    // add to kumulos
    [k addPhotoWithUsername:myUserInfo->username andPhoto:img];
    [picker release];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPhotoDidCompleteWithResult:(NSNumber*)affectedRows;
{
    NSLog(@"Added photo to username %@",  myUserInfo->username);
    
    // force friendView to update photo after we know it is in kumulos
    [self checkForUpdatePhotos];
}

- (NSString *)coordinateArrayPath
{	
    return pathInDocumentDirectory(@"StixxUserData.data");
}

-(void)kumulosAPI:(kumulosProxy *)kumulos apiOperation:(KSAPIOperation *)operation didFailWithError:(NSString *)theError {
    NSLog(@"Kumulos error: %@", theError);
#if 0
    if (lastViewController == feedController) { // currently on feed controller
        NSLog(@"Kumulos error in feedController %x: %@ - probably failed while trying to check for updated tags", feedController, theError);
    }
    if (lastViewController == tagViewController)
        NSLog(@"Kumulos error in tagViewController: %@", theError);
    if (lastViewController == profileController)
        NSLog(@"Kumulos error in profileController: %@ - probably failed while trying to call userLogin", theError);
#endif
}

-(void)didLoginFromSplashScreenWithUsername:(NSString *)username andPhoto:(UIImage *)photo andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary*) stixOrder andFriendsList:(NSMutableSet*)friendsList isFirstTimeUser:(BOOL)firstTime {
    
    [photo retain];
    [stix retain];
    
    /***** if we used splash screen *****/
    [self didDismissSecondaryView];
    //[loginSplashController.view removeFromSuperview];
    //[loginSplashController release];
    
    //[profileController loginWithUsername:myUserInfo->username];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tabBarController.view];
#endif
    //[self.tabBarController didPressCenterButton:self];
    [self.tabBarController setSelectedIndex:0];

    [self didLoginWithUsername:username andPhoto:photo andStix:stix andTotalTags:total andBuxCount:bux andStixOrder:stixOrder andFriendsList:friendsList];
    [photo release];
    [stix release];
    if (firstTime) {
        [tabBarController addFirstTimeInstructions];
    }
}

- (void)didLoginWithUsername:(NSString *)name andPhoto:(UIImage *)photo andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary *)stixOrder andFriendsList:(NSMutableSet *)friendsList {
    if (![stix isKindOfClass:[NSMutableDictionary class]]) {
        stix = [[BadgeView generateDefaultStix] retain];
        [allStix removeAllObjects];
        [allStix addEntriesFromDictionary:stix];
        [stix release];
    }
    else {
        [stix retain];
        [allStix removeAllObjects];
        [allStix addEntriesFromDictionary:stix];
        [stix release];
    }
    if (![stixOrder isKindOfClass:[NSMutableDictionary class]]) {
        stixOrder = [[NSMutableDictionary alloc] init];
        [stixOrder setObject:[NSNumber numberWithInt:0] forKey:@"FIRE"];
        [stixOrder setObject:[NSNumber numberWithInt:1] forKey:@"ICE"];
        NSLog(@"Generating stix order:");
        NSEnumerator *e = [allStix keyEnumerator];
        id key;
        while (key = [e nextObject]) {
            if (![key isEqualToString:@"FIRE"] && ![key isEqualToString:@"ICE"]) {
                int ct = [self getStixCount:key];
                if (ct != 0)
                    [stixOrder setObject:[NSNumber numberWithInt:[stixOrder count]] forKey:key];
                NSLog(@"Stix: %@ count %d order %d", key, ct, [[stixOrder valueForKey:key] intValue]); 
            }
        }    
        [allStixOrder removeAllObjects];
        [allStixOrder addEntriesFromDictionary:stixOrder];
        [stixOrder release];
    }
    else {
        [stixOrder retain];
        [allStixOrder removeAllObjects];
        [allStixOrder addEntriesFromDictionary:stixOrder];
        [stixOrder release];

        // debug
        NSEnumerator *e = [allStixOrder keyEnumerator];
        id key;
        while (key = [e nextObject]) {
            int ct = [[allStixOrder objectForKey:key] intValue];
            if (ct != 0) {
                int order = [[allStixOrder objectForKey:key] intValue];
                NSLog(@"Stix: %@ order %d", key, order); 
            }
        }    
    }  
    if (![friendsList isKindOfClass:[NSMutableSet class]]) {
        [allFriends removeAllObjects];
        [allFriends addObject:@"bobo"];
        [allFriends addObject:@"willh103"];
    }
    else {
        [friendsList retain];
        [allFriends removeAllObjects];
        [allFriends unionSet:friendsList];
        [friendsList release];
    }
    loggedIn = YES;
    myUserInfo->username = [name retain];
    myUserInfo->userphoto = [photo retain];
    myUserInfo->usertagtotal = total;
    myUserInfo->bux = bux;
    
    NSLog(@"Username %@ with %d pix and image of %f %f", myUserInfo->username, myUserInfo->usertagtotal, myUserInfo->userphoto.size.width, myUserInfo->userphoto.size.height);
            
    // DO NOT do this: opening a camera probably means the badgeView belonging to LoginSplashViewer was
    // deleted so now this is invalid. that badgeView does not need badgeLocations anyways
    //if (lastBadgeView)
    //    [lastBadgeView resetBadgeLocations];
    
    //[myStixController forceLoadMyStix];
    [self reloadAllCarousels];
    [self Parse_subscribeToChannel:myUserInfo->username];
    [storeViewController updateBuxCount];
    [storeViewController reloadTableButtons];
    //[profileController updatePixCount];    

    [self performSelectorInBackground:@selector(saveDataToDisk) withObject:self];
    //[self saveDataToDisk];
}

-(void)didLogout {
    if (loggedIn == YES) {
        // logging out from profile view controller
        
        loggedIn = NO;
        myUserInfo->username = @"";
        if (myUserInfo->userphoto) {
            [myUserInfo->userphoto release];
            myUserInfo->userphoto = nil;
        }
        myUserInfo->usertagtotal = 0;
        myUserInfo->bux = 0;
        [self performSelectorInBackground:@selector(saveDataToDisk) withObject:self];
        //[self saveDataToDisk];
        
        [allStix removeAllObjects];
        [profileController updatePixCount];
        if (lastCarouselView)
            [lastCarouselView resetBadgeLocations];
        
#if !TARGET_IPHONE_SIMULATOR
        [self.camera setCameraOverlayView:loginSplashController.view];
#endif
    }
    else {
        // probably came from a failed login attempt with a nonexistent user
        [self didDismissSecondaryView];
#if !TARGET_IPHONE_SIMULATOR
        [self.camera setCameraOverlayView:loginSplashController.view];        
#endif
    }
}

-(void)didChangeUserphoto:(UIImage *)photo {
    myUserInfo->userphoto = photo;
}

-(int)getStixCount:(NSString*)stixStringID {
    //if (loggedIn)
    if ([stixStringID isEqualToString:@"FIRE"] || [stixStringID isEqualToString:@"ICE"] || [[BadgeView getStixDescriptorForStixStringID:stixStringID] isEqualToString:@"Generic"])
        return -1;
    int ret = [[allStix objectForKey:stixStringID] intValue];
    //NSLog(@"Stix count for %@: %d", stixStringID, ret);
    return ret;
}

-(int)getStixOrder:(NSString*)stixStringID {
    if ([allStixOrder objectForKey:stixStringID] == nil) {
        //int pos = -1;
        //[allStixOrder setValue:[NSNumber numberWithInt:ct] forKey:stixStringID];
        return -1;
    }
    else
        return [[allStixOrder objectForKey:stixStringID] intValue];
}

-(NSMutableSet*)getFriendsList {
    return allFriends;
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixToUserDidCompleteWithResult:(NSArray*)theResults;
{
    // all debug
    for (NSMutableDictionary * d in theResults)
    {
        NSString * name = [d valueForKey:@"username"];
        NSLog(@"Updated stix counts for user %@", name);
    }
    [self reloadAllCarousels];
}

-(void)didAddStixToPix:(Tag *)tag withStixStringID:(NSString*)stixStringID withLocation:(CGPoint)location /*withScale:(float)scale withRotation:(float)rotation*/ withTransform:(CGAffineTransform)transform{
    
    // first update existing tag and display to user for immediate viewing
    // only uses these if not fire/ice 
    float peelable = YES;
    if ([tag.username isEqualToString:myUserInfo->username])
        peelable = NO;
    [tag addStix:stixStringID withLocation:location /*withScale:scale withRotation:rotation */withTransform:transform withPeelable:peelable];

    NSNumber * tagID = tag.tagID;
    for (int i=0; i<[allTags count]; i++) {
        Tag * t = [allTags objectAtIndex:i];
        if ([t.tagID intValue] == [tagID intValue])
        {
            [allTags replaceObjectAtIndex:i withObject:tag];
            break;
        }
        //[feedController reloadCurrentPage];
    }
    
    // immediately add comment, update total, decrement stix count
    [self didAddCommentWithTagID:[tag.tagID intValue] andUsername:myUserInfo->username andComment:@"" andStixStringID:stixStringID]; // this adds to history item
    [self updateUserTagTotal];        
    [self decrementStixCount:stixStringID];
    
    if ([self getStixCount:stixStringID] == 0) {
        // ran out of a nonpermanent stix
        [feedController.carouselView carouselTabDismissRemoveStix];
        [tagViewController.descriptorController.carouselView carouselTabDismissRemoveStix];
    }
    
    // second, correctly update tag by getting updates for this tag (new aux stix) from kumulos
    updatingAuxTagID = [tag.tagID intValue];
    updatingAuxStixStringID = stixStringID;
    updatingAuxLocation = location;
    //updatingAuxScale = scale;
    //updatingAuxRotation = rotation;
    updatingAuxTransform = transform;

    isUpdatingAuxStix = YES;
    [k getAllTagsWithIDRangeWithId_min:[tag.tagID intValue]-1 andId_max:[tag.tagID intValue]+1];
}

-(void)didPerformPeelableAction:(int)action forTagWithIndex:(int)tagIndex forAuxStix:(int)index {
    Tag * tag = [allTags objectAtIndex:tagIndex];
    isUpdatingPeelableStix = YES;
    updatingPeelableAction = action;
    updatingPeelableTagID = [tag.tagID intValue];
    updatingPeelableAuxStixIndex = index;

    [k getAllTagsWithIDRangeWithId_min:[tag.tagID intValue]-1 andId_max:[tag.tagID intValue]+1];
}

// not used
-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updatePixDidCompleteWithResult:(NSNumber *)affectedRows {
    [feedController reloadCurrentPage];
}

-(NSString *) getUsername {
    if (loggedIn == YES)
    {
        //NSLog(@"[delegate getUsername] returning %@", username);
        return myUserInfo->username;
    }
    //NSLog(@"[delegate getUsername] returning anonymous");
    return @"anonymous";
}

-(UIImage *) getUserPhoto {
    if ([self isLoggedIn] == NO)
        return [UIImage imageNamed:@"graphic_nouser.png"];
    return myUserInfo->userphoto;
}

-(int)getUserTagTotal { return myUserInfo->usertagtotal; }
-(int)getBuxCount { return myUserInfo->bux; }
//-(bool)isFirstTimeUser { return NO; }// myUserInfo->isFirstTimeUser; }
//-(bool)hasAccessedStore { return YES; }//myUserInfo->hasAccessedStore; }


-(void)changeBuxCountByAmount:(int)change {
    myUserInfo->bux += change;
    [k changeUserBuxByAmountWithUsername:[self getUsername] andBuxChange:change];
    [profileController updateBuxCount];
    [storeViewController updateBuxCount];
}

-(void)rewardBux {
    NSString * title = @"Active Stix User";
    int amount = 5;
    [self.tabBarController doRewardAnimation:title withAmount:amount];
    //[self showAlertWithTitle:@"Award!" andMessage:[NSString stringWithFormat:@"You have been awarded five Bux!"] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    [self changeBuxCountByAmount:amount];
}
-(void)rewardLocation {
    NSString * title = @"Location Added";
    int amount = 1;
    [self.tabBarController doRewardAnimation:title withAmount:amount];
    //[self showAlertWithTitle:@"Award!" andMessage:[NSString stringWithFormat:@"You have been awarded five Bux!"] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    [self changeBuxCountByAmount:amount];
}
-(void)rewardStix {
    NSString * newStixStringID = [BadgeView getRandomStixStringID];
    int count = [[allStix objectForKey:newStixStringID] intValue];
    if (count == 0) {
#if USING_KIIP
        [[KPManager sharedManager] unlockAchievement:@"1"];
#else
        [self showAlertWithTitle:@"Award!" andMessage:[NSString stringWithFormat:@"You have been awarded a new Stix: %@!", [BadgeView getStixDescriptorForStixStringID:newStixStringID]] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
#endif
    }
    else
    {
#if USING_KIIP
        [[KPManager sharedManager] unlockAchievement:@"1"];
#else
        [self showAlertWithTitle:@"Award!" andMessage:[NSString stringWithFormat:@"You have earned additional %@!", [BadgeView getStixDescriptorForStixStringID:newStixStringID]] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
#endif
    }
    [allStix setObject:[NSNumber numberWithInt:count+3] forKey:newStixStringID];
    NSMutableData * data = [KumulosData dictionaryToData:allStix];
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
}

-(void)updateUserTagTotal {
    // update usertagtotal
    myUserInfo->usertagtotal += 1;
    [k updateTotalTagsWithUsername:myUserInfo->username andTotalTags:myUserInfo->usertagtotal];
    if ((myUserInfo->usertagtotal % 5) == 0) {
        //[self rewardStix];
        [self rewardBux];
        [self reloadAllCarousels];
    }
#if USING_KIIP
    [[KPManager sharedManager] updateScore:usertagtotal onLeaderboard:@"topDailyStixter"];
#endif
}

-(bool)isLoggedIn {
    return loggedIn;
}

-(void)didCreateBadgeView:(UIView *)newBadgeView {
//    if (lastViewController != nil) {
//        lastCarouselView = (CarouselView*) newBadgeView;
//    }
    [allCarouselViews addObject:newBadgeView];
}

-(void)didClickFeedbackButton:(NSString *)fromView {
    NSLog(@"Feedback button clicked from %@", fromView);
    FeedbackViewController * feedbackController = [[FeedbackViewController alloc] init];
    [feedbackController setDelegate:self];
    // hack a way to display feedback view over camera: formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [feedbackController.view setFrame:frameShifted];
#if !TARGET_IPHONE_SIMULATOR
    [self.camera setCameraOverlayView:feedbackController.view];
#endif
}

-(void)didCancelFeedback {
    // formerly dismissModalViewController
    [self didDismissSecondaryView];
}

- (void) sendEmailTo:(NSString *)to withCC:(NSString*)cc withSubject:(NSString *) subject withBody:(NSString *)body {
	NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&bcc=%@&subject=%@&body=%@",
							[to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [cc stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
							[subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
							[body  stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}

-(void)didSubmitFeedbackOfType:(NSString *)type withMessage:(NSString *)message {
    NSLog(@"Feedback submitted for %@ by %@", type, [self getUsername]);
    NSString * subject = [NSString stringWithFormat:@"%@ sent from %@", type, myUserInfo->username];
    NSString * fullmessage = [NSString stringWithFormat:@"Stix version Stable %@ Beta %@\n\n%@", versionStringStable, versionStringBeta, message];
	[self sendEmailTo:@"bobbyren@gmail.com, willh103@gmail.com" withCC:@"" withSubject:subject withBody:fullmessage];
    [self didDismissSecondaryView];
}

-(void)didClickInviteButton {
    NSLog(@"Invite button submitted by %@", [self getUsername]);
    NSString * subject = [NSString stringWithFormat:@"Become a Stixster!"];
    NSString * body = [NSString stringWithFormat:@"I'm playing Stix on my iPhone and I think you'd enjoy it too! Just click <a href=\"http://bit.ly/sjvbNE\">here</a> to get started!"];
    [self sendEmailTo:@"" withCC:@"bobbyren@gmail.com, willh103@gmail.com" withSubject:subject withBody:body];
    [self rewardBux];
}

/*** processing stix counts ***/

// debug
-(void)adminUpdateAllStixCountsToZero {
    NSMutableDictionary * stix = [[BadgeView generateDefaultStix] retain];   
    NSMutableData * data = [[KumulosData dictionaryToData:stix] retain];
    [k adminAddStixToAllUsersWithStix:data];
    [data autorelease]; // MRC
    [stix autorelease];
}

-(void)adminUpdateAllStixCountsToOne {
    NSMutableDictionary * stix = [[BadgeView generateOneOfEachStix] retain]; 
    int ct = [[stix objectForKey:@"HEART"] intValue];
    NSLog(@"Heart: %d", ct);
    NSMutableData * data = [[KumulosData dictionaryToData:stix] retain];
    [k adminAddStixToAllUsersWithStix:data];
    [data autorelease]; // MRC
    [stix autorelease];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation adminAddStixToAllUsersDidCompleteWithResult:(NSNumber *)affectedRows {
    [self Parse_sendBadgedNotification:@"Ninja admin stix update" OfType:NB_UPDATECAROUSEL toChannel:@"" withTag:nil orGiftStix:nil];
}

-(void)adminIncrementAllStixCounts {
    int totalStixTypes = [BadgeView totalStixTypes];
    NSLog(@"Total stix: %d", totalStixTypes);
    for (int i=0; i<totalStixTypes; i++) {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
        if (![stixStringID isEqualToString:@"FIRE"] && ![stixStringID isEqualToString:@"ICE"]) {
            int count = [[allStix objectForKey:stixStringID] intValue];
            NSLog(@"New count for %@: %d", stixStringID, count+1);
            [allStix setObject:[NSNumber numberWithInt:count+1] forKey:stixStringID];
        }
    }
    NSMutableData * data = [[KumulosData dictionaryToData:allStix] retain];
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
    [data autorelease]; // MRC
}

-(void)adminSetUnlimitedStix {
    int totalStixTypes = [BadgeView totalStixTypes];
    NSLog(@"Total stix: %d", totalStixTypes);
    for (int i=0; i<totalStixTypes; i++) {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
        int order = [[allStixOrder objectForKey:stixStringID] intValue];
        int count = [[allStix objectForKey:stixStringID] intValue];
        NSLog(@"For %@: old count %d order %d", stixStringID, count, order);
        if (order != -1)
            [allStix setObject:[NSNumber numberWithInt:-1] forKey:stixStringID];
    }
    NSMutableData * data = [[KumulosData dictionaryToData:allStix] retain];
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
    [data autorelease]; // MRC
}

-(void)adminResetAllStixOrders {
//    KumulosHelper * kh = [[KumulosHelper alloc] init];
//    [kh setFunction:@"adminUpdateAllStixOrders"];
    //[kh setFunction:@"adminUpdateAllFriendsLists"];
//    [kh execute];
    [[KumulosHelper sharedKumulosHelper] execute:@"adminUpdateAllStixOrders"];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserStixDidCompleteWithResult:(NSArray *)theResults {
    // called by NB_UPDATECAROUSEL notification
    if ([theResults count] == 0)
        return;
    NSMutableDictionary * d = [theResults objectAtIndex:0];
    NSMutableDictionary * stix = [KumulosData dataToDictionary:[d valueForKey:@"stix"]]; 
    if (![stix isKindOfClass:[NSMutableDictionary class]]) {
        stix = [[BadgeView generateDefaultStix] retain];
        [allStix removeAllObjects];
        [allStix addEntriesFromDictionary:stix];
        [stix autorelease];
    }
    else 
    {
        [allStix removeAllObjects];
        [allStix addEntriesFromDictionary:stix];
    }
    [self reloadAllCarousels];
}
-(void)reloadAllCarousels {
#if 0
    for (int i=0; i<[allCarouselViews count]; i++) {
        [[allCarouselViews objectAtIndex:i] reloadAllStix];
    }
#else
    [feedController reloadCarouselView];
    //[exploreController reloadCarouselView];
    [tagViewController.descriptorController reloadCarouselView];
#endif
}

-(void)didPressAdminEasterEgg:(NSString *)view {
    //if ([[self getUsername] isEqualToString:@"bobo"]) {
    //    [self adminEasterEggShowMenu:@""];
    //}
    //else 
    if ([view isEqualToString:@"ProfileView"]) {
        [self showAlertWithTitle:@"Authorized Access Only" andMessage:@"" andButton:@"Cancel" andOtherButton:@"Stix it to the Man" andAlertType:ALERTVIEW_PROMPT];
    }
    else if ([view isEqualToString:@"FeedView"]) {
#if USING_KIIP
        [[KPManager sharedManager] unlockAchievement:@"1"];
#else
        [self rewardLocation];
#endif
    }
}

-(void)adminEasterEggShowMenu:(NSString *)password {
    if ([[self getUsername] isEqualToString:@"bobo"] || [password isEqualToString:@"admin"]) {
//        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Ye ol' Admin Menu" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reset All Users' Stix", @"Get me one of each", "Set all Users' bux", nil];
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Test" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reset All Users Stix", @"Get me one of each", @"Set my stix to unlimited", @"Set all Users bux", @"Save Stix Feed", @"Reset all stix orders", nil];
        [actionSheet showFromTabBar:tabBarController.tabBar ];
        [actionSheet release];
    }
    else
        [self showAlertWithTitle:@"Wrong Password!" andMessage:@"You cannot access the super secret club." andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // button index: 
    // 0 = "Reset all Users' Stix"
    // 1 = "Get me one of each"
    // 2 = "Set my stix to unlimited"
    // 3 = "Set all Users' bux"
    // 4 = "Save stix feed"
    // 5 = "Reset all Stix Orders"
    // 6 = "Cancel"
    switch (buttonIndex) {
        case 0:
            NSLog(@"button 0");
            //[self adminUpdateAllStixCountsToOne];
            break;
        case 1:
            NSLog(@"button 1");
            //[self adminIncrementAllStixCounts];
            break;
        case 2:
            NSLog(@"button 2 set my stix to unlimited");
            //[self adminSetUnlimitedStix];
            break;
        case 3:
            NSLog(@"button 3");
            [self adminSetAllUsersBuxCounts];
            break;
        case 4:
            NSLog(@"button 4: Save all tag update info");
            [self adminSaveTagUpdateInfo];
            break;
        case 5:
            //NSLog(@"button 5: Reset all stix orders");
            [self adminResetAllStixOrders];
            break;
        default:
            return;
            break;
    }
}

-(void) adminSetAllUsersBuxCounts {
    [k adminSetAllUserBuxWithBux:25];
}

-(void)decrementStixCount:(NSString *)stixStringID {
    int count = [[allStix objectForKey:stixStringID] intValue];
    if (count > 0) {
        count--;
        [allStix setObject:[NSNumber numberWithInt:count] forKey:stixStringID];
        
        for (int i=0; i<[allCarouselViews count]; i++) {
            [[allCarouselViews objectAtIndex:i] reloadAllStix];
        }
    }
    NSMutableData * data = [[KumulosData dictionaryToData:allStix] retain];
    
    // todo: when giftstx are used, we must check to sync with kumulos
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
    [data release];
    
}

-(void)adminSaveTagUpdateInfo {
    [[KumulosHelper sharedKumulosHelper] execute:@"adminSaveTagUpdateInfo"];
}

-(void)incrementStixCount:(NSString *)stixStringID{
    [self incrementStixCount:stixStringID byNumber:1];
}

-(void)incrementStixCount:(NSString *)stixStringID byNumber:(int)increment{
    int count = [[allStix objectForKey:stixStringID] intValue];
    if (![stixStringID isEqualToString:@"FIRE"] && ![stixStringID isEqualToString:@"ICE"]) {
        count+=increment;
        [allStix setObject:[NSNumber numberWithInt:count] forKey:stixStringID]; 
        
        for (int i=0; i<[allCarouselViews count]; i++) {
            [[allCarouselViews objectAtIndex:i] reloadAllStix];
        }
    }
    NSMutableData * data = [[KumulosData dictionaryToData:allStix] retain];
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
    [data release];
}

-(Tag*) getTagWithID:(int)tagID {
    for (int i=0; i<[allTags count]; i++) {
        Tag * t = [allTags objectAtIndex:i];
        if ([[t tagID] intValue] == tagID)
            return [allTags objectAtIndex:i];
    }
    return nil;
}

/***** Parse Notifications ****/
-(void) Parse_subscribeToChannel:(NSString*) channel {
    // Subscribe to the global broadcast channel.
    [PFPush subscribeToChannelInBackground:channel];
}

-(void) Parse_sendBadgedNotification:(NSString*)message OfType:(int)type toChannel:(NSString*) channel withTag:(NSNumber*)tagID orGiftStix:(NSString*)giftStixStringID {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (type == NB_NEWGIFT || type == NB_NEWCOMMENT || type == NB_NEWSTIX)
        [data setObject:message forKey:@"alert"];
    [data setObject:[NSNumber numberWithInt:0] forKey:@"badge"];
    [data setObject:[NSNumber numberWithInt:type] forKey:@"notificationBookmarkType"];
    [data setObject:message forKey:@"message"];
    [data setObject:channel forKey:@"channel"];
    if (tagID != nil)
        [data setObject:tagID forKey:@"tagID"];
    if (giftStixStringID != nil)
        [data setObject:giftStixStringID forKey:@"giftStixStringID"];
    [PFPush sendPushDataToChannelInBackground:channel withData:data];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
            
    notificationBookmarkType = [[userInfo objectForKey:@"notificationBookmarkType"] intValue    ];
    // todo: client should track badge counts and set them this way:
    //[UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;

    bool doAlert = NO;
    switch (notificationBookmarkType) {
        case NB_NEWSTIX: 
        {
            notificationTagID = [[userInfo objectForKey:@"tagID"] intValue];
            notificationGiftStixStringID = nil;
            doAlert = YES;
            break;
        }
            
        case NB_NEWCOMMENT:
        {
            notificationTagID = [[userInfo objectForKey:@"tagID"] intValue];
            notificationGiftStixStringID = nil;
            [self updateCommentCount:notificationTagID]; // in case comment count was not updated
            doAlert = YES;
            break;
        }
            
        case NB_NEWGIFT:
        {
            notificationTagID = -1;
            notificationGiftStixStringID = [[userInfo objectForKey:@"giftStixStringID"] copy];
            doAlert = YES;
            break;
        }
            
        case NB_PEELACTION:
        {
            // a general tag update - either a stix was peeled or attached, or a stix or comment was added to a tag but not the user's tag
            notificationTagID = [[userInfo objectForKey:@"tagID"] intValue];
            notificationGiftStixStringID = nil;
            break;
        }
            
        case NB_UPDATECAROUSEL:
        {
            notificationTagID = -1;
            notificationGiftStixStringID = nil;
            break;
        }
            
        default:
            break;
    }

    notificationTargetChannel = [[userInfo objectForKey:@"channel"] copy];
    NSString * message = [userInfo objectForKey:@"message"]; // get alert message

    if ( application.applicationState == UIApplicationStateActive && ([notificationTargetChannel isEqualToString:[self getUsername]] || [notificationTargetChannel isEqualToString:@""]) && doAlert) {
        // app was already in the foreground
        // create something that will parse and jump to the correct tag
        [self showAlertWithTitle:@"Stix Alert" andMessage:message andButton:@"Close" andOtherButton:@"View" andAlertType:ALERTVIEW_NOTIFICATION];
    }
    else {
        // app was just brought from background to foreground due to clicking
        // because the user clicked, we treat the behavior same as "View" 
       [self handleNotificationBookmarks:YES];
    }
}

-(void)handleNotificationBookmarks:(bool)doJump {
    if (notificationTagID == -1) {
        // gift stix only - no need to jump to or update feed
        if (notificationBookmarkType == NB_UPDATECAROUSEL) {
            [k getUserStixWithUsername:myUserInfo->username];
            doJump = NO;
        }
        if (notificationBookmarkType == NB_NEWGIFT) {
            if (doJump) {
                [tabBarController setSelectedIndex:3]; // go to mystixview
                NSString * message;
                if ([self getStixCount:notificationGiftStixStringID] == -1) {
                    message = [NSString stringWithFormat:@"You have received a %@ but you already have it permanently!", [BadgeView getStixDescriptorForStixStringID:notificationGiftStixStringID]];
                }
                else
                {
                    message = [NSString stringWithFormat:@"You have received 3 one-time use %@.", [BadgeView getStixDescriptorForStixStringID:notificationGiftStixStringID]];
                    [self incrementStixCount:notificationGiftStixStringID byNumber:3];
                    [self reloadAllCarousels];
               }
                [self showAlertWithTitle:@"New Stix" andMessage:message andButton:@"Close" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
            }
        }
    }
    else {
        if (notificationBookmarkType == NB_PEELACTION || ![notificationTargetChannel isEqualToString:[self getUsername]]) {
            // either sent globally, or a peel action - does not require jump
            updatingNotifiedTagDoJump = NO;
        } 
        else {
            updatingNotifiedTagDoJump = doJump;
        }
        isUpdatingNotifiedTag = YES;
        [k getAllTagsWithIDRangeWithId_min:notificationTagID-1 andId_max:notificationTagID+1];
    }
}

- (void)showAlertWithTitle:(NSString *) title andMessage:(NSString*)message andButton:(NSString*)buttonTitle andOtherButton:(NSString *)otherButtonTitle andAlertType:(int)alertType {
    /*
     UIAlertView* alert = [[UIAlertView alloc]init];
     [alert addButtonWithTitle:buttonTitle];
     [alert setTitle:title];
     [alert setMessage:message];
     [alert show];
     [alert release];
     */
    UIAlertView * alert;
    if (alertType == ALERTVIEW_PROMPT) {
        alert = [[AlertPrompt alloc] initWithTitle:title message:@"Here goes the prompt" delegate:self cancelButtonTitle:buttonTitle okButtonTitle:otherButtonTitle];
    }
    else
    {
        if (otherButtonTitle) {
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:buttonTitle
                                     otherButtonTitles:otherButtonTitle, nil];    
        }
        else {
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:buttonTitle
                                     otherButtonTitles: nil];    
        }
    }
    if (alertQueue == nil) {
        alertQueue = [[NSMutableArray alloc] init];
        alertAction = [[NSMutableArray alloc] init];
    }
    [alertQueue insertObject:alert atIndex:[alertQueue count]]; // insert at end
    [alertAction insertObject:[NSNumber numberWithInt:alertType] atIndex:[alertAction count]];
    [alert release];
    [self showAllAlerts];
}

static bool isShowingAlerts = NO;
-(void)showAllAlerts {
    if (isShowingAlerts == YES)
        return;
    UIAlertView * firstAlert = [[alertQueue objectAtIndex:0] retain];
    [alertQueue removeObjectAtIndex:0];
    alertActionCurrent = [[alertAction objectAtIndex:0] intValue];
    [alertAction removeObjectAtIndex:0];
    [firstAlert show];
    isShowingAlerts = YES;
    [firstAlert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Button index: %d", buttonIndex);    
    // 0 = close
    // 1 = view
    
    isShowingAlerts = NO;
    if (alertActionCurrent == ALERTVIEW_NOTIFICATION) {
        if (buttonIndex == 0) {
            [self handleNotificationBookmarks:NO];
        }
        if (buttonIndex == 1) {
            [self handleNotificationBookmarks:YES];
        }
    }
    else if (alertActionCurrent == ALERTVIEW_UPGRADE) {
        if (buttonIndex == 1) {
            NSString* launchUrl = @"http://testflightapp.com/";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
        }            
    }
    else if (alertActionCurrent == ALERTVIEW_PROMPT) {
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            NSString *entered = [(AlertPrompt *)alertView enteredText];
            NSLog(@"Alert prompt input value: %@", entered);
            
            [self adminEasterEggShowMenu:entered];
        }
    }
    else if (alertActionCurrent == ALERTVIEW_GOTOSTORE) {
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            // for now just go to the store
            [self.tabBarController setSelectedIndex:3];
            [self.storeViewShell viewWillAppear:YES];
            //[self.storeViewController displayBuxPricing];
        }
    }
    if ([alertQueue count] == 0)
        return;
    UIAlertView * nextAlert = [[alertQueue objectAtIndex:0] retain];
    [alertQueue removeObjectAtIndex:0];
    [nextAlert show];
    isShowingAlerts = YES;
    [nextAlert release];
}

/**** StoreView delegate ****/
-(void)didGetStixFromStore:(NSString *)stixStringID {
    //NSString * stixDescriptor = [BadgeView getStixDescriptorForStixStringID:stixStringID];
    //[self showAlertWithTitle:@"Stix Attained" andMessage:[NSString stringWithFormat:@"You have added the %@ Stix to your carousel!", stixDescriptor] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    //[self incrementStixCount:stixStringID];
    [allStix setObject:[NSNumber numberWithInt:-1] forKey:stixStringID]; 
    if ([allStixOrder valueForKey:stixStringID] == nil || [[allStixOrder valueForKey:stixStringID] intValue] == -1) {
        [allStixOrder setObject:[NSNumber numberWithInt:[allStixOrder count]] forKey:stixStringID];
    }
    // todo: check for consistency - the number of keys in allStixOrder should equal the largest value
    /*
    for (int i=0; i<[allCarouselViews count]; i++) {
        [[allCarouselViews objectAtIndex:i] reloadAllStix];
    }
     */
    [self reloadAllCarousels];
    NSMutableData * stixData = [[KumulosData dictionaryToData:allStix] retain];
    [k addStixToUserWithUsername:[self getUsername] andStix:stixData];
    
    // debug - see all stix counts
    NSEnumerator *e = [allStixOrder keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        int ct = [[allStixOrder objectForKey:key] intValue];
        if (ct != 0) {
            int order = [[allStixOrder objectForKey:key] intValue];
            NSLog(@"Stix: %@ order %d", key, order); 
        }
    }    
    
    NSMutableDictionary * auxiliaryDict = [[NSMutableDictionary alloc] init];
    [auxiliaryDict setObject:allStixOrder forKey:@"stixOrder"];
    [auxiliaryDict setObject:allFriends forKey:@"friendsList"];
    NSMutableData * newAuxData = [[KumulosData dictionaryToData:auxiliaryDict] retain];
    //[auxiliaryDict release];    
    [k updateAuxiliaryDataWithUsername:[self getUsername] andAuxiliaryData:newAuxData];
    
    [self changeBuxCountByAmount:-5];
    [stixData release];
    [newAuxData release];
    
    NSString * metricName = @"GetStixFromStore";
    NSString * metricData = [NSString stringWithFormat:@"User: %@ Stix: %@", [self getUsername], stixStringID];
    [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:0];
}

-(void)showNoMoreMoneyMessage {
    [self showAlertWithTitle:@"No More Bux" 
                  andMessage:@"You can't get any more stickers without any Bux!" 
                   andButton:@"OK"
//               andOtherButton:@"View" 
//                andAlertType:ALERTVIEW_GOTOSTORE];
              andOtherButton:nil
                andAlertType:ALERTVIEW_SIMPLE];
}

-(void)didPurchaseBux:(int)buxPurchased {
    [self showAlertWithTitle:@"Thank you!" andMessage:[NSString stringWithFormat:@"You have received %d Bux. Have fun buying stickers!", buxPurchased] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    [self changeBuxCountByAmount:buxPurchased];
    if  (buxPurchased == 25) {
        NSString * metricName = @"ExpressBux";
        NSString * metricData = [NSString stringWithFormat:@"User: %@", [self getUsername]];
        [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:buxPurchased];
    }
    else { 
        NSString * metricName = @"MoreBux";
        NSString * metricData = [NSString stringWithFormat:@"User: %@", [self getUsername]];
        [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:buxPurchased];
    }
}
@end
