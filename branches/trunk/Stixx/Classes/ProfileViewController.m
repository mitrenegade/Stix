//
//  ProfileViewController.m
//  ARKitDemo
//
//  Created by Administrator on 7/11/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "ProfileViewController.h"

@implementation ProfileViewController

@synthesize logoutScreenButton;
@synthesize friendCountButton;
@synthesize stixCountButton;
@synthesize delegate;
@synthesize nameLabel;
@synthesize buttonInstructions;
@synthesize photoButton;
@synthesize loginController;
@synthesize friendController;
@synthesize attemptedUsername;
@synthesize k;

-(id)init
{
	self = [super initWithNibName:@"ProfileViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"Profile"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_me.png"];
	[tbi setImage:i];
    
    k = nil;
    k = [[Kumulos alloc]init];
    [k setDelegate:self];    
    //isLoggedIn = NO;
    return self;

}

-(void)viewDidLoad {
    [super viewDidLoad];
    
	if (k == nil)
    {
        k = [[Kumulos alloc]init];
        [k setDelegate:self];    
    }
    loginController = [[LoginViewController alloc] init];
    loginController.delegate = self;
	//return self;
}

/***** logging in with a username ****/

-(void)firstTimeLogin {
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Welcome!"];
    [alert setMessage:@"Because this is your first time, please login or create an account!"];
    [alert show];
    [alert release];

    //[self showLoginScreen:nil];
    // hack todo: this screen doesnt show
}

-(IBAction)showLoginScreen:(id)sender{
    [self presentModalViewController:loginController animated:YES];
}

-(void)loginWithUsername:(NSString *)name {
    // called by delegate, first time when no data has been loaded from kumulos
    NSLog(@"Trying to login as %@", name);
    if (k == nil) {
        k = [[Kumulos alloc]init];
        [k setDelegate:self];    
    }
    [k getUserWithUsername:name];
    attemptedUsername = [NSString stringWithFormat:@"%@", name];//[name retain];

    //[self didSelectUsername:name withResults:nil];
}

// LoginViewDelegate - username is the name used to login, now need to get other info
- (void)didSelectUsername:(NSString *)name withResults:(NSArray *)theResults {
    NSLog(@"Selected username: %@", name);
    for (NSMutableDictionary * d in theResults) {
        NSString * newname = [d valueForKey:@"username"];
        if ([newname isEqualToString:name] == NO) 
            continue;
        
        [self.nameLabel setText:name];
        UIImage * newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
        if (newPhoto) {
            [photoButton setImage:newPhoto forState:UIControlStateNormal];
            //NSLog(@"User %@ has photo of dimensions %f %f\n", name, newPhoto.size.width, newPhoto.size.height);
        }
        else
        {
            newPhoto = [[UIImage imageNamed:@"graphic_nouser.png"] retain];
            [photoButton setImage:newPhoto forState:UIControlStateNormal];
            [photoButton setTitle:@"" forState:UIControlStateNormal]; 
        }
        // badge count array
        NSMutableDictionary * stix = [KumulosData dataToDictionary:[d valueForKey:@"stix"]]; // returns a dictionary whose one element is a dictionary of stix
        NSLog(@"DidLoginWithUsername: %@", name);
        
        // total Pix count
        int totalTags = [[d valueForKey:@"totalTags"] intValue];
        
        [delegate didLoginWithUsername:name andPhoto:newPhoto andStix:stix andTotalTags:totalTags];
        [newPhoto release];
    }
    
    //[loginScreenButton setTitle:@"Switch account" forState:UIControlStateNormal];
    [loginController dismissModalViewControllerAnimated:YES]; // do not dismiss until now, so profileView's viewWillAppear will not be summoned, causing login with old delegate.username
}

- (void)didCancelLogin {
    // did not want to login
    // if we are still anonymous, we should increment badges
    if ([delegate isLoggedIn] == NO) // not needed
    {
        [delegate didCancelFirstTimeLogin]; // does nothing
    }
}

// getUserWithUsername in ProfileViewController is a login operation that populates the profile with all the new user's info
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserDidCompleteWithResult:(NSArray*)theResults {
    if ([theResults count] > 0)
    {
        for (NSMutableDictionary * d in theResults) {
            NSString * name = [d valueForKey:@"username"];
            [self didSelectUsername:name withResults:theResults];
            // should only have one
        }
    }
    if ([theResults count] == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc]init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setTitle:[NSString stringWithFormat:@"The username %@ doesn't seem to exist! Please try logging in again or adding a new account.", attemptedUsername]];
        [alert show];
        [alert release];
        
        [delegate didLogout]; // force logout
    }
    //[attemptedUsername release];
}

-(IBAction) didClickLogoutButton:(id)sender {
#if 0
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want to log out of account %@?", [delegate getUsername]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Log me out!", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
#else
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                    message:@"Do you want to log out?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Log me out!", nil];    
    [alert show];
    [alert release];
#endif
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Button index: %d", buttonIndex);    
    // 0 = cancel
    // 1 = logout
    if (buttonIndex == 1)
        [self showLogoutScreen:nil];
}

-(IBAction) showLogoutScreen:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Logout successful"];
    [alert setMessage:[NSString stringWithFormat:@"You have been logged out from %@.", [delegate getUsername]]];
    [alert show];
    [alert release];
    
    [delegate didLogout];
}

/***** modifying user photo *******/

