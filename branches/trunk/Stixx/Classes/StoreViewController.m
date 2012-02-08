//
//  StoreViewController.m
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StoreViewController.h"

@implementation StoreViewController

//@synthesize badgeView;
@synthesize delegate;
@synthesize buttonBack;
//@synthesize tableController;
@synthesize buttonFeedback;
@synthesize coverflowController;
@synthesize k;
@synthesize activityIndicator;
@synthesize lastUpdate;

static NSDate * timestampCategories;
static NSDate * timestampStixTypes;

#define BADGE_Store_PADDING 45 // how many pixels per side in Store view

-(id)init
{
	self = [super initWithNibName:@"StoreViewController" bundle:nil];
	
	// create tab bar item to become a tab view
	UITabBarItem *tbi = [self tabBarItem];
	
	// give it a label
	[tbi setTitle:@"Store"];
	
	// add an image
	UIImage * i = [UIImage imageNamed:@"tab_mystix.png"];
	[tbi setImage:i];
    
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    
    timestampStixTypes = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    timestampCategories = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(120, 180, 80, 80)];
    [self.view addSubview:activityIndicator];
    
    [activityIndicator startCompleteAnimation];
    [k getAllCategories];
}

-(int)addCategory:(NSString*) categoryName withFilename:(NSString *)filename{
    for (int i=0; i<[categories count]; i++) {
        NSString * currentCategory = [categories objectAtIndex:i];
        if ([currentCategory isEqualToString:categoryName])
            return 0;
    }
    [categories addObject:categoryName];
    [filenames addObject:filename];
    [tables setObject:[NSNull null] forKey:categoryName];
    return 1;
}

