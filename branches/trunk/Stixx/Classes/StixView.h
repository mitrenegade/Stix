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

@class StixView;

@protocol StixViewDelegate 
//-(void)didFinishScalingMotionWithScale:(float)scale;
@optional
-(NSString*) getUsername;
-(void)didAttachStix:(int)index;
-(void)didPeelStix:(int)index;
-(void)peelAnimationDidCompleteForStix:(int)index;
-(void)didTouchInStixView:(StixView*)stixViewTouched;
@end

@interface StixView : UIView <UIGestureRecognizerDelegate, UIActionSheetDelegate>
{
    // stix to be manipulated: new stix or new aux stix
    UIImageView * stix;
    OutlineLabel * stixCount;
    NSString * selectStixStringID;
    bool canManipulate;
    NSMutableArray * auxCanManipulate;
    bool isDragging;
    bool isPinching;
    bool isTap; // tap on stix
    bool isTouch; // touch on stixView
    float offset_x, offset_y;
    
    CGSize originalImageSize;

    // these refer to the current active stix
    //float stixScale;
    //float stixRotation;
    CGAffineTransform referenceTransform;

    bool interactionAllowed;
    float imageScale;
    
    bool isPeelable;
    
    NSMutableArray * auxStixViews;
    NSMutableArray * auxStixStringIDs;
    //NSMutableArray * auxScales; // needed for touch test
    NSMutableArray * auxPeelableByUser;
    
    int stixPeelSelected;
    
    bool showTransformCanvas;
    UIView * transformCanvas;

    NSObject<StixViewDelegate> * delegate;    
    NSMutableSet *_activeRecognizers;
}

@property (nonatomic, retain) UIImageView * stix;
@property (nonatomic, retain) OutlineLabel * stixCount;
@property (nonatomic, assign) bool interactionAllowed;
//@property (nonatomic, assign) float stixScale;
//@property (nonatomic, assign) float stixRotation;
@property (nonatomic, retain) NSMutableArray * auxStixViews;
@property (nonatomic, retain) NSMutableArray * auxStixStringIDs;
@property (nonatomic, assign) bool isPeelable;
@property (nonatomic, assign) NSObject<StixViewDelegate> * delegate;
@property (nonatomic, assign) CGAffineTransform referenceTransform;
@property (nonatomic, copy) NSString * selectStixStringID;
@property (nonatomic, retain) NSNumber * tagID;


-(void)initializeWithImage:(UIImage*)imageData;
-(void)initializeWithImage:(UIImage*)imageData withContextFrame:(CGRect)contextFrame;
-(void)populateWithAuxStixFromTag:(Tag*)tag;
-(void)populateWithStixForManipulation:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y /*andScale:(float)scale andRotation:(float)rotation*/;
-(void)updateStixForManipulation:(NSString*)stixStringID;
-(bool)isStixPeelable:(int)index;
-(bool)isForeground:(CGPoint)point inStix:(UIImageView*)selectedStix;
-(void)doPeelAnimationForStix:(int)index;

-(int)findPeelableStixAtLocation:(CGPoint)location;
-(void)transformBoxShowAtFrame:(CGRect)frame;
@end
