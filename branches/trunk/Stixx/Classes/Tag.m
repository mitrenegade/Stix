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
@synthesize auxStixStringIDs, auxLocations;
@synthesize stixStringID;

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

-(void)addAuxiliaryStixOfType:(NSString*)stringID atLocation:(CGPoint)location {
    [auxStixStringIDs addObject:stringID];
    [auxLocations addObject:[NSValue valueWithCGPoint:location]];
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
    if (stixStringIDs == nil)
        tag.auxStixStringIDs = [[NSMutableArray alloc] init];
    if (stixLocations == nil)
        tag.auxLocations = [[NSMutableArray alloc] init];
    tag.tagID = [d valueForKey:@"allTagID"];
    tag.timestamp = [d valueForKey:@"timeCreated"];
    //[tag.auxLocations addObjectsFromArray:stixLocations];
    //[tag.auxStixStringIDs addObjectsFromArray:stixStringIDs];
    //[image release];
    return tag;
}


@end
