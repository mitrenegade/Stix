//
//  PreviewLoginViewController.m
//  Stixx
//
//  Created by Bobby Ren on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreviewLoginViewController.h"

@interface PreviewLoginViewController ()

@end

@implementation PreviewLoginViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)didClickEmail:(id)sender {
    /*
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Email Login??" message:[NSString stringWithFormat:@"Y U NO GIVE US YOUR PERSONAL INFO?"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
     */
    [delegate doEmailSignup];
}

-(IBAction)didClickFacebook:(id)sender {
    /*
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Login??" message:[NSString stringWithFormat:@"MARK ZUCKERBERG WOULD BE PROUD. THAT LITTLE PRICK"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    */
    [delegate doFacebookLogin];
}

-(IBAction)didClickTwitter:(id)sender {
    /*
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Login??" message:[NSString stringWithFormat:@"IS THAT ALL YOU DO? TWEET TWEET TWEET ALL DAY"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
     */
    [delegate doTwitterLogin];
}

-(IBAction)didClickCancelLogin:(id)sender {
//-(IBAction)didClickCancelLogin:(id)sender {
#if 1
    //[self.view removeFromSuperview];
    [delegate didCancelLogin];
#else
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeOut:self.view forTime:.5 withCompletion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }]; 
#endif
}

@end
