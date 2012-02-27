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
    allCarouselStixFrames = [[NSMutableArray alloc] initWithCapacity:total];
    allCarouselStixViews = [[NSMutableArray alloc] initWithCapacity:total];
        
    for (int i=0; i<[BadgeView totalStixTypes]; i++) {
        [allCarouselStixViews addObject:[NSNull null]];
    }
    showGiftStix = YES;
    sizeOfStixContext = 300; // default
    return self;
}

#define NUM_STIX_FOR_BORDER 0 // put an empty stix on the edge of the content so stix isn't always at the very edge of the screen
-(void)initCarouselWithFrame:(CGRect)frame{
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    carouselHeight = scrollView.frame.size.height;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.directionalLockEnabled = YES; // only allow vertical or horizontal scroll
    [scrollView setDelegate:self];

    shelf.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y+50, 320, 30);
    
    // for debug
    if (0) {
        [scrollView setBackgroundColor:[UIColor blackColor]];
        [self setBackgroundColor:[UIColor redColor]];
    }
    
    // add gesture recognizer
    UIVerticalGestureRecognizer * myVerticalRecognizer = [[UIVerticalGestureRecognizer alloc] initWithTarget:self action:@selector(verticalGestureHandler:)];
    [myVerticalRecognizer setDelegate:self];
    for (UIGestureRecognizer *gestureRecognizer in scrollView.gestureRecognizers)
    {
        [gestureRecognizer requireGestureRecognizerToFail:myVerticalRecognizer];
    } 
    [scrollView addGestureRecognizer:myVerticalRecognizer];

    UITapGestureRecognizer * myTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    [myTapRecognizer setNumberOfTapsRequired:1];
    [myTapRecognizer setNumberOfTouchesRequired:1];
    [myTapRecognizer setDelegate:self];
    [scrollView addGestureRecognizer:myTapRecognizer];
    self.allowTap = NO;

#if 0
    [self reloadAllStixWithFrame:frame];
#else
    UIImageView * basicStix = [[BadgeView getBadgeWithStixStringID:@"ICE"] retain];

    int stixSize = carouselHeight;
    int totalStix = [BadgeView totalStixTypes];
    int ct = 0;
    for (int i=0; i<totalStix; i++)
    {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
        int count = [self.delegate getStixCount:stixStringID];
        if (count > 0 || count == -1) {
            [basicStix setCenter:CGPointMake(stixSize*(ct+NUM_STIX_FOR_BORDER) + stixSize/2, stixSize/2)];
            CGRect basicFrame = basicStix.frame;
            [allCarouselStixFrames addObject:[NSValue valueWithCGRect:basicFrame]];
            ct++;
        }
        else
        {
            CGRect stixFrame = CGRectMake(0, 0, 0, 0);
            [allCarouselStixFrames addObject:[NSValue valueWithCGRect:stixFrame]];
        }
    }
    [basicStix release];
    
    CGSize size = CGSizeMake(carouselHeight*(ct+2*NUM_STIX_FOR_BORDER), carouselHeight);
    [scrollView setContentSize:size];
    for (int i=0; i<totalStix; i++) {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
        int count = [self.delegate getStixCount:stixStringID];
//        NSLog(@"CarouselView stix %d: stixStringID: %@ count: %d order %f frame %f %f", i, stixStringID, count);
        if (count > 0 || count == -1) {
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            CGRect fr = [[allCarouselStixFrames objectAtIndex:i] CGRectValue];
            [stix setFrame:fr];
            [scrollView addSubview:stix];
            [allCarouselStixViews replaceObjectAtIndex:i withObject:stix];
            [stix release];
        }
    }
    [self addSubview:scrollView];
#endif
}

