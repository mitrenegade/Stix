//
//  CarouselView.m
//

#import "CarouselView.h"

@implementation CarouselView

//@synthesize delegate;
@synthesize scrollView;
@synthesize carouselHeight;
@synthesize showGiftStix;
@synthesize sizeOfStixContext;
@synthesize allowTap;
@synthesize tapDefaultOffset;
@synthesize buttonShowCarousel, carouselTab, stixSelected;
@synthesize dismissedTabY, expandedTabY;
@synthesize scrollOffsetFromTabTop;
@synthesize buttonStixCategories;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];

#if 0
    // background image
    UIImageView * bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"load_bkg.png"]];
    [bg setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:bg];
    [bg release];
#endif
    
    int total = [BadgeView totalStixTypes];
    allCarouselStixFrames = [[NSMutableDictionary alloc] initWithCapacity:total];
    allCarouselStixViews = [[NSMutableDictionary alloc] initWithCapacity:total];
        
    /*
    for (int i=0; i<[BadgeView totalStixTypes]; i++) {
        [allCarouselStixViews addObject:[NSNull null]];
    }
     */
    showGiftStix = YES;
    sizeOfStixContext = 300; // default
    self.scrollOffsetFromTabTop = 110; // default start of scrollView
    return self;
}

#define NUM_STIX_FOR_BORDER 0 // put an empty stix on the edge of the content so stix isn't always at the very edge of the screen
-(void)initCarouselWithFrame:(CGRect)frame{
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    carouselHeight = scrollView.frame.size.height;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.directionalLockEnabled = NO; // only allow vertical or horizontal scroll
    [scrollView setDelegate:self];
    
    buttonShowCarousel = [[UIButton alloc] init];
    [buttonShowCarousel addTarget:self action:@selector(didClickShowCarousel:) forControlEvents:UIControlEventTouchUpInside];
    UIButton * button0 = [[UIButton alloc] init];
    UIButton * button1 = [[UIButton alloc] init];
    UIButton * button2 = [[UIButton alloc] init];
    [button0 setImage:[UIImage imageNamed:@"txt_all.png"] forState:UIControlStateNormal];
    [button0 setImage:[UIImage imageNamed:@"txt_all_selected.png"] forState:UIControlStateSelected];
    [button0 setTag:SHELF_CATEGORY_ALL];
    [button0 addTarget:self action:@selector(setShelfCategory:) forControlEvents: UIControlEventValueChanged];
    [button0 setFrame:CGRectMake(20,50,80,50)];
    [button1 setImage:[UIImage imageNamed:@"txt_cute.png"] forState:UIControlStateNormal];
    [button1 setImage:[UIImage imageNamed:@"txt_cute_selected.png"] forState:UIControlStateSelected];
    [button1 setTag:SHELF_CATEGORY_CUTE];
    [button1 addTarget:self action:@selector(setShelfCategory:) forControlEvents: UIControlEventValueChanged];
    [button1 setFrame:CGRectMake(120,50,80,50)];
    [button2 setImage:[UIImage imageNamed:@"txt_facefun.png"] forState:UIControlStateNormal];
    [button2 setImage:[UIImage imageNamed:@"txt_facefun_selected.png"] forState:UIControlStateSelected];
    [button2 setTag:SHELF_CATEGORY_FACEFUN];
    [button2 addTarget:self action:@selector(setShelfCategory:) forControlEvents: UIControlEventValueChanged];
    [button2 setFrame:CGRectMake(220,50,80,50)];

    buttonStixCategories = [[NSMutableArray alloc] initWithObjects:button0, button1, button2, nil];
	[button0 release];
	[button1 release];
	[button2 release];
                        
    UIImageView * tabImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_open.png"]];    
    carouselTab = [[UIView alloc] initWithFrame:tabImage.frame];
    [carouselTab addSubview:tabImage];
    [tabImage release];
    [carouselTab addSubview:scrollView];
    [carouselTab addSubview:buttonShowCarousel];
    for (int i=0; i<[buttonStixCategories count]; i++) {
        [carouselTab addSubview:[buttonStixCategories objectAtIndex:i]];
    }
    [self addSubview:carouselTab];
    [self carouselTabDismiss:NO];

    shelf.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y+50, 320, 30);
    
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

#if 0
    int stixSize = SHELF_STIX_SIZE; //carouselHeight;
    int totalStix = [BadgeView totalStixTypes];
    int maxX = STIX_PER_ROW;
    int maxY = totalStix / maxX;
    CGSize size = CGSizeMake(SHELF_STIX_SIZE * maxX, SHELF_STIX_SIZE * maxY);
    [scrollView setContentSize:size];
    for (int i=0; i<totalStix; i++) {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];    
        if ([allCarouselStixViews objectForKey:stixStringID])
            [[allCarouselStixViews objectForKey:stixStringID] removeFromSuperview];
        
        int count = [self.delegate getStixCount:stixStringID];
        int order = [self.delegate getStixOrder:stixStringID];
        if (order != -1) {
            int y = order / STIX_PER_ROW;
            int x = order - y * STIX_PER_ROW;
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            CGPoint stixCenter = CGPointMake(stixSize*(x+NUM_STIX_FOR_BORDER) + stixSize / 2 + 10, stixSize*(y+NUM_STIX_FOR_BORDER) + stixSize/2);
            [stix setCenter:stixCenter];
            [allCarouselStixFrames setObject:[NSValue valueWithCGRect:stix.frame] forKey:stixStringID];
            if (count == 0)
                [stix setAlpha:.25];
            [scrollView addSubview:stix];
            [allCarouselStixViews setObject:stix forKey:stixStringID];
            [stix release];
        }
    }
