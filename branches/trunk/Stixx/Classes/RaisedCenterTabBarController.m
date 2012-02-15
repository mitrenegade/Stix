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
    [self.myDelegate didCloseFirstTimeInstructions];
}

-(void)addFirstTimeInstructions {
    UIImage * img1 = [UIImage imageNamed:@"message_firsttime_25.png"];
    UIImage * img2 = [UIImage imageNamed:@"green_arrow.png"];
    UIImage * img3 = [UIImage imageNamed:@"btn_close.png"];
    firstTimeInstructions = [[UIImageView alloc] initWithImage:img1];
    firstTimeMallPointer = [[UIImageView alloc] initWithImage:img2];
    buttonClose = [[UIButton alloc] init];
    [buttonClose setImage:img3 forState:UIControlStateNormal];
    
    [firstTimeInstructions setFrame:CGRectMake(5, 30, img1.size.width+25, img1.size.height+20)];
    [firstTimeMallPointer setFrame:CGRectMake(200, 375, img2.size.width, img2.size.height)];
    [buttonClose setFrame:CGRectMake(0, 22, img3.size.width, img3.size.height)];
    
    [buttonClose addTarget:self action:@selector(closeInstructions:) forControlEvents:UIControlEventTouchUpInside];
    [self toggleFirstTimeInstructions:NO];
    [self toggleStixMallPointer:NO];
        
    [self.view addSubview:firstTimeInstructions];
    [self.view addSubview:firstTimeMallPointer];
    [self.view addSubview:buttonClose];
    [self addPointerAnimationUp];
}

-(void)addPointerAnimationUp {
    CGRect endFrame = firstTimeMallPointer.frame;
    endFrame.origin.y -= 20;
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         firstTimeMallPointer.frame = endFrame;
                     } 
                     completion:^(BOOL finished){
                         firstTimeMallPointer.frame = endFrame;
                         [self addPointerAnimationDown];
                     }];  
}
-(void)addPointerAnimationDown {
    CGRect endFrame = firstTimeMallPointer.frame;
    endFrame.origin.y += 20;
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         firstTimeMallPointer.frame = endFrame;
                     } 
                     completion:^(BOOL finished){
                         firstTimeMallPointer.frame = endFrame;
                         [self addPointerAnimationUp];
                     }];  
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
    [firstTimeMallPointer setHidden:!showPointer];
}

@end