-(int)addSubcategory:(NSString*)subcategoryName toCategory:(NSString*)categoryName {
    NSMutableArray * subArray = [subcategories valueForKey:categoryName];
    if (subArray) {
        for (int i=0; i<[subArray count]; i++) {
            NSString * currentSubcategory = [subArray objectAtIndex:i];
            if ([currentSubcategory isEqualToString:subcategoryName])
                return 0;
        }
    }
    else {
        subArray = [[NSMutableArray alloc] init];
    }
    [subArray addObject:subcategoryName];
    [subcategories setObject:subArray forKey:categoryName];
    [tables setObject:[NSNull null] forKey:subcategoryName];
    return 1;
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getAllCategoriesDidCompleteWithResult:(NSArray *)theResults {
    if (coverflowController) {
        [coverflowController.view removeFromSuperview];
        [coverflowController release];
    }
    if (currTableController) // do not release because tables will all get released
        [currTableController.view removeFromSuperview];
    
    if (categories)
        [categories release];
    if (subcategories)
        [subcategories release];
    if (tables)
        [tables release];
    if (filenames)
        [filenames release];
    
    categories = [[NSMutableArray alloc] init];
    subcategories = [[NSMutableDictionary alloc] init];
    tables = [[NSMutableDictionary alloc] init];
    filenames = [[NSMutableArray alloc] init];    
    
    int totalSub = 0;
    int totalCat = 0;
    for (NSMutableDictionary * d in theResults) {
        NSString * categoryName = [d valueForKey:@"categoryName"];
        NSString * subcategoryOf = [d valueForKey:@"subcategoryOf"];
        NSString * filename = [d valueForKey:@"filename"];
        NSDate * timeUpdated = [d valueForKey:@"timeUpdated"];
     
        int ret;
        if ([subcategoryOf length] == 0) {
            ret = [self addCategory:categoryName withFilename:filename];
            totalCat += ret;
        }
        else {
            ret = [self addSubcategory:categoryName toCategory:subcategoryOf];
            totalSub += ret;
        }
        
        if ([timeUpdated compare:timestampCategories] == NSOrderedDescending) {
            timestampCategories = [timeUpdated copy];    
        }
    }
    NSLog(@"Added %d categories and %d subcategories", totalCat, totalSub);  
    NSLog(@"Categories has %d objects", [categories count]);

    // now populate the tables for all categories/subcategories
    for (NSMutableDictionary * d in theResults) {
        NSString * categoryName = [d valueForKey:@"categoryName"];
        if ([tables objectForKey:categoryName] == [NSNull null]) {
            StoreCategoriesController * newTable = [[self populateTableForCategory:categoryName] retain];
            [tables setObject:newTable forKey:categoryName];
        }
    }
    [self populateCoverflow];
    
    [self didSelectCoverAtIndex:0];
    
    [activityIndicator stopCompleteAnimation];
}

-(void)populateCoverflow {
    /***** create coverflow *****/
    coverflowController = [[CoverflowViewController alloc] init];
    coverflowController.delegate = self;
    CGRect coverFrame = CGRectMake(0, 45, 320,150);
    //[self.view insertSubview:coverflowController.view belowSubview:buttonBack];
    [self.view addSubview:coverflowController.view];
    [buttonBack removeFromSuperview];
    [self.view addSubview:buttonBack];
    [coverflowController setCoverflowFrame:coverFrame];    
}

-(IBAction)feedbackButtonClicked:(id)sender {
    [self.delegate didClickFeedbackButton:@"Store view"];
}

/**** coverflow delegate ****/
-(NSMutableArray*) getCoverFilenames {
    return filenames;
}

-(StoreCategoriesController *)populateTableForCategory:(NSString*)category{
    StoreCategoriesController * tableController = [[StoreCategoriesController alloc] init];
    [tableController.view setFrame:CGRectMake(0, 200, 320, 200)];
    [tableController setDelegate:self];
    NSMutableArray * subcategoryList = [subcategories objectForKey:category];
    if (subcategoryList)
        [tableController addSubcategoriesFromArray:subcategoryList];
    NSMutableArray * stixList = [BadgeView getStixForCategory:category];
    [tableController addStixFromArray:stixList];
    return [tableController autorelease];
}

-(void) didSelectCoverAtIndex:(int)index {
    NSString * category = [categories objectAtIndex:index];
    if (currTableController)
        [currTableController.view removeFromSuperview];
    currTableController = [tables objectForKey:category];
    //NSLog(@"Changing to table %x for category %@", currTableController, category);
    [self.view addSubview:currTableController.view];
    //[self.view insertSubview:currTableController.view belowSubview:buttonBack];

    categoryLevel = 0;
    categorySelected = index;
}

-(void)didClickGetStix:(NSString*)stixStringID {
    [self.delegate didClickGetStix:stixStringID];
}

/**** StoreCategories table delegate ****/
-(void) didSelectRow:(int)row {
    int type = [currTableController getTypeForRow:row];
    if (type == CATEGORY_TYPE_SUBCATEGORY) {
        NSString * subcategory = [currTableController getStringForRow:row];
        
        // remove main category table
        //[currTableController.view removeFromSuperview];
        //currTableController = [tables objectForKey:subcategory];
        //[self.view addSubview:currTableController.view];
        StoreCategoriesController * newTableController = [tables objectForKey:subcategory];
        float y = currTableController.view.frame.origin.y;
        float width = currTableController.view.frame.size.width;
        float height = currTableController.view.frame.size.height;
        newTableController.view.frame = CGRectMake(325,y,width,height);
        UIImage * bgimage = [UIImage imageNamed:@"textured_background.png"];
        UIImage * croppedBG = [bgimage croppedImage:CGRectMake(0, y, width, height)];
        UIImageView * bgview = [[UIImageView alloc] initWithImage:croppedBG];
        [bgview setFrame:CGRectMake(325, y, width, height)];
        //[self.view insertSubview:bgview belowSubview:coverflowController.view];
        //[self.view insertSubview:newTableController.view belowSubview:coverflowController.view];
        [self.view addSubview:bgview];
        [self.view addSubview:newTableController.view];
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             newTableController.view.frame = currTableController.view.frame;
                             [bgview setFrame:CGRectMake(0, y, 320, 460)];
                         } 
                         completion:^(BOOL finished){
                             [bgview removeFromSuperview];
                             [bgview release];
                             [currTableController.view removeFromSuperview];
                             currTableController = newTableController;
                         }];  
        categoryLevel = 1;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [k lastUpdatedStixTypesWithTimeUpdated:timestampStixTypes];
    [k lastUpdatedCategoriesWithTimeUpdated:timestampCategories];
}
/*
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation lastUpdatedStixTypesDidCompleteWithResult:(NSArray *)theResults {
    if ([theResults count] == 0)
        return;
    
    [activityIndicator startCompleteAnimation];
    [k getAllCategories];
}
 */
-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation lastUpdatedCategoriesDidCompleteWithResult:(NSArray *)theResults {
    if ([theResults count] == 0)
        return;
    
    [activityIndicator startCompleteAnimation];
    [k getAllCategories];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [activityIndicator release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(int)getStixCount:(NSString *)stixStringID {
    return [self.delegate getStixCount:stixStringID];
}

-(IBAction)didClickBackButton:(id)sender {
    if (categoryLevel == 1) // in subcategory
    {
        [self didSelectCoverAtIndex:categorySelected];
    }
    else {
        // remove modal view of store
    }
}
@end
