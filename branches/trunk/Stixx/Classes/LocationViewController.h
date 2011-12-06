//
//  LocationViewController.h
//  Stixx
//
//  Created by Bobby Ren on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FourSquareLocator.h"
#import "LoadingAnimationView.h"

@protocol LocationViewControllerDelegate
-(void)didChooseLocation:(NSString*)location;
@end

@interface LocationViewController : UITableViewController<VenueDelegate, UITextFieldDelegate> {
    NSObject<LocationViewControllerDelegate> *delegate;
    FourSquareLocator* fsl;
    NSMutableArray * fsLocationStrings;
    UITextField * locationInput;
    UITextField * locationSearch;
    UIView * headerView;

    LoadingAnimationView * activityIndicator;
}

@property (nonatomic, assign) NSObject<LocationViewControllerDelegate> *delegate;
@property (nonatomic, retain) UITextField * locationInput;
@property (nonatomic, retain) UITextField * locationSearch;
@property (nonatomic, retain) UIView * headerView;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
-(void)didEnterSearch;
-(void)getFoursquareVenues:(NSString*)text;
-(void)receiveVenueNames:(NSArray *)venueNames;
-(void)didSelectLocationStringFromTableRow:(NSIndexPath *) indexPath;
-(void)didSelectLocationStringFromHeader;
@end
