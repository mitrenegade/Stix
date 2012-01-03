//
//  ARCoordinate.m
//  ARKitDemo
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#import "ARCoordinate.h"


@implementation ARCoordinate

@synthesize radialDistance, inclination, azimuth;
@synthesize geoLocation;
@synthesize title; // subtitle;

+ (ARCoordinate *)coordinateWithRadialDistance:(double)newRadialDistance inclination:(double)newInclination azimuth:(double)newAzimuth {
	ARCoordinate *newCoordinate = [[ARCoordinate alloc] init];
	newCoordinate.radialDistance = newRadialDistance;
	newCoordinate.inclination = newInclination;
	newCoordinate.azimuth = newAzimuth;
	
	newCoordinate.title = @"";
    //newCoordinate.subtitle = @"";
	
	return [newCoordinate autorelease];
}

- (NSUInteger)hash{
	//return ([self.title hash] ^ [self.subtitle hash]) + (int)(self.radialDistance + self.inclination + self.azimuth);
	return ([self.title hash]) + (int)(self.radialDistance + self.inclination + self.azimuth);
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToCoordinate:other];
}

- (BOOL)isEqualToCoordinate:(ARCoordinate *)otherCoordinate {
    if (self == otherCoordinate) return YES;
    
	BOOL equal = self.radialDistance == otherCoordinate.radialDistance;
	equal = equal && self.inclination == otherCoordinate.inclination;
	equal = equal && self.azimuth == otherCoordinate.azimuth;
	equal = equal && self.geoLocation == otherCoordinate.geoLocation;
		
	if ((self.title && otherCoordinate.title) || (self.title && !otherCoordinate.title) || (!self.title && otherCoordinate.title)) {
		equal = equal && [self.title isEqualToString:otherCoordinate.title];
	}
	
	return equal;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ r: %.3fm φ: %.3f° θ: %.3f°", self.title, self.radialDistance, radiansToDegrees(self.azimuth), radiansToDegrees(self.inclination)];
}

// latitude/longitude code (formerly ARGeoCoordinate)
- (float)angleFromCoordinate:(CLLocationCoordinate2D)first toCoordinate:(CLLocationCoordinate2D)second {
	float longitudinalDifference = second.longitude - first.longitude;
	float latitudinalDifference = second.latitude - first.latitude;
	float possibleAzimuth = (M_PI * .5f) - atan(latitudinalDifference / longitudinalDifference);
	if (longitudinalDifference > 0) return possibleAzimuth;
	else if (longitudinalDifference < 0) return possibleAzimuth + M_PI;
	else if (latitudinalDifference < 0) return M_PI;
	
	return 0.0f;
}

- (void)calibrateUsingOrigin:(CLLocation *)origin {
	
	if (!self.geoLocation) return;
	
	double baseDistance = [origin distanceFromLocation:self.geoLocation];
	
	self.radialDistance = sqrt(pow(origin.altitude - self.geoLocation.altitude, 2) + pow(baseDistance, 2));
	
	float angle = sin(ABS(origin.altitude - self.geoLocation.altitude) / self.radialDistance);
	
	if (origin.altitude > self.geoLocation.altitude) angle = -angle;
	
	self.inclination = angle;
	self.azimuth = [self angleFromCoordinate:origin.coordinate toCoordinate:self.geoLocation.coordinate];
}

+ (ARCoordinate *)coordinateWithLocation:(CLLocation *)location {
	ARCoordinate *newCoordinate = [[ARCoordinate alloc] init];
	newCoordinate.geoLocation = location;
	
	newCoordinate.title = [NSString stringWithFormat:@"<%f %f>", location.coordinate.latitude, location.coordinate.longitude];
	//newCoordinate.subtitle = @"";
	
	return [newCoordinate autorelease];
}

+ (ARCoordinate *)coordinateWithLocation:(CLLocation *)location fromOrigin:(CLLocation *)origin {
	ARCoordinate *newCoordinate = [ARCoordinate coordinateWithLocation:location];
	
	[newCoordinate calibrateUsingOrigin:origin];
	//newCoordinate.hasPhoto = NO;
	
	return newCoordinate;
}

#define BOX_WIDTH 150
#define BOX_HEIGHT 100

- (UIView *)viewForCoordinate {
	
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
	UIView *tempView = [[UIView alloc] initWithFrame:theFrame];
	
	//tempView.backgroundColor = [UIColor colorWithWhite:.5 alpha:.3];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 20.0)];
	titleLabel.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = title;
	[titleLabel sizeToFit];
	
	titleLabel.frame = CGRectMake(BOX_WIDTH / 2.0 - titleLabel.frame.size.width / 2.0 - 4.0, 0, titleLabel.frame.size.width + 8.0, titleLabel.frame.size.height + 8.0);
	
	UIImageView *pointView = [[UIImageView alloc] initWithFrame:CGRectZero];
	pointView.image = [UIImage imageNamed:@"location.png"];
	pointView.frame = CGRectMake((int)(BOX_WIDTH / 2.0 - pointView.image.size.width / 2.0), (int)(BOX_HEIGHT / 2.0 - pointView.image.size.height / 2.0), pointView.image.size.width, pointView.image.size.height);
    
	[tempView addSubview:titleLabel];
	[tempView addSubview:pointView];
	
	[titleLabel release];
	[pointView release];
	
	return [tempView autorelease];
}

// bobby's code

-(void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeDouble:radialDistance forKey:@"radialDistance"];
	[encoder encodeDouble:inclination forKey:@"inclination"];
	[encoder encodeDouble:azimuth forKey:@"azimuth"];
	[encoder encodeObject:title forKey:@"title"];
	//[encoder encodeObject:subtitle forKey:@"subtitle"];	
	[encoder encodeObject:geoLocation forKey:@"geoLocation"];

}

-(id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	
	// TODO: incomplete
	[self setRadialDistance:[decoder decodeDoubleForKey:@"radialDistance"]];
	[self setInclination:[decoder decodeDoubleForKey:@"inclination"]];
	[self setAzimuth:[decoder decodeDoubleForKey:@"azimuth"]];
    [self setTitle:[decoder decodeObjectForKey:@"title"]];
	//[self setSubtitle:[decoder decodeObjectForKey:@"subtitle"]];
	[self setGeoLocation:[decoder decodeObjectForKey:@"geoLocation"]];

	return self;
}

- (void)dealloc {
	
	//self.title = nil;
	//self.subtitle = nil;
	
	[super dealloc];
}


@end
