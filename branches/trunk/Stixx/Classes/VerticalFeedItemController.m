//
//  VerticalFeedItemController.m
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//
//  VerticalFeedItemController.m
//  ARKitDemo
//
//  Created by Administrator on 9/13/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "VerticalFeedItemController.h"

@implementation VerticalFeedItemController

@synthesize labelName;
@synthesize labelComment;
@synthesize labelCommentCount;
@synthesize labelDescriptor;
@synthesize labelTime;
@synthesize labelDescriptorBG;
@synthesize labelLocationString;
@synthesize imageView;
@synthesize nameString, commentString, imageData;
@synthesize userPhotoView;
@synthesize addCommentButton;
@synthesize tagID;
@synthesize delegate;
@synthesize commentCount;
@synthesize stixView;
@synthesize locationIcon;
@synthesize shareButton;
//@synthesize seeAllCommentsButton;
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

-(id)init
{
	// call superclass's initializer
	self = [super initWithNibName:@"VerticalFeedItemController" bundle:nil];
    
    //nameString = [NSString alloc];
    //commentString = [NSString alloc];
    //imageData = [UIImage alloc];
    
    isShowingPlaceholder = YES;
    
    return self;
}

-(void)populateWithName:(NSString *)name andWithDescriptor:(NSString *)descriptor andWithComment:(NSString *)comment andWithLocationString:(NSString*)location {// andWithImage:(UIImage*)image {
    NSLog(@"--PopulateWithName: %@ descriptor %@ comment %@ location %@\n", name, descriptor, comment, location);
    
    nameString = name;
    descriptorString = descriptor;
    commentString = comment;
    if (descriptor == nil || [descriptor length] == 0) {
        if (comment == nil || [comment length] == 0) {
            [labelDescriptorBG setHidden:YES];
            descriptorString = nil;
            commentString = nil;
        } 
        else {
            descriptorString = comment;
            commentString = nil;
        }
    }
    //imageData = image;
    locationString = location;
}

-(void)populateWithUserPhoto:(UIImage*)photo {
    if (photo){
        [photo retain];
        [userPhotoView setImage:photo];
        [userPhotoView setBackgroundColor:[UIColor blackColor]];
        [photo release];
    }
}

-(void)initStixView:(Tag*)_tag {
    tag = [_tag retain];
    imageData = tag.image;
    
    //NSLog(@"VerticalFeedItem: Creating stix view of size %f %f", imageData.size.width, imageData.size.height);
    
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:NO];
    [stixView setIsPeelable:YES];
    [stixView setDelegate:self];
    [stixView initializeWithImage:imageData];
    int canShow = [stixView populateWithAuxStixFromTag:tag];
    if (canShow) {
        [self.view insertSubview:stixView belowSubview:imageView];
        isShowingPlaceholder = NO;
    }
    else {
        placeholderView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(0,0,60,60)];
        [placeholderView setCenter:stixView.center];
        [placeholderView startCompleteAnimation];
        [self.view insertSubview:placeholderView belowSubview:imageView];
        isShowingPlaceholder = YES;
    }
}

-(void)populateWithTimestamp:(NSDate *)timestamp {    
    [labelTime setText:[Tag getTimeLabelFromTimestamp:timestamp]];
} 

-(void)populateWithCommentCount:(int)count {
    self.commentCount = count;
    //if (count > 0)
    //    [addCommentButton setTitle:[NSString stringWithFormat:@"%d", commentCount] forState:UIControlStateNormal];
    if (count == 0) {
        [addCommentButton setImage:[UIImage imageNamed:@"btn_comment.png"] forState:UIControlStateNormal];
        [labelCommentCount setHidden:YES];
    }
    else {
        [addCommentButton setImage:[UIImage imageNamed:@"btn_comment2.png"] forState:UIControlStateNormal];
        [labelCommentCount setHidden:NO];
        [labelCommentCount setText:[NSString stringWithFormat:@"%d", commentCount]];
    }
}

