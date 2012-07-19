//
//  FriendSearchViewController.m
//  Stixx
//
//  Created by Irene Chen on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendSearchViewController.h"

@implementation FriendSearchViewController

@synthesize resultsTable;
@synthesize allUserInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    resultsTable = [[FriendSearchResultsController alloc] init];
    [resultsTable.view setFrame:CGRectMake(0, 44, 320, 430)];
    [resultsTable setDelegate:self];
        
    Kumulos * k = [[Kumulos alloc] init];
    [k setDelegate:self];
    [k getAllUsers];
}

- (void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllUsersDidCompleteWithResult:(NSArray *)theResults {
    [allUserInfo addObjectsFromArray:theResults];
    [kumulos release];
    
    [self.view addSubview:resultsTable.view];
    [resultsTable.tableView reloadData];
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

@end
