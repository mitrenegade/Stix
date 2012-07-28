//
//  NewsletterViewController.m
//  Stixx
//
//  Created by Bobby Ren on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsletterViewController.h"
#import <QuartzCore/QuartzCore.h>

#define ROW_HEIGHT_NEWS 45

@implementation NewsletterViewController

@synthesize tableView;
@synthesize delegate;
@synthesize activityIndicator;
#if USE_PULL_TO_REFRESH
@synthesize reloading=_reloading;
@synthesize refreshHeaderView;
@synthesize hasHeaderRow;
#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        k = [[Kumulos alloc] init];
        [k setDelegate:self];
        activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(LOADING_ANIMATION_X + 20, 9, 25, 25)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:activityIndicator];
#if USE_PULL_TO_REFRESH
    if (refreshHeaderView == nil) {
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
        refreshHeaderView.backgroundColor = [UIColor colorWithWhite:0 alpha:.85]; //[UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        refreshHeaderView.bottomBorderThickness = 1.0;
        [self.tableView addSubview:refreshHeaderView];
        self.tableView.showsVerticalScrollIndicator = YES;
    }
#endif
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [delegate didGetNews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)startActivityIndicator {
    [activityIndicator startCompleteAnimation];
}
-(void)stopActivityIndicator {
    [activityIndicator stopCompleteAnimation];
}

-(void)initializeNewsletter {
    [self startActivityIndicator];
    
    [k getNewsWithUsername:[delegate getUsername]];
    if (!agentArray) {
        agentArray = [[NSMutableArray alloc] init];
        newsArray = [[NSMutableArray alloc] init];
        newsFeedIDs = [[NSMutableArray alloc] init];
        thumbnailArray = [[NSMutableArray alloc] init];
        thumbnailTagID = [[NSMutableArray alloc] init];
        userIsFollowing = [[NSMutableDictionary alloc] init];
        thumbnailButtons = [[NSMutableArray alloc] init];
    }
    else {
        [agentArray removeAllObjects];
        [newsArray removeAllObjects];
        [newsFeedIDs removeAllObjects];
        [thumbnailArray removeAllObjects];
        [thumbnailTagID removeAllObjects];
        [userIsFollowing removeAllObjects];
        [thumbnailButtons removeAllObjects];
    }
}

-(void)initializeHeaderViews {
    if (!headerViews) {
        headerViews = [[NSMutableArray alloc] init];
    }
    else {
        [headerViews removeAllObjects];
    }
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    [header setBackgroundColor:[UIColor blackColor]];
    [header setAlpha:.75];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 320, 15)];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setText:@"All News"];
    [header addSubview:headerLabel];
    [headerViews addObject:header];
    
    NSLog(@"After initializing header views: %d sections", [headerViews count]);
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getNewsDidCompleteWithResult:(NSArray *)theResults {
    NSLog(@"Newsfeed for %@ returned %d results", [delegate getUsername], [theResults count]); 
    for (NSMutableDictionary * d in theResults) {
        NSNumber * hasBeenSeen = [d objectForKey:@"hasBeenSeen"];
        NSNumber * newsFeedID = [d objectForKey:@"newsfeedID"];

        NSString * agentName = [d objectForKey:@"agentName"];
        NSString * news = [d objectForKey:@"news"];
        NSData * data = [d objectForKey:@"thumbnail"];
        NSNumber * tagID = [d objectForKey:@"tagID"];
        if ([agentName isEqualToString:[delegate getUsername]]) {
            [k deleteNewsByIDWithNewsfeedID:[newsFeedID intValue]];
            continue;
            /*
            agentName = @"You";
            if ([news isEqualToString:@"loves your Pix."]) {
                news = @"love your Pix.";
            }
            if ([news isEqualToString:@"is shocked by your Pix."]) {
                news = @"are shocked by your Pix.";
            }
            if ([news isEqualToString:@"is now following you"]) {
                continue;
            }
             */
        }
        if ([news isEqualToString:@"is now following you"]) {
            if ([userIsFollowing objectForKey:agentName]) {
                [k deleteNewsByIDWithNewsfeedID:[newsFeedID intValue]];
                continue;
            }
            [userIsFollowing setObject:[NSNumber numberWithBool:YES] forKey:agentName];
        }

        [agentArray addObject:agentName];
        [newsArray addObject:news];
        [thumbnailTagID addObject:tagID];
        [newsFeedIDs addObject:newsFeedID];
        NSLog(@"Newsletter: %@ %@ %@", agentName, news, tagID);
        if ([data length] > 0) {
            UIImage * thumbnail = [UIImage imageWithData:data];
            [thumbnailArray addObject:thumbnail];
            CGRect frame = CGRectMake(5, 5, ROW_HEIGHT_NEWS-10, ROW_HEIGHT_NEWS-10);
            UIButton * accessoryView = [[UIButton alloc] initWithFrame:frame];
            [accessoryView setImage:thumbnail forState:UIControlStateNormal];
            [accessoryView addTarget:self action:@selector(didClickThumbnail:) forControlEvents:UIControlEventTouchDown];
            [accessoryView setTag:[tagID intValue]];
            [accessoryView setTag:[tagID intValue]];
            [thumbnailButtons addObject:accessoryView];
        }
        else {
            [thumbnailArray addObject:[NSNull null]];
            [thumbnailButtons addObject:[NSNull null]];
        }
    }
    
    if ([agentArray count] == 0) {
        NSString * agentName = [delegate getUsername];
        NSString * news = @"Welcome to Stix!";
        [agentArray addObject:agentName];
        [newsArray addObject:news];
        [thumbnailArray addObject:[NSNull null]];
    }
    
    [self initializeHeaderViews];
    [self stopActivityIndicator];
    [tableView reloadData];
}

