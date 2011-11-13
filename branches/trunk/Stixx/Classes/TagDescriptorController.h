//
//  TagDescriptorController.h
//  ARKitDemo
//
//  Created by Administrator on 7/18/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCache.h"

@protocol TagDescriptorDelegate
	-(void)didAddDescriptor:(NSString*)descriptor;
@end

@interface TagDescriptorController : UIViewController <UITextFieldDelegate>{
	IBOutlet UIImageView * imageView;
	IBOutlet UITextField * commentField;
	IBOutlet UIButton * buttonOK;
	IBOutlet UIButton * buttonCancel;
	
	NSObject<TagDescriptorDelegate> *delegate;
}

@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UITextField * commentField;
@property (nonatomic, retain) IBOutlet UIButton * buttonOK;
@property (nonatomic, retain) IBOutlet UIButton * buttonCancel;
@property (nonatomic, assign) NSObject<TagDescriptorDelegate> *delegate;

-(IBAction)buttonOKPressed:(id)sender;
-(IBAction)buttonCancelPressed:(id)sender;

@end
