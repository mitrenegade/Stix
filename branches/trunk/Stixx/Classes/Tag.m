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
@synthesize auxStixStringIDs, auxLocations, auxScales, auxRotations, auxPeelable;
//@synthesize badge_x, badge_y, badgeCount;
//@synthesize stixStringID;
//@synthesize stixScale, stixRotation;

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

/*
-(void)addMainStixOfType:(NSString*)stringID andCount:(int)count atLocationX:(int)x andLocationY:(int)y{
    badge_x = x;
    badge_y = y;
    badgeCount = count;
    stixStringID = [stringID copy];
    NSLog(@"Added badge at %d %d to tag", x, y);
}
*/

-(void)addStix:(NSString*)newStixStringID withLocation:(CGPoint)newLocation withScale:(float)newScale withRotation:(float)newRotation withPeelable:(bool)newPeelable {
    // called by StixAppDelegate multiple places - makes a decision whether
    // to increment count or add an aux stix
    
    /* NO STIX COUNTS 
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
    else 
     */
    {
        if (auxStixStringIDs == nil) {
            auxStixStringIDs = [[NSMutableArray alloc] init];
            auxLocations = [[NSMutableArray alloc] init];
            auxScales = [[NSMutableArray alloc] init];
            auxRotations = [[NSMutableArray alloc] init];
            auxPeelable = [[NSMutableArray alloc] init];
        }
        //if adding a gift stix, or adding fire or ice to a gift stix, add to the auxStix
        // array for the tag
        //[self addAuxiliaryStixOfType:newStixStringID withLocation:newLocation withScale:newScale withRotation:newRotation withPeelable:newPeelable];
        
        [auxStixStringIDs addObject:newStixStringID];
        [auxLocations addObject:[NSValue valueWithCGPoint:newLocation]];
        [auxScales addObject:[NSNumber numberWithFloat:newScale]];
        [auxRotations addObject:[NSNumber numberWithFloat:newRotation]];
        [auxPeelable addObject:[NSNumber numberWithBool:newPeelable]];
    }
}

/*
-(void)addAuxiliaryStixOfType:(NSString*)stringID withLocation:(CGPoint)location withScale:(float)scale withRotation:(float)rotation withPeelable:(bool)peelable{
    [auxStixStringIDs addObject:stringID];
    [auxLocations addObject:[NSValue valueWithCGPoint:location]];
    [auxScales addObject:[NSNumber numberWithFloat:scale]];
    [auxRotations addObject:[NSNumber numberWithFloat:rotation]];
    [auxPeelable addObject:[NSNumber numberWithBool:peelable]];
}
 */

-(NSString*)removeStixAtIndex:(int)index {
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
        
    NSMutableData *theData = (NSMutableData*)[d valueForKey:@"tagCoordinate"];
    NSKeyedUnarchiver *decoder;
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
    ARCoordinate * coordinate = [decoder decodeObjectForKey:@"coordinate"];
    [decoder finishDecoding];
    [decoder release];
    
    Tag * tag = [[Tag alloc] init]; 
    [tag addUsername:name andDescriptor:descriptor andComment:comment andLocationString:locationString];
	[tag addImage:image];
    //[tag addMainStixOfType:stixStringID andCount:badgeCount atLocationX:badge_x andLocationY:badge_y];
    [tag addARCoordinate:coordinate];
    
    NSMutableData *theData2 = (NSMutableData*)[d valueForKey:@"auxStix"];
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData2];
    tag.auxStixStringIDs = [decoder decodeObjectForKey:@"auxStixStringIDs"];
    tag.auxLocations = [decoder decodeObjectForKey:@"auxLocations"];
    tag.auxScales = [decoder decodeObjectForKey:@"auxScales"];
    tag.auxRotations = [decoder decodeObjectForKey:@"auxRotations"];
    tag.auxPeelable = [decoder decodeObjectForKey:@"auxPeelable"];
    [decoder finishDecoding];
    [decoder release];

    /*
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
     */

    //tag.stixScale = stixScale; // no more main stix
    //tag.stixRotation = stixRotation;
    tag.tagID = [d valueForKey:@"allTagID"];
    tag.timestamp = [d valueForKey:@"timeCreated"];
    return tag;
}


@end
