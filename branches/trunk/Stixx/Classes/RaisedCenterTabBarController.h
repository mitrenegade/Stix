//
//  RaisedCenterTabBarController.h
//  Stixx
//
//  Created by Bobby Ren on 11/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OutlineLabel.h"
#import "StixAnimation.h"
#import "BadgeView.h"

@protocol RaisedCenterTabBarControllerDelegate 

-(void)didPressCenterButton;
//-(void)didCloseFirstTimeInstructions;
@end

@interface RaisedCenterTabBarController : UITabBarController <StixAnimationDelegate>
{
    NSObject<RaisedCenterTabBarControllerDelegate> *myDelegate;
    
    UIButton * button;
    UIImage * bgNormal;
    UIImage * bgSelected;
    
    UIImageView * firstTimeInstructions;
    UIImageView * firstTimeMallPointer;
    bool showMallPointer;
    UIButton * buttonClose;
    
    int allAnimationIDs[4];
    int mallPointerAnimationID;
    int animationIDsPurchase[4];
}

@property (nonatomic, assign) NSObject<RaisedCenterTabBarControllerDelegate> *myDelegate;


// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*)title image:(UIImage*)image;

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;
-(void) addFirstTimeInstructions;
-(IBAction)didPressCenterButton:(id)sender;
-(void)setButtonStateSelected;
-(void)setButtonStateNormal;
-(void)toggleFirstTimeInstructions:(BOOL)showInstructions;
-(void)toggleStixMallPointer:(BOOL)showPointer;
-(IBAction)closeInstructions:(id)sender;
-(void)doRewardAnimation:(NSString *)title withAmount:(int)amount;
-(void)doPointerAnimation;
-(void)doPurchaseAnimation:(NSString*)stixStringID;
@end
