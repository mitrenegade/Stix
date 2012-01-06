//
//  TagDescriptorController.h
//  ARKitDemo
//
//  Created by Administrator on 7/18/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCache.h"
#import "BadgeView.h"
#import "LocationHeaderViewController.h"
#import "StixView.h"

@protocol TagDescriptorDelegate
-(void)didAddDescriptor:(NSString*)descriptor andComment:(NSString *)comment andLocation:(NSString*)location andStixCenter:(CGPoint) center;
-(void)didCancelAddDescriptor;
@end

@interface TagDescriptorController : UIViewController <UITextFieldDelegate, LocationHeaderViewControllerDelegate>{
	IBOutlet UIImageView * imageView;
    StixView * stixView;
	IBOutlet UITextField * commentField;
	IBOutlet UITextField * commentField2;
	IBOutlet UITextField * locationField; 
    IBOutlet UIButton * locationButton;
	IBOutlet UIButton * buttonOK;
	IBOutlet UIButton * buttonCancel;
    IBOutlet UIButton * buttonInstructions;
    
    UIImageView * stix;
	
    LocationHeaderViewController * locationController;
    
    CGRect badgeFrame;
    NSString * stixStringID;
    
    int drag;
    float offset_x;
    float offset_y;
    
	NSObject<TagDescriptorDelegate> *delegate;
}

@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UITextField * commentField;
@property (nonatomic, retain) IBOutlet UITextField * commentField2;
@property (nonatomic, retain) IBOutlet UITextField * locationField;
@property (nonatomic, retain) IBOutlet UIButton * locationButton;
@property (nonatomic, retain) IBOutlet UIButton * buttonOK;
@property (nonatomic, retain) IBOutlet UIButton * buttonCancel;
@property (nonatomic, assign) NSObject<TagDescriptorDelegate> *delegate;
@property (nonatomic, assign) CGRect badgeFrame;
@property (nonatomic, retain) NSString * stixStringID;
@property (nonatomic, retain) UIImageView * stix;
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
@property (nonatomic, retain) StixView * stixView;

-(IBAction)buttonOKPressed:(id)sender;
-(IBAction)locationTextBoxEntered:(id)sender;
-(IBAction)buttonCancelPressed:(id)sender;
//-(UIImageView *)populateWithBadge:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y;
-(IBAction)closeInstructions:(id)sender;

@end
