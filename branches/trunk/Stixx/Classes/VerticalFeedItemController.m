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
@synthesize tagID, tag;
@synthesize delegate;
@synthesize commentCount;
@synthesize stixView;
@synthesize locationIcon;
@synthesize shareButton;
@synthesize reloadView, reloadMessage, reloadMessage2, reloadButton;
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
    
    stixView.isShowingPlaceholder = YES;
    isDisplayingLikeToolbar = NO;
    
    return self;
}

-(void)populateWithName:(NSString *)name andWithDescriptor:(NSString *)descriptor andWithComment:(NSString *)comment andWithLocationString:(NSString*)location {// andWithImage:(UIImage*)image {
    //NSLog(@"--PopulateWithName: %@ descriptor %@ comment %@ location %@\n", name, descriptor, comment, location);
    
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
        [userPhotoView setImage:photo];
        [userPhotoView setBackgroundColor:[UIColor blackColor]];
    }
}

-(void)togglePlaceholderView:(BOOL)showPlaceholder {
    if (placeholderView == nil) {
        placeholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_emptypic.png"]];
        [placeholderView setCenter:imageView.center];
    }
    
    if (showPlaceholder) {
        NSLog(@"TogglePlaceHolder: showing placeholder for tagID %d", tagID);
        [stixView removeFromSuperview];
        [self.view insertSubview:placeholderView belowSubview:imageView];
    }
    else {
        NSLog(@"TogglePlaceHolder: removing placeholder for tagID %d", tagID);
        [placeholderView removeFromSuperview];
        [self.view insertSubview:stixView belowSubview:imageView];
    }
    stixView.isShowingPlaceholder = showPlaceholder;
    [shareButton removeFromSuperview];
    [self.view addSubview:shareButton];
    [addCommentButton removeFromSuperview];
    [self.view addSubview:addCommentButton];
    [labelCommentCount removeFromSuperview];
    [self.view addSubview:labelCommentCount];
}

-(void)initStixView:(Tag*)_tag {
    tag = _tag;
    imageData = tag.image;
    
    //NSLog(@"VerticalFeedItem: Creating stix view of size %f %f", imageData.size.width, imageData.size.height);
    
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:NO];
    [stixView setIsPeelable:YES];
    [stixView setDelegate:self];
    [stixView initializeWithImage:imageData];
    
#if USE_PLACEHOLDER
    [self togglePlaceholderView:YES];
#else
    NSLog(@"InitStixView for tag with id %d", [tag.tagID intValue]);
    int canShow = [stixView populateWithAuxStixFromTag:tag];
    if (canShow) {
        [self togglePlaceholderView:NO];
    }
    else {
        [self togglePlaceholderView:YES];
    }
#endif
    /*
    [shareButton removeFromSuperview];
    [self.view addSubview:shareButton];
    [addCommentButton removeFromSuperview];
    [self.view addSubview:addCommentButton];
     */
}

-(void)displayReloadView {
    [reloadView setCenter:CGPointMake(stixView.center.x - 35, stixView.center.y)];
    [self setReloadMessage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"txt_uploadfailed.png"]]];
    [reloadMessage setFrame:CGRectMake(0,0, 117, 26)];
    [reloadMessage setCenter:CGPointMake(stixView.center.x, stixView.center.y - 40)];
    [self setReloadMessage2:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"txt_retry.png"]]];
    [reloadMessage2 setFrame:CGRectMake(0,0, 64, 36)];
    [reloadMessage2 setCenter:CGPointMake(reloadView.center.x + 60, reloadView.center.y)];
    //        [reloadView setBackgroundColor:[UIColor blackColor]];
    //        [reloadMessage2 setBackgroundColor:[UIColor redColor]];
    //        [reloadMessage setBackgroundColor:[UIColor greenColor]];
    //reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(reloadMessage.frame.origin.x, reloadMessage.frame.origin.y, 120, 70)];
    //[reloadButton setTag:[tag.tagID intValue]];
    //[reloadButton addTarget:self action:@selector(didClickReloadButton:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.view addSubview:reloadMessage];
    [self.view addSubview:reloadMessage2];
    //[self.view insertSubview:reloadButton aboveSubview:stixView];
    tapStartsReloading = YES;
}

-(void)initReloadView {
    if (reloadView)
    {
        [reloadView removeFromSuperview];
        [reloadMessage removeFromSuperview];
        [reloadMessage2 removeFromSuperview];
        [reloadButton removeFromSuperview];
    }
    [self setReloadView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_retry.png"]]];
    [reloadView setFrame:CGRectMake(0, 0, 60, 60)];
    [reloadView setCenter:[stixView center]];
    [self.view addSubview:reloadView];
    //[feedItem setReloadMessage:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"txt_retry.png"]]];

    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doSpin:reloadView forTime:30 withCompletion:^(BOOL finished){ 
        NSLog(@"Spin finished!");
        [self displayReloadView];
    }];
}

