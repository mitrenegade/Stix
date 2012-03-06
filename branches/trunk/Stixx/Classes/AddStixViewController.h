//
//  AddStixViewController.h
//  Stixx
//
//  Created by Bobby Ren on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCache.h"
#import "BadgeView.h"
#import "LocationHeaderViewController.h"
#import "StixView.h"
#import "CarouselView.h"
#import "Tag.h"
#import "QuartzCore/QuartzCore.h"

@protocol AddStixViewControllerDelegate

// tagdescriptor
-(void)didAddDescriptor:(NSString*)descriptor andComment:(NSString *)comment andLocation:(NSString*)location;
-(void)didAddStixWithStixStringID:(NSString*)stixStringID withLocation:(CGPoint)location withTransform:(CGAffineTransform)transform;

-(void)didCancelAddStix;
-(int)getStixCount:(NSString*)stixStringID;
-(int)getStixOrder:(NSString*)stixStringID;

@end

@interface AddStixViewController : UIViewController <BadgeViewDelegate, UITextFieldDelegate, LocationHeaderViewControllerDelegate, UIGestureRecognizerDelegate>{
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
    
    int tap;
    int drag;
    float offset_x;
    float offset_y;
    
    bool shouldShowLocationView;
    bool didAddStixToStixView;
    
	NSObject<AddStixViewControllerDelegate> *delegate;

    // new stix being added to this view
    bool showTransformCanvas;
    UIView * transformCanvas;
    
    NSMutableSet *_activeRecognizers;
}

@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UITextField * commentField;
@property (nonatomic, retain) IBOutlet UITextField * commentField2;
@property (nonatomic, retain) IBOutlet UITextField * locationField;
@property (nonatomic, retain) IBOutlet UIButton * locationButton;
@property (nonatomic, retain) IBOutlet UIButton * buttonOK;
@property (nonatomic, retain) IBOutlet UIButton * buttonCancel;
@property (nonatomic, assign) NSObject<AddStixViewControllerDelegate> *delegate;
@property (nonatomic, assign) CGRect badgeFrame;
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
@property (nonatomic, retain) StixView * stixView;
@property (nonatomic, retain) CarouselView * carouselView;

-(void)toggleCarouselView:(BOOL)carouselEnabled;

-(IBAction)closeInstructions:(id)sender;

-(void)initStixView:(Tag *) tag;
-(void)addNewAuxStix:(UIImageView *)newStix ofType:(NSString*)newStixStringID atLocation:(CGPoint)location;
-(void)transformBoxShowAtFrame:(CGRect)frame;

-(IBAction)buttonOKPressed:(id)sender;
-(IBAction)locationTextBoxEntered:(id)sender;
-(IBAction)buttonCancelPressed:(id)sender;
-(IBAction)commentFieldExited:(id)sender;
//-(UIImageView *)populateWithBadge:(NSString*)stixStringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y;
-(IBAction)closeInstructions:(id)sender;

-(void)createCarouselView;
-(void)reloadCarouselView;

-(void)didClickAtLocation:(CGPoint)location;
-(void)didDropStixByTap:(NSString*)stixStringID atLocation:(CGPoint)location;
-(void)addStixToStixView:(NSString*)stixStringID atLocation:(CGPoint)location;
-(void)didDropStixByDrag:(NSString*)stixStringID atLocation:(CGPoint)location;
-(void)didDropStix:(UIImageView *)badge ofType:(NSString *)stixStringID;

@end
