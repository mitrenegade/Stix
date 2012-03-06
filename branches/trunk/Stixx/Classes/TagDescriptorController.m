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
@synthesize selectedStixStringID;
//@synthesize stix;
@synthesize buttonInstructions;
@synthesize stixView;
@synthesize carouselView;

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
    [stixView initializeWithImage:tmp withContextFrame:frame];
    [stixView setInteractionAllowed:NO];
    [self.view addSubview:stixView];
    
    [self createCarouselView];
    
    drag = 0;
    selectedStixStringID = nil;
    
    // change comment field prompt based on stix
    /*
    if ([selectedStixStringID isEqualToString:@"FIRE"]) {
        [commentField setPlaceholder:@"What's Hot Here?"];
    } else if ([selectedStixStringID isEqualToString:@"ICE"]) {
        [commentField setPlaceholder:@"What's Not Hot?"];
    } else if ([selectedStixStringID isEqualToString:@"HEART"]) {
        [commentField setPlaceholder:@"What Do You Love?"];
    } else {
     */
        [commentField setPlaceholder:@"What's Here?"];
    //}
    [commentField2 setHidden:YES]; // hide for now
    
//#if TARGET_IPHONE_SIMULATOR
    //[locationField addTarget:self action:@selector(locationTextBoxEntered:) forControlEvents:UIControlEventEditingDidBegin]; // added in xib
    locationController = [[LocationHeaderViewController alloc] init];
    [locationController setDelegate:self];
//#endif
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [carouselView resetBadgeLocations];
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

// hack
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

-(IBAction)buttonOKPressed:(id)sender
{
    // scale stix frame back
	float imageScale = 1;// 300 / stixView.frame.size.width;
    CGRect stixFrameScaled = stixView.stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    float centerx = stixView.stix.center.x * imageScale; // center coordinates in original 300x275 space
    float centery = stixView.stix.center.y * imageScale;
    //float stixScale = [stixView stixScale];
    //float stixRotation = [stixView stixRotation];
    CGAffineTransform stixTransform = [stixView referenceTransform];
    //stix.frame = badgeFrame;
    //[stix setCenter:CGPointMake(centerx, centery)];
    NSLog(@"TagDescriptor: didAddDescriptor adding badge of size %f %f at %f %f in image size %f %f\n", stixFrameScaled.size.width, stixFrameScaled.size.height, centerx, centery, imageView.frame.size.width * imageScale, imageView.frame.size.height * imageScale);
	[self.delegate didAddDescriptor:[commentField text] andComment:[commentField2 text] andLocation:[locationField text] withStix:selectedStixStringID andStixCenter:CGPointMake(centerx, centery) /*andScale:stixScale andRotation:stixRotation*/ andTransform:stixTransform];
}

-(IBAction)buttonCancelPressed:(id)sender
{
	[self.delegate didCancelAddDescriptor];
    //[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)commentFieldExited:(id)sender {
    [(UITextField*)sender resignFirstResponder];
}

-(IBAction)locationTextBoxEntered:(id)sender
{   
    //[self presentModalViewController:locationController animated:YES];
    //[stixView setInteractionAllowed:NO];
    [self.view addSubview:locationController.view];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];

	return NO;
}

/*** LocationHeaderViewControllerDelegate ****/

-(void)closeAllKeyboards {
    [commentField resignFirstResponder];
    [commentField2 resignFirstResponder];
    [locationField resignFirstResponder];
}

-(void)didChooseLocation:(NSString *)location {
    NSLog(@"FourSquare locator returned %@\n", location);
    [locationField setText:location];
    //[self dismissModalViewControllerAnimated:YES];
    //[stixView setInteractionAllowed:YES];
    [locationController.view removeFromSuperview];
}

-(void)didCancelLocation
{
    [self.locationField resignFirstResponder];
}

-(IBAction)closeInstructions:(id)sender
{
    [buttonInstructions setHidden:YES];
}

-(void)didReceiveConnectionError {
    UIAlertView* alert = [[UIAlertView alloc]init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setTitle:@"Location error!"];
    [alert setMessage:@"Could not connect to location server!"];
    [alert show];
    [alert release];
}

/**** Carousel ****/

-(void)createCarouselView {
    if (carouselView != nil && [carouselView isKindOfClass:[CarouselView class]]) {
        [carouselView clearAllViews];
        [carouselView release];
    }
    carouselView = [[CarouselView alloc] initWithFrame:self.view.frame];
    carouselView.delegate = self;
    // to set the correct underlay:
    // if no underlay is set, the hittest order is carouselView->badgeView->self.view
    // but badgeView will incorrectly toggle a hit because it contains badgeFrames
    // so we make carouselView return its underlay to skip badgeView. If the underlay is
    // another subview in self.view's subview, it will then cause hittest to traverse
    // all of self.view's subviews after carouselView natually, thus enabling all other buttons
    // and touch interactions
    //    [carouselView setUnderlay:flashModeButton];
    [carouselView setDismissedTabY:420];
    [carouselView setExpandedTabY:350];
    [carouselView initCarouselWithFrame:CGRectMake(0,carouselView.dismissedTabY,320,SHELF_STIX_SIZE)];
    [carouselView setAllowTap:YES];
    [carouselView setTapDefaultOffset:CGPointMake(imageView.center.x / 2, imageView.center.y/2)];//carouselView.frame.origin.x - self.aperture.center.x, carouselView.frame.origin.y - self.aperture.center.y)];
    
    [self.view insertSubview:carouselView aboveSubview:stixView];
    [carouselView setUnderlay:stixView];
    //[delegate didCreateBadgeView:carouselView];
}

