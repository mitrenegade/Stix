//
//  CommentViewController.m
//  Stixx
//
//  Created by Bobby Ren on 12/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentViewController.h"
#import "Tag.h" // just for gettimelabel

@implementation CommentViewController

@synthesize tagID;
@synthesize nameString;
@synthesize nameLabel;
@synthesize backButton, addButton;
@synthesize commentField;
@synthesize delegate;
@synthesize activityIndicator;
@synthesize toolBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        k = [[Kumulos alloc] init];
        [k setDelegate:self];
        tagID = -1;
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


-(void)startActivityIndicator {
    //[logo setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
    [self performSelector:@selector(stopActivityIndicatorAfterTimeout) withObject:nil afterDelay:10];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    //[logo setHidden:NO];
}
-(void)stopActivityIndicatorAfterTimeout {
    [self stopActivityIndicator];
    //NSLog(@"%s: ActivityIndicator stopped after timeout!", __func__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 10, 25, 25)];
    [self.view addSubview:activityIndicator];
#if 0
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,300,320,44)];
    commentField = [[UITextField alloc] initWithFrame:CGRectMake(40, 10.0, 270, 40)];
    commentField.backgroundColor = [UIColor clearColor];
    [commentField.layer setCornerRadius:18];
    [commentField setText:@""]; // clear text
    
    addButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 30, 40)];
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(didClickAddButton) forControlEvents:UIControlEventTouchUpInside];
    
    [toolBar addSubview:commentField];
    [toolBar addSubview:addButton];
    
    [self.view addSubview:toolBar];
    [toolBar release];
    [commentField release];
    [addButton release];
#endif
    [commentField setPlaceholder:@"Enter a comment here"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [commentField setText:@""];
    [commentField setPlaceholder:@"Enter a comment here"];
}

-(void)initCommentViewWithTagID:(int)_tagID andNameString:(NSString*)_nameString {
    [self setTagID:_tagID];
    [self setNameString:_nameString];
    // Do any additional setup after loading the view from its nib.
    if (commentsTable)
    {
        [commentsTable.view removeFromSuperview];
    }
    commentsTable = [[CommentFeedTableController alloc] init];
    //[commentsTable.view setFrame:CGRectMake(0, 150, 320, 280)];
    [commentsTable.view setFrame:CGRectMake(0, 88, 320, 300)];
    [commentsTable setDelegate:self];
    [self.view insertSubview:commentsTable.view belowSubview:toolBar];
    
    // Custom initialization   
    // tagID must be set before this
    
    names = [[NSMutableArray alloc] init];
    comments = [[NSMutableArray alloc] init];
    stixStringIDs = [[NSMutableArray alloc] init];
    timestamps = [[NSMutableArray alloc] init];
    rowHeights = [[NSMutableArray alloc] init];
    
    //[nameLabel setText:[NSString stringWithFormat:@"Viewing comments on %@'s Pix",nameString]];
    [nameLabel setText:[NSString stringWithFormat:@"%@'s Pix",nameString]];
    NSLog(@"NameString: %@ tagID: %d", nameString, tagID);
    
    [k getAllHistoryWithTagID:tagID];
    [self startActivityIndicator];
}

- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllHistoryDidCompleteWithResult:(NSArray*)theResults {

    for (NSMutableDictionary * d in theResults) {        
        NSString * name = [d valueForKey:@"username"];
        NSString * comment = [d valueForKey:@"comment"];
        NSString * stixStringID = [d valueForKey:@"stixStringID"];
        NSDate * timestamp = [d valueForKey:@"timeCreated"];
        float height = [commentsTable getHeightForComment:comment forStixStringID:stixStringID];
        
        if ([stixStringID length] == 0)
        {
            // backwards compatibility
            stixStringID = @"COMMENT";
        }
#if SHOW_COMMENTS_ONLY
        if (![stixStringID isEqualToString:@"COMMENT"])
            continue;
#endif
        [names addObject:name];
        [comments addObject:comment];
        [stixStringIDs addObject:stixStringID];
        [timestamps addObject:timestamp];
        [rowHeights addObject:[NSNumber numberWithFloat:height]];
    }
    //[commentsTable configureRowsWithHeight:70 dividerVisible:YES fontSize:12 fontNameColor:[UIColor colorWithRed:153/255.0 green:51.0/255.0 blue:0.0 alpha:1.0] fontTextColor:[UIColor blackColor]];
    [commentsTable.tableView reloadData];
    [self stopActivityIndicator];
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

/*** commentFeedTableDelegate ***/

-(NSString* )getNameForIndex:(int)index {
    if (index > [names count])
        return nil;
    return [names objectAtIndex:index];
}

-(NSString *)getCommentForIndex:(int)index {
    if (index > [comments count])
        return nil;
    return [comments objectAtIndex:index];
}

-(NSString*)getStixStringIDForIndex:(int)index {
    NSString* type = [stixStringIDs objectAtIndex:index];
    if ([type length] == 0) 
        type = @"COMMENT";
    return type;
}

-(NSString*)getTimestampStringForIndex:(int)index {
    NSDate * date = [timestamps objectAtIndex:index];
    NSString * timeStampString = [Tag getTimeLabelFromTimestamp:date];
    return timeStampString;
}

-(float)getRowHeightForRow:(int)index {
    if (index > [rowHeights count])
        return 0;
    return [[rowHeights objectAtIndex:index] floatValue];
}

-(UIImage*)getPhotoForIndex:(int)index {
    NSString * name = [names objectAtIndex:index];
    return [delegate getUserPhotoForUsername:name];//[photos objectForKey:[names objectAtIndex:index]];
}

-(int)getCount {
    return [names count];
}

-(IBAction)didClickAddButton:(id)sender {
    [commentField resignFirstResponder];
    NSString * newComment = [commentField text];
    if ([newComment length] > 0)
        [delegate didAddNewComment:newComment withTagID:self.tagID];
	NSLog(@"Comment entered: %@", [commentField text]); 
}

-(IBAction)didClickBackButton:(id)sender {
    [commentField resignFirstResponder];
    [delegate didCloseComments];
}
/*** UITextFieldDelegate ***/

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
    NSString * newComment = [commentField text];
    //if ([newComment length] > 0)
    //    [delegate didAddNewComment:newComment withTagID:self.tagID];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

/*
- (void)textFieldDidBeginEditing:(UITextField *)textField {	
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationBeginsFromCurrentState:YES];
	toolBar.frame = CGRectMake(toolBar.frame.origin.x, (toolBar.frame.origin.y - (216-48)), toolBar.frame.size.width, toolBar.frame.size.height);
	[UIView commitAnimations];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {	
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationBeginsFromCurrentState:YES];
	toolBar.frame = CGRectMake(toolBar.frame.origin.x, (toolBar.frame.origin.y + (216-48)), toolBar.frame.size.width, toolBar.frame.size.height);
	[UIView commitAnimations];
}
 */

/*** CommentFeedTableDelegate for user page ***/
-(void)shouldDisplayUserPage:(NSString *)username {
    [delegate shouldDisplayUserPage:username];
}
-(void)shouldCloseUserPage {
    [delegate shouldCloseUserPage];
}

@end
