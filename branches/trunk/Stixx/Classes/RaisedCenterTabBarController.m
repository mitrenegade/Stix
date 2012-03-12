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
    UIViewController* viewController = [[[UIViewController alloc] init] autorelease];
    viewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
    return viewController;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    bgNormal = [buttonImage retain];
    bgSelected = [highlightImage retain];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - 6;
        // debug - to reveal regular tab button too
        //center.y = center.y - 30;
        button.center = center;
    }
    [button addTarget:self
               action:@selector(didPressCenterButton:)
     forControlEvents:UIControlEventTouchDown];

    [self.view addSubview:button];
}

-(IBAction)closeInstructions:(id)sender {
    [self toggleFirstTimeInstructions:NO];
}

-(void)addFirstTimeInstructions {
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
    [self toggleStixMallPointer:YES];
        
}

-(void)doPointerAnimation {
    UIImage * pointerImg = [UIImage imageNamed:@"green_arrow.png"];
    CGRect canvasFrame = CGRectMake(200, 375, pointerImg.size.width, pointerImg.size.height);
    UIView * pointerCanvas = [[UIView alloc] initWithFrame:canvasFrame];
    UIImageView * pointer = [[UIImageView alloc] initWithImage:pointerImg];
    [pointerCanvas addSubview:pointer];
    [pointer release];
    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    mallPointerAnimationID = [animation doJump:pointerCanvas inView:self.view forDistance:20 forTime:1];
    [pointerCanvas release];
    [animation release];
}

-(void)doRewardAnimation:(NSString*)title withAmount:(int)amount {
    int width = 100;
    UIImage * coinImage = [UIImage imageNamed:@"bux_coin.png"];
    CGRect canvasFrame = CGRectMake(190, 275, width, 100);
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
    
    [coinView release];
    [rewardName release];
    [rewardAmount release];

    StixAnimation * animation = [[StixAnimation alloc] init];
    animation.delegate = self;
    allAnimationIDs[0] = [animation doJump:rewardCanvas inView:self.view forDistance:15 forTime:.5];
    [rewardCanvas release];
    [animation release];
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
    [rewardCanvas release];
    [animation release];
}

-(void)didFinishAnimation:(int)animationID withCanvas:(UIView *)canvas{
    NSLog(@"Animation %d finished!", animationID);
    [canvas retain]; // animations autorelease the canvas they are sent
    /* reward animations */
    if (animationID == allAnimationIDs[0]) // first jump animation finished
    {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        allAnimationIDs[1] = [animation doJump:canvas inView:self.view forDistance:15 forTime:.5];
        [animation release];
    }
    else if (animationID == allAnimationIDs[1]) // second jump animation finished
    {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        allAnimationIDs[2] = [animation doJump:canvas inView:self.view forDistance:15 forTime:.5];
        [animation release];
    }
    else if (animationID == allAnimationIDs[2]) // first animation finished
    {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        allAnimationIDs[3] = [animation doDownwardFade:canvas inView:self.view forDistance:100 forTime:1];
        [animation release];
    }
    
    /* first time mall pointer */
    if (animationID == mallPointerAnimationID) // first jump animation finished
    {
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        if (showMallPointer)
            mallPointerAnimationID = [animation doJump:canvas inView:self.view forDistance:20 forTime:1];
        else {
            [canvas removeFromSuperview];
        }
        [animation release];
    }
    
    /* purchase stix */
    if (animationID == animationIDsPurchase[0]) { // fade in finished
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        animationIDsPurchase[1] = [animation doJump:canvas inView:self.view forDistance:15 forTime:.5];
        [animation release];
    }
    else if (animationID == animationIDsPurchase[1]) { // first jump finished
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        animationIDsPurchase[2] = [animation doJump:canvas inView:self.view forDistance:15 forTime:.5];
        [animation release];
    }
    else if (animationID == animationIDsPurchase[2]) { // second jump finished
        StixAnimation * animation = [[StixAnimation alloc] init];
        animation.delegate = self;
        animationIDsPurchase[3] = [animation doDownwardFade:canvas inView:self.view forDistance:300 forTime:1.5];
        [animation release];
    }
    else if (animationID == animationIDsPurchase[3]) {
        [canvas removeFromSuperview];
    }

    [canvas release];
}


/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}
*/
-(IBAction)didPressCenterButton:(id)sender {
    [self.myDelegate didPressCenterButton];
}

// these functions are called by the app delegate - when the tabbar state changes
-(void)setButtonStateSelected {
    [button setBackgroundImage:bgSelected forState:UIControlStateNormal];
}
-(void)setButtonStateNormal {
    [button setBackgroundImage:bgNormal forState:UIControlStateNormal];
}

-(void)toggleFirstTimeInstructions:(BOOL)showInstructions {
    [firstTimeInstructions setHidden:!showInstructions];
    [buttonClose setHidden:!showInstructions];
}

-(void)toggleStixMallPointer:(BOOL)showPointer {
    showMallPointer = showPointer;
    if (showPointer)
        [self doPointerAnimation];
}

@end

