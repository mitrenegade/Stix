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
//#import <MapKit/MapKit.h>
#import "FileHelpers.h"
#import "Kiip.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define START_ID 100
#define TAG_LOAD_WINDOW 3 // load this many tags before or after current tag
#define HOSTNAME @"stix.herokuapp.com"
//#define HOSTNAME @"localhost:3000"

#define DEBUGX 0

@implementation StixxAppDelegate

@synthesize window;
@synthesize emptyViewController;
@synthesize tagViewController;
@synthesize exploreController;
@synthesize tabBarController;
@synthesize feedController;
@synthesize profileController;
@synthesize friendController;
@synthesize loginSplashController;
@synthesize myUserInfo;
@synthesize lastViewController;
@synthesize allTags;
@synthesize timeStampOfMostRecentTag;
@synthesize allUserPhotos;
@synthesize allStix;
@synthesize allStixOrder;
@synthesize allFriends;
@synthesize k;
@synthesize allCommentCounts;
@synthesize allCarouselViews;
@synthesize loadingMessage;
@synthesize alertQueue;
@synthesize camera;
@synthesize metricLogonTime;
@synthesize lastKumulosErrorTimestamp;
@synthesize allCommentHistories;
#if USING_FACEBOOK
@synthesize fbHelper;
#endif
static const int levels[6] = {0,0,5,10,15,20};
static int init=0;
static NSString * uniqueDeviceID = nil;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    versionStringStable = @"0.7.8";
    versionStringBeta = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; //@"0.7.7.4";
    
    metricLogonTime = nil;
    
    /*** Kumulos service ***/
    
    k = [[Kumulos alloc]init];
    [k setDelegate:self];
    [self setLastKumulosErrorTimestamp: [NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    
    /*** device id on pasteboard ***/
	UIPasteboard *appPasteBoard = [UIPasteboard pasteboardWithName:@"StixAppPasteboard" create:YES];
	appPasteBoard.persistent = YES;
	uniqueDeviceID = [appPasteBoard string];    
    if (uniqueDeviceID == nil) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        uniqueDeviceID = (NSString *)CFUUIDCreateString(NULL,uuidRef);
        CFRelease(uuidRef);
        [appPasteBoard setString:uniqueDeviceID];
        NSLog(@"Unique device created and set to pasteboard: %@", uniqueDeviceID);
    }
    else {
        NSLog(@"Unique device retrieved from pasteboard: %@", uniqueDeviceID);
    }
    [uniqueDeviceID retain];
    NSString * description = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
    NSString * string = @"Application started";
    [k addMetricHitWithDescription:description andStringValue:string andIntegerValue:0];
    
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
    
    notificationDeviceToken = nil;
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
    fbHelper = [[FacebookHelper alloc] init];
    [fbHelper setDelegate:self];
    [fbHelper initFacebook];
    
	/***** create first view controller: the TagViewController *****/
    [loadingMessage setText:@"Initializing camera..."];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
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

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        [self initializeBadges];        
    });
    //[self performSelectorInBackground:@selector(initializeBadges) withObject:nil];
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
    allCommentHistories = [[NSMutableDictionary alloc] init];

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

	/***** create feed view *****/
    //[loadingMessage setText:@"Loading feed..."];
    
	//feedController = [[FeedViewController alloc] init];
    feedController = [[VerticalFeedController alloc] init];
    [feedController setDelegate:self];
    feedController.allTags = allTags;
    feedController.tabBarController = tabBarController;
    feedController.camera = camera; // hack: in order to present modal controllers that respond 

    /***** create explore view *****/
    exploreController = [[ExploreViewController alloc] init];
    exploreController.delegate = self;
	
	/***** create friends feed *****/
    //[loadingMessage setText:@"Networking with friends..."];
	friendController = [[FriendsViewController alloc] init];
    friendController.delegate = self;
    [self checkForUpdatePhotos];
    
	/***** create config view *****/
	profileController = [[ProfileViewController alloc] init];
    profileController.delegate = self;
    [profileController setCamera:self.camera];
    [profileController setFriendController:friendController];
    
    /***** add view controllers to tab controller, and add tab to window *****/
    emptyViewController = [[UIViewController alloc] init];
    //UITabBarItem *tbi = [emptyViewController tabBarItem];
	//UIImage * i = [UIImage imageNamed:@"tab_camera.png"];
	//[tbi setImage:i];
    //[tbi setTitle:@"Stix"];
	NSArray * viewControllers = [NSArray arrayWithObjects: feedController, emptyViewController, exploreController, nil];
    [tabBarController setViewControllers:viewControllers];
	[tabBarController setDelegate:self];
    [emptyViewController release];
    [exploreController setTabBarController:tabBarController];
    
    lastViewController = feedController;
    
    //[tabBarController addCenterButtonWithImage:[UIImage imageNamed:@"tab_addstix.png"] highlightImage:[UIImage imageNamed:@"tab_addstix_on.png"]];
    [tabBarController addButtonWithImage:[UIImage imageNamed:@"tab_feed2.png"] highlightImage:[UIImage imageNamed:@"tab_feed2_on.png"] atPosition:TABBAR_BUTTON_FEED];
    [tabBarController addButtonWithImage:[UIImage imageNamed:@"tab_explore2.png"] highlightImage:[UIImage imageNamed:@"tab_explore2_on.png"] atPosition:TABBAR_BUTTON_EXPLORE];
    [tabBarController addButtonWithImage:[UIImage imageNamed:@"tab_camera2.png"] highlightImage:nil atPosition:TABBAR_BUTTON_TAG];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tabBarController.view];
#endif
    
    [self didPressTabButton:TABBAR_BUTTON_FEED];
    
    myUserInfo->userphoto = nil;
    myUserInfo->bux = 0;
    myUserInfo->usertagtotal = 0;
    loggedIn = NO;
    isLoggingIn = NO;
    loginSplashController = [[FacebookLoginController alloc] init];
    [loginSplashController setDelegate:self];
    if (![fbHelper facebookHasSession]) // !myUserInfo->username || [myUserInfo->username length] == 0)
    {
        NSLog(@"Could not log in: forcing new login screen!");
#if 0
        loginSplashController = [[LoginSplashController alloc] init];
        [loginSplashController setDelegate:self];
        [loginSplashController setCamera:self.camera];
#endif
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
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
          //                                       (unsigned long)NULL), ^(void) {
        //[profileController loginWithUsername:myUserInfo->username];
        //});
        [self doFacebookLogin];
    }   
	
    /* display versioning info */
    if (versionIsOutdated)
    {
        [self showAlertWithTitle:@"Update Available" andMessage:[NSString stringWithFormat:@"This version of Stix (v%@) is out of date. Version %@ is available through TestFlight.", versionStringStable, currVersion] andButton:@"Close" andOtherButton:@"View" andAlertType:ALERTVIEW_UPGRADE];
    }
    
    /* add administration calls here */
    
    return YES;
}

/*** Versioning ***/

-(void)checkVersion {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    versionIsOutdated = 0;
    [k getAppInfoWithInfoType:@"version"];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAppInfoDidCompleteWithResult:(NSArray *)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // Tell Parse about the device token.
    [PFPush storeDeviceToken:newDeviceToken];
    // Subscribe to the global broadcast channel.

    [self Parse_unsubscribeFromAll];
    // register for notifications on update channel
    [self Parse_subscribeToChannel:@"StixUpdates"];
    [self Parse_subscribeToChannel:@""];
    if ([self getUsername] != nil && ![[self getUsername] isEqualToString:@"anonymous"])
    {
        [self Parse_subscribeToChannel:[self getUsername]];
    }
    
    notificationDeviceToken = [newDeviceToken retain];
}

/*** facebook delegates ***/

#pragma mark - facebook helper delegates
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [loginSplashController startActivityIndicator];
    return [self.fbHelper handleOpenURL:url]; 
}

