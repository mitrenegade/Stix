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
@synthesize facebookName, facebookEmail, facebookID;
@synthesize k;
@synthesize activityIndicator;

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

#pragma mark activityIndicator

-(void)startActivityIndicator {
    [loginButton setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    [loginButton setHidden:NO];
}

#pragma mark login or join

-(void)addUser {
    NSString* username = facebookName;
    NSString* password = [NSString stringWithFormat:@"%d", facebookID];
    NSString * email = facebookEmail;
#if 0
    UIImage * img = [UIImage imageNamed:@"graphic_nopic.png"];
#else
    NSURL * url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%d/picture", facebookID]];
    CGSize newSize = CGSizeMake(90, 90);
    UIImage * img = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]] resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
#endif
    NSData * photo = UIImageJPEGRepresentation(img, .8);
    
    //[kumulos addEmailToUserWithUsername:username andEmail:email];
    NSMutableDictionary * stix = [[BadgeView generateDefaultStix] retain];   
    NSMutableData * stixData = [[KumulosData dictionaryToData:stix] retain];
    //[kumulos addStixToUserWithUsername:username andStix:data];
    
    // add auxiliary data
    NSMutableDictionary * auxInfo = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * stixOrder = [[NSMutableDictionary alloc] init];
    int orderct = 0;
    [stixOrder setObject:[NSNumber numberWithInt:orderct++] forKey:@"FIRE"]; 
    [stixOrder setObject:[NSNumber numberWithInt:orderct++] forKey:@"ICE"]; 
    NSEnumerator *e = [stix keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        int ct = [[stix objectForKey:key] intValue];
        NSLog(@"Stix %@ count %d", key, ct);
        if (ct != 0)
            NSLog(@"Here!");
        if (![key isEqualToString:@"FIRE"] && ![key isEqualToString:@"ICE"]) {
            if (ct != 0)
                [stixOrder setObject:[NSNumber numberWithInt:orderct++] forKey:key];
        }
    }
    [auxInfo setValue:stixOrder forKey:@"stixOrder"];
    
    NSMutableSet * friendsList = [[NSMutableSet alloc] init];
    [friendsList addObject:@"bobo"];
    [friendsList addObject:@"willh103"];
    [auxInfo setValue:friendsList forKey:@"friendsList"];
    
    NSData * auxData = [[KumulosData dictionaryToData:auxInfo] retain];
    [k updateAuxiliaryDataWithUsername:username andAuxiliaryData:auxData];
    [auxData release];
    
    int totalTags = 0;
    int bux = NEW_USER_BUX;
    
    NSLog(@"FacebookLoginController: Adding user %@ with facebookID %d and email %@", username, facebookID, email);
    
    //[k createUserWithUsername:username andPassword:[k md5:password] andEmail:email andPhoto:photo andStix:stixData andAuxiliaryData:auxData andTotalTags:totalTags andBux:bux];
    [k addUserWithUsername:username andPassword:[k md5:password] andEmail:email andPhoto:photo andStix:stixData andAuxiliaryData:auxData andTotalTags:totalTags andBux:bux andFacebookID:facebookID];
    // MRC
    [stixData release];
    [stix release];
    
}

-(void)loginUser {
    NSString* username = facebookName;
    NSString* password = [NSString stringWithFormat:@"%d", facebookID];

    //[self showLoadingIndicator];
    if ([password isEqualToString:@"admin"]) {
        [k adminLoginWithUsername:username];
    } else {
        NSLog(@"FacebookLoginController: Logging in user %@ with facebookID %d using password %@", username, facebookID, password);
        [k userLoginWithUsername:username andPassword:[k md5:password]];
    }
}

-(void)updateExistingUser:(NSString*)username withFacebookID:(int)newFacebookID {
    NSString* password = [NSString stringWithFormat:@"%d", newFacebookID];
    NSURL * url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%d/picture", facebookID]];
    CGSize newSize = CGSizeMake(90, 90);
    UIImage * img = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]] resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
    NSData * photo = UIImageJPEGRepresentation(img, .8);
//    [k updateUserWithEmailWithEmail:facebookEmail andUsername:username andPassword:[k md5:password] andFacebookID:newFacebookID];
    [k updateUserByEmailWithEmail:facebookEmail andUsername:username andPassword:[k md5: password] andPhoto:photo andFacebookID:newFacebookID];
}

