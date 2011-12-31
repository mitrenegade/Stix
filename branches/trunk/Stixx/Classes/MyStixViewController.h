//
//  MyStixViewController.h
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "GiftStixTableController.h"
#import "CarouselView.h"

@protocol MyStixViewDelegate

- (NSString*)getUsername;

// forward from BadgeViewDelegate
-(int)getStixCount:(NSString*)stixStringID;
-(void)didCreateBadgeView:(UIView*)newBadgeView;

@end

@interface MyStixViewController : UIViewController <BadgeViewDelegate, GiftStixTableControllerDelegate> {
    BadgeView * badgeView;
    NSMutableArray * badges;
    NSMutableArray * labels;
    NSMutableArray * empties;
    
    UIButton * buttonRules;
    
    GiftStixTableController * tableController;
    CarouselView * carouselView;

    NSObject<MyStixViewDelegate> * delegate;
}

@property (nonatomic, retain) BadgeView * badgeView;
@property (nonatomic, retain) CarouselView * carouselView;
@property (nonatomic, assign) NSObject<MyStixViewDelegate> * delegate;
@property (nonatomic, retain) UIButton * buttonRules;
@property (nonatomic, retain) GiftStixTableController * tableController;
-(IBAction)didClickOnButtonRules:(id)sender;
-(void)createCarouselView;
@end
