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
        [pool release];
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
        return [stixView autorelease];
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
    return [stixCounts autorelease];
}

+(void)InitializeDefaultStixTypes {
    /* 
     Manually initialize stix string IDs using the actual filenames
     also create categories 
     */
    
    NSArray * animals = [[NSArray alloc] initWithObjects:
    @"babychick.png",
    @"baldeagle.png",
    @"bluecrab.png",
    @"brownbunny.png",
    @"butterfly2.png",
    @"butterfly3.png",
    @"capuchin.png",
    @"cat.png",
    @"cheladamonkeyface.png",
    @"chipmunk.png",
    @"dog_cleo.png",
    @"duck.png",
    @"fatlizard.png",
    @"fly.png",
    @"frog.png",
    @"frog2.png",
    @"giraffehead.png",
    @"goldfish.png",
    @"judgementalcat.png",
    @"kitten.png",
    @"kittenface.png",
    @"lazydog.png",
    @"lemurhead.png",
    @"lion.png",
    @"lioness.png",
    @"mallard.png",
    @"meerkat.png",
    @"monkeyface.png",
    @"monkeyface2.png",
    @"ostrichhead.png",
    @"owl.png",
    @"parrothead.png",
    @"peacock.png",
    @"penguin.png",
    @"redcardinal.png",
    @"rhino.png",
    @"shybear.png",
    @"sittingmonkey.png",
    @"snowowl.png",
    @"spider.png",
    @"spottedbunny.png",
    @"squirrel1.png",
    @"squirrel2.png",
    @"squirrel3.png",
    @"swan.png",
    @"zebra.png",
    nil];
    NSArray * animalsDesc = [[NSArray alloc] initWithObjects:
                             @"Baby Chick",
                             @"Bald Eagle",
                             @"Blue Crab",
                             @"Brown Bunny",
                             @"Butterfly",
                             @"Butterfly",
                             @"Capuchin",
                             @"Cat",
                             @"Chelada Monkeyface",
                             @"Chipmunk",
                             @"Golden Retriever",
                             @"Duck",
                             @"Fat Lizard",
                             @"Fly",
                             @"Frog",
                             @"Frog",
                             @"Giraffe Head",
                             @"Gold Fish",
                             @"Judgmental Cat",
                             @"Kitten",
                             @"Kitty Face",
                             @"Lazy Dog",
                             @"Lemur Head",
                             @"Lion",
                             @"Lioness",
                             @"Mallard",
                             @"Meerkat",
                             @"Monkey Face",
                             @"Monkey Face",
                             @"Ostrich Head",
                             @"Owl",
                             @"Parrot Head",
                             @"Peacock",
                             @"Penguin",
                             @"Red Cardinal",
                             @"Rhino",
                             @"Shy Bear",
                             @"Sitting Monkey",
                             @"Snow Owl",
                             @"Spider",
                             @"Spotted Bunny",
                             @"Squirrel",
                             @"Squirrel",
                             @"Squirrel",
                             @"Swan",
                             @"Zebra",
                             nil];
    
    NSArray * comics = [[NSArray alloc] initWithObjects:
    @"ant.png",
    @"bomb.png",
    @"bone.png",
    @"bonk.png",
    @"brownanimeeyes.png",
    @"cartoonfly.png",
    @"chickenhero.png",
    @"chimpzilla.png",
    @"dynamite.png",
    @"evilrobot.png",
    @"exclamation.png",
    @"greenspaceman.png",
    @"hal.png",
    @"handgun.png",
    @"kaboom.png",
    @"kapow.png",
    @"lasergun.png",
    @"lightning.png",
    @"lightsword.png",
    @"longsword.png",
    @"milesanders_hook.png",
    @"milesanders_horns.png",
    @"milesanders_lobsterclaw.png",
    @"ninja2.png",
    @"ninjastar.png",
    @"pinkskull.png",
    @"plop.png",
    @"poof.png",
    @"pop.png",
    @"pow.png",
    @"question.png",
    @"rocket.png",
    @"shortsword.png",
    @"smack.png",
    @"speechbubble.png",
    @"stickfigure.png",
    @"thought_bubble.png",
    @"thud.png",
    @"thudd.png",
    @"zombiehead.png",
                        nil];
    NSArray * comicsDesc = [[NSArray alloc] initWithObjects:
                            @"Ant",
                            @"Bomb",
                            @"Bone",
                            @"Bonk",
                            @"Brown Anime Eyes",
                            @"Cartoon Fly",
                            @"Chicken Hero",
                            @"Chimpzilla",
                            @"Dynamite",
                            @"Evil Robot",
                            @"Exclamation",
                            @"Green Space Guy",
                            @"Hal", 
                            @"Handgun",
                            @"Kaboom",
                            @"Kapow",
                            @"Laser Gun",
                            @"Lightening",
                            @"Light Sword",
                            @"Long Sword",
                            @"Pirate Hook",
                            @"Devil Horns",
                            @"Lobster Claw",
                            @"Ninja",
                            @"Ninja Star",
                            @"Pink Skull",
                            @"Plop",
                            @"Poof",
                            @"Pop",
                            @"Pow",
                            @"Question Mark",
                            @"Rocket",
                            @"Short Sword",
                            @"Smack",
                            @"Speech Bubble",
                            @"Stick Figure",
                            @"Thought Bubble",
                            @"Thud",
                            @"Thudd",
                            @"Zombie Head",
                            nil];
    
    NSArray * cute = [[NSArray alloc] initWithObjects:
    @"abstractbubbles.png",
    @"abstractsun.png",
    @"babychick2.png",
    @"babypenguin.png",
    @"bemine.png",
    @"blue_splash.png",
    @"blueflower.png",
    @"bluepenguin.png",
    @"bunchofstars.png",
    @"cartoonpig.png",
    @"cheekymonkey.png",
    @"cherryblossomrabbits.png",
    @"flowerpower.png",
    @"giraffe.png",
    @"green_splash.png",
    @"happylemon.png",
    @"hearts1.png",
    @"heartsplenty.png",
    @"hippo.png",
    @"inksplash.png",
    @"ladybug.png",
    @"littlebear.png",
    @"milesanders_bird.png",
    @"milesanders_cat.png",
    @"milesanders_crab.png",
    @"milesanders_dog.png",
    @"milesanders_fish.png",
    @"milesanders_flower.png",
    @"milesanders_owl.png",
    @"milesanders_parrot.png",
    @"mole.png",
    @"musicnote.png",
    @"panda.png",
    @"panda2.png",
    @"panda3.png",
    @"pawprint.png",
    @"pink_splash.png",
    @"pinkballoon.png",
    @"pinkdolphin.png",
    @"pinkflower.png",
    @"pinkstar.png",
    @"purplebutterfly.png",
    @"rainbow.png",
    @"rainbow2.png",
    @"realteddybear.png",
    @"red_glowing_heart.png",
    @"redrose.png",
    @"smallwhale.png",
    @"snowflake.png",
    @"starexplode.png",
    @"swirlyribbons.png",
    @"teddy.png",
    @"teddyface.png",
    @"tulip.png",
    @"wackybear.png",
    @"yellowflowserborder.png",
                        nil];
    NSArray * cuteDesc = [[NSArray alloc] initWithObjects:
                          @"Abstract Bubbles",
                          @"Abstract Sun",
                          @"Baby Chick",
                          @"Baby Penguin",
                          @"Be Mine",
                          @"Blue Splash",
                          @"Blue Flower",
                          @"Blue Penguin",
                          @"Bunch of Stars",
                          @"Cartoon Pig",
                          @"Cheeky Monkey",
                          @"Cherry Blossom Rabbits",
                          @"Flower Power",
                          @"Giraffe",
                          @"Green Splash",
                          @"Happy Lemon",
                          @"Hearts",
                          @"Plenty of Hearts",
                          @"Hippo",
                          @"Ink Splash",
                          @"Lady Bug",
                          @"Little Bear",
                          @"Green Bird",
                          @"Purple Cat",
                          @"Crab",
                          @"Dog",
                          @"Fish",
                          @"Flower",
                          @"Owl",
                          @"Parrot",
                          @"Mole",
                          @"Music Note",
                          @"Panda",
                          @"Panda",
                          @"Panda",
                          @"Paw Prints",
                          @"Pink Splash",
                          @"Pink Balloon",
                          @"Pink Dolphin",
                          @"Pink Flower",
                          @"Pink Star",
                          @"Purple Butterfly",
                          @"Rainbow",
                          @"Rainbow", 
                          @"Teddy Bear",
                          @"Red Glowing Heart",
                          @"Red Rose",
                          @"Small Whale",
                          @"Snow Flake",
                          @"Star Explosion",
                          @"Swirly Ribbons",
                          @"Teddy",
                          @"Teddy Face",
                          @"Tulip",
                          @"Wacky Bear",
                          @"Yellow Flowers Border",
                          nil];
    
    NSArray * facefun = [[NSArray alloc] initWithObjects:

    @"bandaid.png",
    @"beard_scruffy.png",
    @"blooddrip.png",
    @"crown.png",
    @"drop.png",
    @"eye_scary.png",
    @"eyepatch.png",
    @"eyes_bulging.png",
    @"eyes_creepycat.png",
    @"eyes_crossed.png",
    @"eyes_puppy.png",
    @"furryears.png",
    @"glasses_3d_glasses.png",
    @"glasses_aviatorglasses.png",
    @"glasses_catglasses.png",
    @"hair_afro.png",
    @"hair_blondshort.png",
    @"hair_blondwithbangs.png",
    @"hair_brownbangs.png",
    @"hair_brownlong.png",
    @"hair_celebrityboy.png",
    @"hair_curlylongblond.png",
    @"hair_dreadlocks.png",
    @"hair_eurostyle.png",
    @"hair_platinumblond.png",
    @"hair_redshorthair.png",
    @"hair_shortblondcosplayhair.png",
    @"hair_shortblondguy.png",
    @"hair_shortblue.png",
    @"hair_spikyblondcosplay.png",
    @"hat_browncap.png",
    @"hat_brownstripedcap.png",
    @"hat_fedora.png",
    @"hat_tophat.png",
    @"hockeymask.png",
    @"kiss.png",
    @"mouth_buckteeth.png",
    @"mouth_toothy.png",
    @"mouth_toothy2.png",
    @"mouth_uglyteeth.png",
    @"mouth_vampirefangs.png",
    @"nerdytie.png",
    @"openmouth.png",
    @"partyhat.png",
    @"polarbearhat.png",
    @"stache_bushy.png",
    @"stache_rich.png",
    @"surprised_eyes.png",
                        nil];
    
    NSArray * facefunDesc = [[NSArray alloc] initWithObjects:@"Band Aid", @"Scruffy Beard", @"Blood Drip", @"Crown", @"Tear Drop", @"Scary Eye", @"Eye Patch", @"Bulging Eyes", @"Creepy Cat Eyes", @"Crossed Eyes", @"Puppy Eyes", @"Furry Ears", @"3D Glasses", @"Aviator Glasses", @"Cat Glasses", @"Afro", @"Short Blond Hair", @"Blond Hair with Bangs", @"Brown Hair with Bangs", @"Long Brown Hair", @"Celebrity Boy Hair", @"Curly Long Blond Hair", @"Dreadlocks", @"Euro Style Hair", @"Plantinum Blond Hair", @"Red Short Hair", @"Short Blond Cosplay Hair", @"Short Blond Guy's Hair", @"Short Blue Hair", @"Spikey Hair", @"Brown Cap", @"Brown Striped Hat", @"Fedora", @"Top Hat", @"Hockey Mask", @"Kiss", @"Buck Teeth", @"Toothy Mouth", @"Toothy Smile", @"Ugly Teeth", @"Vampire Fangs", @"Nerdy Tie", @"Open Mouth", @"Party Hat", @"Polar Bear Hat", @"Bushy Mushtache", @"Rich Mustache", @"Surprised Eyes", nil];
    
    NSArray * memes = [[NSArray alloc] initWithObjects:

    @"areyouseriousface.png",
    @"censored.png",
    @"chubbybaby.png",
    @"derp.png",
    @"derpeyes.png",
    @"fail.png",
    @"foreveralone.png",
    @"ftw.png",
    @"guy_fawkes.png",
    @"happycutenessoverload.png",
    @"happysmileyface.png",
    @"lol.png",
    @"lolface.png",
    @"megusta.png",
    @"noface.png",
    @"okayguy.png",
    @"omg.png",
    @"pleaseface.png",
    @"pokerface.png",
    @"rawchicken.png",
    @"skepticalbaby.png",
    @"sleepingbabyface.png",
    @"successkid.png",
    @"trollface.png",
    @"woodface.png",
    @"yolo.png",
    @"yunoguy.png",
                      nil];
    
    NSArray * memesDesc = [[NSArray alloc] initWithObjects: @"Are You Serous", @"Censored Bar", @"Chubby Baby", @"DERP ", @"DERP eyes", @"FAIL", @"Forever Alone", @"FTW", @"Guy Fawkes Mask", @"Happy Cuteness Overload", @"Happy Smiley Face", @"LOL ", @"LOL Face", @"Me Gusta", @"No Face", @"Okay Guy", @"OMG", @"Please ", @"Poker Face", @"Raw Chicken", @"Skeptical Baby", @"Sleeping Baby Face", @"Success Kid", @"Troll Face", @"Wood Face", @"YOLO", @"Y U NO", nil];
    
    NSArray * videogames = [[NSArray alloc] initWithObjects:

    @"cubeangry.png",
    @"cubecool.png",
    @"cubekiss.png",
    @"cubeshocked.png",
    @"cubesick.png",
    @"cubesilly.png",
    @"cubesmile.png",
    @"cubewink.png",
    @"game_coin.png",
    @"game_shroom.png",
    @"gamecontroller.png",
    @"gameinvader.png",
    @"gametower.png",
    @"handcursor.png",
    @"isobuilding.png",
    @"mariostar.png",
    @"minecraft.png",
    @"pacmangreen.png",
    @"pirates_chest.png",
    @"pressbutton.png",
    @"redfireball.png",
    @"robohead.png",
    @"tallisotower.png",
    @"tetris1.png",
    @"tetris2.png",
    @"tetris3.png",
    @"videogame_pipe.png",
                        nil];
    
    NSArray * videogamesDesc = [[NSArray alloc] initWithObjects:@"Angry Cube", @"Cool Cube", @"Kissy Cube", @"Shocked Cube", @"Sick Cube", @"Silly Cube", @"Smiley Cube", @"Wink Cube", @"Game Coin", @"Game Shroom", @"Game Controller", @"Game Invader", @"Game Tower", @"Hand Cursor", @"Isometric Building", @"Game Star", @"Mine Cube", @"Green Ghost", @"Pirates Chest", @"Press Button", @"Red Fireball", @"Robo Head", @"Tall Isometric Tower", @"Puzzle Game Piece", @"Puzzle Game Piece", @"Puzzle Game Piece", @"Game Pipe", nil];
    
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

    NSArray * filenameArrays = [[NSArray alloc] initWithObjects:animals, comics, cute, facefun, memes, videogames, nil];
    NSArray * categoryArrays = [[NSArray alloc] initWithObjects:@"animals", @"comics", @"cute", @"facefun", @"memes", @"videogames", nil];
    NSArray * descArrays = [[NSArray alloc] initWithObjects:animalsDesc, comicsDesc, cuteDesc, facefunDesc, memesDesc, videogamesDesc, nil];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"stix" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    for (int i=0; i<[filenameArrays count]; i++) {
        NSArray * stixStringArray = [filenameArrays objectAtIndex:i];
        // add filenames as the stixStringIDs
        [stixStringIDs addObjectsFromArray:stixStringArray];
        NSString * categoryName = [categoryArrays objectAtIndex:i];
        NSMutableArray * category = [stixCategories objectForKey:categoryName];
        if (!category) {
            category = [[[NSMutableArray alloc] init] autorelease];
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
            
            [img release];
            [stix release];
        }
    }
    totalStixTypes = [stixStringIDs count];
    NSLog(@"BadgeView: Generated %d generic stix!", totalStixTypes);
    
    // MRC
    [animals release];
    [comics release];
    [cute release];
    [facefun release];
    [memes release];
    [videogames release];
    [filenameArrays release];
    [categoryArrays release];
}

@end
