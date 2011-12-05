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
@synthesize newUserImage;
@synthesize loginEmail;
@synthesize loginEmailBG;

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
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 240, 80, 80)];
    [self.view addSubview:activityIndicator];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//    if (newUserImage != nil)
//        [newUserImage release];
    [activityIndicator release];
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
    newUserImageSet = false;
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

/**** adding photo - like takeProfilePicture in profile view ***/

- (IBAction)addPhotoPressed:(id)sender {
    UIImagePickerController * camera = [[UIImagePickerController alloc] init];
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.showsCameraControls = YES;
    camera.navigationBarHidden = YES;
    camera.toolbarHidden = YES;
    camera.wantsFullScreenLayout = YES;
    camera.allowsEditing = YES;
    camera.delegate = self;
    [self presentModalViewController:camera animated:YES];
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
    if (newUserImage == nil)
    {
        newUserImage = [rounded retain];
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

    //we want to log user in
    NSString * username = [loginName text];
    NSString * password = [loginPassword text];
    
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
    
    [activityIndicator stopCompleteAnimation];

    [alert show];
    [alert release];
    [kumulos release];
}


- (void) kumulosAPI:(kumulosProxy*)kumulos apiOperation:(KSAPIOperation*)operation didFailWithError:(NSString*)theError {
    NSLog(@"Kumulos in LoginViewController failed: error: %@", theError);
}

- (IBAction) cancelButtonPressed:(id)sender {
    [delegate didCancelLogin];
    [activityIndicator stopCompleteAnimation];
    [self dismissModalViewControllerAnimated:YES];    
}

- (IBAction)joinButtonPressed:(id)sender
{
    [loginName resignFirstResponder];
    [loginPassword resignFirstResponder];
    [loginEmail resignFirstResponder];
    [self addUser];
}

-(void) addUser{
    
    [activityIndicator startCompleteAnimation];

    //Get values
    NSString* username = [loginName text];
    NSString* password = [loginPassword text];
    NSString * email = [loginEmail text];
    
    if ([username length]==0 || [password length]==0 || [email length]==0) {
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
        [activityIndicator stopCompleteAnimation];
        return;
    }
    
    // in LoginViewController, getUserDidComplete causes a new user to be created        
    NSString* username = [loginName text];
    NSString* password = [loginPassword text];
    UIImage * img = [UIImage imageNamed:@"graphic_nopic.png"];
    
    NSData * photo;
    if (newUserImageSet == YES)
        photo = UIImagePNGRepresentation(newUserImage);
    else
        photo = UIImageJPEGRepresentation(img, .8);

    [kumulos addUserWithUsername:username andPassword:[kumulos md5:password] andPhoto:photo];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addUserDidCompleteWithResult:(NSNumber*)newRecordID{

    // create stix counts - not used by loginViewController
    NSString* username = [loginName text];
    NSString * email = [loginEmail text];
    [kumulos addEmailToUserWithUsername:username andEmail:email];
    NSMutableArray * stix = [[BadgeView generateDefaultStix] retain];   
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
    
    [activityIndicator stopCompleteAnimation];
}

@end
