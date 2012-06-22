//
//  StixPanelView.m
//  Stixx
//
//  Created by Bobby Ren on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StixPanelView.h"

@implementation StixPanelView

@synthesize stixViews, stixStringIDs, stixCategories, stixDescriptors;
@synthesize delegate, delegatePurchase, underlay;
@synthesize buttonCategories, buttonCategoriesSelected, buttonCategoriesNotSelected;
@synthesize carouselTab;
@synthesize buttonShowCarousel;
@synthesize stixScroll, categoryScroll;
@synthesize dismissedTabY, expandedTabY;

static StixPanelView * sharedStixPanelView;
static NSMutableArray * stixCategoryNames;
static NSMutableArray * premiumCategoryNames;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
        
    /** STATIC - must be first **/
    stixCategoryNames = [NSMutableArray arrayWithObjects:@"facefun", @"memes", @"cute", @"animals", @"comics", @"videogames", nil]; 
    premiumCategoryNames = [NSMutableArray arrayWithObjects:@"hipster", nil];
    
    [self InitializeDefaultStixTypes];
    [self InitializePremiumStixTypes];

    shelfCategory = -1;
    allCarouselStixFrames = [[NSMutableDictionary alloc] initWithCapacity:totalStixTypes];
    allCarouselStixViews = [[NSMutableDictionary alloc] initWithCapacity:totalStixTypes];
    allCarouselStixStringIDsAtFrame = [[NSMutableDictionary alloc] initWithCapacity:totalStixTypes];
    premiumPacksPurchased = [[NSMutableSet alloc] init];
    premiumPurchaseButtons = [[NSMutableDictionary alloc] init];
    
    [self initCarouselWithFrame:CGRectMake(0,SHELF_SCROLL_OFFSET_FROM_TOP,320,SHELF_HEIGHT-SHELF_LOWER_FROM_TOP)];

    return self;
}

