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
#import "FileHelpers.h"
//#import "Kiip.h"
#import "QuartzCore/QuartzCore.h"
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>

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
@synthesize profileController, userProfileController;
//@synthesize friendController;
@synthesize loginSplashController;
@synthesize friendSuggestionController;
@synthesize myUserInfo;
@synthesize lastViewController;
@synthesize allTags, allTagIDs;
@synthesize timeStampOfMostRecentTag;
@synthesize allUsers;
@synthesize allUserPhotos;
@synthesize allUserFacebookIDs, allUserEmails, allUserNames, allUserIDs;
@synthesize allStix;
@synthesize allStixOrder;
@synthesize allFollowers, allFollowing;
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
static dispatch_queue_t backgroundQueue;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    versionStringStable = @"1.0";
    versionStringBeta = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]; //@"0.7.7.4";
    
    metricLogonTime = nil;
    backgroundQueue = dispatch_queue_create("com.Neroh.Stix.stixApp.bgQueue", NULL);

    // call the Appirater class
    [Appirater appLaunched];

    /* Flurry Analytics */
    [FlurryAnalytics startSession:@"LKU9KSMBPR1GYZBCHQHV"];
    //[FlurryAnalytics setDebugLogEnabled:YES];
    
    /*** Kumulos service ***/
    
    k = [[Kumulos alloc]init];
    [k setDelegate:self];
    [self setLastKumulosErrorTimestamp: [NSDate dateWithTimeIntervalSinceReferenceDate:0]];
        
    /*** MKStoreKit ***/
    [MKStoreManager sharedManager];
#if 0
    /*** doing store kit stuff manually ***/
    NSSet * productIDs = [[NSSet alloc] initWithObjects:@"collection.Hipster", nil];
    SKProductsRequest * productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDs];
    [productRequest setDelegate:self];
    [productRequest start];
#endif
    notificationDeviceToken = nil;
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];    

    aggregator = [[UserTagAggregator alloc] init];
    [aggregator setDelegate:self];
    
    didGetFollowingLists = NO;

    /*** device id on pasteboard ***/
	UIPasteboard *appPasteBoard = [UIPasteboard pasteboardWithName:@"StixAppPasteboard" create:YES];
	appPasteBoard.persistent = YES;
	uniqueDeviceID = [appPasteBoard string];    
    if (uniqueDeviceID == nil) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        uniqueDeviceID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL,uuidRef);
        CFRelease(uuidRef);
        [appPasteBoard setString:uniqueDeviceID];
        NSLog(@"Unique device created and set to pasteboard: %@", uniqueDeviceID);
    }
    else {
        NSLog(@"Unique device retrieved from pasteboard: %@", uniqueDeviceID);
    }
#if !USING_FLURRY
    NSString * description = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
    NSString * string = @"Application started";
    [k addMetricWithDescription:description andUsername:@"" andStringValue:string andIntegerValue:0];
#endif
    // Override point for customization after application launch
    [loadingMessage setText:@"Connecting to Stix Server..."];
    
    [window makeKeyAndVisible];
    /*
    //dispatch_async(backgroundQueue, ^{
        [self continueInit];
    //});
    return YES;
}

-(BOOL)continueInit {
     */

    /* Crashlytics */
    [Crashlytics startWithAPIKey:@"747b4305662b69b595ac36f88f9c2abe54885ba3"];
    
    myUserInfo = malloc(sizeof(struct UserInfo));
    myUserInfo_username = nil;
    myUserInfo_userphoto = nil;
    myUserInfo->bux = 0;
    myUserInfo->usertagtotal = 0;
    myUserInfo_email = nil;
    myUserInfo->facebookID = 0;
    myUserInfo->firstTimeUserStage = FIRSTTIME_MESSAGE_01;
    didStartFirstTimeMessage = NO;
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
    fbHelper = [FacebookHelper sharedFacebookHelper]; //[[FacebookHelper alloc] init];
    [fbHelper setDelegate:self];
    [fbHelper initFacebook];
    
	/***** create first view controller: the TagViewController *****/
    [loadingMessage setText:@"Initializing camera..."];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    dispatch_async(backgroundQueue, ^{
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
//    });

    /* load stix types, stix views, user info, and check for version */
    
    [self checkVersion];
    
    dispatch_async(backgroundQueue, ^{
        [BadgeView InitializeDefaultStixTypes];
        [BadgeView InitializePremiumStixTypes];
        stixViewsLoadedFromDisk = [self loadStixDataFromDefaults];
    });
    /*
    if (!stixViewsLoadedFromDisk) {
        dispatch_async(dispatch_queue_create("com.Neroh.Stix.stixApp.bgQueue", NULL), ^(void) {
        [self saveStixDataToDefaults];
        });
    }
     */
    
	tabBarController = [[RaisedCenterTabBarController alloc] init];
    tabBarController.myDelegate = self;
    
#if USING_FLURRY
    [FlurryAnalytics logAllPageViews:tabBarController];
#endif
    
    allTags = [[NSMutableArray alloc] init];
    allTagIDs = [[NSMutableDictionary alloc] init];
    allUsers = [[NSMutableDictionary alloc] init];
    allUserPhotos = [[NSMutableDictionary alloc] init];
    allStix = [[NSMutableDictionary alloc] init];
    allStixOrder = [[NSMutableDictionary alloc] init];
    //allFriends = [[NSMutableSet alloc] init];
    allFollowing = [[NSMutableSet alloc] init];
    allFollowers = [[NSMutableSet alloc] init];
    allUserFacebookIDs = [[NSMutableArray alloc] init];
    allUserIDs = [[NSMutableDictionary alloc] init];
    allUserEmails = [[NSMutableArray alloc] init];
    allUserNames = [[NSMutableArray alloc] init];
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
    idOfMostRecentUser = -1;
    pageOfLastNewerTagsRequest = -1;
    pageOfLastOlderTagsRequest = -1;
    // don't get tags until login completes, and first time aggregation is triggered
    // or, download all tags and when first time aggregation is triggered, filter by followingList
    //[self getNewerTagsThanID:idOfNewestTagReceived];
    
	/***** create feed view *****/
    //[loadingMessage setText:@"Loading feed..."];
    
	//feedController = [[FeedViewController alloc] init];
    feedController = [[VerticalFeedController alloc] init];
    [feedController setDelegate:self];
    feedController.allTags = allTags;
    feedController.tabBarController = tabBarController;
    feedController.camera = camera; // hack: in order to present modal controllers that respond 

    // get newest tag on server regardless of who is logged in
    // when login completes, feed will filter 
#if 0
    [self getFirstTags];
#else
    // show activity indicator
    [feedController startActivityIndicatorLarge];
#endif
    
    /***** create explore view *****/
    exploreController = [[ExploreViewController alloc] init];
    exploreController.delegate = self;
	
	/***** create friends feed *****/
    //[loadingMessage setText:@"Networking with friends..."];
	//friendController = [[FriendsViewController alloc] init];
    //friendController.delegate = self;
    [self checkForUpdatePhotos];
    
	/***** create profile view *****/
	profileController = [[ProfileViewController alloc] init];
    profileController.delegate = self;
    userProfileController = [[UserProfileViewController alloc] init];
    userProfileController.delegate = self;
    
    /***** add view controllers to tab controller, and add tab to window *****/
    emptyViewController = [[UIViewController alloc] init];
    //UITabBarItem *tbi = [emptyViewController tabBarItem];
	//UIImage * i = [UIImage imageNamed:@"tab_camera.png"];
	//[tbi setImage:i];
    //[tbi setTitle:@"Stix"];
	NSArray * viewControllers = [NSArray arrayWithObjects: feedController, emptyViewController, exploreController, nil];
    [tabBarController setViewControllers:viewControllers];
	[tabBarController setDelegate:self];
    [exploreController setTabBarController:tabBarController];
    
    friendSuggestionController = [[FriendSuggestionController alloc] init];
    [friendSuggestionController setDelegate:self];
    
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
    
    [self loadCachedTags];
    
    // Login process - first load cached user info from defaults
    loggedIn = [self loadUserInfoFromDefaults];
    isLoggingIn = NO;
    loginSplashController = [[FacebookLoginController alloc] init];
    [loginSplashController setDelegate:self];
    if (![fbHelper facebookHasSession] || !loggedIn) // !myUserInfo_username || [myUserInfo_username length] == 0)
    {
        NSLog(@"Could not log in: forcing new login screen!");
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
        NSLog(@"Loggin in as %@", myUserInfo_username);
        //[loadingMessage setText:[NSString stringWithFormat:@"Logging in as %@...", username]];
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
          //                                       (unsigned long)NULL), ^(void) {
        //[profileController loginWithUsername:myUserInfo_username];
        //});
        
        // preemptively do user login things
        [self didLoginWithUsername:myUserInfo_username andPhoto:myUserInfo_userphoto andEmail:myUserInfo_email andFacebookID:[NSNumber numberWithInteger:myUserInfo->facebookID] andUserID:[NSNumber numberWithInteger:myUserInfo->userID] andStix:nil andTotalTags:myUserInfo->usertagtotal andBuxCount:myUserInfo->bux andStixOrder:nil];
                
        [self getFollowListsForAggregation:[self getUsername]];
        didGetFollowingLists = YES;
        [self doFacebookLogin];
    }   
	
    /* display versioning info */
    if (versionIsOutdated)
    {
        [self showAlertWithTitle:@"Update Available" andMessage:[NSString stringWithFormat:@"This version of Stix (v%@) is out of date. Version %@ is available through TestFlight.", versionStringStable, currVersion] andButton:@"Close" andOtherButton:@"View" andAlertType:ALERTVIEW_UPGRADE];
    }

    /*** twitter ***/
    /*
    twitterHelper = [TwitterHelper sharedTwitterHelper];
    [twitterHelper initTwitter];
//    [self showTwitterDialog];
    [twitterHelper requestTwitterPostPermission];
    */
    
    // sharekit test
    /*
    if (shareController == nil) {
        shareController = [[ShareController alloc] init];
        [shareController setDelegate:self];
    }
    [self.window addSubview:shareController.view];
    [shareController doShareKit];
     */
    return YES;
}
/*
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Received products response!");
    for (int i=0; i<[response.products count]; i++) {
        SKProduct * product = [response.products objectAtIndex:i];
        NSLog(@"Product %d: %@", i, product.description);
    }
    for (int i=0; i<[response.invalidProductIdentifiers count]; i++) {
        NSString * invalidProductID = [response.invalidProductIdentifiers objectAtIndex:i];
        NSLog(@"Invalid product %d: %@", i, invalidProductID);
    }
}
*/
-(void)getFirstTags {
    [k getLastTagIDWithNumEls:[NSNumber numberWithInt:3]];
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
    NSLog(@"Storing parse device token");
    [PFPush storeDeviceToken:newDeviceToken];
    // Subscribe to the global broadcast channel.

    //[self Parse_unsubscribeFromAll];
    // register for notifications on update channel
    
    notificationDeviceToken = newDeviceToken;
    
    //if ([self isLoggedIn]) {
    //    [self Parse_createSubscriptions];
    //}
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
    NSString * email = @"";
    int facebookID = 0;
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

-(void)needFacebookLogin {
    NSLog(@"Need facebook login");
    [self doFacebookLogin];
}

-(void)doFacebookLogin {
    NSLog(@"Do facebook login");
    int ret = [fbHelper facebookLogin];

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
}

-(void)didCancelFacebookLogin {
    [loginSplashController stopActivityIndicator];
    [[loginSplashController loginButton] setHidden:NO];
}

-(void)initializeBadgesFromKumulos {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    //[BadgeView InitializeGenericStixTypes];
    //[self showAlertWithTitle:@"Initializing badges" andMessage:@"We are checking for new badges. Please be patient" andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];

    // load all stix types from Kumulos - doesn't take much
    [k getAllStixTypes];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getStixDataByStixStringIDDidCompleteWithResult:(NSArray *)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([theResults count] == 0)
        NSLog(@"Could not find a stix data! May be missing in Kumulos.");
    else {
        NSMutableDictionary * d = [theResults objectAtIndex:0]; 
        NSString * descriptor = [d valueForKey:@"stixDescriptor"];
        NSLog(@"getStixData completed for stix string: %@", descriptor); 
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                                 (unsigned long)NULL), ^(void) {
        [BadgeView AddStixView:theResults];
        });
    }
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllStixTypesDidCompleteWithResult:(NSArray *)theResults {     
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // initialize stix types for all badge views
    [BadgeView InitializeStixTypes:theResults];
    [self saveStixTypesToDefaults];
    //[feedController configureCarouselView]; // force start of download of first stix in carouselview
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        [feedController.carouselView reloadAllStix];
    });
    NSLog(@"***** InitializeBadges Done: All %d Stix types initialized from kumulos! *****", [BadgeView totalStixTypes]);
    //init++;
    if (0) //(stixViewsLoadedFromDisk)
    {
        // consolidate all stix types with stix views and load any stixViews that weren't loaded
        NSMutableDictionary * stixViews = [BadgeView GetAllStixViewsForSave];
        NSLog(@"%d views loaded from disk; %d types loaded from Kumulos", [stixViews count], [theResults count]);
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
        //                                         (unsigned long)NULL), ^(void) {
            int newStixCount = 0;
            for (int i=0; i<[BadgeView totalStixTypes]; i++) {
                NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
                UIImageView * stixView = [stixViews objectForKey:stixStringID];
                
                if (stixView == nil) {
                    [k getStixDataByStixStringIDWithStixStringID:stixStringID];
                    newStixCount++;
                }
            }
            NSLog(@"Loading %d new stixViews in background...", newStixCount);
        //});
    }
    else {
        //NSLog(@"InitializeBadges starting to download stix views");
        //[k getAllStixViews];
    }

    /*
    if (init >= 2) {
        //[self continueInit];
        [self reloadAllCarousels];
    }
    else {
        NSLog(@"getAllStixTypes still waiting for init=2");
    }
     */
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllStixViewsDidCompleteWithResult:(NSArray *)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [BadgeView InitializeStixViews:theResults];
    NSLog(@"***** InitializeBadges done: All %d Stix data initialized from kumulos! *****", [theResults count]);
        //[self continueInit];
}

-(void)saveUserInfoToDefaults {
    // Store the data
    NSLog(@"Saving data to user defaults");
    if (isLoggingIn)
        return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:versionStringStable forKey:@"stixVersion"];
    [defaults setObject:myUserInfo_username forKey:@"username"];
    [defaults setObject:myUserInfo_email forKey:@"email"];
    [defaults setInteger:myUserInfo->facebookID forKey:@"facebookID"];
    [defaults setInteger:myUserInfo->usertagtotal forKey:@"usertagtotal"];
    [defaults setInteger:myUserInfo->bux forKey:@"bux"];
    [defaults setInteger:myUserInfo->userID forKey:@"userID"];
    NSLog(@"SaveUserInfo: userID %d name %@ facebookID %d", myUserInfo->userID, myUserInfo_username, myUserInfo->facebookID);
    NSData *userphoto = UIImageJPEGRepresentation(myUserInfo_userphoto, 100);
    [defaults setObject:userphoto forKey:@"userphoto"];
    [defaults setInteger:myUserInfo->firstTimeUserStage forKey:@"firstTimeUserStage"];
    
    // sharing
    [defaults setBool:[shareController shareServiceIsConnected:@"Facebook"] forKey:@"FacebookIsConnected"];
    [defaults setBool:[shareController shareServiceIsSharing:@"Facebook"] forKey:@"FacebookIsSharing"];
    [defaults setBool:[shareController shareServiceIsConnected:@"Twitter"] forKey:@"TwitterIsConnected"];
    [defaults setBool:[shareController shareServiceIsSharing:@"Twitter"] forKey:@"TwitterIsSharing"];
    
    // allStix and stixorder
    NSData * allStixData = [NSKeyedArchiver archivedDataWithRootObject:allStix];
    NSData * allStixOrderData = [NSKeyedArchiver archivedDataWithRootObject:allStixOrder];
    [defaults setObject:allStixData forKey:@"allStix"];
    [defaults setObject:allStixOrderData forKey:@"allStixOrder"];

    [defaults synchronize];
}

