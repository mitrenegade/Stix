//
//  ARCoordinate.h
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * (180.0/M_PI))

//@class ARCoordinate;

//@protocol ARPersistentItem

@interface ARCoordinate : NSObject <NSCoding>{
	double radialDistance;
	double inclination;
	double azimuth;
	
	CLLocation *geoLocation;

	NSString *title; // a description of the location, not the name or comment of the tag
	//NSString *subtitle;
	
}

- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToCoordinate:(ARCoordinate *)otherCoordinate;

+ (ARCoordinate *)coordinateWithRadialDistance:(double)newRadialDistance inclination:(double)newInclination azimuth:(double)newAzimuth;

// functions that deal with longitude/latitude (formerly from ARCoordinate)
- (float)angleFromCoordinate:(CLLocationCoordinate2D)first toCoordinate:(CLLocationCoordinate2D)second;

+ (ARCoordinate *)coordinateWithLocation:(CLLocation *)location;

- (void)calibrateUsingOrigin:(CLLocation *)origin;
+ (ARCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin;

// persistence/saving to disk
//-(void)encodeWithCoder:(NSCoder *)encoder;
//-(id)initWithCoder:(NSCoder *)decoder;
-(UIView *)viewForCoordinate;

@property (nonatomic, retain) NSString *title;
//@property (nonatomic, retain) NSString *subtitle;

@property (nonatomic) double radialDistance;
@property (nonatomic) double inclination;
@property (nonatomic) double azimuth;
@property (nonatomic, retain) CLLocation *geoLocation;

@end