+(StixPanelView*)sharedStixPanelView
{
	if (!sharedStixPanelView){
		sharedStixPanelView = [[StixPanelView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	}
	return sharedStixPanelView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)InitializeDefaultStixTypes {
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
    
    NSArray * categoryArrays = stixCategoryNames;
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
        //NSLog(@"Adding %d objects to category %@", [category count], categoryName);
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
    NSLog(@"StixPanelView: Generated %d generic stix!", totalStixTypes);    
}

-(void)InitializePremiumStixTypes {
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
    NSLog(@"StixPanelView: Loaded %d premium stix collections!", [categoryArrays count]);
}

-(void)initCarouselWithFrame:(CGRect)frame{
    scrollFrameRegular = frame;
    scrollFramePremium = frame;
    scrollFramePremium.origin.y += 40;
    scrollFramePremium.size.height -= 30;
    stixScroll = [[UIScrollView alloc] initWithFrame:frame];
    //carouselHeight = stixScroll.frame.size.height;
    stixScroll.showsHorizontalScrollIndicator = NO;
    stixScroll.scrollEnabled = YES;
    stixScroll.directionalLockEnabled = NO; // only allow vertical or horizontal scroll
    [stixScroll setDelegate:self];
    
    buttonShowCarousel = [[UIButton alloc] init];
    [buttonShowCarousel addTarget:self action:@selector(didClickShowCarousel) forControlEvents:UIControlEventTouchUpInside];
    
    buttonCategories = [[NSMutableArray alloc] init];
    buttonCategoriesNotSelected = [[NSMutableArray alloc] initWithObjects:@"txt_facefun.png", @"txt_meme.png", @"txt_cute.png", @"txt_animals.png", @"txt_comics.png", @"txt_videogames.png", @"txt_hipster.png", nil];
    buttonCategoriesSelected = [[NSMutableArray alloc] initWithObjects:@"txt_facefun_selected.png", @"txt_meme_selected.png", @"txt_cute_selected.png", @"txt_animals_selected.png", @"txt_comics_selected.png", @"txt_videogames_selected.png", @"txt_hipster_selected.png", nil];
    float currentContentOrigin = 0;
    for (int i=0; i<[buttonCategoriesSelected count]; i++) {
        UIButton * button0 = [[UIButton alloc] init];
        [button0 setTag:SHELF_CATEGORY_FIRST + i];
        [button0 addTarget:self action:@selector(didClickShelfCategory:) forControlEvents: UIControlEventTouchUpInside];
        int letters = [[buttonCategoriesNotSelected objectAtIndex:i] length] - 8;
        float width = 20 + letters * 12;
        [button0 setFrame:CGRectMake(currentContentOrigin,10,width,50)];
        //[button0 setBackgroundColor:[UIColor greenColor]];
        currentContentOrigin = currentContentOrigin + width+5;
        [buttonCategories addObject:button0];
    }
    
    categoryScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 40, 300, 70)];
    categoryScroll.scrollEnabled = YES;
    categoryScroll.directionalLockEnabled = YES; // only allow horizontal scroll
    [categoryScroll setContentSize:CGSizeMake(currentContentOrigin+20, 70)];
    [categoryScroll setDelegate:self];    
    
    tabImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_open.png"]];
    [tabImage setAlpha:.75];
    carouselTab = [[UIView alloc] initWithFrame:tabImage.frame];
    [carouselTab addSubview:tabImage];
    [carouselTab addSubview:stixScroll];
    [carouselTab addSubview:buttonShowCarousel];
    [carouselTab addSubview:categoryScroll];
    for (int i=0; i<[buttonCategories count]; i++) {
        //[carouselTab addSubview:[buttonCategories objectAtIndex:i]];
        [categoryScroll addSubview:[buttonCategories objectAtIndex:i]];
    }
    [self addSubview:carouselTab];
    [self didClickShelfCategory:[buttonCategories objectAtIndex:SHELF_CATEGORY_FIRST]];
    NSLog(@"current shelf category; %d", shelfCategory);
    
    // for debug
    if (0) {
        [stixScroll setBackgroundColor:[UIColor blackColor]];
        [self setBackgroundColor:[UIColor redColor]];
        [categoryScroll setBackgroundColor:[UIColor blueColor]];
    }
    
    // add gesture recognizer
    UITapGestureRecognizer * myTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [myTapRecognizer setNumberOfTapsRequired:1];
    [myTapRecognizer setNumberOfTouchesRequired:1];
    [myTapRecognizer setDelegate:self];
    [stixScroll addGestureRecognizer:myTapRecognizer];
    //[self reloadAllStix]; // done when clicking on shelf category
}

-(void)didClickShelfCategory:(id)sender {
    UIButton * senderButton = (UIButton *)sender;
    if (senderButton.tag == shelfCategory)
        return;
    
    // remove purchase button if premium
    //NSMutableArray * premiumCategoryNames = [[NSMutableArray alloc] initWithObjects:@"hipster", nil];
    for (NSString * categoryName in premiumCategoryNames) {
        UIButton * button = [premiumPurchaseButtons objectForKey:categoryName];
        if (button) {
            [button removeFromSuperview];
        }
    }
    
    NSLog(@"Button pressed: %d", senderButton.tag);
    for (int i=0; i<[buttonCategories count]; i++) {
        UIButton * button = [buttonCategories objectAtIndex:i];
        if (senderButton.tag == button.tag) {
            [button setImage:[UIImage imageNamed:[buttonCategoriesSelected objectAtIndex:i]] forState:UIControlStateNormal];
            if (shelfCategory != i) {
                // force reload
                shelfCategory = i;
                [allCarouselStixStringIDsAtFrame removeAllObjects];
                [self reloadAllStix];
            }
        }
        else {
            [button setSelected:NO];
            [button setImage:[UIImage imageNamed:[buttonCategoriesNotSelected objectAtIndex:i]] forState:UIControlStateNormal];
        }            
    }
}

-(NSMutableArray *) getStixForCategory:(NSString*)categoryName {
    if (stixCategories) {
        NSMutableArray * stixForCategory = [stixCategories objectForKey:categoryName];
        NSLog(@"Got %d objects for category %@", [stixForCategory count], categoryName);
        return stixForCategory;
    }
    return nil;
}

