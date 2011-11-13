//
//  ARViewController.m
//  ARKitDemo
//
//  Created by Administrator on 9/17/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "ARViewController.h"


@implementation ARViewController

@synthesize locationManager, accelerometerManager;
@synthesize centerCoordinate;
@synthesize centerLocation;
@synthesize scaleViewsBasedOnDistance, rotateViewsBasedOnPerspective;
@synthesize maximumScaleDistance;
@synthesize minimumScaleFactor, maximumRotationAngle;
@synthesize updateFrequency;
@synthesize coordinates = ar_coordinates;
@synthesize locationDelegate, accelerometerDelegate;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        ar_coordinates = [[NSMutableArray alloc] init];
        ar_coordinateViews = [[NSMutableArray alloc] init];
        
        _updateTimer = nil;
        self.updateFrequency = 1 / 20.0;
        self.scaleViewsBasedOnDistance = NO;
        self.maximumScaleDistance = 0.0;
        self.minimumScaleFactor = 1.0;	
        self.rotateViewsBasedOnPerspective = NO;
        self.maximumRotationAngle = M_PI / 6.0;
        self.wantsFullScreenLayout = NO; //YES;
        [self startListening];		
        
        overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        self.view = overlayView;
    }
    return self;
}

- (id)initWithLocationManager:(CLLocationManager *)manager {
	
	if (!(self = [super init])) return nil;
	
	//use the passed in location manager instead of ours.
	self.locationManager = manager;
	self.locationManager.delegate = self;
	
	self.locationDelegate = self;
	
	return self;
}

- (void)dealloc
{
	[ar_coordinateViews release];
	[ar_coordinates release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
	[overlayView release];
	overlayView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidAppear:(BOOL)animated 
{
    if (!_updateTimer) {
        _updateTimer = [[NSTimer scheduledTimerWithTimeInterval:self.updateFrequency
                                                         target:self
                                                       selector:@selector(updateLocations:)
                                                       userInfo:nil
                                                        repeats:YES] retain];
    }
    
    [super viewDidAppear:animated];
}

- (void)setNewUpdateFrequency:(double)newUpdateFrequency {
	
	updateFrequency = newUpdateFrequency;
	
	if (!_updateTimer) return;
	
	[_updateTimer invalidate];
	[_updateTimer release];
	
	_updateTimer = [[NSTimer scheduledTimerWithTimeInterval:self.updateFrequency
													 target:self
												   selector:@selector(updateLocations:)
												   userInfo:nil
													repeats:YES] retain];
}

- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate {
	double centerAzimuth = self.centerCoordinate.azimuth;
	double leftAzimuth = centerAzimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) {
		leftAzimuth = 2 * M_PI + leftAzimuth;
	}
	
	double rightAzimuth = centerAzimuth + VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (rightAzimuth > 2 * M_PI) {
		rightAzimuth = rightAzimuth - 2 * M_PI;
	}
	
	BOOL result = (coordinate.azimuth > leftAzimuth && coordinate.azimuth < rightAzimuth);
	
	if(leftAzimuth > rightAzimuth) {
		result = (coordinate.azimuth < rightAzimuth || coordinate.azimuth > leftAzimuth);
	}
	
	double centerInclination = self.centerCoordinate.inclination;
	double bottomInclination = centerInclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	double topInclination = centerInclination + VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	//check the height.
	result = result && (coordinate.inclination > bottomInclination && coordinate.inclination < topInclination);
	
	//NSLog(@"coordinate: %@ result: %@", coordinate, result?@"YES":@"NO");
	
	return result;
}

- (void)startListening {
	
	//start our heading readings and our accelerometer readings.
	
	if (!self.locationManager) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		
		//we want every move.
		self.locationManager.headingFilter = kCLHeadingFilterNone;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		
		[self.locationManager startUpdatingHeading];
        
		// also start updating location
		[locationManager setDistanceFilter:kCLDistanceFilterNone];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[self.locationManager startUpdatingLocation];
	}
	
	//steal back the delegate.
	self.locationManager.delegate = self;
	
	if (!self.accelerometerManager) {
		self.accelerometerManager = [UIAccelerometer sharedAccelerometer];
		self.accelerometerManager.updateInterval = 0.01;
		self.accelerometerManager.delegate = self;
	}
	
	if (!self.centerCoordinate) {
		self.centerCoordinate = [ARCoordinate coordinateWithRadialDistance:0 inclination:0 azimuth:0];
	}
}

- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARCoordinate *)coordinate {
	
	CGPoint point;
	
	//x coordinate.
	
	double pointAzimuth = coordinate.azimuth;
	
	//our x numbers are left based.
	double leftAzimuth = self.centerCoordinate.azimuth - VIEWPORT_WIDTH_RADIANS / 2.0;
	
	if (leftAzimuth < 0.0) {
		leftAzimuth = 2 * M_PI + leftAzimuth;
	}
	
	if (pointAzimuth < leftAzimuth) {
		//it's past the 0 point.
		point.x = ((2 * M_PI - leftAzimuth + pointAzimuth) / VIEWPORT_WIDTH_RADIANS) * realityView.frame.size.width;
	} else {
		point.x = ((pointAzimuth - leftAzimuth) / VIEWPORT_WIDTH_RADIANS) * realityView.frame.size.width;
	}
	
	//y coordinate.
	
	double pointInclination = coordinate.inclination;
	
	double topInclination = self.centerCoordinate.inclination - VIEWPORT_HEIGHT_RADIANS / 2.0;
	
	point.y = realityView.frame.size.height - ((pointInclination - topInclination) / VIEWPORT_HEIGHT_RADIANS) * realityView.frame.size.height;
	
	return point;
}

#define kFilteringFactor 0.05
UIAccelerationValue rollingX, rollingZ;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	// -1 face down.
	// 1 face up.
	
	//update the center coordinate.
	
	//NSLog(@"x: %f y: %f z: %f", acceleration.x, acceleration.y, acceleration.z);
	
	//this should be different based on orientation.
	
	rollingZ  = (acceleration.z * kFilteringFactor) + (rollingZ  * (1.0 - kFilteringFactor));
    rollingX = (acceleration.y * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
	
	if (rollingZ > 0.0) {
		self.centerCoordinate.inclination = atan(rollingX / rollingZ) + M_PI / 2.0;
	} else if (rollingZ < 0.0) {
		self.centerCoordinate.inclination = atan(rollingX / rollingZ) - M_PI / 2.0;// + M_PI;
	} else if (rollingX < 0) {
		self.centerCoordinate.inclination = M_PI/2.0;
	} else if (rollingX >= 0) {
		self.centerCoordinate.inclination = 3 * M_PI/2.0;
	}
	
	if (self.accelerometerDelegate && [self.accelerometerDelegate respondsToSelector:@selector(accelerometer:didAccelerate:)]) {
		//forward the acceleromter.
		[self.accelerometerDelegate accelerometer:accelerometer didAccelerate:acceleration];
	}
}

