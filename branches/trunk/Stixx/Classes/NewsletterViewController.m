//
//  NewsletterViewController.m
//  Stixx
//
//  Created by Bobby Ren on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsletterViewController.h"
#import <QuartzCore/QuartzCore.h>

#define ROW_HEIGHT 45

@implementation NewsletterViewController

@synthesize tableView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        k = [[Kumulos alloc] init];
        [k setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initializeNewsletter {
    [k getNewsWithUsername:[delegate getUsername]];
    
    agentArray = [[NSMutableArray alloc] init];
    newsArray = [[NSMutableArray alloc] init];
    thumbnailArray = [[NSMutableArray alloc] init];
}

-(void)initializeHeaderViews {
    if (!headerViews) {
        headerViews = [[NSMutableArray alloc] init];
    }
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    [header setBackgroundColor:[UIColor blackColor]];
    [header setAlpha:.75];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 320, 15)];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setText:@"All news"];
    [header addSubview:headerLabel];
    [headerViews addObject:header];
    
    NSLog(@"After initializing header views: %d sections", [headerViews count]);
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getNewsDidCompleteWithResult:(NSArray *)theResults {
    NSLog(@"Newsfeed for %@ returned %d results", [delegate getUsername], [theResults count]);
 
    for (NSMutableDictionary * d in theResults) {
        NSString * agentName = [d objectForKey:@"agentName"];
        NSString * news = [d objectForKey:@"news"];
        NSData * data = [d objectForKey:@"thumbnail"];
        [agentArray addObject:agentName];
        [newsArray addObject:news];
        if (data)
            [thumbnailArray addObject:[UIImage imageWithData:data]];
        else {
            [thumbnailArray addObject:[NSNull null]];
        }
    }
    
    if ([agentArray count] == 0) {
        NSString * agentName = [delegate getUsername];
        NSString * news = @"has no news";
        [agentArray addObject:agentName];
        [newsArray addObject:news];
        [thumbnailArray addObject:[NSNull null]];
    }
    
    [self initializeHeaderViews];
    [tableView reloadData];
}

#pragma mark - Table view data source

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
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
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 22, 230, 12)];
        UILabel * commentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 22, 230, 12)];
        nameLabel.textColor = [UIColor colorWithRed:153/255.0 green:51.0/255.0 blue:0.0 alpha:1.0];
		nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
		commentTextLabel.textColor = [UIColor blackColor];
		commentTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
        [commentTextLabel setBackgroundColor:[UIColor clearColor]];
        
        UIButton * photoView = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, ROW_HEIGHT-10, ROW_HEIGHT-10)];
		[photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photoView.layer setBorderWidth: 2.0];
        [photoView addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        nameLabel.tag = LEFT_LABEL_TAG;
        commentTextLabel.tag = RIGHT_LABEL_TAG;
        photoView.tag = PHOTO_TAG; // + [indexPath row];
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:commentTextLabel];
        [cell.contentView addSubview:photoView];
        [cell addSubview:cell.contentView];
    }
    
    // Configure the cell...
    int index = [indexPath row];
    if (index < [agentArray count])
    {
        NSString * name = [agentArray objectAtIndex:index];
        NSString * news = [newsArray objectAtIndex:index];
        UIImage * photo = [delegate getUserPhotoForUsername:name];
        
        UILabel * nameLabel = (UILabel *)[cell viewWithTag:LEFT_LABEL_TAG];
        UILabel * newsLabel = (UILabel *)[cell viewWithTag:RIGHT_LABEL_TAG];
        
        CGSize commentSize = [news sizeWithFont:[newsLabel font] constrainedToSize:CGSizeMake(newsLabel.frame.size.width, newsLabel.frame.size.height*4) lineBreakMode:UILineBreakModeWordWrap];
        [newsLabel setFrame:CGRectMake(newsLabel.frame.origin.x, newsLabel.frame.origin.y, 230, commentSize.height)];
        [nameLabel setText:name];
        [newsLabel setText:news];

        // resize newslabel
        CGSize maximumLabelSize = CGSizeMake(320,ROW_HEIGHT);
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
            UIView * accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ROW_HEIGHT, ROW_HEIGHT)];
            UIImageView * thumbnailView = [[UIImageView alloc] initWithImage:[thumbnailArray objectAtIndex:index]];
            [thumbnailView setFrame:CGRectMake(5,5,ROW_HEIGHT-10,ROW_HEIGHT-10)];
            [accessoryView addSubview:thumbnailView];
            cell.accessoryView = accessoryView;
            cell.accessoryType = UITableViewCellAccessoryNone;
            //[cell.contentView setBackgroundColor:[UIColor blueColor]];
        }
        else
            cell.accessoryView = nil;
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

@end