-(void)saveStixTypesToDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray * stixStringIDs = [BadgeView GetAllStixStringIDsForSave];
    NSMutableDictionary * stixCategories = [BadgeView GetAllStixCategoriesForSave];

    [defaults setObject:stixCategories forKey:@"stixCategories"];
    [defaults setObject:stixStringIDs forKey:@"stixStringIDs"];
    NSLog(@"Saved %d stixStringIDs", [stixStringIDs count]);
    
    [defaults synchronize];
}

-(void)saveStixDataToDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:versionStringBeta forKey:@"stixDataVersion"];
    
    NSMutableArray * stixStringIDs = [BadgeView GetAllStixStringIDsForSave];
    NSMutableDictionary * stixDescriptors = [BadgeView GetAllStixDescriptorsForSave];   
    NSMutableDictionary * stixCategories = [BadgeView GetAllStixCategoriesForSave];
    [defaults setObject:stixDescriptors forKey:@"stixDescriptors"];
    [defaults setObject:stixCategories forKey:@"stixCategories"];
    //NSMutableDictionary * stixViews = [BadgeView GetAllStixViewsForSave];
    [defaults setObject:stixStringIDs forKey:@"stixStringIDs"];
    NSLog(@"Saved %d stixStringIDs", [stixStringIDs count]);
    int total=0;
    for (NSString * stixStringID in stixStringIDs) {
        total += [self saveStixDataToDefaultsForStixStringID:stixStringID];
    }
    NSLog(@"Saved %d stixViews", total);
    
    [defaults synchronize];
}

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID {
    [self saveStixDataToDefaultsForStixStringID:stixStringID];
}

-(int)saveStixDataToDefaultsForStixStringID:(NSString*)stixStringID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    UIImageView * stixView = [[BadgeView GetAllStixViewsForSave] objectForKey:stixStringID];
    NSString * stixDescriptor = [[BadgeView GetAllStixDescriptorsForSave] objectForKey:stixStringID];   
    if (!stixView)
        return 0;
    NSData * stixPhoto = UIImagePNGRepresentation([stixView image]);
        [defaults setObject:stixPhoto forKey:stixStringID];
    NSLog(@"Saving stix data to disk for %@", stixDescriptor);
    // defaults synchronize will happen periodically
    return 1;
}


-(void)saveCachedTags {
    // archive most recent tags for faster loading
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * cacheTags = [[NSMutableArray alloc] init];
    if ([allTags count] == 0)
        return;
    int ct = MIN(20, [allTags count]);
    for (int i=0; i<ct; i++) {
        [cacheTags addObject:[allTags objectAtIndex:i]];
    }
    
    NSData * cacheData = [NSKeyedArchiver archivedDataWithRootObject:cacheTags];
    [defaults setObject:cacheData forKey:@"cachedTags"];
    [defaults synchronize];
    
    NSLog(@"Cached %d tags", ct);
}

-(void)loadCachedTags {
    
    // load cached tags
    // archive most recent tags for faster loading
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData * cacheData = [defaults objectForKey:@"cachedTags"];
    if (!cacheData)
        return;
    NSMutableArray * cacheTags = [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
    // don't add to allTags - force a getTagWithID call
//    for (int i=0; i<[cacheTags count]; i++) {
//        [allTags addObject:[cacheTags objectAtIndex:i]];
//    }
    NSLog(@"Loaded %d cached tags with ids:", [cacheTags count]);
    for (int i=0; i<[cacheTags count]; i++) {
        Tag * tag = [cacheTags objectAtIndex:i];
        [allTagIDs setObject:tag forKey:tag.tagID];
        NSLog(@"%d", [tag.tagID intValue]);
    }
     
}

-(int)loadUserInfoFromDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString * versionString = [defaults objectForKey:@"stixVersion"];
    if (!versionString || [versionString compare:@"0.9"] == NSOrderedAscending) {
        NSLog(@"LoadUserFromDefaults: no version");
        return 0;
    }
    
    // if there's a version string > 0.9, then we must have also saved username sometime
    myUserInfo_username = [defaults objectForKey:@"username"];
    if (myUserInfo_username == nil)
        return 0;
    myUserInfo_email = [defaults objectForKey:@"email"];
    myUserInfo->facebookID = [defaults integerForKey:@"facebookID"];
    myUserInfo->usertagtotal = [defaults integerForKey:@"usertagtotal"];
    myUserInfo->bux = [defaults integerForKey:@"bux"];
    myUserInfo->userID = [defaults integerForKey:@"userID"];
    NSData * userphoto = [defaults objectForKey:@"userphoto"];
    myUserInfo_userphoto = [UIImage imageWithData:userphoto];
    myUserInfo->firstTimeUserStage = [defaults integerForKey:@"firstTimeUserStage"];
    
    // load previous followers
    NSData * followingData = [defaults objectForKey:@"allFollowing"];
    if (followingData)
        [allFollowing unionSet:[NSKeyedUnarchiver unarchiveObjectWithData:followingData]];
    NSData * followerData = [defaults objectForKey:@"allFollowers"];
    if (followerData)
        [allFollowers unionSet:[NSKeyedUnarchiver unarchiveObjectWithData:followerData]];
    NSLog(@"LoadUserInfo: following %d people, has %d followers", [allFollowing count], [allFollowers count]);
    
    // stix
    NSData * allStixData = [defaults objectForKey:@"allStix"];
    NSData * allStixOrderData = [defaults objectForKey:@"allStixData"];
    //[allStix removeAllObjects];
    //[allStixOrder removeAllObjects];
    [allStix addEntriesFromDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:allStixData]];
    [allStixOrder addEntriesFromDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:allStixOrderData]]; 
                   
    [profileController didLogin]; 
    
    [feedController.buttonProfile setImage:myUserInfo_userphoto forState:UIControlStateNormal];
    [feedController.buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [feedController.buttonProfile.layer setBorderWidth:1];

    return 1;
}
-(int)loadStixDataFromDefaults {
    NSLog(@"Trying to LoadStixDataFromDefaults");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString * versionString = [defaults objectForKey:@"stixVersion"];
    if (!versionString || [versionString compare:@"0.9"] == NSOrderedAscending) {
        
        return 0;
    }
    @try {
        
        // beta v0.9.6 is where on disk stix exist
        NSString * stixDataVersionString = [defaults objectForKey:@"stixDataVersion"];
        if (!stixDataVersionString || [stixDataVersionString compare:@"0.9.6"] == NSOrderedAscending) {
            NSLog(@"LoadUserFromDefaults: old version");
            return 0;
        }
        
        NSMutableArray * stixStringIDs = [defaults objectForKey:@"stixStringIDs"];
        NSMutableDictionary * stixDescriptors = [defaults objectForKey:@"stixDescriptors"];
        NSMutableDictionary * stixCategories = [defaults objectForKey:@"stixCategories"];
        NSMutableDictionary * stixViews = [[NSMutableDictionary alloc] init];
        for (NSString * stixStringID in stixStringIDs) {
            NSData * stixPhoto = [defaults objectForKey:stixStringID];
            if (stixPhoto)
                [stixViews setObject:[[UIImageView alloc] initWithImage:[UIImage imageWithData:stixPhoto]] forKey:stixStringID];
        }
        if (stixStringIDs != nil)
        {
            NSLog(@"Loading %d saved Stix from disk", [stixViews count]);
            [BadgeView InitializeFromDiskWithStixStringIDs:stixStringIDs andStixViews:stixViews andStixDescriptors:stixDescriptors andStixCategories:stixCategories];
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
    //NSLog(@"KumulosHelperDidCompleteWithCallback: params %@ size %d", params, [params count]);
    [self performSelector:callback withObject:params afterDelay:0];
}

// RaisedCenterTabBarController delegate 
-(void)didPressTabButton:(int)pos {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (isDisplayingShareSheet)
        return;
    if (isDisplayingBuxMenu)
        return;
    
    // when center button is pressed, programmatically send the tab bar that command
    [tabBarController setSelectedIndex:pos];
    [tabBarController setButtonStateSelected:pos]; // highlight button
#if !TARGET_IPHONE_SIMULATOR
    if (pos == TABBAR_BUTTON_TAG) {
        [self.camera setCameraOverlayView:tagViewController.view];
        
        if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_01) {
            [self hideFirstTimeUserMessage];
        }
    }
    else if (pos == TABBAR_BUTTON_FEED) {
        [exploreController didDismissZoom];
        lastViewController = feedController;
        // doing this will cause two arrows to be displayed
//        if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
//            [tabBarController toggleFirstTimePointer:YES atStage:FIRSTTIME_MESSAGE_02];
//        }
    }
    else if (pos == TABBAR_BUTTON_EXPLORE) {
        [feedController didCloseComments];
        lastViewController = exploreController;
        if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
            // force back to the feedview
            [tabBarController setSelectedIndex:TABBAR_BUTTON_FEED];
            [tabBarController setButtonStateSelected:TABBAR_BUTTON_FEED];
            [self agitateFirstTimePointer];
            return;
        }
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
        NSString * str = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
        [k addMetricWithDescription:description andUsername:[self getUsername] andStringValue:str andIntegerValue:-lastDiff];
        metricLogonTime = nil;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{	// Get full path of possession archive 
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  

#if !USING_FLURRY
    [self logMetricTimeInApp];
#else
    [FlurryAnalytics endTimedEvent:@"TimeInAppInSeconds" withParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username",nil]];
#endif
    [self saveCachedTags];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{	// Get full path of possession archive 
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    
#if !USING_FLURRY
    [self logMetricTimeInApp];
#else
    [FlurryAnalytics endTimedEvent:@"TimeInAppInSeconds" withParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username",nil]];
#endif
    [self saveCachedTags];
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
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        [self initializeBadges];
    });
     */
    
#if !USING_FLURRY
    [self setMetricLogonTime: [NSDate date]];
#else
    [FlurryAnalytics logEvent:@"TimeInApp" timed:YES];
#endif
    didGetFollowingLists = NO; // request update of following lists at some point
    
    [feedController updateFeedTimestamps];
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
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", [error description]);
    }
}

- (void)dealloc {
	
	//NEW COMMENT!
    free(myUserInfo);
}

/**** loading and adding of stix from kumulos ****/
-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    return [self addTagWithCheck:tag withID:newID overwrite:NO];
}

-(bool)addTagWithCheck:(Tag *) tag withID:(int)newID overwrite:(bool)bOverwrite {
    // also updates stix
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
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
            NSLog(@"Tag %d already exists at index %d: previous stix count %d current idOfNewestTagReceived %d idOfNewestTagOnServer %d", [currtag.tagID intValue], i, [currtag.auxStixStringIDs count], idOfNewestTagReceived, idOfNewestTagOnServer);
            [allTags replaceObjectAtIndex:i withObject:tag];
            // force update of replaced tag
            [feedController reloadPage:i];
            break;
        }
        else if (newID>tagID) // allTags should start at a high tagID (most recent) and go to a lower tagID (oldest)
        {
            // update IDs so we know this content has been received
            if (newID > idOfNewestTagReceived) {
                NSLog(@"Changing id of Newest Tag Received from %d to %d", idOfNewestTagReceived, newID);
                idOfNewestTagReceived = newID;
            }
            if (newID < idOfOldestTagReceived) {
                NSLog(@"Changing id of Oldest Tag Received from %d to %d", idOfOldestTagReceived, newID);
                idOfOldestTagReceived = newID;
            }

            // add into feed if it meets criteria
            [allTags insertObject:tag atIndex:i];
            [allTagIDs setObject:tag forKey:tag.tagID];
            [self getCommentCount:newID]; // store comment count for this tag
            // force update to feedController.allTags
            [feedController reloadPage:i];
            added = YES;
            break;
        }
    }
    if (!added && !alreadyExists)
    {
        if (newID > idOfNewestTagReceived)
            idOfNewestTagReceived = newID;
        if (newID < idOfOldestTagReceived)
            idOfOldestTagReceived = newID;
        if (1) { 
            [allTags insertObject:tag atIndex:i];
            [allTagIDs setObject:tag forKey:tag.tagID];
            [self getCommentCount:newID]; // store comment count for this tag
            // force update to feedController.allTags
            [feedController reloadPage:i];
            added = YES;
        }
        else 
            added = NO;
    }
    return added;
}

-(void)didCreateNewPix:(Tag *)newTag {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // when adding a tag, we add it to both our local tag structure, and to kumulos database

    [self didDismissSecondaryView];
    [tabBarController setSelectedIndex:0];
    [feedController configureCarouselView];
    [feedController.carouselView carouselTabDismiss:YES];
        
    // preemptively add to feed
    if (1)
    {
        //[feedController.scrollView populateScrollPagesAtPage:0]; // force update first page
        //[feedController.tableController populateScrollPagesAtPage:0];
        [feedController addTagForDisplay:newTag];
        [feedController didClickJumpButton:nil];
    }

    // this function migrates toward not using the basic stix
    newestTag = newTag;
    
    /*** automatic sharing and background uploading ***/
    /* New functionality: display the ShareController and allow user
     * to enter a caption and select automatic sharing options.
     * In the background, we should also perform uploading to stixmobile.com
     */
    // display share options controller and start upload
    [self doParallelNewPixShare:newTag];
    
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newTag, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"createNewPix" withParams:params withCallback:@selector(khCallback_didCreateNewPix:) withDelegate:self];

    NSString * loc = newTag.locationString;
    if ([loc length] > 0)
        [self rewardLocation];
    
    [Appirater userDidSignificantEvent:YES];
}
-(void)doParallelNewPixShare:(Tag*)_tag {
    NSLog(@"NewPixShare: resetting toggles for new created pix");
    newPixDidClickShare = NO;
    newPixDidFinishUpload = NO;
    [shareController startUploadImage:_tag withDelegate:self];
    [self displayShareController:_tag];
}

