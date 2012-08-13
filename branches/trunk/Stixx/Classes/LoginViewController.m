//
//  LoginViewController.m
//  KickedIntoShape
//
//  Created by Administrator on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
@implementation LoginViewController

@synthesize tableView;
@synthesize buttonLogin;
@synthesize inputFields;
@synthesize k;
@synthesize activityIndicator;
@synthesize delegate;

static bool usernameExists;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIImage * backImage = [UIImage imageNamed:@"nav_back"];
        UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
        [backButton setImage:backImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(didClickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:leftButton];
        
        UIImageView * logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        [self.navigationItem setTitleView:logo];
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
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    inputFields = [[NSMutableArray alloc] initWithCapacity:2];
    for (int i=0; i<2; i++) 
        [inputFields addObject:[NSNull null]];
    k = [[Kumulos alloc] init];
    [k setDelegate:self];

    [[self tableView] setDelegate:self];
    [tableView setFrame:CGRectMake(10, 60, 300, 2*54)];
    [tableView.layer setCornerRadius:10];
    [tableView setScrollEnabled:NO];

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 320, 80, 80)];
    [self.view addSubview:activityIndicator];
    [activityIndicator setHidden:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
    if (textField == [inputFields objectAtIndex:0])
        [[inputFields objectAtIndex:1] becomeFirstResponder];
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
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 54)];
        [label setText:@"Name or Email"];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(115, 0, 170, 54)];
        [inputField setTextAlignment:UITextAlignmentLeft];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;       
        [inputField setDelegate:self];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 54)];
        [view addSubview:label];
        [view addSubview:inputField];
        
        [inputFields replaceObjectAtIndex:index withObject:inputField];
        return view;
    }
    else if (index == 1) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 54)];
        [label setText:@"Password"];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(115, 0, 170, 54)];
        [inputField setTextAlignment:UITextAlignmentLeft];
        [inputField setDelegate:self];
        [inputField setSecureTextEntry:YES];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;       
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 54)];
        [view addSubview:label];
        [view addSubview:inputField];
        
        [inputFields replaceObjectAtIndex:index withObject:inputField];
        return view;
    }
}

-(IBAction)didClickLogin:(id)sender
{
    UITextField * login = [inputFields objectAtIndex:0];
    UITextField * password = [inputFields objectAtIndex:1];
    [login resignFirstResponder];
	[password resignFirstResponder];

    if ([[login text] length]==0) {
        [delegate showAlert:@"Please enter a login name."];
        return;
    }
    if ([[password text] length]==0) {
        [delegate showAlert:@"Please enter a password."];
        return;
    }
    
    [self startActivityIndicator];
    NSLog(@"Using login %@ and password %@", [login text], [password text]);
    
#if 0
    [k userLoginWithUsername:[login text] andPassword:[k md5:[password text]]];
#else
    [k loginWithNameOrEmailWithLoginName:[login text]];
#endif
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation loginWithNameOrEmailDidCompleteWithResult:(NSArray *)theResults {
    [self stopActivityIndicator];
    if ([theResults count] == 0) {
        NSLog(@"Invalid login! What you entered was neither a valid username or email!");
        [delegate showAlert:@"Your entered username or email does not exist."];
        return;
    }
    else {
        NSLog(@"%d results found", [theResults count]);
        UITextField * password = [inputFields objectAtIndex:1];
        for (NSMutableDictionary * d in theResults) {
            NSString * username = [d objectForKey:@"username"];
            NSString * email = [d objectForKey:@"email"];
            NSString * passwordMD5 = [d objectForKey:@"password"];
            NSString * facebookString = [d objectForKey:@"facebookString"];
            /*
            if (facebookString && ![facebookString isEqualToString:@"0"] && ![facebookString isEqualToString:username]) {
                NSLog(@"This username associated with a facebook account, please login via our facebook option! Name %@ email %@ facebook %@", username, email, facebookString);
                [delegate showAlert:@"This username associated with a facebook account, please login via our facebook option!"];
                return;
            }
             */
            
            if ([passwordMD5 isEqualToString:[k md5:[password text]]]) {
                NSLog(@"Password matches! Logging in as username %@ email %@", username, email);
                //[self.navigationController popViewControllerAnimated:YES]; // don't pop
                [delegate didSelectUsername:username withResults:[NSMutableArray arrayWithObject:d]];
                return;
            }
        }
        NSLog(@"none of the results matched your password!");
        [delegate showAlert:@"Your password was incorrect."];
    }
}
/*
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation userLoginDidCompleteWithResult:(NSArray *)theResults {
    if ([theResults count] == 0) {
        NSLog(@"Invalid login! Username and password combination not found!");
    }
    else {
        NSMutableDictionary * d = [theResults objectAtIndex:0];
        [delegate didSelectUsername:[d objectForKey:@"username"] withResults:theResults];
    }
}
 */
-(void)didClickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:YES];		
    [delegate shouldShowButtons];
}

@end
