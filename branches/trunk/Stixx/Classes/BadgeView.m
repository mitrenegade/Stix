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
        UIImageView * badge = [BadgeView getBadgeWithStixStringID:stixStringID];
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

+(void)InitializeStixTypes:(NSArray*)stixStringIDsFromKumulos {
    NSLog(@"**** Initializing Stix Types from Kumulos ****");
    if (stixStringIDs)
    {
        stixStringIDs = nil;
    }
    if (stixCategories)
    {
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
            category = [[NSMutableArray alloc] init];
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
    if (!stixStringIDs) {
        stixStringIDs = [[NSMutableArray alloc] initWithCapacity:[savedStixStringIDs count]];
    }
    if (!stixViews) {
        stixViews = [[NSMutableDictionary alloc] initWithCapacity:[savedStixViews count]];
    }
    if (!stixDescriptors) {
        stixDescriptors = [[NSMutableDictionary alloc] initWithCapacity:[savedStixDescriptors count]];
    }
    if (!stixCategories) {
        stixCategories = [[NSMutableDictionary alloc] initWithCapacity:[savedStixCategories count]];
    }
    if (pool)
    {
        pool = nil;
    }

    [stixStringIDs addObjectsFromArray:savedStixStringIDs];
    [stixViews addEntriesFromDictionary:savedStixViews];
    [stixDescriptors addEntriesFromDictionary:savedStixDescriptors];
    [stixCategories addEntriesFromDictionary:savedStixCategories];
    
    totalStixTypes = [stixStringIDs count];
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
    return stix;
}

+(NSString*)getStixStringIDAtIndex:(int)index {
    return [stixStringIDs objectAtIndex:index]; 
}

+(NSMutableDictionary *)generateDefaultStix {
    NSMutableDictionary * stixCounts = [[NSMutableDictionary alloc] initWithCapacity:[BadgeView totalStixTypes]];
    NSMutableSet * randomBadges = [[NSMutableSet alloc] initWithCapacity:TOTAL_RANDOM_BADGES];
    for (int i=0; i<TOTAL_RANDOM_BADGES; i++) {
        NSString * randomBadge = [BadgeView getRandomStixStringID];
        while ([randomBadges containsObject:randomBadge])
            randomBadge = [BadgeView getRandomStixStringID];
        [randomBadges addObject:randomBadge];
        NSLog(@"Random badge %d: %@", i, [BadgeView getStixDescriptorForStixStringID:randomBadge]);
    }
    //NSString * randomBadge1 = [BadgeView getRandomStixStringID];
    //NSString * randomBadge2 = [BadgeView getRandomStixStringID];
    //NSString * randomBadge3 = [BadgeView getRandomStixStringID];
    //NSLog(@"Generate Default Stix: random free stix %@, %@, %@", randomBadge1, randomBadge2, randomBadge3);

    for (int i=0; i<[BadgeView totalStixTypes]; i++) {
        NSString * stixID = [stixStringIDs objectAtIndex:i];
        int num = 0;
        if ([randomBadges containsObject:stixID])
        {   
            num = -1;
        }
        [stixCounts setObject:[NSNumber numberWithInt:num] forKey:[stixStringIDs objectAtIndex:i]];
    }
    return stixCounts;
}

+(NSMutableDictionary *)generateOneOfEachStix {
    NSMutableDictionary * stixCounts = [[NSMutableDictionary alloc] initWithCapacity:[BadgeView totalStixTypes]];
    for (int i=0; i<2; i++)
        [stixCounts setObject:[NSNumber numberWithInt:-1] forKey:[stixStringIDs objectAtIndex:i]];
    for (int i=2; i<[BadgeView totalStixTypes]; i++)
        [stixCounts setObject:[NSNumber numberWithInt:1] forKey:[stixStringIDs objectAtIndex:i]];
    return stixCounts;
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

- (void)dealloc {
    
    //[shelf release];
    //shelf = nil;
    
    badges = nil;
    badgeLocations = nil;
    //[labels release];
    //labels = nil;
}

#pragma mark InitializeDefaultStixTypes from disk

+(NSMutableDictionary*)InitializeFirstTimeUserStix {
    NSMutableDictionary * stixCounts = [[NSMutableDictionary alloc] initWithCapacity:[BadgeView totalStixTypes]];
    NSArray * categoryArrays = [NSArray arrayWithObjects:@"animals", @"comics", @"cute", @"facefun", @"memes", @"videogames", nil];
    for (int i=0; i<[categoryArrays count]; i++) {
        NSString * categoryName = [categoryArrays objectAtIndex:i];
        NSMutableArray * category = [BadgeView getStixForCategory:categoryName];
        for (int j=0; j<FREE_STIX_PER_CATEGORY; j++) {
            NSString * stixID = [category objectAtIndex:j];
            //NSLog(@"Giving free sticker %d = %@ in category %@", j, stixID, categoryName);
            [stixCounts setObject:[NSNumber numberWithInt:-1] forKey:stixID];
        }
    }
    return stixCounts;
}

+(void)InitializeDefaultStixTypes {
    /* 
     Manually initialize stix string IDs using the actual filenames
     also create categories 
     */
    
    NSArray * animals = [[NSArray alloc] initWithObjects: STIX_ANIMALS, nil]; 
    NSArray * animalsDesc = [[NSArray alloc] initWithObjects: STIX_DESC_ANIMALS, nil];
    NSArray * comics = [[NSArray alloc] initWithObjects: STIX_COMICS, nil];
    NSArray * comicsDesc = [[NSArray alloc] initWithObjects: STIX_DESC_COMICS, nil];
    NSArray * cute = [[NSArray alloc] initWithObjects: STIX_CUTE, nil];
    NSArray * cuteDesc = [[NSArray alloc] initWithObjects: STIX_DESC_CUTE, nil];
    NSArray * facefun = [[NSArray alloc] initWithObjects: STIX_FACEFUN, nil]; 
    NSArray * facefunDesc = [[NSArray alloc] initWithObjects: STIX_DESC_FACEFUN, nil];
    NSArray * memes = [[NSArray alloc] initWithObjects: STIX_MEMES, nil]; 
    NSArray * memesDesc = [[NSArray alloc] initWithObjects: STIX_DESC_MEMES, nil];
    NSArray * videogames = [[NSArray alloc] initWithObjects: STIX_VIDEOGAMES, nil]; 
    NSArray * videogamesDesc = [[NSArray alloc] initWithObjects: STIX_DESC_VIDEOGAMES, nil];
    
    if (!stixStringIDs) {
        stixStringIDs = [[NSMutableArray alloc] init];
    }
    if (!stixCategories) {
        stixCategories = [[NSMutableDictionary alloc] init];
    }
    if (!stixViews) {
        stixViews = [[NSMutableDictionary alloc] init];
    }
    if (!stixDescriptors) {
        stixDescriptors = [[NSMutableDictionary alloc] init];
    }

    NSArray * categoryArrays = [[NSArray alloc] initWithObjects:@"facefun", @"memes",  @"cute", @"animals", @"comics", @"videogames", nil];
    NSArray * filenameArrays = [[NSArray alloc] initWithObjects:facefun, memes, cute, animals, comics, videogames, nil];
    NSArray * descArrays = [[NSArray alloc] initWithObjects:facefunDesc, memesDesc, cuteDesc, animalsDesc, comicsDesc, videogamesDesc, nil];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"stix" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    for (int i=0; i<[categoryArrays count]; i++) {
        NSArray * stixStringArray = [filenameArrays objectAtIndex:i];
        // add filenames as the stixStringIDs
        [stixStringIDs addObjectsFromArray:stixStringArray];
        NSString * categoryName = [categoryArrays objectAtIndex:i];
        NSMutableArray * category = [stixCategories objectForKey:categoryName];
        if (!category) {
            category = [[NSMutableArray alloc] init];
        }
        [category addObjectsFromArray:stixStringArray];
        [stixCategories setObject:category forKey:categoryName];
        NSMutableArray * stixDescArray = [descArrays objectAtIndex:i];
        
        for (NSString * stixStringID in stixStringArray) {
            int index = [stixStringArray indexOfObject:stixStringID];
            NSRange suffix = [stixStringID rangeOfString:@".png"];
            NSString * filename = [stixStringID substringToIndex:suffix.location];
            NSString * descriptor = [stixDescArray objectAtIndex:index]; //[stixStringID substringToIndex:suffix.location];
            [stixDescriptors setValue:descriptor forKey:stixStringID];

            NSString *imageName = [bundle pathForResource:filename ofType:@"png"];
            UIImage *img = [[UIImage alloc] initWithContentsOfFile:imageName];
            UIImageView * stix = [[UIImageView alloc] initWithImage:img];
            [stixViews setObject:stix forKey:stixStringID];
            
        }
    }
    totalStixTypes = [stixStringIDs count];
    NSLog(@"BadgeView: Generated %d generic stix!", totalStixTypes);    
}

+(void)InitializePremiumStixTypes {
    NSArray * hipster = [[NSArray alloc] initWithObjects:@"hipster_bluewovencap.png", @"hipster_bowtie.png", @"hipster_bull_nosering.png", @"hipster_chunkyframe_glasses.png", @"hipster_deep_vneck.png", @"hipster_denim_shorts.png", @"hipster_dotteddress.png", @"hipster_fauxhawk_hairstyle.png", @"hipster_girls_hairstyle.png", @"hipster_ironic_mustache.png", @"hipster_kitty_sticker.png", @"hipster_lomocamera.png", @"hipster_messenger_bag.png", @"hipster_neckscarf.png", @"hipster_oldschoolsneakers.png", @"hipster_oversized_glasses.png", @"hipster_oversized_headphones.png", @"hipster_pinkshutter_glasses.png", @"hipster_plaidshirt.png", @"hipster_ski_vest.png", @"hipster_skinnytie.png", @"hipster_star_tattoo.png", @"hipster_triangle.png", @"hipster_truckerhat.png", @"hipster_tweed_fedora.png", nil];
    NSArray * hipsterDesc = [[NSArray alloc] initWithObjects: @"Blue Woven Cap", @"Plaid Bowtie", @"Bull Nose Ring", @"Chunky Framed Glasses", @"Deep V Neck", @"Denim Shorts", @"Dotted Blue Dress", @"Faux Hawk", @"Hipster Girls Hairstyle", @"Ironic Mustache", @"Hipster Kitty Sticker", @"Lomo Camera", @"Messenger Bag", @"Neck Scarf", @"Vintage Sneakers", @"Oversized Glasses", @"Large Headphones", @"Pink Shutter Glasses", @"Plaid Shirt", @"70's Ski Vest", @"Skinny Tie", @"Star Tattoo", @"Hipster Triangle", @"Trucker Hat", @"Tweed Fedora", nil];

    NSArray * filenameArrays = [[NSArray alloc] initWithObjects:hipster, nil];
    NSArray * categoryArrays = [[NSArray alloc] initWithObjects:@"hipster", nil];
    NSArray * descArrays = [[NSArray alloc] initWithObjects:hipsterDesc, nil];
    for (int i=0; i<[categoryArrays count]; i++) {
        NSString * bundleName = [categoryArrays objectAtIndex:i];
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSArray * stixStringArray = [filenameArrays objectAtIndex:i];
        // add filenames as the stixStringIDs
        [stixStringIDs addObjectsFromArray:stixStringArray];
        NSString * categoryName = bundleName; //[categoryArrays objectAtIndex:i];
        NSMutableArray * category = [stixCategories objectForKey:categoryName];
        if (!category) {
            category = [[NSMutableArray alloc] init];
        }
        [category addObjectsFromArray:stixStringArray];
        [stixCategories setObject:category forKey:categoryName];
        NSMutableArray * stixDescArray = [descArrays objectAtIndex:i];
        
        for (NSString * stixStringID in stixStringArray) {
            int index = [stixStringArray indexOfObject:stixStringID];
            NSRange suffix = [stixStringID rangeOfString:@".png"];
            NSString * filename = [stixStringID substringToIndex:suffix.location];
            NSString * descriptor = [stixDescArray objectAtIndex:index]; //[stixStringID substringToIndex:suffix.location];
            [stixDescriptors setValue:descriptor forKey:stixStringID];
            
            NSString *imageName = [bundle pathForResource:filename ofType:@"png"];
            UIImage *img = [[UIImage alloc] initWithContentsOfFile:imageName];
            UIImageView * stix = [[UIImageView alloc] initWithImage:img];
            [stixViews setObject:stix forKey:stixStringID];
        }
    }
    totalStixTypes = [stixStringIDs count];
    NSLog(@"BadgeView: Loaded %d premium stix collections!", [categoryArrays count]);
}

@end
