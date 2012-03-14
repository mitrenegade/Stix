    //
//  CarouselView.m
//

#import "CarouselView.h"

@implementation CarouselView

//@synthesize delegate;
@synthesize scrollView;
@synthesize carouselHeight;
@synthesize allowTap;
//@synthesize tapDefaultOffset;
@synthesize buttonShowCarousel, carouselTab, stixSelected;
@synthesize dismissedTabY, expandedTabY;
@synthesize buttonCategories, buttonCategoriesSelected, buttonCategoriesNotSelected;
@synthesize isShowingCarousel;

static CarouselView * sharedCarouselView;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];

    int total = [BadgeView totalStixTypes];
    allCarouselStixFrames = [[NSMutableDictionary alloc] initWithCapacity:total];
    allCarouselStixViews = [[NSMutableDictionary alloc] initWithCapacity:total];
    allCarouselStixStringIDsAtFrame = [[NSMutableDictionary alloc] initWithCapacity:total];
    [self initCarouselWithFrame:CGRectMake(0,SHELF_SCROLL_OFFSET_FROM_TOP,320,SHELF_HEIGHT)];
        
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
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    carouselHeight = scrollView.frame.size.height;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.directionalLockEnabled = NO; // only allow vertical or horizontal scroll
    [scrollView setDelegate:self];
    
    buttonShowCarousel = [[UIButton alloc] init];
    [buttonShowCarousel addTarget:self action:@selector(didClickShowCarousel:) forControlEvents:UIControlEventTouchUpInside];

    buttonCategories = [[NSMutableArray alloc] init];
    buttonCategoriesNotSelected = [[NSMutableArray alloc] initWithObjects:@"txt_all.png", @"txt_cute.png", @"txt_facefun.png", nil];
    buttonCategoriesSelected = [[NSMutableArray alloc] initWithObjects:@"txt_all_selected.png", @"txt_cute_selected.png", @"txt_facefun_selected.png", nil];
    for (int i=0; i<[buttonCategoriesSelected count]; i++) {
        UIButton * button0 = [[UIButton alloc] init];
        [button0 setTag:SHELF_CATEGORY_ALL + i];
        [button0 addTarget:self action:@selector(didClickShelfCategory:) forControlEvents: UIControlEventTouchUpInside];
        [button0 setFrame:CGRectMake(20+100*i,50,80,50)];
        [buttonCategories addObject:button0];
        [button0 release];
    }
                        
    UIImageView * tabImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_open.png"]];    
    carouselTab = [[UIView alloc] initWithFrame:tabImage.frame];
    [carouselTab addSubview:tabImage];
    [tabImage release];
    [carouselTab addSubview:scrollView];
    [carouselTab addSubview:buttonShowCarousel];
    for (int i=0; i<[buttonCategories count]; i++) {
        [carouselTab addSubview:[buttonCategories objectAtIndex:i]];
    }
    [self addSubview:carouselTab];
    [self didClickShelfCategory:[buttonCategories objectAtIndex:SHELF_CATEGORY_ALL]];

    // for debug
    if (0) {
        [scrollView setBackgroundColor:[UIColor blackColor]];
        [self setBackgroundColor:[UIColor redColor]];
    }
    
    // add gesture recognizer
#if USE_VERTICAL_GESTURE
    UIVerticalGestureRecognizer * myVerticalRecognizer = [[UIVerticalGestureRecognizer alloc] initWithTarget:self action:@selector(verticalGestureHandler:)];
    [myVerticalRecognizer setDelegate:self];
    for (UIGestureRecognizer *gestureRecognizer in scrollView.gestureRecognizers)
    {
        [gestureRecognizer requireGestureRecognizerToFail:myVerticalRecognizer];
    } 
    [scrollView addGestureRecognizer:myVerticalRecognizer];
#endif

    UITapGestureRecognizer * myTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    [myTapRecognizer setNumberOfTapsRequired:1];
    [myTapRecognizer setNumberOfTouchesRequired:1];
    [myTapRecognizer setDelegate:self];
    [scrollView addGestureRecognizer:myTapRecognizer];
    self.allowTap = NO;

    //[self reloadAllStix];
}

-(void)didClickShelfCategory:(id)sender {
    UIButton * senderButton = (UIButton *)sender;
    NSLog(@"Button pressed: %d", senderButton.tag);
    for (int i=0; i<[buttonCategories count]; i++) {
        UIButton * button = [buttonCategories objectAtIndex:i];
        if (senderButton.tag == button.tag) {
            [button setImage:[UIImage imageNamed:[buttonCategoriesSelected objectAtIndex:i]]  forState:UIControlStateNormal];
            if (shelfCategory != i) {
                // force reload
                shelfCategory = i;
                [allCarouselStixStringIDsAtFrame removeAllObjects];
                [self reloadAllStix];
            }
        }
        else {
            [button setSelected:NO];
            [button setImage:[UIImage imageNamed:[buttonCategoriesNotSelected objectAtIndex:i]]  forState:UIControlStateNormal];
        }            
    }
}