#else
    [self reloadAllStix];
#endif
}

-(void)setShelfCategory:(UIButton*)button {
    NSLog(@"Button pressed: %d", button.tag);
}

-(void)reloadAllStix {
    [self reloadAllStixWithFrame:scrollView.frame];
}
-(void)reloadAllStixWithFrame:(CGRect)frame {

    [scrollView removeFromSuperview];
    scrollView.frame = frame;
    
    int stixSize = SHELF_STIX_SIZE;
    int totalStix = [BadgeView totalStixTypes];
    int maxX = STIX_PER_ROW;
    int maxY = totalStix / maxX;
    CGSize size = CGSizeMake(SHELF_STIX_SIZE * maxX, SHELF_STIX_SIZE * maxY);
    [scrollView setContentSize:size];
    for (int i=0; i<totalStix; i++) {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];    
        if ([allCarouselStixViews objectForKey:stixStringID])
            [[allCarouselStixViews objectForKey:stixStringID] removeFromSuperview];
        
        int count = [self.delegate getStixCount:stixStringID];
        int order = [self.delegate getStixOrder:stixStringID];
        if (order != -1) {
            int y = order / STIX_PER_ROW;
            int x = order - y * STIX_PER_ROW;
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            CGPoint stixCenter = CGPointMake(stixSize*(x+NUM_STIX_FOR_BORDER) + stixSize / 2 + 10, stixSize*(y+NUM_STIX_FOR_BORDER) + stixSize/2);
            [stix setCenter:stixCenter];
            [allCarouselStixFrames setObject:[NSValue valueWithCGRect:stix.frame] forKey:stixStringID];
            if (count == 0)
                [stix setAlpha:.25];
            [scrollView addSubview:stix];
            [allCarouselStixViews setObject:stix forKey:stixStringID];
            [stix release];
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

-(void)toggleHideShelf:(bool)isHidden {
    [self.shelf setHidden:isHidden];
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
#if 0
    int totalStix = [BadgeView totalStixTypes];
    for (int i=0; i<totalStix; i++)
    {
        if ([allCarouselStixViews count] < totalStix)
            continue;
        if ([NSNull null] == [allCarouselStixViews objectAtIndex:i])
            continue;
        UIImageView * stix = [allCarouselStixViews objectAtIndex:i];
        [stix removeFromSuperview];

        stix.frame = [[allCarouselStixFrames objectAtIndex:i] CGRectValue];
        [self.scrollView addSubview:stix];
    }
    drag = 0;
#else
    NSEnumerator * e = [allCarouselStixViews keyEnumerator];
    id key;
    while (key = [e nextObject]) {
        UIImageView * stix = [allCarouselStixViews objectForKey:key];
        [stix removeFromSuperview];
        
        stix.frame = [[allCarouselStixFrames objectForKey:key] CGRectValue];
        [self.scrollView addSubview:stix];
    }
#endif
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
    for (int i=0; i<[buttonStixCategories count]; i++) {
        if (CGRectContainsPoint([[buttonStixCategories objectAtIndex:i] frame], pointInCarouselFrame))
            return [buttonStixCategories objectAtIndex:i];
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
            float scale = sizeOfStixContext / 300; // if stix context is different from the camera view in TagViewController
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
            for (int i=0; i<[allCarouselStixFrames count]; i++) {
                NSString * stixStringID = [[BadgeView stixStringIDs] objectAtIndex:i];
                CGRect stixFrame = [[allCarouselStixFrames objectForKey:stixStringID] CGRectValue];
                if (CGRectContainsPoint(stixFrame, location)) {
                    NSLog(@"Stix of type %@ touched", stixStringID);
                    UIImageView * stixTouched = [allCarouselStixViews objectForKey:stixStringID];                    

#if 0
                    // remove from scrollView and onto carouselView
                    [stixTouched removeFromSuperview];
                    CGRect frameOutsideCarousel = stixTouched.frame;
                    frameOutsideCarousel.origin.x = 0 - tapDefaultOffset.x;
                    frameOutsideCarousel.origin.y = 0 - tapDefaultOffset.y;
                    frameOutsideCarousel.origin.x -= frameOutsideCarousel.size.width/2;
                    frameOutsideCarousel.origin.y -= frameOutsideCarousel.size.height/2 + 20;
//                    frameOutsideCarousel.origin.x += scrollView.frame.origin.x - scrollView.contentOffset.x;
//                    frameOutsideCarousel.origin.y += scrollView.frame.origin.y;
                    // center to 
                    [stixTouched setFrame:frameOutsideCarousel];
                    [self addSubview:stixTouched];
                    [self.delegate didDropStix:stixTouched ofType:stixStringID];
#else
                    if ([self.delegate getStixCount:stixStringID] != 0) { 
                        [self.delegate didTapStix:stixTouched ofType:stixStringID];
                    }
                    break;
#endif
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

-(void)carouselTabDismiss {
    [self carouselTabDismiss:YES];
}
-(void)carouselTabDismiss:(BOOL)doAnimation {
    CGRect tabFrameHidden = CGRectMake(0, dismissedTabY, 320, 400);
    CGRect tabButtonHidden = CGRectMake(14, 1, 80, 40);
    if (isShowingCarousel == 3) {
        [buttonShowCarousel setCenter:CGPointMake(buttonShowCarousel.center.x, 15)];
        isShowingCarousel = 2;
    }
    else {
        [buttonShowCarousel setImage:[UIImage imageNamed:@"tab_open_icon.png"] forState:UIControlStateNormal];
        [buttonShowCarousel setFrame:tabButtonHidden];
        isShowingCarousel = 0;
        [self setStixSelected:nil];
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
-(void)carouselTabDismissWithStix:(UIImageView*)stix {
    CGRect tabFrameHidden = CGRectMake(0, dismissedTabY, 320, 400);
    CGRect imageFrame = buttonShowCarousel.imageView.frame;
    imageFrame.size.height = 55; // set a size for the tab icon
    imageFrame.size.width = imageFrame.size.height;
    CGPoint imageCenter = CGPointMake(buttonShowCarousel.center.x, 15);
    [buttonShowCarousel setFrame:imageFrame];
    [buttonShowCarousel setCenter:imageCenter];
    [buttonShowCarousel setImage:stix.image forState:UIControlStateNormal];
    isShowingCarousel = 2; // dismissed with stix already selected
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    tabAnimationIDDismiss = [animation doSlide:carouselTab inView:self toFrame:tabFrameHidden forTime:.75];
}
-(void)carouselTabDismissRemoveStix {
    CGRect tabFrameHidden = CGRectMake(0, dismissedTabY, 320, 400);
    CGRect tabButtonHidden = CGRectMake(14, 1, 80, 40);
    [buttonShowCarousel setImage:[UIImage imageNamed:@"tab_open_icon.png"] forState:UIControlStateNormal];
    [buttonShowCarousel setFrame:tabButtonHidden];
    isShowingCarousel = 0;
    
    [self setStixSelected:nil];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    tabAnimationIDDismiss = [animation doSlide:carouselTab inView:self toFrame:tabFrameHidden forTime:.75];
}
-(void)carouselTabExpand {
    CGRect tabFrameShow = CGRectMake(0, expandedTabY, 320, 400);
    CGRect tabButtonShow = CGRectMake(14, 1, 80, 40);
    if (isShowingCarousel == 2) {
        CGPoint imageCenter = CGPointMake(buttonShowCarousel.center.x, 15);
        [buttonShowCarousel setCenter:imageCenter];
        isShowingCarousel = 3;
    }
    else {
        [buttonShowCarousel setImage:[UIImage imageNamed:@"tab_close_icon.png"] forState:UIControlStateNormal];
        [buttonShowCarousel setFrame:tabButtonShow];
        isShowingCarousel = 1;
        [self setStixSelected:nil];
    }
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    tabAnimationIDExpand = [animation doSlide:carouselTab inView:self toFrame:tabFrameShow forTime:.75];
}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas {
    /*
    CGRect carouselFrameHidden = CGRectMake(0, self.scrollOffsetFromTabTop, 320, SHELF_STIX_SIZE);
    CGRect carouselFrameShow = CGRectMake(0, expandedTabY + self.scrollOffsetFromTabTop, 320, SHELF_STIX_SIZE);    
    if (animationID == tabAnimationIDExpand) {
        [scrollView setFrame:carouselFrameShow];
        if ([self.delegate respondsToSelector:@selector(didExpandCarouselTab)])
            [self.delegate didExpandCarouselTab];
    }
    if (animationID == tabAnimationIDDismiss) {
        [scrollView setFrame:carouselFrameHidden];
        if ([self.delegate respondsToSelector:@selector(didDismissCarouselTab)])
            [self.delegate didDismissCarouselTab];
    }
     */
}

-(void)didClickShowCarousel:(id)sender {
    if (isShowingCarousel == 1) {
        // dismiss carousel, change tab button, disable stix attachment
        [self carouselTabDismiss];
    }
    else if (isShowingCarousel == 0) {
        // display carousel above tab bar, change tab button to close tab
        [self carouselTabExpand];
    }
    else if (isShowingCarousel == 2) {
        // stix has been chosen, carousel tab is dismissed but should be shown
        [self carouselTabExpand];
    }    
    else if (isShowingCarousel == 3) {
        [self carouselTabDismiss];
    }
}

@end
