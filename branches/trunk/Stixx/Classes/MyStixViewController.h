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

@protocol MyStixViewDelegate

- (NSString*)getUsername;

// forward from BadgeViewDelegate
-(int)getStixCount:(int)stix_type; // may be needed for one time use stix
-(int)getStixLevel;
-(void)didCreateBadgeView:(UIView*)newBadgeView;

@end

@interface MyStixViewController : UIViewController <BadgeViewDelegate, GiftStixTableControllerDelegate> {
    BadgeView * badgeView;
    NSMutableArray * badges;
    NSMutableArray * labels;
    NSMutableArray * empties;
    
    UIButton * buttonRules;
    
    GiftStixTableController * tableController;

    NSObject<MyStixViewDelegate> * delegate;
}

@property (nonatomic, retain) BadgeView * badgeView;
@property (nonatomic, assign) NSObject<MyStixViewDelegate> * delegate;
@property (nonatomic, retain) UIButton * buttonRules;
@property (nonatomic, retain) GiftStixTableController * tableController;
-(void)forceLoadMyStix;
-(void)generateAllStix;
-(IBAction)didClickOnButtonRules:(id)sender;
@end