#pragma mark - Table view data source

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT_NEWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 2;
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:30]];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic_divider"]]];
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 230, 12)];
        UILabel * commentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 230, 12)];
        nameLabel.textColor = [UIColor colorWithRed:153/255.0 green:51.0/255.0 blue:0.0 alpha:1.0];
		nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
		commentTextLabel.textColor = [UIColor blackColor];
		commentTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        [commentTextLabel setBackgroundColor:[UIColor clearColor]];
        
        UIButton * photoView = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, ROW_HEIGHT_NEWS-10, ROW_HEIGHT_NEWS-10)];
		[photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photoView.layer setBorderWidth: 2.0];
        [photoView addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        photoView.tag = PHOTO_TAG; // + [indexPath row];
        [cell.contentView addSubview:photoView];

        nameLabel.tag = LEFT_LABEL_TAG;
        commentTextLabel.tag = RIGHT_LABEL_TAG;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:commentTextLabel];
        [cell addSubview:cell.contentView];
    }
    
    // Configure the cell...
    int index = [indexPath row];
    if (index < [agentArray count])
    {
        NSLog(@"Displaying news at row %d", index);
        NSString * name = [agentArray objectAtIndex:index];
        NSString * news = [newsArray objectAtIndex:index];
        UIImage * photo = [delegate getUserPhotoForUsername:name];
        if ([name isEqualToString:@"You"]) {
            photo = [delegate getUserPhotoForUsername:[delegate getUsername]];
        }
        
        UILabel * nameLabel = (UILabel *)[cell viewWithTag:LEFT_LABEL_TAG];
        UILabel * newsLabel = (UILabel *)[cell viewWithTag:RIGHT_LABEL_TAG];
        
        CGSize commentSize = [news sizeWithFont:[newsLabel font] constrainedToSize:CGSizeMake(newsLabel.frame.size.width, newsLabel.frame.size.height*4) lineBreakMode:UILineBreakModeWordWrap];
        [newsLabel setFrame:CGRectMake(newsLabel.frame.origin.x, newsLabel.frame.origin.y, 230, commentSize.height)];
        [nameLabel setText:name];
        [newsLabel setText:news];

        // resize newslabel
        CGSize maximumLabelSize = CGSizeMake(320,ROW_HEIGHT_NEWS);
        CGSize expectedLabelSize = [name sizeWithFont:nameLabel.font
                                    constrainedToSize:maximumLabelSize 
                                              lineBreakMode:nameLabel.lineBreakMode];
        CGRect newFrame = nameLabel.frame;
        newFrame.size.width = expectedLabelSize.width;
        nameLabel.frame = newFrame;
        newFrame.origin.x += newFrame.size.width + 5;
        newFrame.size.width = 320 - newFrame.origin.x;
        [newsLabel setFrame:newFrame];

        UIButton * photoView = (UIButton*)[cell viewWithTag:PHOTO_TAG]; // + index];
        [photoView setImage:photo forState:UIControlStateNormal];
        photoView.titleLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
        photoView.titleLabel.hidden = YES;
        
        if ([thumbnailArray objectAtIndex:index] != [NSNull null] ) {
            UIButton * accessoryView = [thumbnailButtons objectAtIndex:index];
            //UIImageView * thumbnailView = [[UIImageView alloc] initWithImage:[thumbnailArray objectAtIndex:index]];
            //[thumbnailView setFrame:CGRectMake(5,5,ROW_HEIGHT_NEWS-10,ROW_HEIGHT_NEWS-10)];
            //[accessoryView addSubview:thumbnailView];
            cell.accessoryView = accessoryView;
            cell.accessoryType = UITableViewCellAccessoryNone;
            //[cell.contentView setBackgroundColor:[UIColor blueColor]];
        }
        else
            cell.accessoryView = nil;
        
        // count it as seen
        [k hasSeenNewsWithNewsfeedID:[[newsFeedIDs objectAtIndex:index] intValue] andHasBeenSeen:YES];
        [delegate decrementNewsCount];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // hack: assume that featured header always exists and is at index 0
    //int ret = SUGGESTIONS_SECTION_MAX;
    //if ([friends count] == 0)
    int ret = [headerViews count];
    ret = 1;
    NSLog(@"Returning number of sections: %d", ret);
    return ret;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // todo: each section is a date (today, last week, last month, etc)
    return MAX(1, [agentArray count]);
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section < [headerViews count])
        return [headerViews objectAtIndex:section];
    return nil;
}

