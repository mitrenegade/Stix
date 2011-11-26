//
//  BadgeViewController.h
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//BadgeView

#import <UIKit/UIKit.h>

@protocol BadgeViewDelegate

-(void)addTag:(UIImageView *)badge;

@end

@interface BadgeViewController : UIViewController <UIScrollViewDelegate>{
	NSMutableArray * badges;
	NSMutableArray * badgeLocations; // original frame of each badge
	IBOutlet UIImageView *badgeFire;
	IBOutlet UIImageView *badgeIce;
	NSMutableArray * badgesLarge;
	NSMutableArray * badgesShadow;
	
	IBOutlet UIImageView *shelf;
	
	UIImageView * badgeTouched;
	UIImageView * badgeTouchedLarge;
	int drag;
	int badgeSelect;
	CGFloat offset_from_center_X; // offset of touch point from center of icno
	CGFloat offset_from_center_Y;
	
	NSObject<BadgeViewDelegate> *delegate;
	UIView * underlay; // pointer to a sibling view of the badgeView owned by its superview's controller - for hittest
}

@property (nonatomic, assign) NSObject<BadgeViewDelegate> *delegate;
@property (nonatomic, assign) UIView * underlay;

-(void)resetBadgeLocations;
-(UIImage * )composeImage:(UIImage *) baseImage withOverlay:(UIImage *) overlayImage;
@end
