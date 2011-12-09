//
//  LocationHeaderViewController.m
//  Stixx
//
//  Created by Bobby Ren on 12/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationHeaderViewController.h"

@implementation LocationHeaderViewController

@synthesize activityIndicator;
@synthesize mySearchBar;
@synthesize cancelButton;
@synthesize manualEnterLocationButton;
@synthesize locationController;
@synthesize delegate;
@synthesize savedSearchTerm;
@synthesize locationInputField;

- (id)init {
	
    self = [super initWithNibName:@"LocationHeaderViewController" bundle:nil];
    
    if (self) {
        // Custom initialization
        activityIndicator = nil;
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

    if ([self savedSearchTerm])
    {
        [[self mySearchBar] setText:[self savedSearchTerm]];
    }
    if (activityIndicator == nil)
        activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 240, 80, 80)];
    [self.view addSubview:activityIndicator];
    
    locationController = [[LocationViewController alloc] init];
    [locationController.view setFrame:CGRectMake(0, 133, 320,480-133)];
    [locationController setDelegate:self];
    [self.view addSubview:locationController.view];
}

-(void)viewWillAppear:(BOOL)animated {
    [locationController setNeedSearch:YES];
    if ([self savedSearchTerm])
        [locationController getFoursquareVenues:[self savedSearchTerm]];
    else
        [locationController getFoursquareVenues:@""];
    
    [locationInputField setHidden:YES];
    [manualEnterLocationButton setHidden:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    [self setSavedSearchTerm:[[self mySearchBar] text]];	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    [savedSearchTerm release], savedSearchTerm = nil;
    [super dealloc];
}


-(IBAction)didClickManualButton:(id)sender {
    [self.locationController setNeedSearch:NO];
    [manualEnterLocationButton setHidden:YES];
    [locationInputField setHidden:NO];
    [locationInputField setFrame:manualEnterLocationButton.frame];
}

-(IBAction)didClickCancelButton:(id)sender {
    [self.locationController setNeedSearch:NO];
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate didCancelLocation];
}

/********* locationViewController delegate ******/

-(void)didChooseLocation:(NSString *) location {
    [self.delegate didChooseLocation:location];
    NSLog(@"Selected from table: %@", location);
}

-(void)didReceiveSearchResults {
    [activityIndicator stopCompleteAnimation];
}

-(void)didReceiveConnectionError {
    // populate with a message that says "No internet connection" and allow entering text
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Location error!"];
    [alert setMessage:@"Could not connect to location server!"];
    [alert show];
    [alert release];
    [self dismissModalViewControllerAnimated:YES];
}

/*** search bar ****/

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // todo: reset generic search results
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString * searchText = [searchBar text];
    //Remove all objects first.
    [locationController clearSearchResults];
    [activityIndicator startCompleteAnimation];
    [locationController setNeedSearch:YES];
    [locationController getFoursquareVenues:searchText];
    
    if (![self savedSearchTerm]) {
        savedSearchTerm = [searchText retain];
    }
    
    [searchBar resignFirstResponder];
}

/*** UITextFieldDelegate ****/
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == locationInputField) {
        NSLog(@"Manually entered location %@", [locationInputField text]);
        [locationInputField resignFirstResponder];
        [self didChooseLocation:[locationInputField text]]; 
    }
}

@end
