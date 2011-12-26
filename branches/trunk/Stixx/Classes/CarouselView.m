//
//  CarouselView.m
//

#import "CarouselView.h"

@implementation CarouselView

//@synthesize delegate;
@synthesize scrollView;
@synthesize carouselHeight;
@synthesize stixLevel;

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

    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 90, 320, 120)];
    self.carouselHeight = 100;
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.scrollEnabled = YES;
    scrollView.directionalLockEnabled = YES; // only allow vertical or horizontal scroll
    [scrollView setDelegate:self];
    
    // add gesture recognizer
    
    UIVerticalGestureRecognizer * myVerticalRecognizer = [[UIVerticalGestureRecognizer alloc] initWithTarget:self action:@selector(verticalGestureHandler:)];
    [myVerticalRecognizer setDelegate:self];
    for (UIGestureRecognizer *gestureRecognizer in scrollView.gestureRecognizers)
    {
        [gestureRecognizer requireGestureRecognizerToFail:myVerticalRecognizer];
    } 
    [scrollView addGestureRecognizer:myVerticalRecognizer];
     
    [self addSubview:scrollView];
    
    return self;
}

-(void)setCarouselFrame:(CGRect)frame {
    scrollView.frame = frame;
    carouselHeight = scrollView.frame.size.height;
}

-(void)initWithStixLevel:(int)level {
    if (level>BADGE_TYPE_MAX)
        level = BADGE_TYPE_MAX;
    int stixSize = carouselHeight;
    stixLevel = level;
    [scrollView setContentSize:CGSizeMake(carouselHeight*stixLevel, carouselHeight)];
    for (int i=0; i<stixLevel; i++)
    {
        CGRect stixFrame = CGRectMake(stixSize*i, 0, stixSize, stixSize);
        UIImageView * stix = [self.badgesLarge objectAtIndex:i];
        [stix setFrame:stixFrame];
        [scrollView addSubview:stix];
    }
}

-(void)toggleShelf:(bool)isVisible {
    [self.shelf setHidden:isVisible];
}

- (void)dealloc {
	[super dealloc];
    
    [scrollView release];
    scrollView = nil;
}

/*** scrollview delegate ***/
static int lastContentOffsetX = 0;
static int lastContentOffsetY = 0;
#define DOWN 1
#define UP -1

-(void)scrollViewDidScroll:(UIScrollView *)sv {
    int scrollDirection;
    if (lastContentOffsetX == sv.contentOffset.x) {
        if (lastContentOffsetY > sv.contentOffset.y) {
            NSLog(@"Scrolling down!");
            scrollDirection = DOWN;
        }
        else if (lastContentOffsetY < sv.contentOffset.y) {
            NSLog(@"Scrolling up!");
            scrollDirection = UP;
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
    if ([vgr state] == UIGestureRecognizerStateBegan) {
        // identify which badge it is
        // basically touchesBegan from BadgeView
        CGPoint touch = [vgr firstTouch];
        CGPoint location = touch;
        drag = 0;
        
        // find which icon is being dragged
        unsigned numEls = [badges count];
        while (numEls--)
        {
            UIImageView * badge = [badges objectAtIndex:numEls];
            CGRect frame = badge.frame;
            if (CGRectContainsPoint(frame, touch)) {
                badgeTouched = badge;
                drag = 1;
                badgeSelect = numEls;
                [[labels objectAtIndex:badgeSelect] removeFromSuperview];
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
            badgeTouched.contentMode = UIViewContentModeScaleAspectFit; // allow scaling based on frame
            badgeTouchedLarge = [BadgeView getLargeBadgeOfType:badgeSelect]; // objectAtIndex:badgeSelect];
            //CGRect frameStart = badgeTouched.frame;
            float centerX = badgeTouched.center.x; //(frameStart.origin.x + frameStart.size.width/2);
            float centerY = badgeTouched.center.y; //(frameStart.origin.y + frameStart.size.height/2);
            
            //frameEnd.origin.x = centerX - frameEnd.size.width / 2;
            //frameEnd.origin.y = centerY - frameEnd.size.height / 2;
            badgeTouchedLarge.center = CGPointMake(centerX, centerY);
            CGRect frameEnd = badgeTouchedLarge.frame;
            
            // point where finger clicked badge
            offset_from_center_X = (location.x - centerX);
            offset_from_center_Y = (location.y - centerY);
            
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
            
            //NSLog(@"Dragging badge %d", badgeSelect);
            
        }
        //fire.center = location;
        //NSLog(@"Location: %f %f", location.x, location.y);
    }
    else if ([vgr state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = vgr.translation; //[vgr translationInView:[inView superview]];
        NSLog(@"Gesture translation: %f %f\n", translation.x, translation.y);

    }
}
@end
