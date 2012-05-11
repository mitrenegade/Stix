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
#import "Kumulos.h"
#import "StixAnimation.h"

@class StixView;

@protocol StixViewDelegate 
//-(void)didFinishScalingMotionWithScale:(float)scale;
-(void)didReceiveRequestedStixViewFromKumulos:(NSString*)stixStringID;
-(void)didReceiveAllRequestedMissingStix:(StixView*)stixView;
@optional
-(NSString*) getUsername;
-(NSString*) getUsernameOfApp;
-(void)didAttachStix:(int)index;
-(void)didPeelStix:(int)index;
-(void)peelAnimationDidCompleteForStix:(int)index;
-(void)didTouchInStixView:(StixView*)stixViewTouched;
-(void)needsRetainForDelegateCall;
-(void)doneWithAsynchronousDelegateCall;
@end

@interface StixView : UIView <UIGestureRecognizerDelegate, UIActionSheetDelegate, KumulosDelegate>
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
    
    NSString * stixPeelSelected;
    CGPoint stixPeelSelectedCenter;
    
    bool showTransformCanvas;
    UIView * transformCanvas;

    NSObject<StixViewDelegate> * __unsafe_unretained delegate;    
    NSMutableSet *_activeRecognizers;
    Kumulos * k;
    
    NSString * tagUsername;

    // key: stixStringID
    // value: array of all auxStix views of this type in this StixView
    // if at any point we've satisfied all stixStringIDs, repopulate this view
    NSMutableDictionary * stixViewsMissing;
    BOOL isShowingPlaceholder;
    
    BOOL isStillPeeling;
}

@property (nonatomic) UIImageView * stix;
@property (nonatomic) OutlineLabel * stixCount;
@property (nonatomic, assign) bool interactionAllowed;
//@property (nonatomic, assign) float stixScale;
//@property (nonatomic, assign) float stixRotation;
@property (nonatomic) NSMutableArray * auxStixViews;
@property (nonatomic) NSMutableArray * auxStixStringIDs;
@property (nonatomic, assign) bool isPeelable;
@property (nonatomic, unsafe_unretained) NSObject<StixViewDelegate> * delegate;
@property (nonatomic, assign) CGAffineTransform referenceTransform;
@property (nonatomic, copy) NSString * selectStixStringID;
@property (nonatomic) NSNumber * tagID;
@property (nonatomic, assign) int stixViewID;
@property (nonatomic, assign) BOOL isShowingPlaceholder;

-(void)initializeWithImage:(UIImage*)imageData;
-(void)initializeWithImage:(UIImage*)imageData withContextFrame:(CGRect)contextFrame;
-(int)populateWithAuxStixFromTag:(Tag*)tag;
-(void)populateWithStixForManipulation:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y /*andScale:(float)scale andRotation:(float)rotation*/;
-(void)updateStixForManipulation:(NSString*)stixStringID;
-(bool)isStixPeelable:(int)index;
-(bool)isForeground:(CGPoint)point inStix:(UIImageView*)selectedStix;
-(void)doPeelAnimationForStix;

-(int)findPeelableStixAtLocation:(CGPoint)location;
-(void)transformBoxShowAtFrame:(CGRect)frame;
-(void)addPeelableAnimationToStix:(UIImageView*)canvas;


// on demand stix download
-(void)requestStixFromKumulos:(NSString*)stixStringID forStix:(UIImageView*)auxStix inStixView:(StixView*)stixView; // andDelegate:(NSObject <StixViewDelegate>*)delegate;
-(void)didReceiveRequestedStix:(NSString*)stixStringID withResults:(NSArray*)theResults fromStixView:(int)senderID;
@end
