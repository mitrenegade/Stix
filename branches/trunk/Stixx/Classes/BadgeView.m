//
//  BadgeView.m
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "BadgeView.h"

static NSMutableDictionary * stixDescriptors = nil;
static NSMutableArray * stixStringIDs = nil;
static NSMutableDictionary * stixViews = nil;
static NSMutableArray * pool = nil;
static NSMutableDictionary * stixCategories = nil; // key: category name value: array of stixStringIDs
static NSMutableDictionary * stixSubcategories = nil; // key: category name value: array of subcategory names
static int totalStixTypes = 0;

@implementation BadgeView

@synthesize delegate;
@synthesize underlay;
@synthesize showStixCounts;
//@synthesize shelf;
@synthesize selectedStixStringID;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
    if ([BadgeView totalStixTypes] == 0)
        NSLog(@"***** ERROR! BadgeView Stix Types not yet initialized! *****");
  
    //shelf = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shelf.png"]];
    //shelf.frame = CGRectMake(0, 390, 320, 30);
    //[self addSubview:shelf];
    
    showStixCounts = YES;
    
    // Populate all stix structures - used by BadgeView, CarouselView
    badges = [[NSMutableArray alloc] init];
    badgeLocations = [[NSMutableArray alloc] init];
    for (int i=0; i<totalStixTypes; i++)
    {
        NSString * stixStringID = [stixStringIDs objectAtIndex:i];
        UIImageView * badge = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
        [badges addObject:badge];
        [badgeLocations addObject:[NSValue valueWithCGRect:badge.frame]];

        /*
        OutlineLabel * label = [[OutlineLabel alloc] initWithFrame:badge.frame];
        [label setCenter:CGPointMake(badge.center.x+[BadgeView getOutlineOffsetX:i], badge.center.y+[BadgeView getOutlineOffsetY:i])];
        [label setTextAttributesForBadgeType:i];
        [label drawTextInRect:CGRectMake(0,0, badge.frame.size.width, badge.frame.size.height)];
        [labels addObject:label];

        [label release];
         */
        [badge release];
    }
    
 	return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"BadgeView" owner:self options:nil];
    //[self addSubview:self];
}
-(void)resetBadgeLocations {
    for (int i=0; i<totalStixTypes; i++)
    {
        UIImageView * badge = [badges objectAtIndex:i];
        [badge removeFromSuperview];
    }
    int numStix = 2; // badgeView always only shows two stix
    for (int i=0; i<numStix; i++)
    {
        UIImageView * badge = [badges objectAtIndex:i];
        // for views that only show the action stix, just position for two stix
        int y = 375;
        
        if (numStix == 2) {
            badge.center = CGPointMake((320-2*80)/numStix*i + (320-2*80)/numStix/2 + 80, y);
        }
        else if (numStix == 3) {
            badge.center = CGPointMake((320-2*50)/numStix*i + (320-2*50)/numStix/2 + 50, y);
        }    
        else if (numStix == 4) {
            badge.center = CGPointMake((320-2*30)/numStix*i + (320-2*30)/numStix/2 + 30, y);
        }    
        [self addSubview:badge];

        /* no labels for stix on shelf */
        /*
        OutlineLabel * label = [[OutlineLabel alloc] initWithFrame:badge.frame];
        [label setCenter:CGPointMake(badge.center.x+[BadgeView getOutlineOffsetX:i], badge.center.y+[BadgeView getOutlineOffsetY:i])];
        [label setTextAttributesForBadgeType:i];
        [label drawTextInRect:CGRectMake(0,0, badge.frame.size.width, badge.frame.size.height)];
        
        [self addSubview:label];
         */
    }
    drag = 0;
}

+(NSString *) getStixDescriptorForStixStringID:(NSString *)stixStringID {
    return [stixDescriptors objectForKey:stixStringID];
}

