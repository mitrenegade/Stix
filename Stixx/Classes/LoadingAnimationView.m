
#import "LoadingAnimationView.h"

@implementation LoadingAnimationView

@synthesize customActivityIndicator;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
  
    //[self setFrame:CGRectMake(0, 0, 100, 100)];
    self.animationImages = [NSArray arrayWithObjects:
#if 0
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
#else
                            [UIImage imageNamed:@"loading_01.png"],
                            [UIImage imageNamed:@"loading_02.png"],
                            [UIImage imageNamed:@"loading_03.png"],
                            [UIImage imageNamed:@"loading_04.png"],
                            [UIImage imageNamed:@"loading_05.png"],
#endif
                                               //[UIImage imageNamed:@"fire_load4.png"],
                                               nil];
    
    self.animationDuration = .5; // in seconds
    self.animationRepeatCount = 0; // sets to loop
    [self setHidden:YES];
    //[self startAnimating];
    
    UIImageView * bkg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_bkg.png"]];
    [bkg setFrame:CGRectMake(-5, -5, frame.size.width+10, frame.size.height+10)];
    //[self insertSubview:bkg belowSubview:self];
    return self;
}

-(void)checkForShouldStop {
    if (shouldStop)
    {
        [self setHidden:YES];
        [self stopAnimating];
    }
    else
        [self performSelector:@selector(checkForShouldStop) withObject:self afterDelay:0]; //self.animationDuration];        
}

- (void)startCompleteAnimation {
    shouldStop = false;
    [self setHidden:NO];
    [self startAnimating];
    [self performSelector:@selector(checkForShouldStop) withObject:self afterDelay:0]; //self.animationDuration];
}
-(void) stopCompleteAnimation {
    shouldStop = true;
}


@end
