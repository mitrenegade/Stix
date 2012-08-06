//  VerticalFeedController.m
//  Stixx
//
//  Created by Bobby Ren on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//

#import "VerticalFeedController.h"
#import <Crashlytics/Crashlytics.h>

@implementation VerticalFeedController

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
#if HAS_PROFILE_BUTTON
@synthesize buttonProfile;
#endif
//@synthesize statusMessage;
@synthesize newestTagIDDisplayed;
@synthesize logo;
@synthesize tagToRemix;

static int tickID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        lastPageViewed = -1;
    }
    return self;
}

-(void)initializeTable
{
    // We need to do some setup once the view is visible. This will only be done once.
    // Position and size the scrollview. It will be centered in the view.    
    // 44 for nav bar header size
    // 40 for tab bar
    // add 20 because no status bar
    CGRect frame = CGRectMake(0,OFFSET_NAVBAR, 320, 480-OFFSET_NAVBAR);
    tableController = [[FeedTableController alloc] init];
    [tableController.view setFrame:frame];
    [tableController.view setBackgroundColor:[UIColor clearColor]];
    tableController.delegate = self;
#if HAS_PROFILE_BUTTON
    [self.view insertSubview:tableController.view belowSubview:self.buttonProfile];
#else
    [self.view addSubview:tableController.view];
#endif
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
    // any frames set in viewDidLoad will happen before the nav controller appears.
    // so we are able to place activityIndicator in the header.
    // also, tables must be added with a Y offset of 44
    [super viewDidLoad];

    lastPageViewed = 0;
    tempTagID = -1;

    [self initializeTable];

    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X, 11, 25, 25)];
    
    //[activityIndicator setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:activityIndicator];

    //[self startActivityIndicator];
    //[logo setHidden:YES];

    // array to retain each FeedItemViewController as it is created so its callback
    // for the button can be used
    feedItems = [[NSMutableDictionary alloc] init]; 
    headerViews = [[NSMutableDictionary alloc] init];
    headerViewsDidLoadPhoto = [[NSMutableDictionary alloc] init];
    feedSectionHeights = [[NSMutableDictionary alloc] init];
    /*
    if (!stixEditorController)
    {
        stixEditorController = [[StixEditorViewController alloc] init];
        [stixEditorController setMyDelegate:self];
    }
     */
    [self startActivityIndicator];
    
    [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    //[self populateAllTagsDisplayed];
    //[tableController.tableView reloadData];
    //[self.buttonProfile setImage:[delegate getUserPhotoForUsername:[delegate getUsername]] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:HIDE_STATUS_BAR];
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

-(void)didAddDescriptor:(NSString *)descriptor andComment:(NSString *)comment andLocation:(NSString *)location {
    Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:lastPageViewed];   
    if ([descriptor length] > 0) {
        NSString * name = [self.delegate getUsername];
        [delegate didAddCommentFromDetailViewController:nil withTag:t andUsername:name andComment:descriptor andStixStringID:@"COMMENT"];
        //        [self didAddNewComment:descriptor withTagID:[t.tagID intValue]];
    }
}

-(void)didAddStixWithStixStringID:(NSString *)stixStringID withLocation:(CGPoint)location withTransform:(CGAffineTransform)transform {
    // hack a way to remove view over camera; formerly dismissModalViewController
    [self.delegate didDismissSecondaryView];
    
    Tag * t = (Tag*) [allTagsDisplayed objectAtIndex:lastPageViewed];   
    [delegate didAddStixToPix:t withStixStringID:stixStringID withLocation:location withTransform:transform];
    //    NSLog(@"Now tag id %d: %@ stix count is %d. User has %d left", [t.tagID intValue], badgeTypeStr, t.badgeCount, [delegate getStixCount:type]);
}

