//  VerticalFeedController.m
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//

#import "VerticalFeedController.h"

@implementation VerticalFeedController

//@synthesize carouselView;
@synthesize delegate;
@synthesize activityIndicator; // initially is active
@synthesize activityIndicatorLarge;
@synthesize feedItems;
@synthesize headerViews, headerViewsDidLoadPhoto;
@synthesize allTags;
@synthesize allTagsDisplayed;
@synthesize allTagsPending;
@synthesize tableController;
@synthesize lastPageViewed;
@synthesize commentView;
@synthesize camera;
@synthesize tabBarController;
@synthesize buttonProfile;
//@synthesize labelBuxCount;
//@synthesize statusMessage;
@synthesize newestTagIDDisplayed;
@synthesize logo;
@synthesize tagToRemix;

-(id)init
{
	self = [super initWithNibName:@"VerticalFeedController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	//[tbi setTitle:@"Feed"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_feed.png"];
	[tbi setImage:i];
    
    lastPageViewed = -1;
    
    return self;
}

-(void)initializeTable
{
    // We need to do some setup once the view is visible. This will only be done once.
    // Position and size the scrollview. It will be centered in the view.    
    CGRect frame = CGRectMake(0,44, 320, 380);
    tableController = [[FeedTableController alloc] init];
    [tableController.view setFrame:frame];
    [tableController.view setBackgroundColor:[UIColor clearColor]];
    tableController.delegate = self;
    [self.view insertSubview:tableController.view belowSubview:self.buttonProfile];
}

-(void)startActivityIndicator {
    //[logo setHidden:YES];
    [activityIndicator setHidden:NO];
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

-(void) viewDidLoad {
    [super viewDidLoad];
    lastPageViewed = 0;
    tempTagID = -1;

    [self initializeTable];

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 11, 25, 25)];
    
    //[activityIndicator setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:activityIndicator];

    //[self startActivityIndicator];
    //[logo setHidden:YES];
    /*
    UIButton * buttonBux = [[UIButton alloc] initWithFrame:CGRectMake(6, 7, 84, 33)];
    [buttonBux setImage:[UIImage imageNamed:@"bux_count.png"] forState:UIControlStateNormal];
    [buttonBux addTarget:self action:@selector(didClickMoreBuxButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:buttonBux belowSubview:tableController.view];
    
    CGRect labelFrame = CGRectMake(28, 5, 58, 38);
    labelBuxCount = [[OutlineLabel alloc] initWithFrame:labelFrame];
    //[labelBuxCount setBackgroundColor:[UIColor redColor]];
    [labelBuxCount setTextAlignment:UITextAlignmentCenter];
    [labelBuxCount setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [labelBuxCount drawTextInRect:CGRectMake(0,0, labelFrame.size.width, labelFrame.size.height)];
    [labelBuxCount setText:[NSString stringWithFormat:@"%d", 0]];
    [self.view insertSubview:labelBuxCount belowSubview:tableController.view];
    */
    // array to retain each FeedItemViewController as it is created so its callback
    // for the button can be used
    feedItems = [[NSMutableDictionary alloc] init]; 
    headerViews = [[NSMutableDictionary alloc] init];
    headerViewsDidLoadPhoto = [[NSMutableDictionary alloc] init];
    feedSectionHeights = [[NSMutableDictionary alloc] init];
    
    if (!stixEditorController)
    {
        stixEditorController = [[StixEditorViewController alloc] init];
        [stixEditorController setDelegate:self];
    }

    [self startActivityIndicator];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [self configureCarouselView];
//    [self.carouselView carouselTabDismiss:NO];
}

/*
-(void)configureCarouselView {
    // claim carousel for self
    NSLog(@"ConfigureCarouselView by VerticalFeedController");
    [self setCarouselView:[CarouselView sharedCarouselView]];
    [carouselView setDelegate:self];
    [carouselView setDismissedTabY:375-STATUS_BAR_SHIFT];
    [carouselView setExpandedTabY:5-STATUS_BAR_SHIFT+SHELF_LOWER_FROM_TOP];
    [carouselView setAllowTap:YES];
    //[carouselView removeFromSuperview];
    [self.view insertSubview:carouselView aboveSubview:tableController.view];
    [carouselView setUnderlay:tableController.view];
    //[carouselView carouselTabDismiss:NO];
    [carouselView resetBadgeLocations];
}
*/
 
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    //[self populateAllTagsDisplayed];
    //[tableController.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewDidAppear:animated];
    //[labelBuxCount setText:[NSString stringWithFormat:@"%d", [delegate getBuxCount]]];
  
    // test spin
//    StixAnimation * animation = [[StixAnimation alloc] init];
//    [animation doSpin:logo forTime:10 withCompletion:^(BOOL finished){ }];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
    //[scrollView clearNonvisiblePages];
}

//-(void)didClearPage:(int)page {
//    [[feedItems objectAtIndex:page] release];
//}

- (void)viewDidUnload {
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
    
    [super viewDidUnload];
}



/******* badge view delegate ******/
/*
-(void)didTapStixOfType:(NSString *)stixStringID {
    //[self.carouselView carouselTabDismissWithStix:badge];
    if ([allTagsDisplayed count]==0) {
    //    [carouselView resetBadgeLocations];
    //    [carouselView carouselTabDismiss:YES];
        return;        
    }
    //[self.carouselView carouselTabDismiss:NO];
    //[self.carouselView setStixSelected:stixStringID];
    CGPoint center = self.view.center;
    center.y -= tableController.view.frame.origin.y; // remove tableController offset
    //[badge setCenter:center];
    int section = [tableController getCurrentSectionAtPoint:center];
    lastPageViewed = section;
    [self didDropStixByTapOfType:stixStringID];
}

-(void)didDropStixByTapOfType:(NSString*)stixStringID {
    // tap inside the feed to add a stix
    Tag * tag;
    if (lastPageViewed < [allTagsPending count]) {
        tag = [allTagsPending objectAtIndex:lastPageViewed];
    }
    else
    {
        tag = [allTagsDisplayed objectAtIndex:lastPageViewed - [allTagsPending count]]; // lastPageViewed set by didTapStix
    }
    [self addAuxStixOfType:stixStringID toTag:tag];
}

-(void)didDropStixByDrag:(UIImageView *) badge ofType:(NSString*)stixStringID {
    if ([allTagsDisplayed count]==0) {
    //    [carouselView resetBadgeLocations];
    //    [carouselView carouselTabDismiss:YES];
        return;
    }
    CGPoint locationInSection = [tableController getContentPoint:badge.center inSection:lastPageViewed];
    locationInSection.y -= tableController.view.frame.origin.y; // remove tableController offset
    [badge setCenter:locationInSection];
    NSLog(@"VerticalFeedController: didDropStixByDrag: section found %d locationInSection origin %f %f center %f %f size %f %f", lastPageViewed, badge.frame.origin.x, badge.frame.origin.y, badge.center.x, badge.center.y, badge.frame.size.width, badge.frame.size.height);
    Tag * tag = [allTagsDisplayed objectAtIndex:lastPageViewed]; // lastPageViewed set by didDropStix
    [self addAuxStixOfType:stixStringID toTag:tag];
}

-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID {
    // comes here through carousel delegate
    // the frame of the badge is in the carousel frame
    // contains no information about which feedItem it was
    [self.carouselView carouselTabDismiss:YES];
    
    CGPoint center = badge.center;
    CGRect frame = badge.frame;
    // this was for drag and drop 
    //center.y -= tableController.view.frame.origin.y;
    int section = [tableController getCurrentSectionAtPoint:center];
    lastPageViewed = section;
    NSLog(@"VerticalFeedController: didDropStix center %f %f size %f %f section %d", center.x,center.y, frame.size.width, frame.size.height, section);
    [self didDropStixByDrag:badge ofType:stixStringID];
}
 */

/*
-(void)addAuxStixOfType:(NSString*)stixStringID toTag:(Tag*) tag{ 
    // HACK: will be changed soon if we have an addStix button
    
    // input badge should have frame within the tag's frame
    if (tag == nil) {
        // nothing loaded yet
        //[carouselView resetBadgeLocations];
        return;
    }

    CGPoint location = CGPointMake(160,216);
    auxView = [[AddStixViewController alloc] init];
    
    // hack a way to display view over camera; formerly presentModalViewController
    CGRect frameShifted = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [auxView.view setFrame:frameShifted];
    [self.camera setCameraOverlayView:auxView.view];
    
    auxView.delegate = self;
    [auxView initStixView:tag];
    //[auxView addNewAuxStix:badge ofType:stixStringID atLocation:location];
    [auxView configureCarouselView];
    [auxView addStixToStixView:stixStringID atLocation:location];
    //[auxView toggleCarouselView:NO];
    //[carouselView setExpandedTabY:5-STATUS_BAR_SHIFT]; // hack: a bit lower
    //[carouselView setDismissedTabY:375-STATUS_BAR_SHIFT];
    //[auxView.carouselView carouselTabExpand:NO];
    [auxView.carouselView carouselTabDismiss:YES];
    //[auxView.carouselView.scrollView setContentOffset:carouselView.scrollView.contentOffset];
    //[auxView didTapStix:badge ofType:stixStringID]; // simulate pressing of that stix
}
*/