- (void)changePhoto:(id)sender {
    if (![delegate isLoggedIn]) // show login screen
    {
        [self showLoginScreen:nil];
    }
    else
    {
        [self takeProfilePicture];
    }
}

-(void)takeProfilePicture {
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
    NSLog(@"Adding photo of size %f %f to user %@", rounded.size.width, rounded.size.height, [delegate getUsername]);
    [photoButton setImage:rounded forState:UIControlStateNormal];
    [self.delegate didChangeUserphoto:rounded];

    // add to kumulos
    [k addPhotoWithUsername:[delegate getUsername] andPhoto:img];
    [picker release];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPhotoDidCompleteWithResult:(NSNumber*)affectedRows;
{
    NSLog(@"Added photo to username %@", [delegate getUsername]);

    // force friendView to update photo after we know it is in kumulos
    [self.delegate checkForUpdatePhotos];
}

/*** other actions ****/

-(IBAction)closeInstructions:(id)sender;
{
    [buttonInstructions setHidden:YES];
}

-(void)administratorModeResetAllStix {
    // hack: resets/creates stix for all existing users
    [k getAllUsers];
}
-(IBAction)adminStixButtonPressed:(id)sender
{
    //[self administratorModeResetAllStix];
    //[self administratorModeIncrementStix];
    [self.delegate didPressAdminEasterEgg];
}

// used only by administratorModeResetAllStix
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults {

    for (NSMutableDictionary * d in theResults) {
        NSString * name = [d valueForKey:@"username"];
        NSMutableDictionary * stix = [[BadgeView generateDefaultStix] retain];
        NSMutableData * data = [[KumulosData dictionaryToData:stix] retain];
        [k addStixToUserWithUsername:name andStix:data];
        [data autorelease];
        [stix autorelease];
    }
 }

-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addStixToUserDidCompleteWithResult:(NSArray *)theResults {
    NSMutableDictionary * d = [theResults objectAtIndex:0];
    NSString * name = [d valueForKey:@"username"];
    NSLog(@"Added new stix for %@ to Kumulos\n", name);
}

-(void)updateFriendCount {
    NSMutableDictionary * allUserPhotos = [self.delegate getUserPhotos];
    int ct = [allUserPhotos count];
    [friendCountButton setTitle:[NSString stringWithFormat:@"%d Friends", ct] forState:UIControlStateNormal];
}

-(void)updatePixCount {
    //int ct = [delegate getStixCount:BADGE_TYPE_FIRE] + [delegate getStixCount:BADGE_TYPE_ICE];
    int ct = [delegate getUserTagTotal];
    [stixCountButton setTitle:[NSString stringWithFormat:@"%d Pix", ct] forState:UIControlStateNormal];
}

-(void)friendCountButtonClicked:(id)sender {
    //[self presentModalViewController:friendController animated:NO];
    [self.view addSubview:friendController.view];
    [friendController viewWillAppear:YES];
    friendViewIsDisplayed = YES;
}

-(void)stixCountButtonClicked:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Beta Version"];
    [alert setMessage:@"My Pix Feed coming soon!"];
    [alert show];
    [alert release];
}

-(IBAction)feedbackButtonClicked:(id)sender {
    [self.delegate didClickFeedbackButton:@"Profile view"];
}

/**** friendsViewControllerDelegate ****/
// badgeViewDelegate forwarded from friendsViewDelegate
- (void)checkForUpdatePhotos {[self.delegate checkForUpdatePhotos];}
-(NSMutableDictionary *)getUserPhotos {return [self.delegate getUserPhotos];}
- (NSString*)getUsername {return [self.delegate getUsername];}

-(int)getStixCount:(NSString*)stixStringID {return [delegate getStixCount:stixStringID];}
-(void)didCreateBadgeView:(UIView*)newBadgeView {[self.delegate didCreateBadgeView:newBadgeView];}

-(void)didDismissFriendView {
    friendViewIsDisplayed = NO;
}

-(void)didSendGiftStix:(NSString *)stixStringID toUsername:(NSString *)friendName {
    [self.delegate didSendGiftStix:stixStringID toUsername:friendName];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"Set config namelabel as %@", username);
    
    if (1) //[delegate isLoggedIn])
    {
        NSLog(@"Profile view appearing with username: %@", [delegate getUsername]);
        //[k getUserWithUsername:[delegate getUsername]];
        [nameLabel setText:[delegate getUsername]];
        [photoButton setImage:[delegate getUserPhoto] forState:UIControlStateNormal];
        [photoButton setBackgroundColor:[UIColor blackColor]];
    }
    
    
    [self updateFriendCount];
    [self updatePixCount];
    
    if (friendViewIsDisplayed)
        [friendController viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {    
    //[loginScreenButton release];
    //loginScreenButton = nil;
    [stixCountButton release];
    stixCountButton = nil;
    [friendCountButton release];
    friendCountButton = nil;
    [nameLabel release];
    nameLabel = nil;
    [photoButton release];
    photoButton = nil;
    [buttonInstructions release];
    buttonInstructions = nil;

    [super viewDidUnload];
}


- (void)dealloc {
    [k release]; 
    [loginController release];
    //[loginScreenButton release];
    //loginScreenButton = nil;
    [stixCountButton release];
    stixCountButton = nil;
    [friendCountButton release];
    friendCountButton = nil;
    [nameLabel release];
    nameLabel = nil;
    [photoButton release];
    photoButton = nil;
    [buttonInstructions release];
    buttonInstructions = nil;
    [super dealloc];
}


@end
