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

    NSObject<LocationHeaderViewControllerDelegate> *__unsafe_unretained delegate;
    NSString *savedSearchTerm;
    IBOutlet UISearchBar *mySearchBar;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIButton * manualEnterLocationButton;
    IBOutlet UITextField * locationInputField;
    
    LocationViewController * locationController;
    
    LoadingAnimationView * activityIndicator;
}

@property(nonatomic, unsafe_unretained) NSObject<LocationHeaderViewControllerDelegate> *delegate;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) LoadingAnimationView * activityIndicator;
@property (nonatomic) IBOutlet UISearchBar * mySearchBar;
@property (nonatomic) IBOutlet UIButton * cancelButton;
@property (nonatomic) IBOutlet UIButton * manualEnterLocationButton;
@property (nonatomic) LocationViewController * locationController;
@property (nonatomic) IBOutlet UITextField * locationInputField;

-(IBAction)didClickManualButton:(id)sender;
-(IBAction)didClickCancelButton:(id)sender;

@end
