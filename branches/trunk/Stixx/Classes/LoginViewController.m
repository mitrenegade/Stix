//
//  LoginViewController.m
//  KickedIntoShape
//
//  Created by Administrator on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

@synthesize loginName, loginButton, loginPassword, joinButton, cancelButton, delegate;
@synthesize activityIndicator;
@synthesize bJoinOrLogin;
@synthesize addPhoto;
@synthesize userImage;
@synthesize loginEmail;
@synthesize loginEmailBG;

static bool usernameExists;

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
    k = [[Kumulos alloc]init];
    [k setDelegate:self];
    // Do any additional setup after loading the view from its nib.
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 300, 80, 80)];
    [self.view addSubview:activityIndicator];
    usernameExists = FALSE;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//    if (newUserImage != nil)
//        [newUserImage release];
    [activityIndicator release];
    [k release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated {
    if (bJoinOrLogin == 0) // join as new user
    {
        [joinButton setHidden:NO];
        [loginButton setHidden:YES];
        [loginEmail setHidden:NO];
        [loginEmailBG setHidden:NO];
        [addPhoto setHidden:YES];
    }
    else // login as existing user
    {
        [joinButton setHidden:YES];
        [loginButton setHidden:NO];
        [loginEmail setHidden:YES];
        [loginEmailBG setHidden:YES];
        [addPhoto setHidden:YES];
    }
    [activityIndicator stopCompleteAnimation];
    [loginName setText:@""];
    [loginPassword setText:@""];
    [loginEmail setText:@""];
    newUserImageSet = false;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
	return YES;
}

/**** adding photo - like takeProfilePicture in profile view ***/

- (IBAction)addPhotoPressed:(id)sender {
#if !TARGET_IPHONE_SIMULATOR
    UIImagePickerController * camera = [[UIImagePickerController alloc] init];
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.showsCameraControls = YES;
    camera.navigationBarHidden = YES;
    camera.toolbarHidden = YES;
    camera.wantsFullScreenLayout = YES;
    camera.allowsEditing = YES;
    camera.delegate = self;
    [self presentModalViewController:camera animated:YES];
#endif
}
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];    
    [picker release];    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage * originalPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage * editedPhoto = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage * newPhoto; 
    //newPhoto = [UIImage imageNamed:@"friend1.png"];
    if (editedPhoto)
        newPhoto = editedPhoto;
    else
        newPhoto = originalPhoto; 
    
    NSLog(@"Finished picking image: dimensions %f %f", newPhoto.size.width, newPhoto.size.height);
    [self dismissModalViewControllerAnimated:TRUE];
    
    // scale down photo
	CGSize targetSize = CGSizeMake(90, 90);		
    /*
     float baseScale =  targetSize.width / newPhoto.size.width;
     CGRect scaledFrame = CGRectMake(0, 0, newPhoto.size.width * baseScale, newPhoto.size.height * baseScale);
     UIGraphicsBeginImageContext(targetSize);
     [newPhoto drawInRect:scaledFrame];	
     UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     */
    UIImage * result = [newPhoto resizedImage:targetSize interpolationQuality:kCGInterpolationDefault];
    UIImage * rounded = [result roundedCornerImage:0 borderSize:2];
    
    // save to album
    UIImageWriteToSavedPhotosAlbum(rounded, nil, nil, nil); 
    
    //NSData * img = UIImageJPEGRepresentation(rounded, .8);
    NSData * img = UIImagePNGRepresentation(rounded);
    [addPhoto setImage:rounded forState:UIControlStateNormal];
    if (userImage == nil)
    {
        userImage = [rounded retain];
        newUserImageSet = YES;
    }
    //[self.delegate didChangeUserphoto:rounded];
    [img release];
    [picker release];
}

/****** loggin in or joining ****/
- (IBAction)loginButtonPressed:(id)sender{
    [loginName resignFirstResponder];
    [loginPassword resignFirstResponder];
    [loginEmail resignFirstResponder];
    [self doLogin];
}

