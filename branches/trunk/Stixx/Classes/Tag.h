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
#import "ARCoordinate.h"

@interface Tag : NSObject {
    // elements saved by Kumulos
    NSString * username;
    NSString * comment;
    NSString * locationString;
    UIImage * image;
    int badge_x;
    int badge_y;
    int badgeType; // 0 = fire, 1 = ice
    int badgeCount;
    // data blob saved by Kumulos
    ARCoordinate * coordinate;
    
    // unique kumulos id number for each object added
    NSNumber * tagID;
    
    NSString* timestring; // the timestamp for the most recent tag, in string format (unused)
    NSDate * timestamp; // the timestamp as an NSDate
}

+ (Tag*)initWithName:(NSString*)name andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(UIImage*)image andBadge_X:(int)badge_x andBadge_Y:(int)badge_y andCoordinate:(ARCoordinate*)coordinate andType:(int)type andCount:(int)count;
- (void)addUsername:(NSString*)newUsername andComment:(NSString*)newComment andLocationString:(NSString*)newLocation;
- (void)addARCoordinate:(ARCoordinate*)ARCoordinate;
- (void) addImage:(UIImage*)image;
-(void)addStixOfType:(int)type andCount:(int)count atLocationX:(int)x andLocationY:(int)y;
+(Tag*)getTagFromDictionary:(NSMutableDictionary *)d;

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * locationString;
@property (nonatomic, retain) UIImage * image;
//@property (nonatomic, retain) NSNumber * badge_x;
//@property (nonatomic, retain) NSNumber * badge_y;
@property (nonatomic, retain) ARCoordinate * coordinate;
@property (nonatomic, retain) NSNumber * tagID;
@property (nonatomic, retain) NSString * timestring;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, assign) int badge_x;
@property (nonatomic, assign) int badge_y;
@property (nonatomic, assign) int badgeType;
@property (nonatomic, assign) int badgeCount;

@end
