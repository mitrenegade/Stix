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
        [stixView removeFromSuperview];
        [self.view insertSubview:placeholderView belowSubview:imageView];
    }
    else {
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
    int canShow = [stixView populateWithAuxStixFromTag:tag];
    if (canShow) {
        [self togglePlaceholderView:NO];
    }
    else {
        [self togglePlaceholderView:YES];
    }
    /*
    [shareButton removeFromSuperview];
    [self.view addSubview:shareButton];
    [addCommentButton removeFromSuperview];
    [self.view addSubview:addCommentButton];
     */
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
    [animation doSpin:reloadView forTime:10 withCompletion:^(BOOL finished){ 
        NSLog(@"Spin finished!");
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
    if ([delegate respondsToSelector:@selector(displayCommentsOfTag:andName:)])
        [delegate displayCommentsOfTag:tagID andName:nameString];
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
    if (!stixView.isShowingPlaceholder)
        return;
    
    //[placeholderView stopCompleteAnimation];
    [placeholderView removeFromSuperview];
    
    NSLog(@"VerticalFeedItemController removing placeholder for StixView %d tagID %d", stixView.stixViewID, tagID);
    dispatch_async( dispatch_queue_create("com.Neroh.Stix.FeedItem.bgQueue", NULL), ^(void) {
        [stixView populateWithAuxStixFromTag:tag];
        [self.view insertSubview:stixView belowSubview:imageView];
    });
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

-(void)didClickShareViaFacebook {
    shareMethod = 0;
    UIImage * result = [tag tagToUIImage];
    NSData *png = UIImagePNGRepresentation(result);
    
    UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil); // write to photo album
    
    [self uploadImage:png];
    
    NSString * metricName = @"SharePixActionsheet";
    [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:@"Method: Facebook" andIntegerValue:[[tag tagID] intValue]];
}

-(void)didClickShareViaEmail {
    shareMethod = 1;
    UIImage * result = [tag tagToUIImage];
    NSData *png = UIImagePNGRepresentation(result);
    
    UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil); // write to photo album
    
    [self uploadImage:png];
    
    NSString * metricName = @"SharePixActionsheet";
    [k addMetricWithDescription:metricName andUsername:[self getUsername] andStringValue:@"Method: Email" andIntegerValue:[tag.tagID intValue]];
}

-(void)uploadImage:(NSData *)dataPNG{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    if ([delegate respondsToSelector:@selector(sharePixDialogDidFinish)])
        [delegate sharePixDialogDidFinish];
    NSLog(@"Uploading data for share method: %d", shareMethod);
    
    NSString * username = [[self getUsername] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString * serverString = [NSString stringWithFormat:@"http://%@/users/%@/pictures", HOSTNAME, username];
    NSURL *url=[[NSURL alloc] initWithString:serverString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setData:dataPNG forKey:@"picture[data]"];
    [request startSynchronous];
    //[url autorelease]; // arc conversion

}

-(void)didSharePixWithURL:(NSString *)url andImageURL:(NSString*)imageURL{
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Pix shared by %@ at %@", [self getUsername], url);
    NSString * subject = [NSString stringWithFormat:@"%@ has shared a remixed photo with you", [self getUsername]];
    NSString * fullmessage = [NSString stringWithFormat:@"Let's remix photos with crazy, fun digital stickers... %@", url];
    if (shareMethod == 0) {
        // facebook
        FacebookHelper * fbHelper = [FacebookHelper sharedFacebookHelper];
        [fbHelper postToFacebookWithLink:url andPictureLink:imageURL andTitle:@"Stix it!" andCaption:@"Get Sticky with me..." andDescription:fullmessage];
    }
    else if (shareMethod == 1) {
        // email
        NSString *mailString = [NSString stringWithFormat:@"mailto:?to=&subject=%@&body=%@",
                                [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                [fullmessage  stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        
        NSLog(@"Sending mail: mailstring %@", mailString);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];    }
    if ([delegate respondsToSelector:@selector(sharePixDialogDidFinish)])
        [delegate sharePixDialogDidFinish];
}

#pragma mark ASIHTTP delegate 
/*** ASIhttp request delegate functions ***/
- (void) requestFinished:(ASIHTTPRequest *)request {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"Response %d : %@", request.responseStatusCode, [request responseString]);
    // the response is an HTML file of the redirect to the image page
    // in this image page there is a meta tag: <meta shared_id='<ID>'>
    // also the webURL: <meta web_url='/users/<USERNAME>/pictures/<ID>'>
    
    NSString * responseString = [request responseString];
    NSRange range0 = [responseString rangeOfString:@"<meta web_url"];
    NSRange range1 = [responseString rangeOfString:@"<meta shared_id"];
    if (range0.length == 0 || range1.length == 0) {
        NSLog(@"Create share page failed!");
        if ([delegate respondsToSelector:@selector(sharePixDialogDidFail:)])
            [delegate sharePixDialogDidFail:0];
    }
    else {
        range0.location = range0.location + 15;
        range0.length = range1.location - range0.location-3; // this could change based on how we output web
        NSString * substring = [responseString substringWithRange:range0];
        NSLog(@"substring for weburl: <%@>", substring);
        
        NSRange imgRange = [responseString rangeOfString:@"http://s3.amazonaws.com"];
        imgRange.length = 60;
        NSString * imgSubstring = [responseString substringWithRange:imgRange];
        NSRange imgRangeEnd = [imgSubstring rangeOfString:@"\" />"];
        imgRange.length = imgRangeEnd.location;
        imgSubstring = [responseString substringWithRange:imgRange];
        
        NSString * weburl = [NSString stringWithFormat:@"http://%@/%@", HOSTNAME,substring];
        [self didSharePixWithURL:weburl andImageURL:imgSubstring];
    }
}

- (void) requestStarted:(ASIHTTPRequest *) request {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSLog(@"request started...");
}

- (void) requestFailed:(ASIHTTPRequest *) request {
#if DEBUGX==1
    NSLog(@"Function: %s", __func__);
#endif  
    NSError *error = [request error];
    NSLog(@"%@", error);

    NSLog(@"ASIHttpRequest to upload image failed!");
    if ([delegate respondsToSelector:@selector(sharePixDialogDidFail:)])
        [delegate sharePixDialogDidFail:1];
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
@end