-(void)didGetFacebookInfo:(NSDictionary *)results {
    NSLog(@"Did get facebook info!");
    NSEnumerator *e = [results keyEnumerator];
    NSString * name = @"";
    NSString * email;
    int facebookID;
    id key;
    while (key = [e nextObject]) {
        NSLog(@"Key: %@ %@", key, [results valueForKey:key]);
        /*
        if ([key isEqualToString:@"last_name"]) {
            str = [results valueForKey:key];
            name = [NSString stringWithFormat:@"%@ %@", name, str];
        }
        if ([key isEqualToString:@"first_name"]) {
            str = [results valueForKey:key];
            name = [NSString stringWithFormat:@"%@ %@", str, name];
        }
         */
        if ([key isEqualToString:@"name"]) {
            name = [results valueForKey:key];
        }
        if ([key isEqualToString:@"email"]) {
            email = [results valueForKey:key];
        }
        if ([key isEqualToString:@"id"]){
            facebookID = [[results valueForKey:key] intValue];
        }
    }
    
    [loginSplashController didGetFacebookName:name andEmail:email andID:facebookID];
}

-(FacebookHelper*)getFacebookHelper {
    return fbHelper;
}

-(void)doFacebookLogin {
    NSLog(@"Do facebook login");
    int ret = [self.fbHelper facebookLogin];

    // if ret == 0, then we were already logged in
    if (ret == 0)
        [fbHelper getFacebookInfo];
}

// functions called by fbHelper
-(void)didLoginToFacebook {
    NSLog(@"Did login to facebook");
    /*
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Login Success" message:@"You have been logged into facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
    */
    [fbHelper getFacebookInfo];
}

-(void)didLogoutFromFacebook {
    NSLog(@"Did logout from facebook");
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Logout Success" message:@"You have been logged out of facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

-(void)didCancelFacebookLogin {
    [loginSplashController stopActivityIndicator];
}

-(void)initializeBadges {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    //[BadgeView InitializeGenericStixTypes];
    //[self showAlertWithTitle:@"Initializing badges" andMessage:@"We are checking for new badges. Please be patient" andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];

    // load all stix types from Kumulos - doesn't take much
    [k getAllStixTypes];
    if (!stixViewsLoadedFromDisk)
        [k getAllStixViews];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getStixDataByStixStringIDDidCompleteWithResult:(NSArray *)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([theResults count] == 0)
        NSLog(@"Could not find a stix data! May be missing in Kumulos.");
    else
        [BadgeView AddStixView:theResults];
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllStixTypesDidCompleteWithResult:(NSArray *)theResults {     
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [BadgeView InitializeStixViews:theResults];
    NSLog(@"All %d Stix data initialized from kumulos!", [theResults count]);
    init++;
    if (init >= 2) {
        if ([self isLoggedIn])
            [self reloadAllCarousels];
        //[self continueInit];
    }
}
    
- (void) saveDataToDisk {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSString * path = [self coordinateArrayPath];
 	
    NSMutableDictionary * rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue: myUserInfo->username forKey:@"username"];
    [rootObject setValue: [NSNumber numberWithInt:myUserInfo->bux] forKey:@"bux"];

    @try {
        // save stix types that we know about
        NSMutableArray * stixStringIDs = [BadgeView GetAllStixStringIDsForSave];
        NSMutableDictionary * stixViews = [BadgeView GetAllStixViewsForSave];
        NSMutableDictionary * stixDescriptors = [BadgeView GetAllStixDescriptorsForSave];
        NSMutableDictionary * stixCategories = [BadgeView GetAllStixCategoriesForSave];
        NSMutableDictionary * stixSubcategories = [BadgeView GetAllStixSubcategoriesForSave];
        
        [rootObject setValue:stixStringIDs forKey:@"stixStringIDs"];
        [rootObject setValue:stixViews forKey:@"stixViews"];
        NSLog(@"Saving %d stix views to disk", [stixViews count]);
        [rootObject setValue:stixDescriptors forKey:@"stixDescriptors"];
        [rootObject setValue:stixCategories forKey:@"stixCategories"];
        [rootObject setValue:stixSubcategories forKey:@"stixSubcategories"];
        NSLog(@"Saving %d stix subcategories to disk", [stixSubcategories count]);
        
        [NSKeyedArchiver archiveRootObject: rootObject toFile: path];
    } 
    @catch (NSException *exception) {
        NSLog(@"SaveDataToDisk encountered an exception! %@", [exception reason]);
    }
}

- (int) loadDataFromDisk {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
    myUserInfo->bux = [[rootObject valueForKey:@"bux"] intValue];
    
    @try {
        NSMutableArray * stixStringIDs = [rootObject valueForKey:@"stixStringIDs"];
        NSMutableDictionary * stixViews = [rootObject valueForKey:@"stixViews"];
        NSMutableDictionary * stixDescriptors = [rootObject valueForKey:@"stixDescriptors"];
        NSMutableDictionary * stixCategories = [rootObject valueForKey:@"stixCategories"];
        
        NSLog(@"LoadDataFromDisk: %d stixViews %d stixCategories", [stixViews count], [stixCategories count]);
        
        if (stixViews != nil)
        {
            NSLog(@"Loading %d saved Stix from disk", [stixViews count]);
            [BadgeView InitializeFromDiskWithStixStringIDs:stixStringIDs andStixViews:stixViews andStixDescriptors:stixDescriptors andStixLikelihoods:nil andStixCategories:stixCategories];
            NSMutableDictionary * stixSubcategories = [rootObject valueForKey:@"stixSubcategories"];
            if (stixSubcategories != nil && [stixSubcategories count] != 0) {
                NSLog(@"%d StixSubcategories loaded from disk!", [stixSubcategories count]);
                [BadgeView InitializeStixSubcategoriesFromDisk:stixSubcategories];
            }
            else
            {
                NSLog(@"StixSubcategories not loaded from disk! Loading from Kumulos...");
                [[KumulosHelper sharedKumulosHelper] execute:@"getSubcategories" withParams:nil withCallback:@selector(didGetKumulosSubcategories:) withDelegate:self]; 
                return 0;
            }
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

-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self performSelector:callback withObject:params afterDelay:0];
}
-(void)didGetKumulosSubcategories:(NSMutableArray*)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSMutableArray * stixSubcategoriesFromKumulos = [theResults objectAtIndex:0];
    [BadgeView InitializeStixSubcategoriesFromKumulos:stixSubcategoriesFromKumulos];
    NSLog(@"%d StixSubcategories loaded from Kumulos!", [stixSubcategoriesFromKumulos count]);
    [self reloadAllCarousels];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        [self saveDataToDisk];
    });
}

#if 0
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    //[self.tabBarController toggleFirstTimeInstructions:NO];
    //[self.tabBarController toggleStixMallPointer:NO];

    if (lastViewController == viewController)
        return;
    
    if ([self.tabBarController selectedIndex] == 1) {
        // selected center - must manually change to camera view
#if !TARGET_IPHONE_SIMULATOR
        [self.camera setCameraOverlayView:tagViewController.view];
#endif
        return;
    }
    /*
    if (lastViewController == tagViewController)
    {
        [self.tabBarController setButtonStateNormal]; // disable highlighted button
        [tagViewController dismissModalViewControllerAnimated:NO];
        [viewController viewWillAppear:TRUE];
        lastViewController = viewController;
    }
    else if (lastViewController == friendController) // if we leave friend controller, start an update for next time
    {
        [self checkForUpdatePhotos];
        [viewController viewWillAppear:TRUE];
        lastViewController = viewController;
    }
     */
    if (lastViewController == feedController)
    {
        //[viewController viewWillAppear:TRUE];
        lastViewController = viewController;
    }
    else if (lastViewController == exploreController)
    {
        //[viewController viewWillAppear:TRUE];
        lastViewController = viewController;
    }

    lastViewController = viewController;
        
    // enabled highlighted button - not done here
    //if (viewController == tagViewController)
    //    [self.tabBarController setButtonStateSelected];
}
#endif

