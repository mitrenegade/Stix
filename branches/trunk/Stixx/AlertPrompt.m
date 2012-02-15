//
//  AlertPrompt.m
//  Prompt
//
//  Created by Jeff LaMarche on 2/26/09.

#import "AlertPrompt.h"

@implementation AlertPrompt
@synthesize textField;
@synthesize enteredText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
        [theTextField.layer setCornerRadius:5];
        [theTextField.layer setMasksToBounds:YES];
        [theTextField setBackgroundColor:[UIColor whiteColor]]; 
        [theTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [theTextField setSecureTextEntry:YES];
        [self addSubview:theTextField];
        self.textField = theTextField;
        [theTextField release];
        //CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 50.0); 
        //[self setTransform:translate];
    }
    return self;
}
- (void)show
{
    [textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText
{
    return textField.text;
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [textField resignFirstResponder];
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

- (void)dealloc
{
    [textField resignFirstResponder];
    [textField release];
    [super dealloc];
}
@end
