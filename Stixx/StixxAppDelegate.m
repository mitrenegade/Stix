
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
@synthesize newsController;
@synthesize friendSuggestionController;
@synthesize myUserInfo;
@synthesize lastViewController;
@synthesize allTags, allTagIDs;
@synthesize timeStampOfMostRecentTag;
@synthesize allUserPhotos;
@synthesize allUserFacebookStrings, allUserEmails, allUserNames, allUserIDs;
@synthesize allUserTwitterStrings;
@synthesize allStix;
@synthesize allStixOrder;
@synthesize allFollowers, allFollowing;
@synthesize k;
@synthesize allCommentCounts;
@synthesize loadingMessage;
@synthesize alertQueue;
@synthesize metricLogonTime;
@synthesize lastKumulosErrorTimestamp;
@synthesize allCommentHistories;
@synthesize editorController;
@synthesize featuredUsers;
@synthesize tagToRemix;

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
    versionStringStable = @"1.0"; // must change this on next release
    versionStringStable = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
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

    notificationDeviceToken = nil;
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];    
    
    /*** sharekit ***/
    // configuring sharekit so both sharekit and twitter connect can work
    DefaultSHKConfigurator *configurator = [[MySHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    [[StixPanelView sharedStixPanelView] setDelegatePurchase:self];

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
    
    allTags = [[NSMutableArray alloc] init];
    allTagIDs = [[NSMutableDictionary alloc] init];
    allUserPhotos = [[NSMutableDictionary alloc] init];
    allStix = [[NSMutableDictionary alloc] init];
    allStixOrder = [[NSMutableDictionary alloc] init];
    //allFriends = [[NSMutableSet alloc] init];
    allFollowing = [[NSMutableSet alloc] init];
    allFollowers = [[NSMutableSet alloc] init];
    allUserFacebookStrings = [[NSMutableArray alloc] init];
    allUserTwitterStrings = [[NSMutableArray alloc] init];
    allUserIDs = [[NSMutableDictionary alloc] init];
    allUserEmails = [[NSMutableArray alloc] init];
    allUserNames = [[NSMutableArray alloc] init];
    allCommentCounts = [[NSMutableDictionary alloc] init];
    allCommentHistories = [[NSMutableDictionary alloc] init];
    
    myUserInfo = malloc(sizeof(struct UserInfo));
    myUserInfo_username = nil;
    myUserInfo_userphoto = nil;
    myUserInfo_email = nil;
    myUserInfo_facebookString = @"0";
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
    
    [Crashlytics startWithAPIKey:@"747b4305662b69b595ac36f88f9c2abe54885ba3"];

    /***** create first view controller: the TagViewController *****/
    [loadingMessage setText:@"Initializing camera..."];
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
    // create an empty main controller in order to turn on camera
    //rootController = [[UIViewController alloc] init];
    //[window addSubview:rootController.view];

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
    // Login process - first load cached user info from defaults
#if 0 && ADMIN_TESTING_MODE
    loggedIn = NO;
    //[TwitterHelper logout];
//    [k loginViaTwitterWithUsername:@"Bobby Ren" andScreenname:@"hackstarbobo" andTwitterString:@""];
//    [k getAllUsers];
#else
    loggedIn = [self loadUserInfoFromDefaults];
#endif
    isLoggingIn = NO;
    if (loggedIn) {
        NSLog(@"Loggin in as %@", myUserInfo_username);
        
        // preemptively do user login things
        [self didLoginWithUsername:myUserInfo_username andPhoto:myUserInfo_userphoto andEmail:myUserInfo_email andFacebookString:myUserInfo_facebookString andTwitterString:myUserInfo_twitterString andUserID:[NSNumber numberWithInt:myUserInfo->userID]];
        
        // create shareController, share and connected lists for each service, and loads from default
        //[self initializeShareController];
        
        [self getFollowListsForAggregation:[self getUsername]];
        didGetFollowingLists = YES;
        if (myUserInfo_facebookString != 0) {
            // logged in but still need facebook info
            [self doFacebookLogin];
        }
    }
    else if (![fbHelper facebookHasSession] || !loggedIn) // !myUserInfo_username || [myUserInfo_username length] == 0)
    {
        NSLog(@"Could not log in: forcing new login screen!");
        isLoggingIn = YES;
        loggedIn = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
#if 0
        loginSplashController = [[FacebookLoginController alloc] init];
        [loginSplashController setDelegate:self];
        nav = [[UINavigationController alloc] initWithRootViewController:loginSplashController];
#else
        previewController = [[PreviewController alloc] init];
        [previewController setDelegate:self];
        nav = [[UINavigationController alloc] initWithRootViewController:previewController];
#endif
        nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar"] forBarMetrics:UIBarMetricsDefault];
        [window addSubview:nav.view];
/*
        UINavigationController * loginNav = [[UINavigationController alloc] initWithRootViewController:loginSplashController];
        loginNav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        [loginNav.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar"] forBarMetrics:UIBarMetricsDefault];
        [tabBarController presentModalViewController:loginNav animated:YES];
 */
    }
    return YES;
}

-(void) continueInit {
    
    if (nav) {
        [nav.view removeFromSuperview];
        nav = nil;
    }
    
	tabBarController = [[RaisedCenterTabBarController alloc] init];
    tabBarController.myDelegate = self;
    
  	tagViewController = [[TagViewController alloc] init];
	tagViewController.delegate = self;
    //[window addSubview:tagViewController.view];
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
    // get newest tag on server regardless of who is logged in
    // when login completes, feed will filter 
    //[self getFirstTags];
    // show activity indicator
    [feedController startActivityIndicatorLarge];
    
    /***** create explore view *****/
    exploreController = [[ExploreViewController alloc] init];
    exploreController.delegate = self;
	
    [self checkForUpdatePhotos];
    
    /***** create news feed *****/
    // show newsfeed, for now
    newsController = [[NewsletterViewController alloc] init];
    [newsController setDelegate:self];
    
	/***** create profile view *****/
	profileController = [[ProfileViewController alloc] init];
    profileController.delegate = self;
    
    /***** add view controllers to tab controller, and add tab to window *****/
    emptyViewController = [[UIViewController alloc] init];
	NSArray * viewControllers = [NSArray arrayWithObjects: feedController,  exploreController, emptyViewController, newsController, profileController, nil];
    [tabBarController setViewControllers:viewControllers];
	[tabBarController setDelegate:self];
    [exploreController setTabBarController:tabBarController];
    
    friendSuggestionController = [[FriendSuggestionController alloc] init];
    [friendSuggestionController setDelegate:self];
    
    lastViewController = feedController;
    
    [tabBarController initializeCustomButtons];

    [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
    nav = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar"] forBarMetrics:UIBarMetricsDefault];
    [window addSubview:nav.view];
    [nav.view setFrame:CGRectMake(0, 0, 320, 480+TABBAR_BUTTON_DIFF_PX)]; // forces bottom of tabbar to be 40 px

    [self loadCachedTags];    
    [self didPressTabButton:TABBAR_BUTTON_FEED];
    
    /*** twitter ***/
    /*
    twitterHelper = [TwitterHelper sharedTwitterHelper];
    [twitterHelper initTwitter];
//    [self showTwitterDialog];
    [twitterHelper requestTwitterPostPermission];
    */
    
    return YES;
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation loginViaTwitterDidCompleteWithResult:(NSArray *)theResults
{
    NSLog(@"Finished");
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults {
    NSLog(@"Finished");
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
            /* display versioning info */
            if (versionIsOutdated)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                int upgradeMessageCounter = [[defaults objectForKey:@"upgradeMessageCounter"] intValue];
                if (upgradeMessageCounter == 0) {
                    [self showAlertWithTitle:@"Update Available" andMessage:[NSString stringWithFormat:@"A newer version of Stix is available through App Store. Download now?", versionStringStable, currVersion] andButton:@"Later" andOtherButton:@"Go" andAlertType:ALERTVIEW_UPGRADE];
                }
                else {
                    upgradeMessageCounter = upgradeMessageCounter - 1;
                    [defaults setObject:[NSNumber numberWithInt:upgradeMessageCounter] forKey:@"upgradeMessageCounter"];
                    [defaults synchronize];
                }
            }
        }
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
#if 0 && ADMIN_TESTING_MODE
    [self showAlertWithTitle:@"Test" andMessage:@"Registered for remote notifications" andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
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
    [previewController startActivityIndicator];
    return [self.fbHelper handleOpenURL:url]; 
}

-(void)didLoginToFacebook:(NSDictionary *)results forShareOnly:(BOOL)gotTokenForShare {
    // didGetFacebookInfo, didFacebookLogin, didLoginToFacebook
    // come here after logging in to facebook
    isLoggingIn = NO;
    NSLog(@"Did get facebook info!");
    NSEnumerator *e = [results keyEnumerator];
    NSString * name = @"";
    NSString * email = @"";
    NSString * facebookString = @"0";
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
            facebookString = [results valueForKey:key];
        }
    }
    if (!gotTokenForShare) {
        NSLog(@"Delegate didLoginToFacebook for login! going back to loginSplashController");
//        if (loginSplashController)
//            [loginSplashController didGetFacebookName:name andEmail:email andFacebookString:facebookString];
        
        if (previewController) {
            [previewController didGetFacebookName:name andEmail:email andFacebookString:facebookString];
            // hack
//            loginSplashController = [[FacebookLoginController alloc] init];
//            [loginSplashController setDelegate:self];
//            [loginSplashController didGetFacebookName:name andEmail:email andFacebookString:facebookString];

        }
        else {
            NSLog(@"No previewController!");
        }
        // update facebookString on kumulos
        // only need to be done with shareController
        /*
        NSMutableDictionary * newUser = [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"username", email, @"email", facebookString, @"facebookString", nil];
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] init];
        [params addObject:newUser];
        [kh execute:@"setFacebookString" withParams:params withCallback:nil withDelegate:nil];
         */
    }
    else {
        // assume we only get here through facebook connecting in ShareController or FriendSearch
        // user is already logged in

        // update facebookString on kumulos
        NSLog(@"Delegate didLoginToFacebook for share token!");
        NSLog(@"Already logged in user: %@ %@ %@", myUserInfo_username, myUserInfo_email, facebookString);
        NSMutableDictionary * newUser = [NSMutableDictionary dictionaryWithObjectsAndKeys:myUserInfo_username, @"username", myUserInfo_email, @"email", facebookString, @"facebookString", nil];
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] init];
        [params addObject:newUser];
        [kh execute:@"setFacebookString" withParams:params withCallback:nil withDelegate:nil];

        // save facebook info
        myUserInfo_facebookString = facebookString;
    }

    [shareController didConnect:@"Facebook"];
    [profileController didConnectToFacebook];
}

-(void)didConnectToTwitter {
    [shareController didConnect:@"Twitter"];
}