-(void)didAddDescriptor:(NSString *)descriptor andComment:(NSString *)comment andLocation:(NSString *)location {
    Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:lastPageViewed];   
    if ([descriptor length] > 0) {
        NSString * name = [self.delegate getUsername];
        [delegate didAddCommentFromDetailViewController:nil withTagID:[t.tagID intValue] andUsername:name andComment:descriptor andStixStringID:@"COMMENT"];
        //        [self didAddNewComment:descriptor withTagID:[t.tagID intValue]];
    }
}

-(void)didAddStixWithStixStringID:(NSString *)stixStringID withLocation:(CGPoint)location withTransform:(CGAffineTransform)transform {
    // hack a way to remove view over camera; formerly dismissModalViewController
    [self.delegate didDismissSecondaryView];
    //[self configureCarouselView];
    //[self.carouselView carouselTabDismiss:YES];
    
    Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:lastPageViewed];   
    [delegate didAddStixToPix:t withStixStringID:stixStringID withLocation:location withTransform:transform];
    //    NSLog(@"Now tag id %d: %@ stix count is %d. User has %d left", [t.tagID intValue], badgeTypeStr, t.badgeCount, [delegate getStixCount:type]);
    
    //[carouselView resetBadgeLocations];
    //[self reloadCurrentPage]; // done in didAddStixToPix
}

-(void)didCancelAddStix {
    // hack a way to remove view over camera; formerly dismissModalViewController
    //[self configureCarouselView];
    //
    //NSLog(@"Is carousel showing? %d", [carouselView isShowingCarousel]);
    //[carouselView carouselTabExpand:NO];
    //[carouselView carouselTabDismiss:YES];
    [delegate didDismissSecondaryView];
    
#if 0
    if ([delegate getFirstTimeUserStage] == FIRSTTIME_MESSAGE_02) {
        //[tabBarController displayFirstTimeUserProgress:FIRSTTIME_MESSAGE_02];
        [tabBarController toggleFirstTimePointer:YES atStage:FIRSTTIME_MESSAGE_02];
    }
#else
    if ([delegate getFirstTimeUserStage] == FIRSTTIME_MESSAGE_02) {
        [delegate advanceFirstTimeUserMessage];
    }
#endif
}

-(int)getStixCount:(NSString*)stixStringID {
    return [delegate getStixCount:stixStringID];
}
-(int)getStixOrder:(NSString*)stixStringID {
    return [delegate getStixOrder:stixStringID];
}
-(int)getBuxCount {
    return [delegate getBuxCount];
}

-(void)didPurchaseStixFromCarousel:(NSString *)stixStringID {
    [self.delegate didPurchaseStixFromCarousel:stixStringID];
}

/*
-(BOOL)shouldPurchasePremiumPack:(NSString *)stixPackName {
    // just pass on
    return [delegate shouldPurchasePremiumPack:stixPackName];
}
 */

/*********** FeedTableView functions *******/

-(int)getHeightForSection:(int)index {
    Tag * tag;
    if (index < [allTagsPending count])
        tag = [allTagsPending objectAtIndex:index];
    else {
        if ([allTagsDisplayed count] <= index - [allTagsPending count])
            return 0;
        tag = [allTagsDisplayed objectAtIndex:(index-[allTagsPending count])];
    }
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
    //NSLog(@"GetHeightForSection: item at row %d: ID %d comments %d view %x frame %f %f %f %f feedSectionHeight %d", index, [tag.tagID intValue], [feedItem commentCount], feedItem.view, feedItem.view.frame.origin.x, feedItem.view.frame.origin.y, feedItem.view.frame.size.width, feedItem.view.frame.size.height, [[feedSectionHeights objectForKey:tag.tagID] intValue]);
    int feedItemHeight = feedItem.view.frame.size.height;
    /*
    if (![delegate isFollowing:tag.username]) {
        NSLog(@"Unfollowing %@ means removing feed item at section %d", tag.username, index);
        feedItemHeight = 0;
    }
     */
    // HACK: feedItem should not be dynamically changing
    if (feedItemHeight != CONTENT_HEIGHT)
        feedItemHeight = CONTENT_HEIGHT;
    return feedItemHeight+5;
}

-(int)heightForHeaderInSection:(int)index {
    int headerHeight = HEADER_HEIGHT;
    /*
     Tag * tag = [allTagsDisplayed objectAtIndex:index];
     if (![delegate isFollowing:tag.username]) {
        NSLog(@"Unfollowing %@ means removing feed item at section %d", tag.username, index);
        headerHeight = 0;
    }
     */
    return headerHeight;
}

-(Tag *) tagAtIndex:(int)index {
//    return [allTagsDisplayed objectAtIndex:index];
    Tag * tag;
    if (index < [allTagsPending count])
        tag = [allTagsPending objectAtIndex:index];
    else {
        if ([allTagsDisplayed count] <= index - [allTagsPending count])
            return nil;
        tag = [allTagsDisplayed objectAtIndex:(index-[allTagsPending count])];
    }
    return tag;
}

-(UIView*)viewForItemWithTagID:(NSNumber*)tagID {
    return [feedItems objectForKey:tagID];
}

-(void)didClickUserPhoto:(UIButton*)button {
    if (isOpeningProfile)
        return;
    isOpeningProfile = YES;
//    Tag * tag = [allTagsDisplayed objectAtIndex:button.tag];
    int index = button.tag;
    Tag * tag;
#if 0
    if (index < [allTagsPending count])
        tag = [allTagsPending objectAtIndex:index];
    else {
        if ([allTagsDisplayed count] <= index - [allTagsPending count])
            return;
        tag = [allTagsDisplayed objectAtIndex:(index-[allTagsPending count])];
    }
#else
    BOOL found = NO;
    for (int i=0; i<[allTagsPending count]; i++) {
        Tag * t = [allTagsPending objectAtIndex:i];
        if ([[t tagID] intValue] == index) {
            tag = [allTagsPending objectAtIndex:i];
            found = YES;
            break;
        }
    }
    if (!found) {
        for (int i=0; i<[allTagsDisplayed count]; i++) {
            Tag * t = [allTagsDisplayed objectAtIndex:i];
            if ([[t tagID] intValue] == index) {
                tag = [allTagsDisplayed objectAtIndex:i];
                found = YES;
                break;
            }
        }
    }
    if (!found)
        return;
#endif
    NSLog(@"Clicked on user photo %d in feed for user %@", button.tag, tag.username);
    [self shouldDisplayUserPage:tag.username];
}

-(void)didClickViaButton:(UIButton*)button {
    if (isOpeningProfile)
        return;
    isOpeningProfile = YES;
    //    Tag * tag = [allTagsDisplayed objectAtIndex:button.tag];
    int index = button.tag;
    Tag * tag;
    BOOL found = NO;
    for (int i=0; i<[allTagsPending count]; i++) {
        Tag * t = [allTagsPending objectAtIndex:i];
        if ([[t tagID] intValue] == index) {
            tag = [allTagsPending objectAtIndex:i];
            found = YES;
            break;
        }
    }
    if (!found) {
        for (int i=0; i<[allTagsDisplayed count]; i++) {
            Tag * t = [allTagsDisplayed objectAtIndex:i];
            if ([[t tagID] intValue] == index) {
                tag = [allTagsDisplayed objectAtIndex:i];
                found = YES;
                break;
            }
        }
    }
    if (!found)
        return;
    NSLog(@"Clicked on user photo %d in feed for original username <%@>", button.tag, tag.originalUsername);
    if (!tag.originalUsername || [tag.originalUsername length] == 0) {
        // backwards compatibility
        // try to parse out
        NSString * parsed = [tag.descriptor substringFromIndex:4];
        NSLog(@"Parsed username: <%@>", parsed);
        [self shouldDisplayUserPage:parsed];
    }
    else {
        [self shouldDisplayUserPage:tag.originalUsername];
    }
}

