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
@synthesize buxBar, buxBarBg, buttonMoreBux, buttonExpressBux;
@synthesize buxCount;

static NSDate * timestampCategories;
static NSDate * timestampStixTypes;

#define BADGE_Store_PADDING 45 // how many pixels per side in Store view

-(id)init
{
    self = [super init];
    timestampStixTypes = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    timestampCategories = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    [k getAllCategories];

    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    lastCategorySelected = 4; // start in middle
    activityIndicator = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(280, 11, 25, 25)];
    [self.view addSubview:activityIndicator];
    
    //[k getAllCategories];
}

-(void) viewDidAppear:(BOOL)animated {
    [buxBarBg setHidden:YES];
    [self.coverflowController setCoverflowIndex:lastCategorySelected];
}

-(void)reloadTableButtons {
    //[k getAllCategories];
    for (int i=0; i<[categories count]; i++) {
        NSString * currentCategory = [categories objectAtIndex:i];
        [self updateTableForCategory:currentCategory];
        NSMutableArray * subArray = [subcategories valueForKey:currentCategory];
        if (subArray) {
            for (int i=0; i<[subArray count]; i++) {
                NSString * currentSubcategory = [subArray objectAtIndex:i];
                [self updateTableForCategory:currentSubcategory];
            }
        }
    }
}

-(int)addCategory:(NSString*) categoryName withCoverImage:(UIImage *)coverImage{
    for (int i=0; i<[categories count]; i++) {
        NSString * currentCategory = [categories objectAtIndex:i];
        if ([currentCategory isEqualToString:categoryName])
            return 0;
    }
    [categories addObject:categoryName];
    [covers addObject:coverImage];
    [tables setObject:[NSNull null] forKey:categoryName];
    return 1;
}

-(int)addSubcategory:(NSString*)subcategoryName toCategory:(NSString*)categoryName {
    NSEnumerator *e = [subcategories keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        NSLog(@"Key: %@", key);
    }
    

    NSMutableArray * subArray = [subcategories valueForKey:categoryName];
    if (subArray) {
        for (int i=0; i<[subArray count]; i++) {
            NSString * currentSubcategory = [subArray objectAtIndex:i];
            if ([currentSubcategory isEqualToString:subcategoryName])
                return 0;
        }
        [subArray addObject:subcategoryName];
        [subcategories setObject:subArray forKey:categoryName];
        [tables setObject:[NSNull null] forKey:subcategoryName];
    }
    else {
        subArray = [[NSMutableArray alloc] init];
        [subArray addObject:subcategoryName];
        [subcategories setObject:subArray forKey:categoryName];
        [tables setObject:[NSNull null] forKey:subcategoryName];
        [subArray release]; // MRC
    }
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
    if (covers)
        [covers release];
    
    categories = [[NSMutableArray alloc] init];
    subcategories = [[NSMutableDictionary alloc] init];
    tables = [[NSMutableDictionary alloc] init];
    covers = [[NSMutableArray alloc] init];    
    
    int totalSub = 0;
    int totalCat = 0;
    for (NSMutableDictionary * d in theResults) {
        NSString * categoryName = [d valueForKey:@"categoryName"];
        NSString * subcategoryOf = [d valueForKey:@"subcategoryOf"];
        NSDate * timeUpdated = [d valueForKey:@"timeUpdated"];
        NSData * coverPNG = [d valueForKey:@"coverPNG"];
        UIImage * coverImage = [[UIImage alloc] initWithData:coverPNG];

        int ret;
        if ([subcategoryOf length] == 0) {
            ret = [self addCategory:categoryName withCoverImage:coverImage];
            totalCat += ret;
        }
        else {
            ret = [self addSubcategory:categoryName toCategory:subcategoryOf];
            totalSub += ret;
        }
        
        if ([timeUpdated compare:timestampCategories] == NSOrderedDescending) {
            timestampCategories = [timeUpdated copy];    
        }
        [coverImage release];
    }
    NSLog(@"Added %d categories and %d subcategories", totalCat, totalSub);  
    NSLog(@"Categories has %d objects", [categories count]);

    // now populate the tables for all categories/subcategories
    for (NSMutableDictionary * d in theResults) {
        NSString * categoryName = [d valueForKey:@"categoryName"];
        if ([tables objectForKey:categoryName] == [NSNull null]) {
            StoreCategoriesController * newTable = [[self populateTableForCategory:categoryName] retain];
            [tables setObject:newTable forKey:categoryName];
            [newTable release]; // MRC
        }
    }
    [self populateCoverflow];
    
    [self.coverflowController setCoverflowIndex:lastCategorySelected];
    
    [activityIndicator stopCompleteAnimation];
}

