//
//  ExploreViewController.h
//  Stixx
//
//  Created by Bobby Ren on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeView.h"

@interface ExploreViewController : UIViewController <BadgeViewDelegate> 
{
    BadgeView * badgeView; // for dragging and releasing badge

    UIScrollView *scrollView;	
	CGSize pageSize;
}

@property (nonatomic, retain) BadgeView * badgeView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, assign) CGSize pageSize;

- (void)initializeScroll;

@end
