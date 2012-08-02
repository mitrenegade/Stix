//
//  RaisedCenterTabBarController.m
//  Stixx
//
//  Created by Bobby Ren on 11/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RaisedCenterTabBarController.h"

// predefined although the buttons should be the correct size
#define BUTTON_WIDTH_CENTER 71
#define BUTTON_WIDTH 63
#define BUTTON_HEIGHT 40 

@implementation RaisedCenterTabBarController

static int tickID = -1;

@synthesize myDelegate;
@synthesize newsCount, newsCallout;

-(void)initializeCustomButtons {
    // hide actual tabbar
    
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            view.hidden = YES;
            break;
        }
    }      
    [self addButtonWithImage:[UIImage imageNamed:@"tab_feed"] highlightImage:[UIImage imageNamed:@"tab_feed_on"] atPosition:TABBAR_BUTTON_FEED];
    [self addButtonWithImage:[UIImage imageNamed:@"tab_popular"] highlightImage:[UIImage imageNamed:@"tab_popular_on"] atPosition:TABBAR_BUTTON_EXPLORE];
    [self addButtonWithImage:[UIImage imageNamed:@"tab_newsletter"] highlightImage:[UIImage imageNamed:@"tab_newsletter_on"] atPosition:TABBAR_BUTTON_NEWS];
    [self addButtonWithImage:[UIImage imageNamed:@"tab_profile"] highlightImage:[UIImage imageNamed:@"tab_profile_on"] atPosition:TABBAR_BUTTON_PROFILE];
    // add camera last
    [self addButtonWithImage:[UIImage imageNamed:@"tab_camera"] highlightImage:nil atPosition:TABBAR_BUTTON_TAG];
     
    // news counter
    /*
    CGRect newsFrame = CGRectMake(230, 420, 20, 20);
    newsCount = [[OutlineLabel alloc] initWithFrame:newsFrame];
    [newsCount setTextColor:[UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1]];
    [newsCount setOutlineColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    [newsCount setFontSize:20];
    [self.view addSubview:newsCount];
     */
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage atPosition:(int)pos
{
    if (pos>=TABBAR_BUTTON_MAX)
        return;
    
    button[pos] = [UIButton buttonWithType:UIButtonTypeCustom];
    button[pos].autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button[pos].frame = CGRectMake(0, 0, ceil(buttonImage.size.width), ceil(buttonImage.size.height));
    [button[pos] setBackgroundColor:[UIColor blackColor]];
    //NSLog(@"Button %d: image size %f %f frame %f %f %f %f", pos, buttonImage.size.width, buttonImage.size.height, button[pos].frame.origin.x, button[pos].frame.origin.y, button[pos].frame.size.width, button[pos].frame.size.height);
    bgNormal[pos] = buttonImage;
    bgSelected[pos] = highlightImage;
    [button[pos] setBackgroundImage:bgNormal[pos] forState:UIControlStateNormal];
    if (highlightImage)
        [button[pos] setBackgroundImage:bgSelected[pos] forState:UIControlStateHighlighted];

    CGPoint center;
    NSLog(@"Self.frame size: %f %f", self.view.frame.size.width, self.view.frame.size.height);
    float height = self.view.frame.size.height;
    if (pos == TABBAR_BUTTON_FEED) {
        center = CGPointMake(BUTTON_WIDTH * pos + ceil(BUTTON_WIDTH/2.0), height-ceil(BUTTON_HEIGHT/2.0));
    }
    else if (pos == TABBAR_BUTTON_EXPLORE) {
        center = CGPointMake(BUTTON_WIDTH * pos + ceil(BUTTON_WIDTH/2.0), height-ceil(BUTTON_HEIGHT/2.0));
    }
    else if (pos == TABBAR_BUTTON_NEWS) {
        center = CGPointMake(320 - BUTTON_WIDTH * (TABBAR_BUTTON_MAX - pos) + ceil(BUTTON_WIDTH/2.0), height - ceil(BUTTON_HEIGHT/2.0));
    }
    else if (pos == TABBAR_BUTTON_PROFILE) {
        center = CGPointMake(320 - BUTTON_WIDTH * (TABBAR_BUTTON_MAX - pos) + ceil(BUTTON_WIDTH/2.0), height - ceil(BUTTON_HEIGHT/2.0));
    }
    if (pos == TABBAR_BUTTON_TAG) 
        center = CGPointMake(161, 480 - (BUTTON_HEIGHT/2));
    
    center.y -= TABBAR_BUTTON_DIFF_PX - 1;

    button[pos].center = center;
    [button[pos] setTag:pos];
    [button[pos] addTarget:self
               action:@selector(didPressTabButton:)
     forControlEvents:UIControlEventTouchDown];
    CGRect frame = button[pos].frame;
    NSLog(@"Button %d: frame %f %f %f %f", pos, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    [self.view addSubview:button[pos]];
}

-(void)setHeaderForTab:(int)pos {
    UIImageView * logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    
    if (pos == TABBAR_BUTTON_EXPLORE) {
        UIImage * img = [UIImage imageNamed:@"txt_stixstergallery"];
        [logo setImage:img];
        [logo setFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        [logo setCenter:self.navigationController.navigationBar.center];
    }
    else if (pos == TABBAR_BUTTON_NEWS) {
        UIImage * img = [UIImage imageNamed:@"txt_newsletter"];
        [logo setImage:img];
        [logo setFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        [logo setCenter:self.navigationController.navigationBar.center];
    }
    else if (pos == TABBAR_BUTTON_PROFILE) {
        
    }
    [self.navigationItem setTitleView:logo];
}

-(void)didGetProfilePhoto:(UIImage *)photo {
    CGPoint center = CGPointMake(320/2, 480-(BUTTON_HEIGHT/2));
    CGRect buttonFrame = button[TABBAR_BUTTON_PROFILE].frame;
    int width = buttonFrame.size.width;
    buttonFrame.size.height -= 10;
    buttonFrame.size.width = buttonFrame.size.height;
    center.x = 320 - (width * (TABBAR_BUTTON_MAX - TABBAR_BUTTON_PROFILE)) + width / 2;
    if (!profileButton) {
        profileButton = [[UIButton alloc] init];
        [self.view addSubview:profileButton];
    }
    [profileButton setFrame:buttonFrame];
    [profileButton setCenter:center];
    [profileButton setImage:photo forState:UIControlStateNormal];
    [profileButton setTag:TABBAR_BUTTON_PROFILE];
    [profileButton addTarget:self action:@selector(didPressTabButton:) forControlEvents:UIControlEventTouchUpInside];
    [profileButton setAdjustsImageWhenHighlighted:NO];
}

-(void)doPointerAnimation:(int)firstTimeUserStage {
#if SHOW_ARROW
    UIImage * pointerImg = [UIImage imageNamed:@"orange_arrow.png"];
    CGRect canvasFrame = CGRectMake(160-pointerImg.size.width/2, 375, pointerImg.size.width, pointerImg.size.height);
    if (firstTimeUserStage == FIRSTTIME_MESSAGE_01) {
        canvasFrame = CGRectMake(160-pointerImg.size.width/2, 375, pointerImg.size.width, pointerImg.size.height);
    }
    else if (firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
        canvasFrame = CGRectMake(50-pointerImg.size.width/2, 335, pointerImg.size.width, pointerImg.size.height);
    }
    else if (firstTimeUserStage == FIRSTTIME_MESSAGE_03) {
        canvasFrame = CGRectMake(290-pointerImg.size.width/2, 375, pointerImg.size.width, pointerImg.size.height);
    }
    UIView * pointerCanvas = [[UIView alloc] initWithFrame:canvasFrame];
    UIImageView * pointer = [[UIImageView alloc] initWithImage:pointerImg];
    //if (firstTimeUserStage == FIRSTTIME_MESSAGE_03) {
    //    pointer.transform = CGAffineTransformMakeRotation(3.141592);
    //}
    [pointerCanvas addSubview:pointer];
    agitatePointer = 0;
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    if (firstTimeUserStage == FIRSTTIME_MESSAGE_01 || firstTimeUserStage == FIRSTTIME_MESSAGE_03)
        mallPointerAnimationID = [animation doJump:pointerCanvas inView:self.view forDistance:20 forTime:1];
#endif
}

-(void)doPurchaseAnimation:(NSString*)stixStringID {
    int width = 140;
    CGRect canvasFrame = CGRectMake(0, 0, 320, 480);
    UIView * rewardCanvas = [[UIView alloc] initWithFrame:canvasFrame];
    UIImageView * stix = [BadgeView getBadgeWithStixStringID:stixStringID];
    [stix setFrame:CGRectMake(0,0,width,width)];
    [stix setCenter:[rewardCanvas center]];
    [rewardCanvas addSubview:stix];
    CGRect rewardNameFrame = CGRectMake(0, 0, width*2, 40);
    OutlineLabel * rewardName = [[OutlineLabel alloc] initWithFrame:rewardNameFrame];
    [rewardName setFrame:rewardNameFrame];
    CGPoint rewardNameCenter = rewardCanvas.center;
    rewardNameCenter.y += width/2;
    [rewardName setCenter:rewardNameCenter];
    [rewardName setTextAttributesForBadgeType:0]; // generic red font
    [rewardName setFontSize:20];
    [rewardName setText:@"Purchased Stix"];
    [rewardName setNumberOfLines:2];
    [rewardName setTextAlignment:UITextAlignmentCenter];
    [rewardCanvas addSubview:rewardName];

    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    [rewardCanvas setAlpha:0];
    animationIDsPurchase[0] = [animation doFade:rewardCanvas inView:self.view toAlpha:1 forTime:.1]; // not working
     // MRC
}

-(void)doPremiumPurchaseAnimation:(NSString*)stixPackName {
    int width = 140;
    CGRect canvasFrame = CGRectMake(0, 0, 320, 480);
    UIView * rewardCanvas = [[UIView alloc] initWithFrame:canvasFrame];
    //UIImageView * stix = [BadgeView getBadgeWithStixStringID:stixStringID];
    //[stix setFrame:CGRectMake(0,0,width,width)];
    //[stix setCenter:[rewardCanvas center]];
    //[rewardCanvas addSubview:stix];
    CGRect rewardNameFrame = CGRectMake(0, 0, width*2, 40);
    OutlineLabel * rewardName = [[OutlineLabel alloc] initWithFrame:rewardNameFrame];
    [rewardName setFrame:rewardNameFrame];
    CGPoint rewardNameCenter = rewardCanvas.center;
    //rewardNameCenter.y += width/2;
    [rewardName setCenter:rewardNameCenter];
    [rewardName setTextAttributesForBadgeType:0]; // generic red font
    [rewardName setFontSize:20];
    [rewardName setText:@"Purchased Premium Pack:"];
    [rewardName setNumberOfLines:2];
    [rewardName setTextAlignment:UITextAlignmentCenter];

    CGRect packFrame = CGRectMake(0, 0, width*2, 40);
    OutlineLabel * packName = [[OutlineLabel alloc] initWithFrame:packFrame];
    [packName setFrame:packFrame];
    CGPoint packCenter = rewardCanvas.center;
    packCenter.y += 30;
    [packName setCenter:packCenter];
    [packName setTextAttributesForBadgeType:0]; // generic red font
    [packName setFontSize:30];
    [packName setText:stixPackName];
    [packName setNumberOfLines:2];
    [packName setTextAlignment:UITextAlignmentCenter];

    [rewardCanvas addSubview:rewardName];
    [rewardCanvas addSubview:packName];
    
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    [rewardCanvas setAlpha:0];
    animationIDsPurchase[0] = [animation doFade:rewardCanvas inView:self.view toAlpha:1 forTime:.1]; // not working
    // MRC
}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas{
    //NSLog(@"Animation %d finished!", animationID);
     // animations autorelease the canvas they are sent
    /* reward animations */
    if (animationID == allAnimationIDs[0]) // first jump animation finished
    {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        allAnimationIDs[1] = [animation doJump:canvas inView:self.view forDistance:15 forTime:.25];
    }
    else if (animationID == allAnimationIDs[1]) // second jump animation finished
    {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        allAnimationIDs[2] = [animation doJump:canvas inView:self.view forDistance:15 forTime:.25];
    }
    else if (animationID == allAnimationIDs[2]) // first animation finished
    {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        allAnimationIDs[3] = [animation doDownwardFade:canvas inView:self.view forDistance:-100 forTime:1];
        [myDelegate didFinishRewardAnimation:rewardValue];
    }
    
    /* first time mall pointer */
#if SHOW_ARROW
    if (animationID == mallPointerAnimationID) // first jump animation finished
    {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        float time = 1;
        if (agitatePointer > 0) {
            agitatePointer--;
            time = .15;
        }
        if (showMallPointer && !pointerWasDismissed)
            mallPointerAnimationID = [animation doJump:canvas inView:self.view forDistance:20 forTime:time];
        else {
            [canvas removeFromSuperview];
//            canvas = nil;
        }
    }
#endif
    
    /* purchase stix */
    if (animationID == animationIDsPurchase[0]) { // fade in finished
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        animationIDsPurchase[1] = [animation doJump:canvas inView:self.view forDistance:15 forTime:.25];
    }
    else if (animationID == animationIDsPurchase[1]) { // first jump finished
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        animationIDsPurchase[2] = [animation doJump:canvas inView:self.view forDistance:15 forTime:.25];
    }
    else if (animationID == animationIDsPurchase[2]) { // second jump finished
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        animationIDsPurchase[3] = [animation doDownwardFade:canvas inView:self.view forDistance:300 forTime:1.5];
    }
    else if (animationID == animationIDsPurchase[3]) {
        [canvas removeFromSuperview];
    }

}


/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}
*/
-(IBAction)didPressTabButton:(id)sender {
    UIButton * pressedButton = sender;
    [myDelegate didPressTabButton:pressedButton.tag];
}

// these functions are called by the app delegate - when the tabbar state changes
-(void)setButtonStateSelected:(int)pos {
    for (int i=0; i<TABBAR_BUTTON_MAX; i++){
        if (pos == i)
            [button[i] setBackgroundImage:bgSelected[i] forState:UIControlStateNormal];        
        else
            [button[i] setBackgroundImage:bgNormal[i] forState:UIControlStateNormal];
    }
}
-(void)setButtonStateNormal:(int)pos {
    [button[pos] setBackgroundImage:bgNormal[pos] forState:UIControlStateNormal];
}


-(void)addFirstTimeInstructions {
#if 0
    UIImage * img1 = [UIImage imageNamed:@"firsttime_message_01.png"];
    firstTimeInstructions = [[UIButton alloc] initWithFrame:CGRectMake(5, 130, img1.size.width+25, img1.size.height+20)];
    [firstTimeInstructions addTarget:self action:@selector(closeInstructions:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:firstTimeInstructions];
    [self toggleFirstTimeInstructions:NO];
#else
    firstTimeInstructions = [[UIImageView alloc] init];
    [firstTimeInstructions setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:firstTimeInstructions];
    firstTimeInstructionsLabel = [[UILabel alloc] init];
    [firstTimeInstructionsLabel setTextColor:[UIColor whiteColor]];
    [firstTimeInstructionsLabel setTextAlignment:UITextAlignmentCenter];
    [firstTimeInstructionsLabel setBackgroundColor:[UIColor clearColor]];
    //[firstTimeInstructionsLabel setOutlineColor:[UIColor blackColor]];
    [firstTimeInstructionsLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [firstTimeInstructions addSubview:firstTimeInstructionsLabel];
    firstTimeInstructionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [firstTimeInstructionsButton setBackgroundColor:[UIColor clearColor]];
    [firstTimeInstructionsButton setAdjustsImageWhenHighlighted:NO];
    [firstTimeInstructionsButton addTarget:self action:@selector(closeInstructions:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:firstTimeInstructionsButton];
    
    //[self toggleFirstTimeInstructions:NO];
#endif
}

-(void)reshowFirstTimeInstructions:(NSNumber*)lastStage {
    // for faded out instructions to be displayed after a delay
    
    NSLog(@"LastStage: %@ current Stage: %d", lastStage, [myDelegate getFirstTimeUserStage]);
    // if stage has changed and is no longer equal to lastStage, do not show it
    if ([lastStage intValue] != [myDelegate getFirstTimeUserStage])
        return;
    
    if ([myDelegate tabBarIsVisible]) {
        [self toggleFirstTimeInstructions:YES];        
    }
    else 
        [self performSelector:@selector(reshowFirstTimeInstructions:) withObject:lastStage afterDelay:5];
}

-(void)closeInstructions:(id)sender forEvent:(UIEvent*)event{

    // must make sure frame does not cover something else
    /*
     // only trigger if actually touched graphic
    UIView *_button = (UIView *)sender;
    UITouch *touch = [[event touchesForView:_button] anyObject];
    CGPoint location = [touch locationInView:_button];

    BOOL isForeground = NO;
    int dx=0;
    int dy=0;
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel, 
                                                 1, 1, 8, 1, NULL,
                                                 kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    UIImage * im = firstTimeInstructions.imageView.image;
    CGSize size = im.size;
    float scale = size.width / _button.frame.size.width;
    location.x *= scale; // convert to the UIImage size
    location.y *= scale; 
    [im drawAtPoint:CGPointMake(-location.x + dx, -location.y + dy)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGFloat alpha = pixel[0]/255.0;
    BOOL thisTransparent = alpha < 0.1;
    if (!thisTransparent) {
        isForeground = YES;
    }
    if (isForeground)
     */
        [self toggleFirstTimeInstructions:NO];
}
-(void)bounceInstructionsWithClock:(NSNumber *)lastTickID {
    if ([lastTickID intValue] == tickID) {
        NSLog(@"Bouncing on clock %@", lastTickID);
        StixAnimation * animation2 = [[StixAnimation alloc] init];
        [animation2 doBounce:firstTimeInstructions forDistance:FTUE_BOUNCE_DISTANCE forTime:.5 repeatCount:FTUE_BOUNCE_COUNT];
        [self performSelector:@selector(bounceInstructionsWithClock:) withObject:lastTickID afterDelay:FTUE_REDISPLAY_TIMER];
    }
    else {
        NSLog(@"Stopping bounce with clock %@", lastTickID);
    }
}

-(void)toggleFirstTimeInstructions:(BOOL)showInstructions {
    StixAnimation * animation = [[StixAnimation alloc] init];
    //CGRect frameOnscreen = firstTimeInstructionsFrame; //CGRectMake(5, 130, img1.size.width+25, img1.size.height+20);
    //CGRect frameOffscreen = frameOnscreen;
    //frameOffscreen.origin.y += 480;
    
    if (showInstructions) {
//        [animation doViewTransition:firstTimeInstructions toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished) {}];
        [animation doFadeIn:firstTimeInstructions forTime:.5 withCompletion:^(BOOL finished) {
            NSLog(@"Starting bounce with new clock %d", tickID + 1);
            [self bounceInstructionsWithClock:[NSNumber numberWithInt:(++tickID)]];
            [firstTimeInstructionsButton setHidden:NO];
        }];
    }
    else {
//        [animation doViewTransition:firstTimeInstructions toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {}];
        // must set dismissedStage before the delay
        NSNumber * dismissedStage = [NSNumber numberWithInt:[myDelegate getFirstTimeUserStage]];
        NSLog(@"Hiding first time instructions at stage %d", [myDelegate getFirstTimeUserStage]);
        [animation doFadeOut:firstTimeInstructions forTime:.5 withCompletion:^(BOOL finished) {
            [firstTimeInstructionsButton setHidden:YES];
            [self performSelector:@selector(reshowFirstTimeInstructions:) withObject:dismissedStage afterDelay:FTUE_REDISPLAY_TIMER];
        }];
    }
}

-(void)toggleFirstTimePointer:(BOOL)showPointer atStage:(int)firstTimeUserStage {
#if SHOW_ARROW
    showMallPointer = showPointer;
    if (showPointer && !pointerWasDismissed)
        [self doPointerAnimation:firstTimeUserStage];
#endif
}

-(void)displayFirstTimeUserProgress:(int)firstTimeUserStage {
    tickID++;
    
    switch (firstTimeUserStage) {
        case FIRSTTIME_DONE:
            return;
            break;
            
        case FIRSTTIME_MESSAGE_01:
        {
            if (firstTimeInstructions == nil)
                [self addFirstTimeInstructions];
            //UIImage * img1 = [UIImage imageNamed:@"firsttime_message_01.png"];
            UIImage * img = [UIImage imageNamed:@"graphic_FTUE_callout"];
            firstTimeInstructionsFrame = CGRectMake(60, 370, img.size.width+25, img.size.height);
            [firstTimeInstructions setFrame:firstTimeInstructionsFrame];
            [firstTimeInstructions setImage:img];// forState:UIControlStateNormal];
            [firstTimeInstructionsLabel setFrame:CGRectMake(0, 0, firstTimeInstructionsFrame.size.width, firstTimeInstructionsFrame.size.height-30)];
            [firstTimeInstructionsLabel setText:@"Take your first Pix"];
            [firstTimeInstructionsButton setFrame:CGRectMake(firstTimeInstructionsFrame.origin.x, firstTimeInstructionsFrame.origin.y,firstTimeInstructionsFrame.size.width, firstTimeInstructionsFrame.size.height-30)];
            //pointerWasDismissed = NO;
            // end old one
            //[self toggleFirstTimeInstructions:NO];
            //[self toggleFirstTimePointer:NO atStage:firstTimeUserStage];
            // start new one
            [self toggleFirstTimeInstructions:YES];
            //[self toggleFirstTimePointer:YES atStage:firstTimeUserStage];
            //instructionsDismissed = NO;
        }
            break;
            
        case FIRSTTIME_MESSAGE_02:
        {
            firstTimeInstructions = nil; // prevent it from popping back up
            firstTimeInstructionsButton = nil;
            /*
            if (firstTimeInstructions == nil)
                [self addFirstTimeInstructions];
            UIImage * img = [UIImage imageNamed:@"graphic_FTUE_callout"];
            firstTimeInstructionsFrame = CGRectMake(60, 330, img.size.width+25, img.size.height+20);
            [firstTimeInstructions setImage:img forState:UIControlStateNormal];
            [firstTimeInstructions setFrame:firstTimeInstructionsFrame];
            [firstTimeInstructionsLabel setText:@"Remix anyone's Pix!"];
            [firstTimeInstructionsLabel setFrame:CGRectMake(0, 0, firstTimeInstructionsFrame.size.width, firstTimeInstructionsFrame.size.height-30)];
            [self toggleFirstTimeInstructions:NO]; // don't show
            //instructionsDismissed = NO;
             */
        }
            break;
        
        case FIRSTTIME_MESSAGE_03:
        {
            if (firstTimeInstructions == nil)
                [self addFirstTimeInstructions];
            //UIImage * img3 = [UIImage imageNamed:@"firsttime_message_03.png"];
            UIImage * img = [UIImage imageNamed:@"graphic_FTUE_callout_side"];
            firstTimeInstructionsFrame = CGRectMake(135, 370, img.size.width+25, img.size.height);
            [firstTimeInstructions setFrame:firstTimeInstructionsFrame];
            [firstTimeInstructions setImage:img];// forState:UIControlStateNormal];
            [firstTimeInstructionsLabel setFrame:CGRectMake(0, 0, firstTimeInstructionsFrame.size.width, firstTimeInstructionsFrame.size.height-30)];
            [firstTimeInstructionsLabel setText:@"Find your Friends"];
            [firstTimeInstructionsButton setFrame:CGRectMake(firstTimeInstructionsFrame.origin.x, firstTimeInstructionsFrame.origin.y,firstTimeInstructionsFrame.size.width, firstTimeInstructionsFrame.size.height-30)];
            [self toggleFirstTimeInstructions:YES];
        }
            break;
            
        default:
            break;
    }
}

-(void)agitateFirstTimePointer {
#if SHOW_ARROW
    agitatePointer = 3;
#endif
}

#pragma mark news count
-(void)setNewsCountValue:(int)newCount {
    //if (newCount == 0)
    //    [newsCount setHidden:YES];
    //else {
    //    [newsCount setHidden:NO];
    //    [newsCount setText:[NSString stringWithFormat:@"%d", newCount]];
    //}
    // display news callout
    if (!newsCallout) {
        newsCallout = [[UIButton alloc] init];
        UIImage * img = [UIImage imageNamed:@"graphic_FTUE_callout"];
        CGRect frame = CGRectMake(120, 330, img.size.width+25, img.size.height+20);
        [newsCallout setFrame:frame];
        [newsCallout setImage:img forState:UIControlStateNormal];
        newsCountLabel = [[UILabel alloc] init];
        [newsCountLabel setTextColor:[UIColor whiteColor]];
        [newsCountLabel setTextAlignment:UITextAlignmentCenter];
        [newsCountLabel setBackgroundColor:[UIColor clearColor]];
        [newsCountLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [newsCountLabel setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-30)];
        [newsCallout addSubview:newsCountLabel];
    }
    newsCount = newCount;
    [newsCountLabel setText:[NSString stringWithFormat:@"%d New Items", newsCount]];
}

-(void)displayNewsCount {
    if (newsCount > 0) {
        [self.view addSubview:newsCallout];
        StixAnimation * animation = [[StixAnimation alloc] init];
        [animation doFadeIn:newsCallout forTime:1.5 withCompletion:^(BOOL finished) {
            [self performSelector:@selector(hideNewsCount) withObject:self afterDelay:NEWSCOUNT_DISPLAY_TIMER];
        }];
    }
}
-(void)hideNewsCount {
    if (newsCallout) {
        //[newsCallout removeFromSuperview];
        StixAnimation * animation = [[StixAnimation alloc] init];
        [animation doFadeOut:newsCallout forTime:1.5 withCompletion:^(BOOL finished) {}];
    }
}
@end

