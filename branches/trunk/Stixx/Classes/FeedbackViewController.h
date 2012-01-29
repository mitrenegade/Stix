//
//  FeedbackViewController.h
//  Stixx
//
//  Created by Bobby Ren on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

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

    NSObject<FeedbackViewDelegate> * delegate;    
}

@property (nonatomic, retain) IBOutlet UITextView * messageView;
@property (nonatomic, retain) IBOutlet UIButton * buttonFeedback;
@property (nonatomic, retain) IBOutlet UIButton * buttonBug;
@property (nonatomic, assign) NSObject<FeedbackViewDelegate> * delegate;    

-(IBAction)didClickFeedbackButton:(id)sender;
-(IBAction)didClickBugButton:(id)sender;
-(IBAction)didClickBackButton:(id)sender;
-(IBAction)didClickSubmitButton:(id)sender;
@end
