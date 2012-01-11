//
//  StixView.h
//  Stixx
//
//  Created by Bobby Ren on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// specifies a UIImageView that is overlaid with multiple stix, which can be manipulated

#import <UIKit/UIKit.h>
#import "BadgeView.h"
#import "OutlineLabel.h"
#import "Tag.h"

@protocol StixViewDelegate 
//-(void)didFinishScalingMotionWithScale:(float)scale;
@end

@interface StixView : UIView <UIGestureRecognizerDelegate>
{
    UIImageView * stix;
    OutlineLabel * stixCount;
    bool canManipulate;
    NSMutableArray * auxCanManipulate;
    bool isDragging;
    bool isPinching;
    float offset_x, offset_y;

    float stixScale;
    CGRect frameBeforeScale;
    float stixRotation;

    bool interactionAllowed;
    float imageScale;
}

@property (nonatomic, retain) UIImageView * stix;
@property (nonatomic, retain) OutlineLabel * stixCount;
@property (nonatomic, assign) bool interactionAllowed;
@property (nonatomic, assign) float stixScale;
@property (nonatomic, assign) float stixRotation;

// could use this
-(void)initializeWithImage:(UIImage*)imageData andStix:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y andScale:(float)scale andRotation:(float)rotation;
-(void)populateWithAuxStix:(NSMutableArray *)auxStix withLocations:(NSMutableArray *)auxLocations withScales:(NSMutableArray *)auxScales withRotations:(NSMutableArray *)auxRotations;
@end
