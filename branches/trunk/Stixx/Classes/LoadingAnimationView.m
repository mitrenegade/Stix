
#import "LoadingAnimationView.h"

@implementation LoadingAnimationView

@synthesize customActivityIndicator;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
  
    //[self setFrame:CGRectMake(0, 0, 100, 100)];
    //customActivityIndicator.center = self.center;
    self.animationImages = [NSArray arrayWithObjects:
#if 0
                                               [UIImage imageNamed:@"fire_load1.png"],
                                               [UIImage imageNamed:@"fire_load2.png"],
                                               [UIImage imageNamed:@"fire_load3.png"],
                                               [UIImage imageNamed:@"fire_load4.png"],
                                               [UIImage imageNamed:@"fire_load3.png"],
                                               [UIImage imageNamed:@"fire_load2.png"],
#else
                            [UIImage imageNamed:@"fire_load_side1.png"],
                            [UIImage imageNamed:@"fire_load_side2.png"],
                            [UIImage imageNamed:@"fire_load_side3.png"],
                            [UIImage imageNamed:@"fire_load_side4.png"],
                            [UIImage imageNamed:@"fire_load_side5.png"],
                            [UIImage imageNamed:@"fire_load_side5.png"],
                            [UIImage imageNamed:@"fire_load_side4.png"],
                            [UIImage imageNamed:@"fire_load_side3.png"],
                            [UIImage imageNamed:@"fire_load_side2.png"],
                            [UIImage imageNamed:@"fire_load_side1.png"],
                            
#endif
                                               //[UIImage imageNamed:@"fire_load4.png"],
                                               nil];
    
    self.animationDuration = 0.8; // in seconds
    self.animationRepeatCount = 0; // sets to loop
    [self setHidden:YES];
    //[self startAnimating];
    
    UIImageView * bkg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"load_bkg.png"]];
    [bkg setFrame:CGRectMake(-5, -5, frame.size.width+10, frame.size.height+10)];
    [self addSubview:bkg];
    //[self addSubview:customActivityIndicator];
    [bkg release];
    return self;
}

-(void)checkForShouldStop {
    if (shouldStop)
    {
        [self setHidden:YES];
        [self stopAnimating];
    }
    else
        [self performSelector:@selector(checkForShouldStop) withObject:self afterDelay:self.animationDuration];        
}

- (void)startCompleteAnimation {
    shouldStop = false;
    [self setHidden:NO];
    [self startAnimating];
    [self performSelector:@selector(checkForShouldStop) withObject:self afterDelay:self.animationDuration];
}
-(void) stopCompleteAnimation {
    shouldStop = true;
}

- (void)dealloc {
    [customActivityIndicator release];
	[super dealloc];
}

@end