// RaisedCenterTabBarController delegate 
-(void)didPressTabButton:(int)pos {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // when center button is pressed, programmatically send the tab bar that command
    [tabBarController setSelectedIndex:pos];
    [tabBarController setButtonStateSelected:pos]; // highlight button
#if !TARGET_IPHONE_SIMULATOR
    if (pos == TABBAR_BUTTON_TAG) {
        [self.camera setCameraOverlayView:tagViewController.view];
    }
    else if (pos == TABBAR_BUTTON_FEED) {
        lastViewController = feedController;
    }
    else if (pos == TABBAR_BUTTON_EXPLORE) {
        lastViewController = exploreController;
    }
#endif
}

-(void)didDismissSecondaryView {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    //[tabBarController setButtonStateNormal:TABBAR_BUTTON_TAG]; // highlight button
    [feedController configureCarouselView];
    [feedController.carouselView carouselTabDismiss:YES];
    if (lastViewController == feedController) {
        [self didPressTabButton:TABBAR_BUTTON_FEED];
        //[self.tabBarController setSelectedIndex:TABBAR_BUTTON_FEED];
    }
    else if (lastViewController == exploreController) {
        [self didPressTabButton:TABBAR_BUTTON_EXPLORE];
        //[self.tabBarController setSelectedIndex:2];
    }
    //else if (lastViewController == profileController) {
    //    [self.tabBarController setSelectedIndex:4];
    //}
#if !TARGET_IPHONE_SIMULATOR
    [self.camera setCameraOverlayView:tabBarController.view];
#endif
}

-(void)logMetricTimeInApp {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (metricLogonTime) {
        NSTimeInterval lastDiff = [metricLogonTime timeIntervalSinceNow];
        NSString * description = @"TimeInAppInSeconds";
        NSString * str = [NSString stringWithFormat:@"Username: %@ UID: %@", [self getUsername], uniqueDeviceID];
        [k addMetricHitWithDescription:description andStringValue:str andIntegerValue:-lastDiff];
        metricLogonTime = nil;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{	// Get full path of possession archive 
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (init == 2) {
        //NSString *path = [self coordinateArrayPath];
        NSLog(@"Logging out and saving username %@", myUserInfo->username);
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
          //                                       (unsigned long)NULL), ^(void) {
            [self saveDataToDisk];
        //});

        [self logMetricTimeInApp];
    }

#if USING_KIIP
    // End the Kiip session when the app terminates
    [[KPManager sharedManager] endSession];
#endif
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{	// Get full path of possession archive 
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    
    // archive username
    if (init == 2) {
        //NSString *path = [self coordinateArrayPath];
        NSLog(@"Logging out and saving username %@", myUserInfo->username);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                                 (unsigned long)NULL), ^(void) {
        [self saveDataToDisk];
        });
        [self logMetricTimeInApp];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        [self initializeBadges];
    });
    //[self performSelectorInBackground:@selector(initializeBadges) withObject:nil];
    //[self initializeBadges];
    
    [self setMetricLogonTime: [NSDate date]];
}

- (void)application:(UIApplication *)application 
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    return [self addTagWithCheck:tag withID:newID overwrite:NO];
}

-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID overwrite:(bool)bOverwrite {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
            // update IDs so we know this content has been received
            if (newID > idOfNewestTagReceived)
                idOfNewestTagReceived = newID;
            if (newID < idOfOldestTagReceived)
                idOfOldestTagReceived = newID;

            // add into feed if it meets criteria
            if (1) { // [allFriends containsObject:tag.username]) {
                [allTags insertObject:tag atIndex:i];
                [self getCommentCount:newID]; // store comment count for this tag
                added = YES;
            }
            else 
                added = NO;
            break;
        }
    }
    if (!added && !alreadyExists)
    {
        if (newID > idOfNewestTagReceived)
            idOfNewestTagReceived = newID;
        if (newID < idOfOldestTagReceived)
            idOfOldestTagReceived = newID;
        if (1) { //[allFriends containsObject:tag.username]) {
            [allTags insertObject:tag atIndex:i];
            [self getCommentCount:newID]; // store comment count for this tag
            added = YES;
        }
        else 
            added = NO;
    }
    [tag release];
    return added;
}

-(void)didCreateNewPix:(Tag *)newTag {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // when adding a tag, we add it to both our local tag structure, and to kumulos database
    //[allTags addObject:newTag];

    [self didDismissSecondaryView];
    [tabBarController setSelectedIndex:0];
    [feedController configureCarouselView];
    [feedController.carouselView carouselTabDismiss:YES];
    
    // this function migrates toward not using the basic stix
    newestTag = [newTag retain];
    
    [k setDelegate:self];
    NSData * theImgData = UIImageJPEGRepresentation([newTag image], .8); 
    //UIImage * thumbnail = [[newTag image] resizedImage:CGSizeMake(100, 100) interpolationQuality:kCGInterpolationMedium];
    
    // this must match Tag.m:getTagFromDictionary
    NSMutableData *theCoordData;
    NSKeyedArchiver *encoder;
    theCoordData = [NSMutableData data];
    encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theCoordData];
	//[encoder encodeObject:newTag.coordinate forKey:@"coordinate"];
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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

    // if we added a stix, save stix as comment history
    NSString * stixStringID = [newestTag.auxStixStringIDs objectAtIndex:0];
    if (stixStringID != nil) {
        NSLog(@"New pix has a new stix also: %@", [BadgeView getStixDescriptorForStixStringID:stixStringID]);
        //[self didAddCommentWithTagID:[newestTag.tagID intValue] andUsername:myUserInfo->username andComment:@"" andStixStringID:stixStringID];
        [k addCommentToPixWithTagID:[newestTag.tagID intValue] andUsername:myUserInfo->username andComment:@"" andStixStringID:stixStringID];
    }

    // do not add scale and rotation - all saved in aux stix
    [self updateUserTagTotal];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation updateTotalTagsDidCompleteWithResult:(NSNumber*)affectedRows {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Updated user tag totals: affect rows %d\n", [affectedRows intValue]);
    @try {
        [profileController updatePixCount];
    } @catch (NSException * e) {
        NSLog(@"exception: %@", [e reason]);
    }
}

- (void)clearTags {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [allTags removeAllObjects];
    [tagViewController clearTags];
}

/**** FeedViewDelegate ****/

// Checking for new items at the beginning of the list

- (void) checkForUpdateTags {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    int numTags = 1;
    NSLog(@"Checking for updated tag ids on kumulos");
    NSNumber * number = [[NSNumber alloc] initWithInt:numTags];
    //[k getLastTagTimestampWithNumEls:number];
    [k getLastTagIDWithNumEls:number];
    [number release];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getLastTagIDDidCompleteWithResult:(NSArray*)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
        NSLog(@"Requesting recent Pix with id %d from Kumulos", idOfNewestTagOnServer);
        [k getAllTagsWithIDRangeWithId_min:idOfNewestTagOnServer-1 andId_max:idOfNewestTagOnServer+1];
        idOfLastTagChecked = idOfNewestTagOnServer;
    }
    else {
        NSLog(@"Tag %d already downloaded. allTags count = %d", idOfNewestTagOnServer, [allTags count]);
        if ([allTags count] == 0) { // try again
            [k getAllTagsWithIDRangeWithId_min:idOfNewestTagOnServer-1 andId_max:idOfNewestTagOnServer+1];
        }
    }
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray *)theResults
{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
        [feedController stopActivityIndicator];
        //[feedController.activityIndicator stopCompleteAnimation];
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
            NSString * stixStringDesc = [BadgeView getStixDescriptorForStixStringID:stixStringID];
            NSString * article = @"a";
            if ([stixStringDesc characterAtIndex:0] == 'A' ||
                [stixStringDesc characterAtIndex:0] == 'E' ||
                [stixStringDesc characterAtIndex:0] == 'I' ||
                [stixStringDesc characterAtIndex:0] == 'O' ||
                [stixStringDesc characterAtIndex:0] == 'U'
                ) {
                article = @"an";
            }
            NSString * message = [NSString stringWithFormat:@"%@ added %@ %@ to your Pix!", myUserInfo->username, article, [BadgeView getStixDescriptorForStixStringID:stixStringID]];
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Update finally completed");
    isUpdatingPeelableStix = NO;
}

