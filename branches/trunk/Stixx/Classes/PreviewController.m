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
@synthesize newHandle, newPhotoData;

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
    return; // do nothing - eventually can display information
}

#pragma mark button actions

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
        [self startActivityIndicator];
        // do twitter login here
        TwitterHelper * twHelper = [[TwitterHelper alloc] init];
        [twHelper setHelperDelegate:self];
    }];
}

#pragma mark Facebook Login functions
-(void)didGetFacebookName:(NSString *)_name andEmail:(NSString *)_email andFacebookString:(NSString*)_facebookString {
    NSLog(@"Received Facebook info: name %@ email %@ facebook %@", _name, _email, _facebookString);
    
    username = [_name copy];
    email = [_email copy];
    facebookString = [_facebookString copy];

    // check for facebookString
    Kumulos * k = [[Kumulos alloc] init];
    [k setDelegate:self];
    // todo: make general login function
    // like [k loginWithUsername:username orFacebookString:facebookString orTwitterString:twitterString orEmail:email]
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
    
    Kumulos * k = [[Kumulos alloc] init];
    [k setDelegate:self];
    // checks for either username, screenname, or twitterString
    [k loginViaTwitterWithUsername:username andScreenname:twitterHandle andTwitterString:twitterString];
}
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation loginViaTwitterDidCompleteWithResult:(NSArray *)theResults {
    [self didSelectUsernameWithResults:theResults];
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

#pragma mark SignupViewController
-(void)doEmailLogin {
    // show LoginView

    LoginViewController * emailLoginController = [[LoginViewController alloc] init];
    [emailLoginController setDelegate:self];
    [self.navigationController pushViewController:emailLoginController animated:YES];
}


-(void)didLoginFromEmailSignup:(NSString *)username andPhoto:(UIImage *)photo andEmail:(NSString *)email andUserID:(NSNumber *)userID {
    
    [self startActivityIndicator];
    
    NSLog(@"Email signup: Username: %@ email %@ userid %@ photo %x", username, email, userID, photo);
    
    if (!IS_ADMIN_USER(username))
        [FlurryAnalytics logEvent:@"Signup" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:email, @"SignupByEmail", nil]];

    if (photo) {
        [d setObject:UIImagePNGRepresentation(photo) forKey:@"photo"];
    }
    else {
        NSLog(@"Nil photo");
    }

    [self stopActivityIndicator];
    [delegate didLoginFromSplashScreenWithUsername:newname andPhoto:photo andEmail:email andFacebookString:nil andUserID:userID andStix:nil andTotalTags:0 andBuxCount:0 andStixOrder:nil isFirstTimeUser:isFirstTimeUser];
    [delegate didAddNewUserWithResult:[NSArray arrayWithObject:d]];
    
    // since it's an email login, force invalidation of facebook and twitter tokens
    [[[FacebookHelper sharedFacebookHelper] facebook] logout];
    [TwitterHelper logout];
}

#pragma mark CreateHandleDelegate
-(void)didAddHandle:(NSString *)handle andPhoto:(NSData *)photoData {
    // from CreateHandleController
    if (!IS_ADMIN_USER(fbUsername))
        [FlurryAnalytics logEvent:@"AddHandle" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:handle, @"NewHandle", username, @"Username", nil]];
    
    [self setNewHandle:handle];
    [self setNewPhotoData:photoData];
    
//    [self addUser];
    NSLog(@"FacebookLoginController: adding user");
    if (newHandle)
        username = newHandle;
    
    [k createFacebookUserWithUsername:username andEmail:email andPhoto:photoData andFacebookString:facebookString];
    
    // todo: 
    // [k createNewUserWithUsername:username andEmail:email andPhoto:photoData andFacebookString:facebookString andTwitterString:twitterString]
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createFacebookUserDidCompleteWithResult:(NSArray *)theResults {
    // todo: should be createNewUserDidComplete
    
    isFirstTimeUser = YES;
    
    if (!IS_ADMIN_USER(facebookName))
        [FlurryAnalytics logEvent:@"Signup" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:facebookName, @"SignupByFacebook", nil]];
    
    NSString * newname = [d valueForKey:@"username"];
    NSNumber * userID = [d valueForKey:@"allUserID"];
    NSString * newemail = [d valueForKey:@"email"];
    NSString * newfacebookString = [d objectForKey:@"facebookString"];
    NSString * newtwitterString = [d objectForKey:@"twitterString"];
    NSLog(@"DidSelectUsername: %@ Userid: %@ email: %@", newname, userID, newemail);
    
    UIImage * newPhoto = nil;
    if ([d valueForKey:@"photo"])
        newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
    else {
        NSLog(@"nil photo");
    }
    
    [self stopActivityIndicator];
    [delegate didLoginFromSplashScreenWithUsername:newname andPhoto:newPhoto andEmail:newEmail andFacebookString:facebookString andUserID:userID andStix:nil andTotalTags:0 andBuxCount:0 andStixOrder:nil isFirstTimeUser:isFirstTimeUser];
    
    [delegate didAddNewUserWithResult:theResults];
}

#pragma mark DidSelectUsername

-(void)didSelectUsernameWithResults:(NSArray *)theResults {
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
            //email = facebookEmail;
        }
        // todo: add facebook, twitter string
        
        UIImage * newPhoto = nil;
        if ([d valueForKey:@"photo"])
            newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
        else {
            NSLog(@"nil photo");
        }
        
        [self stopActivityIndicator];
        NSLog(@"Closing facebookLoginController!");
        //[self.navigationController popViewControllerAnimated:YES];
        [delegate didLoginFromSplashScreenWithUsername:newname andPhoto:nil andEmail:nil andFacebookString:facebookString andUserID:userID andStix:nil andTotalTags:0 andBuxCount:0 andStixOrder:nil isFirstTimeUser:isFirstTimeUser];
        
        [delegate didAddNewUserWithResult:theResults];
    } 
    else {
        NSLog(@"Could not login with twitter credentials! Creating new user");
        CreateHandleController * usernameController = [[CreateHandleController alloc] init];
        [usernameController setDelegate:self];
        [usernameController setFacebookString:facebookString];
        [usernameController setTwitterString:twitterString];
        if (twitterHandle && [twitterHandle length] > 0) 
            [usernameController setInitialName:twitterHandle]; 
        else
            [usernameController setInitialName:username]; 
        
        [self.navigationController pushViewController:usernameController animated:YES];
    }
}

@end
