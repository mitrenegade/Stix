//
//  Tag.m
//  ARKitDemo
//
//  Created by Administrator on 9/16/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize username, image, coordinate, tagID, timestring, timestamp;
@synthesize comment;
@synthesize descriptor;
@synthesize locationString;
@synthesize badge_x, badge_y, badgeCount;
@synthesize auxStixStringIDs, auxLocations, auxScales, auxRotations;
@synthesize stixStringID;
@synthesize stixScale, stixRotation;

- (void)addUsername:(NSString*)newUsername andDescriptor:(NSString *)newDescriptor andComment:(NSString*)newComment andLocationString:(NSString*)newLocation{        
    if (newUsername == nil)
        newUsername = @"";
    if (newDescriptor == nil)
        newDescriptor = @"";
    if (newComment == nil)
        newComment = @"";
    if (newLocation == nil)
        newLocation = @"";
    [self setUsername:newUsername];
    [self setDescriptor:newDescriptor];
    [self setComment:newComment];
    [self setLocationString:newLocation];
    //NSLog(@"Added username %@ and comment %@ to tag", newUsername, newComment);
}

- (void)addARCoordinate:(ARCoordinate*)newARCoordinate {
    [self setCoordinate:newARCoordinate];
    //NSLog(@"Added coordinate %@ to tag", newARCoordinate);
}

- (void) addImage:(UIImage*)newImage {
    [self setImage:[newImage copy]];
}

-(void)addMainStixOfType:(NSString*)stringID andCount:(int)count atLocationX:(int)x andLocationY:(int)y{
    badge_x = x;
    badge_y = y;
    badgeCount = count;
    stixStringID = [stringID copy];
    NSLog(@"Added badge at %d %d to tag", x, y);
}

-(void)addAuxiliaryStixOfType:(NSString*)stringID withLocation:(CGPoint)location withScale:(float)scale withRotation:(float)rotation{
    [auxStixStringIDs addObject:stringID];
    [auxLocations addObject:[NSValue valueWithCGPoint:location]];
    [auxScales addObject:[NSNumber numberWithFloat:scale]];
    [auxRotations addObject:[NSNumber numberWithFloat:rotation]];
}

+(Tag*)getTagFromDictionary:(NSMutableDictionary *)d {
    // loading a tag from kumulos
    
    NSString * name = [d valueForKey:@"username"];
    NSString * descriptor = [d valueForKey:@"descriptor"];
    NSString * comment = [d valueForKey:@"comment"];
    NSString * locationString = [d valueForKey:@"locationString"];
    UIImage * image = [[UIImage alloc] initWithData:[d valueForKey:@"image"]];
    int badge_x = [[d valueForKey:@"badge_x"] intValue];
    int badge_y = [[d valueForKey:@"badge_y"] intValue];
    int badgeType = [[d valueForKey:@"type"] intValue];     
    int badgeCount = [[d valueForKey:@"score"] intValue];
    float stixScale = [[d valueForKey:@"stixScale"] floatValue];
    float stixRotation = [[d valueForKey:@"stixRotation"] floatValue];
    NSString * stixStringID = [d valueForKey:@"stixStringID"];
    if (stixStringID == nil || [stixStringID length] == 0) {
        // backwards compatibility: old tags that have no stixStringID have a badgeType
        stixStringID = [BadgeView getStixStringIDAtIndex:badgeType] ;
        NSLog(@"*** Tag \"%@\"did not have stixStringID: setting badgeType %d to %@", descriptor, badgeType, stixStringID);
    }
    else
    {
        NSLog(@"*** Tag \"%@\"contained badgeType %d and stixStringID %@", descriptor, badgeType, stixStringID);
        stixStringID = [d valueForKey:@"stixStringID"];
    }
    
    NSMutableData *theData = (NSMutableData*)[d valueForKey:@"tagCoordinate"];
    NSKeyedUnarchiver *decoder;
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
    ARCoordinate * coordinate = [decoder decodeObjectForKey:@"coordinate"];
    [decoder finishDecoding];
    [decoder release];
    
    NSMutableData *theData2 = (NSMutableData*)[d valueForKey:@"auxStix"];
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData2];
    NSMutableArray * stixStringIDs = [decoder decodeObjectForKey:@"auxStixStringIDs"];
    NSMutableArray * stixLocations = [decoder decodeObjectForKey:@"auxLocations"];
    NSMutableArray * stixScales = [decoder decodeObjectForKey:@"auxScales"];
    NSMutableArray * stixRotations = [decoder decodeObjectForKey:@"auxRotations"];
    [decoder finishDecoding];
    [decoder release];

    Tag * tag = [[Tag alloc] init]; 
    [tag addUsername:name andDescriptor:descriptor andComment:comment andLocationString:locationString];
	[tag addImage:image];
    [tag addMainStixOfType:stixStringID andCount:badgeCount atLocationX:badge_x andLocationY:badge_y];
    [tag addARCoordinate:coordinate];
    
    // add empty aux
    tag.auxStixStringIDs = stixStringIDs;
    tag.auxLocations = stixLocations; 
    tag.auxScales = stixScales;
    tag.auxRotations = stixRotations;
    if (stixStringIDs == nil)
        tag.auxStixStringIDs = [[NSMutableArray alloc] init];
    if (stixLocations == nil)
        tag.auxLocations = [[NSMutableArray alloc] init];
    if (stixScales == nil) {
        tag.auxScales = [[NSMutableArray alloc] init];        
        for (int i=0; i<[tag.auxStixStringIDs count]; i++)
            [tag.auxScales addObject:[NSNumber numberWithFloat:1]];
    }
    if (stixRotations == nil) {
        tag.auxRotations = [[NSMutableArray alloc] init];
        for (int i=0; i<[tag.auxStixStringIDs count]; i++)
            [tag.auxRotations addObject:[NSNumber numberWithFloat:0]];
    }
    tag.stixScale = stixScale;
    tag.stixRotation = stixRotation;
    tag.tagID = [d valueForKey:@"allTagID"];
    tag.timestamp = [d valueForKey:@"timeCreated"];
    return tag;
}


@end
