//
//  FacebookLoginController.m
//  Stixx
//
//  Created by Bobby Ren on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookLoginController.h"
#import "UIImage+Resize.h"

@implementation FacebookLoginController

@synthesize loginButton, delegate; //, camera;
@synthesize signInButton, signUpButton;
@synthesize facebookName, facebookEmail, facebookString;
@synthesize k;
@synthesize activityIndicator;
@synthesize navController;
@synthesize camera;
@synthesize usersFacebookUsername, usersFacebookPhotoData;
@synthesize signupController, loginController, usernameController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        k = [[Kumulos alloc] init];
        [k setDelegate:self];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 320, 80, 80)];
    [self.view addSubview:activityIndicator];
    [activityIndicator setHidden:YES];
    
    usersFacebookUsername = nil;
    usersFacebookPhotoData = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [loginButton setAlpha:0];
    [signInButton setAlpha:0];
    [signUpButton setAlpha:0];
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeIn:loginButton forTime:.5 withCompletion:^(BOOL finished) {}];
    [animation doFadeIn:signInButton forTime:.5 withCompletion:^(BOOL finished) {}];
    [animation doFadeIn:signUpButton forTime:.5 withCompletion:^(BOOL finished) {}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark activityIndicator

-(void)startActivityIndicator {
    [loginButton setHidden:YES];
    [signInButton setHidden:YES];
    [signUpButton setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
}

#pragma mark login or join
-(void)addUser {
    NSString* username = facebookName;
    if (usersFacebookUsername)
        username = usersFacebookUsername;
    NSString * email = facebookEmail;
#if 0
    UIImage * img = [UIImage imageNamed:@"graphic_nopic.png"];
#else
    NSData * photo;
    if (!usersFacebookPhotoData) {
        NSURL * url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", facebookString]];
        CGSize newSize = CGSizeMake(90, 90);
        UIImage * img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
        UIImage * resized = [img resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
        photo = UIImageJPEGRepresentation(resized, .8);
    }
    else 
        photo = usersFacebookPhotoData;
#endif
    
    NSMutableDictionary * stix = [BadgeView InitializeFirstTimeUserStix];   
    NSMutableData * stixData = [KumulosData dictionaryToData:stix];
    
    // add auxiliary data
    NSMutableDictionary * auxInfo = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * stixOrder = [[NSMutableDictionary alloc] init];
    int orderct = 0;
    NSEnumerator *e = [stix keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        int ct = [[stix objectForKey:key] intValue];
        NSLog(@"Stix %@ count %d", key, ct);
        if (ct != 0)
            [stixOrder setObject:[NSNumber numberWithInt:orderct++] forKey:key];
    }
    [auxInfo setValue:stixOrder forKey:@"stixOrder"];
    
    /*
    NSMutableSet * friendsList = [[NSMutableSet alloc] init];
    [friendsList addObject:@"bobo"];
    [friendsList addObject:@"willh103"];
    [auxInfo setValue:friendsList forKey:@"friendsList"];
    */
    NSData * auxData = [KumulosData dictionaryToData:auxInfo];
    [k updateAuxiliaryDataWithUsername:username andAuxiliaryData:auxData];
    int totalTags = 0;
    int bux = NEW_USER_BUX;
    
    NSLog(@"FacebookLoginController: Adding user %@ with facebookString %@ and email %@", username, facebookString, email);
    
    [k createFacebookUserWithUsername:username andEmail:email andPhoto:photo andFacebookString:facebookString];
}

-(void)loginUser {
    NSString* username = facebookName;    
    //[self checkForRitaPelosiBug:facebookString];
    NSLog(@"LoginUser");
#if 0
    //NSString* password = [NSString stringWithFormat:@"%d", 0];
        NSLog(@"FacebookLoginController: Logging in user %@ using password %@", username, password);
        [k userLoginWithUsername:username andPassword:[k md5:password]];
#else
    NSLog(@"FacebookLoginController: Logging in user %@ with facebookString %@", username, facebookString);
    [k loginViaFacebookStringWithFacebookString:facebookString];
#endif
}

- (void)didSelectUsername:(NSString *)name withResults:(NSArray *)theResults {
    NSLog(@"FacebookLoginController: Selected username: %@", name);
    //for (NSMutableDictionary * d in theResults) {
    NSMutableDictionary * d = [theResults objectAtIndex:0];
    NSString * newname = [d valueForKey:@"username"];
    NSNumber * userID = [d valueForKey:@"allUserID"];
    NSString * email = [d valueForKey:@"email"];
    NSLog(@"Userid: %@ email: %@", userID, email);
    if (!email) {
        NSLog(@"No email! facebookString %@ facebookEmail %@", facebookString, facebookEmail);
        email = facebookEmail;
    }
    if ([[newname lowercaseString] isEqualToString:[name lowercaseString]] == NO) 
        return;
    UIImage * newPhoto = nil;
    if ([d valueForKey:@"photo"])
        newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
    else {
        NSLog(@"nil photo");
    }
    // badge count array
    NSMutableDictionary * stix = [KumulosData dataToDictionary:[d valueForKey:@"stix"]]; // returns a dictionary whose one element is a dictionary of stix
    // total badge count
    //int totalTags;
    //int bux;
    //if (1) { // loginController.bJoinOrLogin == 1) { // login
    //    bux = [[d valueForKey:@"bux"] intValue];
    //    totalTags = [[d valueForKey:@"totalTags"] intValue];
    //}
    //else { // join
    //    bux = NEW_USER_BUX; // should be set in kumulos but go ahead and set it here
    //    totalTags = 0;
    //}
    
    // set First time user flags
    /* auxiliary data */
    //NSMutableData * data = [d valueForKey:@"auxiliaryData"];
    NSMutableDictionary * auxiliaryData;
    NSMutableDictionary * stixOrder = nil;
    //NSMutableSet * friendsList = nil;
    auxiliaryData = [[NSMutableDictionary alloc] init];
    int ret = [KumulosData extractAuxiliaryDataFromUserData:d intoAuxiliaryData:auxiliaryData];
    if (ret == 1) {
        stixOrder = [auxiliaryData objectForKey:@"stixOrder"];
        //friendsList = [auxiliaryData objectForKey:@"friendsList"];
    }
    else if (ret == 0) {
        stixOrder = nil;
    }
    /*
    else if (ret == 2) {
        //friendsList = nil;
    }
    else {
        stixOrder = nil;
        //friendsList = nil;
    }
     */
//    [loginController.view removeFromSuperview];
    [self stopActivityIndicator];
    // BOBBY here! we get here from userLogin...
    // happens both when we have a facebook prompt (button) and when facebook
    // automatically logs in. 
    // need a method to determine whether it's the first time, and needs to display friendSuggestionController
    [delegate didLoginFromSplashScreenWithUsername:name andPhoto:newPhoto andEmail:email andFacebookString:facebookString andUserID:userID andStix:stix andTotalTags:0 andBuxCount:0 andStixOrder:stixOrder isFirstTimeUser:isFirstTimeUser];
}

#pragma mark IBOutlet button actions
-(IBAction)didClickFacebookLoginButton:(id)sender {
    [loginButton setEnabled:NO];
    [signUpButton setEnabled:NO];
    [signInButton setEnabled:NO];
    [delegate doFacebookLogin];
    NSLog(@"Did click Facebook Login button");
    [self startActivityIndicator];
}

-(void)didCreateHandle:(UIButton*)sender {
    //NSLog(@"Handle created: %@", [loginName text]);
}

#pragma mark - facebook

/* To do facebook login this procedure should be followed:
 1. either join, or login, or use facebook
 2. if using facebook, check to see if returned ID exists in database
 3. if no id exists, then prompt to join by creating a username (JOIN)
 4. if id exists, go ahead and login (LOGIN)
 5. add facebookString to kumulos if JOIN
 */

-(void)didGetFacebookName:(NSString *)name andEmail:(NSString *)email andFacebookString:(NSString*)_facebookString {
    NSLog(@"Received Facebook info: name %@ email %@ facebook %@", name, email, _facebookString);
    
    [self setFacebookString:_facebookString];
    [self setFacebookName:name];
    [self setFacebookEmail:email];
    
    // check Kumulos for facebook id existence
#if 1
    [self loginUser]; // ignore facebook and just login
#else
    /*
    NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:_facebookString, nil];
    KumulosHelper * kh = [[KumulosHelper alloc] init];
    [kh execute:@"getFacebookUser" withParams:params withCallback:@selector(khCallback_didGetFacebookUser:) withDelegate:self];
    [params release];
     */
#endif
}

#pragma mark KumulosDelegate functions

-(void)khCallback_didGetFacebookUser:(NSMutableArray*)theResults {
    NSLog(@"DidGetFacebookUser");
    if ([theResults count] == 0) {
        // new user - JOIN
        //NSLog(@"Facebook ID does not exist in user database - creating new user");
        //[self addUser];
        
        // new facebook id, but check to see if email already exists
        //[k getUserByEmailWithEmail:facebookEmail];
    }
    else {
        // existing user - LOGIN
        NSLog(@"Facebook ID found! Logging in existing user.");
        isFirstTimeUser = NO;
        [self loginUser];
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createFacebookUserDidCompleteWithResult:(NSArray *)theResults {
    NSLog(@"CreateFacebookUser");
 
    NSString* username = facebookName;
    if (usersFacebookUsername)
        username = usersFacebookUsername;
    isFirstTimeUser = YES;

    if (!IS_ADMIN_USER(facebookName))
        [FlurryAnalytics logEvent:@"Signup" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:facebookName, @"SignupByFacebook", nil]];
    
    [self didSelectUsername:username withResults:theResults];
    [delegate didAddNewUserWithResult:theResults];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation userLoginDidCompleteWithResult:(NSArray*)theResults{
    
    NSString* username = facebookName;
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    
    if ([theResults count]) {
        [alert setTitle:@"Success"];
        [alert setMessage:@"You are now logged in"];
        [self didSelectUsername:username withResults:theResults];
    }else {
        NSLog(@"Could not login with username %@ and facebookString %@, checking facebook", facebookName, facebookString);
        
#if 0
        [self addUser];
#else
        [self addUsernameForFacebookUser];
#endif
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation loginViaFacebookStringDidCompleteWithResult:(NSArray *)theResults {
    NSLog(@"LoginViaFacebookString");
    if ([theResults count]) {
        // successful login using given facebookString
        NSMutableDictionary * d = [theResults objectAtIndex:0];
        NSString * username = [d objectForKey:@"username"];
        NSString * _facebookString = [d objectForKey:@"facebookString"];
        [self didSelectUsername:username withResults:theResults];
        // debug
        if (1) {
            NSLog(@"Found %d users in database with facebookString %@", [theResults count], facebookString);
            int ct = 1;
            for (NSMutableDictionary * d2 in theResults) {
                NSString * username = [d2 objectForKey:@"username"];
                NSLog(@"Username %d: %@", ct++, username); 
            }
            if ([theResults count] > 1) {
                if (!IS_ADMIN_USER(facebookName))
                    [FlurryAnalytics logEvent:@"Bug_MultipleUsernames" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:facebookString, @"facebookString", nil]];
            }
        }
    } else {
        NSLog(@"Could not login with username %@ and facebookString %@, checking facebook", facebookName, facebookString);        
#if 0
        // show screen to prompt for a username
        [self addUsernameForFacebookUser];
#else
        // hack: if users were wrongly assigned the overflow facebookID 2147483647, look for username/email
        //[k loginWithNameOrEmailWithLoginName:facebookEmail];
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:facebookEmail, nil];
        [kh execute:@"loginWithNameOrEmail" withParams:params withCallback:@selector(khCallback_didLoginWithNameOrEmail:) withDelegate:self];
#endif
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updateUserByEmailDidCompleteWithResult:(NSNumber *)affectedRows {
    [self loginUser];
}

//-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation loginWithNameOrEmailDidCompleteWithResult:(NSArray *)theResults {
-(void)khCallback_didLoginWithNameOrEmail:(NSArray*)returnParams {
    NSArray * theResults = [returnParams objectAtIndex:0];
    // BOBBY: if never comes back here, never proceeds. needs a timeout
    [self stopActivityIndicator];
    if ([theResults count] == 0) {
        // this is a legitimate new user (facebookString and facebookEmail are not in our database)
        // show screen to prompt for a username
        [self addUsernameForFacebookUser];
        return;
    }
    else {
        NSLog(@"%d results found", [theResults count]);
        if ([theResults count] > 1) {
            if (!IS_ADMIN_USER(facebookName))
                [FlurryAnalytics logEvent:@"Bug_MultipleUsernames" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:facebookEmail, @"facebookEmail", nil]];
        }
        for (NSMutableDictionary * d in theResults) {
            [self setFacebookName:[d objectForKey:@"username"]];
            [self setFacebookEmail:[d objectForKey:@"email"]];
            NSString * _facebookString = [d objectForKey:@"facebookString"];
            
            [self checkForRitaPelosiBug:_facebookString];
            //[self loginUser];
            [self didSelectUsername:facebookName withResults:theResults];
        }
    }
}

-(void)checkForRitaPelosiBug:(NSString*)_facebookString {
    if (!_facebookString || [_facebookString isEqualToString:@"0"] || [_facebookString isEqualToString:@"2147483647"]) {
        NSLog(@"Found invalid facebookString %@ for existing user %@ with email %@: setting to new facebookString %@", _facebookString, facebookName, facebookEmail, facebookString);
        NSMutableDictionary * newUser = [NSMutableDictionary dictionaryWithObjectsAndKeys: facebookName, @"username", facebookEmail, @"email", facebookString, @"facebookID", nil];
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] init];
        [params addObject:newUser];
        [kh execute:@"setFacebookString" withParams:params withCallback:nil withDelegate:nil];
        
        [self setFacebookString:_facebookString];
        
        if (!IS_ADMIN_USER(newUser))
            [FlurryAnalytics logEvent:@"UpdateRitaPelosiFBString" withParameters:newUser];
        
        isFirstTimeUser = YES;
    }
}

#pragma mark KumulosHelperDelegate functions

-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    NSLog(@"KumulosHelper completed in FacebookLoginController");
    [self performSelector:callback withObject:params afterDelay:0];
}

-(void)kumulosHelperDidFail:(NSString *)function {
    NSLog(@"FacebookLogin: kumulosHelper failed on function %@", function);
    if ([function isEqualToString:@"loginWithNameOrEmail"]) {
        // also in requestFailed in FacebookHelper for error -1001
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Login Timeout" message:[NSString stringWithFormat:@"Time ran out while searching for user %@", facebookEmail] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [self shouldShowButtons];
    }
}

-(void)kumulosHelperGetFacebookUserDidFail {
#if 0
    NSLog(@"Facebook login failed! Kumulos had some error. trying to login again");
    [self didGetFacebookName:facebookName andEmail:facebookEmail andFacebookString:facebookString];
#else
    // also in requestFailed in FacebookHelper for error -1001
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Facebook login timed out. Try again when there is better connectivity!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
#endif
}

#pragma mark nonfacebook signup/login use chain

-(IBAction)didClickSignUp:(id)sender {
    [loginButton setEnabled:NO];
    [signUpButton setEnabled:NO];
    [signInButton setEnabled:NO];
    signupController = [[SignupViewController alloc] init];
    [signupController setDelegate:self];

    /*
    navController = [[UINavigationController alloc] initWithRootViewController:signupController]; 
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar.png"] forBarMetrics:UIBarMetricsDefault];
    [navController.navigationBar addSubview:nil];
    
    UIButton * buttonBack = [[UIButton alloc] init];
    [buttonBack setImage:[UIImage imageNamed:@"nav_back.png"] forState:UIControlStateNormal];
    [buttonBack setFrame:CGRectMake(8, 7, 50, 35)];
    [buttonBack addTarget:self action:@selector(didCancelSignup:) forControlEvents:UIControlEventTouchUpInside]; //@selector(dismissModalViewControllerAnimated:)];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];  
    [signupController.navigationItem setLeftBarButtonItem:button];
    [signupController.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]]];
     */
    
//    [self presentModalViewController:navController animated:NO ];
    //[self displayNavControllerWithTransition:navController];
    [self shouldDisplaySecondaryViewWithTransition:signupController];
}

/*
 -(IBAction)didCancelSignup:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)didCancelAddUsernameToFacebook {
    [self dismissModalViewControllerAnimated:YES];
    [self stopActivityIndicator];
    [loginButton setHidden:NO];
    [signInButton setHidden:NO];
    [signUpButton setHidden:NO];
}
*/
-(void)didLoginFromEmailSignup:(NSString *)username andPhoto:(UIImage *)photo andEmail:(NSString *)email andUserID:(NSNumber *)userID {
    
    NSLog(@"Email signup: Username: %@ email %@ userid %@ photo %x", username, email, userID, photo);
    
    //[self dismissModalViewControllerAnimated:NO];
    //[self dismissNavControllerWithTransition];
    if (!IS_ADMIN_USER(username))
        [FlurryAnalytics logEvent:@"Signup" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:email, @"SignupByEmail", nil]];
    NSMutableDictionary * d = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               username, @"username",
                               @"0", @"facebookString",
                               email, @"email",
                               userID, @"allUserID",
                               @"", @"twitterString",
//                               UIImagePNGRepresentation(photo), @"photo",
                               nil
                               ];
    if (photo) {
        [d setObject:UIImagePNGRepresentation(photo) forKey:@"photo"];
    }
    else {
        NSLog(@"Nil photo");
    }
    [delegate didAddNewUserWithResult:[NSArray arrayWithObject:d]];
    isFirstTimeUser = YES;
    [self didSelectUsername:username withResults:[NSArray arrayWithObject:d]];
    
    // since it's an email login, force invalidation of the token
    [[[FacebookHelper sharedFacebookHelper] facebook] logout];
}

-(IBAction)didClickSignIn:(id)sender {
    [loginButton setEnabled:NO];
    [signUpButton setEnabled:NO];
    [signInButton setEnabled:NO];
    loginController = [[LoginViewController alloc] init];
    [loginController setDelegate:self];
    
    /*
    navController = [[UINavigationController alloc] initWithRootViewController:loginController]; 
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar.png"] forBarMetrics:UIBarMetricsDefault];
    [navController.navigationBar addSubview:nil];
    
    UIButton * buttonBack = [[UIButton alloc] init];
    [buttonBack setImage:[UIImage imageNamed:@"nav_back.png"] forState:UIControlStateNormal];
    [buttonBack setFrame:CGRectMake(8, 7, 50, 35)];
    [buttonBack addTarget:self action:@selector(didCancelSignup:) forControlEvents:UIControlEventTouchUpInside]; //@selector(dismissModalViewControllerAnimated:)];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];  
    [loginController.navigationItem setLeftBarButtonItem:button];
    [loginController.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]]];
    */
    
    //[self displayNavControllerWithTransition:navController];
    [self shouldDisplaySecondaryViewWithTransition:loginController];
}

-(void)didLoginFromLoginScreen:(NSString*)username withResults:(NSMutableArray*)theResults {
//    [self dismissModalViewControllerAnimated:NO];
//    [self dismissNavControllerWithTransition];
    if (!IS_ADMIN_USER(username))
        [FlurryAnalytics logEvent:@"Login" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:username, @"LoginByUsername", nil]];
    if ([theResults count]) {
//        [alert setTitle:@"Success"];
//        [alert setMessage:@"You are now logged in"];
        [self didSelectUsername:username withResults:theResults];
    }
}

