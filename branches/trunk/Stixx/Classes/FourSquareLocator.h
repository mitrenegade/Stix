//
//  FourSquareLocator.h
//  Stixx
//
//  Created by Mike Burrage on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@protocol VenueDelegate
-(void)receiveVenueNames:(NSArray*)venueNames andLatLong:(NSArray*)latlong;
-(void)didReceiveConnectionError;
@end

// Call query with text from text field and get venuedelegate
// callback with NSArray* of venue names (NSString*).
@interface FourSquareLocator : NSObject<CLLocationManagerDelegate> {
    NSString *activeQuery;
    CLLocationManager *gps;
    NSObject<VenueDelegate> *__unsafe_unretained delegate;
}

@property (nonatomic, unsafe_unretained) NSObject<VenueDelegate> *delegate;

- (id)init;
- (void)query:(NSString*)text;
- (double)distanceFromLatLong:(NSString*)latlongString;
@end
