//
//  Tag.m
//  ARKitDemo
//
//  Created by Administrator on 9/16/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize username, image, tagID, timestring, timestamp;
@synthesize comment;
@synthesize descriptor;
@synthesize locationString;
@synthesize auxStixStringIDs, auxLocations, auxScales, auxRotations, auxPeelable, auxTransforms;
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

//- (void)addARCoordinate:(ARCoordinate*)newARCoordinate {
    //[self setCoordinate:newARCoordinate];
    //NSLog(@"Added coordinate %@ to tag", newARCoordinate);
//}

- (void) addImage:(UIImage*)newImage {
    [self setImage:newImage]; // MRC: setter should call retain automatically
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

-(void)addStix:(NSString*)newStixStringID withLocation:(CGPoint)newLocation /*withScale:(float)newScale withRotation:(float)newRotation */withTransform:(CGAffineTransform)transform withPeelable:(bool)newPeelable {
    // called by StixAppDelegate multiple places - makes a decision whether
    // to increment count or add an aux stix
    
    if (auxStixStringIDs == nil) {
        auxStixStringIDs = [[NSMutableArray alloc] init];
        auxLocations = [[NSMutableArray alloc] init];
        //auxScales = [[NSMutableArray alloc] init];
        //auxRotations = [[NSMutableArray alloc] init];
        auxPeelable = [[NSMutableArray alloc] init];
        auxTransforms = [[NSMutableArray alloc] init];
    }
    //if adding a gift stix, or adding fire or ice to a gift stix, add to the auxStix
    // array for the tag
    //[self addAuxiliaryStixOfType:newStixStringID withLocation:newLocation withScale:newScale withRotation:newRotation withPeelable:newPeelable];
    
    [auxStixStringIDs addObject:newStixStringID];
    [auxLocations addObject:[NSValue valueWithCGPoint:newLocation]];
    //[auxScales addObject:[NSNumber numberWithFloat:newScale]];
    //[auxRotations addObject:[NSNumber numberWithFloat:newRotation]];
    [auxPeelable addObject:[NSNumber numberWithBool:newPeelable]];
    [auxTransforms addObject:NSStringFromCGAffineTransform(transform)];
}

-(NSString*)removeStixAtIndex:(int)index {
    if (index < [auxStixStringIDs count]) {
        NSString * auxStringID = [[auxStixStringIDs objectAtIndex:index] copy];
        [auxStixStringIDs removeObjectAtIndex:index];
        [auxLocations removeObjectAtIndex:index];
        //[auxScales removeObjectAtIndex:index];
        //[auxRotations removeObjectAtIndex:index];
        [auxTransforms removeObjectAtIndex:index];
        [auxPeelable removeObjectAtIndex:index];
        return auxStringID; // MRC
    }
    return nil;
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
    //ARCoordinate * coordinate = [decoder decodeObjectForKey:@"coordinate"];
    [decoder finishDecoding];
    
    Tag * tag = [[Tag alloc] init]; 
    [tag addUsername:name andDescriptor:descriptor andComment:comment andLocationString:locationString];
	[tag addImage:image];
    //[tag addARCoordinate:coordinate];
     // MRC
    
    NSMutableData *theData2 = (NSMutableData*)[d valueForKey:@"auxStix"];
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData2];
    [tag setAuxStixStringIDs:[decoder decodeObjectForKey:@"auxStixStringIDs"]];
    [tag setAuxLocations:[decoder decodeObjectForKey:@"auxLocations"] ];
    //tag.auxScales = [decoder decodeObjectForKey:@"auxScales"];
    //tag.auxRotations = [decoder decodeObjectForKey:@"auxRotations"];
    [tag setAuxTransforms:[decoder decodeObjectForKey:@"auxTransforms"]];
    [tag setAuxPeelable:[decoder decodeObjectForKey:@"auxPeelable"]];
    [decoder finishDecoding];
    
    // backwards compatibility
    [tag setAuxScales:[[NSMutableArray alloc] initWithCapacity:[tag.auxStixStringIDs count]]]; // MRC
    [tag setAuxRotations:[[NSMutableArray alloc] initWithCapacity:[tag.auxStixStringIDs count]]];
    for (int i=0; i<[tag.auxStixStringIDs count]; i++) {
        [tag.auxScales addObject:[NSNumber numberWithFloat:1]];
        [tag.auxRotations addObject:[NSNumber numberWithFloat:0]];
    }
    
    // backwards compatibility
    if (tag.auxTransforms == nil) {
        [tag setAuxTransforms:[[NSMutableArray alloc] init]]; // MRC
        for (int i=0; i<[tag.auxStixStringIDs count]; i++) {
            CGAffineTransform t = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
            [tag.auxTransforms addObject:NSStringFromCGAffineTransform(t)];
        }
    }

    //tag.stixScale = stixScale; // no more main stix
    //tag.stixRotation = stixRotation;
    tag.tagID = [d valueForKey:@"allTagID"];
    NSDate * timeCreated = [d valueForKey:@"timeCreated"];
    NSDate * timeUpdated = [d valueForKey:@"timeUpdated"];
    tag.timestamp = [timeCreated laterDate:timeUpdated];
    return tag;
}