+(void)InitializeGenericStixTypes {
    if (!stixStringIDs)
        stixStringIDs = [[NSMutableArray alloc] init];
    if (!stixViews)
        stixViews = [[NSMutableDictionary alloc] init];
    if (!stixDescriptors)
        stixDescriptors = [[NSMutableDictionary alloc] init];
    NSString * stixStringID = @"FIRE";
    NSString * descriptor = @"Fire Stix";
    UIImage * img = [UIImage imageNamed:@"120_fire.png"];
    UIImageView * stix = [[UIImageView alloc] initWithImage:img];
    if (![stixStringIDs containsObject:stixStringID])
        [stixStringIDs addObject:stixStringID];
    //if ([stixViews objectForKey:stixStringID] != nil)
        [stixViews setObject:stix forKey:stixStringID];
    //if ([stixDescriptors objectForKey:stixStringID] != nil)
        [stixDescriptors setObject:descriptor forKey:stixStringID];
    [stix release];
    stixStringID = @"ICE";
    descriptor = @"Ice Stix";
    img = [UIImage imageNamed:@"120_ice.png"];
    stix = [[UIImageView alloc] initWithImage:img];
    if (![stixStringIDs containsObject:stixStringID])
        [stixStringIDs addObject:stixStringID];
    [stixViews setObject:stix forKey:stixStringID];
    [stixDescriptors setObject:descriptor forKey:stixStringID];
    [stix release];
#if TARGET_IPHONE_SIMULATOR
    // debug: add temporary repeat stix to make carousel work
    for (int i=0; i<5; i++) {
        stixStringID = [NSString stringWithFormat:@"ICE%d", i+2];
        descriptor = @"Generic";
        img = [UIImage imageNamed:@"120_ice.png"];
        stix = [[UIImageView alloc] initWithImage:img];
        if (![stixStringIDs containsObject:stixStringID])
            [stixStringIDs addObject:stixStringID];
        [stixViews setObject:stix forKey:stixStringID];
        [stixDescriptors setObject:descriptor forKey:stixStringID];
        [stix release];
    }
#endif
    totalStixTypes = [stixStringIDs count];
}

+(void)InitializeStixTypes:(NSArray*)stixStringIDsFromKumulos {
    NSLog(@"**** Initializing Stix Types from Kumulos ****");
    if (stixStringIDs)
    {
        [stixStringIDs release];
        stixStringIDs = nil;
    }
    if (stixCategories)
    {
        [stixCategories release];
        stixCategories = nil;
    }
    stixStringIDs = [[NSMutableArray alloc] initWithCapacity:[stixStringIDsFromKumulos count]];
    stixCategories = [[NSMutableDictionary alloc] initWithCapacity:[stixStringIDsFromKumulos count]];
    for (NSMutableDictionary * d in stixStringIDsFromKumulos) {
        NSString * stixStringID = [d valueForKey:@"stixStringID"];
        [stixStringIDs addObject:stixStringID];
        NSString * categoryName = [d valueForKey:@"categoryName"];
        NSMutableArray * category = [stixCategories objectForKey:categoryName];
        if (!category) {
            category = [[[NSMutableArray alloc] init] autorelease];
            [stixCategories setObject:category forKey:categoryName];
        }
        [category addObject:stixStringID];

        //NSLog(@"Initializing stix %@ with category %@: total Stix types %d", stixStringID, categoryName, [stixStringIDs count]);
    }
    totalStixTypes = [stixStringIDs count]; //MIN([stixStringIDs count], [stixViews count]);
}

