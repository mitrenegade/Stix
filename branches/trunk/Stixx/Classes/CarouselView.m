//
//  CarouselView.m
//

#import "CarouselView.h"

@implementation CarouselView

//@synthesize delegate;
@synthesize stixArray;
@synthesize scrollView;
@synthesize carouselHeight;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
  
    stixArray = [[NSMutableArray alloc] init];
    for (int i=0; i<BADGE_TYPE_MAX; i++)
    {
        UIImageView * stix = [[BadgeView getLargeBadgeOfType:i] retain];
        [stixArray addObject:stix];
        [stix release];
    }
    
    carouselHeight = self.frame.size.height;
    
    // background image
    UIImageView * bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"load_bkg.png"]];
    [bg setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:bg];
    [bg release];
    
    scrollView = [[UIScrollView alloc] init];
    //[scrollView setFrame:CGRectMake(0, 0, 120*[stixArray count], 120)];
    [scrollView setFrame:CGRectMake(10, 0, self.frame.size.width-20,carouselHeight)];
    [scrollView setContentSize:CGSizeMake(carouselHeight*[stixArray count], carouselHeight)];
    [self addSubview:scrollView];
 	return self;
}

-(void)initWithStixLevel:(int)level {
    if (level>BADGE_TYPE_MAX)
        level = BADGE_TYPE_MAX;
    int stixSize = carouselHeight;
    for (int i=0; i<level; i++)
    {
        CGRect stixFrame = CGRectMake(stixSize*i, 0, stixSize, stixSize);
        UIImageView * stix = [stixArray objectAtIndex:i];
        [stix setFrame:stixFrame];
        [scrollView addSubview:[stixArray objectAtIndex:i]];
    }
}

- (void)dealloc {
	[super dealloc];
}

@end