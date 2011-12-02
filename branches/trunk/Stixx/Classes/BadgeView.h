//
//  BadgeView.h
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//BadgeView

#import <UIKit/UIKit.h>
#import "OutlineLabel.h"

#define BADGE_TYPE_FIRE 0
#define BADGE_TYPE_ICE 1
#define OUTLINELABEL_X_OFFSET -5
#define OUTLINELABEL_Y_OFFSET 10

@protocol BadgeViewDelegate

-(void)didDropStix:(UIImageView *)badge ofType:(int)type;
-(int)getStixCount:(int)stix_type;

@optional
-(void)didStartDrag;
@end

@interface BadgeView : UIView {// <UIScrollViewDelegate>{
	NSMutableArray * badges;
	NSMutableArray * badgeLocations; // original frame of each badge
	//IBOutlet UIImageView *badgeFire;
	//IBOutlet UIImageView *badgeIce;
	NSMutableArray * badgesLarge;
	NSMutableArray * badgesShadow;
	
	//IBOutlet UIImageView *shelf;
	
	UIImageView * badgeTouched;
	UIImageView * badgeTouchedLarge;
	int drag;
	int badgeSelect;
	CGFloat offset_from_center_X; // offset of touch point from center of icno
	CGFloat offset_from_center_Y;
	
	NSObject<BadgeViewDelegate> *delegate;
	UIView * underlay; // pointer to a sibling view of the badgeView owned by its superview's controller - for hittest
    
//    int countFire;
//    int countIce;
    NSMutableArray * labels;
    OutlineLabel * labelFire;
    OutlineLabel * labelIce;
    
    bool showStixCounts;
    
}

@property (nonatomic, assign) NSObject<BadgeViewDelegate> *delegate;
@property (nonatomic, assign) UIView * underlay;
//@property (nonatomic, retain) IBOutlet UIImageView * badgeFire;
//@property (nonatomic, retain) IBOutlet UIImageView * badgeIce;
//@property (nonatomic, retain) IBOutlet UIImageView * shelf;
@property (nonatomic, retain) OutlineLabel * labelFire;
@property (nonatomic, retain) OutlineLabel * labelIce;
@property (nonatomic, assign) bool showStixCounts;

-(void)resetBadgeLocations;
-(UIImage * )composeImage:(UIImage *) baseImage withOverlay:(UIImage *) overlayImage;
-(void)updateStixCounts;
-(int)getOppositeBadgeType:(int)type;

// for displaying badges
+(UIImageView *) getBadgeOfType:(int)type;
@end
