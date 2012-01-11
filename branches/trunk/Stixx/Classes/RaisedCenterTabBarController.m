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

@end

