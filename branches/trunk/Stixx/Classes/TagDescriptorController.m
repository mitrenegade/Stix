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
@synthesize commentField2;
@synthesize locationField, locationButton;
@synthesize buttonOK;
@synthesize buttonCancel;
@synthesize delegate;
@synthesize badgeFrame;
@synthesize stixStringID;
//@synthesize stix;
@synthesize buttonInstructions;
@synthesize stixView;

-(id)init
{
	self = [super initWithNibName:@"TagDescriptorController" bundle:nil];
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
    UIImage * tmp = [[ImageCache sharedImageCache] imageForKey:@"newImage"];
           
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    int x = badgeFrame.origin.x + badgeFrame.size.width / 2;
    int y = badgeFrame.origin.y + badgeFrame.size.height / 2;
    [stixView initializeWithImage:tmp];
    [stixView populateWithStixForManipulation:stixStringID withCount:1 atLocationX:x andLocationY:y andScale:1 andRotation:0];
    [self.view addSubview:stixView];
    
    drag = 0;
    
    // change comment field prompt based on stix
    if ([stixStringID isEqualToString:@"FIRE"]) {
        [commentField setPlaceholder:@"What's Hot Here?"];
    } else if ([stixStringID isEqualToString:@"ICE"]) {
        [commentField setPlaceholder:@"What's Not Hot?"];
    } else if ([stixStringID isEqualToString:@"HEART"]) {
        [commentField setPlaceholder:@"What Do You Love?"];
    } else {
        [commentField setPlaceholder:@"What's Here?"];
    }
    [commentField2 setHidden:YES]; // hide for now
    
//#if TARGET_IPHONE_SIMULATOR
    //[locationField addTarget:self action:@selector(locationTextBoxEntered:) forControlEvents:UIControlEventEditingDidBegin]; // added in xib
    locationController = [[LocationHeaderViewController alloc] init];
    [locationController setDelegate:self];
//#endif
}
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
    // scale stix frame back
	float imageScale =  300 / stixView.frame.size.width;
    CGRect stixFrameScaled = stixView.stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    float centerx = stixView.stix.center.x * imageScale; // center coordinates in original 300x275 space
    float centery = stixView.stix.center.y * imageScale;
    float stixScale = [stixView stixScale];
    float stixRotation = [stixView stixRotation];
    //stix.frame = badgeFrame;
    //[stix setCenter:CGPointMake(centerx, centery)];
    NSLog(@"TagDescriptor: didAddDescriptor adding badge of size %f %f at %f %f in image size %f %f\n", stixFrameScaled.size.width, stixFrameScaled.size.height, centerx, centery, imageView.frame.size.width * imageScale, imageView.frame.size.height * imageScale);
	[self.delegate didAddDescriptor:[commentField text] andComment:[commentField2 text] andLocation:[locationField text] andStixCenter:CGPointMake(centerx, centery) andScale:stixScale andRotation:stixRotation];
}

-(IBAction)buttonCancelPressed:(id)sender
{
	[self.delegate didCancelAddDescriptor];
    //[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)locationTextBoxEntered:(id)sender
{   
    [commentField resignFirstResponder];
    [commentField2 resignFirstResponder];
    [locationField resignFirstResponder];
    [self presentModalViewController:locationController animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

/*** LocationHeaderViewControllerDelegate ****/

-(void)didChooseLocation:(NSString *)location {
    NSLog(@"FourSquare locator returned %@\n", location);
    [locationField setText:location];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)didCancelLocation
{
    [self.locationField resignFirstResponder];
	//[self.delegate didAddDescriptor:nil];
}

-(IBAction)closeInstructions:(id)sender
{
    [buttonInstructions setHidden:YES];
}

@end