-(void)didClickReloadButton {
    tapStartsReloading = NO;
    if ([delegate respondsToSelector:@selector(didClickReloadButtonForFeedItem:)])
        [delegate didClickReloadButtonForFeedItem:self];
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
    
    //NSLog(@"Number of comments for feedItem %d: %d old frame height: %f new frame height: %d", self.tagID, [names count], self.view.frame.size.height, CONTENT_HEIGHT + commentContentHeight);
    
    CGRect frame = self.view.frame;
    int newHeight = CONTENT_HEIGHT + commentContentHeight;
    frame.size.height = MAX(newHeight, frame.size.height);
    [self.view setFrame:frame];
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

-(IBAction)didPressAddCommentButton:(id)sender {
#if 0
    if ([delegate respondsToSelector:@selector(displayCommentsOfTag:andName:)])
        [delegate displayCommentsOfTag:tagID andName:nameString];
#else
    if (isDisplayingLikeToolbar) {
        [self likeToolbarHide:-1];
    }
    else {
        [self likeToolbarShow];
    }
#endif
}
-(void)didPressSeeAllCommentsButton:(id)sender {
    if ([delegate respondsToSelector:@selector(displayCommentsOfTag:andName:)])
        [delegate displayCommentsOfTag:tagID andName:nameString];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
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
    
    UITapGestureRecognizer * myDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    [myDoubleTapRecognizer setNumberOfTapsRequired:2];
    [myDoubleTapRecognizer setNumberOfTouchesRequired:1];
    [myDoubleTapRecognizer setDelegate:self];
    
    //if (isPeelable)
    [self.view addGestureRecognizer:myDoubleTapRecognizer];
}

- (void)viewDidUnload
{
    NSLog(@"View did unload for feed item with tag id %d", [self tagID]);
    // Release any cached data, images, etc that aren't in use.

    NSLog(@"Super viewDidUnload");
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    NSLog(@"Delegate didReceiveMemoryWarning for self");
    [delegate didReceiveMemoryWarningForFeedItem:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/* StixViewDelegate */
-(NSString*)getUsername {
    return [delegate getUsername];
}
-(NSString*)getUsernameOfApp {
    return [delegate getUsernameOfApp];
}

-(void)didAttachStix:(int)index {
    // 1 = attach
    //[delegate didPerformPeelableAction:1 forAuxStix:index];
    
    // no more attach
}

-(void)didPeelStix:(int)index {
    // 0 = peel
    // show peel animation
    //[stixView doPeelAnimationForStix:index];
    
    // just call from stixView
}

-(void)peelAnimationDidCompleteForStix:(int)index {
    if ([delegate respondsToSelector:@selector(didPerformPeelableAction:forAuxStix:)])
        [delegate didPerformPeelableAction:0 forAuxStix:index];
}

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID {
    NSLog(@"VerticalFeedItemController with tagID %d calling delegate didReceiveRequestedStixView", [self tagID]);
    // send through to StixAppDelegate to save to defaults
    if ([delegate respondsToSelector:@selector(didReceiveRequestedStixViewFromKumulos:)])
        [delegate didReceiveRequestedStixViewFromKumulos:stixStringID];
}
-(void)didReceiveAllRequestedMissingStix:(StixView*)_stixView {
    NSLog(@"didReceiveAllRequestedMissingStix for id %d, isShowingPlaceHolder %d", tagID, stixView.isShowingPlaceholder);
#if USE_PLACEHOLDER
    if (!stixView.isShowingPlaceholder)
    //    return;
        NSLog(@"Placeholder for tagID %d already removed", tagID);
    
    //[placeholderView stopCompleteAnimation];
    [placeholderView removeFromSuperview];
#endif
    
    NSLog(@"VerticalFeedItemController removing placeholder for StixView %d tagID %d", stixView.stixViewID, tagID);
    //dispatch_async( dispatch_queue_create("com.Neroh.Stix.FeedItem.bgQueue", NULL), ^(void) {
        //[stixView populateWithAuxStixFromTag:tag];
        [self.view insertSubview:stixView belowSubview:imageView];
    //});
#if 1
    // fade in
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeIn:stixView forTime:.5 withCompletion:^(BOOL finished){  }];
    //[animation doJump:stixView inView:self.view forDistance:50 forTime:.5];
#endif
    
    stixView.isShowingPlaceholder = NO;
    [shareButton removeFromSuperview];
    [self.view addSubview:shareButton];
    
    // hack: forced retain of delegate (if it is DetailView)
    delegatePointer = nil;
}

//[k getStixDataByStixStringIDWithStixStringID:stixStringID];
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getStixDataByStixStringIDDidCompleteWithResult:(NSArray *)theResults {
    //NSMutableDictionary * d = [theResults objectAtIndex:0]; 
    //NSString * descriptor = [d valueForKey:@"stixDescriptor"];
    //NSLog(@"StixView requested stix data for %@", descriptor);
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
        // hack: sometimes the share and comment buttons don't respond first
        // check for that first
        if (CGRectContainsPoint([shareButton frame], location))
            [self didPressShareButton:shareButton];
            //return;
        else if (CGRectContainsPoint([addCommentButton frame], location)) 
            [self didPressAddCommentButton:addCommentButton];
        //else if (CGRectContainsPoint([reloadButton frame], location))
        //    [self didClickReloadButton:reloadButton];
            //return;
        else if (CGRectContainsPoint([likeIconSmiles frame], location)) 
            [self didClickLikeIconSmiles];
        else if (CGRectContainsPoint([likeIconLove frame], location)) 
            [self didClickLikeIconLove];
        else if (CGRectContainsPoint([likeIconWink frame], location)) 
            [self didClickLikeIconWink];
        else if (CGRectContainsPoint([likeIconShocked frame], location)) 
            [self didClickLikeIconShocked];
        else if (CGRectContainsPoint([likeIconComment frame], location)) 
            [self didClickLikeIconComment];
        else if (tapStartsReloading)
            [self didClickReloadButton];
        else if ([delegate respondsToSelector:@selector(didClickAtLocation:withFeedItem:)])
            [delegate didClickAtLocation:location withFeedItem:self];
    }
}

#pragma mark sharing

-(IBAction)didPressShareButton:(id)sender {
    if ([delegate respondsToSelector:@selector(didPressShareButtonForFeedItem:)])
        [delegate didPressShareButtonForFeedItem:self];
}

-(void)needsRetainForDelegateCall {
    // comes from stixView
    delegatePointer = delegate; // saves detailViewController if from detailView
}

-(void)doneWithAsynchronousDelegateCall {
    delegatePointer = nil;
}

/*
-(void)detailViewNeedsRetainForDelegateCall:(DetailViewController *)detailController {
    // comes from detailView
    delegatePointer = delegate; // saves detailViewController
}

-(void)detailViewDoneWithAsynchronousDelegateCall:(DetailViewController *)detailController {
    delegatePointer = nil;
}
 */

#pragma mark like toolbar

-(void)likeToolbarShow {
    if (!likeToolbarBg) {
        CGRect frame = [imageView frame];
        float iconY = frame.size.height-50;
        likeToolbarBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_comment_background@2x.png"]];
        [likeToolbarBg setFrame:CGRectMake(0, frame.size.height-50, frame.size.width, 50)];
        
        likeIconSmiles = [[UIButton alloc] initWithFrame:CGRectMake(15, iconY, 50, 50)];
        [likeIconSmiles setImage:[UIImage imageNamed:@"icon_pix_smiles@2x.png"] forState:UIControlStateNormal];
        [likeIconSmiles addTarget:self action:@selector(didClickLikeIconSmiles) forControlEvents:UIControlEventTouchUpInside];
        
        likeIconLove = [[UIButton alloc] initWithFrame:CGRectMake(75, iconY, 50, 50)];
        [likeIconLove setImage:[UIImage imageNamed:@"icon_pix_love@2x.png"] forState:UIControlStateNormal];
        [likeIconLove addTarget:self action:@selector(didClickLikeIconLove) forControlEvents:UIControlEventTouchUpInside];
        
        likeIconWink = [[UIButton alloc] initWithFrame:CGRectMake(135, iconY, 50, 50)];
        [likeIconWink setImage:[UIImage imageNamed:@"icon_pix_wink@2x.png"] forState:UIControlStateNormal];
        [likeIconWink addTarget:self action:@selector(didClickLikeIconWink) forControlEvents:UIControlEventTouchUpInside];
        
        likeIconShocked = [[UIButton alloc] initWithFrame:CGRectMake(195, iconY, 50, 50)];
        [likeIconShocked setImage:[UIImage imageNamed:@"icon_pix_shocked@2x.png"] forState:UIControlStateNormal];
        [likeIconShocked addTarget:self action:@selector(didClickLikeIconShocked) forControlEvents:UIControlEventTouchUpInside];
        
        likeIconComment = [[UIButton alloc] initWithFrame:CGRectMake(255, iconY, 50, 50)];
        [likeIconComment setImage:[UIImage imageNamed:@"icon_addcomment@2x.png"] forState:UIControlStateNormal];
        [likeIconComment addTarget:self action:@selector(didClickLikeIconComment) forControlEvents:UIControlEventTouchUpInside];

#if 1
        [self.view addSubview:likeToolbarBg];
        [self.view addSubview:likeIconSmiles];
        [self.view addSubview:likeIconLove];
        [self.view addSubview:likeIconWink];
        [self.view addSubview:likeIconShocked];
        [self.view addSubview:likeIconComment];
#else
        [likeToolbarBg addSubview:likeIconSmiles];
        [likeToolbarBg addSubview:likeIconLove];
        [likeToolbarBg addSubview:likeIconWink];
        [likeToolbarBg addSubview:likeIconShocked];
        [likeToolbarBg addSubview:likeIconComment];
        [self.view addSubview:likeToolbarBg];
#endif
    }

    [likeToolbarBg setAlpha:0];
    [likeIconSmiles setAlpha:0];
    [likeIconLove setAlpha:0];
    [likeIconWink setAlpha:0];
    [likeIconShocked setAlpha:0];
    [likeIconComment setAlpha:0];
    float fadeTime = .25;
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFade:likeToolbarBg inView:self.view toAlpha:1 forTime:fadeTime];
    [animation doFade:likeIconSmiles inView:self.view toAlpha:1 forTime:fadeTime];
    [animation doFade:likeIconLove inView:self.view toAlpha:1 forTime:fadeTime];
    [animation doFade:likeIconWink inView:self.view toAlpha:1 forTime:fadeTime];
    [animation doFade:likeIconShocked inView:self.view toAlpha:1 forTime:fadeTime];
    [animation doFade:likeIconComment inView:self.view toAlpha:1 forTime:fadeTime];
    
    isDisplayingLikeToolbar = YES;
    
    if ([delegate respondsToSelector:@selector(didDisplayLikeToolbar:)])
        [delegate didDisplayLikeToolbar:self];
}

