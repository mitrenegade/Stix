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
     
    [self.view setBackgroundColor:[UIColor redColor]];

    // hack: the tabbar is always 49px at the bottom. we need a 40px space at the bottom for the custom buttons. so extend the whole frame of the tabBarController by 9 pixels
    // but when frame height is manually changed it seems to ignore the status bar so we have to manually increase the y origin. in the end, the screen needs to be shrunk 10 pix (net increase 1 pix) and shifted down 20 pix, 
    CGRect frame = self.view.frame;
    frame.size.height += 1; // cannot be 0 because then status bar shift doesn't occur
    frame.origin.y += STATUS_BAR_SHIFT_OVERLAY;
    [self.view setFrame:frame];
     
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
    button[pos].frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    NSLog(@"Button %d size: %f %f image %x %f %f", pos, buttonImage.size.width, buttonImage.size.height, buttonImage, buttonImage.size.width, buttonImage.size.height);
    [button[pos] setBackgroundColor:[UIColor blackColor]];
    bgNormal[pos] = buttonImage;
    bgSelected[pos] = highlightImage;
    [button[pos] setBackgroundImage:bgNormal[pos] forState:UIControlStateNormal];
    if (highlightImage)
        [button[pos] setBackgroundImage:bgSelected[pos] forState:UIControlStateHighlighted];

    CGPoint center;
    if (pos < TABBAR_BUTTON_TAG) {
        center = CGPointMake(BUTTON_WIDTH * pos + BUTTON_WIDTH/2, 480-(BUTTON_HEIGHT/2));
        NSLog(@"Center %d: %f %f", pos, center.x, center.y);
    }
    if (pos > TABBAR_BUTTON_TAG) {
        center = CGPointMake(320 - BUTTON_WIDTH * (TABBAR_BUTTON_MAX - pos) + BUTTON_WIDTH/2, 480 - (BUTTON_HEIGHT/2));
    }
    if (pos == TABBAR_BUTTON_TAG) 
        center = CGPointMake(160, 480 - (BUTTON_HEIGHT/2));
    button[pos].center = center;
    [button[pos] setTag:pos];
    [button[pos] addTarget:self
               action:@selector(didPressTabButton:)
     forControlEvents:UIControlEventTouchDown];
    CGRect frame = button[pos].frame;
    NSLog(@"Button %d: frame %f %f %f %f", pos, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    [self.view addSubview:button[pos]];
}

-(void)didGetProfilePhoto:(UIImage *)photo {
    CGPoint center = CGPointMake(320/2, 480-(BUTTON_HEIGHT/2)-20);
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
    [self.myDelegate didPressTabButton:pressedButton.tag];
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
    firstTimeInstructions = [[UIButton alloc] init];
    [firstTimeInstructions addTarget:self action:@selector(closeInstructions:) forControlEvents:UIControlEventTouchUpInside];
    [firstTimeInstructions setAdjustsImageWhenHighlighted:NO];
    [self.view addSubview:firstTimeInstructions];
    firstTimeInstructionsLabel = [[UILabel alloc] init];
    [firstTimeInstructionsLabel setTextColor:[UIColor whiteColor]];
    [firstTimeInstructionsLabel setTextAlignment:UITextAlignmentCenter];
    [firstTimeInstructionsLabel setBackgroundColor:[UIColor clearColor]];
    //[firstTimeInstructionsLabel setOutlineColor:[UIColor blackColor]];
    [firstTimeInstructionsLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [firstTimeInstructions addSubview:firstTimeInstructionsLabel];
    
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

-(IBAction)closeInstructions:(id)sender {
    [self toggleFirstTimeInstructions:NO];
    //instructionsDismissed = YES;
}

-(void)toggleFirstTimeInstructions:(BOOL)showInstructions {
    StixAnimation * animation = [[StixAnimation alloc] init];
    //CGRect frameOnscreen = firstTimeInstructionsFrame; //CGRectMake(5, 130, img1.size.width+25, img1.size.height+20);
    //CGRect frameOffscreen = frameOnscreen;
    //frameOffscreen.origin.y += 480;
    
    if (showInstructions) {
//        [animation doViewTransition:firstTimeInstructions toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished) {}];
        [animation doFadeIn:firstTimeInstructions forTime:.5 withCompletion:^(BOOL finished) {}];
    }
    else {
//        [animation doViewTransition:firstTimeInstructions toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {}];
        // must set dismissedStage before the delay
        NSNumber * dismissedStage = [NSNumber numberWithInt:[myDelegate getFirstTimeUserStage]];
        NSLog(@"Hiding first time instructions at stage %d", [myDelegate getFirstTimeUserStage]);
        [animation doFadeOut:firstTimeInstructions forTime:.5 withCompletion:^(BOOL finished) {
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
            firstTimeInstructionsFrame = CGRectMake(60, 330, img.size.width+25, img.size.height+20);
            [firstTimeInstructions setFrame:firstTimeInstructionsFrame];
            [firstTimeInstructions setImage:img forState:UIControlStateNormal];
            [firstTimeInstructionsLabel setFrame:CGRectMake(0, 0, firstTimeInstructionsFrame.size.width, firstTimeInstructionsFrame.size.height-30)];
            [firstTimeInstructionsLabel setText:@"Take your first Pix"];
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
            firstTimeInstructionsFrame = CGRectMake(135, 330, img.size.width+25, img.size.height+20);
            [firstTimeInstructions setFrame:firstTimeInstructionsFrame];
            [firstTimeInstructions setImage:img forState:UIControlStateNormal];
            [firstTimeInstructionsLabel setFrame:CGRectMake(0, 0, firstTimeInstructionsFrame.size.width, firstTimeInstructionsFrame.size.height-30)];
            [firstTimeInstructionsLabel setText:@"Find your Friends"];
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