-(UIImageView *) getStixWithStixStringID:(NSString*)stixStringID {
    // returns a half size image view
    UIImageView * stix = [stixViews objectForKey:stixStringID];
    if (stix == nil) { 
        // return an empty stix view
        stix = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120*.65, 120*.65)];
        [stix setAlpha:0]; // alpha set to 0 as a check for missing stix
        return stix;
    }
    // create smaller size for actual badgeView
    UIImageView * ret = [[UIImageView alloc] initWithImage:[stix image]]; // copy
    CGRect frame = ret.frame;
    // hack: for different resolution badges, start them off at 120x120
    frame.size.width = 120*.65;
    frame.size.height = 120*.65;
    [ret setFrame:frame];    
    return ret;
}

-(NSString*)getStixStringIDAtIndex:(int)index {
    return [stixStringIDs objectAtIndex:index]; 
}

-(void)reloadAllStix {
    [self reloadAllStixWithFrame:scrollFrameRegular]; //stixScroll.frame];
}
-(void)reloadAllStixWithFrame:(CGRect)frame {
    [stixScroll removeFromSuperview];
    stixScroll.frame = frame;
    
    int stixWidth = SHELF_STIX_SIZE + 10;
    int stixHeight = SHELF_STIX_SIZE + 20;
    //    int stixToShow = totalStix;
    //int stixToPurchase = 0; // count the nonordered stix - display backwards
    // create sets of all the categories to see if user has them requested stix
    NSMutableArray * categoryStix;
    NSMutableSet * categorySet = [[NSMutableSet alloc] init];
    NSString * categoryName;
    
    // check for premium category status
    if (shelfCategory < [stixCategoryNames count]) {
        categoryName = [stixCategoryNames objectAtIndex:shelfCategory];
    }
    else {
        categoryName = [premiumCategoryNames objectAtIndex:(shelfCategory - [stixCategoryNames count])];
        if (![premiumPacksPurchased containsObject:categoryName]) {
            // pack not purchased, add button
            if ([premiumPurchaseButtons objectForKey:categoryName] == nil) {
                UIButton * purchaseButton = [[UIButton alloc] initWithFrame:CGRectMake(165-372/4, scrollFramePremium.origin.y - 40, 372/2, 72/2)];
                [purchaseButton setImage:[UIImage imageNamed:@"btn_addcollection@2x.png"] forState:UIControlStateNormal];
                [purchaseButton setTag:shelfCategory];
                //[purchaseButton addTarget:self action:@selector(didClickPurchasePremiumPack:) forControlEvents:UIControlEventTouchUpInside];
                [premiumPurchaseButtons setObject:purchaseButton forKey:categoryName];
            }
            [stixScroll setFrame:scrollFramePremium];
        }
    }
    //NSLog(@"Category name: %@ shelf: %d", categoryName, shelfCategory);
    categoryStix = [self getStixForCategory:categoryName];
    [categorySet addObjectsFromArray:categoryStix];
    int stixToShow = [categorySet count];
    int maxX = STIX_PER_ROW;
    double rows = (double) stixToShow / (double)maxX;
    int maxY = ceil(rows);
    CGSize size = CGSizeMake(stixWidth * maxX, stixHeight * maxY + 20);
    [stixScroll setContentSize:size];
    //NSLog(@"Contentsize; x %d y %d stixToShow %d", maxX, maxY, stixToShow);
    
    int ct_for_category = 0;
    for (int i=0; i<totalStixTypes; i++) {
        NSString * stixStringID = [self getStixStringIDAtIndex:i];
        UIImageView * stix = [allCarouselStixViews objectForKey:stixStringID];
        if (stix) 
            [stix removeFromSuperview];

        if ([categorySet containsObject:stixStringID]) {
            int y = ct_for_category / STIX_PER_ROW;
            int x = ct_for_category - y * STIX_PER_ROW;
            UIImageView * stix = [self getStixWithStixStringID:stixStringID];
            CGPoint stixCenter = CGPointMake(stixWidth*(x+NUM_STIX_FOR_BORDER) + stixWidth / 2, stixHeight*(y+NUM_STIX_FOR_BORDER) + stixHeight/2);
            [stix setCenter:stixCenter];
            [allCarouselStixFrames setObject:[NSValue valueWithCGRect:stix.frame] forKey:stixStringID];
            [allCarouselStixViews setObject:stix forKey:stixStringID];
            [allCarouselStixStringIDsAtFrame setObject:stixStringID forKey:[NSValue valueWithCGRect:stix.frame]];
            [stixScroll addSubview:stix];
            ct_for_category++;
        }
    }
    [carouselTab addSubview:stixScroll];
    
    // pack not purchased, add button
    if (![premiumPacksPurchased containsObject:categoryName])
    {
        NSEnumerator * e = [premiumPurchaseButtons keyEnumerator];
        for (id key in e) {
            UIButton * button = [premiumPurchaseButtons objectForKey:key];
            [button removeFromSuperview];        
        }
        [carouselTab addSubview:[premiumPurchaseButtons objectForKey:categoryName]];
    }
}

