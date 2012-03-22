//
//  ARViewController.h
//  ARKitDemo
//
//  Created by Administrator on 9/17/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARCoordinate.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define VIEWPORT_WIDTH_RADIANS .5
#define VIEWPORT_HEIGHT_RADIANS .7392

@protocol ARViewDelegate 
    // nothing
@end

@interface ARViewController : UIViewController  <UIAccelerometerDelegate, CLLocationManagerDelegate >{
	CLLocationManager *locationManager;
	UIAccelerometer *accelerometerManager;
	ARCoordinate *centerCoordinate;
	CLLocation *centerLocation; // need this?
    
	NSObject<CLLocationManagerDelegate> *locationDelegate;
	NSObject<UIAccelerometerDelegate> *accelerometerDelegate;
    NSObject<ARViewDelegate> *delegate;

	BOOL scaleViewsBasedOnDistance;
	double maximumScaleDistance;
	double minimumScaleFactor;
	
	//defaults to 20hz;
	double updateFrequency;
	
	BOOL rotateViewsBasedOnPerspective;
	double maximumRotationAngle;

	NSTimer *_updateTimer;
	
	NSMutableArray *ar_coordinates;
	NSMutableArray *ar_coordinateViews;
	UIView *overlayView;
}

@property (readonly) NSArray *coordinates;
@property BOOL scaleViewsBasedOnDistance;
@property double maximumScaleDistance;
@property double minimumScaleFactor;

@property BOOL rotateViewsBasedOnPerspective;
@property double maximumRotationAngle;

@property double updateFrequency;

@property (nonatomic, retain) CLLocation *centerLocation;
@property (nonatomic, assign) NSObject<CLLocationManagerDelegate> *locationDelegate;
@property (nonatomic, assign) NSObject<UIAccelerometerDelegate> *accelerometerDelegate;
@property (nonatomic, assign) NSObject<ARViewDelegate> *delegate;

@property (retain) ARCoordinate *centerCoordinate;

@property (nonatomic, retain) UIAccelerometer *accelerometerManager;
@property (nonatomic, retain) CLLocationManager *locationManager;

//adding coordinates to the underlying data model.
- (void)addCoordinate:(ARCoordinate *)coordinate;
- (void)addCoordinates:(NSArray *)newCoordinates;
- (ARCoordinate*)createCoordinateWithLabel:(NSString*)label;

//removing coordinates
- (void)removeCoordinate:(ARCoordinate *)coordinate;
- (void)removeCoordinates:(NSArray *)coordinates;
-(void)removeAllCoordinates;

-(int)totalCoordinates;

//location manager stuff
- (id)initWithLocationManager:(CLLocationManager *)manager;
- (void)startListening;
- (void)updateLocations:(NSTimer *)timer;
- (void)foundLocation:(CLLocation *)newLocation;
NSComparisonResult LocationSortClosestFirst(ARCoordinate *s1, ARCoordinate *s2, void *ignore);
- (CGPoint)pointInView:(UIView *)realityView forCoordinate:(ARCoordinate *)coordinate;
- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate;


@end
