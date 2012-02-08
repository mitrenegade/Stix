//
//  FeedbackViewController.m
//  Stixx
//
//  Created by Bobby Ren on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedbackViewController.h"

@implementation FeedbackViewController

@synthesize messageView;
//@synthesize pickerView;
@synthesize buttonFeedback, buttonBug;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    buttonFeedback = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonFeedback setImage:[UIImage imageNamed:@"radio_button_off.png"] forState:UIControlStateNormal];
    [buttonFeedback setImage:[UIImage imageNamed:@"radio_button_on.png"] forState:UIControlStateSelected];
    [buttonFeedback setFrame:CGRectMake(50, 70, 26, 26)];
    [buttonFeedback addTarget:self action:@selector(didClickFeedbackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonFeedback];

    buttonBug = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBug setImage:[UIImage imageNamed:@"radio_button_off.png"] forState:UIControlStateNormal];
    [buttonBug setImage:[UIImage imageNamed:@"radio_button_on.png"] forState:UIControlStateSelected];
    [buttonBug setFrame:CGRectMake(180, 70, 26, 26)];
    [buttonBug addTarget:self action:@selector(didClickBugButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonBug];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidAppear:(BOOL)animated {
    [self.buttonFeedback setSelected:YES];
    typeString = @"Feedback";
    [messageView.layer setCornerRadius:10];
    [messageView.layer setMasksToBounds:YES];
    [self.buttonBug setSelected:NO];
}

-(IBAction)didClickFeedbackButton:(id)sender {
    [self.buttonFeedback setSelected:YES];
    [self.buttonBug setSelected:NO];
    typeString = @"Feedback";
}

-(IBAction)didClickBugButton:(id)sender {
    [self.buttonBug setSelected:YES];
    [self.buttonFeedback setSelected:NO];
    typeString = @"Bug Report";
}

-(IBAction)didClickBackButton:(id)sender {
    [self.delegate didCancelFeedback];
}

-(IBAction)didClickSubmitButton:(id)sender {
    [self.delegate didSubmitFeedbackOfType:typeString withMessage:[self.messageView text]];
    [self textViewShouldEndEditing:[self messageView]];
    [self didClickBackButton:nil];
}

-(BOOL) textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

@end