#if 0
-(void)populateCommentsWithNames:(NSMutableArray*)allNames andComments:(NSMutableArray*)allComments andStixStringIDs:(NSMutableArray*)allStixStringIDs {
    [names removeAllObjects];
    [names addObjectsFromArray:allNames];
    [comments removeAllObjects];
    [comments addObjectsFromArray:allComments];
    [stixStringIDs removeAllObjects];
    [stixStringIDs addObjectsFromArray:allStixStringIDs];
    
    if (commentsTable)
    {
        [commentsTable.view removeFromSuperview];
        [commentsTable release];
    }
    commentsTable = [[CommentFeedTableController alloc] init];
    [commentsTable setDelegate:self];
    [self.view addSubview:commentsTable.view];

    [commentsTable configureRowsWithHeight:18 dividerVisible:NO fontSize:12 fontNameColor:[UIColor colorWithRed:153/255.0 green:51/255.0 blue:0.0 alpha:1.0] fontTextColor:[UIColor blackColor]];
    [commentsTable.tableView reloadData];
    
    // resize view
    const int buttonHeight = 25; // height of "see all comments" button
    const int noButtonBorder = 10;
    int commentTableHeight = 0;
    int commentContentHeight = 0;
    BOOL showAllCommentsButton = NO;
    if ([names count] == 0) {
        commentTableHeight = 0;
    }
    else if ([names count] <= 3) {
        commentTableHeight = commentsTable.rowHeight * [names count];
        commentContentHeight = commentTableHeight + noButtonBorder;
    }
    else {
        commentTableHeight = commentsTable.rowHeight * 3;
        commentContentHeight = commentTableHeight + buttonHeight;
        showAllCommentsButton = YES;
    }
    [commentsTable.view setFrame:CGRectMake(0, CONTENT_HEIGHT, 320, commentTableHeight)];
    
    NSLog(@"Number of comments for feedItem %d: %d old frame height: %f new frame height: %d", self.tagID, [names count], self.view.frame.size.height, CONTENT_HEIGHT + commentContentHeight);
    
    CGRect frame = self.view.frame;
    int newHeight = CONTENT_HEIGHT + commentContentHeight;
    frame.size.height = MAX(newHeight, frame.size.height);
    [self.view setFrame:frame];
    NSLog(@"Setting frame size to %f", frame.size.height);
    if (showAllCommentsButton) {
        //[seeAllCommentsButton setFrame:CGRectMake(130, commentTableHeight + 2, 60, 20)];
        //[seeAllCommentsButton setHidden:NO];
    }
}
#endif

/*
 - (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation getAllHistoryDidCompleteWithResult:(NSArray*)theResults {
 
 for (NSMutableDictionary * d in theResults) {        
 NSString * name = [d valueForKey:@"username"];
 NSString * comment = [d valueForKey:@"comment"];
 NSString * stixStringID = [d valueForKey:@"stixStringID"];
 if ([stixStringID length] == 0)
 {
 // backwards compatibility
 stixStringID = @"COMMENT";
 }
 
 [names addObject:name];
 [comments addObject:comment];
 [stixStringIDs addObject:stixStringID];
 }
 NSLog(@"GetHistory for feedItem %d completed: %d comments", self.tagID, [names count]);
 
 // do automatically
 //[self.delegate didExpandFeedItem:self];
 }
 */
/** commentTable controller delegate ***/
/*** commentFeedTableDelegate ***/

/*
-(NSString* )getNameForIndex:(int)index {
    return [names objectAtIndex:index];
}

-(NSString *)getCommentForIndex:(int)index {
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

-(int)getCount {
    return [names count];
}
*/

- (void)dealloc
{
    [super dealloc];
}

-(IBAction)didPressAddCommentButton:(id)sender {
    [self.delegate displayCommentsOfTag:tagID andName:nameString];
}
-(void)didPressSeeAllCommentsButton:(id)sender {
    [self.delegate displayCommentsOfTag:tagID andName:nameString];
}

