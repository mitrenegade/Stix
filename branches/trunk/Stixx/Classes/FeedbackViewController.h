//
//  FeedbackViewController.h
//  Stixx
//
//  Created by Bobby Ren on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol FeedbackViewDelegate
    
-(void)didCancelFeedback;
-(void)didSubmitFeedbackOfType:(NSString*)type withMessage:(NSString*)message;

@end

@interface FeedbackViewController : UIViewController <UITextViewDelegate>
{
    IBOutlet UITextView * messageView;
    //IBOutlet UIPickerView * pickerView;
    
    IBOutlet UIButton * buttonFeedback;
    IBOutlet UIButton * buttonBug;
    NSString * typeString;

    NSObject<FeedbackViewDelegate> * __unsafe_unretained delegate;    
}

@property (nonatomic) IBOutlet UITextView * messageView;
@property (nonatomic) IBOutlet UIButton * buttonFeedback;
@property (nonatomic) IBOutlet UIButton * buttonBug;
@property (nonatomic, unsafe_unretained) NSObject<FeedbackViewDelegate> * delegate;    

-(IBAction)didClickFeedbackButton:(id)sender;
-(IBAction)didClickBugButton:(id)sender;
-(IBAction)didClickBackButton:(id)sender;
-(IBAction)didClickSubmitButton:(id)sender;
@end