-(UIView*)headerForSection:(int)index {
    Tag * tag;
    if (index < [allTagsPending count])
        tag = [allTagsPending objectAtIndex:index];
    else {
        if ([allTagsDisplayed count] <= index - [allTagsPending count])
            return nil;
        tag = [allTagsDisplayed objectAtIndex:(index-[allTagsPending count])];
    }
    UIView * headerView = [headerViews objectForKey:tag.tagID];
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        [headerView setBackgroundColor:[UIColor blackColor]];
        [headerView setAlpha:.75];
        
        UIImage * photo = [[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:tag.username]];
        UIButton * photoView = [[UIButton alloc] initWithFrame:CGRectMake(3, 5, 30, 30)];
        [photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photoView.layer setBorderWidth: 2.0];
        if (photo) {
            [photoView setImage:photo forState:UIControlStateNormal];
            [headerViewsDidLoadPhoto setObject:[NSNumber numberWithBool:YES] forKey:tag.tagID];
        }
        else {
            [photoView setImage:[UIImage imageNamed:@"graphic_nopic.png"] forState:UIControlStateNormal];
            [headerViewsDidLoadPhoto setObject:[NSNumber numberWithBool:NO] forKey:tag.tagID];
        }
        [photoView setTag:[tag.tagID intValue]];
        [photoView addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:photoView];
        
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 260, 30)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        if ([tag.username length] > 26) {
            NSString * shortName = [tag.username substringToIndex:25];
            [nameLabel setText:[NSString stringWithFormat:@"%@...", shortName]];
        }
        else
            [nameLabel setText:tag.username];
        [headerView addSubview:nameLabel];
        
        UIButton * nameButton = [[UIButton alloc] initWithFrame:nameLabel.frame];
        //[nameButton setTitle:tag.username forState:UIControlStateNormal];
        //[nameButton.titleLabel setAlpha:0];
        [nameButton setBackgroundColor:[UIColor clearColor]];
        [nameButton setTag:[tag.tagID intValue]];
        [nameButton addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:nameButton];
        
        // the "Via..." label
        if ((tag.originalUsername != nil) && [tag.originalUsername length] != 0 && ![tag.originalUsername isEqualToString:tag.username]) {
            UILabel * subLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 21, 260, 15)];
            [subLabel setBackgroundColor:[UIColor clearColor]];
            [subLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0 alpha:1]];
            [subLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11]];
            //[locLabel setText:tag.locationString];
            [subLabel setText:tag.descriptor];
            [headerView addSubview:subLabel];    
        
            UIButton * viaButton = [[UIButton alloc] initWithFrame:subLabel.frame];
            [viaButton setTag:[tag.tagID intValue]];
            [viaButton setBackgroundColor:[UIColor clearColor]];
            [viaButton addTarget:self action:@selector(didClickViaButton:) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:viaButton];
        }

        UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 5, 60, 20)];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setTextColor:[UIColor whiteColor]];
        [timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:9]];
        [timeLabel setText:[Tag getTimeLabelFromTimestamp:tag.timestamp]];
        [headerView addSubview:timeLabel];
        
        [headerViews setObject:headerView forKey:tag.tagID];
        //[headerView autorelease]; // arc conversion
    }
    else {
        if ([[headerViewsDidLoadPhoto objectForKey:tag.tagID] boolValue] == NO) {
            // try to reload header photo
            UIImage * photo = [[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:tag.username]];
            if (photo) {
                UIButton * photoView = [[UIButton alloc] initWithFrame:CGRectMake(3, 5, 30, 30)];
                [photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
                [photoView.layer setBorderWidth: 2.0];
                [photoView setImage:photo forState:UIControlStateNormal];
                [photoView setTag:[tag.tagID intValue]];
                [photoView addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
                [headerView addSubview:photoView];
                [headerViewsDidLoadPhoto setObject:[NSNumber numberWithBool:YES] forKey:tag.tagID];
            }
        }
    }
    return [headerViews objectForKey:tag.tagID]; // MRC
}

-(UIView*)reloadViewForItemAtIndex:(int)index {
    // todo: reloadData only once for a batch of reloadViewForItem - maybe after requesting content from aggregator
    if (index > [allTagsDisplayed count]+[allTagsPending count]-1) {
        index = [allTagsDisplayed count]+[allTagsPending count]-1;
        NSLog(@"Here! Trying to reload index beyond allTagsDisplayed. Changing index to %d", index);    
    }
    Tag * tag;
    if (index < [allTagsPending count])
        tag = [allTagsPending objectAtIndex:index];
    else {
        if ([allTagsDisplayed count] <= index - [allTagsPending count])
            return nil;
        tag = [allTagsDisplayed objectAtIndex:(index-[allTagsPending count])];
    }
    NSLog(@"ReloadViewForItemAtIndex %d: - tag %d by user %@ with descriptor %@", index, [[tag tagID] intValue], tag.username, tag.descriptor);
    if ([tag.tagID intValue] == 5138) {
        NSLog(@"HERE! user %@ desc %@", tag.username, tag.descriptor);
    }
    VerticalFeedItemController * feedItem = [[VerticalFeedItemController alloc] init]; // do not autorelease
    [feedItem setDelegate:self];
    
    NSString * name = tag.username;
    NSString * descriptor = tag.descriptor;
    NSString * comment = tag.comment;
    NSString * locationString = tag.locationString;
    
    [feedItem.view setCenter:CGPointMake(160, feedItem.view.center.y+3)];
    [feedItem.view setBackgroundColor:[UIColor clearColor]];
    [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString];// andWithImage:image];
    [feedItem setTagID:[tag.tagID intValue]];
    UIImage * photo = [[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:name]];
    if (photo)
    {
        //NSLog(@"User %@ has photo of size %f %f\n", name, photo.size.width, photo.size.height);
        [feedItem populateWithUserPhoto:photo];
        //[photo autorelease]; // arc conversion
    }
    // add timestamp
    [feedItem populateWithTimestamp:tag.timestamp];
    // add badge and counts
    [feedItem initStixView:tag];
#if 1 //USE_PLACEHOLDER
    [feedItem togglePlaceholderView:0];
#endif
    int count = [self.delegate getCommentCount:feedItem.tagID];
    [feedItem populateWithCommentCount:count];
    if (0) { //shouldExpand) {
        NSMutableDictionary * theResults = [self.delegate getCommentHistoriesForTag:tag];
        //NSMutableDictionary * theResults = [commentHistories objectForKey:tag.tagID];
        if (theResults != nil) {
            NSMutableArray * names = [[NSMutableArray alloc] init];
            NSMutableArray * comments = [[NSMutableArray alloc] init];
            NSMutableArray * stixStringIDs = [[NSMutableArray alloc] init];
            NSLog(@"Comment histories for feed item with tagID %d has %d elements", [tag.tagID intValue], [theResults count]);
            //int ct = 0;
            for (NSMutableDictionary * d in theResults) {
                NSString * name = [d valueForKey:@"username"];
                NSString * comment = [d valueForKey:@"comment"];
                NSString * stixStringID = [d valueForKey:@"stixStringID"];
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
            }
            //[feedItem populateCommentsWithNames:names andComments:comments andStixStringIDs:stixStringIDs];
        }
    }

    // create overlay for pending feedItem
    if (index < [allTagsPending count]) {
        //[feedItem.view setAlpha:.25];
        NSLog(@"Calling initReloadView: index %d allTagsPending count %d", index, [allTagsPending count]);
        [[feedItem stixView] setInteractionAllowed:NO];
        [feedItem initReloadView];
    }

    // this object must be retained so that the button actions can be used
    [feedItems setObject:feedItem forKey:tag.tagID];
    
    [self.tableController.tableView reloadData];
    [tableController dataSourceDidFinishLoadingNewData];
    //[self stopActivityIndicator];
    //[self.activityIndicator stopCompleteAnimation];
    [feedSectionHeights setObject:[NSNumber numberWithInt:feedItem.view.frame.size.height] forKey:tag.tagID];
    return feedItem.view;
}

-(UIView*)viewForItemAtIndex:(int)index
{	        
    //index = index - 1;
    Tag * tag;
    if (index < [allTagsPending count])
        tag = [allTagsPending objectAtIndex:index];
    else {
        if ([allTagsDisplayed count] <= index - [allTagsPending count])
            return nil;
        tag = [allTagsDisplayed objectAtIndex:(index-[allTagsPending count])];
    }
    NSLog(@"ViewForItemAtIndex %d: - tag %d by %@", index, [[tag tagID] intValue], tag.username);
    VerticalFeedItemController * feedItem = nil;
    if (tag.tagID) {
        if (deallocatedIndices && [deallocatedIndices containsObject:tag.tagID]) {
            NSLog(@"Viewing deallocated index %d for tag item %d", index, [tag.tagID intValue]);
            feedItem = nil;
        }
        else
            feedItem = [feedItems objectForKey:tag.tagID];
    }
    
    if (!feedItem) {
        feedItem = [[VerticalFeedItemController alloc] init]; // do not autorelease until we no longer need it as a delegate
        [feedItem setDelegate:self];
            
        NSString * name = tag.username;
        NSString * descriptor = tag.descriptor;
        NSString * comment = tag.comment;
        NSString * locationString = tag.locationString;
        
        if ([tag.tagID intValue] == 5138) {
            NSLog(@"HERE! user %@ desc %@", tag.username, tag.descriptor);
        }
        if ([descriptor length]!=0)
            NSLog(@"Username: %@ descriptor: %@", name, descriptor);

        [feedItem.view setCenter:CGPointMake(160, feedItem.view.center.y+3)];
        feedItemViewOffset = feedItem.view.frame.origin; // same offset
        [feedItem.view setBackgroundColor:[UIColor clearColor]];
        [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString];// andWithImage:image];
        [feedItem setTagID:[tag.tagID intValue]];
        
#if 1
        [feedItem togglePlaceholderView:NO];
#endif
        
        //[feedItem.view setFrame:CGRectMake(0, 0, FEED_ITEM_WIDTH, FEED_ITEM_HEIGHT)]; 
        //[carouselView setSizeOfStixContext:feedItem.imageView.frame.size.width];
        UIImage * photo = [[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:name]];
        if (photo)
        {
            //NSLog(@"User %@ has photo of size %f %f\n", name, photo.size.width, photo.size.height);
            [feedItem populateWithUserPhoto:photo];
            //[photo autorelease]; // arc conversion
        }
        //NSLog(@"ViewForItem NEW: feedItem ID %d index %d size %f", [tag.tagID intValue], index, feedItem.view.frame.size.height);
        // add timestamp
        [feedItem populateWithTimestamp:tag.timestamp];
        // add badge and counts
        [feedItem initStixView:tag];
        if (tag.tagID) {
            feedItem.tagID = [tag.tagID intValue];
            int count = [self.delegate getCommentCount:feedItem.tagID];
            [feedItem populateWithCommentCount:count];
            
            // populate comments for this tag
            NSMutableArray * param = [[NSMutableArray alloc] init];
            [param addObject:tag.tagID];
            //[param autorelease]; // arc conversion
            KumulosHelper * kh = [[KumulosHelper alloc] init];
            [kh execute:@"getCommentHistory" withParams:param withCallback:@selector(didGetCommentHistoryWithResults:) withDelegate:self];
        }
        // create overlay for pending feedItem
        if (index < [allTagsPending count]) {
            Tag * tag = [allTagsPending objectAtIndex:0];
            NSLog(@"index %d feedItem tag %@ allTagsPending first object: tagID: %@", index, feedItem.tag.tagID, tag.tagID);
            //[feedItem.view setAlpha:.25];
            [[feedItem stixView] setInteractionAllowed:NO];
            [feedItem initReloadView];
        }
                
        // this object must be retained so that the button actions can be used
        if (tag.tagID)
            [feedItems setObject:feedItem forKey:tag.tagID];
    } 
    else {
        // see what the dimensions were saved previously
        //NSLog(@"ViewForItem EXISTS:  feedItem ID %d index %d view %x height: %f ", feedItem.tagID, index, feedItem.view, feedItem.view.frame.size.height);
    }
    
    // first time user arrow
    if ([delegate getFirstTimeUserStage] == FIRSTTIME_MESSAGE_02) {
        if (index % 2 == 0) {
            if (!firstTimeArrowCanvas[0]) {
                UIImage * pointerImg = [UIImage imageNamed:@"orange_arrow.png"];
                CGRect canvasFrame = CGRectMake(160-pointerImg.size.width/2, 240, pointerImg.size.width, pointerImg.size.height);
                firstTimeArrowCanvas[0] = [[UIView alloc] initWithFrame:canvasFrame];
                UIImageView * pointer = [[UIImageView alloc] initWithImage:pointerImg];
                //[firstTimeArrowCanvas addSubview:pointer];
                StixAnimation * animation = [[StixAnimation alloc] init];
                animation.delegate = self;
                [animation doBounce:pointer inView:firstTimeArrowCanvas[0] forDistance:20 forTime:1]; 
            }
            [firstTimeArrowCanvas[0] removeFromSuperview];
            [feedItem.view addSubview:firstTimeArrowCanvas[0]];
        }
        else {
            if (!firstTimeArrowCanvas[1]) {
                UIImage * pointerImg = [UIImage imageNamed:@"orange_arrow.png"];
                CGRect canvasFrame = CGRectMake(160-pointerImg.size.width/2, 240, pointerImg.size.width, pointerImg.size.height);
                firstTimeArrowCanvas[1] = [[UIView alloc] initWithFrame:canvasFrame];
                UIImageView * pointer = [[UIImageView alloc] initWithImage:pointerImg];
                //[firstTimeArrowCanvas addSubview:pointer];
                StixAnimation * animation = [[StixAnimation alloc] init];
                animation.delegate = self;
                [animation doBounce:pointer inView:firstTimeArrowCanvas[1] forDistance:20 forTime:1]; 
            }
            [firstTimeArrowCanvas[1] removeFromSuperview];
            [feedItem.view addSubview:firstTimeArrowCanvas[1]];
        }
    }
    
    //NSLog(@"ViewForItem: feedItem ID %d index %d view %x frame %f %f %f %f", feedItem.tagID, index, feedItem.view, feedItem.view.frame.origin.x, feedItem.view.frame.origin.y, feedItem.view.frame.size.width, feedItem.view.frame.size.height);
    //[feedSectionHeights setObject:[NSNumber numberWithInt:feedItem.view.frame.size.height] forKey:tag.tagID];
    return feedItem.view;
}

-(void)refreshViewForItemAtIndex:(int)index withTag:(Tag*)tag {
    // refreshes feedItem, without deleting it (so delegate function calls don't go haywire)
    // happens when peel stix causes feedItem to be deallocated
    NSLog(@"RefreshViewForItemAtIndex %d: tag %d by user %@", index, [tag.tagID intValue], tag.username);
    [self startActivityIndicator];
    if (index>[allTagsDisplayed count])
        index = 0;
    if ([allTagsDisplayed count] == 0) {
        [self stopActivityIndicator];
        return;
    }
    /*
    Tag * tag;
    if (index < [allTagsPending count])
        tag = [allTagsPending objectAtIndex:index];
    else {
        if ([allTagsDisplayed count] <= index - [allTagsPending count])
            return;
        tag = [allTagsDisplayed objectAtIndex:(index-[allTagsPending count])];
    }
     */
    
    // copy of reloadviewforitematindex
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
    
    if (!feedItem) {
        [self viewForItemAtIndex:index];
        return;
    }
    
    NSString * name = tag.username;
    NSString * descriptor = tag.descriptor;
    NSString * comment = tag.comment;
    NSString * locationString = tag.locationString;
    
    [feedItem populateWithName:name andWithDescriptor:descriptor andWithComment:comment andWithLocationString:locationString];
    UIImage * photo = [[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:name]];
    if (photo)
        [feedItem populateWithUserPhoto:photo];
    // add timestamp
    [feedItem populateWithTimestamp:tag.timestamp];
    int count = [self.delegate getCommentCount:feedItem.tagID];
    [feedItem populateWithCommentCount:count];

    // update stix
    [feedItem.stixView populateWithAuxStixFromTag:tag];
    
    // this object must be retained so that the button actions can be used
    [feedItems setObject:feedItem forKey:tag.tagID];
    
    [self.tableController.tableView reloadData];
}

-(UIImage*)getUserPhotoForUsername:(NSString *)username {
    return [delegate getUserPhotoForUsername:username];
}

-(void)didGetCommentHistoryWithResults:(NSMutableArray*)theResults {
    if ([theResults count] == 0)
        return;
    NSMutableArray * kumulosResults = [theResults objectAtIndex:0];
    if ([kumulosResults count] == 0)
        return;
    NSMutableDictionary * d = [kumulosResults objectAtIndex:0];
    NSNumber * tagID = [d objectForKey:@"tagID"];
    //NSLog(@"Adding comment history from kumulos: %d results for tag %d", [kumulosResults count], [tagID intValue]);
    //[commentHistories setObject:kumulosResults forKey:tagID];
    // expand feedview to display all comments
    // hack: to test expanding comments
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * tag = [allTagsDisplayed objectAtIndex:i];
        if ([tag.tagID intValue] == [tagID intValue]) {
            //NSLog(@"Displaying comments of tagID %d on page %d", [tag.tagID intValue], i);
            //[self reloadViewForItemAtIndex:i];
            return;
        }
    }
}