-(NSString *) getStixDescriptorForStixStringID:(NSString *)stixStringID {
    return [stixDescriptors objectForKey:stixStringID];
}

-(void)tapGestureHandler:(UITapGestureRecognizer*) sender {
    if (self.hidden)
        return;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // so tap is not continuously sent

        //NSLog(@"Double tap recognized!");
        CGPoint location = [sender locationInView:self.stixScroll];
        NSEnumerator * e = [allCarouselStixStringIDsAtFrame keyEnumerator];
        id key; // key is the frame
        while (key = [e nextObject]) {
            CGRect stixFrame = [key CGRectValue];
            NSString * stixStringID = [allCarouselStixStringIDsAtFrame objectForKey:key];
            if (CGRectContainsPoint(stixFrame, location)) {
                NSLog(@"Stix of type %@ touched", [self getStixDescriptorForStixStringID:stixStringID]);
                UIImageView * stixTouched = [allCarouselStixViews objectForKey:stixStringID];     
                NSLog(@"Stix center %f %f, affine transform %f %f %f %f %f %f", stixTouched.center.x, stixTouched.center.y, stixTouched.transform
                      .a, stixTouched.transform.b, stixTouched.transform.c, stixTouched.transform.d, stixTouched.transform.tx, stixTouched.transform.ty);
                if (![self isPremiumStix:stixStringID] || [self isPremiumStixPurchased:stixStringID])
                    [delegate didTapStixOfType:stixStringID];
                else {
                    // prompt to purchase premium
                    NSString * category = [self getCurrentCategory];
                    NSLog(@"Trying to use %@ in premium category %@. Prompting for purchase", stixStringID, category);
                    [self premiumPurchasePrompt:category usingStixStringID:stixStringID];
                }
                break;
            }
        }
        
        // check for clicking of premium button
        //CGPoint locationRelativeToButton = location;
        //locationRelativeToButton.y += 36; //  button is not located in scrollView
        location = [sender locationInView:carouselTab];
        e = [premiumPurchaseButtons keyEnumerator];
        while (key = [e nextObject])
        {
            UIButton * purchaseButton = [premiumPurchaseButtons objectForKey:key];
            CGRect frame = [purchaseButton frame];
            if (CGRectContainsPoint(frame, location) && purchaseButton.tag == shelfCategory) {
                [self premiumPurchasePrompt:[self getCurrentCategory] usingStixStringID:nil];
                break;
            }
        }
    }
}

-(NSString*)getCurrentCategory {
    NSString * categoryName;
    if (shelfCategory < [stixCategoryNames count]) {
        categoryName = [stixCategoryNames objectAtIndex:shelfCategory];
    }
    else {
        categoryName = [premiumCategoryNames objectAtIndex:(shelfCategory - [stixCategoryNames count])];
    }
    return categoryName;
}

#pragma mark Premium Stix functions

-(void)unlockPremiumPack:(NSString *)stixPackName usingStixStringID:(NSString*)stixStringID {
    
    isPromptingPremiumPurchase = NO;
    if (activityIndicatorLarge) {
        [activityIndicatorLarge stopCompleteAnimation];
        [activityIndicatorLarge removeFromSuperview];
    }
    
#if ADMIN_TESTING_MODE
    return;
#endif
    
    if (stixPackName == nil)
        return; // no purchase/cancel
    
    [premiumPacksPurchased addObject:stixPackName];
    // remove button 
    NSEnumerator * e = [premiumPurchaseButtons keyEnumerator];
    for (id key in e) {
        UIButton * button = [premiumPurchaseButtons objectForKey:key];
        [button removeFromSuperview];        
    }
    [self reloadAllStix];
    
    // in the middle of an actual purchase
    if (stixStringID != nil) {
        [delegate didTapStixOfType:stixStringID];
    }
}