+(void)InitializeStixViews:(NSArray*)stixViewsFromKumulos {
    // initialize all data from kumulos results
    NSLog(@"**** Initializing Stix Views from Kumulos! ****");
    if (!stixViews) {
        stixViews = [[NSMutableDictionary alloc] initWithCapacity:[stixViewsFromKumulos count]];
    }
    if (!stixDescriptors) {
        stixDescriptors = [[NSMutableDictionary alloc] initWithCapacity:[stixViewsFromKumulos count]];
    }
    if (pool)
    {
        [pool release];
        pool = nil;
    }
    // enable stixRepeat to check for repeats
    //NSMutableDictionary * stixRepeat = [[NSMutableDictionary alloc] init];
    //int ct;
    for (NSMutableDictionary * d in stixViewsFromKumulos) {
        NSString * stixStringID = [d valueForKey:@"stixStringID"];
        NSString * descriptor = [d valueForKey:@"stixDescriptor"];
        NSData * dataPNG = [d valueForKey:@"dataPNG"];
        UIImage * img = [[UIImage alloc] initWithData:dataPNG];
        UIImageView * stix = [[UIImageView alloc] initWithImage:img];
        [stixViews setObject:stix forKey:stixStringID];
        [stixDescriptors setObject:descriptor forKey:stixStringID];
        [img release];
        [stix release];
        /*
        if ([stixStringIDs containsObject:stixStringID] == 0)
            NSLog(@"Stix View for %@ downloaded but not in Stix Types!", stixStringID);
        UIImageView * repeated = [stixRepeat objectForKey:stixStringID];
        if (!repeated)
            [stixRepeat setObject:stix forKey:stixStringID];
        else
            NSLog(@"There is a repeat! %@ is already in dictionary!", stixStringID);
         */
        //NSLog(@"Initializing stix view for %@: total Stix types %d", stixStringID, ct++);
    }
//    [stixRepeat release];
}

+(void)InitializeFromDiskWithStixStringIDs:(NSMutableArray*) savedStixStringIDs andStixViews:(NSMutableDictionary *)savedStixViews andStixDescriptors:(NSMutableDictionary *)savedStixDescriptors andStixCategories:(NSMutableDictionary*)savedStixCategories {
    // load from saved data on disk.
    // this should be done first upon loading the app so all stix dictionaries should be reset
    // this saves from having to download the PNG file for each stix, but we should still
    // call InitializeStixTypes to get the current stix types and categories from Kumulos
    if (stixStringIDs) {
        [stixStringIDs release];
        stixStringIDs = nil;
    }
    if (stixViews) {
        [stixViews release];
        stixViews = nil;
    }
    if (stixDescriptors) {
        [stixDescriptors release];
        stixDescriptors = nil;
    }
    if (stixCategories) {
        [stixCategories release];
        stixCategories = nil;
    }
    if (pool)
    {
        [pool release];
        pool = nil;
    }
    stixStringIDs = [[NSMutableArray alloc] initWithCapacity:[savedStixStringIDs count]];
    stixViews = [[NSMutableDictionary alloc] initWithCapacity:[savedStixViews count]];
    stixDescriptors = [[NSMutableDictionary alloc] initWithCapacity:[savedStixDescriptors count]];
    stixCategories = [[NSMutableDictionary alloc] initWithCapacity:[savedStixCategories count]];
    [stixStringIDs addObjectsFromArray:savedStixStringIDs];
    [stixViews addEntriesFromDictionary:savedStixViews];
    [stixDescriptors addEntriesFromDictionary:savedStixDescriptors];
    [stixCategories addEntriesFromDictionary:savedStixCategories];
    
    totalStixTypes = [stixStringIDs count];
}

+(void)InitializeStixSubcategoriesFromKumulos:(NSArray*)theResults {
    // creating list of subcategories
    if (stixSubcategories)
    {
        [stixSubcategories release];
        stixSubcategories = nil;
    }
    stixSubcategories = [[NSMutableDictionary alloc] init];
    for (NSMutableDictionary * d in theResults) {
        NSString * categoryName = [d valueForKey:@"categoryName"];
        NSString * subcategoryOf = [d valueForKey:@"subcategoryOf"];
        if (subcategoryOf != nil) {
            NSMutableArray * supercategory = [stixSubcategories objectForKey:subcategoryOf];
            if (!supercategory) {
                supercategory = [[[NSMutableArray alloc] init] autorelease];
                [stixSubcategories setObject:supercategory forKey:subcategoryOf];
            }
            [supercategory addObject:categoryName];
        }
    }
    //NSLog(@"Subcategories initialized from kumulos: %d", [stixSubcategories count]);
}

