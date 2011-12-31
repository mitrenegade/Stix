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
    [self presentModalViewController:loginController animated:YES];
}

-(IBAction)didClickJoinButton:(id)sender {
    loginController.bJoinOrLogin = 0;
    [self presentModalViewController:loginController animated:YES];
}

- (void)didSelectUsername:(NSString *)name withResults:(NSArray *)theResults {
    NSLog(@"Selected username: %@", name);
    for (NSMutableDictionary * d in theResults) {
        NSString * newname = [d valueForKey:@"username"];
        if ([newname isEqualToString:name] == NO) 
            continue;        
        UIImage * newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
        // badge count array
        NSMutableDictionary * stix;
        if (loginController.bJoinOrLogin == 1) {
            stix = [[KumulosData dataToDictionary:[d valueForKey:@"stix"]] retain]; // returns a dictionary whose one element is a dictionary of stix
            // total badge count
            int totalTags = [[d valueForKey:@"totalTags"] intValue];
            [delegate didLoginWithUsername:name andPhoto:newPhoto andStix:stix andTotalTags:totalTags];
            [stix release];         }
        else
        {
            stix = [[BadgeView generateDefaultStix] retain];
            NSLog(@"DidLoginWithUsername: %@", name);
            // total badge count
            int totalTags = [[d valueForKey:@"totalTags"] intValue];
            [delegate didLoginWithUsername:name andPhoto:newPhoto andStix:stix andTotalTags:totalTags];
            [stix release]; 
        }
        
        
        [newPhoto release];
    }
    
    [self.delegate didLoginFromSplashScreen]; 
}
     
-(void)didCancelLogin {
    [self.delegate didLogout];
}

@end
