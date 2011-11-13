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
    UIImage * image;
    NSNumber * badge_x;
    NSNumber * badge_y;
    
    // data blob saved by Kumulos
    ARCoordinate * coordinate;
    
    // unique kumulos id number for each object added
    NSNumber * tagID;
    
    NSString* timestring; // the timestamp for the most recent tag, in string format (unused)
    NSDate * timestamp; // the timestamp as an NSDate
}

- (void)addUsername:(NSString*)newUsername andComment:(NSString*)newComment;
- (void)addARCoordinate:(ARCoordinate*)ARCoordinate;
- (void) addImage:(UIImage*)image atLocationX:(int)x andLocationY:(int)y;

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain) NSNumber * badge_x;
@property (nonatomic, retain) NSNumber * badge_y;
@property (nonatomic, retain) ARCoordinate * coordinate;
@property (nonatomic, retain) NSNumber * tagID;
@property (nonatomic, retain) NSString * timestring;
@property (nonatomic, retain) NSDate * timestamp;
@end
