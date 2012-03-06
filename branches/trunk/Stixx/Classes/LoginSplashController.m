//
//  LoginSplashController.m
//  Stixx
//
//  Created by Bobby Ren on 11/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginSplashController.h"

@implementation LoginSplashController

@synthesize loginButton, joinButton;
@synthesize delegate;
@synthesize camera;
@synthesize loginController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    loginController = [[LoginViewController alloc] init];
    [loginController setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [loginController release];
    loginController = nil;
    [loginButton release];
    loginButton = nil;
    [joinButton release];
    joinButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)didClickLoginButton:(id)sender {
    loginController.bJoinOrLogin = 1;
    [self.view addSubview:loginController.view];
}

-(IBAction)didClickJoinButton:(id)sender {
    loginController.bJoinOrLogin = 0;
    [self.view addSubview:loginController.view];
}

- (void)didSelectUsername:(NSString *)name withResults:(NSArray *)theResults {
    NSLog(@"Selected username: %@", name);
    //for (NSMutableDictionary * d in theResults) {
    NSMutableDictionary * d = [theResults objectAtIndex:0];
    NSString * newname = [d valueForKey:@"username"];
    if ([[newname lowercaseString] isEqualToString:[name lowercaseString]] == NO) 
        return;
    UIImage * newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
    // badge count array
    NSMutableDictionary * stix = [[KumulosData dataToDictionary:[d valueForKey:@"stix"]] retain]; // returns a dictionary whose one element is a dictionary of stix
    // total badge count
    int totalTags;
    int bux;
    if (loginController.bJoinOrLogin == 1) { // login
        bux = [[d valueForKey:@"bux"] intValue];
        totalTags = [[d valueForKey:@"totalTags"] intValue];
    }
    else { // join
        bux = 25; // should be set in kumulos but go ahead and set it here
        totalTags = 0;
    }

    // set First time user flags
    bool firstTimeUser = YES; 
    if (loginController.bJoinOrLogin == 0) { // join 
        firstTimeUser = YES;
    }        
    else {
        firstTimeUser = NO;
    }        
    
    /* auxiliary data */
    NSMutableData * data = [d valueForKey:@"auxiliaryData"];
    NSMutableDictionary * auxiliaryData;
    NSMutableDictionary * stixOrder = nil;
    NSMutableSet * friendsList = nil;
#if 0
    @try {
        auxiliaryData = [KumulosData dataToDictionary:data];
        if (auxiliaryData == nil || ![auxiliaryData isKindOfClass:[NSMutableDictionary class]]) {
            stixOrder = nil;
            friendsList = nil;
        }
        else {
            stixOrder = [auxiliaryData objectForKey:@"stixOrder"]; 
            // debug
            NSEnumerator *e = [stixOrder keyEnumerator];
            id key;
            while (key = [e nextObject]) {
                int ct = [[stixOrder objectForKey:key] intValue];
                if (ct != 0) {
                    int order = [[stixOrder objectForKey:key] intValue];
                    NSLog(@"Stix: %@ order %d", key, order); 
                }
            }
            
            friendsList = [auxiliaryData objectForKey:@"friendsList"];
        }
    }
    @catch (NSException* exception) { 
        NSLog(@"Error! Exception caught while trying to load aux data! Error %@", [exception reason]);
    }    
#else
    auxiliaryData = [[NSMutableDictionary alloc] init];
    int ret = [KumulosData extractAuxiliaryDataFromUserData:d intoAuxiliaryData:auxiliaryData];
    if (ret == 0) {
        stixOrder = [auxiliaryData objectForKey:@"stixOrder"];
        friendsList = [auxiliaryData objectForKey:@"friendsList"];
    }
    else if (ret == 1) {
        stixOrder = nil;
    }
    else if (ret == 2) {
        friendsList = nil;
    }
    else {
        stixOrder = nil;
        friendsList = nil;
    }
#endif
    [loginController.view removeFromSuperview];
    [delegate didLoginFromSplashScreenWithUsername:name andPhoto:newPhoto andStix:stix andTotalTags:totalTags andBuxCount:bux andStixOrder:stixOrder andFriendsList:friendsList isFirstTimeUser:firstTimeUser];
    [stix release]; // MRC
    [newPhoto release]; // MRC
}
     
-(void)didCancelLogin {
    [loginController.view removeFromSuperview];
    [self.delegate didLogout];
}

@end
