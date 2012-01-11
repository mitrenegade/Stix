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
@synthesize stix;
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
#if 0
	[imageView setImage:tmp];
    float centerX = badgeFrame.origin.x + badgeFrame.size.width / 2;
    float centerY = badgeFrame.origin.y + badgeFrame.size.height / 2;

    NSLog(@"TagDescriptor: Setting imageView to image of dims %f %f with badge at %f %f", tmp.size.width, tmp.size.height, centerX, centerY); 
    
    stix = [[self populateWithBadge:stixStringID withCount:1 atLocationX:centerX andLocationY:centerY] retain];    
    [imageView addSubview:stix];
    [stix release];
#else                
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    int x = badgeFrame.origin.x + badgeFrame.size.width / 2;
    int y = badgeFrame.origin.y + badgeFrame.size.height / 2;
    [stixView initializeWithImage:tmp andStix:stixStringID withCount:1 atLocationX:x andLocationY:y andScale:1 andRotation:0];
    [self.view addSubview:stixView];
    
#endif
        
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
    //[commentField2 setHidden:YES]; // hide for now
    
//#if TARGET_IPHONE_SIMULATOR
    //[locationField addTarget:self action:@selector(locationTextBoxEntered:) forControlEvents:UIControlEventEditingDidBegin]; // added in xib
    locationController = [[LocationHeaderViewController alloc] init];
    [locationController setDelegate:self];
//#endif
}
#if 0
-(UIImageView *)populateWithBadge:(NSString*)stringID withCount:(int)count atLocationX:(int)x andLocationY:(int)y {

    float item_width = imageView.frame.size.width;
    float item_height = imageView.frame.size.height;
    
    UIImageView * newstix = [BadgeView getBadgeWithStixStringID:stringID];
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float centerX = x;
    float centerY = y;
    
    // scale stix and label down to 270x248 which is the size of the feedViewItem
    CGSize originalSize = CGSizeMake(300, 275);
	CGSize targetSize = CGSizeMake(item_width, item_height);
	
	float imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = newstix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    centerX *= imageScale;
    centerY *= imageScale;
    NSLog(@"TagDescriptorController: Scaling badge of %f %f at %f %f in image %f %f down to %f %f at %f %f in image %f %f", newstix.frame.size.width, newstix.frame.size.height, centerX / imageScale, centerY / imageScale, originalSize.width, originalSize.height, stixFrameScaled.size.width, stixFrameScaled.size.height, centerX, centerY, item_width, item_height); 
    [newstix setFrame:stixFrameScaled];
    [newstix setCenter:CGPointMake(centerX, centerY)];
    return newstix;
}
#endif
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
    // scale stix frame back
	float imageScale =  300 / stixView.frame.size.width;
    stix = stixView.stix;
	CGRect stixFrameScaled = stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    float centerx = stix.center.x * imageScale; // center coordinates in original 300x275 space
    float centery = stix.center.y * imageScale;
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