-(void)didLoginToTwitter:(NSDictionary *)results forShareOnly:(BOOL)gotTokenForShare {
    NSLog(@"Did get twitter login info!");
    NSString * username = [results objectForKey:@"name"];
    NSString * screenname = [results objectForKey:@"screen_name"];
    NSString * twitterString = [results objectForKey:@"id_str"];
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

-(void)facebookRequestDidTimeOut {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Timeout" message:[NSString stringWithFormat:@"Facebook Login is unresponsive. Please try login again!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    if (isLoggingIn) {
        //[previewController shouldShowButtons];
        [nav popToRootViewControllerAnimated:YES];
    }
    else {
        [nav.view removeFromSuperview];
        nav = nil;
        if (!previewController) {
            previewController = [[PreviewController alloc] init];
            [previewController setDelegate:self];
        }
        nav = [[UINavigationController alloc] initWithRootViewController:previewController];
        nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar"] forBarMetrics:UIBarMetricsDefault];
        [window addSubview:nav.view];
    }
}

-(void)didLogoutFromFacebook {
    NSLog(@"Did logout from facebook");
    /*
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Logout Success" message:@"You have been logged out of facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
     */
}

-(void)didCancelFacebookLogin {
    [fbHelper facebookLogout]; 
    // force permissions to be reset?
    //[previewController shouldShowButtons];
    [shareController didCancelFacebookConnect];
    [profileController didCancelFacebookConnect];
}

-(void)initializeBadgesFromKumulos {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);a
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
    [defaults setObject:myUserInfo_facebookString forKey:@"facebookString"];
    [defaults setInteger:myUserInfo->userID forKey:@"userID"];
    [defaults setInteger:myUserInfo->hasPhoto forKey:@"hasPhoto"];
    NSLog(@"SaveUserInfo: userID %d name %@ facebookString %@", myUserInfo->userID, myUserInfo_username, myUserInfo_facebookString);
    NSData *userphoto = UIImagePNGRepresentation(myUserInfo_userphoto);
    [defaults setObject:userphoto forKey:@"userphoto"];
    [defaults setInteger:myUserInfo->firstTimeUserStage forKey:@"firstTimeUserStage"];
    
    // sharing
    // todo: save as member variables, not sharecontroller variables
    if (shareController) {
        [defaults setBool:[shareController shareServiceIsConnected:@"Facebook"] forKey:@"FacebookIsConnected"];
        [defaults setBool:[shareController shareServiceIsSharing:@"Facebook"] forKey:@"FacebookIsSharing"];
        [defaults setBool:[shareController shareServiceIsConnected:@"Twitter"] forKey:@"TwitterIsConnected"];
        [defaults setBool:[shareController shareServiceIsSharing:@"Twitter"] forKey:@"TwitterIsSharing"];
    }    
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
    myUserInfo_facebookString = [defaults objectForKey:@"facebookString"];
    myUserInfo->userID = [defaults integerForKey:@"userID"];
    myUserInfo->hasPhoto = [defaults integerForKey:@"hasPhoto"];
    NSData * userphoto = [defaults objectForKey:@"userphoto"];
    UIImage * newphoto = [UIImage imageWithData:userphoto];
    myUserInfo_userphoto = newphoto;
    myUserInfo->firstTimeUserStage = [defaults integerForKey:@"firstTimeUserStage"];
#if 1 && ADMIN_TESTING_MODE
    myUserInfo->firstTimeUserStage = FIRSTTIME_MESSAGE_01;
#endif
    
    NSLog(@"Loading cached user info for user: %@ email %@ facebook %@", myUserInfo_username, myUserInfo_email, myUserInfo_facebookString);
    
    // to invalidate twitter and force a new login each time:
    BOOL isConnected = NO;
    NSString * connectedString = @"TwitterIsConnected";
    NSString * sharingString = @"TwitterIsSharing";
    NSLog(@"According to defaults, Twitter is connected %@ is sharing %@", [defaults objectForKey:connectedString], [defaults objectForKey:sharingString]);
    if ([defaults objectForKey:connectedString]) {
        isConnected = [[defaults objectForKey:connectedString] boolValue];
    }
    if (!isConnected) {
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:connectedString];        // hack to test twitter
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"FacebookIsConnected"];        // hack to test twitter
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"FacebookIsSharing"];        // hack to test twitter
        [TwitterHelper logout];
    }
    
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
                   
    //[profileController didLogin]; 
    
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
        if (!stixDataVersionString) {
            NSLog(@"LoadStixDataFromDefaults: no stix data");
        }
        else if ([stixDataVersionString compare:@"0.9.6"] == NSOrderedAscending) {
            NSLog(@"LoadStixDataFromDefaults: old version");
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
    [tabBarController.navigationItem setLeftBarButtonItem:nil];
    [tabBarController.navigationItem setRightBarButtonItem:nil];
    
    // when center button is pressed, programmatically send the tab bar that command
    [tabBarController setHeaderForTab:pos];
    [tabBarController setSelectedIndex:pos];
    [tabBarController setButtonStateSelected:pos]; // highlight button
    if (pos == TABBAR_BUTTON_TAG) {
        if (lastViewController == tabBarController)
            return;
        lastViewController = tabBarController;
        [self shouldOpenTagView];
    }
    else if (pos == TABBAR_BUTTON_FEED) {
//        [exploreController didDismissZoom];
        lastViewController = feedController;

        // update feed with changes in friends
        if (followListsDidChangeDuringProfileView) {
            followListsDidChangeDuringProfileView = NO;
            [aggregator resetFirstTimeState];
            [aggregator reaggregateTagIDs];
            [feedController followListsDidChange]; // tell feedController to redisplay all users that are in the feed but were unfriended
            idOfOldestTagReceived = idOfNewestTagReceived;
            idOfNewestTagReceived = feedController.newestTagIDDisplayed; //-1;
        }

#if HAS_PROFILE_BUTTON
        if (!myUserInfo_userphoto) {
            UIImage * photo = [self getUserPhotoForUsername:[self getUsername]];
            [feedController.buttonProfile setImage:photo forState:UIControlStateNormal];
        } else {
            [feedController.buttonProfile setImage:myUserInfo_userphoto forState:UIControlStateNormal];
        }
        [feedController.buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [feedController.buttonProfile.layer setBorderWidth:1];
#endif
        // doing this will cause two arrows to be displayed
//        if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
//            [tabBarController toggleFirstTimePointer:YES atStage:FIRSTTIME_MESSAGE_02];
//        }
    }
    else if (pos == TABBAR_BUTTON_EXPLORE) {     
        lastViewController = exploreController;
#if SHOW_ARROW
        if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
            // force back to the feedview
            [tabBarController setSelectedIndex:TABBAR_BUTTON_FEED];
            [tabBarController setButtonStateSelected:TABBAR_BUTTON_FEED];
            [self agitateFirstTimePointer];
            return;
        }
#endif
    }
    else if (pos == TABBAR_BUTTON_PROFILE) {
        lastViewController = profileController;
#if SHOW_ARROW
        if ( (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_01 || myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02)) {
            [self agitateFirstTimePointer];
            return;
        }
#endif
        if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_03) {
            [self hideFirstTimeUserMessage];
            [self advanceFirstTimeUserMessage]; // must come after hide!
            //[profileController doPointerAnimation];
        }

        CGRect frame = CGRectMake(0, 0, 72, 31);
        UIButton * buttonFeedback = [[UIButton alloc] initWithFrame:frame];
        [buttonFeedback setImage:[UIImage imageNamed:@"nav_feedback"] forState:UIControlStateNormal];
        [buttonFeedback addTarget:self action:@selector(didClickFeedbackButton) forControlEvents:UIControlEventTouchDown];
        CGRect frame2 = CGRectMake(0, 0, 52, 31);
        UIButton * buttonAbout = [[UIButton alloc] initWithFrame:frame2];
        [buttonAbout setImage:[UIImage imageNamed:@"btn_about"] forState:UIControlStateNormal];
        [buttonAbout addTarget:self action:@selector(didClickAboutButton) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithCustomView:buttonFeedback];
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithCustomView:buttonAbout];
        [tabBarController.navigationItem setLeftBarButtonItem:leftButton];
        [tabBarController.navigationItem setRightBarButtonItem:rightButton];
    }
    else if (pos == TABBAR_BUTTON_NEWS) {
        lastViewController = newsController;
    }
}

-(void)didDismissSecondaryView {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (lastViewController == feedController) {
        [self didPressTabButton:TABBAR_BUTTON_FEED];
    }
    else if (lastViewController == exploreController) {
        [self didPressTabButton:TABBAR_BUTTON_EXPLORE];
    }
    else if (lastViewController == newsController) {
        [self didPressTabButton:TABBAR_BUTTON_NEWS];
    }
    else if (lastViewController == profileController) {
        [self didPressTabButton:TABBAR_BUTTON_PROFILE];
    }
    [nav popToViewController:tabBarController animated:YES];
    [nav.view setFrame:CGRectMake(0, 0, 320, 480+TABBAR_BUTTON_DIFF_PX)]; // forces bottom of tabbar to be 40 px
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
    
#if !USING_FLURRY
    [self setMetricLogonTime: [NSDate date]];
#else
    if (!IS_ADMIN_USER(myUserInfo_username))
        [FlurryAnalytics logEvent:@"TimeInApp" timed:YES];
#endif
    didGetFollowingLists = NO; // request update of following lists at some point
    
    [Appirater appEnteredForeground:YES];
    [feedController updateFeedTimestamps];
    
    [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
}

- (void)application:(UIApplication *)application 
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
#if ADMIN_TESTING_MODE
    [self showAlertWithTitle:@"Test" andMessage:[NSString stringWithFormat:@"failed to register: %@", [error description]] andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
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
            //[feedController reloadPage:i]; // will already be done because added=YES
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
            //[feedController reloadPage:i]; // will already be done since added = YES
            added = YES;
        }
        else {
            added = NO;
        }
    }
    return added;
}

#pragma mark tagview delegate
-(void)shouldOpenTagView {
#if SHOW_ARROW
    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
        // force back to the feedview
        [tabBarController setSelectedIndex:TABBAR_BUTTON_FEED];
        [tabBarController setButtonStateSelected:TABBAR_BUTTON_FEED];
        [self agitateFirstTimePointer];
        return;
    }
#endif
    
    [tagViewController startCamera];
    [nav pushViewController:tagViewController animated:NO];
    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_01) {
        [self hideFirstTimeUserMessage];
    }
}

-(void)didCloseTagView {
    [nav setNavigationBarHidden:NO];
    [tagViewController stopCamera];
    
    [nav.view setFrame:CGRectMake(0, 0, 320, 480+TABBAR_BUTTON_DIFF_PX)]; // forces bottom of tabbar to be 40 px
    if (lastViewController == feedController)
        [self didPressTabButton:TABBAR_BUTTON_FEED];
    else if (lastViewController == exploreController)
        [self didPressTabButton:TABBAR_BUTTON_EXPLORE];
    else if (lastViewController == newsController)
        [self didPressTabButton:TABBAR_BUTTON_NEWS];
    else if (lastViewController == profileController)
        [self didPressTabButton:TABBAR_BUTTON_PROFILE];
    else {
        [self didPressTabButton:TABBAR_BUTTON_FEED];
    }
}

-(void)didConfirmNewPix:(Tag*)newTag {
    NSLog(@"Did confirm new pix ***********************************");
    // user took a new picture - read to add stix
    
    [self shouldDisplayStixEditor:newTag withRemixMode:REMIX_MODE_NEWPIC];

    hasPendingStixLayerToUpload = NO;
    readyToUploadPendingStixLayer_tagID = -1;

    // preemptively add to feed
    if (1)
    {
        [feedController addTagForDisplay:newTag];
        [feedController didClickJumpButton:nil];
    }
    
    // upload to kumulos in order to create a record ID
    NSNumber * remixMode = [NSNumber numberWithInt:REMIX_MODE_NEWPIC];
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newTag, remixMode, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"createNewPix" withParams:params withCallback:@selector(khCallback_didCreateNewPix:) withDelegate:self];
    
}

#pragma mark StixEditor delegate
-(void)shouldDisplayStixEditor:(Tag*)newTag withRemixMode:(int)remixMode {
    // display stix editor
    NSLog(@"Displaying editor ***********************************" );
    editorController = [[StixEditorViewController alloc] init];
    [editorController setAppDelegate:self];
    [editorController setRemixTag:newTag];
    [editorController setRemixMode:remixMode];
    
    // must initialize after imageView and stixView actually exist
    [nav pushViewController:editorController animated:YES];
//    [editorController initializeWithTag:newTag remixMode:remixMode];
}
-(void) didFinishEditing {//didCloseEditor {
    [feedController stopActivityIndicatorLarge];
    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_03) {
        [tabBarController toggleFirstTimeInstructions:YES];
        [tabBarController toggleFirstTimePointer:YES atStage:myUserInfo->firstTimeUserStage];
    }
}
-(void) shouldCloseStixEditor {
    [nav popToViewController:tabBarController animated:YES];
    [nav.view setFrame:CGRectMake(0, 0, 320, 480+TABBAR_BUTTON_DIFF_PX)]; // forces bottom of tabbar to be 40 px
}

-(BOOL)canClickRemixButton {
#if SHOW_ARROW
    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
        return YES;
    }
    else if ( (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_01 || myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_03)) {
        [self agitateFirstTimePointer];
        return NO;
    }
#endif
    return YES;
}

-(BOOL)canClickNotesButton {
#if SHOW_ARROW
    if ( (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_01 || myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02 || myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_03)) {
        [self agitateFirstTimePointer];
        return NO;
    }
#endif
    return YES;
}