-(void)didCancelAddStix {
    // hack a way to remove view over camera; formerly dismissModalViewController
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
/*
-(int)getBuxCount {
    return [delegate getBuxCount];
}
 */

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
//    if (isOpeningProfile)
//        return;
//    isOpeningProfile = YES;
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
//    if (isOpeningProfile)
//        return;
//    isOpeningProfile = YES;
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
    if ([tag.tagID intValue] == 6019) {
        NSLog(@"here");
        NSLog(@"Tag username %@ comment %@ descriptor %@ original username %@", tag.username, tag.comment, tag.descriptor, tag.originalUsername);
    }
    UIView * headerView = [headerViews objectForKey:tag.tagID];
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        [headerView setBackgroundColor:[UIColor blackColor]];
        [headerView setAlpha:.75];
        
        UIImage * photo = [delegate getUserPhotoForUsername:tag.username]; //[[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:tag.username]];
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
            CGRect frame = CGRectMake(45, 21, 260, 15);
            UILabel * subLabel = [[UILabel alloc] initWithFrame:frame];
            [subLabel setBackgroundColor:[UIColor clearColor]];
            [subLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:0 alpha:1]];
            [subLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11]];
            [subLabel setText:tag.descriptor];
            [headerView addSubview:subLabel];    
        
            UIButton * viaButton = [[UIButton alloc] initWithFrame:frame];
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
            UIImage * photo = [delegate getUserPhotoForUsername:tag.username];//[[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:tag.username]];
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
    /*
    UIImage * photo = [delegate getUserPhotoForUsername:name];//[[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:name]];
    if (photo)
    {
        //NSLog(@"User %@ has photo of size %f %f\n", name, photo.size.width, photo.size.height);
        [feedItem populateWithUserPhoto:photo];
        //[photo autorelease]; // arc conversion
    }
     */
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
        /*
        UIImage * photo = [delegate getUserPhotoForUsername:name];//[[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:name]];
        if (photo)
        {
            //NSLog(@"User %@ has photo of size %f %f\n", name, photo.size.width, photo.size.height);
            [feedItem populateWithUserPhoto:photo];
            //[photo autorelease]; // arc conversion
        }
         */
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
        int i = index % 2;
        if (!firstTimeArrowCanvas[i]) {
            UIImage * calloutImg = [UIImage imageNamed:@"graphic_FTUE_callout"];
            CGRect canvasFrame = CGRectMake(160-calloutImg.size.width/2, 210, calloutImg.size.width, calloutImg.size.height);
            firstTimeArrowCanvas[i] = [[UIView alloc] initWithFrame:canvasFrame];
            UIImageView * callout = [[UIImageView alloc] initWithImage:calloutImg];
            CGRect labelFrame = CGRectMake(0, 0, calloutImg.size.width, calloutImg.size.height-30);
            UILabel * calloutLabel = [[UILabel alloc] initWithFrame:labelFrame];
            [calloutLabel setTextColor:[UIColor whiteColor]];
            [calloutLabel setTextAlignment:UITextAlignmentCenter];
            [calloutLabel setBackgroundColor:[UIColor clearColor]];
            [calloutLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [calloutLabel setText:@"Remix anyone's Pix"];
            [firstTimeArrowCanvas[i] addSubview:callout];
            [firstTimeArrowCanvas[i] addSubview:calloutLabel]; 
            /*
            StixAnimation * animation = [[StixAnimation alloc] init];
            animation.delegate = self;
            if (agitatePointer[i] > 0) {
                animationID[i] = [animation doJump:pointer inView:firstTimeArrowCanvas[i] forDistance:20 forTime:.15];
            }
            else {
                animationID[i] = [animation doJump:pointer inView:firstTimeArrowCanvas[i] forDistance:20 forTime:1];
            }
             */
        }
        //[firstTimeArrowCanvas[i] removeFromSuperview];
        //[feedItem.view addSubview:firstTimeArrowCanvas[i]];
        [self showFirstTimeArrowCanvas:i onFeedItem:(VerticalFeedItemController*)feedItem];
    }    
    //NSLog(@"ViewForItem: feedItem ID %d index %d view %x frame %f %f %f %f", feedItem.tagID, index, feedItem.view, feedItem.view.frame.origin.x, feedItem.view.frame.origin.y, feedItem.view.frame.size.width, feedItem.view.frame.size.height);
    //[feedSectionHeights setObject:[NSNumber numberWithInt:feedItem.view.frame.size.height] forKey:tag.tagID];
    return feedItem.view;
}

