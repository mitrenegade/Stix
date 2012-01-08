//
//  AuxStixViewController.h
//  Stixx
//
//  Created by Bobby Ren on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StixView.h"
#import "Tag.h"

@protocol AuxStixViewControllerDelegate 

-(void)didAddAuxStixWithStixStringID:(NSString*)stixStringID withLocation:(CGPoint)location withScale:(float)scale withRotation:(float)rotation withComment:(NSString*)comment;

@end

@interface AuxStixViewController : UIViewController <UITextFieldDelegate> {
    
	IBOutlet UIImageView * imageView;
    IBOutlet StixView * stixView;
	IBOutlet UITextField * commentField;
	IBOutlet UIButton * buttonOK;
	IBOutlet UIButton * buttonCancel;
    IBOutlet UIButton * buttonInstructions;
    
    // new stix being added to this view
    UIImageView * stix;
    CGRect badgeFrame;
    NSString * stixStringID;
    
    int drag;
    float offset_x;
    float offset_y;
    float auxScale;
    float auxRotation;
    
	NSObject<AuxStixViewControllerDelegate> *delegate;
}

@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UITextField * commentField;
@property (nonatomic, retain) IBOutlet UIButton * buttonOK;
@property (nonatomic, retain) IBOutlet UIButton * buttonCancel;
@property (nonatomic, assign) NSObject<AuxStixViewControllerDelegate> *delegate;
@property (nonatomic, assign) CGRect badgeFrame;
@property (nonatomic, retain) NSString * stixStringID;
@property (nonatomic, retain) UIImageView * stix;
@property (nonatomic, retain) IBOutlet UIButton * buttonInstructions;
@property (nonatomic, retain) IBOutlet StixView * stixView;

-(IBAction)buttonOKPressed:(id)sender;
-(IBAction)buttonCancelPressed:(id)sender;
-(IBAction)closeInstructions:(id)sender;

-(void)initStixView:(Tag *) tag;
-(void)addNewAuxStix:(UIImageView *)newStix ofType:(NSString*)newStixStringID atLocation:(CGPoint)location;
@end
