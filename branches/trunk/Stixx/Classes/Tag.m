//
//  Tag.m
//  ARKitDemo
//
//  Created by Administrator on 9/16/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize username, comment, image, coordinate, tagID, timestring, timestamp, locationString;
@synthesize badge_x, badge_y, badgeType, badgeCount;
@synthesize stixCounts;


+ (Tag*)initWithName:(NSString*)name andComment:(NSString*)comment andLocationString:(NSString*)locationString andImage:(UIImage*)image andBadge_X:(int)badge_x andBadge_Y:(int)badge_y andCoordinate:(ARCoordinate*)coordinate andType:(int)type andCount:(int)count andStixCounts:(NSMutableArray *) stixCounts
{
    // simply allocates and creates a tag from given items
    Tag * tag = [[[Tag alloc] init] autorelease]; 
    [tag addUsername:name andComment:comment andLocationString:locationString];
	[tag addImage:image];
    [tag addStixOfType:type andCount:count atLocationX:badge_x andLocationY:badge_y];
    [tag addARCoordinate:coordinate];
    [tag addStixCounts:stixCounts];
    return tag;
}

+(NSMutableArray *) dataToArray:(NSMutableData *) data{ 
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableArray * dict = [unarchiver decodeObjectForKey:@"dictionary"];
    [unarchiver finishDecoding];
    [unarchiver release];
    //[data release];
    return dict;
}

- (void)addUsername:(NSString*)newUsername andComment:(NSString*)newComment andLocationString:(NSString*)newLocation{
    [self setUsername:newUsername];
    [self setComment:newComment];
    [self setLocationString:newLocation];
    //NSLog(@"Added username %@ and comment %@ to tag", newUsername, newComment);
}

- (void)addARCoordinate:(ARCoordinate*)newARCoordinate {
    [self setCoordinate:newARCoordinate];
    //NSLog(@"Added coordinate %@ to tag", newARCoordinate);
}

- (void) addImage:(UIImage*)newImage {
    [self setImage:newImage];
}

-(void)addStixOfType:(int)type andCount:(int)count atLocationX:(int)x andLocationY:(int)y{
    badge_x = x;
    badge_y = y;
    badgeType = type;
    badgeCount = count;
    NSLog(@"Added badge at %d %d to tag", x, y);
}

-(void)addStixCounts:(NSMutableArray *) newStixCounts {
    if (stixCounts == nil)
        stixCounts = [[NSMutableArray alloc] init];
    [stixCounts removeAllObjects];
    [stixCounts addObjectsFromArray:newStixCounts];
}

+(Tag*)getTagFromDictionary:(NSMutableDictionary *)d {
    // loading a tag from kumulos
    
    NSString * name = [d valueForKey:@"username"];
    NSString * comment = [d valueForKey:@"comment"];
    NSString * locationString = [d valueForKey:@"locationString"];
    UIImage * image = [[UIImage alloc] initWithData:[d valueForKey:@"image"]];
    int badge_x = [[d valueForKey:@"badge_x"] intValue];
    int badge_y = [[d valueForKey:@"badge_y"] intValue];
    int badgeType = [[d valueForKey:@"type"] intValue];     int badgeCount = [[d valueForKey:@"score"] intValue];
    NSMutableData *theData = (NSMutableData*)[d valueForKey:@"tagCoordinate"];
    NSKeyedUnarchiver *decoder;
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
    ARCoordinate * coordinate = [decoder decodeObjectForKey:@"coordinate"];
    [decoder finishDecoding];
    [decoder release];
    theData = (NSMutableData*) [d valueForKey:@"stixCounts"];
    NSMutableArray * stixCounts = [Tag dataToArray:theData];
    if (stixCounts == nil) {
        stixCounts = [[NSMutableArray alloc] initWithCapacity:BADGE_TYPE_MAX];
        for (int i=0; i<BADGE_TYPE_MAX; i++)
            [stixCounts insertObject:[NSNumber numberWithInt:0] atIndex:i];
        [stixCounts replaceObjectAtIndex:badgeType withObject:[NSNumber numberWithInt:badgeCount]];
    }
    Tag * tag = [[Tag initWithName:name andComment:comment andLocationString:locationString andImage:image andBadge_X:badge_x andBadge_Y:badge_y andCoordinate:coordinate andType:badgeType andCount:badgeCount andStixCounts:stixCounts] retain];
    tag.tagID = [d valueForKey:@"allTagID"];
    tag.timestamp = [d valueForKey:@"timeCreated"];
    [image release];
    [tag autorelease];
    return tag;
}


@end