-(void)showAlert:(NSString*)alertMessage {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                       message:alertMessage
                                      delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles: nil];  
    [alert show];
}

-(void)addUsernameForFacebookUser {
    usernameController = [[CreateFacebookUsernameController alloc] init];
    [usernameController setDelegate:self];
    [usernameController setFacebookString:facebookString];
    [usernameController setInitialFacebookName:facebookName];
    
    /*
    navController = [[UINavigationController alloc] initWithRootViewController:usernameController]; 
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar.png"] forBarMetrics:UIBarMetricsDefault];
    [navController.navigationBar addSubview:nil];
    
    UIButton * buttonBack = [[UIButton alloc] init];
    [buttonBack setImage:[UIImage imageNamed:@"nav_back.png"] forState:UIControlStateNormal];
    [buttonBack setFrame:CGRectMake(8, 7, 50, 35)];
    [buttonBack addTarget:self action:@selector(didCancelAddUsernameToFacebook) forControlEvents:UIControlEventTouchUpInside]; //@selector(dismissModalViewControllerAnimated:)];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];  
    [usernameController.navigationItem setLeftBarButtonItem:button];
    [usernameController.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]]];
    */
//    [self presentModalViewController:navController animated:NO];    
//    [self displayNavControllerWithTransition:navController];
    [self shouldDisplaySecondaryViewWithTransition:usernameController];
}

