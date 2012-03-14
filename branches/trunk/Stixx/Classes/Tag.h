//
//  Tag.h
//  ARKitDemo
//
//  Created by Administrator on 9/16/11.
//  Copyright 2011 Neroh. All rights reserved.
//
//  For saving tags locally and into the database, a Tag structure contains:
//  username
//  comment
//  image blob (NSData)
//  badge_x
//  badge_y
//  should have a badge (UIImageView)
//  ARCoordinate (NSData) which contains:
//      radialDistance
//      inclination
//      azimuth
//      title
//      subtitle
//

#import <Foundation/Foundation.h>
#import "BadgeView.h" // for BADGE_TYPE_MAX
#import "KumulosData.h"
#import <QuartzCore/QuartzCore.h>

@interface Tag : NSObject {
    // elements saved by Kumulos
    NSString * username;
    NSString * descriptor;
    NSString * comment;
    NSString * locationString;
    UIImage * image;
    
    // old primary stix info - not used
    /*
    int badge_x;
    int badge_y;
    int badgeCount;
    NSString * stixStringID; // string representation of type
    float stixScale;
    float stixRotation;
    */
    
    // auxiliary stix - stored in Kumulos as a separate table //an array of dictionaries
    NSMutableArray * auxStixStringIDs;
    NSMutableArray * auxLocations;
    NSMutableArray * auxScales; // deprecated  - keep around for backwards compatibility
    NSMutableArray * auxRotations; // deprecated
    NSMutableArray * auxPeelable;
    NSMutableArray * auxTransforms; // rotation and scale combined
    
    // data blob saved by Kumulos
    //ARCoordinate * coordinate;
    
    // unique kumulos id number for each object added
    NSNumber * tagID;
    
    NSString* timestring; // the timestamp for the most recent tag, in string format (unused)
    NSDate * timestamp; // the timestamp as an NSDate
}

- (void)addUsername:(NSString*)newUsername andDescriptor:(NSString*)newDescriptor andComment:(NSString*)newComment andLocationString:(NSString*)newLocation;
//- (void)addARCoordinate:(ARCoordinate*)ARCoordinate;
- (void) addImage:(UIImage*)image;
-(void)addStix:(NSString*)newStixStringID withLocation:(CGPoint)newLocation /*withScale:(float)newScale withRotation:(float)newRotation*/ withTransform:(CGAffineTransform)transform withPeelable:(bool)newPeelable;
//-(void)addMainStixOfType:(NSString*)stixStringID andCount:(int)count atLocationX:(int)x andLocationY:(int)y;
//-(void)addAuxiliaryStixOfType:(NSString*)stringID withLocation:(CGPoint)location withScale:(float)scale withRotation:(float)rotation withPeelable:(bool)peelable;
-(NSString*)removeStixAtIndex:(int)index;
+(Tag*)getTagFromDictionary:(NSMutableDictionary *)d;
-(UIImage *)tagToUIImage;

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * descriptor;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * locationString;
@property (nonatomic, retain) UIImage * image;
//@property (nonatomic, retain) ARCoordinate * coordinate;
@property (nonatomic, retain) NSNumber * tagID;
@property (nonatomic, retain) NSString * timestring;
@property (nonatomic, retain) NSDate * timestamp;
/*
@property (nonatomic, assign) int badge_x; // center coordinate
@property (nonatomic, assign) int badge_y; // center coordinate
@property (nonatomic, assign) int badgeCount;
@property (nonatomic, retain) NSString * stixStringID;
@property (nonatomic, assign) float stixScale;
@property (nonatomic, assign) float stixRotation;
*/

@property (nonatomic, retain) NSMutableArray * auxStixStringIDs;
@property (nonatomic, retain) NSMutableArray * auxLocations;
@property (nonatomic, retain) NSMutableArray * auxScales; // a floating point, where 1 is original size of a regular badge in 300x275 image
@property (nonatomic, retain) NSMutableArray * auxRotations; // a floating point in radians, where 0 is original orientation (no rotation) - deprecated
@property (nonatomic, retain) NSMutableArray * auxPeelable; // boolean whether stix is peelable by its owner - deprecated
@property (nonatomic, retain) NSMutableArray * auxTransforms;
@end