-(void)didReloadPendingPix:(Tag *)tag {
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:tag, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"createNewPix" withParams:params withCallback:@selector(khCallback_didCreateNewPix:) withDelegate:self];
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createNewPixDidCompleteWithResult:(NSNumber *)newRecordID {
-(void)khCallback_didCreateNewPix:(NSArray*)returnParams {
    // get that record and add to feed
    NSNumber * newRecordID = [returnParams objectAtIndex:0];
    [k getNewlyCreatedPixWithAllTagID:[newRecordID intValue]];
    
    // update aggregator
    [aggregator insertNewTagID:newRecordID];
    
    // send notification
    NSString * message = [NSString stringWithFormat:@"%@ added a new photo to remix.", myUserInfo_username];
    NSString * channel = [NSString stringWithFormat:@"From%@", [[self getUsername] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
    channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
    
    // DO NOT SEND newpix NOTIFICATIONS for now
    //[self Parse_sendNotificationToFollowers:message ofType:NB_NEWPIX withTag:newRecordID];
    
/*
    // this tagID is necessary for the shareController to work - if we have a comment
    [newestTag setTagID:newRecordID];
    [newestTag setTimestamp:[NSDate date]]; // set a temporary date because we are adding newestTag that does not have a kumulos timestamp
    [self displayShareController:newestTag];
 */
}

-(void)kumulosHelperCreateNewPixDidFail:(Tag *)failedTag {
    [feedController showReloadPendingPix:failedTag];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getNewlyCreatedPixDidCompleteWithResult:(NSArray *)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    
    NSMutableDictionary * d = [theResults objectAtIndex:0];
    Tag * newTag = [Tag getTagFromDictionary:d];
    NSNumber * newRecordID = newTag.tagID;
    NSNumber * pendingID = [d objectForKey:@"pendingID"];
    NSLog(@"New pix created: id %d pendingID %d", [newRecordID intValue], [pendingID intValue]);
    
    // touch tag to indicate it was updated
    // force timeUpdated to exist - if there's no stix this will be 0 otherwise
    [k touchPixToUpdateWithAllTagID:[newTag.tagID intValue]];

    // metrics
#if !USING_FLURRY
    NSString * metricName = @"CreatePix";
    [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:@"" andIntegerValue:[newRecordID intValue]];
#else
    [FlurryAnalytics logEvent:@"CreatePix" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", newRecordID, @"tagID", nil]];
#endif
    // save large image to large image database
    if (0) {
        UIImage * hiResImg = [[ImageCache sharedImageCache] imageForKey:@"largeImage"];
        NSData * largeImgData = UIImageJPEGRepresentation(hiResImg, .95); 
        [k addHighResPixWithDataPNG:largeImgData andTagID:[newRecordID intValue]];
    }
    // add tagID to pixBelongsToUser table, with error handling
    //[k addPixBelongsToUserWithUsername:[self getUsername] andTagID:[newRecordID intValue]];
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects: myUserInfo_username, newRecordID, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"addPixBelongsToUser" withParams:params withCallback:nil withDelegate:self];
    
    bool added = [self addTagWithCheck:newTag withID:[newRecordID intValue]];
    if (added)
    {
        NSLog(@"Added new record to kumulos: tag id %d", [newRecordID intValue]);
        [feedController finishedCreateNewPix:newTag withPendingID:[pendingID intValue]];
    }
    else
        NSLog(@"Error! New record has duplicate tag id: %d", [newRecordID intValue]);
    
    // do not add scale and rotation - all saved in aux stix
    [self updateUserTagTotal];
    
}

-(void)uploadImageFinished {
    // share controller stuff
    if (newPixDidClickShare) {
        NSLog(@"NewPixShare: Upload finished: Now time to share!");
        [shareController doSharePix];
    }
    else {
        NSLog(@"NewPixShare: Now time to wait for user to click on share!");
        newPixDidFinishUpload = YES;
    }    
}

-(void)pendingTagDidHaveAuxiliaryStix:(Tag*)pendingTag withNewTagID:(int)tagID {
    for (int i=0; i<[pendingTag.auxStixStringIDs count]; i++) {
        NSString * stixStringID = [pendingTag.auxStixStringIDs objectAtIndex:i];
        CGPoint location = [[pendingTag.auxLocations objectAtIndex:i] CGPointValue];
        NSString * transform = [pendingTag.auxTransforms objectAtIndex:i];
        
        NSLog(@"New pix has a new stix also: %@", [BadgeView getStixDescriptorForStixStringID:stixStringID]);
        
        // add aux stix to auxiliaryStixes table
        [k addAuxiliaryStixToPixWithTagID:tagID andStixStringID:stixStringID andX:location.x andY:location.y andTransform:transform];
        
        // add comment to comment table
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:tagID], myUserInfo_username, @"", stixStringID, nil];
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        [kh execute:@"addCommentToPix" withParams:params withCallback:@selector(khCallback_addCommentToPixCompleted:) withDelegate:self];
    }
    
    // add to current tag
    for (int i=0; i<[allTags count]; i++) {
        Tag * tag = [allTags objectAtIndex:i];
        if ([tag.tagID intValue] == tagID) {
            [tag setAuxStixStringIDs:pendingTag.auxStixStringIDs];
            [tag setAuxLocations:pendingTag.auxLocations];
            [tag setAuxTransforms:pendingTag.auxTransforms];
            [tag setAuxPeelable:pendingTag.auxPeelable];
            break;
        }
    }
}

-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addHighResImageDidCompleteWithResult:(NSArray *)theResults {
    NSLog(@"High res pic uploaded!");
    NSLog(@"TheResults: %d", [theResults count]);
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

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getLastTagIDDidCompleteWithResult:(NSArray*)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // NSArray contains a number of elements which is the most recently created element in the database
	for (NSMutableDictionary * d in theResults) {        
        int idnum = [[d valueForKey:@"allTagID"] intValue];
        if (idnum > idOfNewestTagOnServer)//idOfMostRecentTagReceived)
        {
            idOfNewestTagOnServer = idnum;
        }
    }
    
    // now download those tags
    NSLog(@"Requesting recent Pix with id %d from Kumulos", idOfNewestTagOnServer);
    [k getAllTagsWithIDRangeWithId_min:idOfNewestTagOnServer-[theResults count] andId_max:idOfNewestTagOnServer+1];    
}

-(void)processTagsWithIDRange:(NSArray*)theResults {
    [feedController stopActivityIndicatorLarge];
    
    // first, update from kumulos in case other people have added stix
    // to the same pix we are modifying
    {
        // this is called from simply wanting to populate our allTags structure
        bool didAddTag = NO;
        // assume result is ordered by allTagID
        for (NSMutableDictionary * d in theResults) {
            Tag * tag = [Tag getTagFromDictionary:d]; // MRC
            int new_id = [tag.tagID intValue];
            didAddTag = [self addTagWithCheck:tag withID:new_id];
            if (didAddTag)
                [feedController reloadPageForTagID:[tag.tagID intValue]];

            // new system of auxiliary stix: request from auxiliaryStixes table
            if (1) {
                NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:tag.tagID, nil]; 
                KumulosHelper * kh = [[KumulosHelper alloc] init];
                [kh execute:@"getAuxiliaryStixOfTag" withParams:params withCallback:@selector(khCallback_didGetAuxiliaryStixOfTag:) withDelegate:self];
            }
        }
        //if (didAddTag) {
            //[feedController reloadCurrentPage]; // should reload page that it is displayed on
        //}
        [feedController stopActivityIndicator];
    }    
    
    
    // we get here from handleNotificationBookmarks
    if (isUpdatingNotifiedTag) {
        if (updatingNotifiedTagDoJump) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
            [self.camera setCameraOverlayView:tabBarController.view];
#endif
            [tabBarController setSelectedIndex:0];
            BOOL exists = [feedController jumpToPageWithTagID:[notificationTagID intValue]];
            if (!exists) {
                NSLog(@"How come no exist?!");
            }
        }
        [feedController reloadCurrentPage]; // allTags were already updated
        [feedController configureCarouselView];
        [self updateCommentCount:[notificationTagID intValue]];
        if (notificationBookmarkType == NB_NEWCOMMENT) {
            [feedController openCommentForPageWithTagID:notificationTagID];
        }
        updatingNotifiedTagDoJump = NO;
        isUpdatingNotifiedTag = NO;
    }
}

-(void)updateTagWithStix:(NSMutableArray *)theResults forTagID:(int)tagID{
    NSLog(@"Updating aux stix for tag: %d downloaded %d auxStix", tagID, [theResults count]);
    for (int i=0; i<[allTags count]; i++) {
        Tag * tag = [allTags objectAtIndex:i];
        if ([[tag tagID] intValue] == tagID) {
            [tag populateWithAuxiliaryStix:theResults];
            [feedController populateAllTagsDisplayedWithTag:tag]; // also removes placeholder (formerly TODO)
            return;
        }
    }
}

-(void)khCallback_didGetAuxiliaryStixOfTag:(NSMutableArray *) returnParams {
    NSNumber * tagID = [returnParams objectAtIndex:0];
    NSMutableArray * theResults = [returnParams objectAtIndex:1];
    
    if ([theResults count] > 0) {
        NSLog(@"Got auxiliary stix of tag %d with %d stix!", [tagID intValue], [theResults count]);
        [self updateTagWithStix:theResults forTagID:[tagID intValue]];
    }
}

