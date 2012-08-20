//
//  PreviewController.m
//  Stixx
//
//  Created by Bobby Ren on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreviewController.h"

@implementation PreviewController

@synthesize delegate;
@synthesize barBase, buttonNext;
@synthesize handle, photoData;
@synthesize k;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIImageView * logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"txt_stixstergallery"]];
        [self.navigationItem setTitleView:logo];    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(100, 200, 120, 120)];
    [self.view addSubview:activityIndicator];
    [activityIndicator setHidden:YES];
    
    exploreController = [[ExploreViewController alloc] init];
    [exploreController setDelegate:self];
    hasExplore = NO;
    
    k = [[Kumulos alloc]init];
    [k setDelegate:self];    
    //    [self.view addSubview:exploreController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!hasExplore) {
        [self.view insertSubview:exploreController.view belowSubview:barBase];
        hasExplore = YES;
    }
    [self stopActivityIndicator];
    /*
    [self.navigationController setNavigationBarHidden:NO];
    UIImageView * logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"txt_stixstergallery"]];
    [self.navigationItem setTitleView:logo];    
     */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)startActivityIndicator {
    [activityIndicator setHidden:NO];
    [activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [activityIndicator stopCompleteAnimation];
    [activityIndicator setHidden:YES];
}

#pragma mark ExploreViewDelegate
-(UIImage*)getUserPhotoForUsername:(NSString *)username {
    return nil;
}

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID {
    return; // do nothing
}

-(int)getNewestTagID {
    return [delegate getNewestTagID];
}
-(NSString*)getUsername {
    return nil;
}

-(void)shouldDisplayUserPage:(NSString*)username {
    return; // do nothing
}

-(void)pauseAggregation {
    return; // do nothing - not aggregating
}

-(void)shouldDisplayDetailViewWithTag:(Tag*)tag {
    detailController = [[DetailViewController alloc] init];
    [detailController setDelegate:self];    
    [detailController initDetailViewWithTag:tag];
//    [self.navigationController pushViewController:detailController animated:YES];
    [self.view insertSubview:detailController.view belowSubview:barBase];
    [detailController setIsPreview]; 

    UIImage * backImage = [UIImage imageNamed:@"nav_back"];
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(didClickBackButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    return; 
}

#pragma mark button actions

-(void)didClickBackButton {
    // close detailView
    [detailController.view removeFromSuperview];
    [self.navigationItem setLeftBarButtonItem:nil];
}

-(IBAction)didClickNextButton:(id)sender {
    NSLog(@"You ready to log in?");
    loginController = [[PreviewLoginViewController alloc] init];
    [loginController setDelegate:self];
    [self.view addSubview:loginController.view];
#if 1
    [loginController.view setAlpha:0];
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeIn:loginController.view forTime:.5 withCompletion:^(BOOL finished) {
        [self.view addSubview:loginController.view];
    }];
#endif
}

#pragma mark PreviewLoginDelegate

-(void)didCancelLogin {
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeOut:loginController.view forTime:.5 withCompletion:^(BOOL finished) {
        [loginController.view removeFromSuperview];
        loginController = nil;
    }];
}

-(void)doFacebookLogin {
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeOut:loginController.view forTime:.5 withCompletion:^(BOOL finished) {
        [loginController.view removeFromSuperview];
        loginController = nil;
        [self startActivityIndicator];
        [delegate doFacebookLogin];
    }];
}

-(void)doTwitterLogin {
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeOut:loginController.view forTime:.5 withCompletion:^(BOOL finished) {
        [loginController.view removeFromSuperview];
        loginController = nil;
        //[self startActivityIndicator];
        // do twitter login here
        [SHK setRootViewController:self];
        TwitterHelper * twHelper = [[TwitterHelper alloc] init];
        [twHelper setHelperDelegate:self];
        if ([TwitterHelper isServiceAuthorized]) {
            [self startActivityIndicator];
        }
        [twHelper doInitialConnect];
    }];
}

#pragma mark Facebook Login functions
-(void)didGetFacebookName:(NSString *)_name andEmail:(NSString *)_email andFacebookString:(NSString*)_facebookString {
    NSLog(@"Received Facebook info: name %@ email %@ facebook %@", _name, _email, _facebookString);
    
    username = [_name copy];
    email = [_email copy];
    facebookString = [_facebookString copy];

    // check specifically for facebookString
    [k loginViaFacebookStringWithFacebookString:facebookString];
}
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation loginViaFacebookStringDidCompleteWithResult:(NSArray *)theResults {
    [self didSelectUsernameWithResults:theResults];
}

