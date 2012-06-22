//
//  RaisedCenterTabBarController.m
//  Stixx
//
//  Created by Bobby Ren on 11/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RaisedCenterTabBarController.h"

@implementation RaisedCenterTabBarController

@synthesize myDelegate;

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{
    UIViewController* viewController = [[UIViewController alloc] init];
    viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    return viewController;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage atPosition:(int)pos
{
    if (pos>=TABBAR_BUTTON_MAX)
        return;
    
    button[pos] = [UIButton buttonWithType:UIButtonTypeCustom];
    button[pos].autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button[pos].frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    bgNormal[pos] = buttonImage;
    bgSelected[pos] = highlightImage;
    [button[pos] setBackgroundImage:bgNormal[pos] forState:UIControlStateNormal];
    if (highlightImage)
        [button[pos] setBackgroundImage:bgSelected[pos] forState:UIControlStateHighlighted];
    
    CGPoint center = self.tabBar.center;
    if (pos == TABBAR_BUTTON_FEED)
        center.x = buttonImage.size.width/2;
    else if (pos == TABBAR_BUTTON_EXPLORE)
        center.x = 320 - buttonImage.size.width/2;    
    else if (pos == TABBAR_BUTTON_TAG) {
        center.y = center.y - 3;
    }
    button[pos].center = center;
    [button[pos] setTag:pos];
    [button[pos] addTarget:self
               action:@selector(didPressTabButton:)
     forControlEvents:UIControlEventTouchDown];

    [self.view addSubview:button[pos]];
}

-(IBAction)closeInstructions:(id)sender {
    [self toggleFirstTimeInstructions:NO];
    //[myDelegate didCloseFirstTimeMessage];
//    [self toggleFirstTimePointer:NO atStage:0];
//    pointerWasDismissed = YES;
    instructionsDismissed = YES;
}

-(void)flashFirstTimeInstructions {
    // briefly show instructions again
    if (instructionsDismissed) {
        [self toggleFirstTimeInstructions:YES];
        //[self performSelector:@selector(closeInstructions:) withObject:nil afterDelay:1.5];
    }
}

-(void)addFirstTimeInstructions {
#if 0
    UIImage * img1 = [UIImage imageNamed:@"message_firsttime_25.png"];
    UIImage * img3 = [UIImage imageNamed:@"btn_close.png"];
    firstTimeInstructions = [[UIImageView alloc] initWithImage:img1];
    buttonClose = [[UIButton alloc] init];
    [buttonClose setImage:img3 forState:UIControlStateNormal];
    
    [firstTimeInstructions setFrame:CGRectMake(5, 30, img1.size.width+25, img1.size.height+20)];
    [buttonClose setFrame:CGRectMake(0, 22, img3.size.width, img3.size.height)];
    
    [buttonClose addTarget:self action:@selector(closeInstructions:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:firstTimeInstructions];
    [self.view addSubview:buttonClose];
    [self toggleFirstTimeInstructions:YES];
#else
    UIImage * img1 = [UIImage imageNamed:@"firsttime_message_01.png"];
    //UIImage * img2 = [UIImage imageNamed:@"firsttime_message_02.png"];
    //UIImage * img3 = [UIImage imageNamed:@"firsttime_message_03.png"];
    firstTimeInstructions = [[UIButton alloc] initWithFrame:CGRectMake(5, 130, img1.size.width+25, img1.size.height+20)];
    [firstTimeInstructions addTarget:self action:@selector(closeInstructions:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:firstTimeInstructions];
    [self toggleFirstTimeInstructions:NO];
#endif
}

-(void)doPointerAnimation:(int)firstTimeUserStage {
    UIImage * pointerImg = [UIImage imageNamed:@"orange_arrow.png"];
    CGRect canvasFrame = CGRectMake(160-pointerImg.size.width/2, 375, pointerImg.size.width, pointerImg.size.height);
    if (firstTimeUserStage == FIRSTTIME_MESSAGE_01) {
        canvasFrame = CGRectMake(160-pointerImg.size.width/2, 375, pointerImg.size.width, pointerImg.size.height);
    }
    else if (firstTimeUserStage == FIRSTTIME_MESSAGE_02) {
        canvasFrame = CGRectMake(50-pointerImg.size.width/2, 335, pointerImg.size.width, pointerImg.size.height);
    }
    else if (firstTimeUserStage == FIRSTTIME_MESSAGE_03) {
        canvasFrame = CGRectMake(295-pointerImg.size.width/2, 75, pointerImg.size.width, pointerImg.size.height);
    }
    UIView * pointerCanvas = [[UIView alloc] initWithFrame:canvasFrame];
    UIImageView * pointer = [[UIImageView alloc] initWithImage:pointerImg];
    if (firstTimeUserStage == FIRSTTIME_MESSAGE_03) {
        pointer.transform = CGAffineTransformMakeRotation(3.141592);
    }
    [pointerCanvas addSubview:pointer];
    agitatePointer = 0;
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    if (firstTimeUserStage == FIRSTTIME_MESSAGE_01 || firstTimeUserStage == FIRSTTIME_MESSAGE_03)
        mallPointerAnimationID = [animation doJump:pointerCanvas inView:self.view forDistance:20 forTime:1];
}

-(void)doRewardAnimation:(NSString*)title withAmount:(int)amount {
    return;
    /*
    int width = 100;
    rewardValue = amount;
    UIImage * coinImage = [UIImage imageNamed:@"bux_coin.png"];
    //CGRect canvasFrame = CGRectMake(190, 275, width, 100);
    CGRect canvasFrame = CGRectMake(5, 60, width, 100);
    UIView * rewardCanvas = [[UIView alloc] initWithFrame:canvasFrame];
    UIImageView * coinView = [[UIImageView alloc] initWithImage:coinImage];
    CGRect rewardNameFrame = CGRectMake(0, 60, width, 15);
    CGRect rewardAmountFrame = CGRectMake(0, 70, width, 35);
    OutlineLabel * rewardName = [[OutlineLabel alloc] initWithFrame:rewardNameFrame];
    OutlineLabel * rewardAmount = [[OutlineLabel alloc] initWithFrame:rewardAmountFrame];
    [rewardName setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [rewardName setOutlineColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    [rewardName setFontSize:12];
    [rewardAmount setTextColor:[UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1]];
    [rewardAmount setOutlineColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    [rewardAmount setFontSize:20];
    [rewardName setText:title];
    [rewardAmount setText:[NSString stringWithFormat:@"+%d BUX", amount]];

    [rewardCanvas addSubview:coinView];
    [rewardCanvas addSubview:rewardName];
    [rewardCanvas addSubview:rewardAmount];
    [coinView setCenter:CGPointMake(canvasFrame.size.width/2, coinView.center.y)];
    [rewardName setCenter:CGPointMake(canvasFrame.size.width/2, rewardName.center.y)];
    [rewardAmount setCenter:CGPointMake(canvasFrame.size.width/2, rewardAmount.center.y)];
    

    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    allAnimationIDs[0] = [animation doJump:rewardCanvas inView:self.view forDistance:15 forTime:.25];
     */
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
    for (int i=0; i<3; i++){
        if (pos == i)
            [button[i] setBackgroundImage:bgSelected[i] forState:UIControlStateNormal];        
        else
            [button[i] setBackgroundImage:bgNormal[i] forState:UIControlStateNormal];
    }
}
-(void)setButtonStateNormal:(int)pos {
    [button[pos] setBackgroundImage:bgNormal[pos] forState:UIControlStateNormal];
}

-(void)toggleFirstTimeInstructions:(BOOL)showInstructions {
    StixAnimation * animation = [[StixAnimation alloc] init];
    UIImage * img1 = [UIImage imageNamed:@"firsttime_message_01.png"];
    CGRect frameOnscreen = CGRectMake(5, 130, img1.size.width+25, img1.size.height+20);
    CGRect frameOffscreen = frameOnscreen;
    frameOffscreen.origin.y += 480;
    
    if (showInstructions) {
        //[firstTimeInstructions setFrame:frameOffscreen];
        [animation doViewTransition:firstTimeInstructions toFrame:frameOnscreen forTime:.25 withCompletion:^(BOOL finished) {
        }];
    }
    else {
        //[firstTimeInstructions setFrame:frameOnscreen];
        [animation doViewTransition:firstTimeInstructions toFrame:frameOffscreen forTime:.25 withCompletion:^(BOOL finished) {
        }];
    }
//    [firstTimeInstructions setHidden:!showInstructions];
    [buttonClose setHidden:!showInstructions];
}

-(void)toggleFirstTimePointer:(BOOL)showPointer atStage:(int)firstTimeUserStage {
    showMallPointer = showPointer;
    if (showPointer && !pointerWasDismissed)
        [self doPointerAnimation:firstTimeUserStage];
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
            UIImage * img1 = [UIImage imageNamed:@"firsttime_message_01.png"];
            [firstTimeInstructions setImage:img1 forState:UIControlStateNormal];
            pointerWasDismissed = NO;
            // end old one
            [self toggleFirstTimeInstructions:NO];
            [self toggleFirstTimePointer:NO atStage:firstTimeUserStage];
            // start new one
            [self toggleFirstTimeInstructions:YES];
            [self toggleFirstTimePointer:YES atStage:firstTimeUserStage];
            instructionsDismissed = NO;
        }
            break;
            
        case FIRSTTIME_MESSAGE_02:
        {
            if (firstTimeInstructions == nil)
                [self addFirstTimeInstructions];
            UIImage * img2 = [UIImage imageNamed:@"firsttime_message_02.png"];
            [firstTimeInstructions setImage:img2 forState:UIControlStateNormal];
            pointerWasDismissed = NO;
            // end old one
            [self toggleFirstTimeInstructions:NO];
            [self toggleFirstTimePointer:NO atStage:firstTimeUserStage];
            // start new one
            [self toggleFirstTimeInstructions:YES];
            [self toggleFirstTimePointer:YES atStage:firstTimeUserStage];
            instructionsDismissed = NO;
        }
            break;
        
        case FIRSTTIME_MESSAGE_03:
        {
            if (firstTimeInstructions == nil)
                [self addFirstTimeInstructions];
            UIImage * img3 = [UIImage imageNamed:@"firsttime_message_03.png"];
            [firstTimeInstructions setImage:img3 forState:UIControlStateNormal];
            pointerWasDismissed = NO;
            // end old one
            [self toggleFirstTimeInstructions:NO];
            [self toggleFirstTimePointer:NO atStage:firstTimeUserStage];
            // start new one
            //[self toggleFirstTimeInstructions:YES];
            //[self toggleFirstTimePointer:YES atStage:firstTimeUserStage];
            instructionsDismissed = NO;
        }
            break;
            
        default:
            break;
    }
}

-(void)agitateFirstTimePointer {
    agitatePointer = 3;
}
@end