-(void)khCallback_didRemoveAuxiliaryStix:(NSMutableArray *) returnParams {
    [self khCallback_didGetAuxiliaryStixOfTag:returnParams];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllTagsWithIDRangeDidCompleteWithResult:(NSArray *)theResults
{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([theResults count]>0) {
        //dispatch_async(backgroundQueue, ^{
            Tag * tag = [Tag getTagFromDictionary:[theResults objectAtIndex:0]] ;
            NSLog(@"Processing tags with id: %d",[[tag tagID] intValue]);
            [self processTagsWithIDRange:theResults];
        //});
    }
    else {
        NSLog(@"Processing results: none exist!");
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updateStixOfPixDidCompleteWithResult:(NSNumber *)affectedRows {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Update finally completed");
    isUpdatingPeelableStix = NO;
}

-(void)checkAggregatorStatus {
    [aggregator displayState];
    NSLog(@"idOfNewestTagReceived: %d", idOfNewestTagReceived);
    NSLog(@"idOfOldestTagReceived: %d", idOfOldestTagReceived);
    NSLog(@"allTags: %d allTagsDisplayed: %d", [allTags count], [[feedController allTagsDisplayed] count]);
}

-(void)getNewerTagsThanID:(int)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // because this gets called multiple times during scrollViewDidScroll, we have to save
    // the last request to try to minimize making duplicate requests
    //[feedController stopActivityIndicator];

    if (tagID == idOfNewestTagReceived || // we always want to make this request
        pageOfLastNewerTagsRequest != tagID){
        pageOfLastNewerTagsRequest = tagID;
        //[k getAllTagsWithIDGreaterThanWithAllTagID:tagID andNumTags:[NSNumber numberWithInt:TAG_LOAD_WINDOW]];
        NSLog(@"Calling getNewerTagsThanID to get newer tags than %d", tagID);
        if (idOfNewestTagReceived < [aggregator getNewestTag]) {
            // manually renew
            NSLog(@"Newer tag already aggregated: %d is newer than last received %d", [aggregator getNewestTag], idOfNewestTagReceived);
            [self didFinishAggregation:NO];
        } else {
        // kick off process to download new tags
        //@try {
            [aggregator aggregateNewTagIDs];
            NSLog(@"Get follow list returned: %@ is following %d people", [self getUsername], [allFollowing count]);
        //} @catch (NSException * error) {
        //    NSLog(@"Aggregate new tags failed! error %@", [error reason]);
        //}
        }
    }
    else{
        //NSLog(@"Duplicate call to getNewerTagsThanID: id %d", tagID);
    }
}

-(void)didStartAggregationWithTagID:(NSNumber *)tagID {
    NSLog(@"Requesting first tag: %@", tagID);
#if 0
    [k getAllTagsWithIDRangeWithId_min:[tagID intValue]-1 andId_max:[tagID intValue]+1];
#else
    if ([allTags count] == 0 || [[feedController allTagsDisplayed] count] == 0)
        [self getTagWithID:[tagID intValue]];
#endif
}

-(void)didSetAggregationTrigger {
    // we've finished aggregation process so all parse is done
}

-(void)didFinishAggregation:(BOOL)isFirstTime {
    if (isFirstTime) {
        NSLog(@"didFinishAggregation: isFirstTime after aggregateTrigger");
        // load from the newest tags, not from the last tag received which could be -1
        int newestTagOnServer = [aggregator getNewestTag];
        NSArray * newerTagsToGet = [aggregator getTagIDsGreaterThanTagID:newestTagOnServer-1 totalTags:-1];
        NSLog(@"didFinishAggregation newestTagOnServer %d tagIDs aggregated %d", newestTagOnServer, [newerTagsToGet count]);
        for (NSNumber * tagID in newerTagsToGet) {
            NSLog(@"First time requesting aggregated tags: newer tags %d", [tagID intValue]);
#if 0
            [k getAllTagsWithIDRangeWithId_min:[tagID intValue]-1 andId_max:[tagID intValue]+1];
#else
            [self getTagWithID:[tagID intValue]];
#endif
        }
        NSArray * olderTagsToGet = [aggregator getTagIDsLessThanTagID:newestTagOnServer totalTags:5];
        for (NSNumber * tagID in olderTagsToGet) {
            NSLog(@"First time requesting aggregated tags: older tags %d", [tagID intValue]);
#if 0
            [k getAllTagsWithIDRangeWithId_min:[tagID intValue]-1 andId_max:[tagID intValue]+1];
#else
            [self getTagWithID:[tagID intValue]];
#endif
        }
    }
    else {
        NSArray * newerTagsToGet = [aggregator getTagIDsGreaterThanTagID:idOfNewestTagReceived totalTags:-1];
        //NSLog(@"didFinishAggregation: aggregateTagId list after id %d", idOfNewestTagReceived);
        if (!newerTagsToGet)
            return;
        NSLog(@"didFinishAggregation list count: %d", [newerTagsToGet count]);
        
        for (int i=0; i<[newerTagsToGet count]; i++) {
            int tID = [[newerTagsToGet objectAtIndex:i] intValue];
            NSLog(@"GetAllTagsWithIDRange called for single tag %d", tID);
#if 0
            [k getAllTagsWithIDRangeWithId_min:tID-1 andId_max:tID+1];
#else
            [self getTagWithID:tID];
#endif
        }
    }
}

-(void)dismissAggregateIndicator {
    // if pulldown was used to refresh feed, indicate that aggregator has completed
    // the requests and dismiss the pulldown.
    // if there's actually any new tagIDs, [self didAggregateNewerTagID] will be called
    // and the feedView will be updated accordingly
    [feedController finishedCheckingForNewData:NO];    
}

-(void)getOlderTagsThanID:(int)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [feedController stopActivityIndicator];

    if (1) { //pageOfLastOlderTagsRequest != tagID) {
        pageOfLastOlderTagsRequest = tagID;
        //[k getAllTagsWithIDLessThanWithAllTagID:tagID andNumTags:[NSNumber numberWithInt:TAG_LOAD_WINDOW]];
        NSArray * oldTagsToGet = [aggregator getTagIDsLessThanTagID:tagID totalTags:TAG_LOAD_WINDOW];
        if (!oldTagsToGet) {
            NSLog(@"getOlderTagsThanID: no more older tags! You are out of content!");
            [feedController stopActivityIndicator];
            return;            
        }
        
        for (int i=0; i<[oldTagsToGet count]; i++) {
            NSNumber * tID = [oldTagsToGet objectAtIndex:i];
            NSLog(@"getOlderTagsThanID to get %d older tags than %d: getTagWithID %d", [oldTagsToGet count], tagID, [tID intValue]);
#if 0
            Tag * tag = [allTagIDs objectForKey:tID];
            if (tag) {
                NSLog(@"Older tag with id %d already exists in allTagIDs structure", tID);
                //bool didAddTag = [self addTagWithCheck:tag withID:tagID];
            }
            else {
                int tID = [[oldTagsToGet objectAtIndex:i] intValue];
                NSLog(@"GetAllTagsWithIDRange called for single tag %d", tID);
                [k getAllTagsWithIDRangeWithId_min:tID-1 andId_max:tID+1];
            }
#else
            [self getTagWithID:[tID intValue]];
#endif
        }
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
        Tag * tag = [Tag getTagFromDictionary:d]; // MRC
        id key = [d valueForKey:@"allTagID"];
        int new_id = [key intValue];
        if (new_id > idOfNewestTagReceived)
            idOfNewestTagReceived = new_id;
        //[tagViewController addCoordinateOfTag:tag];
        //[allTags setObject:tag forKey:key];
        didAddTag = [self addTagWithCheck:tag withID:new_id]; // insert newest key to head
        if (didAddTag)
            totalAdded = totalAdded+1;
         // MRC
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
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllTagsWithIDLessThanDidCompleteWithResult:(NSArray *)theResults {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    bool didAddTag = NO;
    int totalAdded = 0;
	for (NSMutableDictionary * d in theResults) {
        Tag * tag = [Tag getTagFromDictionary:d]; // MRC
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
        //[feedController.scrollView populateScrollPagesAtPage:feedController.lastPageViewed]; // hack: forced reload of end
//        [feedController viewWillAppear:YES];
        [feedController finishedCheckingForNewData:YES];
    }
    else
    {
        [feedController finishedCheckingForNewData:NO];
    }
    [feedController stopActivityIndicator];
}

- (NSMutableArray *) getTags {
    return allTags;
}

-(void)khCallback_addCommentToPixCompleted:(NSMutableArray*)params {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSNumber * tagID = [params objectAtIndex:0];
    if (tagID) {
        //[self getCommentCount:[tagID intValue]];
        [k getAllHistoryWithTagID:[tagID intValue]];
    }
}

-(void)khCallback_addCommentToPixWithDetailViewControllerCompleted:(NSMutableArray*)params {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSNumber * tagID = [params objectAtIndex:0];
    if (tagID) {
        //[self getCommentCount:[tagID intValue]];
        [k getAllHistoryWithTagID:[tagID intValue]];
    }
    if ([params count] > 1) {
        DetailViewController * detailViewController = [params objectAtIndex:1];
        [detailViewController addCommentDidFinish];
    }
}

-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID {
    // simple version - no detailViewController
    [self didAddCommentFromDetailViewController:nil withTagID:tagID andUsername:name andComment:comment andStixStringID:stixStringID];
}

-(void)didAddCommentFromDetailViewController:(DetailViewController*)detailViewController withTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    if (detailViewController == nil) {
        // regular comment
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:tagID], name, comment, stixStringID, nil];
        [kh execute:@"addCommentToPix" withParams:params withCallback:@selector(khCallback_addCommentToPixCompleted:) withDelegate:self];
        NSLog(@"Kumulos: Adding comment to tagID %d", tagID);
    }
    else {
        // comment from a detailViewController - must do a callback
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:tagID], name, comment, stixStringID, detailViewController, nil];
        [kh execute:@"addCommentToPixWithDetailViewController" withParams:params withCallback:@selector(khCallback_addCommentToPixWithDetailViewControllerCompleted:) withDelegate:self];
        NSLog(@"Kumulos: Adding comment to tagID %d", tagID);
    }
    
    if ([stixStringID isEqualToString:@"LIKE"]) {
        // comment from the Like Toolbar
        
        // notify
        NSString * actionMsg;
        if ([comment isEqualToString:@"LIKE_SMILES"])
            actionMsg = [NSString stringWithFormat:@"%@ smiled at your Pix.", myUserInfo_username];
        if ([comment isEqualToString:@"LIKE_LOVE"])
            actionMsg = [NSString stringWithFormat:@"%@ loves your Pix.", myUserInfo_username];
        if ([comment isEqualToString:@"LIKE_WINK"])
            actionMsg = [NSString stringWithFormat:@"%@ winked at your Pix.", myUserInfo_username];
        if ([comment isEqualToString:@"LIKE_SHOCKED"])
            actionMsg = [NSString stringWithFormat:@"%@ is shocked by your Pix.", myUserInfo_username];
        Tag * tag = [allTagIDs objectForKey:[NSNumber numberWithInt:tagID]]; //[self getTagWithID:tagID];
        if (tag != nil) // if tag is nil, it is not on feed yet, just ignore
        {
            if (![tag.username isEqualToString:[self getUsername]]) {
                NSString * tagName = [tag.username stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSLog(@"allUserIDs: %d objects Id %d for tagName %@", [allUserIDs count], [[allUserIDs objectForKey:tagName] intValue], tagName);
                NSString * channel = [NSString stringWithFormat:@"To%d", [[allUserIDs objectForKey:tagName] intValue]];
                NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
                [self Parse_sendBadgedNotification:actionMsg OfType:NB_NEWCOMMENT toChannel:channel withTag:tag.tagID];  
            }
        }
    }
    else if ([stixStringID isEqualToString:@"COMMENT"]) { //![comment isEqualToString:@""]) {
        // actual comment
        
        // notify
        NSString * message = [NSString stringWithFormat:@"%@ commented on your feed.", myUserInfo_username];
        Tag * tag = [allTagIDs objectForKey:[NSNumber numberWithInt:tagID]]; //[self getTagWithID:tagID];
        if (tag != nil) // if tag is nil, it is not on feed yet, just ignore
        {
            if (![tag.username isEqualToString:[self getUsername]]) {
                NSString * tagName = [tag.username stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSNumber * userID = [allUserIDs objectForKey:tagName];
                NSString * channel = [NSString stringWithFormat:@"To%d", [userID intValue]];
                if (!userID || [userID intValue] == 0) {
                    NSLog(@"Invalid user number being used for channel!");
                    if (!userID)
                        NSLog(@"User %@ has null userid! allUserIDs has %d objects", tagName, [allUserIDs count]);
                    else
                        NSLog(@"User %@ has id %d, allUserIDs has %d objects", tagName, [userID intValue], [allUserIDs count]);
                }
                //NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                //channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
                [self Parse_sendBadgedNotification:message OfType:NB_NEWCOMMENT toChannel:channel withTag:tag.tagID];
            }
        }
        [self updateUserTagTotal];
        
        // don't updateCommentCount;
        // touch tag to indicate it was updated
        [k touchPixToUpdateWithAllTagID:tagID];
        
        // metrics
#if !USING_FLURRY
        NSString * metricName = @"CommentAdded";
        //NSString * metricData = [NSString stringWithFormat:@"Comment: %@", comment];
        [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:comment andIntegerValue:0];
#else
        [FlurryAnalytics logEvent:@"CommentAdded" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", comment, @"comment", nil]];
#endif
    }
}

-(int)getCommentCount:(int)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (tagID == -1)
        return 0;
    
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
//-(void)didDismissFriendView {}; // only used in profileView
-(void) checkForUpdatePhotos {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Checking for update photos");
    if (1)
    {
        //[friendController setIndicator:YES];
        //[k getAllUsers];
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        [kh execute:@"getAllUsersForUpdatePhotos" withParams:nil withCallback:@selector(khCallback_getAllUsersDidComplete:) withDelegate:self];
    }
}
-(void)didSendGiftStix:(NSString *)stixStringID toUsername:(NSString *)friendName {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
}

//- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults {
-(void)khCallback_getAllUsersDidComplete:(NSArray *) returnParams {
    NSMutableArray * theResults = [returnParams objectAtIndex:0];
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"kumulosHelper getAllUsers did complete with %d users", [theResults count]);
    dispatch_async(backgroundQueue, ^{
        [allUsers removeAllObjects];
        [allUserPhotos removeAllObjects];
        [allUserFacebookIDs removeAllObjects];
        [allUserIDs removeAllObjects];
        [allUserEmails removeAllObjects];
        [allUserNames removeAllObjects];
        for (NSMutableDictionary * d in theResults) {
            NSString * name = [d valueForKey:@"username"];
            UIImage * photo = [d valueForKey:@"photo"];
            NSNumber * facebookID = [d valueForKey:@"facebookID"];
            NSNumber * userID = [d valueForKey:@"allUserID"];
            [allUsers setObject:d forKey:name];
            [allUserPhotos setObject:photo forKey:name];
            [allUserFacebookIDs addObject:[NSString stringWithFormat:@"%d", [facebookID intValue]]];
            [allUserEmails addObject:[d valueForKey:@"email"]];
            [allUserNames addObject:name];
            [allUserIDs setObject:userID forKey:name];
            //NSLog(@"AllUserIDS: %@ %d", userID, [userID intValue]);
        }
    });
}

-(void)didAddNewUserWithResult:(NSArray *)theResults {
    for (NSMutableDictionary * d in theResults) {
        NSString * name = [d valueForKey:@"username"];
        UIImage * photo = [d valueForKey:@"photo"];
        NSNumber * facebookID = [d valueForKey:@"facebookID"];
        [allUsers setObject:d forKey:name];
        [allUserPhotos setObject:photo forKey:name];
        [allUserFacebookIDs addObject:[NSString stringWithFormat:@"%d", [facebookID intValue]]];
        [allUserEmails addObject:[d valueForKey:@"email"]];
        [allUserNames addObject:name];
        [allUserIDs setObject:[NSString stringWithFormat:@"%d", [facebookID intValue]] forKey:name];
    }    
}

/**** LoginSplashController delegate ****/

/**** ProfileViewController and login functions ****/
-(void)didOpenProfileView {
    if ( (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_01 || myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02)) {
        [self agitateFirstTimePointer];
        return;
    }
    if (isDisplayingShareSheet)
        return;
    if (isLoggingIn) {
        [feedController.buttonProfile setImage:myUserInfo_userphoto forState:UIControlStateNormal];
        [feedController.buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [feedController.buttonProfile.layer setBorderWidth:1];
    }
    
    // hack a way to display feedback view over camera: formerly presentModalViewController
    CGRect frameOffscreen = CGRectMake(-320, STATUS_BAR_SHIFT, 320, 480);
    [self.tabBarController.view addSubview:profileController.view];
    [profileController.view setFrame:frameOffscreen];

    CGRect frameOnscreen = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:profileController.view toFrame:frameOnscreen forTime:.5 withCompletion:^(BOOL finished){
    }];
    
    // must force viewDidAppear because it doesn't happen when it's offscreen?
    [profileController viewDidAppear:YES]; 

    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_03) {
        [self advanceFirstTimeUserMessage];
        [self hideFirstTimeUserMessage];
        [profileController doPointerAnimation];
    }
}

-(void)closeProfileView {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (followListsDidChangeDuringProfileView) {
        followListsDidChangeDuringProfileView = NO;
        [aggregator resetFirstTimeState];
        [aggregator reaggregateTagIDs];
        [feedController followListsDidChange]; // tell feedController to redisplay all users that are in the feed but were unfriended
        idOfOldestTagReceived = idOfNewestTagReceived;
        idOfNewestTagReceived = feedController.newestTagIDDisplayed; //-1;
    }
//    [self.profileController.view removeFromSuperview];
//    [self.camera setCameraOverlayView:self.tabBarController.view];
    StixAnimation * animation = [[StixAnimation alloc] init];
    //animation.delegate = self;
    CGRect frameOffscreen = profileController.view.frame;
    //[self.window addSubview:profileController.view];
    //[self.camera setCameraOverlayView:self.tabBarController.view];
    
    frameOffscreen.origin.x -= 330;
    [animation doViewTransition:profileController.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [profileController.view removeFromSuperview];
//        [self.camera setCameraOverlayView:self.tabBarController.view];
    }];
    /*
    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_01 || myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
        [tabBarController toggleFirstTimePointer:YES atStage:myUserInfo->firstTimeUserStage];
    }
     */
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
    //[profileController viewWillAppear:YES];
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
    //[profileController viewWillAppear:YES];
    
    // scale down photo
	CGSize targetSize = CGSizeMake(90, 90);		
    UIImage * result = [newPhoto resizedImage:targetSize interpolationQuality:kCGInterpolationDefault];
    UIImage * rounded = [result roundedCornerImage:0 borderSize:2];
    
    // save to album
#if 0
    UIImageWriteToSavedPhotosAlbum(rounded, nil, nil, nil); 
#else
    [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:rounded toAlbum:@"Stix Album" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"Could not write to library: error %@", [error description]);
        }
    }];
#endif    
    //NSData * img = UIImageJPEGRepresentation(rounded, .8);
    NSData * img = UIImagePNGRepresentation(rounded);
    [profileController.photoButton setImage:rounded forState:UIControlStateNormal];
    [self didChangeUserphoto:rounded];
    
    // add to kumulos
    [k addPhotoWithUsername:myUserInfo_username andPhoto:img];
    //if (lastViewController == feedController)
    //    [self didPressTabButton:0];
    //else if (lastViewController == exploreController)
    //    [self didPressTabButton:2];
    //[self closeProfileView];
    [feedController.buttonProfile setImage:myUserInfo_userphoto forState:UIControlStateNormal];
    [feedController.buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [feedController.buttonProfile.layer setBorderWidth:1];
    [exploreController.buttonProfile setImage:myUserInfo_userphoto forState:UIControlStateNormal];
    [exploreController.buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [exploreController.buttonProfile.layer setBorderWidth:1];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPhotoDidCompleteWithResult:(NSNumber*)affectedRows;
{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Added photo to username %@",  myUserInfo_username);
    
    // force friendView to update photo after we know it is in kumulos
    [self checkForUpdatePhotos];
}

-(void)searchFriendsByFacebook {
    NSLog(@"Requesting friends on facebook");
    [fbHelper requestFacebookFriends];
}

-(void)receivedFacebookFriends:(NSArray*)friendsArray {
    [profileController populateFacebookSearchResults:friendsArray];
    if (friendSuggestionController)
        [friendSuggestionController populateFacebookSearchResults:friendsArray];
}

-(NSMutableDictionary*)getAllUsers {
    return allUsers;
}

-(NSMutableArray*)getAllUserFacebookIDs {
    return allUserFacebookIDs;
}
-(NSMutableArray*)getAllUserEmails {
    return allUserEmails;
}
-(NSMutableArray*)getAllUserNames {
    return allUserNames;
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
    NSLog(@"Kumulos error: %@ in op %@", theError, [operation description]);
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
        //[self showAlertWithTitle:@"Network Error" andMessage:@"Your network connectivity is too weak. Connection to the servers failed!" andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
        [self showAlertWithTitle:@"Low Connectivity" andMessage:@"Your network connectivity is weak. Stix may be unresponsive." andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    }
}

-(void)didLoginFromSplashScreenWithUsername:(NSString *)username andPhoto:(UIImage *)photo andEmail:(NSString*)email andFacebookID:(NSNumber*)facebookID andUserID:(NSNumber*)userID andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary*) stixOrder isFirstTimeUser:(BOOL)firstTime {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
        
    NSLog(@"DidLoginFromSplashScreen: username %@ stix %d, stixOrder %d", username, [stix count], [stixOrder count]);

#if USING_FLURRY
    // only log to flurry here because every session eventually comes here; didLoginWithUsername can be called twice
    [FlurryAnalytics logEvent:@"LoginWithUsername" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:username, @"username", nil]];
    [FlurryAnalytics setUserID:username];
#endif
    
    /***** if we used splash screen *****/
#if 0
    [self didDismissSecondaryView];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tabBarController.view];
#endif
    [self.tabBarController setSelectedIndex:0];    
#else
    if (!didGetFollowingLists) {
        // may be called after cached user login
        [self getFollowListsWithoutAggregation:username];
        didGetFollowingLists = YES;
        isShowingFriendSuggestions = YES; // following lists are used to initialize friend suggestion page so we want to lock other functions
    }
