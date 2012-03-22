//
//  ConfigViewController.m
//  ARKitDemo
//
//  Created by Administrator on 7/11/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "ConfigViewController.h"

@implementation ConfigViewController

@synthesize loginScreenButton;
@synthesize delegate;
@synthesize username, nameLabel;
@synthesize buttonInstructions;
@synthesize photoButton;
@synthesize isLoggedIn;
@synthesize photoView;

-(id)init
{
	[super initWithNibName:@"ConfigViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"Profile"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_me.png"];
	[tbi setImage:i];
    
    isLoggedIn = NO;
	
	return self;
}

-(IBAction)showLoginScreen:(id)sender{
    LoginViewController * loginController = [[[LoginViewController alloc] init] autorelease];
    loginController.delegate = (NSObject<LoginViewDelegate>*) self.delegate;
    [self presentModalViewController:loginController animated:YES];
}

-(void)setUsernameLabel:(NSString *)name {
    [self setUsername:name];
    isLoggedIn = YES;
    [self.nameLabel setText:name];
}

-(void)setPhoto:(UIImage *)photo {
    [photoView setImage:photo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"Set config namelabel as %@", username);
    //[nameLabel setText:username];
    //[photoView setImage:photo];
    Kumulos* k = [[Kumulos alloc]init];
    [k setDelegate:self];    
    [k getUserWithUsername:username];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)loginWithUsername:(NSString *)name {
    // if name is already specified, login and update photo
    Kumulos* k = [[Kumulos alloc]init];
    [k setDelegate:self];
  
    [k getUserWithUsername:name];
}
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getUserDidCompleteWithResult:(NSArray*)theResults {
    
    if ([theResults count] > 0)
    {
        for (NSMutableDictionary * d in theResults) {
            NSString * name = [d valueForKey:@"username"];
            [self setUsernameLabel:name];
            UIImage * newPhoto = [[UIImage alloc] initWithData:[d valueForKey:@"photo"]];
            if (newPhoto) {
                NSLog(@"User has photo of dims %f %f\n", newPhoto.size.width, newPhoto.size.height);
                //[photoView setImage:newPhoto];                
                [photoButton setImage:newPhoto forState:UIControlStateNormal];
                NSLog(@"User %@ has photo of dimensions %f %f\n", name, newPhoto.size.width, newPhoto.size.height);
                [newPhoto release];
            }
            else
            {
                UIImage * newPhoto = [UIImage imageNamed:@"emptyuser.png"];
                [photoButton setImage:newPhoto forState:UIControlStateNormal];
                [photoButton setTitle:@"" forState:UIControlStateNormal]; 
            }
        }
        [loginScreenButton setTitle:@"Switch account" forState:UIControlStateNormal];
    }
    [kumulos release];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)changePhoto:(id)sender {
    if (!isLoggedIn) // show login screen
    {
        LoginViewController * loginController = [[[LoginViewController alloc] init] autorelease];
        loginController.delegate = (NSObject<LoginViewDelegate>*) self.delegate;
        [self presentModalViewController:loginController animated:YES];
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
	CGSize targetSize = CGSizeMake(100, 100);		
	float baseScale =  targetSize.width / newPhoto.size.width;
	CGRect scaledFrame = CGRectMake(0, 0, newPhoto.size.width * baseScale, newPhoto.size.height * baseScale);
	UIGraphicsBeginImageContext(targetSize);
	[newPhoto drawInRect:scaledFrame];	
	UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    UIImage * rounded = [result roundedCornerImage:5 borderSize:2];

    // save to album
    UIImageWriteToSavedPhotosAlbum(rounded, nil, nil, nil); 
    
    Kumulos* k = [[Kumulos alloc]init];
    [k setDelegate:self];
    NSData * img = UIImagePNGRepresentation(rounded);
    NSLog(@"Adding photo of size %f %f to user %@", rounded.size.width, rounded.size.height, username);
    [k addPhotoWithUsername:username andPhoto:img];
    [picker release];
}

- (void) kumulosAPI:(kumulosProxy*)kumulos apiOperation:(KSAPIOperation*)operation didFailWithError:(NSString*)theError {
    NSLog(@"Kumulos failed: error: %@", theError);
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation addPhotoDidCompleteWithResult:(NSNumber*)affectedRows;
{
    // done! yay!
    NSLog(@"Updated %d rows", [affectedRows intValue]);
    [kumulos release]; 
    [self loginWithUsername:username]; // force reload of photoView
    [self.delegate checkForUpdatePhotos];
}

-(IBAction)closeInstructions:(id)sender;
{
    [buttonInstructions setHidden:YES];
}


- (void)dealloc {
    [super dealloc];
}




@end
