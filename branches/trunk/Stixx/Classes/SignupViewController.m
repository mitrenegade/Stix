//
//  SignupViewController.m
//  Stixx
//
//  Created by Bobby Ren on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignupViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SignupViewController ()

@end

@implementation SignupViewController
@synthesize inputViews;
@synthesize tableView;
@synthesize buttonSignup;
@synthesize inputFields;
@synthesize k;
@synthesize activityIndicator;
@synthesize delegate;
@synthesize camera;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        inputViews = [[NSMutableDictionary alloc] init];
        inputFields = [[NSMutableArray alloc] initWithCapacity:5];
        for (int i=0; i<5; i++) 
            [inputFields addObject:[NSNull null]];
        didChangePhoto = NO;
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
    [tableView setFrame:CGRectMake(10, 60, 300, 4*54-20)];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
    if (textField == [inputFields objectAtIndex:0])
        [[inputFields objectAtIndex:1] becomeFirstResponder];
    else if (textField == [inputFields objectAtIndex:1])
        [[inputFields objectAtIndex:2] becomeFirstResponder];

	return YES;
}
#pragma mark activityIndicator

-(void)startActivityIndicator {
    [buttonSignup setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    [buttonSignup setHidden:NO];
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
    return 4;
}

-(UIView*)viewForItemAtIndex:(int)index {
    if ([inputViews objectForKey:[NSNumber numberWithInt:index]])
        return [inputViews objectForKey:[NSNumber numberWithInt:index]];
    
    if (index == 0) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 54)];
        [label setText:@"Email"];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, 54)];
        [inputField setPlaceholder:@"example@example.com"];
        [inputField setTag:TAG_EMAIL];
        [inputField setTextAlignment:UITextAlignmentLeft];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;       
        [inputField setDelegate:self];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 54)];
        [view addSubview:label];
        [view addSubview:inputField];
        
        [inputViews setObject:view forKey:[NSNumber numberWithInt:index]];
        [inputFields replaceObjectAtIndex:index withObject:inputField];
        return view;
    }
    else if (index == 1) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 54)];
        [label setText:@"Username"];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, 54)];
        [inputField setTag:TAG_USERNAME];
        [inputField setTextAlignment:UITextAlignmentLeft];
        [inputField setDelegate:self];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;       
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 54)];
        [view addSubview:label];
        [view addSubview:inputField];
        
        [inputViews setObject:view forKey:[NSNumber numberWithInt:index]];
        [inputFields replaceObjectAtIndex:index withObject:inputField];
        return view;
    }
    if (index == 2) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 54)];
        [label setText:@"Password"];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, 54)];
        [inputField setTag:TAG_PASSWORD];
        [inputField setSecureTextEntry:YES];
        [inputField setTextAlignment:UITextAlignmentLeft];
        [inputField setDelegate:self];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;       
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 54)];
        [view addSubview:label];
        [view addSubview:inputField];
        
        [inputViews setObject:view forKey:[NSNumber numberWithInt:index]];
        [inputFields replaceObjectAtIndex:index withObject:inputField];
        return view;
    }
    if (index == 3) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 54)];
        [label setText:@"Picture"];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        UIButton * photoButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 7, 40, 40)];
        [photoButton setImage:[UIImage imageNamed:@"graphic_login_picture"] forState:UIControlStateNormal];
        [photoButton addTarget:self action:@selector(didClickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [photoButton setTag:TAG_PICTURE];
        [photoButton.layer setBorderWidth:2];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 54)];
        [view addSubview:label];
        [view addSubview:photoButton];
        
        [inputViews setObject:view forKey:[NSNumber numberWithInt:index]];
        [inputFields replaceObjectAtIndex:index withObject:photoButton];
        return view;
    }
}

-(IBAction)didClickPhoto:(id)sender {
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

-(IBAction)didClickSignup:(id)sender {
    // check for correctness
    UITextField * email = [inputFields objectAtIndex:0];
    UITextField * username = [inputFields objectAtIndex:1];
    UITextField * password = [inputFields objectAtIndex:2];
    NSLog(@"Email: %@ username: %@ password: %@ photo changed: %d", [email text], [username text], [password text], didChangePhoto);
    
#if !ADMIN_TESTING_MODE
    if (![self NSStringIsValidEmail:[email text]]) {
        NSLog(@"Invalid email format!");
        [delegate showAlert:@"Invalid email format!"];
        if (!IS_ADMIN_USER(username))
            [FlurryAnalytics logEvent:@"SignupError" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[email text], @"InvalidEmail", nil]];
        return;
    }
    if ([[username text] length] == 0) {
        NSLog(@"Invalid username!");
        [delegate showAlert:@"Please enter a username."];
        if (!IS_ADMIN_USER(username))
            [FlurryAnalytics logEvent:@"SignupError" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[username text], @"InvalidName", nil]];
        return;
    }
    if ([[password text] length] == 0) {
        [delegate showAlert:@"Please enter a password."];
        return;
    }
    if ([[password text] length] == 0) {
        NSLog(@"Password must not be blank!");
        [delegate showAlert:@"Password must not be blank!"];
        if (!IS_ADMIN_USER(username))
            [FlurryAnalytics logEvent:@"SignupError" withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"", @"BlankPassword", nil]];
        return;
    }
    
