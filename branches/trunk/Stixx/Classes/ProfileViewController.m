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
	[super initWithNibName:@"ProfileViewController" bundle:nil];
	
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


-(NSMutableData * ) arrayToData:(NSMutableArray *) dict {
    // used to be dictionaryToData
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:@"dictionary"];
    [archiver finishEncoding];
    [archiver release];
    return [data autorelease];
}
-(NSMutableArray *) dataToArray:(NSMutableData *) data{ 
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableArray * dict = [unarchiver decodeObjectForKey:@"dictionary"];
    [unarchiver finishDecoding];
    [unarchiver release];
    //[data release];
    return dict;
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
    attemptedUsername = [name retain];

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
        NSMutableArray * stix = [self dataToArray:[d valueForKey:@"stix"]]; // returns a dictionary whose one element is a dictionary of stix
        NSLog(@"DidLoginWithUsername: %@ - currently has stix ", name);
        
        // total badge count
        int totalTags = [[d valueForKey:@"totalTags"] intValue];
        
        [delegate didLoginWithUsername:name andPhoto:newPhoto andStix:stix andTotalTags:totalTags];
        [newPhoto release];
    }
    
    //[loginScreenButton setTitle:@"Switch account" forState:UIControlStateNormal];
    [loginController dismissModalViewControllerAnimated:YES]; // do not dismiss until now, so profileView's viewWillAppear will not be summoned, causing login with old delegate.username
    //[self updateStixCount];
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
    [attemptedUsername release];
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

-(void)administratorModeIncrementStix {
    // hack: increment own stix
    for (int i=0; i<5; i++) {
        [delegate incrementStixCount:BADGE_TYPE_FIRE forUser:[delegate getUsername]];
        [delegate incrementStixCount:BADGE_TYPE_ICE forUser:[delegate getUsername]];
    }
}
-(void)administratorModeResetAllStix {
    // hack: resets/creates stix for all existing users
    [k getAllUsers];
}
-(IBAction)adminStixButtonPressed:(id)sender
{
    //[self administratorModeResetAllStix];
    [self administratorModeIncrementStix];
}

// used only by administratorModeResetAllStix
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllUsersDidCompleteWithResult:(NSArray*)theResults {

    for (NSMutableDictionary * d in theResults) {
        NSString * name = [d valueForKey:@"username"];
        NSMutableArray * stix = [[BadgeView generateDefaultStix] retain];
        NSMutableData * data = [[self arrayToData:stix] retain];
        [k addStixToUserWithUsername:name andStix:data];
        [data release];
        [stix release];
    }
 }

-(void) kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation addStixToUserDidCompleteWithResult:(NSArray *)theResults {
    NSMutableDictionary * d = [theResults objectAtIndex:0];
    NSString * name = [d valueForKey:@"username"];
    NSMutableData * data = [d valueForKey:@"stix"];
    NSMutableArray * stix = [[self dataToArray:data] retain];
    NSLog(@"Changed stix counts for %@ to %d and %d\n", name, [[stix objectAtIndex:BADGE_TYPE_FIRE] intValue], [[stix objectAtIndex:BADGE_TYPE_ICE] intValue]);
    [stix release];
}

-(void)updateFriendCount {
    NSMutableDictionary * allUserPhotos = [self.delegate getUserPhotos];
    int ct = [allUserPhotos count];
    [friendCountButton setTitle:[NSString stringWithFormat:@"%d Friends", ct] forState:UIControlStateNormal];
}

-(void)updateStixCount {
    //int ct = [delegate getStixCount:BADGE_TYPE_FIRE] + [delegate getStixCount:BADGE_TYPE_ICE];
    int ct = [delegate getUserTagTotal];
    [stixCountButton setTitle:[NSString stringWithFormat:@"%d Pix", ct] forState:UIControlStateNormal];
}

-(void)showFriendView:(id)sender {
    //[self presentModalViewController:friendController animated:NO];
    [self.view addSubview:friendController.view];
    [friendController viewWillAppear:YES];
    friendViewIsDisplayed = YES;
}

/**** friendsViewControllerDelegate ****/
// badgeViewDelegate forwarded from friendsViewDelegate
- (void)checkForUpdatePhotos {[self.delegate checkForUpdatePhotos];}
-(NSMutableDictionary *)getUserPhotos {return [self.delegate getUserPhotos];}
- (NSString*)getUsername {return [self.delegate getUsername];}

-(int)getStixCount:(int)stix_type {return [delegate getStixCount:stix_type];}
-(int)incrementStixCount:(int)type forUser:(NSString *)name {return [self.delegate incrementStixCount:type forUser:name];}
-(int)decrementStixCount:(int)type forUser:(NSString *)name {return [self.delegate decrementStixCount:type forUser:name];}
-(void)didCreateBadgeView:(UIView*)newBadgeView {[self.delegate didCreateBadgeView:newBadgeView];}

-(void)didDismissFriendView {
    friendViewIsDisplayed = NO;
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
    
    //[badgeFire setImage:[[UIImage imageNamed:@"fire.png"] resizedImage:CGSizeMake(21, 35) interpolationQuality:kCGInterpolationDefault]];
    //[badgeIce setImage:[[UIImage imageNamed:@"ice.png"] resizedImage:CGSizeMake(21, 35) interpolationQuality:kCGInterpolationDefault]];
    /*
    UIImageView * badgeFire = [[BadgeView getBadgeOfType:BADGE_TYPE_FIRE] retain];
    float originX = 190;
    float originY = 150;
    float width = badgeFire.frame.size.width / 2;
    float height = badgeFire.frame.size.height / 2;
    [badgeFire setFrame:CGRectMake(originX, originY, width, height)];
    UIImageView * badgeIce = [[BadgeView getBadgeOfType:BADGE_TYPE_ICE] retain];
    originX = 190;
    originY = 190;
    width = badgeIce.frame.size.width / 2;
    height = badgeIce.frame.size.height / 2;
    [badgeIce setFrame:CGRectMake(originX, originY, width, height)];
    UILabel * labelFire = [[UILabel alloc] init];
    UILabel * labelIce = [[UILabel alloc] init];
    [labelFire setFrame:CGRectMake(220, 155, 15, 30)];
    [labelIce setFrame:CGRectMake(220, 195, 15, 30)];
    [labelFire setBackgroundColor:[UIColor clearColor]];
    [labelIce setBackgroundColor:[UIColor clearColor]];
    [labelFire setText:[NSString stringWithFormat:@"%d", countFire]];
    [labelIce setText:[NSString stringWithFormat:@"%d", countIce]];
    
    [self.view addSubview:badgeFire];
    [self.view addSubview:badgeIce];
    [self.view addSubview:labelFire];
    [self.view addSubview:labelIce];
    
    [badgeFire release];
    [badgeIce release];
    [labelFire release];
    [labelIce release];
     */
    
    [self updateFriendCount];
    [self updateStixCount];
    
    if (friendViewIsDisplayed)
        [friendController viewWillAppear:YES];
}


- (void) kumulosAPI:(kumulosProxy*)kumulos apiOperation:(KSAPIOperation*)operation didFailWithError:(NSString*)theError {
    NSLog(@"Kumulos failed: error: %@", theError);
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
