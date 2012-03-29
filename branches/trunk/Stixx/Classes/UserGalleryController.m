//
//  UserGalleryController.m
//  Stixx
//
//  Created by Bobby Ren on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserGalleryController.h"

@implementation UserGalleryController

@synthesize username;
@synthesize pixTableController;
@synthesize delegate;
@synthesize headerView;
@synthesize k;
@synthesize activityIndicator;
@synthesize detailController;

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
    allTagIDs = [[NSMutableArray alloc] init];
    allTags = [[NSMutableDictionary alloc] init];
    contentViews = [[NSMutableDictionary alloc] init];

    if (!pixTableController) {
        CGRect frame = CGRectMake(0,44, 320, 460-44);
        pixTableController = [[ColumnTableController alloc] init];
        [pixTableController.view setFrame:frame];
        [pixTableController.view setBackgroundColor:[UIColor clearColor]];
        pixTableController.delegate = self;
        numColumns = 3;
        [pixTableController setNumberOfColumns:numColumns andBorder:4];
        [self.view addSubview:pixTableController.view];
    }
    k = [[Kumulos alloc] init];
    [k setDelegate:self];

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(150, 9, 25, 25)];
    [self.view addSubview:activityIndicator];
    [self forceReloadAll];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [headerView release];
    headerView = nil;
    [pixTableController release];
    pixTableController = nil;
    [k release];
    k = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark ColumnTableController delegate

-(UIView*)headerForSection:(NSInteger)section {
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        [headerView setBackgroundColor:[UIColor blackColor]];
        [headerView setAlpha:.75];
        
        UIImage * photo = [delegate getUserPhoto];
        UIImageView * photoView = [[[UIImageView alloc] initWithFrame:CGRectMake(3, 5, 30, 30)] autorelease];
        [photoView setImage:photo];
        [headerView addSubview:photoView];
        
        UILabel * nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(45, 0, 260, 30)] autorelease];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [nameLabel setText:username];
        [headerView addSubview:nameLabel];
    }
    return headerView;  
}

-(int)heightForHeader {
    return 40;
}

-(int)numberOfRows {
    double total = [allTagIDs count];
    //NSLog(@"allTagIDs has %d items", total);
    return ceil(total / numColumns);
}

-(UIView*)viewForItemAtIndex:(int)index
{    
    // for now, display images of friends, six to a page
    NSNumber * key = [NSNumber numberWithInt:index];
    
    if (index >= [allTagIDs count])
        return nil;
    
    if ([contentViews objectForKey:key] == nil) {
        NSNumber * tagID = [allTagIDs objectAtIndex:index];
        Tag * tag = [allTags objectForKey:tagID];
        
        //UIImageView * cview = [[UIImageView alloc] initWithImage:tag.image];
        
        int contentWidth = [pixTableController getContentWidth];
        int targetWidth = contentWidth;
        int targetHeight = 282 * targetWidth / 314.0    ; //tagImageSize.height * scale;
        CGRect frame = CGRectMake(0, 0, targetWidth, targetHeight);
        StixView * cview = [[StixView alloc] initWithFrame:frame];
        [cview setInteractionAllowed:YES];
        [cview setIsPeelable:NO];
        [cview setDelegate:self];
        [cview initializeWithImage:tag.image];
        [cview populateWithAuxStixFromTag:tag];
        [contentViews setObject:cview forKey:key];
        [cview release];
    }
    return [contentViews objectForKey:key];
}

-(void)loadContentPastRow:(int)row {
    NSLog(@"Loading row %d of total %d for gallery of user %@", row, [self numberOfRows], username);
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
    if (row == -1) {
        // load initial row(s)
        NSDate * now = [NSDate date]; // now
        [k getUserPixByTimeWithUsername:username andLastUpdated:now andNumRequested:[NSNumber numberWithInt:(numColumns*5)]];
    }
    else {
        NSNumber * tagID = [allTagIDs lastObject];
        Tag * tag = [allTags objectForKey:tagID];
        NSDate * lastUpdated = [tag.timestamp dateByAddingTimeInterval:-1];
        NSLog(@"lastUpdated: %@", lastUpdated);
        [k getUserPixByTimeWithUsername:username andLastUpdated:lastUpdated andNumRequested:[NSNumber numberWithInt:(numColumns*3)]];
    }
}

-(void)didPullToRefresh {
    [self forceReloadAll];
}

