//
//  LocationHeaderViewController.h
//  Stixx
//
//  Created by Bobby Ren on 12/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "LocationViewController.h"

@protocol LocationHeaderViewControllerDelegate 
-(void)didChooseLocation:(NSString*)location;
-(void)didCancelLocation;
-(void)didReceiveConnectionError;
-(void)closeAllKeyboards;
@end

@interface LocationHeaderViewController : UIViewController <UITextFieldDelegate,   
    UISearchDisplayDelegate, UISearchBarDelegate, LocationViewControllerDelegate>{

    NSObject<LocationHeaderViewControllerDelegate> *delegate;
    NSString *savedSearchTerm;
    IBOutlet UISearchBar *mySearchBar;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIButton * manualEnterLocationButton;
    IBOutlet UITextField * locationInputField;
    
    LocationViewController * locationController;
    
    LoadingAnimationView * activityIndicator;
}

@property(nonatomic, assign) NSObject<LocationHeaderViewControllerDelegate> *delegate;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic, retain) LoadingAnimationView * activityIndicator;
@property (nonatomic, retain) IBOutlet UISearchBar * mySearchBar;
@property (nonatomic, retain) IBOutlet UIButton * cancelButton;
@property (nonatomic, retain) IBOutlet UIButton * manualEnterLocationButton;
@property (nonatomic, retain) LocationViewController * locationController;
@property (nonatomic, retain) IBOutlet UITextField * locationInputField;

-(IBAction)didClickManualButton:(id)sender;
-(IBAction)didClickCancelButton:(id)sender;

@end