-(void)didRemixNewPix:(Tag *)cameraTag remixMode:(int)remixMode {
    
    // cameraTag should have a stixLayer saved already

    if (remixMode == REMIX_MODE_NEWPIC) {
        [cameraTag setOriginalUsername:cameraTag.username];
        // cameraTag has already been saved; just update the stixLayer
        // at this point tag doesn't have a tagID!
        // do not update stixlayer until a record id is created
        if (readyToUploadPendingStixLayer_tagID != -1) {
            //Tag * newTag = cameraTag; //.copy;
            NSLog(@"Finished remixing and tag was already uploaded. cameraTag: %@ readyToUploadTag: %d", cameraTag.tagID, readyToUploadPendingStixLayer_tagID);
            cameraTag.tagID = [NSNumber numberWithInt:readyToUploadPendingStixLayer_tagID];
            if (cameraTag.stixLayer) {
                NSData * stixLayerData = UIImagePNGRepresentation(cameraTag.stixLayer);
                NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:cameraTag, stixLayerData, nil];
                KumulosHelper * kh = [[KumulosHelper alloc] init];
                [kh execute:@"updateStixLayer" withParams:params withCallback:@selector(khCallback_didUpdateStixLayer:) withDelegate:self];
            }                
            // reload - force stixLayer to appear on feed
            [feedController reloadPageForTagID:readyToUploadPendingStixLayer_tagID];
            
            [self doParallelNewPixShare:cameraTag];
        }
        else {
            // set this so that when the createNewPix call finishes, we upload a new stix
            hasPendingStixLayerToUpload = YES;
            
            // do not share until upload is complete
        }
    }
    else {
        // cameraTag needs to update the username, but keep the original author as the descriptor and original username
        // cameraTag is already a copy
        Tag * newTag = cameraTag; // cameraTag.copy
        NSLog(@"Camera username %@ original %@", cameraTag.username, cameraTag.originalUsername);
        
#if USING_FLURRY
        if (!IS_ADMIN_USER(myUserInfo_username))
            [FlurryAnalytics logEvent:@"Remix" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:cameraTag.username, @"Remix author", cameraTag.originalUsername, @"Original author", nil]];
#endif
        
        if (![cameraTag.username isEqualToString:[self getUsername]]) {
            // username is not cameraTag.username
            if (remixMode == REMIX_MODE_ADDSTIX) {
                // original name is tag's author
                [newTag setOriginalUsername:[cameraTag.username copy]]; // set original username to username
            }
            else {
                // original name is tag's original author if it exists
                if ([cameraTag.originalUsername length]>0)
                    [newTag setOriginalUsername:[cameraTag.originalUsername copy]];
                else {
                    [newTag setOriginalUsername:[cameraTag.username copy]]; // set original username to username
                }
            }
            [newTag setUsername:[self getUsername]]; // change username if necessary
            [newTag setDescriptor:[NSString stringWithFormat:@"via %@", newTag.originalUsername]];
        }
        else {
            // username is cameraTag.username
            if ([[self getUsername] isEqualToString:cameraTag.originalUsername]) {
                [newTag setDescriptor:@""];
                [newTag setUsername:[self getUsername]];
            }
            else {
                // keep the original username
                [newTag setUsername:[self getUsername]];
                [newTag setDescriptor:[NSString stringWithFormat:@"via %@", newTag.originalUsername]];
            }
        }
        NSLog(@"Saving remixed tag: original tagID %@ by %@, description %@, with highresID %@", newTag.tagID, newTag.username, newTag.descriptor, newTag.highResImageID);
        
        // if we clicked from exploreView, we need to:
        if (lastViewController == exploreController) {
            // close exploreView's detailview
            [self didDismissSecondaryView];
            // jump to feed
            [self didPressTabButton:TABBAR_BUTTON_FEED];
        }
        
        // must create preemptive tag in controller!
        [feedController addTagForDisplay:newTag];
        [feedController didClickJumpButton:nil];
        
        // upload to kumulos in order to create a DIFFERENT record ID
        NSNumber * remixModeParam = [NSNumber numberWithInt:remixMode];
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newTag, remixModeParam, nil];
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSLog(@"newTag: %@ from Tag: %@", newTag.tagID, cameraTag.tagID);
        [kh execute:@"createNewPix" withParams:params withCallback:@selector(khCallback_didCreateNewPix:) withDelegate:self];
        
        [self doParallelNewPixShare:cameraTag];
    }
    
}

-(void)khCallback_didGetHighResImage:(NSArray*)returnParams {
    Tag * tag = [returnParams objectAtIndex:0];
    UIImage * highResImage;
    NSArray * theResults = [returnParams objectAtIndex:1];
    if ([theResults count] == 0) { 
        // high res or original picture does not exist, use tag image
        highResImage = tag.image;
    }
    else {
        NSMutableDictionary * d = [theResults objectAtIndex:0];
        NSData * dataPNG = [d objectForKey:@"dataPNG"];
        highResImage = [UIImage imageWithData:dataPNG];
    }
    [tag setHighResImage:highResImage];
    [shareController startUploadImage:tag withDelegate:self];
}

-(void)didGetHighResImage:(UIImage *)highResImage forTagID:(NSNumber *)tagID {
    // optimization - only request high res image once
    Tag * t = [allTagIDs objectForKey:tagID];
    [t setHighResImage:highResImage];
    
    for (int i=0; i<[feedController.allTags count]; i++) {
        Tag * t = [feedController.allTags objectAtIndex:i];
        if ([[t tagID] intValue] == [tagID intValue]) {
            NSLog(@"DidGetHighResImage: updating allTags at index %d", i);
            [t setHighResImage:highResImage];
            return;
        }
    }
    for (int i=0; i<[feedController.allTagsDisplayed count]; i++) {
        Tag * t = [feedController.allTagsDisplayed objectAtIndex:i];
        if ([[t tagID] intValue] == [tagID intValue]) {
            NSLog(@"DidGetHighResImage: updating allTagsDisplayed at index %d", i);
            [t setHighResImage:highResImage];
            return;
        }
    }
}

-(void)khCallback_didUpdateStixLayer:(NSArray *)returnParams {
    Tag * tag = [returnParams objectAtIndex:0];
    NSLog(@"Did update stix layer for tag %@", tag.tagID);
    readyToUploadPendingStixLayer_tagID = -1;
    hasPendingStixLayerToUpload = NO;
    // updates allTags and forces reload of page
    [self addTagWithCheck:tag withID:[tag.tagID intValue] overwrite:YES];
    [feedController jumpToPageWithTagID:[tag.tagID intValue]];
    [feedController forceReloadWholeTableZOMG];
}

-(void)didReloadPendingPix:(Tag *)tag {
    NSNumber * remixMode = [NSNumber numberWithInt:0];
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:tag, remixMode, nil];
    [aggregator delayAggregationForTime:5];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"createNewPix" withParams:params withCallback:@selector(khCallback_didCreateNewPix:) withDelegate:self];
    
    // perhaps upload failed and also didn't write to stix album
    NSLog(@"*******************************Writing to stix album*******************************");
    UIImage * savedBackup = [tag tagToUIImage];
    UIImageWriteToSavedPhotosAlbum(savedBackup, nil, nil, nil); 
    [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:savedBackup toAlbum:@"Stix Album" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"*******************************Could not write to library: error %@*******************************", [error description]);
            // retry one more time
            [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:savedBackup toAlbum:@"Stix Album" withCompletionBlock:^(NSError *error) {
                if (error!=nil) {
                    NSLog(@"Second attempt to write to library failed: error %@", [error description]);
                }
            }];
        }
        else {
            NSLog(@"*******************************Wrote to stix album*******************************");
        }
    }];
}

-(void)pauseAggregation {
    [aggregator delayAggregationForTime:.5];
}

-(void)khCallback_didCreateNewPix:(NSArray*)returnParams {
    // created a new entry in allTags in Kumulos
    
    NSNumber * remixMode = [returnParams objectAtIndex:2];
    
    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_01 && [remixMode intValue] == REMIX_MODE_NEWPIC) {
        [self advanceFirstTimeUserMessage];
    }
    
    // get that record and add to feed
    NSNumber * newRecordID = [returnParams objectAtIndex:0];
    Tag * newTag = [returnParams objectAtIndex:1]; // newTag should be a newly created tag
    NSNumber * oldID = newTag.tagID; // if it was a new pix, then the tagID is pendingID. 
    
    // we must create a new tag, because old tag is a pointer to the previous tag so if we are remixing
    // a photo it will change the feed
    //Tag * newTag = oldTag.copy;
    NSLog(@"Tag's id: %@ recordID: %@", newTag.tagID, newRecordID); // check 5899
    
    // must always update originalUsername for this tag regardless of remixMode
    if (!newTag.originalUsername) // if not set
        newTag.originalUsername = newTag.username;
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newRecordID, newTag.originalUsername, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"setOriginalUsername" withParams:params withCallback:@selector(khCallback_didSetOriginalUsername:) withDelegate:self];

    // If we have already finished editing/adding stix
    if (hasPendingStixLayerToUpload) {
        // already finished modifying stix; ready to upload and share
        // stix layer editing was finished before upload completed
        
        // must update the stix layer for all remix modes
        NSData * stixLayerData = UIImagePNGRepresentation(newTag.stixLayer);
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newTag, stixLayerData, nil];
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        [kh execute:@"updateStixLayer" withParams:params withCallback:@selector(khCallback_didUpdateStixLayer:) withDelegate:self];   

        // share since we have completed editing
        [self doParallelNewPixShare:newTag];
    }
    // if we have not finished editing stix
    else {
        readyToUploadPendingStixLayer_tagID = [newRecordID intValue];        
    }
    
    if ([remixMode intValue] != REMIX_MODE_NEWPIC) {
        // add comment: "Remixed this Pix via..." to original tag
        NSLog(@"NewTag: name %@ original %@ myname %@", newTag.username, newTag.originalUsername, [self getUsername]);
        // send remix notification if not own pix
        if (![newTag.originalUsername isEqualToString:[self getUsername]]) {
            NSString * message = [NSString stringWithFormat:@"%@ remixed your Pix.", myUserInfo_username];
            NSString * channel = [NSString stringWithFormat:@"To%d", [[allUserIDs objectForKey:newTag.originalUsername] intValue]];
            [self Parse_sendBadgedNotification:message OfType:NB_REMIX toChannel:channel withTag:newRecordID];  
        }

        // update popularity for REMIX
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:newRecordID, nil];
        [kh execute:@"incrementPopularity" withParams:params withCallback:nil withDelegate:self];
        
        // add to newsletter
        NSString * targetName = newTag.originalUsername;
        NSString * agentName = [self getUsername];
        if (![targetName isEqualToString:agentName]) {
            [k addNewsWithUsername:targetName andAgentName:agentName andNews:@"remixed your pix" andThumbnail:UIImagePNGRepresentation([newTag thumbnail]) andTagID:[newRecordID intValue]];
        }
    }
    
    bool added = [self addTagWithCheck:newTag withID:[newRecordID intValue]];
    // hack: addTagWithCheck changes a pendingID from a negative number (-1, -2...) to the actual number
    // so we have to store it inside Tag in order for finishedCreateNewPix to remove it
    if (added)
    {
        NSLog(@"Added new record to kumulos: tag id %@ with pending ID: %@", newRecordID, oldID);
        [feedController finishedCreateNewPix:newTag withPendingID:[oldID intValue]];
        //[feedController forceReloadWholeTableZOMG];
    }
    else {
        NSLog(@"Error! New record has duplicate tag id: %d", [newRecordID intValue]);
        [feedController finishedCreateNewPix:newTag withPendingID:[oldID intValue]];
    }    
    /*** automatic sharing and background uploading ***/
    /* New functionality: display the ShareController and allow user
     * to enter a caption and select automatic sharing options.
     * In the background, we should also perform uploading to stixmobile.com
     */
    // display share options controller and start upload
    //[self doParallelNewPixShare:newTag];
    
    // save large image to large image database
    if ([remixMode intValue] == REMIX_MODE_NEWPIC) {
        // new picture; add high res pic to database
        UIImage * hiResImg = newTag.highResImage;
        if (hiResImg != nil) { //USE_HIGHRES_SHARE && (hiResImg != nil)) {
            NSData * largeImgData = UIImageJPEGRepresentation(hiResImg, .95); 
            NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:largeImgData, newRecordID, nil];
            KumulosHelper * kh = [[KumulosHelper alloc] init];
            [kh execute:@"addHighResPix" withParams:params withCallback:@selector(khCallback_didAddHighResPix:) withDelegate:self];
        }
    }
    else {
        NSNumber * highResID = [newTag highResImageID];
        if (highResID) {
            NSLog(@"No high res id set for tag %@!", newTag.tagID);
            NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:highResID, newTag.tagID, nil];
            NSLog(@"setHighResImageID: highresID: %@ newTagID: %@", highResID, newTag.tagID);
            KumulosHelper * kh = [[KumulosHelper alloc] init];
            [kh execute:@"setHighResImageID" withParams:params withCallback:@selector(khCallback_didSetHighResImageID:) withDelegate:self];
        }
    }
    
    // touch tag to indicate it was updated
    // force timeUpdated to exist - if there's no stix this will be 0 otherwise
    [k touchPixToUpdateWithAllTagID:[newRecordID intValue]];
    
    // metrics