-(void)reloadAllStix {
    [self reloadAllStixWithFrame:scrollView.frame];
}
-(void)reloadAllStixWithFrame:(CGRect)frame {

    [scrollView removeFromSuperview];
    scrollView.frame = frame;
    
    if ([allCarouselStixViews count] != [BadgeView totalStixTypes]) {
        [allCarouselStixViews release];
        [allCarouselStixFrames release];
        allCarouselStixViews = [[NSMutableArray alloc] initWithCapacity:[BadgeView totalStixTypes]];
        allCarouselStixFrames = [[NSMutableArray alloc] initWithCapacity:[BadgeView totalStixTypes]];
        for (int i=0; i<[BadgeView totalStixTypes]; i++) {
            [allCarouselStixViews addObject:[NSNull null]];
            [allCarouselStixFrames addObject:[NSNull null]];
        }
    }
    
    int stixSize = carouselHeight;
    int totalStix = [BadgeView totalStixTypes];
    int ct=0; //2;
    UIImageView * basicStix = [[BadgeView getBadgeWithStixStringID:@"ICE"] retain];
    for (int i=0; i<totalStix; i++) {
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
        int count = [self.delegate getStixCount:stixStringID];
        int order = [self.delegate getStixOrder:stixStringID];
        if (order != -1) { //(count > 0 || count == -1) {
            [basicStix setCenter:CGPointMake(stixSize*(order+NUM_STIX_FOR_BORDER) + stixSize / 2, stixSize/2)];
            CGRect basicFrame = basicStix.frame;
            [allCarouselStixFrames replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:basicFrame]];
            NSLog(@"Repositioning CarouselView stix %d: stixStringID: %@ count: %d order %d frame %f %f", i, stixStringID, count, order, basicStix.frame.origin.x, basicStix.frame.origin.y);
            ct++;
        }
        else
        {
            CGRect stixFrame = CGRectMake(0, 0, 0, 0);
            [allCarouselStixFrames replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:stixFrame]];
        }
    }
    [basicStix release];
    
    CGSize size = CGSizeMake(carouselHeight*(ct+2*NUM_STIX_FOR_BORDER), carouselHeight);
    [scrollView setContentSize:size];
    for (int i=0; i<totalStix; i++) {
        if ([NSNull null] != [allCarouselStixViews objectAtIndex:i])
            [[allCarouselStixViews objectAtIndex:i] removeFromSuperview];
        
        NSString * stixStringID = [BadgeView getStixStringIDAtIndex:i];
        int count = [self.delegate getStixCount:stixStringID];
        int order = [self.delegate getStixOrder:stixStringID];
        //NSLog(@"i: %d stixStringID: %@ count: %d", i, stixStringID, count);
        if  (count > 0 || count == -1) {
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            CGRect fr = [[allCarouselStixFrames objectAtIndex:i] CGRectValue];
            [stix setFrame:fr];
            [scrollView addSubview:stix];
            [allCarouselStixViews replaceObjectAtIndex:i withObject:stix];
            [stix release];
        }
        if (count == 0 && order != -1) {
            UIImageView * stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
            CGRect fr = [[allCarouselStixFrames objectAtIndex:i] CGRectValue];
            [stix setFrame:fr];
            [stix setAlpha:.25];
            [scrollView addSubview:stix];
            [allCarouselStixViews replaceObjectAtIndex:i withObject:stix];
            [stix release];
        }
    }
    [self addSubview:scrollView];
}

-(void)clearAllViews {
    for (int i=0; i<[allCarouselStixViews count]; i++)
    {
        if ([allCarouselStixViews objectAtIndex:i] != [NSNull null])
            [[allCarouselStixViews objectAtIndex:i] removeFromSuperview];
    }
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
#if 1
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
    
    if (CGRectContainsPoint(scrollView.frame, point))
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
            if ([allCarouselStixViews count] < totalStixTypes)
                continue;
            if ([allCarouselStixViews objectAtIndex:i] == [NSNull null])
                continue;
            UIImageView * stix = [allCarouselStixViews objectAtIndex:i];
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
                if ([self.delegate getStixCount:selectedStixStringID] != 0)
                    [self.delegate didDropStix:badgeTouched ofType:selectedStixStringID];
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
                CGRect stixFrame = [[allCarouselStixFrames objectAtIndex:i] CGRectValue];
                if (CGRectContainsPoint(stixFrame, location)) {
                    NSString * stixStringID = [[BadgeView stixStringIDs] objectAtIndex:i];
                    NSLog(@"Stix of type %@ touched", stixStringID);
                    UIImageView * stixTouched = [allCarouselStixViews objectAtIndex:i];                    

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
                    if ([self.delegate getStixCount:stixStringID] != 0)
                        [self.delegate didTapStix:stixTouched ofType:stixStringID];
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
@end
