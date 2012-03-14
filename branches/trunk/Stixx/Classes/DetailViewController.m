//
//  DetailViewController.m
//  Stixx
//
//  Created by Bobby Ren on 11/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

//@synthesize labelComment;
//@synthesize labelLocationString;
@synthesize delegate;
@synthesize stixView;
@synthesize activityIndicator;
@synthesize logo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view setFrame:CGRectMake(160, 0, 320, 480)];
}

-(void)initDetailViewWithTag:(Tag*)tag {
    //NSLog(@"DetailView: Creating stix view of size %f %f", tag.image.size.width, tag.image.size.height);
    
    //CGRect frame = CGRectMake(3, 65, 314, 282);
    CGRect frame = CGRectMake(3, 3, 314, 282);
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:YES];
    [stixView setIsPeelable:NO];
    [stixView initializeWithImage:tag.image];
    [stixView populateWithAuxStixFromTag:tag];
    [stixView setDelegate:self];
    //[self.view addSubview:stixView];    
    tagID = [tag.tagID intValue];
}

// StixViewDelegate
-(void)didTouchInStixView:(StixView *)stixViewTouched {
    //[stixView removeFromSuperview];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = CGRectMake(3+320, 0, 320, 480);
    animationID[1] = [animation doSlide:self.view inView:self.view toFrame:frameOffscreen forTime:.5];
}

-(void)didFinishAnimation:(int)animID withCanvas:(UIView *)canvas {
    if (animID == animationID[1]) {
        [stixView release];
        [delegate didDismissZoom];
    }
}

-(void)startActivityIndicator {
    [logo setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    [logo setHidden:NO];
}

/*** commentFeedTableDelegate ***/

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

-(int)getCount {
    return [names count];
}

-(IBAction)didPressBackButton:(id)sender {    
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = CGRectMake(3+320, 0, 320, 480);
    animationID[1] = [animation doSlide:self.view inView:self.view toFrame:frameOffscreen forTime:.5];
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
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,46,320,380)];
    [self.view addSubview:scrollView];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.directionalLockEnabled = NO; // only allow vertical or horizontal scroll
    //[scrollView setDelegate:self];
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(150, 11, 25, 25)];
    
    if (names)
        [names release];
    if (comments)
        [comments release];
    if (stixStringIDs)
        [stixStringIDs release];
    names = [[NSMutableArray alloc] init];
    comments = [[NSMutableArray alloc] init];
    stixStringIDs = [[NSMutableArray alloc] init];
    
    if (commentsTable)
    {
        [commentsTable.view removeFromSuperview];
        [commentsTable release];
    }
    commentsTable = [[CommentFeedTableController alloc] init];
    [commentsTable.view setFrame:CGRectMake(0, 290, 320, 280)];
    [commentsTable setDelegate:self];
    
    [scrollView setContentSize:CGSizeMake(320, stixView.frame.size.height + commentsTable.view.frame.size.height + 10)];
    [scrollView addSubview:stixView];
    [scrollView addSubview:commentsTable.view];
    
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    [k getAllHistoryWithTagID:tagID];
}

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
    [commentsTable.tableView reloadData];

    // resize scrollview
    [commentsTable.view setFrame:CGRectMake(0, 290, 320, 70 * [names count])];
    [scrollView setContentSize:CGSizeMake(320, stixView.frame.size.height + commentsTable.view.frame.size.height + 10)];
    [self stopActivityIndicator];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //[imageView release];
    //[labelComment release];
    //[labelLocationString release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [scrollView release];
    [commentsTable release];
    [stixView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