#endif
    
    // create shareController, share and connected lists for each service, and loads from default
    [self initializeShareController];

    // check for user stage saved in UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"firstTimeUserStage"] == nil) {
        myUserInfo->firstTimeUserStage = FIRSTTIME_MESSAGE_01;
    }
    // first time facebook connects, set defaults to YES automatically
    [shareController connectService:@"Facebook"];

    if (firstTime) {
        // flag set if someone is added to Kumulos for the first time
        [k addFollowerWithUsername:username andFollowsUser:@"William Ho"];
        [k addFollowerWithUsername:username andFollowsUser:@"Bobby Ren"];
        [k addFollowerWithUsername:@"William Ho" andFollowsUser:username];
        [k addFollowerWithUsername:@"Bobby Ren" andFollowsUser:username];
    }
    
    [self didLoginWithUsername:username andPhoto:photo andEmail:email andFacebookID:facebookID andUserID:userID andStix:stix andTotalTags:total andBuxCount:bux andStixOrder:stixOrder];
    
    // login to parse only if facebook has correctly logged in. this ensures that the userID being saved to myUserInfo is the correct one
    if (notificationDeviceToken) {
        [self Parse_createSubscriptions];  
    }
    else {
        // try registering again
        //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];    
        // just wait
        NSLog(@"No device token yet!");
    }
}

- (void)didLoginWithUsername:(NSString *)name andPhoto:(UIImage *)photo andEmail:(NSString*)email andFacebookID:(NSNumber*)facebookID andUserID:(NSNumber*)userID andStix:(NSMutableDictionary *)stix andTotalTags:(int)total andBuxCount:(int)bux andStixOrder:(NSMutableDictionary *)stixOrder {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  

#if !USING_FLURRY
    NSString * metricName = @"LoginWithUsername";
    NSString * metricData = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
    //NSString * string = [NSString stringWithFormat:@"User login: %@", name];
    [k addMetricWithDescription:metricName andUsername:name andStringValue:metricData andIntegerValue:0];
#endif

    if (![stix isKindOfClass:[NSMutableDictionary class]]) {
        stix = nil;
        [allStix removeAllObjects];
    }
    else {
        [allStix removeAllObjects];
        [allStix addEntriesFromDictionary:stix];
    }
    if (![stixOrder isKindOfClass:[NSMutableDictionary class]]) {
       
        stixOrder = nil;
        [stixOrder removeAllObjects];
    }
    else {
        [allStixOrder removeAllObjects];
        [allStixOrder addEntriesFromDictionary:stixOrder];
        
        NSLog(@"DidLoginWithUsername: %@ allStix: %d stixOrder: %d", name, [allStix count], [stixOrder count]);
    }  
    
    [aggregator loadCachedUserTagListForUsers];

    // done by whoever calls didLoginWithUsername now
    // get friends/follow relationships
    //if (!didGetFollowingLists) { 
    //    [self getFollowLists];
    //    didGetFollowingLists = YES;
    //}
    
    loggedIn = YES;
    myUserInfo_username = name;
    myUserInfo_userphoto = photo;
    myUserInfo->usertagtotal = total;
    myUserInfo->bux = bux;
    myUserInfo_email = email;
    myUserInfo->facebookID = [facebookID intValue];
    myUserInfo->userID = [userID intValue];
    [profileController didLogin]; 
    
    [feedController.buttonProfile setImage:myUserInfo_userphoto forState:UIControlStateNormal];
    [feedController.buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [feedController.buttonProfile.layer setBorderWidth:1];
    NSLog(@"UserID: %d Username %@ with email %@ and facebookID %d", myUserInfo->userID, myUserInfo_username, email, [facebookID intValue]);
            
    // DO NOT do this: opening a camera probably means the badgeView belonging to LoginSplashViewer was
    // deleted so now this is invalid. that badgeView does not need badgeLocations anyways
    
    //[myStixController forceLoadMyStix];
    [self reloadAllCarousels];
    [self updateBuxCount];
    //[profileController updatePixCount];    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        // save username, facebookid, email to disk
        [self saveUserInfoToDefaults]; // saves user name
    });
        
#if !USING_FLURRY
    [self setMetricLogonTime:[NSDate date]];
#else
    [FlurryAnalytics logEvent:@"TimeInApp" timed:YES];
#endif
    // only download badges after login is over
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        NSLog(@"Login complete: starting initializeBadges");
        //[self initializeBadgesFromKumulos];
    });
     */
    if (!didStartFirstTimeMessage && !isShowingFriendSuggestions) {
        [tabBarController displayFirstTimeUserProgress:myUserInfo->firstTimeUserStage];    
        didStartFirstTimeMessage = YES;
    }
    
    // check for premium
    [k getUserPremiumPacksWithUsername:myUserInfo_username];
    
}

/*
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
        [allStix addEntriesFromDictionary:[BadgeView InitializeFirstTimeUserStix] ];
        
        NSLog(@"Generating stix order:");
        NSEnumerator *e = [allStix keyEnumerator];
        id key;
        while (key = [e nextObject]) {
                int ct = [self getStixCount:key];
                if (ct != 0)
                    [allStixOrder setObject:[NSNumber numberWithInt:[allStixOrder count]] forKey:key];
        }    
    }
}
*/

-(void)didLogout {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    loggedIn = NO;
    myUserInfo_username = @"";
    if (myUserInfo_userphoto) {
        myUserInfo_userphoto = nil;
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
        myUserInfo_username = @"";
        if (myUserInfo_userphoto) {
            [myUserInfo_userphoto release];
            myUserInfo_userphoto = nil;
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
    myUserInfo_userphoto = photo;
}

-(int)getStixCount:(NSString*)stixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    //if (loggedIn)
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

-(NSMutableSet*)getFollowerList {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    return allFollowers;
}
-(NSMutableSet*)getFollowingList {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    return allFollowing;
}

-(BOOL)isFollowing:(NSString*)name {
    if ([allFollowing count] == 0)
        return YES;
    return [allFollowing containsObject:name];
}

-(void)setFollowing:(NSString *)friendName toState:(BOOL)shouldFollow {
    if (shouldFollow) {
        [allFollowing addObject:friendName];
        NSLog(@"SetFollowing: you are now following %@ currentList %@", friendName, allFollowing );
        [k addFollowerWithUsername:[self getUsername] andFollowsUser:friendName];
        followListsDidChangeDuringProfileView = YES;
        
        NSString * message = [NSString stringWithFormat:@"%@ is now following you on Stix.", [self getUsername]];
        NSString * name = [friendName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString * channel = [NSString stringWithFormat:@"To%d", [[allUserIDs objectForKey:friendName] intValue]];//name];
        //NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
        //channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
        [self Parse_sendBadgedNotification:message OfType:NB_NEWFOLLOWER toChannel:channel withTag:nil];
        //[self Parse_sendNotificationToFollowers:message ofType:NB_NEWFOLLOWER withTag:nil];
        
        // subscribe to channel
        //channel = [NSString stringWithFormat:@"From%@", friendName];
        //channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
        //[self Parse_subscribeToChannel:channel];
    }
    else {
        [allFollowing removeObject:friendName];
        [k removeFollowerWithUsername:[self getUsername] andFollowsUser:friendName];
        NSLog(@"You are no longer following %@ - reloading view", friendName);
        followListsDidChangeDuringProfileView = YES;
        //[feedController didUnfollowUser]; // tell feedController to hide all users that were followed but were unfriended
        
        // corner case - if all tags removed from this friend causes feed to be empty
        // we have to reset aggregator first time state
        /*
        if ([[feedController allTagsDisplayed] count] == 0)
        {
            NSLog(@"Unfollowing a user cleared our view! must reset aggregator");
            [aggregator resetFirstTimeState];
        }
         */
        
        // unsubscribe from that channel
        //NSString * channel = [NSString stringWithFormat:@"From%@", friendName];
        //NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
        //channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
        //[self Parse_unsubscribeFromChannel:channel];
    }
    [profileController updateFollowCounts];
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
    
    // touch tag to indicate it was updated
    [k touchPixToUpdateWithAllTagID:[tag.tagID intValue]];
    
    // first update existing tag and display to user for immediate viewing
    // only uses these if not fire/ice 
    float peelable = YES;
    if ([tag.username isEqualToString:myUserInfo_username])
        peelable = NO;
    [tag addStix:stixStringID withLocation:location /*withScale:scale withRotation:rotation */withTransform:transform withPeelable:peelable];

    NSNumber * tagID = tag.tagID;
    for (int i=0; i<[allTags count]; i++) {
        Tag * t = [allTags objectAtIndex:i];
        if ([t.tagID intValue] == [tagID intValue])
        {
            [allTags replaceObjectAtIndex:i withObject:tag];
            [allTagIDs setObject:tag forKey:tagID];
            [feedController reloadPage:i];
            break;
        }
    }
    
    // immediately add comment, update total, decrement stix count
    [self didAddCommentWithTagID:[tag.tagID intValue] andUsername:myUserInfo_username andComment:@"" andStixStringID:stixStringID]; // this adds to history item
    [self updateUserTagTotal];        
    
    // metrics
#if !USING_FLURRY
    NSString * metricName = @"StixTypesUsed";
    //NSString * metricData = [NSString stringWithFormat:@"StixType: %@", [self getUsername], stixStringID];
    [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:stixStringID andIntegerValue:0];
    // metrics - adding to another user's
    if (![[self getUsername] isEqualToString:tag.username]) {
        NSString * metricName = @"StixAddedToFriend";
        NSString * metricData = [NSString stringWithFormat:@"Friend: %@ Stix: %@", tag.username, stixStringID];
        [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:metricData andIntegerValue:0];
    }
#else
    [FlurryAnalytics logEvent:@"StixTypesUsed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", stixStringID, @"stixStringID", nil]];
    if (![[self getUsername] isEqualToString:tag.username]) {
        [FlurryAnalytics logEvent:@"StixAddedToFriend" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", tag.username, @"friendName", stixStringID, @"stixStringID", nil]];
    }
#endif

    // second, correctly update tag by getting updates for this tag (new aux stix) from kumulos
    updatingAuxTagID = [tag.tagID intValue];
    updatingAuxStixStringID = stixStringID;
    updatingAuxLocation = location;
    //updatingAuxScale = scale;
    //updatingAuxRotation = rotation;
    updatingAuxTransform = transform;

#if 0
    isUpdatingAuxStix = YES;
#else
    [k addAuxiliaryStixToPixWithTagID:[tag.tagID intValue] andStixStringID:stixStringID andX:location.x andY:location.y andTransform:NSStringFromCGAffineTransform(transform)];
#endif
    
    // send notification
    // if adding to own pix, do not notify or broadcast
    if (![myUserInfo_username isEqualToString:tag.username]) {
        NSString * message = [NSString stringWithFormat:@"%@ added %@ to your Pix!", myUserInfo_username, [BadgeView getStixDescriptorForStixStringID:stixStringID]];
        NSString * tagName = [tag.username stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString * channel = [NSString stringWithFormat:@"To%d", [[allUserIDs objectForKey:tag.username] intValue]];
        NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
        channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
        [self Parse_sendBadgedNotification:message OfType:NB_NEWSTIX toChannel:channel withTag:tag.tagID];
    }
    
    //[k getAllTagsWithIDRangeWithId_min:[tag.tagID intValue]-1 andId_max:[tag.tagID intValue]+1];
    
    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
        [self advanceFirstTimeUserMessage];
    }
}

-(void)didPerformPeelableAction:(int)action forTagWithID:(int)tagID forAuxStix:(int)index {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (tagID < 0)
        return;
    if ([allTags count] == 0)
        return;
    Tag * tag = nil;
    for (int i=0; i<[allTags count]; i++) {
        tag = [allTags objectAtIndex:i];
        if ([tag.tagID intValue] == tagID)
            break;
    }
    if (tag==nil)
        return;

    updatingPeelableAuxStixIndex = index;
#if 0
    isUpdatingPeelableStix = YES;
    updatingPeelableAction = action;
    updatingPeelableTagID = [tag.tagID intValue];

    [k getAllTagsWithIDRangeWithId_min:[tag.tagID intValue]-1 andId_max:[tag.tagID intValue]+1];
#else
    CGPoint peeledLocation = [tag getLocationOfRemoveStixAtIndex:updatingPeelableAuxStixIndex];

    // do not call removeStixAtIndex - instead, allow tag to update all stix together
    //NSString * peeledAuxStixStringID = [[tag removeStixAtIndex:updatingPeelableAuxStixIndex] copy];
    NSString * peeledAuxStixStringID = [[tag.auxStixStringIDs objectAtIndex:updatingPeelableAuxStixIndex] copy];
    
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:tag.tagID, myUserInfo_username, @"PEEL", peeledAuxStixStringID, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"addCommentToPix" withParams:params withCallback:@selector(khCallback_addCommentToPixCompleted:) withDelegate:self];

    [self Parse_sendBadgedNotification:@"This is an automatic general notification!" OfType:NB_PEELACTION toChannel:@"" withTag:tag.tagID];
    
    NSMutableArray * params2 = [[NSMutableArray alloc] initWithObjects:tag.tagID, peeledAuxStixStringID, [NSValue valueWithCGPoint:peeledLocation], nil]; 
    KumulosHelper * kh2 = [[KumulosHelper alloc] init];
    [kh2 execute:@"removeAuxiliaryStix" withParams:params2 withCallback:@selector(khCallback_didRemoveAuxiliaryStix:) withDelegate:self];
    
#endif
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
        return myUserInfo_username;
    }
    //NSLog(@"[delegate getUsername] returning anonymous");
    return @"anonymous";
}

-(UIImage *) getUserPhoto {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([self isLoggedIn] == NO)
        return [UIImage imageNamed:@"graphic_nopic.png"];
    return myUserInfo_userphoto;
}

-(UIImage *)getUserPhotoForProfile {
    // for profile view
    if ([self isLoggedIn])
        return [self getUserPhoto];
    else
        return [UIImage imageNamed:@"graphic_addpic.png"];
}

-(NSMutableDictionary * )getUserPhotos {
    return allUserPhotos;
}
-(UIImage*)getUserPhotoForUsername:(NSString *)username {
    NSData * photoData = [allUserPhotos objectForKey:username];
    UIImage * photo = [[UIImage alloc] initWithData:photoData];
    if (photo)
        return photo;
    else
        return [UIImage imageNamed:@"graphic_nopic.png"];
}

-(int)getUserTagTotal { return myUserInfo->usertagtotal; }
-(int)getBuxCount { return myUserInfo->bux; }
-(int)getUserFacebookID { return myUserInfo->facebookID; }

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

-(void)didEarnFacebookReward:(int)bux {
    if (bux == 10) {
        NSString * title = @"Invite Complete";
        [tabBarController doRewardAnimation:title withAmount:bux];
    }
    if (bux == 5) {
        NSString * title = @"Shared Picture";
        [tabBarController doRewardAnimation:title withAmount:bux];
    }
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

-(void)updateUserTagTotal {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // update usertagtotal
    myUserInfo->usertagtotal += 1;
    [k updateTotalTagsWithUsername:myUserInfo_username andTotalTags:myUserInfo->usertagtotal];
    if ((myUserInfo->usertagtotal % 5) == 0) {
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
    feedbackController = [[FeedbackViewController alloc] init];
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
    NSString * subject = [NSString stringWithFormat:@"%@ sent from %@", type, myUserInfo_username];
    NSString * fullmessage = [NSString stringWithFormat:@"Stix version Stable %@ Beta %@\n\n%@", versionStringStable, versionStringBeta, message];
	[self sendEmailTo:@"bobbyren@gmail.com, willh103@gmail.com" withCC:@"" withSubject:subject withBody:fullmessage];
    [self didDismissSecondaryView];
}

#pragma mark shareController and share services
-(void)initializeShareController {
    if (shareController == nil) {
        shareController = [ShareController sharedShareController];
        [shareController setDelegate:self];
    }
    
    //[[SHK currentHelper] setRootViewController:feedController];

    // check to see if each service is already sharing - load from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * connected, * sharing;
         
    // set whether facebook is connected based on session
    //if ([fbHelper facebookHasSession]) {
    BOOL bConnected = [fbHelper facebookHasSession];
    [shareController shareServiceShouldConnect:bConnected forService:@"Facebook"];
    // set whether facebook is sharing based on defaults
    sharing = [defaults objectForKey:@"FacebookIsSharing"]; 
    if (sharing) {
        BOOL isSharing = [sharing boolValue];
        [shareController shareServiceShouldShare:isSharing forService:@"Facebook"];
    }
    
    // set whether twitter is connect based on defaults
    connected = [defaults objectForKey:@"TwitterIsConnected"]; 
    if (connected) 
    {
        BOOL bConnected = [connected boolValue];
        NSLog(@"bConnected: %d", bConnected);
        [shareController shareServiceShouldConnect:bConnected forService:@"Twitter"];
    }
    // set whether twitter is sharing based on defaults
    sharing = [defaults objectForKey:@"TwitterIsSharing"]; 
    if (sharing) {
        BOOL bSharing = [sharing boolValue];
        NSLog(@"bSharing: %d", bSharing);
        [shareController shareServiceShouldShare:bSharing forService:@"Twitter"];
    }
}
-(void)displayShareController:(Tag*)tag {
#if 0
    UIImage * result = [tag tagToUIImage];
    NSData *png = UIImagePNGRepresentation(result);
    [shareController setImage:result];
    [shareController setPNG:png];
    [shareController setTagID:[tag.tagID intValue]];
    [shareController setDelegate:self];
#endif
    
    // hack a way to display feedback view over camera: formerly presentModalViewController
    CGRect frameOffscreen = CGRectMake(-320, STATUS_BAR_SHIFT, 320, 480);
    [self.tabBarController.view addSubview:shareController.view];
    [shareController.view setFrame:frameOffscreen];
    
    CGRect frameOnscreen = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:shareController.view toFrame:frameOnscreen forTime:.5 withCompletion:^(BOOL finished){
    }];
    
    // must force viewDidAppear because it doesn't happen when it's offscreen?
    [shareController reloadConnections];
    [shareController viewDidAppear:YES]; 
}

-(void)initializeFriendSuggestionController {
    // starts requests for friends on facbook and featured users
    // keeps the login screen up, and only dismisses when both have loaded
    // calls displayFriendSuggestionController then
    [friendSuggestionController initializeSuggestions];
}

-(void)friendSuggestionControllerFinishedLoading:(int)totalSuggestions { 
    // used to be displayFriendSuggestionController
    if (totalSuggestions == 0) {
        [self didDismissSecondaryView]; // close login controller
        [self shouldCloseFriendSuggestionControllerWithNames:nil];
    }
    else {
        //isShowingFriendSuggestions = YES;
        
#if 1
        [self didDismissSecondaryView];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [camera setCameraOverlayView:tabBarController.view];
        [self.tabBarController setSelectedIndex:0];    

        // hack a way to display feedback view over camera: formerly presentModalViewController
        CGRect frameOffscreen = CGRectMake(-320, STATUS_BAR_SHIFT, 320, 480);
        [self.tabBarController.view addSubview:friendSuggestionController.view];
        [friendSuggestionController.view setFrame:frameOffscreen];
        
        CGRect frameOnscreen = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
        StixAnimation * animation = [[StixAnimation alloc] init];
        [animation doViewTransition:friendSuggestionController.view toFrame:frameOnscreen forTime:.5 withCompletion:^(BOOL finished){
        }];
#else
        [self didDismissSecondaryView];
        CGRect frameOnscreen = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
        [friendSuggestionController.view setFrame:frameOnscreen];
        [tabBarController.view addSubview:friendSuggestionController.view];
#endif
    }        
}

-(void)didClickInviteButton {
    /*
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Invite button submitted by %@", [self getUsername]);
    NSString * subject = [NSString stringWithFormat:@"Become a Stixster!"];
    NSString * body = [NSString stringWithFormat:@"I'm playing Stix on my iPhone and I think you'd enjoy it too! Just click <a href=\"http://bit.ly/sjvbNE\">here</a> to get started!"];
    [self sendEmailTo:@"" withCC:@"bobbyren@gmail.com, willh103@gmail.com" withSubject:subject withBody:body];
    [self rewardBux];
     */
}
-(void)didClickInviteButtonByFacebook:(NSString *)username withFacebookID:(NSString *)fbID {
    //NSString * metricString = [NSString stringWithFormat:@"%@ invited %@", [self getUsername], username];
#if !USING_FLURRY
    [k addMetricWithDescription:@"facebookInvite" andUsername:[self getUsername] andStringValue:username andIntegerValue:0];
#else
    [FlurryAnalytics logEvent:@"facebookInvite" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", username, @"invitedFriend", nil]];
#endif
    [fbHelper sendInvite:username withFacebookID:fbID];
//    [self rewardBux];
}

-(void)shouldDisplayUserPage:(NSString *)name {
    NSLog(@"ShouldDisplayUserPage: %@", name);
    if (myUserInfo->firstTimeUserStage < FIRSTTIME_DONE) {
        [self agitateFirstTimePointer];
        return;
    }
    if ([name isEqualToString:[self getUsername]]) {
        [self didOpenProfileView];
        return;
    }
    // hack a way to display feedback view over camera: formerly presentModalViewController
    CGRect frameOffscreen = CGRectMake(-330, STATUS_BAR_SHIFT, 320, 480);
    [self.tabBarController.view addSubview:userProfileController.view];
    [userProfileController.view setFrame:frameOffscreen];
    [userProfileController setUsername:name];

    CGRect frameOnscreen = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:userProfileController.view toFrame:frameOnscreen forTime:.5 withCompletion:^(BOOL finished){
    }];    // does not need delegate function
    // must force viewDidAppear because it doesn't happen when it's offscreen?
    [userProfileController viewDidAppear:YES]; 
}

-(void)shouldCloseUserPage {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = userProfileController.view.frame;
    frameOffscreen.origin.x -= 330;
    //[self.tabBarController.view addSubview:userProfileController.view];
    //[self.camera setCameraOverlayView:self.tabBarController.view];
    
    [animation doViewTransition:userProfileController.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [userProfileController.view removeFromSuperview];
    }];
}

-(void)shouldCloseShareController:(BOOL)didClickDone {
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = shareController.view.frame;
    frameOffscreen.origin.x -= 330;
    
    if (didClickDone) {
        if (newPixDidFinishUpload) {
            NSLog(@"NewPixShare: Did click done: upload already finished");
            [shareController doSharePix];
        }
        else {
            newPixDidClickShare = YES;
            NSLog(@"NewPixShare: Clicked share; waiting for upload");
        }
        
        // check for caption - used as comment
        NSString * caption = [shareController.caption text];
        NSLog(@"Did add caption: %@", caption);
        if (caption && [caption length] > 0) {
            int tagID = [[shareController.tag tagID] intValue];
            [self didAddCommentWithTagID:tagID andUsername:[self getUsername] andComment:caption andStixStringID:@"COMMENT"];
        }
    }    

    [animation doViewTransition:shareController.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [shareController.view removeFromSuperview];

        // check for first time user experience
        if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_01) {
            [self advanceFirstTimeUserMessage];
        }
    }];

}