-(void)likeToolbarHide:(int)selected {
//    [likeToolbarBg setAlpha:1];
    float fadeTimeLong = 1.25;
    float fadeTime = .25;
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFade:likeToolbarBg inView:self.view toAlpha:0 forTime:selected==-1?fadeTime:fadeTimeLong];
    [animation doFade:likeIconSmiles inView:self.view toAlpha:0 forTime:selected==0?fadeTimeLong:fadeTime];
    [animation doFade:likeIconLove inView:self.view toAlpha:0 forTime:selected==1?fadeTimeLong:fadeTime];
    [animation doFade:likeIconWink inView:self.view toAlpha:0 forTime:selected==2?fadeTimeLong:fadeTime];
    [animation doFade:likeIconShocked inView:self.view toAlpha:0 forTime:selected==3?fadeTimeLong:fadeTime];
    [animation doFade:likeIconComment inView:self.view toAlpha:0 forTime:fadeTime];
    isDisplayingLikeToolbar = NO;
}

-(void)didClickLikeIconSmiles {
    NSLog(@"Did click Smile!");
    [self likeToolbarHide:0];
    [delegate didClickLikeButton:0 withTagID:tagID];
}
-(void)didClickLikeIconLove {
    NSLog(@"Did click Love!");
    [self likeToolbarHide:1];
    [delegate didClickLikeButton:1 withTagID:tagID];
}
-(void)didClickLikeIconWink {
    NSLog(@"Did click Wink!");
    [self likeToolbarHide:2];
    [delegate didClickLikeButton:2 withTagID:tagID];
}
-(void)didClickLikeIconShocked {
    NSLog(@"Did click Shocked!");
    [self likeToolbarHide:3];
    [delegate didClickLikeButton:3 withTagID:tagID];
}
-(void)didClickLikeIconComment {
    NSLog(@"Did click Comment!");
    [self likeToolbarHide:-1];
    if ([delegate respondsToSelector:@selector(displayCommentsOfTag:andName:)])
        [delegate displayCommentsOfTag:tagID andName:nameString];
}

-(void)doubleTapGestureHandler:(UITapGestureRecognizer*) gesture {
    // warning: this gets recognized after single tap on a stix
    NSLog(@"Double tap!");
    [self didPressAddCommentButton:nil];
}

@end