-(void)getNewerTagsThanID:(int)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (1) { //pageOfLastOlderTagsRequest != tagID) {
        pageOfLastOlderTagsRequest = tagID;
        [k getAllTagsWithIDLessThanWithAllTagID:tagID andNumTags:[NSNumber numberWithInt:TAG_LOAD_WINDOW]];
    }
    else{
        //NSLog(@"Duplicate call to getOlderTagsThanID: id %d", tagID);
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDGreaterThanDidCompleteWithResult:(NSArray *)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
    [feedController stopActivityIndicator];
    //[feedController.activityIndicator stopCompleteAnimation];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDLessThanDidCompleteWithResult:(NSArray *)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
    [feedController stopActivityIndicator];
    //[feedController.activityIndicator stopCompleteAnimation];
}

- (NSMutableArray *) getTags {
    return allTags;
}

-(void)addCommentToPixCompleted:(NSMutableArray*)params {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSNumber * tagID = [params objectAtIndex:0];
    if (tagID) {
        //[self getCommentCount:[tagID intValue]];
        [k getAllHistoryWithTagID:[tagID intValue]];
    }
}

-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
#if 1
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:tagID], name, comment, stixStringID, nil];
    [[KumulosHelper sharedKumulosHelper] execute:@"addCommentToPix" withParams:params withCallback:@selector(addCommentToPixCompleted:) withDelegate:self];
    NSLog(@"Kumulos: Adding comment to tagID %d", tagID);
#else
    [k addCommentToPixWithTagID:tagID andUsername:name andComment:comment andStixStringID:stixStringID];
#endif
    if (![comment isEqualToString:@""]) {
        // actual comment

        // notify
        NSString * message = [NSString stringWithFormat:@"%@ commented on your feed: %@", myUserInfo->username, comment];
        Tag * tag = [self getTagWithID:tagID];
        if (![tag.username isEqualToString:[self getUsername]])
            [self Parse_sendBadgedNotification:message OfType:NB_NEWCOMMENT toChannel:tag.username withTag:tag.tagID orGiftStix:nil];
        [self updateUserTagTotal];
        // don't updateCommentCount;
        // touch tag to indicate it was updated
        [k touchPixToUpdateWithAllTagID:tagID];
    }
}

-(int)getCommentCount:(int)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSNumber * commentCount = [allCommentCounts objectForKey:[NSNumber numberWithInt:tagID]];
    if (commentCount == nil)
        [k getAllHistoryWithTagID:tagID];
    else
        return [commentCount intValue];
    
    return 0;
}

-(void)updateCommentCount:(int)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // get most recent comment count from kumulos
    [k getAllHistoryWithTagID:tagID];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllHistoryDidCompleteWithResult:(NSArray *)theResults{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    
    if ([theResults count] == 0)
        return;
    
    NSMutableDictionary * d = [theResults objectAtIndex:0];        
    NSNumber * tagID = [d valueForKey:@"tagID"]; 
    [allCommentHistories setObject:d forKey:tagID];
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

-(NSMutableDictionary *)getCommentHistoriesForTag:(Tag*)tag {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    return [allCommentHistories objectForKey:tag.tagID];
}

/***** FriendsViewDelegate ********/
-(void)didDismissFriendView {}; // only used in profileView
-(void) checkForUpdatePhotos {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (1) // todo: check for updated users by id
    {
        [friendController setIndicator:YES];
        
        [k getAllUsers];
    }
}
-(void)didSendGiftStix:(NSString *)stixStringID toUsername:(NSString *)friendName {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSString * message = [NSString stringWithFormat:@"%@ sent you a %@!", myUserInfo->username, [BadgeView getStixDescriptorForStixStringID:stixStringID]];
    [self Parse_sendBadgedNotification:message OfType:NB_NEWGIFT toChannel:friendName withTag:nil orGiftStix:stixStringID];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
-(UIImage*)getUserPhotoForUsername:(NSString *)username {
    return [[UIImage alloc] initWithData:[allUserPhotos objectForKey:username]];
}

/**** LoginSplashController delegate ****/

/**** ProfileViewController and login functions ****/
-(void)didOpenProfileView {
    // hack a way to display feedback view over camera: formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [profileController.view setFrame:frameShifted];
#if !TARGET_IPHONE_SIMULATOR
    //[self.camera setCameraOverlayView:profileController.view];
#endif
    [tabBarController.view addSubview:profileController.view];
    [profileController viewWillAppear:YES]; // force updates -> hack: this doesn't automatically happen??
}

-(void)closeProfileView {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self.profileController.view removeFromSuperview];
    [self.camera setCameraOverlayView:self.tabBarController.view];
}

-(void)didClickChangePhoto {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    //[camera presentModalViewController:picker animated:YES];
    [profileController presentModalViewController:picker animated:YES];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    //    [[picker parentViewController] dismissModalViewControllerAnimated: YES];    
    //    [picker release];    
    
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    [profileController dismissModalViewControllerAnimated:TRUE];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tabBarController.view];
#endif
    [tabBarController setSelectedIndex:0];
    [profileController viewWillAppear:YES];
    [picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
	UIImage * originalPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage * editedPhoto = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage * newPhoto; 
    //newPhoto = [UIImage imageNamed:@"friend1.png"];
    if (editedPhoto)
        newPhoto = editedPhoto;
    else
        newPhoto = originalPhoto; 
    
    NSLog(@"Finished picking image: dimensions %f %f", newPhoto.size.width, newPhoto.size.height);
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [profileController dismissModalViewControllerAnimated:TRUE];
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tabBarController.view];
#endif
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
    //if (lastViewController == feedController)
    //    [self didPressTabButton:0];
    //else if (lastViewController == exploreController)
    //    [self didPressTabButton:2];
    //[self closeProfileView];
    [picker release];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPhotoDidCompleteWithResult:(NSNumber*)affectedRows;
{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Added photo to username %@",  myUserInfo->username);
    
    // force friendView to update photo after we know it is in kumulos
    [self checkForUpdatePhotos];
}

- (NSString *)coordinateArrayPath
{	
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    return pathInDocumentDirectory(@"StixxUserData.data");
}

-(void)kumulosAPI:(kumulosProxy *)kumulos apiOperation:(KSAPIOperation *)operation didFailWithError:(NSString *)theError {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
    NSDate * now = [NSDate date];
    NSLog(@"Last error timestamp: %@ now: %@", lastKumulosErrorTimestamp, now);
    NSDate * thirtyMore = [lastKumulosErrorTimestamp dateByAddingTimeInterval:30];
    NSComparisonResult compared = [thirtyMore compare:now];//[thirtyMore earlierDate:now];
    NSString * compareSymbol = @"=";
    if (compared == NSOrderedAscending)
        compareSymbol = @"<";
    else if (compared == NSOrderedDescending)
        compareSymbol = @">";
    NSLog(@"%@ %@ %@", thirtyMore, compareSymbol, now);
    if ( compared == NSOrderedAscending )
    {
        [self setLastKumulosErrorTimestamp:now];
        [self showAlertWithTitle:@"Network Error" andMessage:@"Your network connectivity is too weak. Connection to the servers failed!" andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    }
}

-(void)didLoginFromSplashScreenWithUsername:(NSString *)username andPhoto:(UIImage *)photo andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary*) stixOrder andFriendsList:(NSMutableSet*)friendsList isFirstTimeUser:(BOOL)firstTime {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    
    [photo retain];
    [stix retain];
    
    NSLog(@"DidLoginFromSplashScreen: username %@ stix %d, stixOrder %d", username, [stix count], [stixOrder count]);
    
    /***** if we used splash screen *****/
    @try {
        [self didDismissSecondaryView];
    }
    @catch (NSException * e) {
        NSLog(@"Login from splash screen: dismiss secondary view broken! %@", [e reason]);
    }
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
    //if (firstTime) {
    //    [tabBarController addFirstTimeInstructions];
    //}
}

- (void)didLoginWithUsername:(NSString *)name andPhoto:(UIImage *)photo andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary *)stixOrder andFriendsList:(NSMutableSet *)friendsList {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSString * description = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
    NSString * string = [NSString stringWithFormat:@"User login: %@", name];
    [k addMetricHitWithDescription:description andStringValue:string andIntegerValue:0];

    if (![stix isKindOfClass:[NSMutableDictionary class]]) {
        stix = nil;
        [allStix removeAllObjects];
    }
    else {
        [stix retain];
        [allStix removeAllObjects];
        [allStix addEntriesFromDictionary:stix];
        [stix release];
    }
    if (![stixOrder isKindOfClass:[NSMutableDictionary class]]) {
       
        stixOrder = nil;
        [stixOrder removeAllObjects];
    }
    else {
        [stixOrder retain];
        [allStixOrder removeAllObjects];
        [allStixOrder addEntriesFromDictionary:stixOrder];
        [stixOrder release];
        
        NSLog(@"DidLoginWithUsername: %@ allStix: %d stixOrder: %d", name, [allStix count], [stixOrder count]);

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
    
    // do consistency check on stix and stix order
    [self checkConsistency];
    
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
    
    //[myStixController forceLoadMyStix];
    [self reloadAllCarousels];
    if (notificationDeviceToken) {
        [self Parse_subscribeToChannel:[self getUsername]];
    }
    else
        // try registering again
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];    

    [self updateBuxCount];
    //[profileController updatePixCount];    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        [self saveDataToDisk];
    });
    
    //[self performSelectorInBackground:@selector(saveDataToDisk) withObject:self];
    //[self saveDataToDisk];
    
    [self setMetricLogonTime:[NSDate date]];
    
    [self closeProfileView];
}

