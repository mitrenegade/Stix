//
//  LoginViewController.m
//  KickedIntoShape
//
//  Created by Administrator on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"


@implementation LoginViewController

@synthesize loginName, loginButton, loginPassword, addUserButton, cancelButton, delegate;
@synthesize activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[loginName setTag:1];
        //[loginPassword setTag:2];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSMutableData * ) arrayToData:(NSMutableArray *) dict {
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:@"dictionary"];
    [archiver finishEncoding];
    [archiver release];
    return [data autorelease];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
	return YES;
}

- (IBAction)loginButtonPressed:(id)sender{
    [loginName resignFirstResponder];
    [loginPassword resignFirstResponder];
    [self doLogin];
}

-(void)doLogin{
    
    [activityIndicator startAnimating];    

    //we want to log user in
    NSString* username = [loginName text];
    NSString* password = [loginPassword text];
    
    Kumulos* k = [[Kumulos alloc]init];
    [k setDelegate:self];
    //[self showLoadingIndicator];
    [k userLoginWithUsername:username andPassword:[k md5:password]];
}
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation userLoginDidCompleteWithResult:(NSArray*)theResults{

    NSString* username = [loginName text];
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];

    if ([theResults count]) {
        [alert setTitle:@"Success"];
        [alert setMessage:@"You are now logged in"];
        [self.delegate didSelectUsername:username withResults:theResults];
        [self dismissModalViewControllerAnimated:YES];
    }else {
        [alert setTitle:@"Whoops"];
        [alert setMessage:@"Sorry we could not log you in."];
    }
    
    [activityIndicator stopAnimating];

    [alert show];
    [alert release];
    [kumulos release];
}


- (void) kumulosAPI:(kumulosProxy*)kumulos apiOperation:(KSAPIOperation*)operation didFailWithError:(NSString*)theError {
    NSLog(@"Kumulos in LoginViewController failed: error: %@", theError);
}

- (IBAction) cancelButtonPressed:(id)sender {
    [delegate didCancelLogin];
    [self dismissModalViewControllerAnimated:YES];    
}

- (IBAction)addUserButtonPressed:(id)sender
{
    [loginName resignFirstResponder];
    [loginPassword resignFirstResponder];
    [self addUser];
}

-(void) addUser{
    
    [activityIndicator startAnimating];

    //Get values
    NSString* username = [loginName text];
    NSString* password = [loginPassword text];
    
    if (username == nil || password == nil) {
        UIAlertView* alert = [[UIAlertView alloc]init];
        [alert addButtonWithTitle:@"OK"];
        [alert setDelegate:nil];
        [alert setTitle:@"Whoops"];
        [alert setMessage:@"You need to input all fields"];
        [alert show];
        [alert release];
        return;
    }

    //We want to register
    Kumulos* k = [[Kumulos alloc]init];
    [k setDelegate:self];
    [k getUserWithUsername:username]; // check if user already exists
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserDidCompleteWithResult:(NSArray*)theResults {
   
    if ([theResults count] > 0)
    {
        UIAlertView* alert = [[UIAlertView alloc]init];
        [alert addButtonWithTitle:@"OK"];
        [alert setDelegate:nil];
        [alert setTitle:@"Whoops"];
        [alert setMessage:@"Username already exists!"];
        [alert show];
        [alert release];
        [kumulos release];
        return;
    }
    
    // in LoginViewController, getUserDidComplete causes a new user to be created        
    NSString* username = [loginName text];
    NSString* password = [loginPassword text];
    UIImage * img = [UIImage imageNamed:@"emptyuser.png"];
    NSData * photo = UIImagePNGRepresentation(img);

    [kumulos addUserWithUsername:username andPassword:[kumulos md5:password] andPhoto:photo];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addUserDidCompleteWithResult:(NSNumber*)newRecordID{

    // create stix counts - not used by loginViewController
    NSString* username = [loginName text];
    NSMutableArray * stix = [[self.delegate generateDefaultStix] retain];   
    NSMutableData * data = [[self arrayToData:stix] retain];
    [kumulos addStixToUserWithUsername:username andStix:data];
    [data release];
    [stix release];
}

-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addStixToUserDidCompleteWithResult:(NSArray *)theResults {
    
    //[self hideLoadingIndicator];
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    [alert setTitle:@"Success"];
    [alert setMessage:@"New user added. You are now logged in."];
    
    NSString* username = [loginName text];
    [self.delegate didSelectUsername:username withResults:theResults];
    //[self dismissModalViewControllerAnimated:YES]; // do not dismiss until delegate tells us it is done changing the username
    [alert show];
    [alert release];
    [kumulos release];
    
    [activityIndicator stopAnimating];
}

@end
