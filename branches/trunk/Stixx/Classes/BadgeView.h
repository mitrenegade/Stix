//
//  BadgeView.h
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//BadgeView

#import <UIKit/UIKit.h>
#import "OutlineLabel.h"

enum {
    BADGE_TYPE_FIRE = 0,
    BADGE_TYPE_ICE,
    BADGE_TYPE_HEART,
    BADGE_TYPE_LEAF,
    BADGE_TYPE_MAX
};

#define BADGE_SHELF_PADDING 20 // how many pixels per side on shelf

@protocol BadgeViewDelegate

-(void)didDropStix:(UIImageView *)badge ofType:(int)type;
-(int)getStixCount:(int)stix_type;
-(int)getStixLevel;

@optional
-(void)didStartDrag;
@end

@interface BadgeView : UIView {// <UIScrollViewDelegate>{
	NSMutableArray * badges;
	NSMutableArray * badgeLocations; // original frame of each badge
	NSMutableArray * badgesLarge;
	
	UIImageView * badgeTouched;
	UIImageView * badgeTouchedLarge;
	int drag;
	int badgeSelect;
	CGFloat offset_from_center_X; // offset of touch point from center of icno
	CGFloat offset_from_center_Y;
	
	NSObject<BadgeViewDelegate> *delegate;
	UIView * underlay; // pointer to a sibling view of the badgeView owned by its superview's controller - for hittest
    
    NSMutableArray * labels;
    //OutlineLabel * labelFire;
    //OutlineLabel * labelIce;
    
    bool showStixCounts;
    bool showRewardStix;
    int lastStixLevel;
}

@property (nonatomic, assign) NSObject<BadgeViewDelegate> *delegate;
@property (nonatomic, assign) UIView * underlay;
//@property (nonatomic, retain) OutlineLabel * labelFire;
//@property (nonatomic, retain) OutlineLabel * labelIce;
@property (nonatomic, assign) bool showStixCounts;
@property (nonatomic, assign) bool showRewardStix;
@property (nonatomic, retain) NSMutableArray * badgesLarge; // access allowed

-(void)resetBadgeLocations;
-(UIImage * )composeImage:(UIImage *) baseImage withOverlay:(UIImage *) overlayImage;
-(void)updateStixCounts;
-(int)getOppositeBadgeType:(int)type;
+(int)getOutlineOffsetX:(int) type;
+(int)getOutlineOffsetY:(int) type;

// for displaying badges
+(UIImageView *) getBadgeOfType:(int)type;
+(UIImageView *) getLargeBadgeOfType:(int)type;
+(UIImageView *) getEmptyBadgeOfType:(int)type;
+(NSMutableArray *) generateDefaultStix;
@end