-(void)checkConsistency { 
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // if stix got messed up or stixOrders got messed up
    for (int i=0; i<[BadgeView totalStixTypes]; i++) {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
        NSNumber * count = [allStix objectForKey:stixStringID];
        NSNumber * order = [allStixOrder objectForKey:stixStringID];

        if (count && !order) {
            // create an order
            if ([count intValue] != 0)
            {
                int orderInt = [allStixOrder count];
                [allStixOrder setObject:[NSNumber numberWithInt:orderInt] forKey:stixStringID];
                NSLog(@"Consistency: count for %@ = %d, new order %d", [BadgeView getStixDescriptorForStixStringID:stixStringID], [count intValue], orderInt);
            }
        }
        if (order && !count) {
            if ([order intValue] != -1)
            {
                [allStix setObject:[NSNumber numberWithInt:-1] forKey:stixStringID];
                NSLog(@"Consistency: order for %@ = %d, new count %d", [BadgeView getStixDescriptorForStixStringID:stixStringID], [order intValue], -1);
            }
        }
    }
    if ([allStix count] == 0 && [allStixOrder count] == 0) {
        // generate defaults
        [allStix addEntriesFromDictionary:[BadgeView generateDefaultStix] ];
        
        [allStixOrder setObject:[NSNumber numberWithInt:0] forKey:@"FIRE"];
        [allStixOrder setObject:[NSNumber numberWithInt:1] forKey:@"ICE"];
        NSLog(@"Generating stix order:");
        NSEnumerator *e = [allStix keyEnumerator];
        id key;
        while (key = [e nextObject]) {
            if (![key isEqualToString:@"FIRE"] && ![key isEqualToString:@"ICE"]) {
                int ct = [self getStixCount:key];
                if (ct != 0)
                    [allStixOrder setObject:[NSNumber numberWithInt:[allStixOrder count]] forKey:key];
            }
        }    
    }
}

-(void)didLogout {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    loggedIn = NO;
    myUserInfo->username = @"";
    if (myUserInfo->userphoto) {
        [myUserInfo->userphoto release];
        myUserInfo->userphoto = nil;
    }
    myUserInfo->usertagtotal = 0;
    myUserInfo->bux = 0;
    [allStix removeAllObjects];
    [allStixOrder removeAllObjects];
    [self logMetricTimeInApp];
    
    [fbHelper facebookLogout];
    [self didDismissSecondaryView];
#if !TARGET_IPHONE_SIMULATOR
    [self.camera setCameraOverlayView:loginSplashController.view];
#endif
    /*
    [self.tabBarController toggleStixMallPointer:NO]; // stop stix mall pointer
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                                 (unsigned long)NULL), ^(void) {
            [self saveDataToDisk];
        });
        
        [allStix removeAllObjects];
        [profileController updatePixCount];
        
        [self logMetricTimeInApp];
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
     */
}

-(void)didChangeUserphoto:(UIImage *)photo {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    myUserInfo->userphoto = photo;
}

-(int)getStixCount:(NSString*)stixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    //if (loggedIn)
    if ([stixStringID isEqualToString:@"FIRE"] || [stixStringID isEqualToString:@"ICE"] || [[BadgeView getStixDescriptorForStixStringID:stixStringID] isEqualToString:@"Generic"])
        return -1;
    int ret = [[allStix objectForKey:stixStringID] intValue];
    //NSLog(@"Stix count for %@: %d", stixStringID, ret);
    return ret;
}

-(int)getStixOrder:(NSString*)stixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([allStixOrder objectForKey:stixStringID] == nil) {
        //int pos = -1;
        //[allStixOrder setValue:[NSNumber numberWithInt:ct] forKey:stixStringID];
        return -1;
    }
    else
        return [[allStixOrder objectForKey:stixStringID] intValue];
}

-(NSMutableSet*)getFriendsList {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    return allFriends;
}
-(void)didUpdateFriendsList {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Updated friends list: total friends %d", [allFriends count]);
    [self.profileController updateFriendCount];
    // todo: save friends List to kumulos
    NSMutableDictionary * auxiliaryDict = [[NSMutableDictionary alloc] init];
    [auxiliaryDict setObject:allStixOrder forKey:@"stixOrder"];
    [auxiliaryDict setObject:allFriends forKey:@"friendsList"];
    NSMutableData * newAuxData = [[KumulosData dictionaryToData:auxiliaryDict] retain];
    //[auxiliaryDict release];    
    [k updateAuxiliaryDataWithUsername:[self getUsername] andAuxiliaryData:newAuxData];
}
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addStixToUserDidCompleteWithResult:(NSArray*)theResults;
{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // all debug
    for (NSMutableDictionary * d in theResults)
    {
        NSString * name = [d valueForKey:@"username"];
        NSLog(@"Updated stix counts for user %@: %d stix", name, [allStix count]);
    }
}

-(void)didAddStixToPix:(Tag *)tag withStixStringID:(NSString*)stixStringID withLocation:(CGPoint)location /*withScale:(float)scale withRotation:(float)rotation*/ withTransform:(CGAffineTransform)transform{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
   
    [feedController configureCarouselView];
    [feedController.carouselView carouselTabDismiss:YES];
    
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
    
    /*
    if ([self getStixCount:stixStringID] == 0) {
        // ran out of a nonpermanent stix
        [feedController.carouselView carouselTabDismissRemoveStix];
        [tagViewController.descriptorController.carouselView carouselTabDismissRemoveStix];
    }
     */
    
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    Tag * tag = [allTags objectAtIndex:tagIndex];
    isUpdatingPeelableStix = YES;
    updatingPeelableAction = action;
    updatingPeelableTagID = [tag.tagID intValue];
    updatingPeelableAuxStixIndex = index;

    [k getAllTagsWithIDRangeWithId_min:[tag.tagID intValue]-1 andId_max:[tag.tagID intValue]+1];
}