-(BOOL)jumpToPageWithTagID:(int)tagID {
    // find position of tag in allTagsDisplayed
    BOOL exists = NO;
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * t = [allTagsDisplayed objectAtIndex:i];
        if ([t.tagID intValue] == tagID) {
            //[self reloadViewForItemAtIndex:i];
            NSLog(@"JumpToPageWithTagID: %d Target row: %d", tagID, i);
            NSIndexPath * targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
            [tableController.tableView scrollToRowAtIndexPath:targetIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            exists = YES;
        }
    }
    if (!exists) {
        for (int i=0; i<[allTagsPending count]; i++) {
            Tag * t = [allTagsPending objectAtIndex:i];
            if ([t.tagID intValue] == tagID) {
                NSLog(@"JumpToPageWithTagID: %d Target row: %d", tagID, i);
                NSIndexPath * targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
                [tableController.tableView scrollToRowAtIndexPath:targetIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                exists = YES;
            }
        }
    }
    return exists;
}

-(IBAction)didClickJumpButton:(id)sender {
    // jumps to top
    if ([allTagsDisplayed count] == 0) {
        return;
    }
    NSIndexPath * targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableController.tableView scrollToRowAtIndexPath:targetIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(IBAction)didClickProfileButton:(id)sender {
    if ([delegate isShowingBuxInstructions])
        return;
    if ([delegate isDisplayingShareSheet])
        return;
    
    [delegate didOpenProfileView];
}

-(void)didPullToRefresh {
    [self updateScrollPagesAtPage:-1];
    [delegate checkAggregatorStatus];
    [self checkForUpdatedStix];
    [self updateFeedTimestamps];
}
-(void)didPullToRefreshDoActivityIndicator {
    [self startActivityIndicator];
}

-(void)updateScrollPagesAtPage:(int)page {
    [self startActivityIndicator];
    NSLog(@"VerticalFeedController: UpdateScrollPagesAtPage %d: AllTagsDisplayed currently has %d elements", page, [allTagsDisplayed count]);
    if ([self numberOfSections] > 0) {
        if (page < 0 + LAZY_LOAD_BOUNDARY) { // trying to find a more recent tag
            Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:0];
            int tagid = [t.tagID intValue];
            [self startActivityIndicator];
            [delegate getNewerTagsThanID:tagid];            
        }
        if (page >= [self numberOfSections] - LAZY_LOAD_BOUNDARY) { // trying to load an earlier tag
            Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:[self numberOfSections]-1];
            int tagid = [t.tagID intValue];
            [self startActivityIndicator];
            [delegate getOlderTagsThanID:tagid];
        }
    }
    else
    {
        NSLog(@"what's taking so long? sections %d tags %d feedItems %d", [self numberOfSections], [self itemCount], [feedItems count]);
        // no tags are loaded, just get the first few
        [delegate checkAggregatorStatus];
        [delegate getNewerTagsThanID:-1];
        //int lastIDNotDisplayed;
        if ([allTags count] == 0)
            [delegate getFirstTags];
        else {
            Tag * lastTag = [allTags objectAtIndex:0];
            int lastIDNotDisplayed = [[lastTag tagID] intValue];
            NSLog(@"allTags last tag: %d", lastIDNotDisplayed);
            [delegate getOlderTagsThanID:lastIDNotDisplayed];
        }
    }
}