-(void)shouldCloseFriendSuggestionControllerWithNames:(NSArray *)addedFriends {
    isShowingFriendSuggestions = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
#if !TARGET_IPHONE_SIMULATOR
    [camera setCameraOverlayView:tabBarController.view];
#endif
    [self.tabBarController setSelectedIndex:0];    

    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = friendSuggestionController.view.frame;
    frameOffscreen.origin.x -= 330;
    
    if (addedFriends) {
        [allFollowing addObjectsFromArray:addedFriends];
        NSLog(@"Friend Suggestion resulted in %d added friends, now following %d people", [addedFriends count], [allFollowing count]);
        
        for (NSString * name in addedFriends) {
            [k addFollowerWithUsername:[self getUsername] andFollowsUser:name];
        }
    }
    
    [animation doViewTransition:friendSuggestionController.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [friendSuggestionController.view removeFromSuperview];

        isShowingFriendSuggestions = NO;
        // check for first time user experience
        if (!didStartFirstTimeMessage) {
            if (notificationDeviceToken) {
                [self Parse_createSubscriptions];  
            }
            else {
                // try registering again
                //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];    
                // just wait
                NSLog(@"No device token yet!");
            }
            myUserInfo->firstTimeUserStage = FIRSTTIME_MESSAGE_01;
            [tabBarController displayFirstTimeUserProgress:myUserInfo->firstTimeUserStage];    
            didStartFirstTimeMessage = YES;
        }
    }];
    
    // start first time message if needed
    if (!didStartFirstTimeMessage) {
        [tabBarController displayFirstTimeUserProgress:myUserInfo->firstTimeUserStage];    
        didStartFirstTimeMessage = YES;
    }
    
    // at this time, friend list should have been updated
    // after adding users, then start aggregation
    //[self getFollowListsForAggregation:[self getUsername]];        
    [aggregator aggregateNewTagIDs];
}

#pragma mark twitter helper
/*
-(void)showTwitterDialog {
#if 0
    twitterDialog = [twitterHelper getTwitterDialog];
    
    CGRect frameOffscreen = CGRectMake(-320, STATUS_BAR_SHIFT, 320, 480);
    [self.tabBarController.view addSubview:twitterDialog.view];
    [twitterDialog.view setFrame:frameOffscreen];
    
    CGRect frameOnscreen = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:twitterDialog.view toFrame:frameOnscreen forTime:.5 withCompletion:^(BOOL finished){
    }];
#else
    // Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://getsharekit.com"];
	SHKItem *item = [SHKItem URL:url title:@"ShareKit is Awesome!"];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	[actionSheet showFromTabBar:(UITabBar*)tabBarController];
#endif
}
-(void)twitterDialogDidFinish {
    CGRect frameOffscreen = CGRectMake(-320, STATUS_BAR_SHIFT, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:profileController.view toFrame:frameOffscreen forTime:.5 withCompletion:^(BOOL finished) {
        [twitterDialog.view removeFromSuperview];
        twitterDialog = nil;
    }];
}
*/

// debug
-(void)adminUpdateAllStixCountsToZero {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSMutableDictionary * stix = [BadgeView InitializeFirstTimeUserStix];   
    NSMutableData * data = [KumulosData dictionaryToData:stix];
    [k adminAddStixToAllUsersWithStix:data];
    //[data autorelease]; // arc conversion
    //[stix autorelease]; // arc conversion
}

-(void)adminUpdateAllStixCountsToOne {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
   NSMutableDictionary * stix = [BadgeView generateOneOfEachStix]; 
    int ct = [[stix objectForKey:@"HEART"] intValue];
    NSLog(@"Heart: %d", ct);
    NSMutableData * data = [KumulosData dictionaryToData:stix];
    [k adminAddStixToAllUsersWithStix:data];
    //[data autorelease]; // arc conversion
    //[stix autorelease]; // arc conversion
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation adminAddStixToAllUsersDidCompleteWithResult:(NSNumber *)affectedRows {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self Parse_sendBadgedNotification:@"Ninja admin stix update" OfType:NB_UPDATECAROUSEL toChannel:@"" withTag:nil];
}

-(void)adminResetAllStixOrders {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"adminUpdateAllStixOrders" withParams:nil withCallback:nil withDelegate:self];
    //[[KumulosHelper sharedKumulosHelper] execute:@"adminUpdateAllStixOrders"];
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
        stix = [BadgeView InitializeFirstTimeUserStix];
        [allStix removeAllObjects];
        [allStix addEntriesFromDictionary:stix];
        //[stix autorelease];// arc conversion
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
    }
    else
        [self showAlertWithTitle:@"Wrong Password!" andMessage:@"You cannot access the super secret club." andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
}

-(void)didClickShowBuxPurchaseMenu {    
    NSString * metricName = @"MoreBuxMenuPressed";
    NSString * metricData = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
    [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:metricData andIntegerValue:0];
    
    [self didCloseBuxInstructions];
#if 0
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Buy more Bux" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"5 Bux for $0.99", @"15 Bux for $2.99", @"40 Bux for $4.99", @"80 Bux for $8.99", @"170 Bux for $19.99", @"475 Bux for $49.99", nil];
    actionSheet.tag = ACTIONSHEET_TAG_BUYBUX;
    [actionSheet showFromTabBar:tabBarController.tabBar];
    [actionSheet release];
#endif
    
    if (isShowingBuxPurchaseMenu)
        return;
    
    isShowingBuxPurchaseMenu = YES;
    
    CGRect frameInside = CGRectMake(16, 22+20, 289, 380);
    CGRect frameOutside = CGRectMake(16-320, 22+20, 289, 380);
    buxPurchaseMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stixster_shop.png"]];
    [buxPurchaseMenu setFrame:frameOutside];
    [buxPurchaseMenu setBackgroundColor:[UIColor clearColor]];
    
    buxPurchaseButtons = [[NSMutableArray alloc] init];
    
    for (int i=0; i<3; i++) {
        UIButton * buxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [buxButton setTag:i];
        [buxButton setFrame:CGRectMake(55, 120 + 80*i+20, 200, 60)];
        [buxButton setBackgroundColor:[UIColor clearColor]];
        [buxButton addTarget:self action:@selector(didClickPurchaseBuxButton:) forControlEvents:UIControlEventTouchUpInside];
        [buxPurchaseButtons addObject:buxButton];
    }
    
    buttonBuxPurchaseClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBuxPurchaseClose setFrame:CGRectMake(270-16, 60-22+20, 37, 39)];
    [buttonBuxPurchaseClose setBackgroundColor:[UIColor clearColor]];
    [buttonBuxPurchaseClose addTarget:self action:@selector(didCloseBuxPurchaseMenu) forControlEvents:UIControlEventTouchUpInside];

    [self.tabBarController.view addSubview:buxPurchaseMenu];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    [animation doViewTransition:buxPurchaseMenu toFrame:frameInside forTime:.5 withCompletion:^(BOOL finished){
        [self.window addSubview:[buxPurchaseButtons objectAtIndex:0]];
        [self.window addSubview:[buxPurchaseButtons objectAtIndex:1]];
        [self.window addSubview:[buxPurchaseButtons objectAtIndex:2]];
        [self.window addSubview:buttonBuxPurchaseClose];
    }];
}

-(void)didClickPurchaseBuxButton:(UIButton*)sender {
    if ([self getFirstTimeUserStage] < FIRSTTIME_DONE) {
        [tabBarController toggleFirstTimeInstructions:NO];
    }
    [self didCloseBuxPurchaseMenu];
    
    NSLog(@"Did click bux purchase button: %d", sender.tag);
    int values[3] = {50, 125, 200};
    buyBuxPurchaseAmount = values[sender.tag];
    NSString * title = @"Bux Purchase";
    NSString * message = [NSString stringWithFormat:@"Are you sure you want to purchase %d Bux?", buyBuxPurchaseAmount];
    [self showAlertWithTitle:title andMessage:message andButton:@"Cancel" andOtherButton:@"Make Purchase" andAlertType:ALERTVIEW_BUYBUX];
}

-(void)didCloseBuxPurchaseMenu {
    NSLog(@"Did click close bux menu");
    isShowingBuxPurchaseMenu = NO;
    //CGRect frameInside = CGRectMake(16, 22+20, 289, 380);
    CGRect frameOutside = CGRectMake(16-320, 22+20, 289, 380);
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    [animation doViewTransition:buxPurchaseMenu toFrame:frameOutside forTime:.5 withCompletion:^(BOOL finished){
        [buxPurchaseMenu removeFromSuperview];
        buxPurchaseMenu = nil;
        for (int i=0; i<3; i++) {
            UIButton * buxButton = [buxPurchaseButtons objectAtIndex:i];
            [buxButton removeFromSuperview];
        }
        [buttonBuxPurchaseClose removeFromSuperview];
    }];
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
/*
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
            [self showAlertWithTitle:title andMessage:message andButton:@"Cancel" andOtherButton:@"Make Purchase" andAlertType:ALERTVIEW_BUYBUX];
        }
    }
*/
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
    
    [self Parse_sendBadgedNotification:[NSString stringWithFormat:@"Your Bux have been incremented by %d", buxIncrement] OfType:NB_INCREMENTBUX toChannel:@"" withTag:nil];
}

