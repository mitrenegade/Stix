//
//  MyStixViewController.h
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"

@protocol MyStixViewDelegate

- (NSString*)getUsername;

// forward from BadgeViewDelegate
-(int)getStixCount:(int)stix_type; // may be needed for one time use stix
-(void)didCreateBadgeView:(UIView*)newBadgeView;

@end

@interface MyStixViewController : UIViewController <BadgeViewDelegate> {
    BadgeView * badgeView;
    NSMutableArray * badges;

    NSObject<MyStixViewDelegate> * delegate;
}

@property (nonatomic, retain) BadgeView * badgeView;
@property (nonatomic, assign) NSObject<MyStixViewDelegate> * delegate;

-(void)forceLoadMyStix;
@end