-(void)reloadCarouselView {
    // hack: if carouselView is not scrolling, it is being eclipsed by the tabbar
    [[self carouselView] reloadAllStix]; //WithFrame:CGRectMake(0,carouselView.dismissedTabY+60,320,SHELF_STIX_SIZE)];
    // HACK: make sure carouselView doesn't prevent other buttons from being touched
    // this is different because of the weird camera layer that doesn't exist in others (feedView, exploreView)
    [[self carouselView] removeFromSuperview];    
    [self.view insertSubview:carouselView aboveSubview:stixView];
}

// BadgeViewDelegate function
-(void)didTapStix:(UIImageView *)badge ofType:(NSString *)stixStringID {
    // selection of a stix to use from the carousel
    [self.carouselView carouselTabDismissWithStix:badge];
    [self.carouselView setStixSelected:stixStringID];
    if (didAddStixToStixView) {
        // we've already added a stix, so the only thing we can do is now change it
        selectedStixStringID = stixStringID;
        [self.stixView updateStixForManipulation:stixStringID];
    }
    else {
        CGPoint center = stixView.center;
        [self didDropStixByTap:stixStringID atLocation:center];
    }
}

-(void)didDropStixByTap:(NSString*)stixStringID atLocation:(CGPoint)location{
    // location is in TagDescriptorController's view
    CGPoint locationInStixView = location;
    locationInStixView.x -= stixView.frame.origin.x;
    locationInStixView.y -= stixView.frame.origin.y;
    [self addStixToStixView:stixStringID atLocation:locationInStixView];
}

-(void)didDropStixByDrag:(NSString*)stixStringID atLocation:(CGPoint)location {
    // location is in TagDescriptorController's view
    [carouselView carouselTabDismiss];
    [carouselView resetBadgeLocations];
    CGPoint locationInStixView = location;
    locationInStixView.x -= stixView.frame.origin.x;
    locationInStixView.y -= stixView.frame.origin.y;
    [self addStixToStixView:stixStringID atLocation:locationInStixView];
}

-(void)didDropStix:(UIImageView *)badge ofType:(NSString *)stixStringID {
    // delegate function for CarouselView 
    CGPoint location = badge.center;
    [self.carouselView resetBadgeLocations];
    if (!didAddStixToStixView) {
        [self didDropStixByDrag:stixStringID atLocation:location];
    }
}

-(void)addStixToStixView:(NSString*)stixStringID atLocation:(CGPoint)location {
    [stixView setInteractionAllowed:YES];
    [stixView populateWithStixForManipulation:stixStringID withCount:1 atLocationX:location.x andLocationY:location.y /*andScale:1 andRotation:0*/];
    didAddStixToStixView = YES;
    selectedStixStringID = stixStringID;
}

-(int)getStixCount:(NSString*)stixStringID {
    return [self.delegate getStixCount:stixStringID];
}

-(int)getStixOrder:(NSString*)stixStringID;
{
    return [self.delegate getStixOrder:stixStringID];
}

-(void)didStartDrag {
    [self.carouselView carouselTabDismiss];
    [self.buttonInstructions setHidden:YES];
}
-(void)didClickAtLocation:(CGPoint)location {
    // location is the click location inside feeditem's frame
    
    NSLog(@"TagDescriptorController: Click on view at position %f %f\n", location.x, location.y);
    NSLog(@"CarouselView: Stix Selected %@ count %d", carouselView.stixSelected, [self.delegate getStixCount:carouselView.stixSelected]);
    
    if (carouselView.stixSelected != nil && [self.delegate getStixCount:carouselView.stixSelected] != 0 && !didAddStixToStixView) {
        // if a stix was selected already from the carousel tab
        [self didDropStixByTap:[carouselView stixSelected] atLocation:location];
    }
    else {
        // auto take a photo?
        // focus?
    }
}

/** touch messages **/
// a single click on the camera should take a picture
// single click will trigger at the end of a drag motion
// unlike in VerticalFeedItemController because the table
// is not present here.
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	drag = 0;    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	drag = 1;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (drag != 1)
	{
        UITouch *touch = [[event allTouches] anyObject];	
        CGPoint location = [touch locationInView:self.view];
        [self didClickAtLocation:location];
    }
}

@end