-(void)populateCoverflow {
    /***** create coverflow *****/
    coverflowController = [[CoverflowViewController alloc] init];
    coverflowController.delegate = self;
    CGRect coverFrame = CGRectMake(0, 45, 320,130);
    //[self.view insertSubview:coverflowController.view belowSubview:buttonBack];
    [self.view addSubview:coverflowController.view];
    [buttonBack removeFromSuperview];
    [self.view addSubview:buttonBack];
    [coverflowController setCoverflowFrame:coverFrame];    
}

-(IBAction)feedbackButtonClicked:(id)sender {
    [self.delegate didClickFeedbackButton:@"Store view"];
}

-(void) redrawBuxBar {
    // draw bux bar above table
    [buxBarBg removeFromSuperview];
    [buxBar removeFromSuperview];
    [buttonExpressBux removeFromSuperview];
    [buttonMoreBux removeFromSuperview];

    [self.view addSubview:buxBarBg];
    [self.view addSubview:buxBar];
    [self.view addSubview:buttonMoreBux];
    [self.view addSubview:buttonExpressBux];
}

/**** coverflow delegate ****/
-(NSMutableArray*) getCovers {
    return covers;
}

-(StoreCategoriesController *)populateTableForCategory:(NSString*)category{
    StoreCategoriesController * tableController = [[StoreCategoriesController alloc] init];
    [tableController.view setFrame:CGRectMake(0, 175, 320, 305)];
    [tableController setDelegate:self];
    NSMutableArray * subcategoryList = [subcategories objectForKey:category];
    if (subcategoryList)
        [tableController addSubcategoriesFromArray:subcategoryList];
    NSMutableArray * stixList = [BadgeView getStixForCategory:category];
    NSMutableArray * hasStix = [[NSMutableArray alloc] initWithCapacity:[stixList count]];
    for (int i=0; i<[stixList count]; i++) {
        if ([self.delegate getStixCount:[stixList objectAtIndex:i]] != -1) {
            [hasStix insertObject:[NSNumber numberWithBool:NO] atIndex:i];
        }
        else {
            [hasStix insertObject:[NSNumber numberWithBool:YES] atIndex:i];
        }
    }
    [tableController addStixFromArray:stixList withHasList:hasStix];
    [hasStix release];
    return [tableController autorelease];
}

-(void)updateTableForCategory:(NSString*)category {
    StoreCategoriesController * tableController = [tables valueForKey:category];
    NSMutableArray * stixList = [BadgeView getStixForCategory:category];
    NSMutableArray * hasStix = [[NSMutableArray alloc] initWithCapacity:[stixList count]];
    //NSLog(@"Updating table for category %@ with %d objects", category, [stixList count]);
    for (int i=0; i<[stixList count]; i++) {
        NSString * stixStringID = [stixList objectAtIndex:i];
        int ct = [self.delegate getStixCount:stixStringID];
        //NSLog(@"Stix %@ count %d", stixStringID, ct);
        if (ct != -1) {
            [hasStix insertObject:[NSNumber numberWithBool:NO] atIndex:i];
        }
        else {
            [hasStix insertObject:[NSNumber numberWithBool:YES] atIndex:i];
        }
    }
    [tableController updateTableButtons:stixList withHasList:hasStix];
    [tableController.view removeFromSuperview];
    [hasStix release];
}

-(void) didSelectCoverAtIndex:(int)index {
    NSString * category = [categories objectAtIndex:index];
    if (currTableController)
        [currTableController.view removeFromSuperview];
    currTableController = [tables objectForKey:category];
    [self.view addSubview:currTableController.view];

    [self redrawBuxBar];
    
    categoryLevel = 0;
    categorySelected = index;
    lastCategorySelected = index;
}

