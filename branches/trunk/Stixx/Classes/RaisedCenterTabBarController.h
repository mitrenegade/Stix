//
//  RaisedCenterTabBarController.h
//  Stixx
//
//  Created by Bobby Ren on 11/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@protocol RaisedCenterTabBarControllerDelegate 

-(void)didPressCenterButton;

@end

@interface RaisedCenterTabBarController : UITabBarController
{
    NSObject<RaisedCenterTabBarControllerDelegate> *myDelegate;
    
    UIButton * button;
    UIImage * bgNormal;
    UIImage * bgSelected;
}

@property (nonatomic, assign) NSObject<RaisedCenterTabBarControllerDelegate> *myDelegate;


// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*)title image:(UIImage*)image;

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

-(IBAction)didPressCenterButton:(id)sender;
-(void)setButtonStateSelected;
-(void)setButtonStateNormal;

@end