-(void)premiumPurchasePrompt:(NSString*)categoryName usingStixStringID:(NSString*)stixStringID {
    if (isPromptingPremiumPurchase)
        return;
    
    isPromptingPremiumPurchase = YES;
    if (!activityIndicatorLarge)
        activityIndicatorLarge = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(115, 170, 90, 90)];
    [self addSubview:activityIndicatorLarge];
    [activityIndicatorLarge startCompleteAnimation];
    
    [delegatePurchase shouldPurchasePremiumPack:[self getCurrentCategory] usingStixStringID:stixStringID]; 
}

/*
-(void)didClickPurchasePremiumPack:(UIButton*)sender {
    // does not come here because button does not have target
    if (sender.tag != shelfCategory) {
        NSLog(@"Error! current category not the button pressed!");
        return;
    }
    
    NSString * categoryName = [self getCurrentCategory];
    NSLog(@"Did purchase premium pack: %@", categoryName);
    // mkStoreKitSuccess not used; comes here if we clickon the Add Collection button
    // and success/cancel is handled in mkStoreKit call
    BOOL mkStoreKitSuccess = [delegate shouldPurchasePremiumPack:categoryName];
    
    UIButton * button = [premiumPurchaseButtons objectForKey:categoryName];
    if (button) {
        [button removeFromSuperview];
        [premiumPurchaseButtons removeObjectForKey:categoryName];
    }
}
*/
-(BOOL)isPremiumStix:(NSString *) stixStringID {
    NSMutableArray * premiumCategoryNames = [[NSMutableArray alloc] initWithObjects:@"hipster", nil];
    for (NSString * categoryName in premiumCategoryNames) {
        NSMutableArray * categoryStix = [self getStixForCategory:categoryName];
        if ([categoryStix containsObject:stixStringID])
            return YES;
    }
    return NO;
}

-(BOOL)isPremiumStixPurchased:(NSString *)stixStringID {
    NSMutableArray * premiumCategoryNames = [[NSMutableArray alloc] initWithObjects:@"hipster", nil];
    for (NSString * categoryName in premiumCategoryNames) {
        NSMutableArray * categoryStix = [self getStixForCategory:categoryName];
        if ([categoryStix containsObject:stixStringID])
            return [premiumPacksPurchased containsObject:categoryName];
    }
    return NO;
}

/**** Carousel Tab *****/

-(void)carouselTabDismiss:(BOOL)doAnimation {
    CGRect tabFrameHidden = CGRectMake(0, dismissedTabY, 320, 400);
    CGRect tabButtonHidden = CGRectMake(14, 1, 80, 40);
    if (1) {
        [buttonShowCarousel setImage:[UIImage imageNamed:@"tab_open_icon.png"] forState:UIControlStateNormal];
        [buttonShowCarousel setFrame:tabButtonHidden];
        isShowingCarousel = NO;
    }
    if (doAnimation) {
        StixAnimation * animation = [[StixAnimation alloc] init];
        //tabAnimationIDDismiss = [animation doSlide:carouselTab inView:self toFrame:tabFrameHidden forTime:.75];
        [animation doViewTransition:carouselTab toFrame:tabFrameHidden forTime:.35 withCompletion:^(BOOL finished) {
            [tabImage setAlpha:0];        
            [self setAlpha:0];
        }];
    }
    else {
        // use this the first time to dismiss tab without animating it
        [carouselTab setFrame:tabFrameHidden];
        [tabImage setAlpha:0];
        [self setAlpha:0];
    }
}

