//
//  Tag.m
//  ARKitDemo
//
//  Created by Administrator on 9/16/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize username, originalUsername, image, tagID, timestring, timestamp;
@synthesize comment;
@synthesize descriptor;
@synthesize locationString;
@synthesize auxStixStringIDs, auxLocations, auxScales, auxRotations, auxPeelable, auxTransforms, auxIDs;
@synthesize highResImage, highResImageID;
@synthesize stixLayer;
@synthesize pendingID;
//@synthesize badge_x, badge_y, badgeCount;
//@synthesize stixStringID;
//@synthesize stixScale, stixRotation;

-(void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:username forKey:@"username"];
    [aCoder encodeObject:username forKey:@"originalUsername"];
    [aCoder encodeObject:image forKey:@"image"];
    [aCoder encodeObject:tagID forKey:@"tagID"];
    [aCoder encodeObject:timestamp forKey:@"timestamp"];
    [aCoder encodeObject:timestring forKey:@"timestring"];
    [aCoder encodeObject:descriptor forKey:@"descriptor"];
    [aCoder encodeObject:highResImageID forKey:@"highResImageID"];
    [aCoder encodeObject:stixLayer forKey:@"stixLayer"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super init])) {
        [self setUsername:[aDecoder decodeObjectForKey:@"username"]];
        [self setOriginalUsername:[aDecoder decodeObjectForKey:@"originalUsername"]];
        [self setImage:[aDecoder decodeObjectForKey:@"image"]];
        [self setTagID:[aDecoder decodeObjectForKey:@"tagID"]];
        [self setTimestamp:[aDecoder decodeObjectForKey:@"timestamp"]];
        [self setTimestring:[aDecoder decodeObjectForKey:@"timestring"]];
        [self setDescriptor:[aDecoder decodeObjectForKey:@"descriptor"]];
        [self setHighResImageID:[aDecoder decodeObjectForKey:@"highResImageID"]];
        [self setStixLayer:[aDecoder decodeObjectForKey:@"stixLayer"]];
    }
    return self;
    
}

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

- (void) addImage:(UIImage*)newImage {
    [self setImage:newImage]; // MRC: setter should call retain automatically
}

-(void)addStix:(NSString*)newStixStringID withLocation:(CGPoint)newLocation /*withScale:(float)newScale withRotation:(float)newRotation */withTransform:(CGAffineTransform)transform withPeelable:(bool)newPeelable {
    // called by StixAppDelegate multiple places - makes a decision whether
    // to increment count or add an aux stix
    
    if (auxStixStringIDs == nil) {
        auxStixStringIDs = [[NSMutableArray alloc] init];
        auxLocations = [[NSMutableArray alloc] init];
        auxPeelable = [[NSMutableArray alloc] init];
        auxTransforms = [[NSMutableArray alloc] init];
        auxIDs = [[NSMutableArray alloc] init];
    }
    
    [auxStixStringIDs addObject:newStixStringID];
    [auxLocations addObject:[NSValue valueWithCGPoint:newLocation]];
    [auxPeelable addObject:[NSNumber numberWithBool:newPeelable]];
    [auxTransforms addObject:NSStringFromCGAffineTransform(transform)];
}

-(CGPoint)getLocationOfRemoveStixAtIndex:(int)index {
    if (index < [auxStixStringIDs count]) {
        CGPoint location = [[auxLocations objectAtIndex:index] CGPointValue];
        return location;
    }
    return CGPointMake(-1, -1);
}
-(NSString*)removeStixAtIndex:(int)index {
    if (index < [auxStixStringIDs count]) {
        NSString * auxStringID = [[auxStixStringIDs objectAtIndex:index] copy];
        [auxStixStringIDs removeObjectAtIndex:index];
        [auxLocations removeObjectAtIndex:index];
        [auxTransforms removeObjectAtIndex:index];
        [auxPeelable removeObjectAtIndex:index];
        return auxStringID; // MRC
    }
    return nil;
}