-(void) getTagWithID:(int)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"GetTagWithID: %d", tagID);
    if ([allTagIDs objectForKey:[NSNumber numberWithInt:tagID]]) {
        Tag * tag = [allTagIDs objectForKey:[NSNumber numberWithInt:tagID]];
        NSMutableDictionary * dict = [Tag tagToDictionary:tag];
        [self processTagsWithIDRange:[[NSMutableArray alloc] initWithObjects:dict, nil]];
//        [feedController forceReloadWholeTableZOMG];
        return;
    }
    else
        [k getAllTagsWithIDRangeWithId_min:tagID-1 andId_max:tagID+1];
}

/***** Parse Notifications ****/
//-(void) Parse_unsubscribeFromAll {
-(void)Parse_createSubscriptions {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif
    
    //return;
    
    /*** Parse service ***/
#if 1
    NSLog(@"Parse_createsubscriptions: creating request");
    PFObject *testObject = [PFObject objectWithClassName:@"SubscriptionRequests"];
    [testObject setObject:myUserInfo_username forKey:@"username"];
    [testObject save];
#endif
    
    Parse_subscribedChannels = [[NSMutableSet alloc] init];
    /*
    [PFPush getSubscribedChannelsInBackgroundWithBlock:^(NSSet *channels, NSError *error) {
        NSEnumerator * e = [channels objectEnumerator];
        id element;
        NSMutableString * channelsString = [[NSMutableString alloc] initWithString:@"Parse: unsubscribing this device from: "];
        while (element = [e nextObject]) {
            // add subscribed channels to array
            [Parse_subscribedChannels addObject:element];
        }
     */
        NSError * err = nil;
        //dispatch_async(backgroundQueue, ^{
    NSLog(@"Parse_createsubscriptions: starting createsubscriptions");
            [self Parse_subscribeToChannel:@""];
        //});
        if ([self getUsername] != nil && ![[self getUsername] isEqualToString:@"anonymous"])
        {
            // a To channel is where people send messages to
            NSString * channelString = [NSString stringWithFormat:@"To%d", myUserInfo->userID];
#if 1
            [self Parse_subscribeToChannel:channelString]; // subscribe to my channel
#else
            NSLog(@"Trying to subscribe to %@", channelString);
            [PFPush subscribeToChannelInBackground:channelString block:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    // display channels
                    [PFPush getSubscribedChannelsInBackgroundWithBlock:^(NSSet *channels, NSError *error) {
                        NSEnumerator * e = [channels objectEnumerator];
                        id element;
                        NSMutableString * channelsString = [[NSMutableString alloc] initWithString:@"Parse: subscribing this device to: "];
                        while (element = [e nextObject]) {
                            [channelsString appendString:element];
                            [channelsString appendString:@" "];
                        }
                        if (error)
                            NSLog(@"%@ with error: %@", channelsString, [error description]);
                        else {
                            NSLog(@"%@", channelsString);
                        }
                        //[channelsString autorelease]; // arc conversion
                    }];
                }
                else
                    NSLog(@"Subscribing to channel: %@ returning with errors: %@", channel_, [error description]);
            }];
#endif
            
            // broadcast to everyone that you are online
            //[self Parse_sendBadgedNotification:[self getUsername] OfType:NB_ONLINE toChannel:@"" withTag:nil];
        } // if ([self username] !isEqualTo:@"anonymous")..
    //}]; // subscribe in background
}
-(void) Parse_subscribeToChannel:(NSString*) channel {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSString * channel_ = [channel stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSLog(@"Parse: subscribing to channel <%@>", channel_);
    [PFPush subscribeToChannelInBackground:channel_ block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Parse: Subscribed to channel <%@>", channel_);
            [Parse_subscribedChannels addObject:channel];
            PFObject *testObject = [PFObject objectWithClassName:@"SubscriptionSuccess"];
            [testObject setObject:myUserInfo_username forKey:@"username"];
            [testObject save];
        }
        else {
            NSLog(@"Parse: Could not subscribe to <%@>: error %@", channel_, [error localizedDescription]);
            PFObject *testObject = [PFObject objectWithClassName:@"SubscriptionFailure"];
            [testObject setObject:myUserInfo_username forKey:@"username"];
            [testObject save];
        }
    }];
}

-(void) Parse_unsubscribeFromChannel:(NSString*)channel {
    NSString * channel_ = [channel stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSLog(@"Parse: unsubscribing from channel <%@>", channel_);
    [PFPush unsubscribeFromChannelInBackground:channel_ block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Parse: Unsubscribed from channel <%@>", channel_);
            [Parse_subscribedChannels removeObject:channel];
        }
        else
            NSLog(@"Parse: Could not unsubscribe to <%@>: error %@", channel_, [error localizedDescription]);
    }];
}

-(void) Parse_sendBadgedNotification:(NSString*)message OfType:(int)type toChannel:(NSString*) channel withTag:(NSNumber*)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSString * channel_ = [channel stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Parse: sending notification to channel <%@> with message: %@", channel_, message);

    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (type == NB_NEWGIFT || type == NB_NEWCOMMENT || type == NB_NEWSTIX || type == NB_INCREMENTBUX || type == NB_NEWFOLLOWER || type == NB_NEWPIX)
        [data setObject:message forKey:@"alert"];
    [data setObject:myUserInfo_username forKey:@"sender"];
    //[data setObject:[NSNumber numberWithInt:0] forKey:@"badge"];
    [data setObject:[NSNumber numberWithInt:type] forKey:@"nbType"]; //notificationBookmarkType
    [data setObject:message forKey:@"message"];
    [data setObject:channel_ forKey:@"channel"];
    if (tagID != nil)
        [data setObject:tagID forKey:@"tagID"];
//    if (giftStixStringID != nil)
//        [data setObject:giftStixStringID forKey:@"giftStixStringID"];
    [PFPush sendPushDataToChannelInBackground:channel_ withData:data];
}

-(void) Parse_sendNotificationToFollowers:(NSString*)message ofType:(int)type withTag:(NSNumber*)tagID {
    NSMutableSet * followers = [self getFollowerList]; 
    NSMutableArray * channels = [[NSMutableArray alloc] init];
    
    for (NSString * name in followers) {
        NSString *channel = [NSString stringWithFormat:@"To%d", [[allUserIDs objectForKey:name] intValue]];//[[ name componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ]];
        NSLog(@"Adding channel %@ for follower %@", channel, name); 
        [channels addObject:channel];
    }
    NSLog(@"Parse: sending notification to %d channels with message: %@", [channels count], message);

    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (type == NB_NEWCOMMENT || type == NB_NEWFOLLOWER || type == NB_NEWPIX)
        [data setObject:message forKey:@"alert"];
    [data setObject:myUserInfo_username forKey:@"sender"];
    [data setObject:[NSNumber numberWithInt:type] forKey:@"nbType"]; //notificationBookmarkType
    [data setObject:message forKey:@"message"];
    if (tagID != nil)
        [data setObject:tagID forKey:@"tagID"];    

    PFPush *push = [[PFPush alloc] init];
    [push setChannels:channels];
    [push setPushToAndroid:false];
    [push expireAfterTimeInterval:86400];
    [push setData:data];
    NSError * err;
    [push sendPush:&err];
    if (err)
        NSLog(@"Parse: send to followers with error: %@", [err description]);
}

- (void)application:(UIApplication *)application 
didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if 1
    [PFPush handlePush:userInfo];
#else
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // debug - display userInfo
    NSLog(@"%@", userInfo);
    //NSDictionary * aps = [userInfo objectForKey:@"aps"]; 
    notificationBookmarkType = [[userInfo objectForKey:@"nbType"] intValue];
    // todo: client should track badge counts and set them this way:
    //[UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;

    NSEnumerator * e = [userInfo keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        NSLog(@"Key: %@", key);
    }
    bool doAlert = NO;
#if 1
    notificationTagID = [userInfo objectForKey:@"tagID"];
    if (notificationBookmarkType == NB_NEWSTIX || notificationBookmarkType == NB_NEWCOMMENT) 
        doAlert = YES;
    if (notificationBookmarkType == NB_NEWPIX && 
        (![[userInfo objectForKey:@"sender"] isEqualToString:myUserInfo_username])) 
    {
        // get friend status
        if ([self isFollowing:[userInfo objectForKey:@"sender"]])
            doAlert = YES;
        else {
            doAlert = NO;
        }
    }
#else
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
        /*
        case NB_NEWGIFT:
        {
            notificationTagID = -1;
            notificationGiftStixStringID = [[userInfo objectForKey:@"giftStixStringID"] copy];
            doAlert = YES;
            break;
        }
         */
            
        case NB_PEELACTION:
        {
            // a general tag update - either a stix was peeled or attached, or a stix or comment was added to a tag but not the user's tag
            notificationTagID = [[userInfo objectForKey:@"tagID"] intValue];
        }
            
        case NB_UPDATECAROUSEL:
        {
            notificationTagID = -1;
        }
            break;
            
        case NB_INCREMENTBUX: 
        {
            notificationTagID = -1;
            doAlert = NO; // do not show general alert - go to bookmark jump
        }
            break;
         
        case NB_NEWPIX: 
        {
            notificationTagID = [[userInfo objectForKey:@"tagID"] intValue];
            doAlert = YES;
        }
            break;
        case NB_ONLINE: 
        {
            // broadcast that a person is online
            notificationTagID = -1;
            doAlert = NO;
        }
            break;
        case NB_ONLINEREPLY: 
        {
            // broadcast that a person is online
            notificationTagID = -1;
            doAlert = NO;
        }
            break;
        default:
            break;
    }
#endif

    notificationTargetChannel = [[userInfo objectForKey:@"channel"] copy];
    NSString * message = [userInfo objectForKey:@"message"]; // get alert message
    NSLog(@"Message %@ for channel <%@>", message, notificationTargetChannel);

    if ( application.applicationState == UIApplicationStateActive && doAlert) {
        // app was already in the foreground
        if ([notificationTargetChannel isEqualToString:[[self getUsername] stringByReplacingOccurrencesOfString:@" " withString:@""]] || [notificationTargetChannel isEqualToString:@""]) {
            // if target channel is Broadcast or this user
            // create something that will parse and jump to the correct tag
            [self showAlertWithTitle:@"Stix Alert" andMessage:message andButton:@"Close" andOtherButton:@"View" andAlertType:ALERTVIEW_NOTIFICATION];
        }
    }
    else {
        // app was just brought from background to foreground due to clicking
        // because the user clicked, we treat the behavior same as "View" 
        // the target channel in this case must have been broadcast or self
        [self handleNotificationBookmarks:YES withMessage:message];
    }
#endif
}