+(NSString*) getTimeLabelFromTimestamp:(NSDate*) timestamp {
    // format timestring
    // from 1 min - 1 hour, display # of minutes since tag
    // from 1 hr to 24 hour, display # of hours since tag
    // beyond that, display date of timestamp
    // format is: 2011-10-27 06:09:28
    
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate * timestamp = [dateFormatter dateFromString:tmp]; //timestring];
    NSDate * now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:timestamp]; // interval is a float of total seconds
    
    int num;
    NSString * unit;
    if (interval < 60)
    {
        //num = (int) interval;
        //unit = @"sec ago";
        num = 0;
        unit = @"Just now";
    }
    else if (interval < 3600)
    {
        num = interval / 60;
        if (num == 1)
            unit = @"min ago";
        else
            unit = @"mins ago";
    }
    else if (interval < 86400)
    {
        num = interval / 3600;
        if (num == 1)
            unit = @"hour ago";
        else
            unit = @"hours ago";
    }
    else //if (interval >= 86400)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd"]; //NSDateFormatterShortStyle];
        unit = [dateFormatter stringFromDate:timestamp];
        num = 0;
    }
    
    NSString * timeLabel;
    if (num > 0)
        timeLabel = [NSString stringWithFormat:@"%d %@", num, unit];
    else
        timeLabel = [NSString stringWithFormat:@"%@", unit];
    return timeLabel;
}

-(UIImage *)tagToUIImage {
    CGSize newSize = [self.image size];
    CGRect fullFrame = CGRectMake(0, 0, newSize.width, newSize.height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:fullFrame];	
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();	
    
    for (int i=0; i<[auxStixStringIDs count]; i++) {
    //int i = 0; {
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:i];
        NSString * transformString = [auxTransforms objectAtIndex:i];
        CGAffineTransform auxTransform = CGAffineTransformFromString(transformString); // if fails, returns identity
        UIImageView * stix = [BadgeView getBadgeWithStixStringID:stixStringID];
        //CGPoint center = [[auxLocations objectAtIndex:i] CGPointValue];
        //[stix setCenter:center];
        //CGPoint location = stix.frame.origin;
        
        // resize and rotate stix image source to correct auxTransform
        CGSize stixSize = stix.frame.size;
        UIGraphicsBeginImageContext(newSize);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        
        // add previous result
        [result drawInRect:fullFrame];
        
        // save state
        CGContextSaveGState(currentContext);

        // center context around center of stix
        CGPoint location = [[auxLocations objectAtIndex:i] CGPointValue];
        CGContextTranslateCTM(currentContext, location.x, location.y);
        
        // apply stix's transform about this anchor point
        CGContextConcatCTM(currentContext, auxTransform);
        
        // offset by portion of bounds left and above anchor point
        CGContextTranslateCTM(currentContext, -stixSize.width/2, -stixSize.height/2);
        
        // render
        [[stix layer] renderInContext:currentContext];
        
        // restore state
        CGContextRestoreGState(currentContext);

        // Get an image from the context
        result = UIGraphicsGetImageFromCurrentImageContext();; //[UIImage imageWithCGImage: CGBitmapContextCreateImage(currentContext)];
        UIGraphicsEndImageContext();
    }    
    // save edited image to photo album
    return result;
}

@end
