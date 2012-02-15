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
    if ([newname isEqualToString:name] == NO) 
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

    NSMutableData * data = nil; //[d valueForKey:@"auxiliaryData"];
    // loading auxiliary data for new users
    bool firstTimeUser = YES; 
    bool hasAccessedStore = NO;
    if (data == nil) {
        if (loginController.bJoinOrLogin == 0) { // join 
            firstTimeUser = YES;
            hasAccessedStore = NO;   
        }        
        else {
            firstTimeUser = NO;
            hasAccessedStore = YES;   
        }        
    }
    else {
        @try {
            NSMutableDictionary * auxiliaryData = [[KumulosData dataToDictionary:data] retain];
            if (auxiliaryData != nil)
            {
                firstTimeUser = [[auxiliaryData objectForKey:@"isFirstTimeUser"] boolValue]; 
                hasAccessedStore = [[auxiliaryData objectForKey:@"hasAccessedStore"] boolValue]; 
            }
        }
        @catch (NSException* exception) { 
            firstTimeUser = YES;
            hasAccessedStore = NO;
        }              
    }
    [loginController.view removeFromSuperview];
    [delegate didLoginFromSplashScreenWithUsername:name andPhoto:newPhoto andStix:stix andTotalTags:totalTags andBuxCount:bux isFirstTimeUser:firstTimeUser hasAccessedStore:hasAccessedStore];
}
     
-(void)didCancelLogin {
    [loginController.view removeFromSuperview];
    [self.delegate didLogout];
}

@end