-(void)handleNotificationBookmarks:(bool)doJump withMessage:(NSString*)message{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (notificationTagID == nil) { //== -1) {
        if (notificationBookmarkType == NB_NEWFOLLOWER) {
            // only display message
            [self showAlertWithTitle:@"Stix Notification" andMessage:message andButton:@"Close" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
            [k getFollowersOfUserWithFollowsUser:[self getUsername]]; // update own follower list
        }
        if (notificationBookmarkType == NB_INCREMENTBUX) {
            // only display message
            [self showAlertWithTitle:@"Stix Notification" andMessage:message andButton:@"Close" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
            [self updateBuxCountFromKumulos];
        }
        if (notificationBookmarkType == NB_UPDATECAROUSEL) {
            [k getUserStixWithUsername:myUserInfo_username];
            //doJump = NO;
        }
        /*
        if (notificationBookmarkType == NB_NEWGIFT) {
            if (doJump) {
                [tabBarController setSelectedIndex:3]; // go to mystixview
                NSString * message;
                if ([self getStixCount:notificationGiftStixStringID] == -1) {
                    message = [NSString stringWithFormat:@"You have received a %@ but you already have it permanently!", [BadgeView getStixDescriptorForStixStringID:notificationGiftStixStringID]];
                }
                else
                {
                    message = [NSString stringWithFormat:@"You have received a gift of %@.", [BadgeView getStixDescriptorForStixStringID:notificationGiftStixStringID]];
                    [self reloadAllCarousels];
               }
                [self showAlertWithTitle:@"New Stix" andMessage:message andButton:@"Close" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
            }
        }
         */
        if (notificationBookmarkType == NB_ONLINE && ![message isEqualToString:[self getUsername]]) {
            NSString * onlineUser = message;                
            NSLog(@"%@ just came online!", onlineUser);
            if ([self isFollowing:onlineUser]) {
                NSString * channel = [NSString stringWithFormat:@"From%@", onlineUser];
                NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
                [self Parse_subscribeToChannel:channel];
            }
            
            // send notification right back in case that person is a subscriber
            NSString * channel = [NSString stringWithFormat:@"To%d", [[allUserIDs objectForKey:onlineUser] intValue]];//onlineUser] stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
            channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
            NSLog(@"Replying to online notice to channel %@", channel);
            [self Parse_sendBadgedNotification:[self getUsername] OfType:NB_ONLINEREPLY toChannel:channel withTag:nil];
        }
        if (notificationBookmarkType == NB_ONLINEREPLY) {
            NSString * onlineUser = message;
            NSLog(@"%@ just replied that they are online!", onlineUser);
            if ([self isFollowing:onlineUser]) {
                NSString * channel = [NSString stringWithFormat:@"From%@", onlineUser];
                NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
                [self Parse_subscribeToChannel:channel];
            }
        }
    }
    else {
        BOOL doUpdateTag = YES;
        if (notificationBookmarkType == NB_PEELACTION) {
            // either sent globally, or a peel action - does not require jump
            updatingNotifiedTagDoJump = NO;
            
            // if peel was on own stix, do not download it again
            Tag * tag = [allTagIDs objectForKey:notificationTagID];
            if (tag == nil) {
                // if tag is not in feed, ignore notification
                doUpdateTag = NO;
            }
            else { 
                if ([tag.username isEqualToString:[[self getUsername] stringByReplacingOccurrencesOfString:@" " withString:@""]]) {
                    // if tag belongs to self, do not update it
                    doUpdateTag = NO;
                }
            }
        } else if (notificationBookmarkType == NB_NEWPIX) {
            // user should be prompted to jump to new pix
            updatingNotifiedTagDoJump = YES;
            doUpdateTag = YES;
            NSLog(@"Handling notification NB_NEWPIX for tagID %d", [notificationTagID intValue]);
        } else if (![notificationTargetChannel isEqualToString:[[self getUsername] stringByReplacingOccurrencesOfString:@" " withString:@""]]) {
            // notification to target that is not the current user
            updatingNotifiedTagDoJump = NO; // does it ever go here?
            doUpdateTag = NO;
        }
        else {
            updatingNotifiedTagDoJump = doJump;
            doUpdateTag = YES;
        }
        isUpdatingNotifiedTag = YES;
        if (doUpdateTag)
#if 0
            [k getAllTagsWithIDRangeWithId_min:[notificationTagID intValue]-1 andId_max:[notificationTagID intValue]+1];
#else
            [self getTagWithID:[notificationTagID intValue]];
#endif
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
    [self showAllAlerts];
}

static bool isShowingAlerts = NO;
-(void)showAllAlerts {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (isShowingAlerts == YES)
        return;
    UIAlertView * firstAlert = [alertQueue objectAtIndex:0];
    [alertQueue removeObjectAtIndex:0];
    alertActionCurrent = [[alertAction objectAtIndex:0] intValue];
    [alertAction removeObjectAtIndex:0];
    [firstAlert show];
    isShowingAlerts = YES;
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
    UIAlertView * nextAlert = [alertQueue objectAtIndex:0];
    [alertQueue removeObjectAtIndex:0];
    [nextAlert show];
    isShowingAlerts = YES;
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
    [allStix setObject:[NSNumber numberWithInt:-1] forKey:stixStringID]; 
    if ([allStixOrder valueForKey:stixStringID] == nil || [[allStixOrder valueForKey:stixStringID] intValue] == -1) {
        [allStixOrder setObject:[NSNumber numberWithInt:[allStixOrder count]] forKey:stixStringID];
    }
    [self reloadAllCarousels];
    NSMutableData * stixData = [KumulosData dictionaryToData:allStix];
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
    //[auxiliaryDict setObject:allFriends forKey:@"friendsList"];
    NSMutableData * newAuxData = [KumulosData dictionaryToData:auxiliaryDict];
       // MRC  
    [k updateAuxiliaryDataWithUsername:[self getUsername] andAuxiliaryData:newAuxData];
    
    [self changeBuxCountByAmount:-5];
    
    // metric
#if !USING_FLURRY
    NSString * metricName = @"GetStixFromStore";
    //NSString * metricData = [NSString stringWithFormat:@"User: %@ Stix: %@", [self getUsername], stixStringID];
    [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:stixStringID andIntegerValue:0];
#else
    [FlurryAnalytics logEvent:@"GetStixFromStore" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", stixStringID, @"stixStringID", nil]];
#endif
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

-(void)displayPurchasedBuxMessage:(int)buxPurchased {
    [self showAlertWithTitle:@"Thank you!" andMessage:[NSString stringWithFormat:@"You have received %d Bux. Have fun buying stickers!", buxPurchased] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    [self changeBuxCountByAmount:buxPurchased];
    if  (buxPurchased == 25) {
        NSString * metricName = @"ExpressBux";
        NSString * metricData = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
        [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:metricData andIntegerValue:buxPurchased];
    }
    else { 
        NSString * metricName = @"MoreBux";
        NSString * metricData = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
        [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:metricData andIntegerValue:buxPurchased];     
    }
}

-(void)didPurchaseBux:(int)buxPurchased {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [self didCloseBuxPurchaseMenu];
    
#if 1
    [self displayPurchasedBuxMessage:buxPurchased];
#else
    NSString * buxPurchaseObject = nil;
    if (buxPurchased == 50) {
        buxPurchaseObject = @"neroh.stix.bux.50";
    }
    else if (buxPurchased == 125) {
        buxPurchaseObject = @"neroh.stix.bux.125";
    }
    else if (buxPurchased == 200) {
        buxPurchaseObject = @"neroh.stix.bux.200";
    }

#if USING_MKSTOREKIT
    [[MKStoreManager sharedManager] buyFeature:buxPurchaseObject
                                    onComplete:^(NSString* purchasedFeature, NSData * data)
     {
         // provide your product to the user here.
         // if it's a subscription, allow user to use now.
         // remembering this purchase is taken care of by MKStoreKit.
         [self displayPurchasedBuxMessage:buxPurchased];

         // consume
         //[[MKStoreManager sharedManager] consumeProduct:buxPurchaseObject quantity:buxPurchased];
     }
     onCancelled:^
     {
         // User cancels the transaction, you can log this using any analytics software like Flurry.
         NSString * metricName = @"CancelledBux";
         NSString * metricData = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
         [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:metricData andIntegerValue:buxPurchased];     
     }];
    
#endif
    
#endif
}

-(void)getFollowListsWithoutAggregation:(NSString*)name {
    // called if we only want the friend list
    // called by FriendSuggestionController - if logging in for the first time
    // friend list is needed by the suggestion controller, but
    // we don't want to start aggregating yet because we don't know
    // if the friend list will change after the controller closes
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:name, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"getFollowList" withParams:params withCallback:@selector(khCallback_didGetFollowList:) withDelegate:self];
    NSMutableArray * params2 = [[NSMutableArray alloc] initWithObjects:name, nil];
    KumulosHelper * kh2 = [[KumulosHelper alloc] init];
    [kh2 execute:@"getFollowersOfUser" withParams:params2 withCallback:@selector(khCallback_didGetFollowers:) withDelegate:self];
}

-(void)getFollowListsForAggregation:(NSString*)name {
    // called if we do not show the suggest friends page
    // get follows list, immediately start aggregation
    
    //[k getFollowListWithUsername:name];
    //[k getFollowersOfUserWithFollowsUser:name];
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:name, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"getFollowList" withParams:params withCallback:@selector(khCallback_didGetFollowListWithAggregation:) withDelegate:self];
    NSMutableArray * params2 = [[NSMutableArray alloc] initWithObjects:name, nil];
    KumulosHelper * kh2 = [[KumulosHelper alloc] init];
    [kh2 execute:@"getFollowersOfUser" withParams:params2 withCallback:@selector(khCallback_didGetFollowers:) withDelegate:self];
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFollowListDidCompleteWithResult:(NSArray *)theResults {
-(void)khCallback_didGetFollowList:(NSArray*)returnParams {
    NSArray * theResults = returnParams; // objectAtIndex:0];
    // list of people this user is following
    // key: username value: friendName
    [allFollowing removeAllObjects];
    for (NSMutableDictionary * d in theResults) {
        NSString * friendName = [d valueForKey:@"followsUser"];
        if (![allFollowing containsObject:friendName] && ![friendName isEqualToString:[self getUsername]]) {
            //NSLog(@"allFollowing adding %@", friendName);
            [allFollowing addObject:friendName];
        }
    }
    
    // cache followers
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData * followingData = [NSKeyedArchiver archivedDataWithRootObject:allFollowing];
    [defaults setObject:followingData forKey:@"allFollowing"];
    [defaults synchronize];
    [profileController updateFollowCounts];
    NSLog(@"Get follow list returned: %@ is following %d people", [self getUsername], [allFollowing count]);
    
    // only initialize friend controller after we have followList
    [self initializeFriendSuggestionController];
}

-(void)khCallback_didGetFollowListWithAggregation:(NSArray*)returnParams {
    NSArray * theResults = returnParams; // objectAtIndex:0];
    // list of people this user is following
    // key: username value: friendName
    [allFollowing removeAllObjects];
    for (NSMutableDictionary * d in theResults) {
        NSString * friendName = [d valueForKey:@"followsUser"];
        if (![allFollowing containsObject:friendName] && ![friendName isEqualToString:[self getUsername]]) {
            //NSLog(@"allFollowing adding %@", friendName);
            [allFollowing addObject:friendName];
        }
    }
    
    // cache followers
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData * followingData = [NSKeyedArchiver archivedDataWithRootObject:allFollowing];
    [defaults setObject:followingData forKey:@"allFollowing"];
    [defaults synchronize];
    [profileController updateFollowCounts];
    NSLog(@"Get follow list returned: %@ is following %d people", [self getUsername], [allFollowing count]);
    
    // AGGREGATE FOR THE FIRST TIME HERE 
    [aggregator aggregateNewTagIDs];
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFollowersOfUserDidCompleteWithResult:(NSArray *)theResults {
-(void)khCallback_didGetFollowers:(NSArray*)returnParams {
    NSArray * theResults = returnParams; // objectAtIndex:0];
    // list of people who follow this user
    // key: friendName value: username
    [allFollowers removeAllObjects];
    for (NSMutableDictionary * d in theResults) {
        NSString * friendName = [d valueForKey:@"username"];
        if (![allFollowers containsObject:friendName] && ![friendName isEqualToString:[self getUsername]])
            [allFollowers addObject:friendName];
    }
    // cache followers
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData * followerData = [NSKeyedArchiver archivedDataWithRootObject:allFollowers];
    [defaults setObject:followerData forKey:@"allFollowers"];
    [defaults synchronize];
    [profileController updateFollowCounts];
    NSLog(@"Get followers returned: %@ has %d followers", [self getUsername], [allFollowers count]);    
}


#pragma mark first time user stuff

-(int)getFirstTimeUserStage {
    return myUserInfo->firstTimeUserStage;
}
-(void)hideFirstTimeUserMessage {
    [tabBarController toggleFirstTimePointer:NO atStage:myUserInfo->firstTimeUserStage];
    [tabBarController toggleFirstTimeInstructions:NO];
}
-(void)agitateFirstTimePointer {
    [tabBarController agitateFirstTimePointer];
}
-(void)advanceFirstTimeUserMessage {
    myUserInfo->firstTimeUserStage++;
    [tabBarController displayFirstTimeUserProgress:myUserInfo->firstTimeUserStage];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:myUserInfo->firstTimeUserStage forKey:@"firstTimeUserStage"];
    [defaults synchronize];
}

#pragma mark share pix sheet

-(void)didDisplayShareSheet {
    isDisplayingShareSheet = YES;
}
-(BOOL)isDisplayingShareSheet {
    return isDisplayingShareSheet;
}
-(void)didCloseShareSheet {
    isDisplayingShareSheet = NO;
}

#pragma mark bux instructions

-(BOOL)isShowingBuxInstructions {
    return isShowingBuxInstructions || isShowingBuxPurchaseMenu;
}

-(void)didCloseBuxInstructions {
    isShowingBuxInstructions = NO;
#if 0
    [buxInstructions removeFromSuperview];
    [buttonBuxStore removeFromSuperview];
    [buttonBuxInstructionsClose removeFromSuperview];
#else
    //CGRect frameInside = CGRectMake(16, 22+20, 289, 380);
    CGRect frameOutside = CGRectMake(16-320, 22+20, 289, 380);
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    //int buxAnimationClose = [animation doSlide:buxInstructions inView:self.tabBarController.view toFrame:frameOutside forTime:.5];
    [animation doViewTransition:buxInstructions toFrame:frameOutside forTime:.5 withCompletion:^(BOOL finished) {
        [buxInstructions removeFromSuperview];
        [buttonBuxStore removeFromSuperview];
        [buttonBuxInstructionsClose removeFromSuperview];
    }];
#endif
}

-(void)didShowBuxInstructions {
    if ([self getFirstTimeUserStage] < FIRSTTIME_DONE) {
        [self agitateFirstTimePointer];
        return;
    }
    if ([self isDisplayingShareSheet])
        return;
    
    if ([self isShowingBuxInstructions])
        return;
    
    isShowingBuxInstructions = YES;
    CGRect frameInside = CGRectMake(16, 22+20, 289, 380);
    CGRect frameOutside = CGRectMake(16-320, 22+20, 289, 380);
    buxInstructions = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bux_rewards.png"]];
    [buxInstructions setFrame:frameOutside];
    /*
    buttonBuxStore = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBuxStore setFrame:CGRectMake(68-10, 300, 200, 60)];
    [buttonBuxStore setBackgroundColor:[UIColor clearColor]];
    [buttonBuxStore addTarget:self action:@selector(didClickShowBuxPurchaseMenu) forControlEvents:UIControlEventTouchUpInside];
     */
    buttonBuxInstructionsClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBuxInstructionsClose setFrame:CGRectMake(270-6, 60-12, 37, 39)];
    [buttonBuxInstructionsClose setBackgroundColor:[UIColor clearColor]];
    [buttonBuxInstructionsClose addTarget:self action:@selector(didCloseBuxInstructions) forControlEvents:UIControlEventTouchUpInside];
    //    [buxInstructions addSubview:buttonBuxStore];
    //    [buxInstructions addSubview:buttonBuxInstructionsClose];
    [self.tabBarController.view addSubview:buxInstructions];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    //int buxAnimationOpen = [animation doSlide:buxInstructions inView:self.tabBarController.view toFrame:frameInside forTime:.5];
    [animation doViewTransition:buxInstructions toFrame:frameInside forTime:.5 withCompletion:^(BOOL finished) {
        // bux purchase menu
            //[self.tabBarController.view addSubview:buttonBuxStore];
            [self.tabBarController.view addSubview:buttonBuxInstructionsClose];   
    }];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPremiumPacksDidCompleteWithResult:(NSArray *)theResults {
    for (NSMutableDictionary * d in theResults) {
        NSString * stixPackName = [d objectForKey:@"stixPackName"];
        
        NSMutableArray * stixArray = [BadgeView getStixForCategory:stixPackName];
        for (int i=0; i<[stixArray count]; i++) {
            NSString * stixStringID = [stixArray objectAtIndex:i];
            [allStix setObject:[NSNumber numberWithInt:-1] forKey:stixStringID]; 
        }
        
        [[CarouselView sharedCarouselView] unlockPremiumPack:stixPackName];
    }
}

-(BOOL)shouldPurchasePremiumPack:(NSString *)stixPackName {
    NSLog(@"Did purchase premium pack: %@", stixPackName);
    
#if 0 // beta
    // add purchase to kumulos
    [k didPurchasePremiumPackWithUsername:myUserInfo_username andStixPackName:stixPackName];
    
    // force carouselview to update
    [[CarouselView sharedCarouselView] unlockPremiumPack:stixPackName];
    
    // animate
    NSString *firstChar = [stixPackName substringToIndex:1];
    NSString * stixPack = [[firstChar uppercaseString] stringByAppendingString:[stixPackName substringFromIndex:1]];
    [tabBarController doPremiumPurchaseAnimation:stixPack]; 

    // metrics
    NSString * metricName = @"PremiumPurchase";
    [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:stixPack andIntegerValue:0];     
    
    return YES;
#else
    
#if USING_MKSTOREKIT
    NSString * purchaseID = @"collection.Hipster";
    mkStoreKitSuccess = NO;
    [[MKStoreManager sharedManager] buyFeature:purchaseID
                                    onComplete:^(NSString* purchasedFeature, NSData * data)
     {
         // provide your product to the user here.
         // if it's a subscription, allow user to use now.
         // remembering this purchase is taken care of by MKStoreKit.
         // add purchase to kumulos
         [k didPurchasePremiumPackWithUsername:myUserInfo_username andStixPackName:stixPackName];
         
         // force carouselview to update
         [[CarouselView sharedCarouselView] unlockPremiumPack:stixPackName];
         
         // animate
         NSString *firstChar = [stixPackName substringToIndex:1];
         NSString * stixPack = [[firstChar uppercaseString] stringByAppendingString:[stixPackName substringFromIndex:1]];
         [tabBarController doPremiumPurchaseAnimation:stixPack]; 

         // metrics
#if !USING_FLURRY
         NSString * metricName = @"PremiumPurchase";
         [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:stixPack andIntegerValue:0];     
#else
         [FlurryAnalytics logEvent:@"PremiumPurchase" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", stixPack, @"stixPack", nil]];
#endif
         mkStoreKitSuccess = YES;
     }
                                    onCancelled:^
     {
         // User cancels the transaction, you can log this using any analytics software like Flurry.
#if !USING_FLURRY
         NSString * metricName = @"CancelledPurchase";
         NSString * firstChar = [stixPackName substringToIndex:1];
         NSString * metricData = [[firstChar uppercaseString] stringByAppendingString:[stixPackName substringFromIndex:1]];
         [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:metricData andIntegerValue:0];     
#else
         [FlurryAnalytics logEvent:@"CancelledPurchase" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", stixPackName, @"stixPack", nil]];
#endif
         mkStoreKitSuccess = NO;
     }];
    return mkStoreKitSuccess;
#endif

#endif
}
@end
