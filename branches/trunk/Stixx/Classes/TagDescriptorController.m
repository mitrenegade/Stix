//
//  TagDescriptorController.m
//  ARKitDemo
//
//  Created by Administrator on 7/18/11.
//  Copyright 2011 Neroh. All rights reserved.
//

#import "TagDescriptorController.h"


@implementation TagDescriptorController

@synthesize imageView;
@synthesize commentField;
@synthesize buttonOK;
@synthesize buttonCancel;
@synthesize delegate;

-(id)init
{
	[super initWithNibName:@"TagDescriptorController" bundle:nil];

	return self;
}
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
        // Custom initialization.
//    }
//    return self;
//}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad]; 
	//imageView = [[UIImageView alloc] init]; // this is done automatically
#if 1
	[imageView setImage:[[ImageCache sharedImageCache] imageForKey:@"newImage"]];
#else
	NSString * str = @"sample.jpg";
	UIImage * tmpImage = [UIImage imageNamed:str];
	if (tmpImage == nil){
		NSLog(@"Could not load image!");
	} else {
		NSLog(@"Loaded %@", str);
	}
	[imageView setImage:tmpImage];
#endif
	
	[commentField setDelegate:self];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[imageView release];
	imageView = nil;
}

- (void)dealloc {
    [super dealloc];
	
	[imageView release];
}

-(IBAction)buttonOKPressed:(id)sender
{
	[self.delegate didAddDescriptor:[commentField text]];
}
-(IBAction)buttonCancelPressed:(id)sender
{
	//[self.delegate didAddDescriptor:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}
@end