-(void)carouselTabExpand:(BOOL)doAnimation {
    CGRect tabFrameShow = CGRectMake(0, expandedTabY, 320, 400);
    CGRect tabButtonShow = CGRectMake(14, 1, 80, 40);
    NSLog(@"ExpandedTabY: %d", expandedTabY);
    if (1) {
        [self setAlpha:.9];
        [tabImage setAlpha:.9];
        [buttonShowCarousel setImage:[UIImage imageNamed:@"tab_close_icon.png"] forState:UIControlStateNormal];
        [buttonShowCarousel setFrame:tabButtonShow];
        isShowingCarousel = YES;
    }
    if (doAnimation) {
        StixAnimation * animation = [[StixAnimation alloc] init];
        //tabAnimationIDExpand = [animation doSlide:carouselTab inView:self toFrame:tabFrameShow forTime:.75];
        [animation doViewTransition:carouselTab toFrame:tabFrameShow forTime:.35 withCompletion:^(BOOL finished) {
            [tabImage setAlpha:1];
            [self setAlpha:.9];
        }];
    }
    else {
        [carouselTab setFrame:tabFrameShow];
        [tabImage setAlpha:.9];
        [self setAlpha:1];
    }
}

-(void)didClickShowCarousel {
    NSLog(@"StixPanel showCarousel button clicked!");
    [self carouselTabDismiss:YES];
}

-(void)toggleShowPanel {
//    if ([delegate respondsToSelector:@selector(isDisplayingShareSheet)] && [delegate isDisplayingShareSheet])
//        return;
//    if ([delegate respondsToSelector:@selector(isShowingBuxInstructions)] && [delegate isShowingBuxInstructions])
//        return;
    
    if (isShowingCarousel) {
        [self carouselTabDismiss:YES];
        if ([delegate respondsToSelector:@selector(didDismissCarouselTab)])
            [delegate didDismissCarouselTab];
    }
    else if (!isShowingCarousel) {
        [self carouselTabExpand:YES];
        if ([delegate respondsToSelector:@selector(didExpandCarouselTab)])
            [delegate didExpandCarouselTab];
    }
//#endif
}

#if 1
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // badgeView should only respond to touch events if we are touching the badges. otherwise,
    // foward the event to the underlay of badgeController, which is a sibling/same level view controller
    // that is also a subview of badgeController's superview
    //
    // for example:
    // badgeView
    //   ^                  stixScroll
    //   |                      ^
    //   |                      |
    //    ---- feedView --------
    // this specifically makes badgeView call hitTest on stixScroll; stixScroll must be set
    // as an underlay of badgeController by feedView when the subviews are laid out
    
    UIView * result;
    if (self.underlay) {
        CGPoint newPoint = point;
        newPoint.x -= self.underlay.frame.origin.x;
        newPoint.y -= self.underlay.frame.origin.y;
        result = [self.underlay hitTest:newPoint withEvent:event];
    }
    else 
        result = [super hitTest:point withEvent:event];
    
    CGRect stixScrollFrame = stixScroll.frame;
    CGRect buttonFrame = buttonShowCarousel.frame;
    CGPoint pointInCarouselFrame = point;
    pointInCarouselFrame.y -= carouselTab.frame.origin.y;
    if (CGRectContainsPoint(stixScrollFrame, pointInCarouselFrame))
        return self.stixScroll;
    if (CGRectContainsPoint(buttonFrame, pointInCarouselFrame))
        return self.buttonShowCarousel;
    for (int i=0; i<[buttonCategories count]; i++) {
        CGRect buttonFrame = [[buttonCategories objectAtIndex:i] frame];
        buttonFrame.origin.y += categoryScroll.frame.origin.y;
        buttonFrame.origin.x -= categoryScroll.contentOffset.x;
        if (CGRectContainsPoint(buttonFrame, pointInCarouselFrame))
            return [buttonCategories objectAtIndex:i];
    }
    // catch the rest of the tab so what's behind it doesn't actually get hit
    CGRect tabMainFrame = carouselTab.frame;
    tabMainFrame.origin.y += 40;
    if (CGRectContainsPoint(tabMainFrame, point))
        return self.stixScroll;
    
    // if the touch was not on one of the badges, either return the known underlay or just
    // return self which means the hit is not passed downwards to anything else
    return result;
}
#endif

@end