-(IBAction)didPressShareButton:(id)sender {
    [self.delegate sharePix:tagID];
    /*
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Beta Version"];
    [alert setMessage:@"Share coming soon!"];
    [alert show];
    [alert release];
     */
    return;
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
    [labelName setText:[NSString stringWithFormat:@"%@", nameString]];
    UIColor * textColor = [UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1.0];
    [labelDescriptor setTextColor:textColor];
    [labelDescriptor setText:descriptorString];
    [labelComment setText:commentString];
    [imageView setImage:imageData];
    [labelLocationString setText:locationString];
    if ([commentString length] == 0) {
        if ([descriptorString length] != 0) {
            [labelDescriptor setFrame:CGRectMake(labelDescriptor.frame.origin.x, labelDescriptor.frame.origin.y, labelDescriptor.frame.size.width, 46)]; // combined heights
            //[labelDescriptorBG setFrame:CGRectMake(labelDescriptorBG.frame.origin.x, labelDescriptorBG.frame.origin.y, labelDescriptorBG.frame.size.width, 46)];
            [labelComment setHidden:YES];
        }
        else {
            [labelDescriptor setHidden:YES];
            [labelComment setHidden:YES];
            [labelDescriptorBG setHidden:YES];
        }
    }
    if ([locationString length] == 0)
        [locationIcon setHidden:YES];
    //NSLog(@"Loading feed item with name %@ comment %@ and imageView %f %f with image Data size %f %f", labelName.text, labelDescriptor.text, imageView.frame.size.width, imageView.frame.size.height, imageData.size.width, imageData.size.height);

    [labelCommentCount setText:@""];
    
#if 0
    if (names)
        [names release];
    if (comments)
        [comments release];
    if (stixStringIDs)
        [stixStringIDs release];
    names = [[NSMutableArray alloc] init];
    comments = [[NSMutableArray alloc] init];
    stixStringIDs = [[NSMutableArray alloc] init];
    
    isExpanded = NO;
    /*
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    [k getAllHistoryWithTagID:tagID];
     */
#endif
    
    //[shareButton setHidden:YES];
    //[seeAllCommentsButton setHidden:YES];
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

/* StixViewDelegate */
-(NSString*)getUsername {
    return [self.delegate getUsername];
}

-(void)didAttachStix:(int)index {
    // 1 = attach
    [self.delegate didPerformPeelableAction:1 forAuxStix:index];
}

-(void)didPeelStix:(int)index {
    // 0 = peel
    // show peel animation
    [stixView doPeelAnimationForStix:index];
}

-(void)peelAnimationDidCompleteForStix:(int)index {
    [self.delegate didPerformPeelableAction:0 forAuxStix:index];
}

-(void)didRequestStixFromKumulos:(NSString *)stixStringID {
    //[delegate didRequestStixFromKumulos:stixStringID forFeedItem:self];
}
-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID {
    NSLog(@"VerticalFeedItemController calling delegate didReceiveRequestedStixView");
    // send through to StixAppDelegate to save to defaults
    [delegate didReceiveRequestedStixViewFromKumulos:stixStringID];
}
-(void)didReceiveAllRequestedStixViews {
    if (!isShowingPlaceholder)
        return;
    
    [placeholderView stopCompleteAnimation];
    [placeholderView removeFromSuperview];
    
    NSLog(@"VerticalFeedItemController removing placeholder for StixView %d tagID %d", stixView.stixViewID, tagID);
    [stixView populateWithAuxStixFromTag:tag];
    [self.view insertSubview:stixView belowSubview:imageView];
#if 1
    // fade in
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeIn:stixView forTime:.5 withCompletion:^(BOOL finished){}];
    //[animation doJump:stixView inView:self.view forDistance:50 forTime:.5];
#endif
}

//[k getStixDataByStixStringIDWithStixStringID:stixStringID];
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getStixDataByStixStringIDDidCompleteWithResult:(NSArray *)theResults {
    NSMutableDictionary * d = [theResults objectAtIndex:0]; 
    NSString * descriptor = [d valueForKey:@"stixDescriptor"];
    NSLog(@"StixView requested stix data for %@", descriptor);
    [BadgeView AddStixView:theResults];
}


/******** process clicks *******/
/*
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	int drag = 0;    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	int drag = 1;
}
 */
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//if (drag != 1)
	{
        UITouch *touch = [[event allTouches] anyObject];	
        CGPoint location = [touch locationInView:self.view];
        if ([self.delegate respondsToSelector:@selector(didClickAtLocation:withFeedItem:)])
            [self.delegate didClickAtLocation:location withFeedItem:self];
    }
}

@end