#if !USING_FLURRY
    NSString * metricName = @"CreatePix";
    [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:@"" andIntegerValue:[newRecordID intValue]];
#else
    if (!IS_ADMIN_USER(myUserInfo_username))
        [FlurryAnalytics logEvent:@"CreatePix" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", newRecordID, @"tagID", nil]];
#endif

    [Appirater userDidSignificantEvent:YES];
    
    // add tagID to pixBelongsToUser table, with error handling
    NSMutableArray * params2 = [[NSMutableArray alloc] initWithObjects: myUserInfo_username, newRecordID, nil];
    KumulosHelper * kh2 = [[KumulosHelper alloc] init];
    [kh2 execute:@"addPixBelongsToUser" withParams:params2 withCallback:nil withDelegate:self];
    
    // update aggregator
    [aggregator insertNewTagID:newRecordID];
        
    [feedController forceReloadWholeTableZOMG];
    [feedController jumpToPageWithTagID:[newRecordID intValue]];
}

-(void)khCallback_didSetOriginalUsername:(NSMutableArray*)returnParams {
    //NSlog(@"DidSetOriginalUsername for tagID %@ to %@");
    NSLog(@"Did set original usernamne!");
}

-(void)kumulosHelperCreateNewPixDidFail:(Tag *)failedTag {
    [self showAlertWithTitle:@"Low Connectivity" andMessage:@"Stix is having trouble uploading your image." andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    [feedController showReloadPendingPix:failedTag];
}

-(void)khCallback_didAddHighResPix:(NSMutableArray *)returnParams {
    NSNumber * highResID = [returnParams objectAtIndex:0];
    NSNumber * tagID = [returnParams objectAtIndex:1];
    NSLog(@"High res pic for tagID %d uploaded! high res id %d", [tagID intValue], [highResID intValue]);
    
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:highResID, tagID, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"setHighResImageID" withParams:params withCallback:@selector(khCallback_didSetHighResImageID:) withDelegate:self];
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
    
    // first, update from kumulos in case other people have added stix
    // to the same pix we are modifying
    // this is called from simply wanting to populate our allTags structure
    bool didAddTag = NO;
    // assume result is ordered by allTagID
    for (NSMutableDictionary * d in theResults) {
        Tag * tag = [Tag getTagFromDictionary:d]; // MRC
        int new_id = [tag.tagID intValue];
        didAddTag = [self addTagWithCheck:tag withID:new_id];
        if (didAddTag) {
            [feedController reloadPageForTagID:[tag.tagID intValue]];
        }        
        // new system of auxiliary stix: request from auxiliaryStixes table
        if (0) {
            NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:tag.tagID, nil]; 
            KumulosHelper * kh = [[KumulosHelper alloc] init];
            [kh execute:@"getAuxiliaryStixOfTag" withParams:params withCallback:@selector(khCallback_didGetAuxiliaryStixOfTag:) withDelegate:self];
        }
    }

    if ([[feedController allTagsDisplayed] count] > 0) {
        [feedController stopActivityIndicator];
        [feedController stopActivityIndicatorLarge];
    }    
    // we get here from handleNotificationBookmarks
    if (isUpdatingNotifiedTag) {
        if (updatingNotifiedTagDoJump) {
            [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
            [nav popToRootViewControllerAnimated:YES];
            [tabBarController setSelectedIndex:0];
            BOOL exists = [feedController jumpToPageWithTagID:[notificationTagID intValue]];
            if (!exists) {
                NSLog(@"How come no exist?!");
            }
        }
        [feedController reloadCurrentPage]; // allTags were already updated
        [self updateCommentCount:[notificationTagID intValue]];
        if (notificationBookmarkType == NB_NEWCOMMENT) {
            [feedController openCommentForPageWithTagID:notificationTagID];
        }
        updatingNotifiedTagDoJump = NO;
        isUpdatingNotifiedTag = NO;
    }
    
    if (jumpPendingTagID != 0) {
        [feedController jumpToPageWithTagID:jumpPendingTagID];
        [feedController stopActivityIndicator];
        jumpPendingTagID = 0;
    }
}