NSComparisonResult LocationSortClosestFirst(ARCoordinate *s1, ARCoordinate *s2, void *ignore) {
    if (s1.radialDistance < s2.radialDistance) {
		return NSOrderedAscending;
	} else if (s1.radialDistance > s2.radialDistance) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

- (void)addCoordinate:(ARCoordinate *)coordinate {
    // error checking for null coordinates
    if (coordinate == 0)
    {
        ARCoordinate * tmp = [[ARCoordinate alloc] init];
        [tmp setTitle:@"Invalid coordinate"];
        [tmp setGeoLocation:centerLocation];
        
        [ar_coordinates addObject:tmp];
        [ar_coordinateViews addObject:[tmp viewForCoordinate]];
        [tmp release];
    }
    else
    {
        [ar_coordinates addObject:coordinate];
    
        if (coordinate.radialDistance > self.maximumScaleDistance) {
            self.maximumScaleDistance = coordinate.radialDistance;
        }
	
        [ar_coordinateViews addObject:[coordinate viewForCoordinate]];
    }
}

- (void)addCoordinates:(NSArray *)newCoordinates {
	//go through and add each coordinate.
	for (ARCoordinate *coordinate in newCoordinates) {
		[self addCoordinate:coordinate];
	}
}

- (void)removeCoordinate:(ARCoordinate *)coordinate {
	[ar_coordinates removeObject:coordinate];
}

- (void)removeCoordinates:(NSArray *)coordinates {	
	for (ARCoordinate *coordinateToRemove in coordinates) {
		NSUInteger indexToRemove = [ar_coordinates indexOfObject:coordinateToRemove];
		
		//TODO: Error checking in here.
		
		[ar_coordinates removeObjectAtIndex:indexToRemove];
		[ar_coordinateViews removeObjectAtIndex:indexToRemove];
	}
}

-(void)removeAllCoordinates {
	while( [ar_coordinates count] > 0)
	{
		[ar_coordinates removeLastObject];
		[ar_coordinateViews removeLastObject];
	}
}

- (void)updateLocations:(NSTimer *)timer {
	//update locations!
	
	if (!ar_coordinateViews || ar_coordinateViews.count == 0) {
		return;
	}
	
	int index = 0;
	for (ARCoordinate *item in ar_coordinates) {
		UIView *viewToDraw = [ar_coordinateViews objectAtIndex:index];
		
		if ([self viewportContainsCoordinate:item]) {
			
			CGPoint loc = [self pointInView:overlayView forCoordinate:item];
			
			//NSLog(@"index %d item title %@ INSIDE", index, [item title]);
			
			CGFloat scaleFactor = 1.0;
			if (self.scaleViewsBasedOnDistance) {
                if (self.maximumScaleDistance != 0)
                    scaleFactor = 1.0 - self.minimumScaleFactor * (item.radialDistance / self.maximumScaleDistance);
			}
			
			float width = viewToDraw.bounds.size.width * scaleFactor;
			float height = viewToDraw.bounds.size.height * scaleFactor;
			
			viewToDraw.frame = CGRectMake(loc.x - width / 2.0, loc.y - height / 2.0, width, height);
            
			CATransform3D transform = CATransform3DIdentity;
			
			//set the scale if it needs it.
			if (self.scaleViewsBasedOnDistance) {
				//scale the perspective transform if we have one.
				transform = CATransform3DScale(transform, scaleFactor, scaleFactor, scaleFactor);
			}
			
			if (self.rotateViewsBasedOnPerspective) {
				transform.m34 = 1.0 / 300.0;
				
				double itemAzimuth = item.azimuth;
				double centerAzimuth = self.centerCoordinate.azimuth;
				if (itemAzimuth - centerAzimuth > M_PI) centerAzimuth += 2*M_PI;
				if (itemAzimuth - centerAzimuth < -M_PI) itemAzimuth += 2*M_PI;
				
				double angleDifference = itemAzimuth - centerAzimuth;
				transform = CATransform3DRotate(transform, self.maximumRotationAngle * angleDifference / (VIEWPORT_HEIGHT_RADIANS / 2.0) , 0, 1, 0);
			}
			
			viewToDraw.layer.transform = transform;
			
			//if we don't have a superview, set it up.
			if (!(viewToDraw.superview)) {
				[overlayView addSubview:viewToDraw];
				[overlayView sendSubviewToBack:viewToDraw];
			}
			
		} else {
			//NSLog(@"index %d item title %@ OUTSIDE", index, [item title]);
			[viewToDraw removeFromSuperview];
			viewToDraw.transform = CGAffineTransformIdentity;
		}
		index++;
	}
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
	self.centerCoordinate.azimuth = fmod(newHeading.magneticHeading, 360.0) * (2 * (M_PI / 360.0));
	
	if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
		//forward the call.
		[self.locationDelegate locationManager:manager didUpdateHeading:newHeading];
	}
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	
	if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(locationManagerShouldDisplayHeadingCalibration:)]) {
		//forward the call.
		return [self.locationDelegate locationManagerShouldDisplayHeadingCalibration:manager];
	}
	
	return YES;
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
		//forward the call.
		return [self.locationDelegate locationManager:manager didFailWithError:error];
	}
}


-(int)totalCoordinates{
	return [ar_coordinates count]+1;
}

- (void)setCenterLocation:(CLLocation *)newLocation {
	[centerLocation release];
	centerLocation = [newLocation retain];
	
	for (ARCoordinate *geoLocation in self.coordinates) {
		if ([geoLocation isKindOfClass:[ARCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
			
			if (geoLocation.radialDistance > self.maximumScaleDistance) {
				self.maximumScaleDistance = geoLocation.radialDistance;
			}
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
		//forward the call.
		[self.locationDelegate locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
	}
	
	[self foundLocation:newLocation];
}


// BOBBY'S CODE
- (void)foundLocation:(CLLocation *)newLocation{
	
	// implement function so when locationManager forwards this info, we can do something with it
	
	// display location
	//CLLocationCoordinate2D latlong = [centerLocation coordinate];
	//[locationText setText:[NSString stringWithFormat:@"Current Location: %f %f", latlong.latitude, latlong.longitude]];
	
	[self setCenterLocation:newLocation];
}

-(ARCoordinate*)createCoordinateWithLabel:(NSString*)label{
    
	// save coordinates
	CLLocationCoordinate2D currLatLong = [centerLocation coordinate];
	NSLog(@"Current location: %f %f", currLatLong.latitude, currLatLong.longitude);
	
	// add new coordinate
	CLLocation *tempLocation;
	ARCoordinate *tempCoordinate;
	
	tempLocation = [[CLLocation alloc] initWithLatitude:currLatLong.latitude longitude:currLatLong.longitude];
	tempCoordinate = [[ARCoordinate coordinateWithLocation:tempLocation] retain];
	[tempLocation release];		
    [tempCoordinate setTitle:label];
    
	NSLog(@"Set item %d: title %@", [self totalCoordinates] , [tempCoordinate title]) ;
	
	[self addCoordinate:tempCoordinate];
	[tempCoordinate autorelease];
    return tempCoordinate;
}

@end