-(void)didAddFacebookUsername:(NSString *)fbUsername andPhoto:(NSData *)photoData {
    // from CreateFacebookUsernameController
//    [self dismissModalViewControllerAnimated:NO];
    //[self dismissNavControllerWithTransition];
    if (!IS_ADMIN_USER(fbUsername))
        [FlurryAnalytics logEvent:@"AddUsernameToFacebook" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:fbUsername, @"NewUsername", facebookName, @"FacebookName", nil]];
    
    [self setUsersFacebookUsername:fbUsername];
    [self setUsersFacebookPhotoData:photoData];
    
    [self addUser];
}

//-(void)displayNavControllerWithTransition:(UINavigationController*)_navController {
-(void)shouldDisplaySecondaryViewWithTransition:(UIViewController*)controller {
    // we want a side to side transition
    // so we have to use the hack for navController.view in addition to presentmodalview
    
    CGRect frameOffscreen = CGRectMake(-320, STATUS_BAR_SHIFT_OVERLAY, 320, 480);
//    [self presentModalViewController:_navController animated:NO];
    [self.view addSubview:controller.view];
    [controller.view setFrame:frameOffscreen];
    
    // must initialize after imageView and stixView actually exist
    CGRect frameOnscreen = CGRectMake(0, STATUS_BAR_SHIFT_OVERLAY, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:controller.view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished){
    }];
}

-(void)shouldDismissSecondaryViewWithTransition:(UIView *)viewToDismiss {
    [loginButton setEnabled:YES];
    [signUpButton setEnabled:YES];
    [signInButton setEnabled:YES];
    CGRect frameOffscreen = CGRectMake(-320, STATUS_BAR_SHIFT, 320, 480);
    // must initialize after imageView and stixView actually exist
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:viewToDismiss toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished){
        [viewToDismiss removeFromSuperview];
    }];
}

-(void)shouldShowButtons {
    [self stopActivityIndicator];
    [loginButton setHidden:NO];
    [signInButton setHidden:NO];
    [signUpButton setHidden:NO];
    [loginButton setEnabled:YES];
    [signUpButton setEnabled:YES];
    [signInButton setEnabled:YES];
}
@end
