//
//  CreateFacebookUsernameController.m
//  Stixx
//
//  Created by Bobby Ren on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateFacebookUsernameController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"
@implementation CreateFacebookUsernameController

@synthesize tableView;
@synthesize buttonLogin;
@synthesize inputFields;
@synthesize k;
@synthesize activityIndicator;
@synthesize delegate;
@synthesize camera;
@synthesize userphoto;
@synthesize facebookString;
@synthesize buttonBack;
@synthesize initialFacebookName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        inputFields = [[NSMutableArray alloc] initWithCapacity:2];
        for (int i=0; i<2; i++) 
            [inputFields addObject:[NSNull null]];
        k = [[Kumulos alloc] init];
        [k setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self tableView] setDelegate:self];
    [tableView setFrame:CGRectMake(10, 60, 300, 2*54-20)];
    [tableView.layer setCornerRadius:10];
    [tableView setScrollEnabled:NO];

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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [buttonLogin setEnabled:NO];
    NSURL * url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", facebookString]];
    NSLog(@"FacebookString: %@ url: %@", facebookString, url);
    CGSize newSize = CGSizeMake(90, 90);
    UIImage * img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    userphoto = [img resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
    [[inputFields objectAtIndex:0] setText:initialFacebookName];
    [[inputFields objectAtIndex:1] setImage:userphoto forState:UIControlStateNormal];
    [buttonLogin setEnabled:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
	return YES;
}

-(void)startActivityIndicator {
    [buttonLogin setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    [buttonLogin setHidden:NO];
}

#pragma mark - Table view data source

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 1;
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // Configure the cell...
    int index = [indexPath row];
    for (UIView * subview in cell.subviews)
        [subview removeFromSuperview];
    [cell addSubview:[self viewForItemAtIndex:index]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

-(UIView*)viewForItemAtIndex:(int)index {
    if (index == 0) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 54)];
        [label setText:@"Select username"];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(135, 0, 150, 54)];
        [inputField setTextAlignment:UITextAlignmentLeft];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;       
        [inputField setDelegate:self];
        [inputField setClearButtonMode:UITextFieldViewModeWhileEditing];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 54)];
        [view addSubview:label];
        [view addSubview:inputField];
        
        [inputFields replaceObjectAtIndex:index withObject:inputField];
        return view;
    }
    if (index == 1) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 54)];
        [label setText:@"Picture"];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        UIButton * photoButton = [[UIButton alloc] initWithFrame:CGRectMake(135, 7, 40, 40)];
        if (!userphoto)
            [photoButton setImage:[UIImage imageNamed:@"graphic_login_picture"] forState:UIControlStateNormal];
        else {
            [photoButton setImage:userphoto forState:UIControlStateNormal];
        }
        [photoButton addTarget:self action:@selector(didClickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [photoButton.layer setBorderWidth:2];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 54)];
        [view addSubview:label];
        [view addSubview:photoButton];
        
        [inputFields replaceObjectAtIndex:index withObject:photoButton];
        return view;
    }
}

-(IBAction)didClickPhoto:(id)sender {
    UITextField * login = [inputFields objectAtIndex:0];
    [login resignFirstResponder];

    camera = [[UIImagePickerController alloc] init];
    camera.allowsEditing = YES;
    camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    camera.delegate = self;
    /*
     camera.navigationBarHidden = YES;
     camera.toolbarHidden = NO; // prevents bottom bar from being displayed
     camera.wantsFullScreenLayout = YES;
     camera.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto; 
     camera.showsCameraControls = YES;
     */
    [self presentModalViewController:camera animated:NO];
}

#pragma mark imagepickercontrollerdelegate for changing user photo
/**** adding photo - like takeProfilePicture in profile view ***/

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissModalViewControllerAnimated: NO];    
    [tableView setFrame:CGRectMake(10, 60, 300, 2*54)];
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
    [self dismissModalViewControllerAnimated:NO];
    [tableView setFrame:CGRectMake(10, 60, 300, 2*54)];

    // scale down photo
	CGSize targetSize = CGSizeMake(90, 90);		
    userphoto = [newPhoto resizedImage:targetSize interpolationQuality:kCGInterpolationDefault];
    
    // save to album
    UIImageWriteToSavedPhotosAlbum(userphoto, nil, nil, nil); 
    
    UIButton * photoButton = [inputFields objectAtIndex:1];
    [photoButton setImage:userphoto forState:UIControlStateNormal];
    [inputFields replaceObjectAtIndex:1 withObject:photoButton];
    didChangePhoto = YES;
}

-(IBAction)didClickLogin:(id)sender
{
    UITextField * login = [inputFields objectAtIndex:0];
    UIButton * photoButton = [inputFields objectAtIndex:1];
    [login resignFirstResponder];
    
    if ([[login text] length]==0) {
        [delegate showAlert:@"Please enter the name that will appear on your pictures"];
        return;
    }
    NSData * photoData = nil;
    if (didChangePhoto)
        photoData = UIImagePNGRepresentation(userphoto);
    
    [self startActivityIndicator];
    
    NSString * fbUsername = login.text;
#if 0
    [delegate didAddFacebookUsername:fbUsername andPhoto:photoData];
    [delegate shouldDismissSecondaryViewWithTransition:self.view];
#else
    // check for existence of username 
    [k getUserWithUsername:fbUsername];
#endif
}

-(IBAction)didClickBackButton:(id)sender {
    [delegate shouldDismissSecondaryViewWithTransition:self.view];
    [delegate shouldShowButtons];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserDidCompleteWithResult:(NSArray *)theResults {
    if ([theResults count] > 0) {
        [delegate showAlert:@"Username already exists! Please choose another."];
        [self stopActivityIndicator];
    }
    else {
        UITextField * login = [inputFields objectAtIndex:0];
        UIButton * photoButton = [inputFields objectAtIndex:1];
        NSString * fbUsername = login.text;
        NSData * photoData = nil;
        //if (didChangePhoto)
        photoData = UIImagePNGRepresentation(userphoto);
        //else {
        //    NSLog(@"nil photo!");
        //}
        
        [self startActivityIndicator];
        [delegate didAddFacebookUsername:fbUsername andPhoto:photoData];
        [delegate shouldDismissSecondaryViewWithTransition:self.view];
    }
}
@end