-(void)populateWithAuxiliaryStix:(NSMutableArray*)theResults {
    NSLog(@"Populating tag with %d aux stix", [theResults count]);
//#error Not implemented!
    [auxStixStringIDs removeAllObjects];
    [auxLocations removeAllObjects];
    [auxTransforms removeAllObjects];
    [auxPeelable removeAllObjects];
    for (NSMutableDictionary * d in theResults) {
        NSString * newStixStringID = [d objectForKey:@"stixStringID"];
        float x = [[d objectForKey:@"x"] floatValue];
        float y = [[d objectForKey:@"y"] floatValue];
        NSString * transform = [d objectForKey:@"transform"];
        [auxStixStringIDs addObject:newStixStringID];
        [auxLocations addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        [auxPeelable addObject:[NSNumber numberWithBool:NO]];
        [auxTransforms addObject:transform];
    }
}

+(NSMutableDictionary*)tagToDictionary:(Tag*)tag {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[tag username] forKey:@"username"];
    [dict setObject: UIImagePNGRepresentation([tag image]) forKey:@"image"];
    [dict setObject:[tag tagID] forKey:@"allTagID"];
    if ([tag originalUsername])
        [dict setObject:[tag originalUsername] forKey:@"originalUsername"];
    if ([tag descriptor])
        [dict setObject:[tag descriptor] forKey:@"descriptor"];
    if ([tag comment])
        [dict setObject:[tag comment] forKey:@"comment"];
    if ([tag locationString])
        [dict setObject:[tag locationString] forKey:@"locationString"];
    if ([tag highResImageID])
        [dict setObject:[tag highResImageID] forKey:@"highResImageID"];
    if ([tag stixLayer])
        [dict setObject:UIImagePNGRepresentation([tag stixLayer]) forKey:@"stixLayer"];
    if ([tag timestamp]) {
        [dict setObject:[tag timestamp] forKey:@"timeCreated"];
        [dict setObject:[tag timestamp] forKey:@"timeUpdated"];
    }
    else {
        [dict setObject:[NSDate date] forKey:@"timeCreated"];
        [dict setObject:[NSDate date] forKey:@"timeUpdated"];
    }
    return dict;
}
+(Tag*)getTagFromDictionary:(NSMutableDictionary *)d {
    // loading a tag from kumulos
    
    NSString * name = [d valueForKey:@"username"];
    NSString * originalUsername = [d valueForKey:@"originalUsername"];
    NSString * descriptor = [d valueForKey:@"descriptor"];
    NSString * comment = [d valueForKey:@"comment"];
    NSString * locationString = [d valueForKey:@"locationString"];
    UIImage * image = [[UIImage alloc] initWithData:[d valueForKey:@"image"]];
    NSNumber * highResImageID = [d valueForKey:@"highResImageID"];
    NSData * stixLayerData = [d valueForKey:@"stixLayer"];
    NSData * highResImageData = [d valueForKey:@"highResImage"];
    
    NSLog(@"GetTagFromDictionary: id %@ username %@ descriptor %@ pendingID %@ highResID %@", [d valueForKey:@"tagID"], name, descriptor, [d valueForKey:@"pendingID"], [d valueForKey:@"highResImageID"]);
        
    Tag * tag = [[Tag alloc] init]; 
    [tag addUsername:name andDescriptor:descriptor andComment:comment andLocationString:locationString];
	[tag addImage:image];
    [tag setHighResImageID:highResImageID];
    if (originalUsername)
        [tag setOriginalUsername:originalUsername];
    if (stixLayerData)
        [tag setStixLayer:[UIImage imageWithData:stixLayerData]];
    if (highResImageData)
        [tag setHighResImage:[UIImage imageWithData:highResImageData]];
    tag.tagID = [d valueForKey:@"allTagID"];
    NSDate * timeCreated = [d valueForKey:@"timeCreated"];
    NSDate * timeUpdated = [d valueForKey:@"timeUpdated"];
    tag.timestamp = [timeCreated laterDate:timeUpdated];
    /*
    //NSMutableData *theData = (NSMutableData*)[d valueForKey:@"tagCoordinate"];
    //NSKeyedUnarchiver *decoder;
    //decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
    //ARCoordinate * coordinate = [decoder decodeObjectForKey:@"coordinate"];
    //[decoder finishDecoding];
    //[tag addARCoordinate:coordinate];
     
    NSMutableData *theData2 = (NSMutableData*)[d valueForKey:@"auxStix"];
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData2];
    [tag setAuxStixStringIDs:[decoder decodeObjectForKey:@"auxStixStringIDs"]];
    [tag setAuxLocations:[decoder decodeObjectForKey:@"auxLocations"] ];
    [tag setAuxTransforms:[decoder decodeObjectForKey:@"auxTransforms"]];
    [tag setAuxPeelable:[decoder decodeObjectForKey:@"auxPeelable"]];
    [decoder finishDecoding];
    */
    
    if (tag.auxStixStringIDs == nil) {
        [tag setAuxStixStringIDs:[[NSMutableArray alloc] init]];
    }
    if (tag.auxLocations == nil) {
        [tag setAuxLocations:[[NSMutableArray alloc] init]];
        for (int i=0; i<[tag.auxStixStringIDs count]; i++) {
            [tag.auxLocations addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
        }
    }
    if (tag.auxPeelable == nil) {
        [tag setAuxPeelable:[[NSMutableArray alloc] init]];
        for (int i=0; i<[tag.auxStixStringIDs count]; i++) {
            [tag.auxLocations addObject:[NSNumber numberWithBool:NO]];
        }
    }
    if (tag.auxTransforms == nil) {
        [tag setAuxTransforms:[[NSMutableArray alloc] init]]; // MRC
        for (int i=0; i<[tag.auxStixStringIDs count]; i++) {
            CGAffineTransform t = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
            [tag.auxTransforms addObject:NSStringFromCGAffineTransform(t)];
        }
    }

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

-(void)burnStixLayerImage {
    // returns the layer of only stix
    [self setStixLayer:[self tagToUIImageUsingBase:NO retainStixLayer:NO useHighRes:NO]];
}

-(UIImage*)tagToUIImage {
    return [self tagToUIImageUsingBase:YES retainStixLayer:YES useHighRes:NO];
}
-(UIImage *)tagToUIImageUsingBase:(BOOL)includeBaseImage retainStixLayer:(BOOL)retainStixLayer useHighRes:(BOOL)useHighRes {
    
    // set size of canvas
    CGSize newSize;
    if (USE_HIGHRES_SHARE && useHighRes && self.highResImage) {
        newSize = [self.highResImage size];
    } 
    else {
        newSize = [self.image size];
    }
    UIGraphicsBeginImageContext(newSize);
     
    // draw base image
    CGRect fullFrame = CGRectMake(0, 0, newSize.width, newSize.height);
    if (includeBaseImage) {
        if (USE_HIGHRES_SHARE && self.highResImage) {
            [self.highResImage drawInRect:fullFrame];
        }
        else {
            [self.image drawInRect:fullFrame];	
        }
    }
    
    // draw previous stix image
    if (stixLayer && retainStixLayer)
        [stixLayer drawInRect:fullFrame];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();	

    // add all stix that are currently in auxStix lists
    for (int i=0; i<[auxStixStringIDs count]; i++) {
        NSString * stixStringID = [auxStixStringIDs objectAtIndex:i];
        NSString * transformString = [auxTransforms objectAtIndex:i];
        CGAffineTransform auxTransform = CGAffineTransformFromString(transformString); // if fails, returns identity
        UIImageView * stix = [BadgeView getBadgeWithStixStringID:stixStringID];
        
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

-(Tag*)copy {
    Tag * t = [[Tag alloc] init];
    [t setUsername:[self.username copy]];
    [t setOriginalUsername:[self.originalUsername copy]]; // needs some attention
    [t setImage:[self.image copy]];
    [t setTagID:[self.tagID copy]];
    [t setTimestamp:[NSDate date]];
    [t setTimestring:[Tag getTimeLabelFromTimestamp:[t timestamp]]];
    [t setDescriptor:[self.descriptor copy]];
    [t setHighResImageID:[self.highResImageID copy]];
    [t setHighResImage:[self.highResImage copy]];
    [t setStixLayer:[self.stixLayer copy]];
    return t;
}

@end
