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
@synthesize auxStixStringIDs, auxLocations, auxScales, auxRotations, auxPeelable;
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

-(void)addAnyStix:(NSString*)newStixStringID withLocation:(CGPoint)newLocation withScale:(float)newScale withRotation:(float)newRotation withPeelable:(bool)newPeelable {
    // called by StixAppDelegate multiple places - makes a decision whether
    // to increment count or add an aux stix
    if ( ([newStixStringID isEqualToString:@"FIRE"] || [newStixStringID isEqualToString:@"ICE"]) && 
        ([self.stixStringID isEqualToString:@"FIRE"] || [self.stixStringID isEqualToString:@"ICE"]))
    {
        // increment/decrement fire and ice if it is the primary stix; do not change other stix counts
        if ([self.stixStringID isEqualToString:newStixStringID])
            self.badgeCount++;
        else {
            self.badgeCount--;
            if (self.badgeCount < 0) {
                self.badgeCount = -self.badgeCount;
                if ([self.stixStringID isEqualToString:@"FIRE"])
                    self.stixStringID = @"ICE";
                else
                    self.stixStringID = @"FIRE";
            }
        }
    }
    else {
        //if adding a gift stix, or adding fire or ice to a gift stix, add to the auxStix
        // array for the tag
        [self addAuxiliaryStixOfType:newStixStringID withLocation:newLocation withScale:newScale withRotation:newRotation withPeelable:newPeelable];
    }
}

-(void)addAuxiliaryStixOfType:(NSString*)stringID withLocation:(CGPoint)location withScale:(float)scale withRotation:(float)rotation withPeelable:(bool)peelable{
    [auxStixStringIDs addObject:stringID];
    [auxLocations addObject:[NSValue valueWithCGPoint:location]];
    [auxScales addObject:[NSNumber numberWithFloat:scale]];
    [auxRotations addObject:[NSNumber numberWithFloat:rotation]];
    [auxPeelable addObject:[NSNumber numberWithBool:peelable]];
}

-(NSString*)removeAuxiliaryStixAtIndex:(int)index {
    NSString * auxStringID = [[auxStixStringIDs objectAtIndex:index] copy];
    [auxStixStringIDs removeObjectAtIndex:index];
    [auxLocations removeObjectAtIndex:index];
    [auxScales removeObjectAtIndex:index];
    [auxRotations removeObjectAtIndex:index];
    [auxPeelable removeObjectAtIndex:index];
    return auxStringID;
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
    NSMutableArray * stixPeelable = [decoder decodeObjectForKey:@"auxPeelable"];
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
    tag.auxPeelable = stixPeelable;
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
    if (stixPeelable == nil) {
        tag.auxPeelable = [[NSMutableArray alloc] init];
        for (int i=0; i<[tag.auxStixStringIDs count]; i++) {
            [tag.auxPeelable addObject:[NSNumber numberWithBool:YES]];
        }
    }
    tag.stixScale = stixScale;
    tag.stixRotation = stixRotation;
    tag.tagID = [d valueForKey:@"allTagID"];
    tag.timestamp = [d valueForKey:@"timeCreated"];
    return tag;
}


@end