-(void)jumpToPageWithTagID:(int)tagID {
    // called by newsletter
    [self didPressTabButton:TABBAR_BUTTON_FEED];
    if (tagID == -1)
        return;
    [feedController jumpToPageWithTagID:tagID];
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
        [self processTagsWithIDRange:theResults];
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
        if (newerTagsToGet && [newerTagsToGet count]>0) {
            for (NSNumber * tagID in newerTagsToGet) {
                NSLog(@"First time requesting aggregated tags: newer tags %d", [tagID intValue]);
                [self getTagWithID:[tagID intValue]];
            }
        }
        NSArray * olderTagsToGet = [aggregator getTagIDsLessThanTagID:newestTagOnServer totalTags:5];
        if (olderTagsToGet && [olderTagsToGet count] > 0) {
            for (NSNumber * tagID in olderTagsToGet) {
                NSLog(@"First time requesting aggregated tags: older tags %d", [tagID intValue]);
                [self getTagWithID:[tagID intValue]];
            }
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
            [self getTagWithID:tID];
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

-(void)didAddCommentFromDetailViewController:(DetailViewController*)detailViewController withTag:(Tag*)_tag andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString*)stixStringID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    int tagID = [_tag.tagID intValue];
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
    
    // notifications
    if ([stixStringID isEqualToString:@"LIKE"]) {
        // comment from the Like Toolbar

        // update popularity for LIKE
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:tagID], nil];
        [kh execute:@"incrementPopularity" withParams:params withCallback:nil withDelegate:self];
        
        // notify
        NSString * actionMsg;
        NSString * shortMsg;
        if ([comment isEqualToString:@"LIKE_SMILES"])
            shortMsg = @"smiled at your Pix.";
        if ([comment isEqualToString:@"LIKE_LOVE"])
            shortMsg = @"loves your Pix.";
        if ([comment isEqualToString:@"LIKE_WINK"])
            shortMsg = @"winked at your Pix.";
        if ([comment isEqualToString:@"LIKE_SHOCKED"])
            shortMsg = @"is shocked by your Pix.";
        actionMsg = [NSString stringWithFormat:@"%@ %@.", myUserInfo_username, shortMsg];
        Tag * tag = _tag; //[allTagIDs objectForKey:[NSNumber numberWithInt:tagID]]; //[self getTagWithID:tagID];
        if (tag != nil) // if tag is nil, it is not on feed yet, just ignore
        {
            if (![tag.username isEqualToString:[self getUsername]]) {
                NSString * tagName = [tag.username stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSLog(@"allUserIDs: %d objects Id %d for tagName %@", [allUserIDs count], [[allUserIDs objectForKey:tag.username] intValue], tag.username);
                NSString * channel = [NSString stringWithFormat:@"To%d", [[allUserIDs objectForKey:tag.username] intValue]];
                [self Parse_sendBadgedNotification:actionMsg OfType:NB_NEWCOMMENT toChannel:channel withTag:tag.tagID];  
            }
        }
        if (!IS_ADMIN_USER(myUserInfo_username))
            [FlurryAnalytics logEvent:@"Liked" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", comment, @"likeType", nil]];
        
        // add to newsletter
        NSString * targetName = tag.username;
        NSString * agentName = [self getUsername];
        if (![targetName isEqualToString:agentName]) {
            NSData * thumbData = UIImagePNGRepresentation([tag thumbnail]);
            [k addNewsWithUsername:targetName andAgentName:agentName andNews:shortMsg andThumbnail:thumbData andTagID:[tag.tagID intValue]];
        }
#if USING_FLURRY
        if ([tag.tagID intValue]==0) {
            // log flurry error
            NSString * name = [NSString stringWithFormat:@"<%@>",tag.username];
            [FlurryAnalytics logEvent:@"NewsletterError" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:tag.username, @"username", [self getUsername], @"agentName", shortMsg, @"news", nil] ];
        }
#endif
    }
    /*
    else if ([stixStringID isEqualToString:@"REMIX"]) { //![comment isEqualToString:@""]) {
        // notify
        Tag * tag = [allTagIDs objectForKey:[NSNumber numberWithInt:tagID]]; //[self getTagWithID:tagID];
        if (tag != nil) // if tag is nil, it is not on feed yet, just ignore
        {
            // todo: make an NB_REMIX notification type to jump to remixed photo
            NSString * message = [NSString stringWithFormat:@"%@ remixed your Pix", myUserInfo_username];
            NSString * channel = [NSString stringWithFormat:@"To%d", [[allUserIDs objectForKey:tag.username] intValue]];
            [self Parse_sendBadgedNotification:message OfType:NB_MESSAGE toChannel:channel withTag:tag.tagID];
        }
        // metrics
        [FlurryAnalytics logEvent:@"CommentAdded" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", comment, @"comment", nil]];
    }
     */
    else if ([stixStringID isEqualToString:@"COMMENT"]) { //![comment isEqualToString:@""]) {
        // actual comment
        
        // update popularity for COMMENT
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:tagID], nil];
        [kh execute:@"incrementPopularity" withParams:params withCallback:nil withDelegate:self];

        // notify
        NSString * message = [NSString stringWithFormat:@"%@ commented on your pix.", myUserInfo_username];
        Tag * tag = [allTagIDs objectForKey:[NSNumber numberWithInt:tagID]]; //[self getTagWithID:tagID];
        if (tag != nil) // if tag is nil, it is not on feed yet, just ignore
        {
            if (![tag.username isEqualToString:[self getUsername]]) {
                NSString * tagName = [tag.username stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSNumber * userID = [allUserIDs objectForKey:tag.username];
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
        //[self updateUserTagTotal];
        
        // add to newsletter
        NSString * targetName = tag.username;
        NSString * agentName = [self getUsername];
        if (![targetName isEqualToString:agentName]) {
            NSData * thumbData = UIImagePNGRepresentation([tag thumbnail]);
            [k addNewsWithUsername:targetName andAgentName:agentName andNews:@"commented on your pix." andThumbnail:thumbData andTagID:[tag.tagID intValue]];
        }
        
        // don't updateCommentCount;
        // touch tag to indicate it was updated
        [k touchPixToUpdateWithAllTagID:tagID];
        
        // metrics
#if !USING_FLURRY
        NSString * metricName = @"CommentAdded";
        //NSString * metricData = [NSString stringWithFormat:@"Comment: %@", comment];
        [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:comment andIntegerValue:0];
#else
        if (!IS_ADMIN_USER(myUserInfo_username))
            [FlurryAnalytics logEvent:@"CommentAdded" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", comment, @"comment", nil]];
#endif
    }

    // check to see if need to update detailViewController
    if (detailViewController) {
        NSLog(@"Comments added from detailViewController! Must reload!");
        [detailViewController reloadComments];
    }
    else {
        NSLog(@"Comment was added from ExploreView or ShareController!");
    }
    
    // check to see if comment was added from a commentview
    if ([[nav topViewController] isKindOfClass:[CommentViewController class]]) {
        NSLog(@"Need to close commentView!");
        [nav popViewControllerAnimated:YES];
    }
    else {
        NSLog(@"Top not commentView! Comment was saved from share controller!");
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
        if ([commentStixStringID length] == 0 || [commentStixStringID isEqualToString:@"COMMENT"] || [commentStixStringID isEqualToString:@"LIKE"]) {
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
    
    //[Admin adminUpdateAllUserFacebookStrings:theResults];
    NSLog(@"DidGetAllUsers!");
    didGetAllUsers = YES;
    
    NSLog(@"kumulosHelper getAllUsers did complete with %d users", [theResults count]);
    [allUserPhotos removeAllObjects];
    [allUserFacebookStrings removeAllObjects];
    [allUserTwitterStrings removeAllObjects];
    [allUserIDs removeAllObjects];
    [allUserEmails removeAllObjects];
    [allUserNames removeAllObjects];
    for (NSMutableDictionary * d in theResults) {
        NSString * name = [d valueForKey:@"username"];
        id photoData = [d valueForKey:@"photo"];
        //NSLog(@"photoData class: %@", [photoData class]);
        UIImage * photo = [UIImage imageWithData:photoData];
        if (photo == nil) {
            //NSLog(@"name %@ photo %x photoData %x", name, photo, photoData);
            photo = [UIImage imageNamed:@"graphic_nopic.png"];
        }
        NSString * facebookString = [d valueForKey:@"facebookString"];
        NSString * twitterString = [d valueForKey:@"twitterString"];
        NSNumber * userID = [d valueForKey:@"allUserID"];
        [allUserPhotos setObject:photo forKey:name];
        [allUserFacebookStrings addObject:facebookString];
        [allUserTwitterStrings addObject:twitterString];
        [allUserEmails addObject:[d valueForKey:@"email"]];
        [allUserNames addObject:name];
        [allUserIDs setObject:userID forKey:name];
        //NSLog(@"AllUserIDS: %@ %d", name, [userID intValue]);
    }
    NSLog(@"allUserFacebookStrings: %d", [allUserFacebookStrings count]);
//    [feedController forceReloadWholeTableZOMG];
    [friendSuggestionController refreshUserPhotos];
    [newsController refreshUserPhotos];
    [profileController reloadSuggestionsForOutsideChange];
}

/**** LoginSplashController delegate ****/

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
    StixAnimation * animation = [[StixAnimation alloc] init];
    CGRect frameOffscreen = profileController.view.frame;
    
    frameOffscreen.origin.x -= 330;
    [animation doViewTransition:profileController.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [profileController.view removeFromSuperview];
        //[feedController unlockProfile];
    }];
}

#pragma mark Changing user photo

-(void)didClickChangePhoto {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    // we want to open another camera source
    // we have to do it over the existing camera because touch controls don't work if
    // we add a modal view to profileViewController
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; ////SavedPhotosAlbum;
    picker.allowsEditing = NO;
    picker.delegate = self;
    
    // because a modal camera already exists, we must present a modal view over that camera
    [profileController presentModalViewController:picker animated:YES];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    //    [[picker parentViewController] dismissModalViewControllerAnimated: YES];    
    //    [picker release];    
    
    [profileController dismissModalViewControllerAnimated:TRUE];
    [nav popToRootViewControllerAnimated:YES];
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
    [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
    [profileController dismissModalViewControllerAnimated:TRUE];
    [nav popToRootViewControllerAnimated:YES];
    //[profileController viewWillAppear:YES];
    
    // scale down photo
	CGSize targetSize = CGSizeMake(90, 90);		
    UIImage * result = [newPhoto resizedImage:targetSize interpolationQuality:kCGInterpolationDefault];
    UIImage * rounded = [result roundedCornerImage:0 borderSize:2];
    
    // save to both albums
    UIImageWriteToSavedPhotosAlbum(rounded, nil, nil, nil); 
    [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:rounded toAlbum:@"Stix Album" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"Could not write to library: error %@", [error description]);
        }
    }];
    
    NSData * img = UIImagePNGRepresentation(rounded);
    //[profileController.photoButton setImage:rounded forState:UIControlStateNormal];
    [self didChangeUserphoto:rounded];
    
    // add to kumulos
    [k addPhotoWithUsername:myUserInfo_username andPhoto:img];
#if HAS_PROFILE_BUTTON
    [feedController.buttonProfile setImage:myUserInfo_userphoto forState:UIControlStateNormal];
    [feedController.buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [feedController.buttonProfile.layer setBorderWidth:1];
    [exploreController.buttonProfile setImage:myUserInfo_userphoto forState:UIControlStateNormal];
    [exploreController.buttonProfile.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [exploreController.buttonProfile.layer setBorderWidth:1];
#endif
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
    NSLog(@"Todo: show a facebook login and merge accounts");
    [fbHelper requestFacebookFriends];
}

-(void)searchFriendsOnStix {
    NSLog(@"Requesting friends on facebook");
    if ([fbHelper facebookHasSession] == 1)
        [self searchFriendsByFacebook];
    else 
        // if not logged into facebook, simulate 0 friends
        [self didReceiveFacebookFriends:[NSArray arrayWithObjects: nil]];
}

-(void)didReceiveFacebookFriends:(NSArray*)friendsArray {
    NSLog(@"DidReceiveFacebookFriends! updating profileController and friendSuggestionController!");
    [profileController didGetFacebookFriends:friendsArray];
    if (friendSuggestionController && !didDismissFriendSuggestions)
        [friendSuggestionController populateFacebookSearchResults:friendsArray];
}

-(NSMutableArray*)getAllUserFacebookStrings {
    NSLog(@"Returning %d alluserfacebookstrings", [allUserFacebookStrings count]);
    return allUserFacebookStrings;
}
-(NSMutableArray*)getAllUserTwitterStrings {
    return allUserTwitterStrings;
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

-(void)didLoginFromSplashScreenWithScreenname:(NSString *)username andPhoto:(NSData *)photo andEmail:(NSString *)email andFacebookString:(NSString *)facebookString andTwitterString:(NSString *)twitterString andUserID:(NSNumber *)userID isFirstTimeUser:(BOOL)isFirstTimeUser {

    // dismiss splash screen/s navcontroller
    [tabBarController dismissModalViewControllerAnimated:YES];
    [nav.view setFrame:CGRectMake(0, 0, 320, 480+TABBAR_BUTTON_DIFF_PX)]; // forces bottom of tabbar to be 40 px
    NSLog(@"DidLoginFromSplashScreen: username %@ userID %@ email %@ facebookString %@ twitterString %@", username, userID, email,facebookString, twitterString);

#if USING_FLURRY
    // only log to flurry here because every session eventually comes here; didLoginWithUsername can be called twice
    if (!IS_ADMIN_USER(myUserInfo_username)) {
        [FlurryAnalytics logEvent:@"LoginWithUsername" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:username, @"username", versionStringBeta, @"Version",  nil]];
        [FlurryAnalytics setUserID:username];
    }
#endif
    
    /***** if we used splash screen *****/
    if (!didGetFollowingLists) {
        // may be called after cached user login
        [self getFollowListsWithoutAggregation:username];
        didGetFollowingLists = YES;
        // we WANT to display suggstion controller, and just wait a bit
        //isShowingFriendSuggestions = YES;         // following lists are used to initialize friend suggestion page so we want to lock other functions
    }

    // check for user stage saved in UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"firstTimeUserStage"] == nil) {
        myUserInfo->firstTimeUserStage = FIRSTTIME_MESSAGE_01;
    }
    // first time logging in via a service, set defaults to YES automatically
    // shareController doesn't exist
    /*
    if (![facebookString isEqualToString:@"0"] && [facebookString length] > 0)      
        [shareController connectService:@"Facebook"];
    if (![twitterString isEqualToString:@"0"] && [twitterString length] > 0)
        [shareController connectService:@"Twitter"];
     */

    if (isFirstTimeUser) {
        myUserInfo_username = username; // needed by setFollowing to getUsername
        // flag set if someone is added to Kumulos for the first time
        NSLog(@"Adding follower %@ to %@", username, @"Bobby Ren");
        [k addFollowerWithUsername:@"William Ho" andFollowsUser:username];
        [k addFollowerWithUsername:@"Bobby Ren" andFollowsUser:username];
        
        [self setFollowing:@"William Ho" toState:YES];
        [self setFollowing:@"Bobby Ren" toState:YES];
        addAutomaticFollows = YES;
    }
    if (photo != nil) {
        myUserInfo->hasPhoto = 1;
    }
    
    [self didLoginWithUsername:username andPhoto:photo andEmail:email andFacebookString:facebookString andTwitterString:twitterString andUserID:userID];
    
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
    
    if (isFirstTimeUser) {
        // do all the initial content stuff while waiting for friend controller
        [self initialContent];
    }
    
    // from didAddNewUserWithResult
    
    if ([allUserNames containsObject:username]) {
        [allUserPhotos setObject:photo forKey:username];
        [allUserFacebookStrings addObject:facebookString];
        [allUserTwitterStrings addObject:twitterString];
        [allUserEmails addObject:email];
        [allUserNames addObject:username];
        [allUserIDs setObject:userID forKey:username];
    }
}

- (void)didLoginWithUsername:(NSString *)name andPhoto:(UIImage *)photo andEmail:(NSString*)email andFacebookString:(NSString*)facebookString andTwitterString:(NSString*)twitterString andUserID:(NSNumber*)userID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    
    NSLog(@"DidLoginWithUsername: %@ email %@ facebookString %@ twitterString %@ userid %@", name, email, facebookString, twitterString, userID);

    [self continueInit];

#if !USING_FLURRY
    NSString * metricName = @"LoginWithUsername";
    NSString * metricData = [NSString stringWithFormat:@"UID: %@", uniqueDeviceID];
    //NSString * string = [NSString stringWithFormat:@"User login: %@", name];
    [k addMetricWithDescription:metricName andUsername:name andStringValue:metricData andIntegerValue:0];
#endif
        
    [aggregator loadCachedUserTagListForUsers];

    if (photo) {
        myUserInfo->hasPhoto = 1;
        [tabBarController didGetProfilePhoto:photo];
    }
    else {
        myUserInfo->hasPhoto = 0;
    }
    
    loggedIn = YES;
    myUserInfo_username = name;
    myUserInfo_userphoto = photo;
    myUserInfo_email = email;
    myUserInfo_facebookString = facebookString;
    myUserInfo_twitterString = twitterString;
    myUserInfo->userID = [userID intValue];
    
    NSLog(@"UserID: %d Username %@ with email %@ and facebookString %@", myUserInfo->userID, myUserInfo_username, email, myUserInfo_facebookString);
            
    [self reloadAllCarousels];
    [self getNewsCount];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        // save username, facebookString, email to disk
        [self saveUserInfoToDefaults]; // saves user name
    });
        
#if !USING_FLURRY
    [self setMetricLogonTime:[NSDate date]];
#else
    if (!IS_ADMIN_USER(myUserInfo_username))
        [FlurryAnalytics logEvent:@"TimeInApp" timed:YES];
#endif
    if (!didStartFirstTimeMessage && !isShowingFriendSuggestions && [self tabBarIsVisible]) {
        [tabBarController displayFirstTimeUserProgress:myUserInfo->firstTimeUserStage];    
        didStartFirstTimeMessage = YES;
    }
    
    // check for premium
    [k getUserPremiumPacksWithUsername:myUserInfo_username];
}

-(void)didLogout {
    /*
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    loggedIn = NO;
    myUserInfo_username = @"";
    if (myUserInfo_userphoto) {
        myUserInfo_userphoto = nil;
    }
    [allStix removeAllObjects];
    [allStixOrder removeAllObjects];
    [self logMetricTimeInApp];
    
    [fbHelper facebookLogout];
    [self didDismissSecondaryView];
    [nav pushViewController:previewController animated:YES];
     */
}

-(void)didChangeUserphoto:(UIImage *)photo {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    myUserInfo_userphoto = photo;
    myUserInfo->hasPhoto = 1;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:myUserInfo->hasPhoto forKey:@"hasPhoto"];
    NSData *userphoto = UIImagePNGRepresentation(myUserInfo_userphoto);
    [defaults setObject:userphoto forKey:@"userphoto"];
    [defaults synchronize];
    
    [allUserPhotos setObject:userphoto forKey:[self getUsername]];
    [userProfileController didChangeUserPhoto:photo];
    [tabBarController didGetProfilePhoto:photo];
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
        return NO;
    return [allFollowing containsObject:name];
}

