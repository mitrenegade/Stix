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

-(void)didPressTabButton:(int)pos;
//-(void)didCloseFirstTimeInstructions;
@end

enum {
    TABBAR_BUTTON_FEED = 0,
    TABBAR_BUTTON_TAG,
    TABBAR_BUTTON_EXPLORE,
    TABBAR_BUTTON_MAX
};

@interface RaisedCenterTabBarController : UITabBarController <StixAnimationDelegate>
{
    NSObject<RaisedCenterTabBarControllerDelegate> *myDelegate;
    
    UIButton * button[3];
    UIImage * bgNormal[3];
    UIImage * bgSelected[3];
    
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
-(void) addButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage atPosition:(int)pos;
-(void) addFirstTimeInstructions;
-(IBAction)didPressTabButton:(id)sender;
-(void)setButtonStateSelected:(int)pos;
-(void)setButtonStateNormal:(int)pos;
-(void)toggleFirstTimeInstructions:(BOOL)showInstructions;
-(void)toggleStixMallPointer:(BOOL)showPointer;
-(IBAction)closeInstructions:(id)sender;
-(void)doRewardAnimation:(NSString *)title withAmount:(int)amount;
-(void)doPointerAnimation;
-(void)doPurchaseAnimation:(NSString*)stixStringID;
@end