// not used
-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updatePixDidCompleteWithResult:(NSNumber *)affectedRows {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [feedController reloadCurrentPage];
}

-(int)getNewestTagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    return MAX(idOfNewestTagReceived, idOfNewestTagOnServer);
}

-(NSString *) getUsername {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (loggedIn == YES)
    {
        //NSLog(@"[delegate getUsername] returning %@", username);
        return myUserInfo->username;
    }
    //NSLog(@"[delegate getUsername] returning anonymous");
    return @"anonymous";
}

-(UIImage *) getUserPhoto {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([self isLoggedIn] == NO)
        return [UIImage imageNamed:@"graphic_nouser.png"];
    return myUserInfo->userphoto;
}

-(int)getUserTagTotal { return myUserInfo->usertagtotal; }
-(int)getBuxCount { return myUserInfo->bux; }
//-(bool)isFirstTimeUser { return NO; }// myUserInfo->isFirstTimeUser; }
//-(bool)hasAccessedStore { return YES; }//myUserInfo->hasAccessedStore; }


-(void)changeBuxCountByAmount:(int)change {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    myUserInfo->bux += change;
    [k changeUserBuxByAmountWithUsername:[self getUsername] andBuxChange:change];
    [self updateBuxCount];
}

-(void)rewardBux {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSString * title = @"Active Stix User";
    int amount = 5;
    [self.tabBarController doRewardAnimation:title withAmount:amount];
    //[self showAlertWithTitle:@"Award!" andMessage:[NSString stringWithFormat:@"You have been awarded five Bux!"] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    //[self changeBuxCountByAmount:amount];
}
-(void)didFinishRewardAnimation:(int)amount {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self changeBuxCountByAmount:amount];
}
-(void)rewardLocation {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSString * title = @"Location Added";
    int amount = 1;
    [self.tabBarController doRewardAnimation:title withAmount:amount];
    //[self showAlertWithTitle:@"Award!" andMessage:[NSString stringWithFormat:@"You have been awarded five Bux!"] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    //[self changeBuxCountByAmount:amount];
}
-(void)rewardStix {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
    [self reloadAllCarousels];
    NSMutableData * data = [KumulosData dictionaryToData:allStix];
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
}

-(void)updateUserTagTotal {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // update usertagtotal
    myUserInfo->usertagtotal += 1;
    [k updateTotalTagsWithUsername:myUserInfo->username andTotalTags:myUserInfo->usertagtotal];
    if ((myUserInfo->usertagtotal % 5) == 0) {
        //[self rewardStix];
        [self rewardBux];
        //[self reloadAllCarousels];
    }
#if USING_KIIP
    [[KPManager sharedManager] updateScore:usertagtotal onLeaderboard:@"topDailyStixter"];
#endif
}

-(bool)isLoggedIn {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    return loggedIn;
}

-(void)didCreateBadgeView:(UIView *)newBadgeView {
//    if (lastViewController != nil) {
//    }
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [allCarouselViews addObject:newBadgeView];
}

-(void)didClickFeedbackButton:(NSString *)fromView {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // formerly dismissModalViewController
    [self didDismissSecondaryView];
}