-(void)setFollowing:(NSString *)friendName toState:(BOOL)shouldFollow {
    if (shouldFollow) {
        [allFollowing addObject:friendName];
        NSLog(@"SetFollowing: you are now following %@.", friendName); // currentList %@", friendName, allFollowing );
        [k addFollowerWithUsername:myUserInfo_username andFollowsUser:friendName];
        followListsDidChangeDuringProfileView = YES;
        
        NSString * message = [NSString stringWithFormat:@"%@ is now following you on Stix.", myUserInfo_username];
        NSString * name = [friendName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString * channel = [NSString stringWithFormat:@"To%d", [[allUserIDs objectForKey:friendName] intValue]];//name];
        //NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
        //channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
#if !ADMIN_TESTING_MODE
        [self Parse_sendBadgedNotification:message OfType:NB_NEWFOLLOWER toChannel:channel withTag:nil];
#endif
        
        // add to newsletter
        NSString * targetName = friendName;
        NSString * agentName = myUserInfo_username;
        if (![targetName isEqualToString:agentName]) {
            NSLog(@"TargetName: %@ AgentName: %@", targetName, agentName);
            [k addNewsWithUsername:targetName andAgentName:agentName andNews:@"is now following you" andThumbnail:nil andTagID:-1];
        }
        // subscribe to channel
        //channel = [NSString stringWithFormat:@"From%@", friendName];
        //channel = [[ channel componentsSeparatedByCharactersInSet:charactersToRemove ]componentsJoinedByString:@"" ];
        //[self Parse_subscribeToChannel:channel];
    }
    else {
        [allFollowing removeObject:friendName];
        [k removeFollowerWithUsername:myUserInfo_username andFollowsUser:friendName];
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
    //[profileController updateFollowCounts];
    // don't do this or adding friends from profile's suggestions will crash
    //[profileController reloadSuggestionsForOutsideChange];
}
-(void)didChangeFriendsFromUserProfile {
    [profileController reloadSuggestionsForOutsideChange];
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

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addFollowerDidCompleteWithResult:(NSNumber *)newRecordID {
    NSLog(@"Add follower did complete: record %@", newRecordID);
}

-(void)didAddStixToPix:(Tag *)tag withStixStringID:(NSString*)stixStringID withLocation:(CGPoint)location /*withScale:(float)scale withRotation:(float)rotation*/ withTransform:(CGAffineTransform)transform{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
   
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
    if (!IS_ADMIN_USER(myUserInfo_username))
    {
        [FlurryAnalytics logEvent:@"StixTypesUsed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", stixStringID, @"stixStringID", nil]];
        if (![[self getUsername] isEqualToString:tag.username]) {
            [FlurryAnalytics logEvent:@"StixAddedToFriend" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", tag.username, @"friendName", stixStringID, @"stixStringID", nil]];
        }
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
        return [myUserInfo_username copy];
    }
    //NSLog(@"[delegate getUsername] returning anonymous");
    return @"anonymous";
}

-(NSString *)getFacebookString {
    if (loggedIn)
        return myUserInfo_facebookString;
    return @"";
}

-(int)getUserID {
    NSLog(@"loggedIn: %d myUserInfo ID: %d", loggedIn, myUserInfo->userID);
    return myUserInfo->userID;
}

-(UIImage *) getUserPhoto {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([self isLoggedIn] == NO)
        return [UIImage imageNamed:@"graphic_nopic.png"];
    return myUserInfo_userphoto;
}

-(BOOL)didGetAllUsers {
    return didGetAllUsers;
}

-(UIImage *)getUserPhotoForProfile {
    // for profile view
    if ([self isLoggedIn]) {
        UIImage * userphoto = [self getUserPhoto];
        if (myUserInfo->hasPhoto == 0) {
            // if default no_pic photo is saved as myUserInfo->photo from first time login
            //return [UIImage imageNamed:@"graphic_addpic"];
            return nil;
        }
        if (!userphoto) {
            //return [UIImage imageNamed:@"graphic_addpic.png"];
            //return [UIImage imageNamed:@"graphic_addpic"]; 
            return nil;
        }
        return userphoto;
    }
    else
        return [UIImage imageNamed:@"graphic_addpic.png"];
}

-(NSMutableDictionary * )getUserPhotos {
    return allUserPhotos;
}
-(UIImage*)getUserPhotoForUsername:(NSString *)username {
    id photoObject = [allUserPhotos objectForKey:username];
    UIImage * photo;
    if ([photoObject isKindOfClass:[UIImage class]])
        photo = photoObject;
    else {
        photo = [[UIImage alloc] initWithData:photoObject];
    }
    if (photo)
        return photo;
    else
        return [UIImage imageNamed:@"graphic_nopic.png"];
}

-(NSString*)getNameForFacebookString:(NSString*)_facebookString {
    if ([_facebookString intValue] == 0)
        return @"";
    for (int i=0; i<[allUserFacebookStrings count]; i++) {
        if ([_facebookString isEqualToString:[allUserFacebookStrings objectAtIndex:i]]) {
            return [allUserNames objectAtIndex:i];
        }
    }
    return nil;
}
-(NSString*)getNameForTwitterString:(NSString*)_twitterString {
    if ([_twitterString intValue] == 0)
        return @"";
    for (int i=0; i<[allUserTwitterStrings count]; i++) {
        if ([_twitterString isEqualToString:[allUserTwitterStrings objectAtIndex:i]]) {
            return [allUserNames objectAtIndex:i];
        }
    }
    return nil;
}

-(NSString*)getUserFacebookString { return myUserInfo_facebookString; }

-(void)didFinishRewardAnimation:(int)amount {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
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
    //[allCarouselViews addObject:newBadgeView];
}

-(void)didClickFeedbackButton {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (!feedbackController) {
        feedbackController = [[FeedbackViewController alloc] init];
        [feedbackController setDelegate:self];
    }
//    lastViewController = profileController;
    [nav pushViewController:feedbackController animated:NO];
}

-(void)didClickAboutButton {
#if 0
    UIWebView * webView = [[UIWebView alloc] init];
    [webView setFrame:CGRectMake(0, OFFSET_NAVBAR, 320, 480-OFFSET_NAVBAR)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.stixmobile.com/tos"]]];
    [webView setDelegate:self];
    UIViewController * webController = [[UIViewController alloc] init];
    [webController.view addSubview:webView];
    UIImageView * logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [webController.navigationItem setTitleView:logo];
    [nav pushViewController:webController animated:NO];
#else
    AboutViewController * aboutController = [[AboutViewController alloc] init];
    [nav pushViewController:aboutController animated:NO];
#endif
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
-(ShareController *)initializeShareController {
    // this function must be called each time shareController is initialized
    
#if USE_SINGLETON_SHARE
    if (shareController == nil) 
#endif
    {
        shareController = [ShareController sharedShareController];
        [shareController setDelegate:self];
    }
    // check to see if each service is already sharing - load from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * connected, * sharing;
         
    // set whether facebook is connected based on session
    //if ([fbHelper facebookHasSession]) {
    BOOL bConnected = [fbHelper facebookHasSession];
    NSLog(@"Facebook bConnected (hasSession): %d", bConnected);
    [shareController shareServiceShouldConnect:bConnected forService:@"Facebook"];
    if (bConnected) {
        // set whether facebook is sharing based on defaults
        sharing = [defaults objectForKey:@"FacebookIsSharing"]; 
        if (sharing) {
            BOOL isSharing = [sharing boolValue];
            [shareController shareServiceShouldShare:isSharing forService:@"Facebook"];
        }
    }
    
    // set whether twitter is connect based on defaults
    bConnected = [TwitterHelper isServiceAuthorized];
    //connected =  //[defaults objectForKey:@"TwitterIsConnected"]; 
    if (bConnected) 
    {
        NSLog(@"Twitter bConnected: %d", bConnected);
        [shareController shareServiceShouldConnect:bConnected forService:@"Twitter"];
        if (bConnected) {
            // set whether twitter is sharing based on defaults
            sharing = [defaults objectForKey:@"TwitterIsSharing"]; 
            if (sharing) {
                BOOL bSharing = [sharing boolValue];
                NSLog(@"bSharing: %d", bSharing);
                [shareController shareServiceShouldShare:bSharing forService:@"Twitter"];
            }
        }
    }
    return shareController;
}

-(void)initializeFriendSuggestionController {
    // starts requests for friends on facbook and featured users
    // keeps the login screen up, and only dismisses when both have loaded
    // calls displayFriendSuggestionController then
    [friendSuggestionController initializeSuggestions];
#if 0 && ADMIN_TESTING_MODE
    [self friendSuggestionControllerFinishedLoading:0];
#endif
}

-(void)showFriendSuggestionController {
    // hack: this is called with a delay so the navController doesnt get screwed up
    [nav pushViewController:friendSuggestionController animated:YES];
}

-(void)friendSuggestionControllerFinishedLoading:(int)totalSuggestions { 
    // friendSuggestionController is initialized but not shown
    // comes here when both friends and featured have been downloaded
    NSLog(@"FriendSuggestionController finished loading with totalSuggestions: %d", totalSuggestions);
    if (isShowingFriendSuggestions || didDismissFriendSuggestions)
        return;
    
    if (totalSuggestions == 0) {
        [self didAddFriendsFromFriendSuggestionController:nil];
    }
    else {
        NSLog(@"Showing friend suggestions view");
        // hack: timing issue.
        //[self performSelector:@selector(showFriendSuggestionController) withObject:nil afterDelay:5];
        [nav pushViewController:friendSuggestionController animated:YES];
        isShowingFriendSuggestions = YES;
    }        
}

-(void)didClickInviteButtonByFacebook:(NSString *)username withFacebookString:(NSString *)_facebookString {
    //NSString * metricString = [NSString stringWithFormat:@"%@ invited %@", [self getUsername], username];
#if !USING_FLURRY
    [k addMetricWithDescription:@"facebookInvite" andUsername:[self getUsername] andStringValue:username andIntegerValue:0];
#else
    if (!IS_ADMIN_USER(myUserInfo_username))
        [FlurryAnalytics logEvent:@"facebookInvite" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", username, @"invitedFriend", nil]];
#endif
    [fbHelper sendInvite:username withFacebookString:_facebookString];
}

-(void)shouldDisplayUserPage:(NSString *)name {
    NSLog(@"ShouldDisplayUserPage: %@", name);
#if SHOW_ARROW
    if (myUserInfo->firstTimeUserStage < FIRSTTIME_DONE) {
        [self agitateFirstTimePointer];
        return;
    }
#endif
    UserProfileViewController * userGallery = [[UserProfileViewController alloc] init];
    [userGallery setUsername:name];
    [userGallery setDelegate:self];
    [nav pushViewController:userGallery animated:YES];
}

-(void)didAddFriendsFromFriendSuggestionController:(NSArray *)addedFriends {
    isShowingFriendSuggestions = NO;
    didDismissFriendSuggestions = YES;
//    friendSuggestionController = nil;
    
    NSLog(@"Current allFollowing: %d", [allFollowing count]);
    
    if (addedFriends) {
        [allFollowing addObjectsFromArray:addedFriends];
        NSLog(@"Friend Suggestion resulted in %d added friends, now following %d people", [addedFriends count], [allFollowing count]);
        
        for (NSString * name in addedFriends) {
            [k addFollowerWithUsername:[self getUsername] andFollowsUser:name];
        }
    }

    [self.tabBarController setSelectedIndex:0];    
    [self initialContent];
}

-(void)initialContent {
    // do all the stuff needed upon startup
    
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
        // start first time message if needed
        if (!didStartFirstTimeMessage) {
            [tabBarController displayFirstTimeUserProgress:myUserInfo->firstTimeUserStage];    
            didStartFirstTimeMessage = YES;
        }
    }
    // at this time, friend list should have been updated
    // after adding users, then start aggregation
    //[self getFollowListsForAggregation:[self getUsername]];        
    [aggregator aggregateNewTagIDs];
}

-(void)reloadSuggestionsForOutsideChange {
    [profileController reloadSuggestionsForOutsideChange];
}

-(void)reloadAllCarousels {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    [[StixPanelView sharedStixPanelView] reloadAllStix];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if (actionSheet.tag == ACTIONSHEET_TAG_REMIX) {
        //    BOOL bUseOriginal = NO;
        int remixMode;
        if (buttonIndex == 0) {
            // remixed photo
            NSLog(@"Button 0");
            remixMode = REMIX_MODE_ADDSTIX;
        }
        else if (buttonIndex == 1) {
            // original photo
            NSLog(@"Button 1");
            remixMode = REMIX_MODE_USEORIGINAL;
        }
        else if (buttonIndex == 2) {
            NSLog(@"Button 2");
            tagToRemix = nil;
            return;
        }
        [self shouldDisplayStixEditor:tagToRemix withRemixMode:remixMode];
    }
}

-(void)didGetFeaturedUsers:(NSArray *)featured {
    if (featuredUsers == nil) {
        featuredUsers = [[NSMutableSet alloc] init];
    }
    for (NSMutableDictionary * d in featured) {
        NSString * name = [d objectForKey:@"username"];
        NSLog(@"Did get featured users: %@", name);
        [featuredUsers addObject:name];
    }
}
-(NSMutableSet*)getFeaturedUserSet {
    NSLog(@"FeaturedUsers: %@", featuredUsers);
    return featuredUsers;
}

-(void)requestTagWithTagID:(int)tagID {
    // called by VerticalFeedController if a jump to tagID fails
    [self getTagWithID:tagID];
    jumpPendingTagID = tagID;
    [feedController startActivityIndicator];
}

-(void) getTagWithID:(int)tagID {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"GetTagWithID: %d", tagID);
    Tag * tag = [allTagIDs objectForKey:[NSNumber numberWithInt:tagID]];
    if (tag) {
        NSMutableDictionary * dict = [Tag tagToDictionary:tag];
        [self processTagsWithIDRange:[[NSMutableArray alloc] initWithObjects:dict, nil]];
//        [feedController forceReloadWholeTableZOMG];
        return;
    }
    else {
        [aggregator delayAggregationForTime:1.5];
        [k getAllTagsWithIDRangeWithId_min:tagID-1 andId_max:tagID+1];
    }
}

/***** Parse Notifications ****/
//-(void) Parse_unsubscribeFromAll {
-(void)Parse_createSubscriptions {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif
#if 1 && ADMIN_TESTING_MODE
    return;
#endif
    
    /*** Parse service ***/
#if 1
    NSString * msg = @"Parse_createsubscriptions: creating request";
    NSLog(msg);
#if ADMIN_TESTING_MODE
    [self showAlertWithTitle:@"Test" andMessage:msg andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
#endif
    PFObject *testObject = [PFObject objectWithClassName:@"SubscriptionRequests"];
    [testObject setObject:myUserInfo_username forKey:@"username"];
    NSString* newStr = [NSString stringWithFormat:@"%@", notificationDeviceToken];
    NSRange range = (NSRange){1, 9};
    NSString *substr = [newStr substringWithRange:range];
    NSLog(@"newStr: %@ token: %@", substr, notificationDeviceToken);
    [testObject setObject:substr forKey:@"deviceTokenValue"];
    [testObject save];
#endif
    
    Parse_subscribedChannels = [[NSMutableSet alloc] init];
    NSError * err = nil;
    NSLog(@"Parse_createsubscriptions: starting createsubscriptions");
    
    // first, unsubscribe from everything, in case of logouts, etc
    [Parse_subscribedChannels unionSet:[PFPush getSubscribedChannels:&err]];
    NSString * unsubscribeStr = @"unsubscribing from: ";
    for (NSString * channel in Parse_subscribedChannels) {
        [PFPush unsubscribeFromChannel:channel error:&err];
        NSLog(@"unsubscribing from %@", channel);
        unsubscribeStr = [NSString stringWithFormat:@"%@ %@", unsubscribeStr, channel];
    }
#if ADMIN_TESTING_MODE
    [self showAlertWithTitle:@"Test" andMessage:unsubscribeStr andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    
    /*
    [self Parse_subscribeToChannel:@"letsSEE"];
    [self Parse_subscribeToChannel:@"testChannel"];
    [self Parse_subscribeToChannel:@"To500"];
    [self Parse_subscribeToChannel:@"anotherChannel"];
    [self Parse_subscribeToChannel:@"lastTest"];
    
    return;
     */
#endif
    
    [self Parse_subscribeToChannel:@""];
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
            NSString * subscribeString = [NSString stringWithFormat:@"Parse: Subscribed to channel <%@>", channel_];
            NSLog(@"%@", subscribeString);
#if ADMIN_TESTING_MODE
            [self showAlertWithTitle:@"Test" andMessage:subscribeString andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
#endif
            [Parse_subscribedChannels addObject:channel];
            PFObject *testObject = [PFObject objectWithClassName:@"SubscriptionSuccess"];
            [testObject setObject:myUserInfo_username forKey:@"username"];
            NSString* newStr = [NSString stringWithFormat:@"%@", notificationDeviceToken];
            NSRange range = (NSRange){1, 9};
            NSString *substr = [newStr substringWithRange:range];
            NSLog(@"newStr: %@ token: %@", substr, notificationDeviceToken);
            [testObject setObject:substr forKey:@"deviceTokenValue"];
            [testObject setObject:channel_ forKey:@"channel"];
            [testObject save];
        }
        else {
            NSString * errorString = [NSString stringWithFormat:@"Parse: Could not subscribe to <%@>: error %@", channel_, [error localizedDescription]];
            NSLog(@"%@", errorString);
#if ADMIN_TESTING_MODE
            [self showAlertWithTitle:@"Test" andMessage:errorString andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
#endif
            PFObject *testObject = [PFObject objectWithClassName:@"SubscriptionFailure"];
            [testObject setObject:myUserInfo_username forKey:@"username"];
            NSString* newStr = [NSString stringWithFormat:@"%@", notificationDeviceToken];
            NSRange range = (NSRange){1, 9};
            NSString *substr = [newStr substringWithRange:range];
            NSLog(@"newStr: %@ token: %@", substr, notificationDeviceToken);
            [testObject setObject:substr forKey:@"deviceTokenValue"];
            [testObject setObject:channel_ forKey:@"channel"];
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
    if (type == NB_NEWGIFT || type == NB_NEWCOMMENT || type == NB_NEWSTIX || type == NB_INCREMENTBUX || type == NB_NEWFOLLOWER || type == NB_NEWPIX || type == NB_REMIX)
        [data setObject:message forKey:@"alert"];
    if (type == NB_REMIX || type == NB_NEWFOLLOWER || type == NB_NEWCOMMENT) {
        [data setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"badge"];
    }
    [data setObject:myUserInfo_username forKey:@"sender"];
    [data setObject:[NSNumber numberWithInt:type] forKey:@"nbType"]; //notificationBookmarkType
    [data setObject:message forKey:@"message"];
    [data setObject:channel_ forKey:@"channel"];
    if (tagID != nil)
        [data setObject:tagID forKey:@"tagID"];
    [PFPush sendPushDataToChannelInBackground:channel_ withData:data];
}

- (void)application:(UIApplication *)application 
didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if ADMIN_TESTING_MODE
    [PFPush handlePush:userInfo];
#else
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
    notificationTagID = [userInfo objectForKey:@"tagID"];
    if (notificationBookmarkType == NB_REMIX || notificationBookmarkType == NB_NEWCOMMENT) 
    {
        doAlert = YES;
        [self getNewsCount];
    }
    if (notificationBookmarkType == NB_NEWFOLLOWER) {
        doAlert = NO;
        [self getNewsCount];
    }
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
        if (notificationBookmarkType == NB_MESSAGE) {
            // only display message
            [self showAlertWithTitle:@"Stix Notification" andMessage:message andButton:@"Close" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
        }
        if (notificationBookmarkType == NB_NEWFOLLOWER) {
            // only display message
            [self showAlertWithTitle:@"Stix Notification" andMessage:message andButton:@"Close" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
            [k getFollowersOfUserWithFollowsUser:[self getUsername]]; // update own follower list
        }
    }
    else {
        BOOL doUpdateTag = YES;
        if (notificationBookmarkType == NB_NEWPIX || notificationBookmarkType == NB_REMIX || notificationBookmarkType == NB_NEWCOMMENT) {
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
        // reset the counter
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInt:5] forKey:@"upgradeMessageCounter"];
        [defaults synchronize];
        if (buttonIndex == 1) {
            //NSString* launchUrl = @"http://testflightapp.com/";
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
            NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.com/apps/stix"];
            [[UIApplication sharedApplication] openURL:url];
        }            
    }
    else if (alertActionCurrent == ALERTVIEW_PROMPT) {
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            NSString *entered = [(AlertPrompt *)alertView enteredText];
            NSLog(@"Alert prompt input value: %@", entered);
        }
    }
    else if (alertActionCurrent == ALERTVIEW_SHAREFAIL) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            // let shareController continue and try uploading the same thing
            [shareController startUploadImage:nil withDelegate:self];
        }
        else {
            [self didCloseShareController:NO];
        }
    }
    if ([alertQueue count] == 0)
        return;
    UIAlertView * nextAlert = [alertQueue objectAtIndex:0];
    [alertQueue removeObjectAtIndex:0];
    [nextAlert show];
    isShowingAlerts = YES;
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
    
    // metric
#if !USING_FLURRY
    NSString * metricName = @"GetStixFromStore";
    //NSString * metricData = [NSString stringWithFormat:@"User: %@ Stix: %@", [self getUsername], stixStringID];
    [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:stixStringID andIntegerValue:0];
#else
    if (!IS_ADMIN_USER(myUserInfo_username))
        [FlurryAnalytics logEvent:@"GetStixFromStore" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", stixStringID, @"stixStringID", nil]];
#endif
}


-(void)getFollowListsWithoutAggregation:(NSString*)name {
    // called if we only want the friend list
    // called by FriendSuggestionController - if logging in for the first time
    // friend list is needed by the suggestion controller, but
    // we don't want to start aggregating yet because we don't know
    // if the friend list will change after the controller closes
    NSLog(@"GetFollowListsWithoutAggregation");
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
    
    NSLog(@"GetFollowListsForAggregation");
    
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
    NSLog(@"didGetFollowList returned %d", [theResults count]);
    // list of people this user is following
    // key: username value: friendName
    if (!addAutomaticFollows)
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
    //[profileController updateFollowCounts];
    NSLog(@"Get follow list returned: %@ is following %d people", [self getUsername], [allFollowing count]);
    
    // only initialize friend controller after we have followList
    [self initializeFriendSuggestionController];
}

-(void)khCallback_didGetFollowListWithAggregation:(NSArray*)returnParams {
    NSArray * theResults = returnParams; // objectAtIndex:0];
    // list of people this user is following
    // key: username value: friendName
    NSLog(@"didGetFollowListWithAggregation returned: You are following %d users", [theResults count]);
    if (!addAutomaticFollows)
        [allFollowing removeAllObjects];
    for (NSMutableDictionary * d in theResults) {
        NSString * friendName = [d valueForKey:@"followsUser"];
        if (![friendName isEqualToString:[self getUsername]]) {
            //NSLog(@"allFollowing adding %@", friendName);
            [allFollowing addObject:friendName];
        }
    }
    
    // cache followers
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData * followingData = [NSKeyedArchiver archivedDataWithRootObject:allFollowing];
    [defaults setObject:followingData forKey:@"allFollowing"];
    [defaults synchronize];
    //[profileController updateFollowCounts];
    NSLog(@"Get follow list returned: %@ is following %d people", [self getUsername], [allFollowing count]);
    
    // AGGREGATE FOR THE FIRST TIME HERE 
    [aggregator aggregateNewTagIDs];
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFollowersOfUserDidCompleteWithResult:(NSArray *)theResults {
-(void)khCallback_didGetFollowers:(NSArray*)returnParams {
    NSArray * theResults = returnParams; // objectAtIndex:0];
    // list of people who follow this user
    // key: friendName value: username
    if (!addAutomaticFollows)
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
    //[profileController updateFollowCounts];
    NSLog(@"Get followers returned: %@ has %d followers", [self getUsername], [allFollowers count]);    
}


#pragma mark first time user stuff

-(int)getFirstTimeUserStage {
    return myUserInfo->firstTimeUserStage;
}
-(void)hideFirstTimeUserMessage {
    //[tabBarController toggleFirstTimePointer:NO atStage:myUserInfo->firstTimeUserStage];
    [tabBarController toggleFirstTimeInstructions:NO];
}
#if SHOW_ARROW
-(void)hideFirstTimeArrowForShareController {
    [tabBarController toggleFirstTimePointer:NO atStage:myUserInfo->firstTimeUserStage];
}
#endif

-(void)agitateFirstTimePointer {
#if SHOW_ARROW
#if USING_FLURRY
    // first do logs on flurry
    if (!IS_ADMIN_USER([self getUsername]))
        [FlurryAnalytics logEvent:@"FirstTimeUser Agigtate" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:myUserInfo->firstTimeUserStage], @"Stage", nil]];
#endif
    [tabBarController agitateFirstTimePointer];
    if (myUserInfo->firstTimeUserStage != FIRSTTIME_MESSAGE_02)
        [tabBarController flashFirstTimeInstructions];
    else 
        [feedController agitatePointer];
#endif
}
-(void)redisplayFirstTimeUserMessage01 {
    // called by TagView if person has no friends
    [tabBarController displayFirstTimeUserProgress:myUserInfo->firstTimeUserStage];
}
-(void)advanceFirstTimeUserMessage {
#if USING_FLURRY
    // first do logs on flurry
    if (!IS_ADMIN_USER([self getUsername]))
        [FlurryAnalytics logEvent:@"FirstTimeUser Advanced" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:myUserInfo->firstTimeUserStage], @"Stage", nil]];
#endif
    myUserInfo->firstTimeUserStage++;
    NSLog(@"New FTUE stage: %d", myUserInfo->firstTimeUserStage);
    [tabBarController displayFirstTimeUserProgress:myUserInfo->firstTimeUserStage];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:myUserInfo->firstTimeUserStage forKey:@"firstTimeUserStage"];
    [defaults synchronize];
    
    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) 
        [feedController forceReloadWholeTableZOMG];
    
    if (myUserInfo->firstTimeUserStage >= FIRSTTIME_DONE)
        [tabBarController displayNewsCount];
    
#if USING_FLURRY
    if (!IS_ADMIN_USER([self getUsername]))
        if (myUserInfo->firstTimeUserStage > FIRSTTIME_MESSAGE_03) {
            [FlurryAnalytics logEvent:@"FirstTimeUser Finished" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"Username", nil]];
        }
#endif

}
-(void)didCloseFirstTimeMessage {
    // if user clicks on the 2nd message (remix)
    //if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02)
    //    [self advanceFirstTimeUserMessage];
}
-(BOOL)canDisplayNewsCount {
    return (myUserInfo->firstTimeUserStage == FIRSTTIME_DONE);
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPremiumPacksDidCompleteWithResult:(NSArray *)theResults {
    for (NSMutableDictionary * d in theResults) {
        NSString * stixPackName = [d objectForKey:@"stixPackName"];
        
        NSMutableArray * stixArray = [BadgeView getStixForCategory:stixPackName];
        for (int i=0; i<[stixArray count]; i++) {
            NSString * stixStringID = [stixArray objectAtIndex:i];
            [allStix setObject:[NSNumber numberWithInt:-1] forKey:stixStringID]; 
        }
        
        [[StixPanelView sharedStixPanelView] unlockPremiumPack:stixPackName usingStixStringID:nil];
    }
}

-(BOOL)shouldPurchasePremiumPack:(NSString *)stixPackName usingStixStringID:(NSString*)stixStringID {
    NSLog(@"Prompting to purchase premium pack: %@ after using stix %@", stixPackName, stixStringID);
    
#if 0 // beta
    // add purchase to kumulos
    [k didPurchasePremiumPackWithUsername:myUserInfo_username andStixPackName:stixPackName];
    
    // force stixPanel to update
    [[StixPanelView sharedStixPanelView] unlockPremiumPack:stixPackName];
    
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
    [[MKStoreManager sharedManager] buyFeature:purchaseID
                                    onComplete:^(NSString* purchasedFeature, NSData * data)
     {
         // provide your product to the user here.
         // if it's a subscription, allow user to use now.
         // remembering this purchase is taken care of by MKStoreKit.
         // add purchase to kumulos
         [k didPurchasePremiumPackWithUsername:myUserInfo_username andStixPackName:stixPackName];
         
         // force stixPanel to update
         [[StixPanelView sharedStixPanelView] unlockPremiumPack:stixPackName usingStixStringID:stixStringID];
         
         // animate
         NSString *firstChar = [stixPackName substringToIndex:1];
         NSString * stixPack = [[firstChar uppercaseString] stringByAppendingString:[stixPackName substringFromIndex:1]];
         [tabBarController doPremiumPurchaseAnimation:stixPack]; 

         // metrics
#if !USING_FLURRY
         NSString * metricName = @"PremiumPurchase";
         [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:stixPack andIntegerValue:0];     
#else
         if (!IS_ADMIN_USER(myUserInfo_username))
             [FlurryAnalytics logEvent:@"PremiumPurchase" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", stixPack, @"stixPack", nil]];
#endif
         mkStoreKitSuccess = YES;
     }
                                    onCancelled:^
     {
         // User cancels the transaction, you can log this using any analytics software like Flurry.
         
         // clear the activity indicator
         [[StixPanelView sharedStixPanelView] unlockPremiumPack:nil usingStixStringID:nil];
         
#if !USING_FLURRY
         NSString * metricName = @"CancelledPurchase";
         NSString * firstChar = [stixPackName substringToIndex:1];
         NSString * metricData = [[firstChar uppercaseString] stringByAppendingString:[stixPackName substringFromIndex:1]];
         [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:metricData andIntegerValue:0];     
#else
         if (!IS_ADMIN_USER(myUserInfo_username))
             [FlurryAnalytics logEvent:@"CancelledPurchase" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self getUsername], @"username", stixPackName, @"stixPack", nil]];
#endif
         mkStoreKitSuccess = NO;
     }];
    return mkStoreKitSuccess;
#endif

#endif
}

