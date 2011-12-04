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
	[super init];
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
    [Foursquare2 searchVenuesNearByLatitude:lat longitude:lon radius:@"1500" query:text limit:@"20" callback:^(BOOL success, id result) {
        NSMutableArray* venueNames = [[NSMutableArray alloc] init];
        NSDictionary* message = (NSDictionary*)result;
        if (nil != message) {
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
                                    if (nil != name)
                                    {
                                        [venueNames addObject:name];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if (nil != self.delegate) {
            [self.delegate receiveVenueNames:venueNames];
        }
    }];
}
@end