- (void) sendEmailTo:(NSString *)to withCC:(NSString*)cc withSubject:(NSString *) subject withBody:(NSString *)body {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
	NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&bcc=%@&subject=%@&body=%@",
							[to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [cc stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
							[subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [body  stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
    NSLog(@"Sending mail: mailstring %@", mailString);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}

-(void)didSubmitFeedbackOfType:(NSString *)type withMessage:(NSString *)message {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Feedback submitted for %@ by %@", type, [self getUsername]);
    NSString * subject = [NSString stringWithFormat:@"%@ sent from %@", type, myUserInfo->username];
    NSString * fullmessage = [NSString stringWithFormat:@"Stix version Stable %@ Beta %@\n\n%@", versionStringStable, versionStringBeta, message];
	[self sendEmailTo:@"bobbyren@gmail.com, willh103@gmail.com" withCC:@"" withSubject:subject withBody:fullmessage];
    [self didDismissSecondaryView];
}

-(void)uploadImage:(NSData *)dataPNG withShareMethod:(int)method{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
   NSData *imageData = dataPNG;
    NSString * username = [[self getUsername] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString * serverString = [NSString stringWithFormat:@"http://%@/users/%@/pictures", HOSTNAME, username];
    NSURL *url=[[NSURL alloc] initWithString:serverString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setData:imageData forKey:@"picture[data]"];
    [request startSynchronous];
    shareMethod = method;
}

-(void)sharePix:(int)tagID {
    //[self.delegate sharePix:tagID];
    shareActionSheetTagID = tagID;
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Pix" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Email", /*@"Move", */nil];
    [actionSheet setTag:ACTIONSHEET_TAG_SHAREPIX];
    [actionSheet showFromTabBar:tabBarController.tabBar ];
    [actionSheet release];
}

-(void)didSharePixWithURL:(NSString *)url andImageURL:(NSString*)imageURL{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
   NSLog(@"Pix shared by %@ at %@", [self getUsername], url);
    NSString * subject = [NSString stringWithFormat:@"%@ has shared a Stix picture with you!", myUserInfo->username];
    NSString * fullmessage = [NSString stringWithFormat:@"Stix version Stable %@ Beta %@\n\n%@ has shared a Pix with you! See it here: %@", versionStringStable, versionStringBeta, [self getUsername], url];
    if (shareMethod == 0) {
        // facebook
        [fbHelper postToFacebookWithLink:url andPictureLink:imageURL andTitle:@"Stix it!" andCaption:@"View my Stix collection" andDescription:@"Remix your photos with Stix! Click here to see my Pix."];
    }
    else if (shareMethod == 1) {
        // email
        [self sendEmailTo:@"" withCC:@"" withSubject:subject withBody:fullmessage];        
    }
    [self didDismissSecondaryView];
    
}

-(void)didClickInviteButton {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Invite button submitted by %@", [self getUsername]);
    NSString * subject = [NSString stringWithFormat:@"Become a Stixster!"];
    NSString * body = [NSString stringWithFormat:@"I'm playing Stix on my iPhone and I think you'd enjoy it too! Just click <a href=\"http://bit.ly/sjvbNE\">here</a> to get started!"];
    [self sendEmailTo:@"" withCC:@"bobbyren@gmail.com, willh103@gmail.com" withSubject:subject withBody:body];
    [self rewardBux];
}

/*** processing stix counts ***/

// debug
-(void)adminUpdateAllStixCountsToZero {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSMutableDictionary * stix = [[BadgeView generateDefaultStix] retain];   
    NSMutableData * data = [[KumulosData dictionaryToData:stix] retain];
    [k adminAddStixToAllUsersWithStix:data];
    [data autorelease]; // MRC
    [stix autorelease];
}

-(void)adminUpdateAllStixCountsToOne {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
   NSMutableDictionary * stix = [[BadgeView generateOneOfEachStix] retain]; 
    int ct = [[stix objectForKey:@"HEART"] intValue];
    NSLog(@"Heart: %d", ct);
    NSMutableData * data = [[KumulosData dictionaryToData:stix] retain];
    [k adminAddStixToAllUsersWithStix:data];
    [data autorelease]; // MRC
    [stix autorelease];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation adminAddStixToAllUsersDidCompleteWithResult:(NSNumber *)affectedRows {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self Parse_sendBadgedNotification:@"Ninja admin stix update" OfType:NB_UPDATECAROUSEL toChannel:@"" withTag:nil orGiftStix:nil];
}

-(void)adminIncrementAllStixCounts {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
    [self reloadAllCarousels];
    NSMutableData * data = [[KumulosData dictionaryToData:allStix] retain];
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
    [data autorelease]; // MRC
}

-(void)adminSetUnlimitedStix {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
    [self reloadAllCarousels];
    NSMutableData * data = [[KumulosData dictionaryToData:allStix] retain];
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
    [data autorelease]; // MRC
}

-(void)adminResetAllStixOrders {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
//    KumulosHelper * kh = [[KumulosHelper alloc] init];
//    [kh setFunction:@"adminUpdateAllStixOrders"];
    //[kh setFunction:@"adminUpdateAllFriendsLists"];
//    [kh execute];
    [[KumulosHelper sharedKumulosHelper] execute:@"adminUpdateAllStixOrders"];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserStixDidCompleteWithResult:(NSArray *)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [[CarouselView sharedCarouselView] reloadAllStix];
}

-(void)didPressAdminEasterEgg:(NSString *)view {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([[self getUsername] isEqualToString:@"bobo"] || [password isEqualToString:@"admin"]) {
//        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Ye ol' Admin Menu" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reset All Users' Stix", @"Get me one of each", "Set all Users' bux", nil];
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Test" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reset All Users Stix (disabled)", @"Get me one of each (disabled)", @"Set my stix to unlimited (disabled)", @"Increment all Users' Bux by 5", @"Reset all stix orders (disabled)", nil];
        [actionSheet setTag:ACTIONSHEET_TAG_ADMIN];
        [actionSheet showFromTabBar:tabBarController.tabBar ];
        [actionSheet release];
    }
    else
        [self showAlertWithTitle:@"Wrong Password!" andMessage:@"You cannot access the super secret club." andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
}

-(void)didClickPurchaseBuxButton {
    NSString * metricName = @"MoreBuxMenuPressed";
    NSString * metricData = [NSString stringWithFormat:@"User: %@ UID: %@", [self getUsername], uniqueDeviceID];
    [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:0];
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Buy more Bux" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"5 Bux for $0.99", @"15 Bux for $2.99", @"40 Bux for $4.99", @"80 Bux for $8.99", @"170 Bux for $19.99", @"475 Bux for $49.99", nil];
    actionSheet.tag = ACTIONSHEET_TAG_BUYBUX;
    [actionSheet showFromTabBar:tabBarController.tabBar];
    [actionSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (actionSheet.tag == ACTIONSHEET_TAG_ADMIN) {
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
                NSLog(@"button 3 increment all user bux by 5");
                //[self adminSetAllUsersBuxCounts];
                [self adminIncrementAllUsersBuxCounts];
                break;
            case 4:
                NSLog(@"button 5: Reset all stix orders");
                //[self adminResetAllStixOrders];
                break;
            default:
                return;
                break;
        }        
    }
    else if (actionSheet.tag == ACTIONSHEET_TAG_SHAREPIX) {
        // button index: 0 = "Facebook", 1 = "Email", 2 = "Cancel"
        switch (buttonIndex) {
            case 0: // Facebook
            {
                /*
                UIAlertView* alert = [[UIAlertView alloc]init];
                [alert addButtonWithTitle:@"Ok"];
                [alert setTitle:@"Beta Version"];
                [alert setMessage:@"Uploading Pix via Facebook coming soon!"];
                [alert show];
                [alert release];
                 */
                Tag * tag = nil;
                for (int i=0; i<[allTags count]; i++) {
                    Tag * t = [allTags objectAtIndex:i];
                    if ([t.tagID intValue] == shareActionSheetTagID) {
                        tag = t;
                        break;
                    }
                }
                if (tag == nil) {
                    NSLog(@"Error in sharing pix! Tag doesn't exist!");
                    return;
                }
                UIImage * result = [tag tagToUIImage];
                NSData *png = UIImagePNGRepresentation(result);
                
                UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil); // write to photo album
                
                [self uploadImage:png withShareMethod:buttonIndex];
                
                NSString * metricName = @"SharePixActionsheet";
                NSString * metricData = [NSString stringWithFormat:@"User: %@ Method: Facebook", [self getUsername]];
                [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:0];
            }
                break;
            case 1: // Email
            {
                Tag * tag = nil;
                for (int i=0; i<[allTags count]; i++) {
                    Tag * t = [allTags objectAtIndex:i];
                    if ([t.tagID intValue] == shareActionSheetTagID) {
                        tag = t;
                        break;
                    }
                }
                if (tag == nil) {
                    NSLog(@"Error in sharing pix! Tag doesn't exist!");
                    return;
                }
                UIImage * result = [tag tagToUIImage];
                NSData *png = UIImagePNGRepresentation(result);
                
                UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil); // write to photo album
                
                [self uploadImage:png withShareMethod:buttonIndex];
                
                NSString * metricName = @"SharePixActionsheet";
                NSString * metricData = [NSString stringWithFormat:@"User: %@ Method: Email", [self getUsername]];
                [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:0];
            }
                break;
            case 2: // Cancel
                return;
                break;
            default:
                return;
                break;
        }
    }
    else if (actionSheet.tag == ACTIONSHEET_TAG_BUYBUX) {
        // button index: 
        // 0 @"5 Bux for $0.99"
        // 1 @"15 Bux for $2.99"
        // 2 @"40 Bux for $4.99"
        // 3 @"80 Bux for $8.99"
        // 4 @"170 Bux for $19.99"
        // 5 @"475 Bux for $49.99"
        // 6 cancel
        int values[6] = {5,15,40,80,170,475};
        if (buttonIndex != [actionSheet cancelButtonIndex]) {
            buyBuxPurchaseAmount = values[buttonIndex];
            NSString * title = @"Bux Purchase";
            NSString * message = [NSString stringWithFormat:@"Are you sure you want to purchase %d Bux?", buyBuxPurchaseAmount];
            /*
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Make Purchase", nil];
            [alert show];
            [alert release];
             */
            [self showAlertWithTitle:title andMessage:message andButton:@"Cancel" andOtherButton:@"Make Purchase" andAlertType:ALERTVIEW_BUYBUX];
        }
    }
}

-(void) adminSetAllUsersBuxCounts {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [k adminSetAllUserBuxWithBux:25];
}

-(void) adminIncrementAllUsersBuxCounts {
    int buxIncrement = 5;
    [k adminIncrementAllUserBuxWithBux:buxIncrement];
    
    [self Parse_sendBadgedNotification:[NSString stringWithFormat:@"Your Bux have been incremented by %d", buxIncrement] OfType:NB_INCREMENTBUX toChannel:@"" withTag:nil orGiftStix:nil];
}

-(void)decrementStixCount:(NSString *)stixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    int count = [[allStix objectForKey:stixStringID] intValue];
    if (count > 0) {
        count--;
        [allStix setObject:[NSNumber numberWithInt:count] forKey:stixStringID];
        
        for (int i=0; i<[allCarouselViews count]; i++) {
            [[allCarouselViews objectAtIndex:i] reloadAllStix];
        }
    }
    [self reloadAllCarousels];
    NSMutableData * data = [[KumulosData dictionaryToData:allStix] retain];
    
    // todo: when giftstx are used, we must check to sync with kumulos
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
    [data release];
    
}

-(void)incrementStixCount:(NSString *)stixStringID{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self incrementStixCount:stixStringID byNumber:1];
}