#pragma mark newsFeed badging
-(void)getNewsCount {
    // count how many news pieces are unseen
    NSLog(@"Getting unseen news for %@", [self getUsername]);
    [k countUnseenNewsWithUsername:[self getUsername] andHasBeenSeen:NO];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation countUnseenNewsDidCompleteWithResult:(NSNumber *)aggregateResult {
    
    NSLog(@"%d pieces of news have not been seen!", [aggregateResult intValue]);

    // start download news
    [newsController initializeNewsletter];
    
    // create news badge
    [tabBarController setNewsCountValue:[aggregateResult intValue]];
    if ([self canDisplayNewsCount])
        [tabBarController displayNewsCount];
}

-(void)clearNewsCount {
    [tabBarController setNewsCountValue: 0];
}

-(void)decrementNewsCount {
    int newCount = MAX(0, [tabBarController newsCount]-1);
    NSLog(@"Decrementing to %d", newCount);
    [tabBarController setNewsCountValue:newCount];
}

-(void)didGetNews {
    // reset application badge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // reset tab bar badge
    [tabBarController setNewsCountValue:0];
}

-(BOOL)tabBarIsVisible {
    return [nav topViewController] == tabBarController;
}

#pragma mark DetailViewController

static NSMutableSet * retainedDetailControllers;

-(void)didClickRemixFromDetailViewWithTag:(Tag*)tag {
    // hack a way to do remix for all feedItem views, whether from the explore or profile
    [self setTagToRemix:[tag copy]];
    NSLog(@"Did click remix with with tagID %@ by %@, creating tagToRemix with ID %@", tag.tagID, tag.username, tagToRemix.tagID);
    if (tagToRemix.stixLayer) {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to remix?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remixed Photo", @"Original Photo", nil];
        [actionSheet setTag:ACTIONSHEET_TAG_REMIX];
        [actionSheet showFromTabBar:tabBarController.tabBar];
    }
    else {
        // no previous stix exist, automatically choose original mode
        [self shouldDisplayStixEditor:[tag copy] withRemixMode:REMIX_MODE_USEORIGINAL];
    }

    if (myUserInfo->firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
        [self advanceFirstTimeUserMessage];
        [feedController didAdvanceFirstTimeUserMessage];
        //[tabBarController toggleFirstTimePointer:NO atStage:myUserInfo->firstTimeUserStage];
    }
}

-(void)shouldDisplayDetailViewWithTag:(Tag *)tag {
    DetailViewController * detailController = [[DetailViewController alloc] init];
    [detailController setDelegate:self];    
    [detailController initDetailViewWithTag:tag];
    [nav pushViewController:detailController animated:YES];
    
    // also add to feed if it doesn't exist
    if ([allTagIDs objectForKey:tag.tagID] == nil) {
        [self addTagWithCheck:tag withID:[tag.tagID intValue]];
        [feedController forceReloadWholeTableZOMG];
    }
}

-(void)detailViewNeedsRetainForDelegateCall:(DetailViewController *)_detailController {
    //-(void)detailViewNeedsRetainForDelegateCall:(DetailViewController*)_detailController {
    // comes from stixViews
    if (!retainedDetailControllers) 
        retainedDetailControllers = [[NSMutableSet alloc] init];
    NSLog(@"ExploreView: retaining detail view with username %@", [_detailController tagUsername]);
    [retainedDetailControllers addObject:_detailController];
}

-(void)detailViewDoneWithAsynchronousDelegateCall:(DetailViewController*)_detailViewController {
    NSLog(@"ExploreView: releasing detail view with username %@", [_detailViewController tagUsername]);
//    [retainedDetailControllers removeObject:_detailViewController]; // do not do this - will already be deallocated?
}

#pragma mark CommentView

-(void)shouldDisplayCommentViewWithTag:(Tag *)tag andNameString:(NSString *)nameString fromDetailView:(DetailViewController*)detailView{
    CommentViewController * commentView = [[CommentViewController alloc] init];
    [commentView setDelegate:self];
    [commentView setDetailViewController:detailView];
    [commentView initCommentViewWithTag:tag andNameString:nameString];
    
    [nav pushViewController:commentView animated:YES];
}

#pragma mark shareControllerDelegate

-(void)doParallelNewPixShare:(Tag*)_tag {
    NSLog(@"NewPixShare: resetting toggles for new created pix");
    newPixDidClickShare = NO;
    newPixDidFinishUpload = NO;
    if (USE_HIGHRES_SHARE && (_tag.highResImage == nil)) {
        /*
        // for now, skip high res share
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:_tag, nil];
        [kh execute:@"getHighResImage" withParams:params withCallback:@selector(khCallback_didGetHighResImage:) withDelegate:self];    
         */
    } else {
#if USE_SINGLETON_SHARE       
        // always does this: uploads the new, unstix'd tag in case
        // user wants to just share that
        NSLog(@"ShareController: %@", shareController);
        [shareController startUploadImage:_tag withDelegate:self];
#else
        shareController = [self initializeShareController];
        [shareController startUploadImage:_tag withDelegate:self];
#endif
    }
    [nav pushViewController:shareController animated:YES];
    //[shareController.view setFrame:CGRectMake(160, 0, 320, 480)];
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

-(void)didCloseShareController:(BOOL)didClickDone {
    if (didClickDone) {
        if (newPixDidFinishUpload) {
            //NSLog(@"NewPixShare: Did click done: upload already finished");
            [shareController doSharePix];
        }
        else {
            // wait for shareController to finish the update
            newPixDidClickShare = YES;
            NSLog(@"NewPixShare: Clicked share; waiting for upload");
        }
        
        // check for caption - used as comment
        NSString * caption = [shareController.caption text];
        NSLog(@"Did add caption: %@", caption);
        if (caption && [caption length] > 0) {
            int tagID = [[shareController.tag tagID] intValue];
            NSLog(@"TagID: %d username %@", tagID, [self getUsername]);
            [self didAddCommentFromDetailViewController:nil withTag:shareController.tag andUsername:[self getUsername] andComment:caption andStixStringID:@"COMMENT"]; 
        }
        
        // update popularity for SHARE
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:shareController.tag.tagID, nil];
        [kh execute:@"incrementPopularity" withParams:params withCallback:nil withDelegate:self];
    }
    [nav popToViewController:tabBarController animated:YES];
    [nav setNavigationBarHidden:NO];
    [nav.view setFrame:CGRectMake(0, 0, 320, 480+TABBAR_BUTTON_DIFF_PX)]; // forces bottom of tabbar to be 40 px
}

-(void)sharePixDialogDidFail:(int)errorType {
    if (errorType == 0) {
        // upload picture malfunction
        //UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Sharing Failed" message:@"It seems that our Share pages are under maintenance. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //[alertView show];
        [self showAlertWithTitle:@"Sharing Failed" andMessage:@"It seems that our Share pages are under maintenance. Please try again later." andButton:@"OK" andOtherButton:nil andAlertType:ALERTVIEW_SIMPLE];
    }
    else if (errorType == 1) {
        // asihttp request timeout
        //UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Low Connectivity" message:@"Could not complete your Share request. Please try again later." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        //[alertView setTag:ALERTVIEW_SHAREFAIL];
        //[alertView show];
        [self showAlertWithTitle:@"Low Connectivity" andMessage:@"Could not complete your Share request. Please try again later." andButton:@"Cancel" andOtherButton:@"Try again" andAlertType:ALERTVIEW_SHAREFAIL];
    }
}


@end