-(void)doLogin{
    
    [activityIndicator startCompleteAnimation];    

    NSString * username = [loginName text];
    [k checkUsernameExistenceWithUsername:username];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation checkUsernameExistenceDidCompleteWithResult:(NSNumber *)aggregateResult {
    if ([aggregateResult intValue] > 0)
        usernameExists = YES;
    else
        usernameExists = NO;
 
    if (bJoinOrLogin == 0) // join
        [self continueJoin];
    else
        [self continueLogin];
}


-(void)continueLogin {
    //we want to log user in
    NSString * username = [loginName text];
    NSString * password = [loginPassword text];
    
    //[self showLoadingIndicator];
    if ([password isEqualToString:@"admin"]) {
        [k adminLoginWithUsername:username];
    } else {
        [k userLoginWithUsername:username andPassword:[k md5:password]];
    }
}

- (void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation adminLoginDidCompleteWithResult:(NSArray *)theResults {
    NSString* username = [loginName text];
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    
    if ([theResults count]) {
        [alert setTitle:@"Admin Success"];
        [alert setMessage:[NSString stringWithFormat:@"You are now Admin logged in as %@", username]];
        [self.delegate didSelectUsername:username withResults:theResults];
        //[self dismissModalViewControllerAnimated:YES];
    }else {
        [alert setTitle:@"Admin Login Failed"];
        [alert setMessage:[NSString stringWithFormat:@"No User exists: %@.", username]];
    }
    
    [activityIndicator stopCompleteAnimation];
    
    [alert show];
    [alert release];
    //[kumulos release];
    
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
        //[self dismissModalViewControllerAnimated:YES];
    }else {
        [alert setTitle:@"Whoops"];
        if (usernameExists) {
            [alert setMessage:@"Sorry we could not log you in: invalid password."];
        }
        else
        {
            [alert setMessage:[NSString stringWithFormat:@"Username %@ does not exist!", username]];
        }
    }
    
    [activityIndicator stopCompleteAnimation];

    [alert show];
    [alert release];
}

- (IBAction) cancelButtonPressed:(id)sender {
    [delegate didCancelLogin];
    [activityIndicator stopCompleteAnimation];
//    [self dismissModalViewControllerAnimated:YES];    
}

- (IBAction)joinButtonPressed:(id)sender
{
    [loginName resignFirstResponder];
    [loginPassword resignFirstResponder];
    [loginEmail resignFirstResponder];
    [self addUser];
}

static int addUserStage;

-(void) addUser{
    
    [activityIndicator startCompleteAnimation];
    NSString* username = [loginName text];
    
    [k checkUsernameExistenceWithUsername:username];
}

-(void)continueJoin {
    //Get values
    NSString* username = [loginName text];
    NSString* password = [loginPassword text];
    NSString * email = [loginEmail text];
    
    if ([username length]==0 || [password length]==0 || [email length]==0) {// || newUserImageSet == NO) {
        UIAlertView* alert = [[UIAlertView alloc]init];
        [alert addButtonWithTitle:@"OK"];
        [alert setDelegate:nil];
        [alert setTitle:@"Whoops"];
        [alert setMessage:@"You need to input all fields"];
        [alert show];
        [alert release];
        [activityIndicator stopCompleteAnimation];
        return;
    }

    //We want to register
    addUserStage = 0;
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
        [activityIndicator stopCompleteAnimation];
        return;
    }
    
    // in LoginViewController, getUserDidComplete causes a new user to be created        
    NSString* username = [loginName text];
    NSString* password = [loginPassword text];
    NSString * email = [loginEmail text];
    UIImage * img = [UIImage imageNamed:@"graphic_nopic.png"];
    
    NSData * photo;
    if (newUserImageSet == YES)
        photo = UIImagePNGRepresentation(userImage);
    else
        photo = UIImageJPEGRepresentation(img, .8);
    
    //[kumulos addEmailToUserWithUsername:username andEmail:email];
    NSMutableDictionary * stix = [[BadgeView generateDefaultStix] retain];   
    NSMutableData * stixData = [[KumulosData dictionaryToData:stix] retain];
    //[kumulos addStixToUserWithUsername:username andStix:data];

    // add auxiliary data
#if 1
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
            //else    
            //    [stixOrder setObject:[NSNumber numberWithInt:-1] forKey:key];
        }
    }
    [auxInfo setValue:stixOrder forKey:@"stixOrder"];
    
    NSMutableSet * friendsList = [[NSMutableSet alloc] init];
    [friendsList addObject:@"bobo"];
    [friendsList addObject:@"willh103"];
    [auxInfo setValue:friendsList forKey:@"friendsList"];

    NSData * auxData = [[KumulosData dictionaryToData:auxInfo] retain];
    [kumulos updateAuxiliaryDataWithUsername:username andAuxiliaryData:auxData];
    [auxData release];
#else
    NSData * auxData = nil;
#endif
    int totalTags = 0;
    int bux = NEW_USER_BUX;
    
    //[kumulos addUserWithUsername:username andPassword:[kumulos md5:password] andPhoto:photo];
    [k createUserWithUsername:username andPassword:[k md5:password] andEmail:email andPhoto:photo andStix:stixData andAuxiliaryData:auxData andTotalTags:totalTags andBux:bux];
    // MRC
    [stixData release];
    [stix release];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createUserDidCompleteWithResult:(NSArray *)theResults {
    NSString* username = [loginName text];

    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"OK"];
    [alert setTitle:@"Success"];
    [alert setMessage:[NSString stringWithFormat:@"New User %@ created!", username]];
    [alert show];
    [alert release];
    [activityIndicator stopCompleteAnimation];
    
    [self.delegate didSelectUsername:username withResults:theResults];
}

@end