-(void)reloadPage:(int)page {
    // forces scrollview to clear view at lastPageViewed, forces self to recreate FeedItem at lastPageViewed
    [self populateAllTagsDisplayed];
    [self startActivityIndicator];
    if (page>[allTagsDisplayed count])
        page = 0;
    if ([allTagsDisplayed count] == 0) {
        [self stopActivityIndicator];
        return;
    }
    [self reloadViewForItemAtIndex:page];
}

-(void)reloadPageForTagID:(int)tagID {
    NSMutableArray * allTagsNew = [delegate getTags];
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * tag = [allTagsDisplayed objectAtIndex:i];
        if ([tag.tagID intValue] == tagID) {
            [self reloadPage:i];
            return;
        }
    }
    if ([allTagsDisplayed count] == 0)
        [self reloadCurrentPage];
}

-(void)reloadCurrentPage {
    // forces scrollview to clear view at lastPageViewed, forces self to recreate FeedItem at lastPageViewed
    int section = [tableController getCurrentSectionAtPoint:CGPointMake(160, 240)];
    [self populateAllTagsDisplayed];
    //[activityIndicator startCompleteAnimation];
    [self startActivityIndicator];
    if (section>[allTagsDisplayed count])
        section = 0;
    if ([allTagsDisplayed count] == 0) {
        [self stopActivityIndicator];
        return;
    }
    [self reloadViewForItemAtIndex:section];
}

-(void)forceReloadWholeTableZOMG {
    NSLog(@"Calling forceReloadWholeTable - ZOMG!");
    
    int index = 0;
    for (int i=0; i<[[self.view subviews] count]; i++) {
        if ([[self.view subviews] objectAtIndex:i] == tableController.view) {
            index = i;
        }
    }
    [tableController.view removeFromSuperview];
    [tableController.tableView reloadData];
    [self.view insertSubview:tableController.view atIndex:index];
}

-(void)followListsDidChange {
    [self populateAllTagsDisplayed];
    [self forceReloadWholeTableZOMG];
    NSLog(@"After unfollowing user, there are %d tags on display.", [allTagsDisplayed count]);
}

-(void)populateAllTagsDisplayedWithTag:(Tag*)tag {
    // replaces an object with no auxStix with a new tag that has been populated with auxStix from kumulos
    BOOL found = NO;
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * t = [allTagsDisplayed objectAtIndex:i];
        if (t.tagID == tag.tagID) {
            [allTagsDisplayed replaceObjectAtIndex:i withObject:tag];
            //[self reloadPageForTagID:[tag.tagID intValue]];
            NSLog(@"PopulateAllTagsDisplayedWithTag with tagID: %d for allTagsDisplayed index %d", [tag.tagID intValue], i);
            [self refreshViewForItemAtIndex:i withTag:t];
            
            // remove placeholder
            VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
            if (!feedItem)
                NSLog(@"PopulateAllTagsDisplayedWithTag feeditem doesn't exist yet");
            [feedItem didReceiveAllRequestedMissingStix:[feedItem stixView]];
            found = YES;
            return;
        }
    }
    if (!found)
        NSLog(@"AllTagsDisplayed did not contain tagID %d", [tag.tagID intValue]);
}

-(void)populateAllTagsDisplayed {
    // allTags contains all tags that have been downloaded from the server
    // allTagsDisplayed contains only the tags that belong to the following list
    newestTagIDDisplayed = -1;
    self.allTags = [self.delegate getTags];
    if (!allTagsDisplayed)
        allTagsDisplayed = [[NSMutableArray alloc] init];
    [allTagsDisplayed removeAllObjects];
    NSMutableSet * followingSet = [delegate getFollowingList];
    NSMutableSet * followingSetWithMe = [[NSMutableSet alloc] initWithSet:followingSet];
    if ([delegate isLoggedIn]) {
        [followingSetWithMe addObject:[self getUsername]];
        for (int i=0; i<[allTags count]; i++) {
            Tag * tag = [allTags objectAtIndex:i];
            NSString * name = tag.username;
            if ([followingSetWithMe containsObject:name]) {
                [allTagsDisplayed addObject:tag];
                if ([tag.tagID intValue] > newestTagIDDisplayed)
                    newestTagIDDisplayed = [tag.tagID intValue];
            }            
            else {
                NSLog(@"Skipping tag %d with username %@", [tag.tagID intValue], tag.username);
                [feedItems removeObjectForKey:tag.tagID];
            }
        }
    }
    else
    {
        // display all tags
        [allTagsDisplayed addObjectsFromArray:allTags];
    }
    NSLog(@"After populateAllTagsDisplayed, allTagsDisplayed %d allTags %d", [allTagsDisplayed count], [allTags count]);
}

-(int)addTagForDisplay:(Tag *)tag {
    // add newly created tag so it appears in the feed
    // create temporary tag id and timestamps
    int originalID = [tag.tagID intValue];
    tag.tagID = [NSNumber numberWithInt:tempTagID]; // temp
    tag.pendingID = tempTagID;
    tempTagID--;
    tag.timestamp = [NSDate date];
    //[allTagsDisplayed insertObject:tag atIndex:0];
    if (!allTagsPending)
        allTagsPending = [[NSMutableArray alloc] init];
    [allTagsPending insertObject:tag atIndex:0];
    NSLog(@"Tag original ID %d pending ID %d allTagsPending %d",originalID, tag.pendingID, [allTagsPending count]);
    [self forceReloadWholeTableZOMG];
    return [tag.tagID intValue];
}

-(void)finishedCheckingForNewData:(bool)updated {
    [tableController dataSourceDidFinishLoadingNewData];
    if (updated)
        [self reloadViewForItemAtIndex:0];
    //[tableController setContentPageIDs:allTags];
    [self stopActivityIndicator];
    //[self.activityIndicator stopCompleteAnimation];
}

-(int)itemCount
{
	// Return the total number of pages that exist, including unfollowed pages
	return [allTags count];
}

-(int)numberOfSections {
    return [allTagsDisplayed count];
}

-(void)forceUpdateCommentCount:(int)tagID {
    // this function is called after StixxAppDelegate has retrieved the comment
    // count from kumulos and inserted it into the allCommentCounts array
    
    //for (int i=0; i<[feedItems count]; i++) {
    VerticalFeedItemController * curr = [feedItems objectForKey:[NSNumber numberWithInt:tagID]];
    [curr populateWithCommentCount:[self.delegate getCommentCount:tagID]];
}

/************** FeedItemDelegate ***********/
// comes from feedItem instead of carousel
-(void)didClickAtLocation:(CGPoint)location withFeedItem:(VerticalFeedItemController *)feedItem {
    
    return;  // no peeling
    /*
    // location is the click location inside feeditem's frame
    CGPoint locationInStixView = location;
    int peelableFound = [[feedItem stixView] findPeelableStixAtLocation:locationInStixView];
    NSLog(@"VerticalFeedController: Click on table at position %f %f with tagID %d peelableFound: %d\n", location.x, location.y, feedItem.tagID, peelableFound);
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * tag = [allTagsDisplayed objectAtIndex:i];
        if ([tag.tagID intValue] == feedItem.tagID) {
            lastPageViewed = i;
            break;            
        }
    }
     */
}