#pragma mark TwitterHelperDelegate

-(void)didInitialLoginForTwitter {
    // start activity indicator running
    // do not show stix users view controller yet
    // ask twitter for credentials
    TwitterHelper * twHelper = [[TwitterHelper alloc] init];
    if ([twHelper isAuthorized]) { // needs to do this to renew token?
        [self startActivityIndicator];
        [twHelper setHelperDelegate:self];
        [twHelper getMyCredentials];
        [delegate didConnectToTwitter]; // only to toggle shareController
    }
    else 
        NSLog(@"After login still not working!");
}

-(void)twitterHelperDidReturnWithCallback:(SEL)callback andParams:(id)params andRequestType:(NSString *)requestType {
    // will be sent back by twitterHelper 
    NSNumber * _service = params;
    NSLog(@"connecting to twitter from friendServices worked! params: service %@ requestType %@", _service, requestType);
    [self performSelector:callback withObject:_service afterDelay:0];
}
-(void)twitterHelperDidFailWithRequestType:(NSString *)requestType {
    if ([requestType isEqualToString:@"directMessage"]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Timeout" message:@"Your invite failed due to connectivity issues...please try again later!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [self stopActivityIndicator];
    }
    else if ([requestType isEqualToString:@"initialConnect"] || [requestType isEqualToString:@"getMyCredentials"]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Timeout" message:@"Twitter is taking too long and can't connect...please try again later!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [self stopActivityIndicator];
    }
}

-(void)didGetTwitterCredentials:(NSDictionary*)results {
    NSLog(@"Did get twitter credentials: %@", results);
    NSEnumerator * e = [results keyEnumerator];
    for (NSString * key in e)
        NSLog(@"Key: %@ value: %@", key, [results objectForKey:key]);
    //NSString * friendsCount = [results objectForKey:@"friends_count"];
    username = [results objectForKey:@"name"];
    twitterHandle = [results objectForKey:@"screen_name"];
    twitterString = [results objectForKey:@"id_str"];
    twitterProfileURL = [results objectForKey:@"profile_image_url_https"];
    
    // checks specifically for twitterString
    NSLog(@"Looking for twitterString %@", twitterString);
    [k loginViaTwitterWithTwitterString:twitterString];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation loginViaTwitterDidCompleteWithResult:(NSArray *)theResults {
    [self didSelectUsernameWithResults:theResults];
}

-(void)kumulosAPI:(kumulosProxy *)kumulos apiOperation:(KSAPIOperation *)operation didFailWithError:(NSString *)theError {
    NSLog(@"Operation failed! %@", theError);
}

#pragma mark Email login

-(void)doEmailSignup {
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeOut:loginController.view forTime:.5 withCompletion:^(BOOL finished) {
        [loginController.view removeFromSuperview];
        loginController = nil;
        [self startActivityIndicator];
        
        // show signup view
        SignupViewController * signupController = [[SignupViewController alloc] init];
        [signupController setDelegate:self];
        
        [self.navigationController pushViewController:signupController animated:YES];
        
        [self stopActivityIndicator];
    }];
}

#pragma mark SignupViewController/LoginViewController delegate
-(void)doEmailLogin {
    // show LoginView

    LoginViewController * emailLoginController = [[LoginViewController alloc] init];
    [emailLoginController setDelegate:self];
    [self.navigationController pushViewController:emailLoginController animated:YES];
}


-(void)didLoginFromEmailSignup:(NSString *)newname andPhoto:(UIImage *)photo andEmail:(NSString *)newemail andUserID:(NSNumber *)userID isFirstTime:(BOOL)isFirstTime {
    
    [self startActivityIndicator];
    isFirstTimeUser = isFirstTime;
    
    NSLog(@"Email signup: Username: %@ email %@ userid %@ photo %@", newname, newemail, userID, photo?@"YES": @"NO");
    
    if (!IS_ADMIN_USER(username))
        [FlurryAnalytics logEvent:@"Signup" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:email, @"SignupByEmail", nil]];

    [self stopActivityIndicator];
    [delegate didLoginFromSplashScreenWithScreenname:newname andPhoto:photo andEmail:newemail andFacebookString:nil andTwitterString:nil andUserID:userID isFirstTimeUser:isFirstTimeUser];
    
    // since it's an email login, force invalidation of facebook and twitter tokens
    [[[FacebookHelper sharedFacebookHelper] facebook] logout];
    [TwitterHelper logout];
}

