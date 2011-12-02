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

// LoginViewDelegate - username is the name used to login, now need to get other info
-(NSMutableArray *) dataToArray:(NSMutableData *) data{ 
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableArray * dict = [unarchiver decodeObjectForKey:@"dictionary"];
    [unarchiver finishDecoding];
    [unarchiver release];
    //[data release];
    return dict;
}

-(NSMutableArray *)generateDefaultStix {
    NSMutableArray * stix = [[[NSMutableArray alloc] init] autorelease];
    [stix insertObject:[NSNumber numberWithInt:20 ] atIndex:BADGE_TYPE_FIRE];
    [stix insertObject:[NSNumber numberWithInt:20 ] atIndex:BADGE_TYPE_ICE];
    return stix;
}

- (void)didSelectUsername:(NSString *)name withResults:(NSArray *)theResults {
    NSLog(@"Selected username: %@", name);
    for (NSMutableDictionary * d in theResults) {
        NSString * newname = [d valueForKey:@"username"];
        if ([newname isEqualToString:name] == NO) 
            continue;        
        UIImage * newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
        // badge count array
        NSMutableArray * stix = [self dataToArray:[d valueForKey:@"stix"]]; // returns a dictionary whose one element is a dictionary of stix
        NSLog(@"DidLoginWithUsername: %@ - currently has stix ", name);
        
        // total badge count
        int totalTags = [[d valueForKey:@"totalTags"] intValue];
        
        [delegate didLoginWithUsername:name andPhoto:newPhoto andStix:stix andTotalTags:totalTags];
        [newPhoto release];
    }
    
    [self.delegate didLoginFromSplashScreen]; 
}
     
-(void)didCancelLogin {
    [self.delegate didLogout];
}

@end