-(void)summonSubview:(UIView*)view {
    // display with an animation
    CGRect frameOffscreen = CGRectMake(-320, 0, 320, 480);
    [self.view addSubview:view];
    [view setFrame:frameOffscreen];
    
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished){
    }];
}

-(void)unsummonSubview:(UIView*)view {
    StixAnimation * animation = [[StixAnimation alloc] init];
    CGRect frameOffscreen = view.frame;
    
    frameOffscreen.origin.x -= 330;
    [animation doViewTransition:view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [view removeFromSuperview];
    }];    
}

-(void)displayEditorWithRemixMode:(int)remixMode {
    [delegate didClickRemixButton];
    
    if (!stixEditorController)
    {
        stixEditorController = [[StixEditorViewController alloc] init];
        [stixEditorController setDelegate:self];
    }

    // display with an animation
    NSLog(@"Displaying editor with remix mode %d", remixMode);
    CGRect frameOffscreen = CGRectMake(-320, 0, 320, 480);
    [self.view addSubview:stixEditorController.view];
    //[stixEditorController.view setFrame:frameOffscreen];
    
    // temporarily add to feed; also correctly assigns a pending tagID
    //int oldID = [tagToRemix.tagID intValue];
    //int pendingID = [self addTagForDisplay:tagToRemix];
    //NSLog(@"Remixing new tag with pending ID %d from original tagID %d", pendingID, oldID);
    
#if 0
    [stixEditorController initializeWithTag:tagToRemix remixMode:remixMode];    
    CGRect frameOnscreen = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:stixEditorController.view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished){
        // hack a way to display view over camera; formerly presentModalViewController
        [stixEditorController.view setFrame:frameOnscreen];
        [self.camera setCameraOverlayView:stixEditorController.view];        
    }];
#else
    CGRect frameOnscreen = CGRectMake(0, STATUS_BAR_SHIFT, 320, 480);
    [stixEditorController.view setFrame:frameOnscreen];
    [self.camera setCameraOverlayView:stixEditorController.view];        
    [stixEditorController initializeWithTag:tagToRemix remixMode:remixMode];
#endif
}

-(void)didClickRemixFromDetailView:(Tag*)tag {
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
    if (feedItem) {
        NSLog(@"Calling didClickRemixFromDetailView with tagID %@", tag.tagID);
        [self didClickRemixWithFeedItem:feedItem];
    }
}

-(BOOL)didClickNotesButton {
    // checks for first time user state
    return [delegate canClickNotesButton];
}

-(void)didClickRemixWithFeedItem:(VerticalFeedItemController *)feedItem {
    BOOL okToAdvance = [delegate canClickRemixButton]; // just to advance first time message, metrics, etc
    if (!okToAdvance)
        return;
    if (firstTimeArrowCanvas[0]) {
        [firstTimeArrowCanvas[0] removeFromSuperview];
        firstTimeArrowCanvas[0] = nil;
    }
    if (firstTimeArrowCanvas[1]) {
        [firstTimeArrowCanvas[1] removeFromSuperview];
        firstTimeArrowCanvas[1] = nil;
    }
    [self setTagToRemix:[feedItem.tag copy]];
    NSLog(@"Did click remix with feedItem by %@ with tagID %@, creating tagToRemix with ID %@", feedItem.tag.username, feedItem.tag.tagID, tagToRemix.tagID);
    if (tagToRemix.stixLayer) {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to remix?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remixed Photo", @"Original Photo", nil];
        //    [actionSheet showFromRect:CGRectMake(0, 0, 320,480) inView:self.view animated:YES];
        [actionSheet showFromTabBar:tabBarController.tabBar];
    }
    else {
        // no previous stix exist, automatically choose original mode
        [self displayEditorWithRemixMode:REMIX_MODE_USEORIGINAL];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    BOOL bUseOriginal = NO;
    int remixMode;
    if (buttonIndex == 0) {
        // remixed photo
        NSLog(@"Button 0");
        remixMode = REMIX_MODE_ADDSTIX;
    }
    else if (buttonIndex == 1) {
        // original photo
        NSLog(@"Button 1");
        remixMode = REMIX_MODE_USEORIGINAL;
    }
    else if (buttonIndex == 2) {
        NSLog(@"Button 2");
        tagToRemix = nil;
        return;
    }
    [self displayEditorWithRemixMode:remixMode];
}

-(void)didRemixNewPix:(Tag *)cameraTag remixMode:(int)remixMode{
    [delegate didRemixNewPix:cameraTag remixMode:remixMode];
}

-(void)didGetHighResImage:(UIImage *)highResImage forTagID:(NSNumber *)tagID {
    // optimization - only request high res image once
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tagID];
    Tag * t = feedItem.tag;
    [t setHighResImage:highResImage];
    
    for (int i=0; i<[allTags count]; i++) {
        Tag * t = [allTags objectAtIndex:i];
        if ([[t tagID] intValue] == [tagID intValue]) {
            NSLog(@"DidGetHighResImage: updating allTags at index %d", i);
            [t setHighResImage:highResImage];
            return;
        }
    }
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * t = [allTagsDisplayed objectAtIndex:i];
        if ([[t tagID] intValue] == [tagID intValue]) {
            NSLog(@"DidGetHighResImage: updating allTagsDisplayed at index %d", i);
            [t setHighResImage:highResImage];
            return;
        }
    }
}

-(void)displayCommentsOfTag:(int)tagID andName:(NSString *)nameString{
    if ([delegate getFirstTimeUserStage] < FIRSTTIME_DONE) {
        [delegate agitateFirstTimePointer];
        return;
    }
    if ([delegate isDisplayingShareSheet])
        return;
    if ([delegate isShowingBuxInstructions])
        return;
    
    if (commentView == nil) {
        commentView = [[CommentViewController alloc] init];
        [commentView setDelegate:self];
    }
    [commentView initCommentViewWithTagID:tagID andNameString:nameString];
    //[commentView setTagID:tagID];
    //[commentView setNameString:nameString];
    
    // hack a way to display feedback view over camera: formerly presentModalViewController
#if 0
    CGRect frameOffscreen = CGRectMake(-320, 0, 320, 480);
    [self.view addSubview:commentView.view];
    [commentView.view setFrame:frameOffscreen];
    
    CGRect frameOnscreen = CGRectMake(0, 0, 320, 480);
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doViewTransition:commentView.view toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished){
    }];
#else
    [self summonSubview:commentView.view];
#endif
    
    // must force viewDidAppear because it doesn't happen when it's offscreen?
    [commentView viewDidAppear:YES];     
}

#pragma mark StixEditorDelegate 

-(void)didCloseEditor {
#if 0
    [delegate didDismissSecondaryView];
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    CGRect frameOffscreen = stixEditorController.view.frame;
    
    frameOffscreen.origin.x -= 330;
    [animation doViewTransition:stixEditorController.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [stixEditorController.view removeFromSuperview];
    }];
#else
    [delegate didDismissSecondaryView];
    [stixEditorController.view removeFromSuperview];    
    [delegate didCloseEditorFromFeedController];
#endif
}

-(void)kumulosHelperDidCompleteWithCallback:(SEL)callback andParams:(NSMutableArray *)params {
    [self performSelector:callback withObject:params afterDelay:0];
}

// hack: forced display of comment page
-(void)openCommentForPageWithTagID:(NSNumber*)tagID {
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tagID];
    if (feedItem != nil) {
        [feedItem didClickAddCommentButton:self];
        for (int i=0; i<[allTagsDisplayed count]; i++) {
            Tag * tag = [allTagsDisplayed objectAtIndex:i];
            if ([tag.tagID intValue] == [tagID intValue]) {
                lastPageViewed = i;
            }
        }
    }
    // todo: implement for offline pending pics?
}

/*** CommentViewDelegate ***/
-(void)didCloseComments {
#if 1
    // hack a way to remove view over camera; formerly dismissModalViewController
    StixAnimation * animation = [[StixAnimation alloc] init];
    CGRect frameOffscreen = commentView.view.frame;
    
    frameOffscreen.origin.x -= 330;
    [animation doViewTransition:commentView.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [commentView.view removeFromSuperview];
    }];
#else
    [self unsummonSubview:commentView.view];
#endif
}

-(void)didAddNewComment:(NSString *)newComment withTagID:(int)tagID{
    NSString * name = [self.delegate getUsername];
    //int tagID = [commentView tagID];
    if ([newComment length] > 0)
        [delegate didAddCommentFromDetailViewController:nil withTagID:tagID andUsername:name andComment:newComment andStixStringID:@"COMMENT"];
    [self didCloseComments];
}

-(void)didClickLikeButton:(int)type withTagID:(int)tagID {
    NSString * newComment = @"";
    NSString * newType = @"LIKE";
    switch (type) {
        case 0:
            newComment = @"LIKE_SMILES";
            break;
        case 1:
            newComment = @"LIKE_LOVE";
            break;
        
        case 2:
            newComment = @"LIKE_WINK";
            break;
            
        case 3:
            newComment = @"LIKE_SHOCKED";
            break;
            
        default:
            break;
    }
    //[self didAddNewComment:newComment withTagID:tagID];
    NSString * name = [delegate getUsername];
//    if ([newComment length] > 0)
    [delegate didAddCommentFromDetailViewController:nil withTagID:tagID andUsername:name andComment:newComment andStixStringID:newType];
}

