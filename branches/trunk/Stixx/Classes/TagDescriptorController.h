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

@protocol TagDescriptorDelegate
-(void)didAddDescriptor:(NSString*)descriptor andLocation:(NSString*)location;
@end

@interface TagDescriptorController : UIViewController <UITextFieldDelegate, LocationHeaderViewControllerDelegate>{
	IBOutlet UIImageView * imageView;
	IBOutlet UITextField * commentField;
	IBOutlet UIButton * locationField; // not editable
	IBOutlet UIButton * buttonOK;
	IBOutlet UIButton * buttonCancel;
	
    LocationHeaderViewController * locationController;
    
    CGRect badgeFrame;
    int badgeType;
    
	NSObject<TagDescriptorDelegate> *delegate;
}

@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UITextField * commentField;
@property (nonatomic, retain) IBOutlet UIButton * locationField;
@property (nonatomic, retain) IBOutlet UIButton * buttonOK;
@property (nonatomic, retain) IBOutlet UIButton * buttonCancel;
@property (nonatomic, assign) NSObject<TagDescriptorDelegate> *delegate;
@property (nonatomic, assign) CGRect badgeFrame;
@property (nonatomic, assign) int badgeType;

-(IBAction)buttonOKPressed:(id)sender;
-(IBAction)locationTextBoxEntered:(id)sender;
-(IBAction)buttonCancelPressed:(id)sender;
-(UIImageView *)populateWithBadge:(int)type withCount:(int)count atLocationX:(int)x andLocationY:(int)y;
@end
