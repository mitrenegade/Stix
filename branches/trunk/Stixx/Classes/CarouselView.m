    //
//  CarouselView.m
//

#import "CarouselView.h"

@implementation CarouselView

//@synthesize delegate;
@synthesize stixScroll, categoryScroll;
@synthesize carouselHeight;
@synthesize allowTap;
//@synthesize tapDefaultOffset;
@synthesize buttonShowCarousel, carouselTab, stixSelected;
@synthesize dismissedTabY, expandedTabY;
@synthesize buttonCategories, buttonCategoriesSelected, buttonCategoriesNotSelected;
@synthesize isShowingCarousel;

static CarouselView * sharedCarouselView;
static int carouselRequests = 0;
static dispatch_queue_t backgroundQueue;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];

    shelfCategory = -1;
    int total = [BadgeView totalStixTypes];
    allCarouselStixFrames = [[NSMutableDictionary alloc] initWithCapacity:total];
    allCarouselStixViews = [[NSMutableDictionary alloc] initWithCapacity:total];
    allCarouselStixStringIDsAtFrame = [[NSMutableDictionary alloc] initWithCapacity:total];
    allCarouselMissingStixStringIDs = [[NSMutableSet alloc] initWithCapacity:total];
    allCarouselMissingStixStringOpacity = [[NSMutableDictionary alloc] initWithCapacity:total];
    [self initCarouselWithFrame:CGRectMake(0,SHELF_SCROLL_OFFSET_FROM_TOP,320,SHELF_HEIGHT)];
    k = [[Kumulos alloc] init];
    [k setDelegate:self];
    //backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL);
    backgroundQueue = dispatch_queue_create("com.Neroh.Stix.carouselView.bgQueue", NULL);
    return self;
}