#pragma mark KumulosDelegate functions
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getUserPixByTimeDidCompleteWithResult:(NSArray *)theResults {
    for (int i=0; i<[theResults count]; i++) {
        NSMutableDictionary * d = [theResults objectAtIndex:i];
        Tag * newtag = [Tag getTagFromDictionary:d];
        [allTagIDs addObject:newtag.tagID]; // save in order 
        //NSLog(@"Explore recent tags: Downloaded tag ID %d at position %d", [newtag.tagID intValue], [allTagIDs count]);
        [allTags setObject:newtag forKey:newtag.tagID]; // save to dictionary
    }
    if ([theResults count]>0)
        [pixTableController dataSourceDidFinishLoadingNewData];
    [self stopActivityIndicator];
}

#pragma other functions
-(void)startActivityIndicator {
    [logo setHidden:YES];
    [self.activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [self.activityIndicator stopCompleteAnimation];
    [self.activityIndicator setHidden:YES];
    [logo setHidden:NO];
}

-(void)forceReloadAll {    
    [allTags removeAllObjects];
    [allTagIDs removeAllObjects];
    [contentViews removeAllObjects];
    [self loadContentPastRow:-1];
    //isZooming = NO;
    [self startActivityIndicator];
    //[activityIndicator startCompleteAnimation];
}

-(IBAction)didClickBackButton:(id)sender {
    [self.view removeFromSuperview];
}

#pragma mark DetailView 
/************** DetailView ***********/
-(void)didTouchInStixView:(StixView *)stixViewTouched {
    NSNumber * tagID = stixViewTouched.tagID;
    Tag * tag = [allTags objectForKey:tagID];
    detailController = [[DetailViewController alloc] init];
    [detailController setDelegate:self];    
    [detailController initDetailViewWithTag:tag];
    CGRect frameOffscreen = CGRectMake(320,0,320,480);
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:detailController.view];
    [detailController setScrollHeight:370];
    [detailController.view setFrame:frameOffscreen];
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doSlide:detailController.view inView:self.view toFrame:frameOnscreen forTime:.5];
}

-(void)sharePix:(int)tagID {
    //[self.delegate sharePix:tagID];
    shareActionSheetTagID = tagID;
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Pix" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Email", /*@"Move", */nil];
    [actionSheet showFromRect:CGRectMake(0,0,320,480) inView:self.view animated:YES];//showFromTabBar:self.tabBarController.tabBar];
    [actionSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // button index: 0 = "Facebook", 1 = "Email", 2 = "Cancel"
    switch (buttonIndex) {
        case 0: // Facebook
        {
            /*
             UIAlertView* alert = [[UIAlertView alloc]init];
             [alert addButtonWithTitle:@"Ok"];
             [alert setTitle:@"Beta Version"];
             [alert setMessage:@"Uploading Pix via Facebook coming soon!"];
             [alert show];
             [alert release];
             */
            Tag * tag = nil;
            tag = [allTags objectForKey:[NSNumber numberWithInt:shareActionSheetTagID]];
            if (tag == nil) {
                NSLog(@"Error in sharing pix! Tag doesn't exist!");
                return;
            }
            UIImage * result = [tag tagToUIImage];
            NSData *png = UIImagePNGRepresentation(result);
            
            UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil); // write to photo album
            
            [self.delegate uploadImage:png withShareMethod:buttonIndex];
            
            NSString * metricName = @"SharePixActionsheet";
            NSString * metricData = [NSString stringWithFormat:@"User: %@ Method: Facebook", [self getUsername]];
            [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:0];
        }
            break;
        case 1: // Email
        {
            Tag * tag = nil;
            tag = [allTags objectForKey:[NSNumber numberWithInt:shareActionSheetTagID]];
            if (tag == nil) {
                NSLog(@"Error in sharing pix! Tag doesn't exist!");
                return;
            }
            UIImage * result = [tag tagToUIImage];
            NSData *png = UIImagePNGRepresentation(result);
            
            UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil); // write to photo album
            
            [self.delegate uploadImage:png withShareMethod:buttonIndex];
            
            NSString * metricName = @"SharePixActionsheet";
            NSString * metricData = [NSString stringWithFormat:@"User: %@ Method: Email", [self getUsername]];
            [k addMetricHitWithDescription:metricName andStringValue:metricData andIntegerValue:0];
        }
            break;
        case 2: // Cancel
            return;
            break;
        default:
            return;
            break;
    }
}

-(void)didAddCommentWithTagID:(int)tagID andUsername:(NSString *)name andComment:(NSString *)comment andStixStringID:(NSString *)stixStringID {
    [self.delegate didAddCommentWithTagID:tagID andUsername:name andComment:comment andStixStringID:stixStringID];
}

-(void)didDismissZoom {
    //isZooming = NO;
    //[carouselView setUnderlay:scrollView];
    [detailController.view removeFromSuperview];
    [detailController release];
    detailController = nil;
}

-(NSString*)getUsername {
    return username;
}

-(UIImage*)getUserPhotoForUsername:(NSString*)name {
    return [delegate getUserPhoto];
}
@end
