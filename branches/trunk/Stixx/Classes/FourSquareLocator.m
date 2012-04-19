//
//  FourSquareLocator.m
//  Stixx
//
//  Created by Mike Burrage on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FourSquareLocator.h"
#import "Foursquare2.h"

@implementation FourSquareLocator
@synthesize delegate;
-(id)init
{
	self = [super init];
    gps = [[CLLocationManager alloc] init];

    // start listening
    gps.headingFilter = kCLHeadingFilterNone;
    gps.desiredAccuracy = kCLLocationAccuracyBest;
    //[gps startUpdatingHeading];
    
    // also start updating location
    [gps setDistanceFilter:kCLDistanceFilterNone];
    [gps setDesiredAccuracy:kCLLocationAccuracyBest];
    [gps startUpdatingLocation];
    
	return self;
}

-(double)distanceFromLatLong:(NSString *)latlongString {
    // parse latlong
    NSArray * tmp = [latlongString componentsSeparatedByString:@","];
    NSString * latstr = [tmp objectAtIndex:0];
    double lat = [latstr doubleValue];
    NSString * lonstr = [tmp objectAtIndex:1];
    double lon = [lonstr doubleValue];

    CLLocation* location = [gps location];
    if (nil == location) {
        return 9999;
    }
    double currlat = [location coordinate].latitude;
    double currlong = [location coordinate].longitude;
    double dx = currlat - lat;
    double dy = currlong - lon;
    double dist = sqrt(dx*dx + dy*dy);
    return dist;
}

-(void)query:(NSString*)text
{
#if TARGET_IPHONE_SIMULATOR
    NSString* lat = @"42.365";
    NSString* lon = @"-71.055";
#else
    CLLocation* location = [gps location];
    if (nil == location) {
        return;
    }
    NSString* lat = [[NSString alloc] initWithFormat:@"%f", [location coordinate].latitude];
    NSString* lon = [[NSString alloc] initWithFormat:@"%f", [location coordinate].longitude];
#endif
    [Foursquare2 searchVenuesNearByLatitude:lat longitude:lon radius:@"500" query:text limit:@"20" callback:^(BOOL success, id result) {
        NSMutableArray* venueNames = [[NSMutableArray alloc] init];
        NSMutableArray * venueLL = [[NSMutableArray alloc] init];
        NSDictionary* message = (NSDictionary*)result;
        if(success==NO) {
            if (nil != self.delegate) {
                [self.delegate didReceiveConnectionError];
            }
        }
        else if (nil != message) {
            NSDictionary* response = (NSDictionary*)[message valueForKey:@"response"];
            if (nil != response) {
                NSArray* groups = (NSArray*)[response valueForKey:@"groups"];
                if (nil != groups) {
                    for (int i = 0; i < [groups count]; ++i) {
                        NSDictionary* group = (NSDictionary*)[groups objectAtIndex:i];                
                        if (nil != group) {
                            NSArray* items = (NSArray*)[group valueForKey:@"items"];
                            if (nil != items) {
                                for (int i = 0; i < [items count]; ++i) {
                                    NSDictionary* item = (NSDictionary*)[items objectAtIndex:i];
                                    NSString* name = [item valueForKey:@"name"];
                                    NSString* latlong = [item valueForKey:@"ll"];
                                    if (nil != name)
                                    {
                                        [venueNames addObject:name];
                                        if (latlong)
                                            [venueLL addObject:latlong];
                                        else
                                            [venueLL addObject:@"22,22"];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if (nil != self.delegate) {
            [self.delegate receiveVenueNames:venueNames andLatLong:venueLL];
        }
        [venueLL release];
        [venueNames release];
    }];
    [lat release];
    [lon release];
}
@end