- (void)didSelectUsername:(NSString *)name withResults:(NSArray *)theResults {
    NSLog(@"FacebookLoginController: Selected username: %@", name);
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
    if (1) { // loginController.bJoinOrLogin == 1) { // login
        bux = [[d valueForKey:@"bux"] intValue];
        totalTags = [[d valueForKey:@"totalTags"] intValue];
    }
    //else { // join
    //    bux = NEW_USER_BUX; // should be set in kumulos but go ahead and set it here
    //    totalTags = 0;
    //}
    
    // set First time user flags
    bool firstTimeUser = NO; 
    //if (loginController.bJoinOrLogin == 0) { // join 
    //    firstTimeUser = YES;
    //}        
    //else {
    //    firstTimeUser = NO;
    //}        
    
    /* auxiliary data */
    //NSMutableData * data = [d valueForKey:@"auxiliaryData"];
    NSMutableDictionary * auxiliaryData;
    NSMutableDictionary * stixOrder = nil;
    NSMutableSet * friendsList = nil;
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
//    [loginController.view removeFromSuperview];
    [delegate didLoginFromSplashScreenWithUsername:name andPhoto:newPhoto andStix:stix andTotalTags:totalTags andBuxCount:bux andStixOrder:stixOrder andFriendsList:friendsList isFirstTimeUser:firstTimeUser];
    [stix release]; // MRC
    [newPhoto release]; // MRC
}


#pragma mark IBOutlet button actions
-(IBAction)didClickJoinButton:(id)sender {
    [self.delegate doFacebookLogin];
    NSLog(@"Did click Facebook Login button");
    [self startActivityIndicator];
}

#pragma mark - facebook

/* To do facebook login this procedure should be followed:
 1. either join, or login, or use facebook
 2. if using facebook, check to see if returned ID exists in database
 3. if no id exists, then prompt to join by creating a username (JOIN)
 4. if id exists, go ahead and login (LOGIN)
 5. add facebookID to kumulos if JOIN
 */

-(void)didGetFacebookName:(NSString *)name andEmail:(NSString *)email andID:(int)fbID {
    NSLog(@"Received Facebook info: name %@ email %@ id %d", name, email, fbID);
    
    [self setFacebookID:fbID];
    [self setFacebookName:name];
    [self setFacebookEmail:email];
    
    // check Kumulos for facebook id existence
    [k getFacebookUserWithFacebookID:fbID];
}

-(void)didCreateHandle:(UIButton*)sender {
    //NSLog(@"Handle created: %@", [loginName text]);
}

#pragma mark KumulosDelegate functions

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getFacebookUserDidCompleteWithResult:(NSArray *)theResults {
    
    if ([theResults count] == 0) {
        // new user - JOIN
        //NSLog(@"Facebook ID does not exist in user database - creating new user");
        //[self addUser];
        
        // new facebook id, but check to see if email already exists
        [k getUserByEmailWithEmail:facebookEmail];
    }
    else {
        // existing user - LOGIN
        NSLog(@"Facebook ID found! Logging in existing user.");
        [self loginUser];
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addUserDidCompleteWithResult:(NSArray *)theResults {
    NSString* username = facebookName;
    
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"OK"];
    [alert setTitle:@"Success"];
    [alert setMessage:[NSString stringWithFormat:@"New User %@ created!", username]];
    [alert show];
    [alert release];
    
    [self stopActivityIndicator];
    [self didSelectUsername:username withResults:theResults];
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
        [alert setTitle:@"Whoops"];
        [alert setMessage:@"Sorry we could not log you in: invalid password."];
    }
    
    [self stopActivityIndicator];
    [alert show];
    [alert release];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserByEmailDidCompleteWithResult:(NSArray *)theResults {
    if ([theResults count] == 0) {
        // new user - JOIN
        NSLog(@"Facebook ID and email does not exist in user database - creating new user");
        [self addUser];
    }
    else {
        // existing user - LOGIN
        NSLog(@"Email found! Logging in existing user.");
        NSLog(@"changing username to %@", facebookName);
        [self updateExistingUser:facebookName withFacebookID:facebookID];
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation updateUserByEmailDidCompleteWithResult:(NSNumber *)affectedRows {
    [self loginUser];
}

@end