//    Kumulos * k = [[Kumulos alloc] init];
//    [k setDelegate:self];
    [self startActivityIndicator];
    [k checkValidNewUserWithUsername:[username text] andEmail:[email text]];
#else
    // test - just add the user for gods sake
    UIButton * photoButton = [inputFields objectAtIndex:3];
    NSData * photoData = nil;
    if (didChangePhoto)
        photoData = UIImagePNGRepresentation([[photoButton imageView] image]);
    [k createEmailUserWithUsername:[username text] andPassword:[k md5:[password text]] andEmail:[email text] andPhoto:photoData];
    
#endif
    
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation checkValidNewUserDidCompleteWithResult:(NSArray *)theResults {
    if ([theResults count] > 0) {
        BOOL nameAlreadyExists = NO;
        BOOL emailAlreadyExists = NO;
        NSString * email = [[inputFields objectAtIndex:0] text];
        NSString * username = [[inputFields objectAtIndex:1] text];
        for (NSMutableDictionary * d in theResults) {
            NSString * name = [d objectForKey:@"username"];
            NSString * mail = [d objectForKey:@"email"];
            if ([name isEqualToString:username])
                nameAlreadyExists = YES;
            if ([mail isEqualToString:email])
                emailAlreadyExists = YES;
        }
        NSLog(@"Invalid new user! User already exists!");
        if (nameAlreadyExists)
            [delegate showAlert:@"Username is already taken!"];
        else if (emailAlreadyExists)
            [delegate showAlert:@"Email is already taken!"];
        [self stopActivityIndicator];
        return;
    }
    else 
    {
        UITextField * email = [inputFields objectAtIndex:0];
        UITextField * username = [inputFields objectAtIndex:1];
        UITextField * password = [inputFields objectAtIndex:2];
        UIButton * photoButton = [inputFields objectAtIndex:3];
        
        [email setEnabled:NO];
        [username setEnabled:NO];
        [password setEnabled:NO];
        [photoButton setEnabled:NO];
        
        NSData * photoData = nil;
        if (didChangePhoto)
            photoData = UIImageJPEGRepresentation([[photoButton imageView] image], .9);

//        Kumulos * k = [[Kumulos alloc] init];
//        [k setDelegate:self];
        [k createEmailUserWithUsername:[username text] andPassword:[k md5:[password text]] andEmail:[email text] andPhoto:photoData];
    }
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation createEmailUserDidCompleteWithResult:(NSNumber *)newRecordID {
    [self stopActivityIndicator];
    // BOBBY here! we get here from userLogin...
    // happens both when we have a facebook prompt (button) and when facebook
    // automatically logs in. 
    // need a method to determine whether it's the first time, and needs to display friendSuggestionController
    UITextField * email = [inputFields objectAtIndex:0];
    UITextField * username = [inputFields objectAtIndex:1];
    UIButton * photoButton = [inputFields objectAtIndex:3];
    
    NSLog(@"Added new user! email %@ name %@ recordID: %@ photo? %d", email.text, username.text, newRecordID, didChangePhoto);

    [delegate shouldDismissSecondaryViewWithTransition:self.view];
    [delegate didLoginFromEmailSignup:[username text] andPhoto:didChangePhoto?[[photoButton imageView] image]:nil andEmail:[email text] andUserID:newRecordID];
}

#pragma mark imagepickercontrollerdelegate for changing user photo
/**** adding photo - like takeProfilePicture in profile view ***/

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissModalViewControllerAnimated: NO];    
    // hack: table size always gets screwed up
    [tableView setFrame:CGRectMake(10, 60, 300, 4*54)];
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
    // hack: table size always gets screwed up
    [tableView setFrame:CGRectMake(10, 60, 300, 4*54)];
    
    // scale down photo
	CGSize targetSize = CGSizeMake(90, 90);		
    UIImage * result = [newPhoto resizedImage:targetSize interpolationQuality:kCGInterpolationDefault];
    
    // save to album
    UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil); 

    UIButton * photoButton = [inputFields objectAtIndex:3];
    [photoButton setImage:result forState:UIControlStateNormal];
    [photoButton.layer setBorderWidth:2];
    [inputFields replaceObjectAtIndex:3 withObject:photoButton];
    didChangePhoto = YES;
}

-(IBAction)didClickBackButton:(id)sender {
    [delegate shouldDismissSecondaryViewWithTransition:self.view];
}
@end
