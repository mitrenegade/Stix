//
//  Tag.m
//  ARKitDemo
//
//  Created by Administrator on 9/16/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize username, comment, image, coordinate, tagID, timestring, timestamp;
@synthesize badge_x, badge_y;

- (void)addUsername:(NSString*)newUsername andComment:(NSString*)newComment{
    [self setUsername:newUsername];
    [self setComment:newComment];
    NSLog(@"Added username %@ and comment %@ to tag", newUsername, newComment);
}

- (void)addARCoordinate:(ARCoordinate*)newARCoordinate {
    [self setCoordinate:newARCoordinate];
    NSLog(@"Added coordinate %@ to tag", newARCoordinate);
}

- (void) addImage:(UIImage*)newImage atLocationX:(int)x andLocationY:(int)y{
    badge_x = [NSNumber numberWithInt:x];
    badge_y = [NSNumber numberWithInt:y];
    [self setImage:newImage];
    NSLog(@"Added badge at %d %d to tag", x, y);
}

@end