-(void)refreshUserPhotos {
    [tableView reloadData];
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation hasSeenNewsDidCompleteWithResult:(NSNumber *)affectedRows {
    // do nothing
    //[delegate getNewsCount];
    //[delegate clearNewsCount];
}

#if USE_PULL_TO_REFRESH
#pragma mark ScrollView Callbacks
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
            NSLog(@"ScrollView: EGO refreshHeaderView going to normal");
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
            NSLog(@"ScrollView: EGO refreshHeaderView going to pulling");
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
        //[delegate didPullToRefreshDoActivityIndicator];
        [refreshHeaderView setState:EGOOPullRefreshLoading];
        [UIView animateWithDuration:.5
                              delay:0
                            options: UIViewAnimationCurveLinear
                         animations:^{
                             [self.tableView setContentInset:UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0)];
                         } 
                         completion:^(BOOL finished){
                             NSLog(@"EGO Refresh view: content inset at 60 - calling reloadTableViewDataSource");
                             [self reloadTableViewDataSource];
                             [UIView animateWithDuration:0.2
                                                   delay:1
                                                 options: UIViewAnimationCurveLinear
                                              animations:^{
                                                  [self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
                                              }
                                              completion:^(BOOL finished) {
                                                  NSLog(@"EGO Refresh view: content inset at 0");
                                                  [refreshHeaderView setState:EGOOPullRefreshNormal];
                                                  _reloading = NO;
                                              }
                              ];
                         }
         ];
	}
}

#pragma mark -
#pragma mark refreshHeaderView Methods

- (void)dataSourceDidFinishLoadingNewData{
    
    [self.tableView reloadData];
    if (_reloading) {
    	[UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];
        
        [refreshHeaderView setState:EGOOPullRefreshNormal];
        
    }
	_reloading = NO;
}

- (void) reloadTableViewDataSource
{
//    [self.delegate didPullToRefresh];
    [self initializeNewsletter];
}
#endif

-(void)didClickUserPhoto:(UIButton*)button {
    int row = [button.titleLabel.text intValue];
    NSString * name = [agentArray objectAtIndex:row];
    if ([name isEqualToString:@"You"])
        name = [delegate getUsername];
    NSLog(@"CommentFeedTable: did click on user's photo %d, username = %@", row, name);
    [delegate shouldDisplayUserPage:name];
}

-(void)didClickThumbnail:(UIButton*)button {
    int tagID = button.tag;
    NSLog(@"Clicking on thumbnail with tagID: %d", tagID);
    [delegate jumpToPageWithTagID:tagID];
}

@end