-(void)didDisplayLikeToolbar:(VerticalFeedItemController *)feedItem {
    if (!feedItemsWithLikeToolbar)
        feedItemsWithLikeToolbar = [[NSMutableArray alloc] init];
    
    [feedItemsWithLikeToolbar addObject:feedItem];
}

-(void) feedDidScroll {
    if (!feedItemsWithLikeToolbar || [feedItemsWithLikeToolbar count] == 0)
        return;
    
    for (int i=0; i<[feedItemsWithLikeToolbar count]; i++) {
        VerticalFeedItemController * feedItem = [feedItemsWithLikeToolbar objectAtIndex:i];
        [feedItem likeToolbarHide:-1];
    }
    [feedItemsWithLikeToolbar removeAllObjects];
}

//-(IBAction)feedbackButtonClicked:(id)sender {
//    [self.delegate didClickFeedbackButton:@"Feed view"];
//}

/*** FeedViewItemDelegate ***/
-(NSString*)getUsername {
    return [delegate getUsername];
}
-(NSString*)getUsernameOfApp {
    return [delegate getUsername];
}

-(void)didPerformPeelableAction:(int)action forAuxStix:(int)index {
    // change local tag structure for immediate display
    //Tag * tag = [allTagsDisplayed objectAtIndex:lastPageViewed];
    Tag * tag;
    if (lastPageViewed < [allTagsPending count])
        tag = [allTagsPending objectAtIndex:lastPageViewed];
    else
        tag = [allTagsDisplayed objectAtIndex:(lastPageViewed-[allTagsPending count])];
    // tell app delegate to reload tag before altering internal info
    [delegate didPerformPeelableAction:action forTagWithID:[tag.tagID intValue] forAuxStix:index];
}

/*
-(void)didDismissCarouselTab {
    if ([delegate getFirstTimeUserStage] == FIRSTTIME_MESSAGE_02) {
        [tabBarController toggleFirstTimePointer:YES atStage:FIRSTTIME_MESSAGE_02];
    }
}
-(void)didExpandCarouselTab {
    if ([delegate getFirstTimeUserStage] == FIRSTTIME_MESSAGE_02) {
        [tabBarController toggleFirstTimeInstructions:NO];
        [tabBarController toggleFirstTimePointer:NO atStage:FIRSTTIME_MESSAGE_02];
    }
}
*/

#pragma mark UserGalleryDelegate

-(void)shouldDisplayUserPage:(NSString *)username {
    if ([delegate isShowingBuxInstructions]) {
        isOpeningProfile = NO;
        return;        
    }
    if ([delegate isDisplayingShareSheet]) {
        isOpeningProfile = NO;
        return;
    }
    
#if 1    // custom callbacks needed here
    //    [self.delegate shouldDisplayUserPage:username];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    CGRect frameOffscreen = commentView.view.frame;
    frameOffscreen.origin.x -= 330;
    
    [animation doViewTransition:commentView.view toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        [commentView.view removeFromSuperview];
        [delegate shouldDisplayUserPage:username];
    }];
#else
    [self unsummonSubview:commentView.view];
#endif
}

-(void)unlockProfile {
    isOpeningProfile = NO;
}

/*
-(void)shouldCloseUserPage {
// doesn't come here
    [delegate shouldCloseUserPage];
}
*/

-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID {
    // send through to StixAppDelegate to save to defaults
    [delegate didReceiveRequestedStixViewFromKumulos:stixStringID];
    
    if (feedItemsWithLikeToolbar)
        [feedItemsWithLikeToolbar removeAllObjects];
}

#pragma mark bux instructions
-(BOOL)isShowingBuxInstructions {
    return [delegate isShowingBuxInstructions];
}
-(void)didClickMoreBuxButton:(id)sender {
    [delegate didShowBuxInstructions];
}

#pragma mark share
-(BOOL)isDisplayingShareSheet {
    return [delegate isDisplayingShareSheet];
}
-(void)didCloseShareSheet {
    CGRect frameOutside = CGRectMake(16-320, 22, 289, 380);
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    //shareMenuCloseAnimation = [animation doSlide:shareSheet inView:self.view toFrame:frameOutside forTime:.25];
    [animation doViewTransition:shareSheet toFrame:frameOutside forTime:.25 withCompletion:^(BOOL finished) {
        [self stopActivityIndicator];
        if (shareSheet) {
            shareSheet = nil;
            [buttonShareEmail removeFromSuperview];
            [buttonShareFacebook removeFromSuperview];
            [buttonShareClose removeFromSuperview];
            buttonShareClose = nil;
            buttonShareEmail = nil;
            buttonShareFacebook = nil;
        }
    }];
    
}

-(void)didClickCloseShareSheet {
    [self didCloseShareSheet];
    [delegate didCloseShareSheet];
}
/*
-(void)didClickShareViaFacebook {
    [self startActivityIndicator];
    if (!activityIndicatorLarge)
        activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
    [self.view addSubview:activityIndicatorLarge];
    [activityIndicatorLarge startCompleteAnimation];
    dispatch_async( dispatch_queue_create("com.Neroh.Stix.FeedController.bgQueue", NULL), ^(void) {
        [shareFeedItem didClickShareViaFacebook];
    });
    [self didCloseShareSheet];
}

-(void)didClickShareViaEmail {
    [self startActivityIndicator];
    [self didCloseShareSheet];
    if (!activityIndicatorLarge)
        activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
    [self.view addSubview:activityIndicatorLarge];
    [activityIndicatorLarge startCompleteAnimation];
    dispatch_async( dispatch_queue_create("com.Neroh.Stix.FeedController.bgQueue", NULL), ^(void) {
        [shareFeedItem didClickShareViaEmail];
    });
    [self didCloseShareSheet];
}
*/
-(void)didClickShareButtonForFeedItem:(VerticalFeedItemController *)feedItem {
    if ([delegate getFirstTimeUserStage] < FIRSTTIME_DONE) {
        [delegate agitateFirstTimePointer];
        return;
    }
    if ([delegate isShowingBuxInstructions])
        return;
    if ([delegate isDisplayingShareSheet])
        return;
#if 0
    shareFeedItem = feedItem;
    
    CGRect frameInside = CGRectMake(16, 22, 289, 380);
    CGRect frameOutside = CGRectMake(16-320, 22, 289, 380);
    shareSheet = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share_actions.png"]];
    [shareSheet setFrame:frameOutside];
    
    buttonShareFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonShareFacebook setFrame:CGRectMake(68-16, 175-22, 210, 60)];
    [buttonShareFacebook setBackgroundColor:[UIColor clearColor]];
    [buttonShareFacebook addTarget:self action:@selector(didClickShareViaFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    buttonShareEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonShareEmail setFrame:CGRectMake(68-16, 250-22, 210, 60)];
    [buttonShareEmail setBackgroundColor:[UIColor clearColor]];
    [buttonShareEmail addTarget:self action:@selector(didClickShareViaEmail) forControlEvents:UIControlEventTouchUpInside];
    
    buttonShareClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonShareClose setFrame:CGRectMake(270-16, 60-22, 37, 39)];
    [buttonShareClose setBackgroundColor:[UIColor clearColor]];
    [buttonShareClose addTarget:self action:@selector(didClickCloseShareSheet) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:shareSheet];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
//    shareMenuOpenAnimation = [animation doSlide:shareSheet inView:self.view toFrame:frameInside forTime:.25];
    [animation doViewTransition:shareSheet toFrame:frameInside forTime:.25 withCompletion:^(BOOL finished) {
        [self.view addSubview:buttonShareEmail];
        [self.view addSubview:buttonShareFacebook];
        [self.view addSubview:buttonShareClose];
    }];

    [delegate didDisplayShareSheet];
#else
    //for (int i=0; i<[allTags count]; i++) {
        //Tag * tag = [allTags objectAtIndex:i];
        //if ([tag.tagID intValue] == feedItem.tagID) {
        //    [delegate displayShareController:tag];
        //    return;
        //}
    //}
    [delegate doParallelNewPixShare:feedItem.tag];
#endif
}

-(void)startActivityIndicatorLarge {
    if (!activityIndicatorLarge)
        activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
    [self.view addSubview:activityIndicatorLarge];
    [activityIndicatorLarge startCompleteAnimation];
}

-(void)stopActivityIndicatorLarge {
    if (activityIndicatorLarge) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
            [activityIndicatorLarge setHidden:YES];
            [activityIndicatorLarge stopCompleteAnimation];
            [activityIndicatorLarge removeFromSuperview];
//        });
        //activityIndicatorLarge = nil;
    }
}