-(void)hideFirstTimeArrowCanvas:(int)i showAfterDelay:(float)delay{
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeOut:firstTimeArrowCanvas[i] forTime:.5 withCompletion:^(BOOL finished) {
        if (delay == 0)
            [firstTimeArrowCanvas[i] removeFromSuperview];
    }];
    if (delay != 0) {
        [self performSelector:@selector(redisplayFirstTimeArrowCanvas:) withObject:[NSNumber numberWithInt:i] afterDelay:delay];
    }
}
-(void)redisplayFirstTimeArrowCanvas:(NSNumber *)number {
    // doesn't change superview
    int i = [number intValue];
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeIn:firstTimeArrowCanvas[i] forTime:.5 withCompletion:^(BOOL finished) {
    }];
}

-(void)bounceInstructionsWithClock:(NSNumber *)lastTickID {
    if ([lastTickID intValue] == tickID) {
        NSLog(@"Bouncing on clock %@", lastTickID);
        for (int i=0; i<2; i++) {
            StixAnimation * animation = [[StixAnimation alloc] init];
            [animation doBounce:firstTimeArrowCanvas[i] forDistance:FTUE_BOUNCE_DISTANCE forTime:.5 repeatCount:FTUE_BOUNCE_COUNT];
        }
        [self performSelector:@selector(bounceInstructionsWithClock:) withObject:lastTickID afterDelay:FTUE_REDISPLAY_TIMER];
    }
    else {
        NSLog(@"Stopping bounce with clock %@", lastTickID);
    }
}

-(void)showFirstTimeArrowCanvas:(int)i onFeedItem:(VerticalFeedItemController*)feedItem {
    // at this point this should already be offscreen
    [firstTimeArrowCanvas[i] removeFromSuperview];
    [feedItem.view addSubview:firstTimeArrowCanvas[i]];
    StixAnimation * animation = [[StixAnimation alloc] init];
    [animation doFadeIn:firstTimeArrowCanvas[i] forTime:.5 withCompletion:^(BOOL finished) {
        [self bounceInstructionsWithClock:[NSNumber numberWithInt:(++tickID)]];
    }];
}

-(BOOL)hasFirstTimeUserMessageStage2 {
    return [delegate getFirstTimeUserStage] == FIRSTTIME_MESSAGE_02;
}

-(void)didClickFirstTimeUserMessage {
    [self hideFirstTimeArrowCanvas:0 showAfterDelay:FTUE_REDISPLAY_TIMER];
    [self hideFirstTimeArrowCanvas:1 showAfterDelay:FTUE_REDISPLAY_TIMER];
}

#if SHOW_ARROW
-(void)agitatePointer {
    agitatePointer[0] = 3;
    agitatePointer[1] = 3;
}
#endif