+(CarouselView*)sharedCarouselView
{
	if (!sharedCarouselView){
		sharedCarouselView = [[CarouselView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	}
	return sharedCarouselView;
}

-(void)initCarouselWithFrame:(CGRect)frame{
    stixScroll = [[UIScrollView alloc] initWithFrame:frame];
    carouselHeight = stixScroll.frame.size.height;
    stixScroll.showsHorizontalScrollIndicator = NO;
    stixScroll.scrollEnabled = YES;
    stixScroll.directionalLockEnabled = NO; // only allow vertical or horizontal scroll
    [stixScroll setDelegate:self];
    
    buttonShowCarousel = [[UIButton alloc] init];
    [buttonShowCarousel addTarget:self action:@selector(didClickShowCarousel:) forControlEvents:UIControlEventTouchUpInside];

    buttonCategories = [[NSMutableArray alloc] init];
    buttonCategoriesNotSelected = [[NSMutableArray alloc] initWithObjects:@"txt_facefun.png", @"txt_meme.png", @"txt_cute.png", @"txt_animals.png", @"txt_comics.png", @"txt_videogames.png", nil];
    buttonCategoriesSelected = [[NSMutableArray alloc] initWithObjects:@"txt_facefun_selected.png", @"txt_meme_selected.png", @"txt_cute_selected.png", @"txt_animals_selected.png", @"txt_comics_selected.png", @"txt_videogames_selected.png", nil];
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
                        
    UIImageView * tabImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_open.png"]];    
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
    NSLog(@"current shelf category; %d", shelfCategory);
    [self didClickShelfCategory:[buttonCategories objectAtIndex:SHELF_CATEGORY_FIRST]];

    // for debug
    if (0) {
        [stixScroll setBackgroundColor:[UIColor blackColor]];
        [self setBackgroundColor:[UIColor redColor]];
        [categoryScroll setBackgroundColor:[UIColor blueColor]];
    }
    
    // add gesture recognizer
#if USE_VERTICAL_GESTURE
    UIVerticalGestureRecognizer * myVerticalRecognizer = [[UIVerticalGestureRecognizer alloc] initWithTarget:self action:@selector(verticalGestureHandler:)];
    [myVerticalRecognizer setDelegate:self];
    for (UIGestureRecognizer *gestureRecognizer in stixScroll.gestureRecognizers)
    {
        [gestureRecognizer requireGestureRecognizerToFail:myVerticalRecognizer];
    } 
    [stixScroll addGestureRecognizer:myVerticalRecognizer];
#endif

    UITapGestureRecognizer * myTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    [myTapRecognizer setNumberOfTapsRequired:1];
    [myTapRecognizer setNumberOfTouchesRequired:1];
    [myTapRecognizer setDelegate:self];
    [stixScroll addGestureRecognizer:myTapRecognizer];
    self.allowTap = NO;

    //[self reloadAllStix];
}

-(void)didClickShelfCategory:(id)sender {
    UIButton * senderButton = (UIButton *)sender;
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


-(void)reloadAllStix {
    [self reloadAllStixWithFrame:stixScroll.frame];
}
-(void)reloadAllStixWithFrame:(CGRect)frame {
    /*
    NSMutableArray * stixCategoryNames = [[NSMutableArray alloc] initWithObjects: @"All", @"Animals", @"Anime", @"Art", @"Comics", @"Costumes", @"Cuddly and Cute", @"Decorations", @"Events", @"Face Fun", @"Fashion", @"Food and Drink", @"Geeky", @"Hollywood", @"Nature", @"Pranks", @"Sports", @"Symbols", @"Video Games", nil]; 
     */
    NSMutableArray * stixCategoryNames = [[NSMutableArray alloc] initWithObjects:@"facefun", @"memes", @"cute", @"animals", @"comics", @"videogames", nil]; 
    [stixScroll removeFromSuperview];
    stixScroll.frame = frame;
    
    int stixWidth = SHELF_STIX_SIZE + 10;
    int stixHeight = SHELF_STIX_SIZE + 20;
    int totalStix = [BadgeView totalStixTypes];
//    int stixToShow = totalStix;
    //int stixToPurchase = 0; // count the nonordered stix - display backwards
    // create sets of all the categories to see if user has them requested stix
    NSMutableArray * categoryStix;
    NSMutableSet * categorySet = [[NSMutableSet alloc] init];
    NSString * categoryName = [stixCategoryNames objectAtIndex:shelfCategory];
    categoryStix = [BadgeView getStixForCategory:categoryName];
    [categorySet addObjectsFromArray:categoryStix];
    int stixToShow = [categorySet count];
    int maxX = STIX_PER_ROW;
    double rows = (double) stixToShow / (double)maxX;
    int maxY = ceil(rows);
    CGSize size = CGSizeMake(stixWidth * maxX, stixHeight * maxY + 20);
    [stixScroll setContentSize:size];
    NSLog(@"Contentsize; x %d y %d stixToShow %d", maxX, maxY, stixToShow);
    
    [allCarouselMissingStixStringIDs removeAllObjects];
    [allCarouselMissingStixStringOpacity removeAllObjects];

    int orderCtForFilters = 0;
    for (int i=0; i<totalStix; i++) {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
        //NSLog(@"Removing stixView %@", stixStringID);
        UIImageView * stixView = [allCarouselStixViews objectForKey:stixStringID];
        if (stixView)
            [stixView removeFromSuperview];
        
        int count = [delegate getStixCount:stixStringID];
        int order = 0;
        if ([categorySet containsObject:stixStringID]) {
            order = orderCtForFilters++;
            //NSLog(@"Order for %@: %d", stixStringID, order);
            int y = order / STIX_PER_ROW;
            int x = order - y * STIX_PER_ROW;
            UIImageView * stix = [BadgeView getBadgeWithStixStringID:stixStringID];
            //NSString * stixDescriptor = [BadgeView getStixDescriptorForStixStringID:stixStringID];
            if (stix.alpha == 0) {
                // debug
                if (0) {
                    stix.alpha = 1;
                    float r = order/orderCtForFilters;
                    float g = 0;
                    float b = 1 - r;
                    NSLog(@"CarouselView: Stix %@ order %d needs to be loaded! rgb %f %f %f", stixStringID, order, r, g, b);
                    //[stix setBackgroundColor:[UIColor colorWithRed:r green:g blue:b alpha:1]];
                }
                // add stix to own list
                [allCarouselMissingStixStringIDs addObject:stixStringID];
                [allCarouselMissingStixStringOpacity setObject:[NSNumber numberWithDouble:1] forKey:stixStringID];
                [self requestStixFromKumulos:stixStringID];
            }
            CGPoint stixCenter = CGPointMake(stixWidth*(x+NUM_STIX_FOR_BORDER) + stixWidth / 2, stixHeight*(y+NUM_STIX_FOR_BORDER) + stixHeight/2);
            [stix setCenter:stixCenter];
            [allCarouselStixFrames setObject:[NSValue valueWithCGRect:stix.frame] forKey:stixStringID];
            if (count == 0) {
                //[stix setAlpha:.25];
                UIImageView * buxImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bux_price.png"]];
                CGRect buxFrame = CGRectMake(stixWidth/2-54/2, stix.frame.size.height-10, 54, 20);
                [buxImg setFrame:buxFrame];
                [stix addSubview:buxImg];
                UILabel * buxPrice = [[UILabel alloc] initWithFrame:buxFrame];
                [buxPrice setTextColor:[UIColor blackColor]];
                [buxPrice setBackgroundColor:[UIColor clearColor]];
                [buxPrice setTextAlignment:UITextAlignmentCenter];
                [buxPrice setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
                [buxPrice setText:@"5"];
//                [stix addSubview:buxPrice];
            }
            [stixScroll addSubview:stix];
            [allCarouselStixViews setObject:stix forKey:stixStringID];
            [allCarouselStixStringIDsAtFrame setObject:stixStringID forKey:[NSValue valueWithCGRect:stix.frame]];
        }
        else { //if (shelfCategory == SHELF_CATEGORY_FIRST) {
            /*
            // display nonowned stix, only on this category
            int neworder = (totalStix - stixToPurchase - 1);
            int y = neworder / STIX_PER_ROW;
            int x = neworder - y*STIX_PER_ROW;
            //NSString * stixDescriptor = [BadgeView getStixDescriptorForStixStringID:stixStringID];
            //NSLog(@"Adding nonowned stix %@ = %@ to %d %d index %d, totalStix-stixToPurchase-1 %d", stixStringID, stixDescriptor, x, y, stixToPurchase, neworder);
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            NSString * stixDescriptor = [BadgeView getStixDescriptorForStixStringID:stixStringID];
            if (stix.alpha == 0) {
                // debug
                if (0) {
                    stix.alpha = 1;
                    float r = order/orderCtForFilters;
                    float g = 0;
                    float b = 1 - r;
                    //NSLog(@"CarouselView: Stix %@ order %d needs to be loaded! rgb %f %f %f", stixStringID, order, r, g, b);
                    //[stix setBackgroundColor:[UIColor colorWithRed:r green:g blue:b alpha:1]];
                }
                // add stix to own list
                [allCarouselMissingStixStringIDs addObject:stixStringID];
                [allCarouselMissingStixStringOpacity setObject:[NSNumber numberWithDouble:.5] forKey:stixStringID];
                [self requestStixFromKumulos:stixStringID];
            }
            CGPoint stixCenter = CGPointMake(stixWidth*(x+NUM_STIX_FOR_BORDER) + stixWidth / 2, stixHeight*(y+NUM_STIX_FOR_BORDER) + stixHeight/2);
            [stix setCenter:stixCenter];
            [allCarouselStixFrames setObject:[NSValue valueWithCGRect:stix.frame] forKey:stixStringID];
            [allCarouselStixStringIDsAtFrame setObject:stixStringID forKey:[NSValue valueWithCGRect:stix.frame]];
            [stix setAlpha:.5];
            UIImageView * buxImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"5bux.png"]];
            [buxImg setFrame:CGRectMake(0,stix.frame.size.height+5,stix.frame.size.width, 18)];
            [stix addSubview:buxImg];
            [stixScroll addSubview:stix];
            [allCarouselStixViews setObject:stix forKey:stixStringID];
            [stix release];
            [buxImg release];
            stixToPurchase++;
             */
        }
    }
    [carouselTab addSubview:stixScroll];
}

-(void)clearAllViews {
    NSEnumerator * e = [allCarouselStixViews keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        [[allCarouselStixViews objectForKey:key] removeFromSuperview];
    }
    /*
    for (int i=0; i<[allCarouselStixViews count]; i++)
    {
        if (allCarouselStixViews)
            [[allCarouselStixViews objectAtIndex:i] removeFromSuperview];
    }
     */
    [stixScroll removeFromSuperview];
    [self removeFromSuperview];
}


-(void)resetBadgeLocations{
    // center frame and adjust for size
    NSLog(@"Current shelf category: %d", shelfCategory);
//    NSEnumerator * e = [allCarouselStixViews keyEnumerator];
    NSEnumerator * e = [allCarouselStixStringIDsAtFrame keyEnumerator];
    id key; // the frame
    while (key = [e nextObject]) {
        CGRect frame = [key CGRectValue];
        NSString * stixStringID = [allCarouselStixStringIDsAtFrame objectForKey:key];
        UIImageView * stix = [allCarouselStixViews objectForKey:stixStringID];
        [stix removeFromSuperview];
        
        stix.frame = frame;
        [self.stixScroll addSubview:stix];
    }

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
    //CGRect categoryScrollFrame = categoryScroll.frame;
    CGRect buttonFrame = buttonShowCarousel.frame;
    CGPoint pointInCarouselFrame = point;
    pointInCarouselFrame.y -= carouselTab.frame.origin.y;
    if (CGRectContainsPoint(stixScrollFrame, pointInCarouselFrame))
        return self.stixScroll;
    if (CGRectContainsPoint(buttonFrame, pointInCarouselFrame))
        return self.buttonShowCarousel;
    //if (CGRectContainsPoint(categoryScrollFrame, pointInCarouselFrame))
    //    return self.categoryScroll;
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
/*** scrollview delegate ***/
static int lastContentOffsetX = 0;
static int lastContentOffsetY = 0;
#define DOWN 1
#define UP -1

-(void)scrollViewDidScroll:(UIScrollView *)sv {
    if (lastContentOffsetX == sv.contentOffset.x) {
        if (lastContentOffsetY > sv.contentOffset.y) {
            //NSLog(@"Scrolling down!");
        }
        else if (lastContentOffsetY < sv.contentOffset.y) {
            //NSLog(@"Scrolling up!");
        }
    }
    lastContentOffsetX = sv.contentOffset.x;
    lastContentOffsetY = sv.contentOffset.y;
}

/*** GestureRecognizer action selector ***/
#define NONE 0
#define HORIZONTAL 1
#define VERTICAL 2
-(void)verticalGestureHandler:(UIVerticalGestureRecognizer*)vgr {
    if (self.hidden)
        return;
    
    if ([vgr state] == UIGestureRecognizerStateBegan) {
        // identify which badge it is
        // basically touchesBegan from BadgeView
        CGPoint touch = [vgr firstTouch];
        CGPoint location = touch;
        drag = 0;
        
        if ([self.delegate respondsToSelector:@selector(didStartDrag)]) 
            [self.delegate performSelector:@selector(didStartDrag)];
        
        // find which icon is being dragged
        int totalStixTypes = [BadgeView totalStixTypes];
        for (int i=0; i<totalStixTypes; i++)
        {
            NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
            if ([allCarouselStixViews count] < totalStixTypes)
                continue;
            //if ([allCarouselStixViews objectForKey:stixStringID] == [NSNull null])
              //  continue;
            UIImageView * stix = [allCarouselStixViews objectForKey:stixStringID];
            CGRect frame = stix.frame;
            if (CGRectContainsPoint(frame, touch)) {
                badgeTouched = stix;
                drag = 1;
                badgeSelect = i;
                selectedStixStringID = [BadgeView getStixStringIDAtIndex:badgeSelect];
                break;
            }
        }
        if (drag == 0)
        {
            //NSLog(@"No badge dragged");
            // pass event to nextResponder, which is first the controller, then the view's superview
        }
        else
        {
            // first, move off of scrollview and onto carousel base
            [badgeTouched removeFromSuperview];
            CGRect frameOutsideCarousel = badgeTouched.frame;
            frameOutsideCarousel.origin.x += stixScroll.frame.origin.x - stixScroll.contentOffset.x;
            frameOutsideCarousel.origin.y += stixScroll.frame.origin.y;
            [badgeTouched setFrame:frameOutsideCarousel];
            [self addSubview:badgeTouched];

            badgeLifted = [BadgeView getBadgeWithStixStringID:selectedStixStringID]; 
            float scale =1; // sizeOfStixContext / 300; // if stix context is different from the camera view in TagViewController
            badgeLifted.frame = CGRectMake(0, 0, badgeLifted.frame.size.width*scale, badgeLifted.frame.size.height * scale);
            float centerX = badgeTouched.center.x; 
            float centerY = badgeTouched.center.y; 
            badgeLifted.center = CGPointMake(centerX, centerY);
            // debug
            //badgeTouched.backgroundColor = [UIColor whiteColor];
            
            // point where finger clicked badge
            offset_from_center_X = (location.x - centerX);
            offset_from_center_Y = (location.y - centerY);
            
            CGRect frameEnd = badgeLifted.frame;

            // animate a scaling transition
            [UIView 
             animateWithDuration:0.2
             delay:0 
             options:UIViewAnimationCurveEaseOut
             animations:^{
                 badgeTouched.frame = frameEnd;
             }
             completion:^(BOOL finished){
                 badgeTouched.hidden = NO;
             }
             ];
        }
    }
    else if ([vgr state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = vgr.translation; //[vgr translationInView:[inView superview]];
        NSLog(@"Gesture translation: %f %f\n", translation.x, translation.y);
        if (drag == 1)
        {
            CGPoint location = vgr.currTouch; // location of touch in stixScroll
            
            // update frame of dragged badge, also scale
            if (badgeTouched == nil)
                return;
            float centerX = location.x - offset_from_center_X;// + stixScroll.frame.origin.x;
            float centerY = location.y - offset_from_center_Y;// + stixScroll.frame.origin.y;
            badgeTouched.center = CGPointMake(centerX, centerY);

            NSLog(@"Dragging to %f %f: new center %f %f", location.x, location.y, centerX, centerY);
        }
    }
    else if ([vgr state] == UIGestureRecognizerStateEnded) {
        if (drag == 1)
        {
            if (badgeTouched != nil)
            {
                /*
                CGRect originalFrame = [[allCarouselStixFrames objectAtIndex:badgeSelect] CGRectValue];
                UIImageView * newFrameView = [[UIImageView alloc] initWithFrame:originalFrame];
                newFrameView.center = CGPointMake(badgeTouched.center.x, badgeTouched.center.y);
                CGRect frame = newFrameView.frame;
                [newFrameView release];
                
                //NSLog(@"Badge released with frame origin at %f %f", frame.origin.x, frame.origin.y);
                */
                // animate a scaling transition
#if 0
                [UIView 
                 animateWithDuration:0.2
                 delay:0 
                 options:UIViewAnimationCurveEaseOut
                 animations:^{
                     badgeTouched.frame = frame;
                 }
                 completion:^(BOOL finished){
                     badgeTouched.hidden = NO;
                 }
                 ];
#endif
                
                // tells delegate to do necessary things such as take a photo
                drag = 0;
                if ([self.delegate getStixCount:selectedStixStringID] != 0) {
                    CGRect frame = badgeTouched.frame;
                    CGPoint center = badgeTouched.center;
                    NSLog(@"CarouselView: didDropStix at origin %f %f center %f %f size %f %f in carousel frame %f %f %f %f", frame.origin.x, frame.origin.y, center.x, center.y, frame.size.width, frame.size.height, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                    [self.delegate didDropStix:badgeTouched ofType:selectedStixStringID];
                }
                else
                    [self resetBadgeLocations];
            }
        }   
    }
}

-(void)doubleTapGestureHandler:(UITapGestureRecognizer*) sender {
    if (self.hidden)
        return;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        // so tap is not continuously sent
        if (allowTap) {
            //NSLog(@"Double tap recognized!");
            CGPoint location = [sender locationInView:self.stixScroll];
            NSEnumerator * e = [allCarouselStixStringIDsAtFrame keyEnumerator];
            id key; // key is the frame
            while (key = [e nextObject]) {
                CGRect stixFrame = [key CGRectValue];
                NSString * stixStringID = [allCarouselStixStringIDsAtFrame objectForKey:key];
                if (CGRectContainsPoint(stixFrame, location)) {
                    NSLog(@"Stix of type %@ touched", [BadgeView getStixDescriptorForStixStringID:stixStringID]);
                    UIImageView * stixTouched = [allCarouselStixViews objectForKey:stixStringID];     
                    NSLog(@"Stix center %f %f, affine transform %f %f %f %f %f %f", stixTouched.center.x, stixTouched.center.y, stixTouched.transform
                          .a, stixTouched.transform.b, stixTouched.transform.c, stixTouched.transform.d, stixTouched.transform.tx, stixTouched.transform.ty);
                    //if ([self.delegate getStixCount:stixStringID] != 0) { 
                        //[delegate didTapStix:stixTouched ofType:stixStringID];
                    //}
                    [delegate didTapStixOfType:stixStringID];
                    break;
                }
            }
        }
    }
}


-(void)vibe:(id)sender
{
    // for continuous vibe
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //if (drag==1)
    //    [self performSelector:@selector(vibe:) withObject:self afterDelay:.3f];
}

/**** Carousel Tab *****/

-(void)carouselTabDismiss:(BOOL)doAnimation {
    CGRect tabFrameHidden = CGRectMake(0, dismissedTabY, 320, 400);
    CGRect tabButtonHidden = CGRectMake(14, 1, 80, 40);
    /*
    if (isShowingCarousel == 3) {
        [buttonShowCarousel setCenter:CGPointMake(buttonShowCarousel.center.x, 15)];
        isShowingCarousel = 2;
    }
    else {
     */
    if (1) {
        [buttonShowCarousel setImage:[UIImage imageNamed:@"tab_open_icon.png"] forState:UIControlStateNormal];
        [buttonShowCarousel setFrame:tabButtonHidden];
        isShowingCarousel = NO;
        //[self setStixSelected:nil];
    }
    if (doAnimation) {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        tabAnimationIDDismiss = [animation doSlide:carouselTab inView:self toFrame:tabFrameHidden forTime:.75];
    }
    else {
        // use this the first time to dismiss tab without animating it
        [carouselTab setFrame:tabFrameHidden];
    }
}

-(void)carouselTabExpand:(BOOL)doAnimation {
    CGRect tabFrameShow = CGRectMake(0, expandedTabY, 320, 400);
    CGRect tabButtonShow = CGRectMake(14, 1, 80, 40);
/*
    if (isShowingCarousel == 2) {
        CGPoint imageCenter = CGPointMake(buttonShowCarousel.center.x, 15);
        [buttonShowCarousel setCenter:imageCenter];
        isShowingCarousel = 3;
    }
    else {
*/
    if (1) {
        [buttonShowCarousel setImage:[UIImage imageNamed:@"tab_close_icon.png"] forState:UIControlStateNormal];
        [buttonShowCarousel setFrame:tabButtonShow];
        isShowingCarousel = YES;
        //[self setStixSelected:nil];
    }
    if (doAnimation) {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        tabAnimationIDExpand = [animation doSlide:carouselTab inView:self toFrame:tabFrameShow forTime:.75];
    }
    else {
        [carouselTab setFrame:tabFrameShow];
    }
}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas {
    // do nothing for carousel button
}

-(void)didClickShowCarousel:(id)sender {
#if 0
    if (isShowingCarousel == 1) {
        // dismiss carousel, change tab button, disable stix attachment
        [self carouselTabDismiss:YES];
    }
    else if (isShowingCarousel == 0) {
        // display carousel above tab bar, change tab button to close tab
        [self carouselTabExpand:YES];
    }
    else if (isShowingCarousel == 2) {
        // stix has been chosen, carousel tab is dismissed but should be shown
        [self carouselTabExpand:YES];
    }    
    else if (isShowingCarousel == 3) {
        [self carouselTabDismiss:YES];
    }
#else
    if ([delegate respondsToSelector:@selector(isDisplayingShareSheet)] && [delegate isDisplayingShareSheet])
        return;
    if ([delegate respondsToSelector:@selector(isShowingBuxInstructions)] && [delegate isShowingBuxInstructions])
        return;
    
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
#endif
}

/*** stix requests ***/
-(void)requestStixFromKumulos:(NSString *)stixStringID { // forStix:(UIImageView *)auxStix { // andDelegate:(NSObject<StixViewDelegate> *)_delegate {
    
    [k getStixDataByStixStringIDWithStixStringID:stixStringID];
    
    carouselRequests++;
    NSLog(@"CarouselView: requesting missing stix %@ total requests %d total missing in this tab %d", stixStringID, carouselRequests, [allCarouselMissingStixStringIDs count]);
}

-(void)kumulosAPI:(Kumulos *)kumulos apiOperation:(KSAPIOperation *)operation getStixDataByStixStringIDDidCompleteWithResult:(NSArray *)theResults {
    
    if ([theResults count] == 0) {
        NSLog(@"CarouselView: GetStixDataByStixString returned no stix!");
        return;        
    }
    
    dispatch_async(backgroundQueue, ^(void) {
    
    // populate all stix
    NSMutableDictionary * d = [theResults objectAtIndex:0];
    NSString * stixStringID = [d objectForKey:@"stixStringID"];
    
    //    NSLog(@"CarouselView: GetStixDataByStixString for %@ = %@ returned", descriptor, stixStringID);
    [BadgeView AddStixView:theResults];
    // in case carousel has changed
    NSString * descriptor = [d valueForKey:@"stixDescriptor"];
    if ([allCarouselMissingStixStringIDs containsObject:stixStringID]) {
        
        // remove old, invisible stixView
        UIImageView * stixOld = [allCarouselStixViews objectForKey:stixStringID];
        [stixOld removeFromSuperview];
        UIImageView * stixNew = [BadgeView getBadgeWithStixStringID:stixStringID];
        CGRect frame = [[allCarouselStixFrames objectForKey:stixStringID] CGRectValue];
        double opacity = [[allCarouselMissingStixStringOpacity objectForKey:stixStringID] doubleValue];
        [stixNew setFrame:frame];
        [stixNew setAlpha:opacity];
        [stixScroll addSubview:stixNew];
        [allCarouselStixViews setObject:stixNew forKey:stixStringID];
        [allCarouselMissingStixStringIDs removeObject:stixStringID];
         // MRC
        
        carouselRequests--;
        NSLog(@"Received requested stix %@: carousel Requests left %d missing stix left %d", descriptor, carouselRequests, [allCarouselMissingStixStringIDs count]);
    };
    //[stixView didReceiveRequestedStix:stixStringID withResults:theResults fromStixView:stixViewID];
    [self saveStixDataToDefaultsForStixStringID:stixStringID];
    
    }); // end dispatch
}

-(int)saveStixDataToDefaultsForStixStringID:(NSString*)stixStringID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    UIImageView * stixView = [[BadgeView GetAllStixViewsForSave] objectForKey:stixStringID];
    NSString * stixDescriptor = [[BadgeView GetAllStixDescriptorsForSave] objectForKey:stixStringID];   
    if (!stixView)
        return 0;
    NSData * stixPhoto = UIImagePNGRepresentation([stixView image]);
    [defaults setObject:stixPhoto forKey:stixStringID];
    NSLog(@"Saving stix data to disk for %@", stixDescriptor);
    // defaults synchronize will happen periodically
    return 1;
}
@end