-(void)didClickGetStix:(NSString*)stixStringID withFrame:(CGRect)frame{
    int cost = 5;
    if ([self.delegate getBuxCount] < cost) {
        [self.delegate showNoMoreMoneyMessage];
        return;
    }
    UIImageView * stix = [[BadgeView getLargeBadgeWithStixStringID:stixStringID] retain];
    // ignore frame
    [stix setFrame:frame];
    [stix setCenter:[self.view.superview center]];
    CGRect endFrame = stix.frame;
    endFrame.origin.x -= endFrame.size.width;
    endFrame.origin.y -= endFrame.size.height;
    endFrame.size.width *= 3;
    endFrame.size.height *= 3;
    [self.view addSubview:stix];
    [UIView animateWithDuration:.75
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         [stix setFrame:endFrame];
                         [stix setAlpha:0];
                     } 
                     completion:^(BOOL finished){
                         [stix removeFromSuperview];
                         [stix release];
                         // change + marker to check
                         [self.delegate didGetStixFromStore:stixStringID];                         
                     }];  
    [currTableController didGetStix:stixStringID];
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
        CGRect endFrame = currTableController.view.frame;
        newTableController.view.frame = CGRectMake(325,y,width,height);
        UIImage * bgimage = [UIImage imageNamed:@"textured_background.png"];
        UIImage * croppedBG = [bgimage croppedImage:CGRectMake(0, y, width, height)];
        UIImageView * bgview = [[UIImageView alloc] initWithImage:croppedBG];
        [bgview setFrame:CGRectMake(325, y, width, height)];
        [self.view addSubview:bgview];
        [self.view addSubview:newTableController.view];
        [self redrawBuxBar];
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             newTableController.view.frame = endFrame; //currTableController.view.frame;
                             [bgview setFrame:endFrame];
                         } 
                         completion:^(BOOL finished){
                             [bgview removeFromSuperview];
                             [bgview release];
                             [currTableController.view removeFromSuperview];
                             currTableController = [newTableController retain];
                             [newTableController release];
                         }];  
        categoryLevel = 1;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [k lastUpdatedStixTypesWithTimeUpdated:timestampStixTypes];
    [k lastUpdatedCategoriesWithTimeUpdated:timestampCategories];
    
    [coverflowController setCoverflowIndex:lastCategorySelected];
    [self updateBuxCount];
}

-(void)updateBuxCount {
    int bux = [self.delegate getBuxCount];
    if (bux < 25)
        NSLog(@"Bux getting low!");
    [buxCount setText:[NSString stringWithFormat:@"BUX %d", bux]];
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

-(int)getStixOrder:(NSString*)stixStringID;
{
    return [self.delegate getStixOrder:stixStringID];
}

-(IBAction)didClickBackButton:(id)sender {
    if (categoryLevel == 1) // in subcategory
    {
//        [self didSelectCoverAtIndex:categorySelected];
        NSString * category = [categories objectAtIndex:categorySelected];
        StoreCategoriesController * newTableController = [tables objectForKey:category];
        float y = currTableController.view.frame.origin.y;
        float width = currTableController.view.frame.size.width;
        float height = currTableController.view.frame.size.height;
        CGRect endFrame = CGRectMake(325,y,width,height);
        UIImage * bgimage = [UIImage imageNamed:@"textured_background.png"];
        UIImage * croppedBG = [bgimage croppedImage:CGRectMake(0, y, width, height)];
        UIImageView * bgview = [[UIImageView alloc] initWithImage:croppedBG];
        [bgview setFrame:currTableController.view.frame];
        
        // prepare the animation
        [currTableController.view removeFromSuperview];
        [self.view addSubview:newTableController.view];
        [self.view addSubview:bgview];
        [self.view addSubview:currTableController.view];
        [self redrawBuxBar];
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             currTableController.view.frame = endFrame;
                             [bgview setFrame:endFrame];
                         } 
                         completion:^(BOOL finished){
                             [bgview removeFromSuperview];
                             [bgview release];
                             [currTableController.view removeFromSuperview];
                             currTableController = [newTableController retain];
                             [newTableController release];
                         }];  
        categoryLevel = 0;
    }
    else {
        // remove modal view of store
        [self.delegate didDismissSecondaryView];
    }
}

-(IBAction)didClickMoreBuxButton:(id)sender {
    //[self.delegate didPurchaseBux:0];
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Buy more Bux" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"5 Bux for $0.99", @"15 Bux for $2.99", @"40 Bux for $4.99", @"80 Bux for $8.99", @"170 Bux for $19.99", @"475 Bux for $49.99", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];

}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // button index: 
    // 0 @"5 Bux for $0.99"
    // 1 @"15 Bux for $2.99"
    // 2 @"40 Bux for $4.99"
    // 3 @"80 Bux for $8.99"
    // 4 @"170 Bux for $19.99"
    // 5 @"475 Bux for $49.99"
    // 6 cancel
    int values[6] = {5,15,40,80,170,475};
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        currentBuxPurchase = values[buttonIndex];
        NSString * title = @"Bux Purchase";
        NSString * message = [NSString stringWithFormat:@"Are you sure you want to purchase %d Bux?", currentBuxPurchase];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@"Make Purchase", nil];
        [alert show];
        [alert release];
    }
}

-(IBAction)didClickExpressBuxButton:(id)sender {
//    [self.delegate didPurchaseBux:25];
    currentBuxPurchase = 25;
    NSString * title = @"Bux Purchase";
    NSString * message = [NSString stringWithFormat:@"Are you sure you want to purchase %d Bux?", currentBuxPurchase];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Make Purchase", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Button index: %d", buttonIndex);    
    // 0 = close
    // 1 = view
    
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [self.delegate didPurchaseBux:currentBuxPurchase];
    }
}

@end