+(void)InitializeStixSubcategoriesFromDisk:(NSMutableDictionary *)subcategories {
    if (stixSubcategories) {
        [stixSubcategories release];
        stixSubcategories = nil;
    }
    stixSubcategories = [[NSMutableDictionary alloc] init];
    [stixSubcategories addEntriesFromDictionary:subcategories];
}

+(void)AddStixView:(NSArray*)resultFromKumulos {
    // must initialize first or we will get infinite requests because nothing is there to store them
    if (!stixStringIDs)
        stixStringIDs = [[NSMutableArray alloc] init];
    if (!stixViews)
        stixViews = [[NSMutableDictionary alloc] init];
    if (!stixDescriptors)
        stixDescriptors = [[NSMutableDictionary alloc] init];

    // takes a result from getStixDataForStixStringID
    NSMutableDictionary * d = [resultFromKumulos objectAtIndex:0]; 
    NSString * stixStringID = [d valueForKey:@"stixStringID"];
    NSString * descriptor = [d valueForKey:@"stixDescriptor"];
    NSData * dataPNG = [d valueForKey:@"dataPNG"];
    UIImage * img = [[UIImage alloc] initWithData:dataPNG];
    UIImageView * stix = [[UIImageView alloc] initWithImage:img];
    [stixViews setObject:stix forKey:stixStringID];
    [stixDescriptors setObject:descriptor forKey:stixStringID];
    [img release];
    [stix release];
    //NSLog(@"Adding a new Stix view downloaded from Kumulos: %@ stixStringID %@", descriptor, stixStringID);
}

+(int)totalStixTypes {
    return totalStixTypes;
}

+(NSString*) stringIDOfStix:(int)type {
    if (!stixStringIDs) {
        return nil;
    }
    return [stixStringIDs objectAtIndex:type];
}
+(NSArray*) stixStringIDs {
    return stixStringIDs;
}

+(UIImageView *) getBadgeWithStixStringID:(NSString*)stixStringID {
    // returns a half size image view
    UIImageView * stixView = [stixViews objectForKey:stixStringID];
    if (stixView == nil) { 
        // return an empty stix view
        stixView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120*.65, 120*.65)];
        [stixView setAlpha:0]; // alpha set to 0 as a check for missing stix
        return stixView;
    }
    // create smaller size for actual badgeView
    UIImageView * stix = [[UIImageView alloc] initWithImage:[stixView image]]; // copy
    CGRect frame = stix.frame;
    // hack: for different resolution badges, start them off at 120x120
    frame.size.width = 120*.65;
    frame.size.height = 120*.65;
    [stix setFrame:frame];    
    return [stix autorelease];
}

+(NSString*)getStixStringIDAtIndex:(int)index {
    return [stixStringIDs objectAtIndex:index]; 
}

+(NSMutableDictionary *)generateDefaultStix {
    NSMutableDictionary * stixCounts = [[NSMutableDictionary alloc] initWithCapacity:[BadgeView totalStixTypes]];
    const int TOTAL_RANDOM_BADGES = 48;
    NSMutableSet * randomBadges = [[NSMutableSet alloc] initWithCapacity:TOTAL_RANDOM_BADGES];
    for (int i=0; i<TOTAL_RANDOM_BADGES; i++) {
        NSString * randomBadge = [BadgeView getRandomStixStringID];
        while ([randomBadges containsObject:randomBadge] || [randomBadge isEqualToString:@"FIRE"] || [randomBadge isEqualToString:@"ICE"]) {
            randomBadge = [BadgeView getRandomStixStringID];
        }
        [randomBadges addObject:randomBadge];
        NSLog(@"Random badge %d: %@", i, [BadgeView getStixDescriptorForStixStringID:randomBadge]);
    }
    //NSString * randomBadge1 = [BadgeView getRandomStixStringID];
    //NSString * randomBadge2 = [BadgeView getRandomStixStringID];
    //NSString * randomBadge3 = [BadgeView getRandomStixStringID];
    //NSLog(@"Generate Default Stix: random free stix %@, %@, %@", randomBadge1, randomBadge2, randomBadge3);

    for (int i=2; i<[BadgeView totalStixTypes]; i++) {
        NSString * stixID = [stixStringIDs objectAtIndex:i];
        int num = 0;
        if ([stixID isEqualToString:@"FIRE"] || [stixID isEqualToString:@"ICE"])
            num = -1;
        if ([randomBadges containsObject:stixID])
        {   
            NSLog(@"Setting stix %d: %@ %@ to 3", i, stixID, [BadgeView getStixDescriptorForStixStringID:stixID]);
            num = 3;
        }
        [stixCounts setObject:[NSNumber numberWithInt:num] forKey:[stixStringIDs objectAtIndex:i]];
    }
    return [stixCounts autorelease];
}