-(void)reloadAllStix {
    [self reloadAllStixWithFrame:scrollView.frame];
}
-(void)reloadAllStixWithFrame:(CGRect)frame {

    [scrollView removeFromSuperview];
    scrollView.frame = frame;
    
    int stixWidth = SHELF_STIX_SIZE + 10;
    int stixHeight = SHELF_STIX_SIZE + 20;
    int totalStix = [BadgeView totalStixTypes];
    int stixToShow = totalStix;
    int stixToPurchase = 0; // count the nonordered stix - display backwards
    // create sets of all the categories to see if user has them requested stix
    NSMutableArray * categoryStix;
    NSMutableSet * categorySet;
    NSMutableArray * subcategories;
    if (shelfCategory == SHELF_CATEGORY_CUTE) {
        categoryStix = [BadgeView getStixForCategory:@"Cuddly and Cute"];
        categorySet = [[NSMutableSet alloc] initWithArray:categoryStix];
        subcategories = [BadgeView getSubcategoriesForCategory:@"Cuddly and Cute"];
        for (int i=0; i<[subcategories count]; i++) {
            NSString * subcategory = [subcategories objectAtIndex:i];
            NSLog(@"Subcategory %d of cuddly and cute: %@",i, subcategory);
            NSMutableArray * stixForSubcategory = [BadgeView getStixForCategory:subcategory];
            [categorySet addObjectsFromArray:stixForSubcategory];
        }
        stixToShow = [categorySet count];
    }
    else if (shelfCategory == SHELF_CATEGORY_FACEFUN) {
        categoryStix = [BadgeView getStixForCategory:@"Face Fun"];
        categorySet = [[NSMutableSet alloc] initWithArray:categoryStix];
        subcategories = [BadgeView getSubcategoriesForCategory:@"Face Fun"];
        for (int i=0; i<[subcategories count]; i++) {
            NSString * subcategory = [subcategories objectAtIndex:i];
            NSLog(@"Subcategory %d of face fun: %@",i, subcategory);
            NSMutableArray * stixForSubcategory = [BadgeView getStixForCategory:subcategory];
            [categorySet addObjectsFromArray:stixForSubcategory];
        }
        stixToShow = [categorySet count];
    }
    int maxX = STIX_PER_ROW;
    double rows = (double) stixToShow / (double)maxX;
    int maxY = ceil(rows);
    CGSize size = CGSizeMake(stixWidth * maxX, stixHeight * maxY);
    [scrollView setContentSize:size];
    NSLog(@"Contentsize; x %d y %d stixToShow %d", maxX, maxY, stixToShow);

    int orderCtForFilters = 0;
    for (int i=0; i<totalStix; i++) {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];    
        if ([allCarouselStixViews objectForKey:stixStringID])
            [[allCarouselStixViews objectForKey:stixStringID] removeFromSuperview];
        
        int count = [self.delegate getStixCount:stixStringID];
        int order = -1;
        if (shelfCategory == SHELF_CATEGORY_ALL) {
            order = [self.delegate getStixOrder:stixStringID];
        }
        else if (shelfCategory == SHELF_CATEGORY_CUTE || shelfCategory == SHELF_CATEGORY_FACEFUN) {
            if ([categorySet containsObject:stixStringID]) {
                order = orderCtForFilters++;
            }
        }
        //NSLog(@"Order for %@: %d", stixStringID, order);
        if (order != -1) {
            int y = order / STIX_PER_ROW;
            int x = order - y * STIX_PER_ROW;
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            CGPoint stixCenter = CGPointMake(stixWidth*(x+NUM_STIX_FOR_BORDER) + stixWidth / 2, stixHeight*(y+NUM_STIX_FOR_BORDER) + stixHeight/2);
            [stix setCenter:stixCenter];
            [allCarouselStixFrames setObject:[NSValue valueWithCGRect:stix.frame] forKey:stixStringID];
            if (count == 0)
                [stix setAlpha:.25];
            [scrollView addSubview:stix];
            [allCarouselStixViews setObject:stix forKey:stixStringID];
            [allCarouselStixStringIDsAtFrame setObject:stixStringID forKey:[NSValue valueWithCGRect:stix.frame]];
            [stix release];
        }
        else if (shelfCategory == SHELF_CATEGORY_ALL) {
            // display nonowned stix, only on this category
            int neworder = (totalStix - stixToPurchase - 1);
            int y = neworder / STIX_PER_ROW;
            int x = neworder - y*STIX_PER_ROW;
            //NSString * stixDescriptor = [BadgeView getStixDescriptorForStixStringID:stixStringID];
            //NSLog(@"Adding nonowned stix %@ = %@ to %d %d index %d, totalStix-stixToPurchase-1 %d", stixStringID, stixDescriptor, x, y, stixToPurchase, neworder);
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            CGPoint stixCenter = CGPointMake(stixWidth*(x+NUM_STIX_FOR_BORDER) + stixWidth / 2, stixHeight*(y+NUM_STIX_FOR_BORDER) + stixHeight/2);
            [stix setCenter:stixCenter];
            [allCarouselStixFrames setObject:[NSValue valueWithCGRect:stix.frame] forKey:stixStringID];
            [allCarouselStixStringIDsAtFrame setObject:stixStringID forKey:[NSValue valueWithCGRect:stix.frame]];
            [stix setAlpha:.5];
            UIImageView * buxImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"5bux.png"]];
            [buxImg setFrame:CGRectMake(0,stix.frame.size.height+5,stix.frame.size.width, 18)];
            [stix addSubview:buxImg];
            [scrollView addSubview:stix];
            [allCarouselStixViews setObject:stix forKey:stixStringID];
            [stix release];
            [buxImg release];
            stixToPurchase++;
        }
    }
    [carouselTab addSubview:scrollView];
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
    [scrollView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)dealloc {

	[super dealloc];
    
    [allCarouselStixFrames release];
    [allCarouselStixViews release];

    [scrollView release];
    scrollView = nil;
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
        [self.scrollView addSubview:stix];
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
    //   ^                  scrollView
    //   |                      ^
    //   |                      |
    //    ---- feedView --------
    // this specifically makes badgeView call hitTest on scrollView; scrollView must be set
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
    
    CGRect scrollViewFrame = scrollView.frame;
    CGRect buttonFrame = buttonShowCarousel.frame;
    CGPoint pointInCarouselFrame = point;
    pointInCarouselFrame.y -= carouselTab.frame.origin.y;
    if (CGRectContainsPoint(scrollViewFrame, pointInCarouselFrame))
        return self.scrollView;
    if (CGRectContainsPoint(buttonFrame, pointInCarouselFrame))
        return self.buttonShowCarousel;
    for (int i=0; i<[buttonCategories count]; i++) {
        if (CGRectContainsPoint([[buttonCategories objectAtIndex:i] frame], pointInCarouselFrame))
            return [buttonCategories objectAtIndex:i];
    }
    // catch the rest of the tab so what's behind it doesn't actually get hit
    CGRect tabMainFrame = carouselTab.frame;
    tabMainFrame.origin.y += 40;
    if (CGRectContainsPoint(tabMainFrame, point))
        return self.scrollView;
    
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
            NSLog(@"Scrolling down!");
        }
        else if (lastContentOffsetY < sv.contentOffset.y) {
            NSLog(@"Scrolling up!");
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
            frameOutsideCarousel.origin.x += scrollView.frame.origin.x - scrollView.contentOffset.x;
            frameOutsideCarousel.origin.y += scrollView.frame.origin.y;
            [badgeTouched setFrame:frameOutsideCarousel];
            [self addSubview:badgeTouched];

            badgeLifted = [[BadgeView getBadgeWithStixStringID:selectedStixStringID] retain]; 
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
            CGPoint location = vgr.currTouch; // location of touch in scrollview
            
            // update frame of dragged badge, also scale
            if (badgeTouched == nil)
                return;
            float centerX = location.x - offset_from_center_X;// + scrollView.frame.origin.x;
            float centerY = location.y - offset_from_center_Y;// + scrollView.frame.origin.y;
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
            CGPoint location = [sender locationInView:self.scrollView];
            NSEnumerator * e = [allCarouselStixStringIDsAtFrame keyEnumerator];
            id key; // key is the frame
            while (key = [e nextObject]) {
                CGRect stixFrame = [key CGRectValue];
                NSString * stixStringID = [allCarouselStixStringIDsAtFrame objectForKey:key];
                if (CGRectContainsPoint(stixFrame, location)) {
                    NSLog(@"Stix of type %@ touched", [BadgeView getStixDescriptorForStixStringID:stixStringID]);
                    UIImageView * stixTouched = [allCarouselStixViews objectForKey:stixStringID];                    

                    //if ([self.delegate getStixCount:stixStringID] != 0) { 
                        [self.delegate didTapStix:stixTouched ofType:stixStringID];
                    //}
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
    if (isShowingCarousel) {
        [self carouselTabDismiss:YES];
    }
    else if (!isShowingCarousel) {
        [self carouselTabExpand:YES];
    }
#endif
}

@end