-(void)sharePixDialogDidFinish {
    [self didCloseShareSheet];
    [self startActivityIndicatorLarge];
    [delegate didCloseShareSheet];
}
-(void)sharePixDialogDidFail:(int)errorType {
    [self didCloseShareSheet];
    if (activityIndicatorLarge) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
            [activityIndicatorLarge setHidden:YES];
            [activityIndicatorLarge stopCompleteAnimation];
            [activityIndicatorLarge removeFromSuperview];
        });
        //activityIndicatorLarge = nil;
    }
    [delegate didCloseShareSheet];
    if (errorType == 0) {
        // upload picture malfunction
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Sharing Failed" message:@"It seems that our Share pages are under maintenance. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    else if (errorType == 1) {
        // asihttp request timeout
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Connectivity Failed" message:@"Could not contact Stix Share pages due to low internet connectivity. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas {
    // share menu
    if (animationID == shareMenuOpenAnimation) {
    }
    else if (animationID == shareMenuCloseAnimation) {
    }
}

-(void)finishedCreateNewPix:(Tag*)tag withPendingID:(int)pendingID {
    // remove from pending list
    for (int i=0; i<[allTagsPending count]; i++) {
        Tag * pendingTag = [allTagsPending objectAtIndex:i];
        NSLog(@"allTagsPending tag %d: id %@ pendingID %d ",i, pendingTag.tagID, pendingTag.pendingID);
        if (pendingTag.pendingID == pendingID) {
            NSLog(@"Founding pending tag in allTagsPending: pendingID %d index %d new record id %d", pendingID, i, [tag.tagID intValue]);
            
            // if we added a stix, save stix as comment history
            // new way to add stix
            // any stix created in offline mode will still get saved to auxStixStringId and other structures
            // first time a Pix is added to Kumulos, we call addAuxiliaryStixToPix based on its auxStix structures.
            // when a Pix is downloaded, we generate auxStix structures from auxiliaryStixes table, not from the saved auxStix in the tag
            /* // deprecated with stixeditor
            if ([pendingTag.auxStixStringIDs count] > 0) {
                [delegate pendingTagDidHaveAuxiliaryStix:pendingTag withNewTagID:[tag.tagID intValue]];
            } 
             */

            [allTagsPending removeObjectAtIndex:i];
            NSLog(@"finishedCreateNewPix removed object: alltagsPending now %d", [allTagsPending count]);
            /*
            [tag setAuxStixStringIDs:pendingTag.auxStixStringIDs];
            [tag setAuxLocations:pendingTag.auxLocations];
            [tag setAuxTransforms:pendingTag.auxTransforms];
            [tag setAuxPeelable:pendingTag.auxPeelable];
            [self populateAllTagsDisplayedWithTag:tag];
             */
            break;
        }
    }
   
    // force reload
    //[self populateAllTagsDisplayed];
#if 1
    [headerViews removeAllObjects];
    [self reloadPageForTagID:[tag.tagID intValue]];
    [tableController.tableView reloadData];
#else
    [headerViews removeAllObjects];
    [feedItems removeAllObjects];
    [self forceReloadWholeTableZOMG];
#endif

    NSLog(@"FeedController: finished create new pix: sharing ID %d", [tag.tagID intValue]);
    [self reloadPage:0];
    VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
    shareFeedItem = feedItem;
    //[delegate displayShareController:tag];
}

-(void)checkForUpdatedStix {
    NSLog(@"Checking for updated stix in 10 most recent tags");
    for (int i=0; i<MIN(20, [allTagsDisplayed count]); i++) {
        if (i >= [allTagsDisplayed count])
            break;
        Tag * tag = [allTagsDisplayed objectAtIndex:i];
        NSLog(@"Checking for updated stix at tag %d", [[tag tagID] intValue]);
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:tag, tag.tagID, nil];
        [kh execute:@"checkForUpdatedStix" withParams:params withCallback:@selector(khCallback_checkForUpdatedStix:) withDelegate:self];        
    }
}

-(void)khCallback_checkForUpdatedStix:(NSMutableArray*)returnParams {
#if 0
    Tag * tag = [returnParams objectAtIndex:0];
    BOOL needUpdate = NO;
    NSDate * timestamp = tag.timestamp;
    for (int i=1; i<[returnParams count]; i++) {
        NSMutableDictionary * historyItem = [returnParams objectAtIndex:i];
        NSDate * timestampHistory = [historyItem objectForKey:@"timeCreated"];
        if ([timestampHistory compare:timestamp] == NSOrderedDescending)
            needUpdate = YES;
    }
    if (needUpdate) {
        NSLog(@"Tag %d needs to update stix", [[tag tagID] intValue]);
        KumulosHelper * kh = [[KumulosHelper alloc] init];
        NSMutableArray * params = [[NSMutableArray alloc] initWithObjects:tag.tagID, nil];
        [kh execute:@"updateStixForPix" withParams:params withCallback:@selector(khCallback_updateStixForPix:) withDelegate:self];        
    } else {
        NSLog(@"Tag %d does not need to update stix", [[tag tagID] intValue]);
    }
#else
    Tag * updatingTag = [returnParams objectAtIndex:0];
    NSMutableArray * auxiliaryStix = [returnParams objectAtIndex:1];
    [updatingTag populateWithAuxiliaryStix:auxiliaryStix];
    [self populateAllTagsDisplayedWithTag:updatingTag];
#endif
}

-(void)khCallback_updateStixForPix:(NSMutableArray*)returnParams {
    NSNumber * tagID = [returnParams objectAtIndex:0];
    NSLog(@"UpdateStixForPix: %d", [tagID intValue]);
    NSMutableArray * theResults = [returnParams objectAtIndex:1];
    // find the correct tag in allTags;
    if ([theResults count] == 0)
        return;
    //Tag * tag = nil;
    for (NSMutableDictionary * d in theResults) {
        Tag * tag = [Tag getTagFromDictionary:d]; // MRC
        if ([tag.tagID intValue]== [tagID intValue]) {
//            tag = t; // MRC: when we break, t is not released so tag is retaining t
//            break;
            // find local tag and sync with kumulos tag
            Tag * localTag = nil;
            int index = -1;
            for (int i=0; i<[allTagsDisplayed count]; i++) {
                localTag = [allTagsDisplayed objectAtIndex:i];
                if ([localTag.tagID intValue] == [tagID intValue]) {
                    index = i;
                    NSLog(@"UpdateStixForPix: Found tag %d at index %d", [localTag.tagID intValue], index);
                    [allTagsDisplayed replaceObjectAtIndex:index withObject:tag];
                    [delegate addTagWithCheck:tag withID:[tag.tagID intValue] overwrite:YES];
                    //    [self reloadViewForItemAtIndex:index];
                    //    [self.tableController.tableView reloadData];
                    [self reloadPage:index];
                    return;
                }
            }

        }
    }
//    if (tag == nil)
        return;
}

-(void)updateFeedTimestamps {
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * tag = [allTagsDisplayed objectAtIndex:i];
        if (!tag.tagID) 
            continue;
        VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
        if (feedItem) {
            [[self headerViews] removeObjectForKey:tag.tagID];
            //[feedItem populateWithTimestamp:tag.timestamp];
            [self reloadPage:i];
        }
    }
}

-(void)didReceiveMemoryWarningForFeedItem:(VerticalFeedItemController *)feedItem {
    // feedItem will be released soon
    if (!deallocatedIndices)
        deallocatedIndices = [[NSMutableSet alloc] init];
    
    for (int i=0; i<[allTagsDisplayed count]; i++) {
        Tag * tag = [allTagsDisplayed objectAtIndex:i];
        if ([tag.tagID intValue] == feedItem.tagID) {
            NSLog(@"FeedView: reloading deallocated feedItem at index %d with tagID %d", i, feedItem.tagID);
            //[self reloadPage:i];
            //[feedItems removeObjectForKey:tag.tagID]; // will automatically cause reloadviewforitematindex
            [deallocatedIndices addObject:tag.tagID];
            return;
        }
    }
}

-(void)didClickReloadButtonForFeedItem:(VerticalFeedItemController *)feedItem {
    int tagID = [feedItem tagID];
    for (int i=0; i<[allTagsPending count]; i++) {
        Tag * tag = [allTagsPending objectAtIndex:i];
        if ([tag.tagID intValue] == tagID) {
            [delegate didReloadPendingPix:tag];
            [feedItem initReloadView];
            return;
        }
    }
    NSLog(@"didClickReloadButton couldn't find feedItem with tag %d", [feedItem tagID]);
}

-(void)showReloadPendingPix:(Tag *)failedTag {
    int tagID = [failedTag.tagID intValue];
    NSLog(@"Network connectivity problem: forcing reload view for feedItem with tagID %d", tagID);
    for (int i=0; i<[allTagsPending count]; i++) {
        Tag * tag = [allTagsPending objectAtIndex:i];
        if ([tag.tagID intValue] == tagID) {
            VerticalFeedItemController * feedItem = [feedItems objectForKey:tag.tagID];
            if (!feedItem)
                return;
            [feedItem displayReloadView];
            return;
        }
    }
}
@end