+(NSMutableDictionary *)generateOneOfEachStix {
    NSMutableDictionary * stixCounts = [[NSMutableDictionary alloc] initWithCapacity:[BadgeView totalStixTypes]];
    for (int i=0; i<2; i++)
        [stixCounts setObject:[NSNumber numberWithInt:-1] forKey:[stixStringIDs objectAtIndex:i]];
    for (int i=2; i<[BadgeView totalStixTypes]; i++)
        [stixCounts setObject:[NSNumber numberWithInt:1] forKey:[stixStringIDs objectAtIndex:i]];
    return [stixCounts autorelease];
}

+(NSString*)getRandomStixStringID {
    if (pool == nil) {
        // accumulate all likelihoods
        pool = [[NSMutableArray alloc] init];
        for (int i=0; i<[self totalStixTypes]; i++) {
            NSString * stixStringID = [self getStixStringIDAtIndex:i];
            int likelihood = 1; //
            for (int j=0; j<likelihood; j++) {
                [pool addObject:stixStringID];
            }
        }
    }
    
    int total = [pool count];
    NSInteger num = arc4random() % total;
    NSLog(@"Random stix string id: choosing from 0 to %d: result %d\n", total-1, num);
    return [pool objectAtIndex:num];
}

+(int)getOutlineOffsetX:(int)type {

    //const int xoffset[BADGE_TYPE_MAX] = {-5, -5, -2, -5};
    return -3; //xoffset[type];
}
+(int)getOutlineOffsetY:(int)type {
    
    //const int yoffset[BADGE_TYPE_MAX] = {10, 10, 2, 10};
    return 9; //yoffset[type];
}

+(NSMutableArray *) getStixForCategory:(NSString*)categoryName {
    if (stixCategories) {
        NSMutableArray * stixForCategory = [stixCategories objectForKey:categoryName];
        return stixForCategory;
    }
    return nil;
}
+(NSMutableArray *) getSubcategoriesForCategory:(NSString*)categoryName {
    if (stixSubcategories) {
        NSMutableArray * subcategories = [stixSubcategories objectForKey:categoryName];
        return subcategories;
    }
    return nil;
}

+(NSMutableArray *)GetAllStixStringIDsForSave {
    // for saving to disk
    return stixStringIDs;
}
+(NSMutableDictionary *)GetAllStixCategoriesForSave {
    // for saving to disk
    return stixCategories;
}
+(NSMutableDictionary *)GetAllStixViewsForSave {
    // for saving to disk
    return stixViews;
}
+(NSMutableDictionary *)GetAllStixDescriptorsForSave {
    // for saving to disk
    return stixDescriptors;
}
+(NSMutableDictionary *)GetAllStixSubcategoriesForSave {
    // for saving to disk
    return stixSubcategories;
}

- (void)dealloc {
	[super dealloc];
    
    //[shelf release];
    //shelf = nil;
    
    [badges release];
    badges = nil;
    [badgeLocations release];
    badgeLocations = nil;
    //[labels release];
    //labels = nil;
}

@end