-(void)didFinishAnimation:(int)_animationID withCanvas:(UIView *)canvas {
#if SHOW_ARROW
    for (int i=0; i<2; i++) {
        if (_animationID == animationID[i]) // first jump animation finished
        {
            StixAnimation * animation = [[StixAnimation alloc] init];
            animation.delegate = self;
            float time = 1;
            if (agitatePointer[i] > 0) {
                agitatePointer[i]--;
                time = .15;
                animationID[i] = [animation doJump:canvas inView:firstTimeArrowCanvas[i] forDistance:20 forTime:time];
            }
            else {
                animationID[i] = [animation doJump:canvas inView:firstTimeArrowCanvas[i] forDistance:20 forTime:time];
            }
        }
    }
#endif
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
    /*
    UIImage * photo = [delegate getUserPhotoForUsername:name];//[[UIImage alloc] initWithData:[[delegate getUserPhotos] objectForKey:name]];
    if (photo)
        [feedItem populateWithUserPhoto:photo];
     */
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
    if (exists == NO) {
        [delegate requestTagWithTagID:tagID];
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

#if HAS_PROFILE_BUTTON
-(IBAction)didClickProfileButton:(id)sender {
    if ([delegate isShowingBuxInstructions])
        return;
    if ([delegate isDisplayingShareSheet])
        return;
    
    [delegate didOpenProfileView];
}
#endif

-(void)didPullToRefresh {
    [self updateScrollPagesAtPage:-1];
    [delegate checkAggregatorStatus];
    //[self checkForUpdatedStix];
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
    [headerViews removeAllObjects];
    [headerViewsDidLoadPhoto removeAllObjects];
    
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
    NSLog(@"Did click remix with feedItem with tagID %@, creating tagToRemix with ID %@", feedItem.tag.tagID, tagToRemix.tagID);
    [delegate didClickRemixFromDetailViewWithTag:feedItem.tag];
}
/*
-(void)didClickRemixWithFeedItem:(VerticalFeedItemController *)feedItem {
    BOOL okToAdvance = [delegate canClickRemixButton]; // just to advance first time message, metrics, etc
    if (!okToAdvance)
        return;
    if (firstTimeArrowCanvas[0]) {
        [self hideFirstTimeArrowCanvas:0 showAfterDelay:0];
        //[firstTimeArrowCanvas[0] removeFromSuperview];
        firstTimeArrowCanvas[0] = nil;
    }
    if (firstTimeArrowCanvas[1]) {
        [self hideFirstTimeArrowCanvas:1 showAfterDelay:0];
        //[firstTimeArrowCanvas[1] removeFromSuperview];
        firstTimeArrowCanvas[1] = nil;
    }
    tickID++;
    
    [self setTagToRemix:[feedItem.tag copy]];
    NSLog(@"Did click remix with feedItem by %@ with tagID %@, creating tagToRemix with ID %@", feedItem.tag.username, feedItem.tag.tagID, tagToRemix.tagID);
    if (tagToRemix.stixLayer) {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to remix?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remixed Photo", @"Original Photo", nil];
        [actionSheet showFromRect:CGRectMake(0, 0, 320,480) inView:self.view animated:YES];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        //[actionSheet showFromTabBar:tabBarController.tabBar];
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
        [self reloadCurrentPage];
        return;
    }
    [self displayEditorWithRemixMode:remixMode];
}
-(void)didRemixNewPix:(Tag *)cameraTag remixMode:(int)remixMode{
    [delegate didRemixNewPix:cameraTag remixMode:remixMode];
}

-(void)displayEditorWithRemixMode:(int)remixMode {
    [delegate didClickRemixButton];
    [delegate shouldDisplayStixEditor:tagToRemix withRemixMode:remixMode];
}
*/
-(void)displayCommentsOfTag:(Tag*)tag andName:(NSString *)nameString{
#if SHOW_ARROW
    if ([delegate getFirstTimeUserStage] < FIRSTTIME_DONE) {
        [delegate agitateFirstTimePointer];
        return;
    }
#endif
    if ([delegate isDisplayingShareSheet])
        return;
    if ([delegate isShowingBuxInstructions])
        return;
    
#if 0
    if (commentView == nil) {
        commentView = [[CommentViewController alloc] init];
        [commentView setDelegate:self];
    }
    int tagID = [tag.tagID intValue];
    [commentView initCommentViewWithTagID:tagID andNameString:nameString];
    //[commentView setTagID:tagID];
    //[commentView setNameString:nameString];
    
    // hack a way to display feedback view over camera: formerly presentModalViewController
    [self summonSubview:commentView.view];
    // must force viewDidAppear because it doesn't happen when it's offscreen?
    [commentView viewDidAppear:YES];     
#else
    [delegate shouldDisplayCommentViewWithTag:tag andNameString:nameString];
#endif
}

#pragma mark StixEditorDelegate 
/*
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
*/
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

-(void)didAddNewComment:(NSString *)newComment withTag:(Tag*)tag{
    NSString * name = [self.delegate getUsername];
    //int tagID = [commentView tagID];
    if ([newComment length] > 0)
        [delegate didAddCommentFromDetailViewController:nil withTag:tag andUsername:name andComment:newComment andStixStringID:@"COMMENT"];
    [self didCloseComments];
}

-(void)didClickLikeButton:(int)type withTag:(Tag*)_tag {
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
    [delegate didAddCommentFromDetailViewController:nil withTag:_tag andUsername:name andComment:newComment andStixStringID:newType];
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

//-(void)unlockProfile {
//    isOpeningProfile = NO;
//}

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
        [self stopActivityIndicatorLarge];
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
-(void)didClickShareButtonForFeedItem:(VerticalFeedItemController *)feedItem {
#if SHOW_ARROW
    if ([delegate getFirstTimeUserStage] < FIRSTTIME_DONE) {
        [delegate agitateFirstTimePointer];
        return;
    }
#endif
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
    if (!activityIndicatorLarge) {
        activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
        [self.view addSubview:activityIndicatorLarge];
    }
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

