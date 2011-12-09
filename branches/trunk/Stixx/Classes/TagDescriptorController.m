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
@synthesize locationField;
@synthesize buttonOK;
@synthesize buttonCancel;
@synthesize delegate;
@synthesize badgeFrame, badgeType;

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
    UIImage * tmp = [[ImageCache sharedImageCache] imageForKey:@"newImage"];
	[imageView setImage:tmp];
    NSLog(@"TagDescriptor: Setting imageView to image of dims %f %f", tmp.size.width, tmp.size.height); 

    UIImageView * stix = [[self populateWithBadge:badgeType withCount:1 atLocationX:badgeFrame.origin.x andLocationY:badgeFrame.origin.y] retain];    
    [imageView addSubview:stix];
    [stix release];
    NSLog(@"TagDescriptor: imageView dims %f %f badge at %f %f", imageView.frame.size.width, imageView.frame.size.height, badgeFrame.origin.x, badgeFrame.origin.y);
    //[badge release];
	[commentField setDelegate:self];

//#if TARGET_IPHONE_SIMULATOR
    //[locationField addTarget:self action:@selector(locationTextBoxEntered:) forControlEvents:UIControlEventEditingDidBegin]; // added in xib
    locationController = [[LocationHeaderViewController alloc] init];
    [locationController setDelegate:self];
//#endif
}

-(UIImageView *)populateWithBadge:(int)type withCount:(int)count atLocationX:(int)x andLocationY:(int)y {
    float item_width = imageView.frame.size.width;
    float item_height = imageView.frame.size.height;
    
    UIImageView * stix = [[BadgeView getBadgeOfType:type] retain];
    //[stix setBackgroundColor:[UIColor whiteColor]]; // for debug
    float originX = x;
    float originY = y;
    NSLog(@"Adding badge to %d %d in image of size %f %f", x, y, item_width, item_height);
    stix.frame = CGRectMake(originX, originY, stix.frame.size.width, stix.frame.size.height);
    
    // scale stix and label down to 270x270 which is the size of the feedViewItem
    CGSize originalSize = CGSizeMake(300, 300);
	CGSize targetSize = CGSizeMake(item_width, item_height);
	
	float imageScale =  targetSize.width / originalSize.width;
    
	CGRect stixFrameScaled = stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    NSLog(@"Scaling badge of %f %f in image %f %f down to %f %f in image %f %f", stix.frame.size.width, stix.frame.size.height, 300.0, 300.0, stixFrameScaled.size.width, stixFrameScaled.size.height, item_width, item_height); 
    [stix setFrame:stixFrameScaled];
    
    // change comment field prompt based on stix
    switch (type) {
        case BADGE_TYPE_FIRE:
            [commentField setPlaceholder:@"What's Hot Here?"];
            break;
        case BADGE_TYPE_ICE:
            [commentField setPlaceholder:@"What's Not Hot?"];
            break;
        case BADGE_TYPE_HEART:
            [commentField setPlaceholder:@"What Do You Love?"];
            break;
        case BADGE_TYPE_LEAF:
            [commentField setPlaceholder:@"What's Natural Here?"];
            break;
            
        default:
            break;
    }
    return [stix autorelease];
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
	[self.delegate didAddDescriptor:[commentField text] andLocation:[[locationField titleLabel] text]];
}

-(IBAction)buttonCancelPressed:(id)sender
{
	//[self.delegate didAddDescriptor:nil];
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)locationTextBoxEntered:(id)sender
{   
    [commentField resignFirstResponder];
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
    [locationField setTitle:location forState:UIControlStateNormal];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)didCancelLocation
{
    [self.locationField resignFirstResponder];
	//[self.delegate didAddDescriptor:nil];
}

@end