-(void)incrementStixCount:(NSString *)stixStringID byNumber:(int)increment{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    int count = [[allStix objectForKey:stixStringID] intValue];
    if (![stixStringID isEqualToString:@"FIRE"] && ![stixStringID isEqualToString:@"ICE"]) {
        count+=increment;
        [allStix setObject:[NSNumber numberWithInt:count] forKey:stixStringID]; 
        
        for (int i=0; i<[allCarouselViews count]; i++) {
            [[allCarouselViews objectAtIndex:i] reloadAllStix];
        }
    }
    [self reloadAllCarousels];
    NSMutableData * data = [[KumulosData dictionaryToData:allStix] retain];
    [k addStixToUserWithUsername:myUserInfo->username andStix:data];
    [data release];
}

-(Tag*) getTagWithID:(int)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    for (int i=0; i<[allTags count]; i++) {
        Tag * t = [allTags objectAtIndex:i];
        if ([[t tagID] intValue] == tagID)
            return [allTags objectAtIndex:i];
    }
    return nil;
}

/***** Parse Notifications ****/
-(void) Parse_unsubscribeFromAll {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif
    //NSError * error;
    //NSSet * channels = [PFPush getSubscribedChannels:&error];
   [PFPush getSubscribedChannelsInBackgroundWithBlock:^(NSSet *channels, NSError *error) {
        NSEnumerator * e = [channels objectEnumerator];
        id element;
        NSMutableString * channelsString = [[NSMutableString alloc] initWithString:@"Parse: unsubscribing this device from: "];
        while (element = [e nextObject]) {
            [channelsString appendString:element];
            [channelsString appendString:@" "];
            [PFPush unsubscribeFromChannelInBackground:element];
        }
        NSLog(@"%@", channelsString);
    }]; // perform in background
}
-(void) Parse_subscribeToChannel:(NSString*) channel {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSString * channel_ = [channel stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSLog(@"Parse: subscribing to channel <%@>", channel_);
    [PFPush subscribeToChannelInBackground:channel_ block:^(BOOL succeeded, NSError *error) {
        if (succeeded) 
            NSLog(@"Subscribed to channel <%@>", channel_);
        else
            NSLog(@"Could not subscribe to <%@>: error %@", channel_, [error localizedDescription]);
    }];
}

-(void) Parse_sendBadgedNotification:(NSString*)message OfType:(int)type toChannel:(NSString*) channel withTag:(NSNumber*)tagID orGiftStix:(NSString*)giftStixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (type == NB_NEWGIFT || type == NB_NEWCOMMENT || type == NB_NEWSTIX || type == NB_INCREMENTBUX)
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

- (void)application:(UIApplication *)application 
didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if 0
    [PFPush handlePush:userInfo];
#else
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // debug - display userInfo
    NSLog(@"%@", userInfo);
    //NSDictionary * aps = [userInfo objectForKey:@"aps"]; 
    notificationBookmarkType = [[userInfo objectForKey:@"notificationBookmarkType"] intValue];
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
        }
            break;
            
        case NB_INCREMENTBUX: 
        {
            notificationTagID = -1;
            notificationGiftStixStringID = nil;
            doAlert = NO; // do not show general alert - go to bookmark jump
        }
            break;
            
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
        [self handleNotificationBookmarks:YES withMessage:message];
    }
#endif
}

-(void)handleNotificationBookmarks:(bool)doJump withMessage:(NSString*)message{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // message is only used for NB_GENERAL - if coming from offline
    if (notificationTagID == -1) {
        // gift stix only - no need to jump to or update feed
        if (notificationBookmarkType == NB_INCREMENTBUX) {
            // only display message
            [self showAlertWithTitle:@"Stix Notification" andMessage:message andButton:@"Close" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
            [self updateBuxCountFromKumulos];
        }
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
   NSLog(@"Button index: %d", buttonIndex);    
    // 0 = close
    // 1 = view
    
    isShowingAlerts = NO;
    if (alertActionCurrent == ALERTVIEW_NOTIFICATION) {
        if (buttonIndex == 0) {
            [self handleNotificationBookmarks:NO withMessage:nil];
        }
        if (buttonIndex == 1) {
            [self handleNotificationBookmarks:YES withMessage:nil];
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
        }
    }
    else if (alertActionCurrent == ALERTVIEW_BUYBUX) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [self didPurchaseBux:buyBuxPurchaseAmount];
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

-(void)updateBuxCountFromKumulos {
    [k getBuxForUserWithUsername:[self getUsername]];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getBuxForUserDidCompleteWithResult:(NSArray *)theResults {
    if ([theResults count] == 0)
        return;
    NSMutableDictionary * d = [theResults objectAtIndex:0];
    int bux = [[d valueForKey:@"bux"] intValue];
    myUserInfo->bux = bux;
    [self updateBuxCount];
}

-(void)updateBuxCount {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // display bux on feed?
    [[feedController labelBuxCount] setText:[NSString stringWithFormat:@"%d", myUserInfo->bux]];
    [[exploreController labelBuxCount] setText:[NSString stringWithFormat:@"%d", myUserInfo->bux]];
}

-(void)didPurchaseStixFromCarousel:(NSString *)stixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self didGetStixFromStore:stixStringID];
    [tabBarController doPurchaseAnimation:stixStringID]; 
}

/**** StoreView delegate ****/
-(void)didGetStixFromStore:(NSString *)stixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
            NSLog(@"Stix: %@ order %d", [BadgeView getStixDescriptorForStixStringID:key], order); 
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
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self showAlertWithTitle:@"No More Bux" 
                  andMessage:@"You can't get any more stickers without any Bux!" 
                   andButton:@"OK"
//               andOtherButton:@"View" 
//                andAlertType:ALERTVIEW_GOTOSTORE];
              andOtherButton:nil
                andAlertType:ALERTVIEW_SIMPLE];
}

-(void)didPurchaseBux:(int)buxPurchased {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self showAlertWithTitle:@"Thank you!" andMessage:[NSString stringWithFormat:@"You have received %d Bux. Have fun buying stickers!", buxPurchased] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    [self changeBuxCountByAmount:buxPurchased];
    if  (buxPurchased == 25) {
        NSString * metricName = @"ExpressBux";
        NSString * metricData = [NSString stringWithFormat:@"User: %@ UID: %@", [self getUsername], uniqueDeviceID];
        [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:buxPurchased];
    }
    else { 
        NSString * metricName = @"MoreBux";
        NSString * metricData = [NSString stringWithFormat:@"User: %@ UID: %@", [self getUsername], uniqueDeviceID];
        [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:buxPurchased];
    }
}

/*** ASIhttp request delegate functions ***/
- (void) requestFinished:(ASIHTTPRequest *)request {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Response %d : %@", request.responseStatusCode, [request responseString]);
    // the response is an HTML file of the redirect to the image page
    // in this image page there is a meta tag: <meta shared_id='<ID>'>
    // also the webURL: <meta web_url='/users/<USERNAME>/pictures/<ID>'>
    
    NSString * responseString = [request responseString];
    NSRange range0 = [responseString rangeOfString:@"<meta web_url"];
    NSRange range1 = [responseString rangeOfString:@"<meta shared_id"];
    range0.location = range0.location + 15;
    range0.length = range1.location - range0.location-3; // this could change based on how we output web
    NSString * substring = [responseString substringWithRange:range0];
    NSLog(@"substring for weburl: <%@>", substring);
    
    NSRange imgRange = [responseString rangeOfString:@"http://s3.amazonaws.com"];
    imgRange.length = 60;
    NSString * imgSubstring = [responseString substringWithRange:imgRange];
    NSRange imgRangeEnd = [imgSubstring rangeOfString:@"\" />"];
    imgRange.length = imgRangeEnd.location;
    imgSubstring = [responseString substringWithRange:imgRange];

    NSString * weburl = [NSString stringWithFormat:@"http://%@%@", HOSTNAME,substring];
    [self didSharePixWithURL:weburl andImageURL:imgSubstring];
}

- (void) requestStarted:(ASIHTTPRequest *) request {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"request started...");
}

- (void) requestFailed:(ASIHTTPRequest *) request {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSError *error = [request error];
    NSLog(@"%@", error);
}

@end
