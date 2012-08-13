//
//  StixEditorViewController.h
//  Stixx
//
//  Created by Bobby Ren on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#ifndef STIX_EDITOR_VIEW_CONTROLLER_H
#define STIX_EDITOR_VIEW_CONTROLLER_H

#import <UIKit/UIKit.h>
#import "StixPanelView.h"
#import "GlobalHeaders.h"
#import "Tag.h"
#import "StixView.h"
#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"
#import "UIImage+RoundedCorner.h"
#import "LoadingAnimationView.h"
#import "FlurryAnalytics.h"

@protocol StixEditorDelegate <NSObject>

-(void)didCloseEditor;

@optional

// for optimization
-(void)didGetHighResImage:(UIImage*)highResImage forTagID:(NSNumber*)tagID;
-(void)didRemixNewPix:(Tag*)cameraTag remixMode:(int)remixMode;
-(NSString*)getUsername;
@end

@interface StixEditorViewController : UIViewController <StixPanelDelegate, StixViewDelegate, KumulosHelperDelegate, UIAlertViewDelegate>
{
    IBOutlet UIImageView * imageView;
    IBOutlet UIButton * buttonDelete;
    IBOutlet UIButton * buttonClear;
    IBOutlet UIButton * buttonAddstix;
    IBOutlet UIButton * buttonSave;
    IBOutlet UIButton * buttonClose;
    
    StixPanelView * stixPanel;
    StixView * stixView;
    
    NSObject<StixEditorDelegate> * __unsafe_unretained appDelegate;
    
    LoadingAnimationView * activityIndicator;
    
    BOOL isLoadingPixSource;
    int remixMode;
    Tag * remixTag;
}

@property (nonatomic) IBOutlet UIImageView * imageView;
@property (nonatomic) IBOutlet UIButton * buttonDelete;
@property (nonatomic) IBOutlet UIButton * buttonClear;
@property (nonatomic) IBOutlet UIButton * buttonAddstix;
@property (nonatomic) IBOutlet UIButton * buttonSave;
@property (nonatomic) IBOutlet UIButton * buttonClose;
@property (nonatomic) StixPanelView * stixPanel;
@property (nonatomic) StixView * stixView;
@property (nonatomic, unsafe_unretained) NSObject<StixEditorDelegate> * appDelegate;
@property (nonatomic) Tag * remixTag;
@property (nonatomic, assign) int remixMode;

-(IBAction)didClickButtonDelete:(id)sender;
-(IBAction)didClickButtonClear:(id)sender;
-(IBAction)didClickButtonAddStix:(id)sender;
-(IBAction)didClickButtonSave:(id)sender;
-(IBAction)didClickButtonClose:(id)sender;

//-(void)initializeWithTag:(Tag*)tag remixMode:(int)remixMode;
-(void)saveRemixedPix;

-(void)disableButtonDelete;
-(void)disableButtonClear;
-(void)enableButtonDelete;
-(void)enableButtonClear;
@end

#endif