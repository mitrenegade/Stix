//
//  LocationViewController.h
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FourSquareLocator.h"

@protocol LocationViewControllerDelegate
-(void)didChooseLocation:(NSString*)location;
-(void)didReceiveConnectionError;
-(void)didReceiveSearchResults;
@end

@interface LocationViewController : UITableViewController<VenueDelegate, UITableViewDataSource, UITableViewDelegate> {

    NSObject<LocationViewControllerDelegate> *delegate;
    FourSquareLocator* fsl;
    NSMutableArray * fsLocationStrings;
    NSMutableArray *searchResults;
    bool searching;
    bool letUserSelectRow;
    bool needSearch; // used to cancel a search if cancel button is hit in delegate

}

@property (nonatomic, assign) NSObject<LocationViewControllerDelegate> *delegate;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, assign) bool needSearch;

-(void)getFoursquareVenues:(NSString*)text;
-(void)receiveVenueNames:(NSArray *)venueNames andLatLong:(NSArray *)latlong;
-(void)clearSearchResults;
@end