#pragma mark CreateHandleDelegate
-(void)didAddHandle:(NSString *)_handle andPhoto:(NSData *)_photoData {
    // from CreateHandleController
    if (!IS_ADMIN_USER(handle))
        [FlurryAnalytics logEvent:@"AddHandle" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:handle, @"NewHandle", username, @"Username", nil]];
    
    [self setHandle:_handle];
    [self setPhotoData:_photoData];
    
    NSLog(@"FacebookLoginController: adding user");
    if (handle)
        username = handle;
    
    [k createFacebookUserWithUsername:username andEmail:email andPhoto:photoData andFacebookString:facebookString];
    
    // todo: 
    // [k createNewUserWithUsername:username andEmail:email andPhoto:photoData andFacebookString:facebookString andTwitterString:twitterString]
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createFacebookUserDidCompleteWithResult:(NSArray *)theResults {
    // todo: should be createNewUserDidComplete
    
    isFirstTimeUser = YES;
    
    if ([theResults count] == 0)
        [NSException raise:NSInternalInconsistencyException format:@"CreateFacebookUser completed but did not create user!"];  
    NSMutableDictionary * d = [theResults objectAtIndex:0];

    NSString * newname = [d valueForKey:@"username"];
    NSNumber * userID = [d valueForKey:@"allUserID"];
    NSString * newemail = [d valueForKey:@"email"];
    NSString * newfacebookString = [d objectForKey:@"facebookString"];
    NSString * newtwitterString = [d objectForKey:@"twitterString"];
    
    if (!IS_ADMIN_USER(newname))
        [FlurryAnalytics logEvent:@"Signup" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:newname, @"SignupByFacebook", nil]];
    NSLog(@"DidSelectUsername: %@ Userid: %@ email: %@", newname, userID, newemail);
    
    UIImage * newPhoto = nil;
    if ([d valueForKey:@"photo"])
        newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
    else {
        NSLog(@"nil photo");
    }
    
    [self stopActivityIndicator];
    [delegate didLoginFromSplashScreenWithScreenname:newname andPhoto:newPhoto andEmail:newemail andFacebookString:newfacebookString andTwitterString:newtwitterString andUserID:userID isFirstTimeUser:isFirstTimeUser];
}

#pragma mark DidSelectUsername

-(void)didSelectUsernameWithResults:(NSArray *)theResults {
    NSLog(@"PreviewController: didSelecUsernameWithResults: %d results", [theResults count]);
    if ([theResults count]) {
        // successful login using given facebookString
        NSMutableDictionary * d = [theResults objectAtIndex:0];
        //NSString * username = [d objectForKey:@"username"];
        //NSString * facebookString = [d objectForKey:@"facebookString"];
        //NSString * twitterString = [d objectForKey:@"twitterString"];
        
        NSString * newname = [d valueForKey:@"username"];
        NSNumber * userID = [d valueForKey:@"allUserID"];
        NSString * newemail = [d valueForKey:@"email"];
        NSString * newfacebookString = [d objectForKey:@"facebookString"];
        NSString * newtwitterString = [d objectForKey:@"twitterString"];
        NSLog(@"DidSelectUsername: %@ Userid: %@ email: %@", newname, userID, newemail);
        
        // add email
        if (!newemail) {
            NSLog(@"No email! facebookString %@ facebookEmail %@", facebookString, email);
            newemail = email;
        }
        // will this ever happen? 
        if (!newfacebookString)
            newfacebookString = facebookString;
        if (!newtwitterString)
            newtwitterString = twitterString;
        
        UIImage * newPhoto = nil;
        if ([d valueForKey:@"photo"])
            newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
        else {
            NSLog(@"nil photo");
        }
        
        [self stopActivityIndicator];
        [delegate didLoginFromSplashScreenWithScreenname:newname andPhoto:newPhoto andEmail:newemail andFacebookString:newfacebookString andTwitterString:newtwitterString andUserID:userID isFirstTimeUser:isFirstTimeUser];
    } 
    else {
        NSLog(@"Could not login with twitter credentials! Creating new user");
        CreateHandleController * usernameController = [[CreateHandleController alloc] init];
        [usernameController setDelegate:self];
        [usernameController setFacebookString:facebookString];
        [usernameController setTwitterString:twitterString];
        [usernameController setTwitterProfileURL:twitterProfileURL];
        if (twitterHandle && [twitterHandle length] > 0) 
            [usernameController setInitialName:twitterHandle]; 
        else
            [usernameController setInitialName:username]; 
        
        [self.navigationController pushViewController:usernameController animated:YES];
    }
}

@end
