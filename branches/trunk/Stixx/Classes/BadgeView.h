//
//  BadgeView.h
//  ARKitDemo
//
//  Created by Administrator on 6/14/11.
//  Copyright 2011 Neroh. All rights reserved.
//BadgeView

//
// BadgeView is a static draggable toolbox consisting of the two main stix:
// fire stix and ice stix. It will always be located on the bottom of the screen
// and be in the middle of the shelf. CarouselView is an extension of BadgeView
// that allows gift stix to be included, and thus uses a changeable scrollview
// to house all the different stix.
//
// There are functions in badgeview to do other basic things such as load all
// the stix imageviews, whether it is from disk or from kumulos.

#import <UIKit/UIKit.h>
#import "OutlineLabel.h"

// Not used for kumulos based stix
enum {
    BADGE_TYPE_FIRE = 0,
    BADGE_TYPE_ICE,
    BADGE_TYPE_HEART,
    BADGE_TYPE_LEAF,
    BADGE_TYPE_BOMB,
    BADGE_TYPE_BULB,
    BADGE_TYPE_DEAL,
    BADGE_TYPE_EYES,
    BADGE_TYPE_GLASSES,
    BADGE_TYPE_LIPS,
    BADGE_TYPE_PARTYHAT,
    BADGE_TYPE_SMILE,
    BADGE_TYPE_STACHE,
    BADGE_TYPE_STAR,
    BADGE_TYPE_SUN,
    BADGE_TYPE_MAX
};

#define BADGE_SHELF_PADDING 20 // how many pixels per side on shelf

@protocol BadgeViewDelegate

-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;

@optional

-(void)didDropStix:(UIImageView *)badge ofType:(NSString*)stixStringID;
-(void)didStartDrag;
@end

@interface BadgeView : UIView {// <UIScrollViewDelegate>{
    
	NSMutableArray * badges;
	NSMutableArray * badgeLocations; // original frame of each badge
	NSMutableArray * badgesLarge;
	
	UIImageView * badgeTouched; // the stix on the carousel (at whatever size the carousel is)
	UIImageView * badgeLifted; // what a stix looks like in the correct context
    UIImageView * shelf;
    
	int drag;
    int badgeSelect; // id into the badgesLarge and locations arrays
    NSString * selectedStixStringID; // replaces badgeSelect for stringID based stix
    
	CGFloat offset_from_center_X; // offset of touch point from center of icno
	CGFloat offset_from_center_Y;
	
	NSObject<BadgeViewDelegate> *delegate;
	UIView * underlay; // pointer to a sibling view of the badgeView owned by its superview's controller - for hitTest
    
    //NSMutableArray * labels;
    
    bool showStixCounts;
}

@property (nonatomic, assign) NSObject<BadgeViewDelegate> *delegate;
@property (nonatomic, assign) UIView * underlay;
@property (nonatomic, assign) bool showStixCounts;
@property (nonatomic, retain) NSMutableArray * badgesLarge; // access allowed
@property (nonatomic, retain) UIImageView * shelf;
@property (nonatomic, assign) NSString * selectedStixStringID;

-(void)resetBadgeLocations;
//-(void)updateStixCounts;
+(int)getOutlineOffsetX:(int) type;
+(int)getOutlineOffsetY:(int) type;

// The methods used to determine what Stix type exists, and how to find them

// this must be called at the very beginning. Retrieves the list of Stix currently in
// existence by their StringIDs (FIRE, ICE, GLASSES, STAR_GOLD, etc).
// populates the static variable stixStringIDs from an array from the delegate
// which calls kumulos beforehand to retrieve these values.
+(void)InitializeGenericStixTypes;
+(void)InitializeStixTypes:(NSArray*)stixStringIDsFromKumulos;
+(void)InitializeStixViews:(NSArray*)stixViewsFromKumulos;
+(int)totalStixTypes;
+(void)InitializeFromDiskWithStixViews:(NSMutableDictionary *)savedStixViews andStixDescriptors:(NSMutableDictionary *)savedStixDescriptors andStixLikelihoods:(NSMutableDictionary*)savedStixLikelihoods;

// returns stixStringID for given badge type. THIS IS DONE FOR BACKWARD COMPATIBILITY.
// Type is still drawn from a static list by some old builds.
+(NSArray *)stixStringIDs;

// returns a human readable string for each Stix
+(NSString *)getStixDescriptorForStixStringID:(NSString*)stixStringID;

// for displaying badges
+(UIImageView *) getBadgeWithStixStringID:(NSString*)stixStringID;
+(UIImageView *) getLargeBadgeWithStixStringID:(NSString*)stixStringID;
+(NSMutableDictionary *) generateDefaultStix;
+(NSMutableDictionary *) generateOneOfEachStix;
+(NSString*) getStixStringIDAtIndex:(int)index;
+(NSString*) getRandomStixStringID;
+(NSMutableArray *) getStixForCategory:(NSString*)categoryName;
+(NSMutableDictionary *)GetAllStixViewsForSave;
+(NSMutableDictionary *)GetAllStixDescriptorsForSave;
+(NSMutableDictionary *)GetAllStixLikelihoodsForSave;
+(void)AddStixView:(NSArray*)resultFromKumulos;

@end
