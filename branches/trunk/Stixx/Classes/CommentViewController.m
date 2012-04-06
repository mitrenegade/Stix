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
    [logo setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    [logo setHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(150, 10, 25, 25)];
    [self.view addSubview:activityIndicator];
    [commentField setText:@""]; // clear text
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [commentField setText:@""]; // clear text
}

-(void)initCommentViewWithTagID:(int)_tagID andNameString:(NSString*)_nameString {
    [self setTagID:_tagID];
    [self setNameString:_nameString];
    // Do any additional setup after loading the view from its nib.
    if (commentsTable)
    {
        [commentsTable.view removeFromSuperview];
        [commentsTable release];
    }
    commentsTable = [[CommentFeedTableController alloc] init];
    [commentsTable.view setFrame:CGRectMake(0, 150, 320, 280)];
    [commentsTable setDelegate:self];
    [self.view addSubview:commentsTable.view];
    
    // Custom initialization   
    // tagID must be set before this
    
    if (names)
        [names release];
    if (comments)
        [comments release];
    if (stixStringIDs)
        [stixStringIDs release];
    if (timestamps)
        [timestamps release];
    if (rowHeights)
        [rowHeights release];
    names = [[NSMutableArray alloc] init];
    comments = [[NSMutableArray alloc] init];
    stixStringIDs = [[NSMutableArray alloc] init];
    timestamps = [[NSMutableArray alloc] init];
    rowHeights = [[NSMutableArray alloc] init];
    
    [nameLabel setText:[NSString stringWithFormat:@"Viewing comments on %@'s Pix",nameString]];
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
    return [self.delegate getUserPhotoForUsername:[names objectAtIndex:index]];//[photos objectForKey:[names objectAtIndex:index]];
}

-(int)getCount {
    return [names count];
}

-(IBAction)addButtonPressed:(id)sender {
    NSString * newComment = [commentField text];
    [commentField resignFirstResponder];
    if ([newComment length] > 0)
        [self.delegate didAddNewComment:newComment withTagID:self.tagID];
}

-(IBAction)backButtonPressed:(id)sender {
    [self.delegate didCloseComments];
}
/*** UITextFieldDelegate ***/

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

/*** CommentFeedTableDelegate for user page ***/
-(void)shouldDisplayUserPage:(NSString *)username {
    [delegate shouldDisplayUserPage:username];
}
-(void)shouldCloseUserPage {
    [delegate shouldCloseUserPage];
}

@end
