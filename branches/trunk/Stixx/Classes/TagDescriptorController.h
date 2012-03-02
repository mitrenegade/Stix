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
#import "CarouselView.h"

@protocol TagDescriptorDelegate
-(void)didAddDescriptor:(NSString*)descriptor andComment:(NSString *)comment andLocation:(NSString*)location withStix:(NSString*)stixStringID andStixCenter:(CGPoint) center /*andScale:(float)stixScale andRotation:(float)stixRotation*/ andTransform:(CGAffineTransform)stixTransform;
-(void)didCancelAddDescriptor;
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;
@end

@interface TagDescriptorController : UIViewController <BadgeViewDelegate, UITextFieldDelegate, LocationHeaderViewControllerDelegate>{
	IBOutlet UIImageView * imageView;
    StixView * stixView;
	IBOutlet UITextField * commentField;
	IBOutlet UITextField * commentField2;
	IBOutlet UITextField * locationField; 
    IBOutlet UIButton * locationButton;
	IBOutlet UIButton * buttonOK;
	IBOutlet UIButton * buttonCancel;
    IBOutlet UIButton * buttonInstructions;
    CarouselView * carouselView; // for dragging and releasing badge
    
    LocationHeaderViewController * locationController;
    
    CGRect badgeFrame;
    NSString * selectedStixStringID;
    
    int drag;
    float offset_x;
    float offset_y;
    
    bool shouldShowLocationView;
    bool didAddStixToStixView;
    
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
@property (nonatomic, retain) NSString * selectedStixStringID;
//@property (nonatomic, retain) UIImageView * stix;
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
@property (nonatomic, retain) StixView * stixView;
@property (nonatomic, retain) CarouselView * carouselView;

-(IBAction)buttonOKPressed:(id)sender;
-(IBAction)locationTextBoxEntered:(id)sender;
-(IBAction)buttonCancelPressed:(id)sender;
-(IBAction)commentFieldExited:(id)sender;
//-(UIImageView *)populateWithBadge:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y;
-(IBAction)closeInstructions:(id)sender;

-(void)createCarouselView;
-(void)reloadCarouselView;

-(void)addStixToStixView:(NSString*)stixStringID atLocation:(CGPoint)location;

@end
