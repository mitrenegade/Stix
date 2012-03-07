//
//  AddStixViewController.m
//  Stixx
//
//  Created by Bobby Ren on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddStixViewController.h"

@implementation AddStixViewController


@synthesize imageView;
@synthesize commentField;
@synthesize commentField2;
@synthesize locationField, locationButton;
@synthesize buttonOK;
@synthesize buttonCancel;
@synthesize delegate;
@synthesize badgeFrame;
@synthesize buttonInstructions;
@synthesize stixView;
@synthesize carouselView;


/*** AUX STIX ***/

-(id)init
{
	// call superclass's initializer
	self = [super initWithNibName:@"AddStixViewController" bundle:nil];
    
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
    drag = 0;
    [commentField setPlaceholder:@"What's Here?"];
    locationController = [[LocationHeaderViewController alloc] init];
    [locationController setDelegate:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[imageView release];
	imageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)toggleCarouselView:(BOOL)carouselEnabled {
    [carouselView setHidden:!carouselEnabled];
    
}

-(void)initStixView:(Tag*)tag {
    UIImage * imageData = tag.image;
    
    // for the tag's primary stix
    //NSLog(@"AuxStix: Creating stix view of size %f %f", imageData.size.width, imageData.size.height);
    
    CGRect frame = [imageView frame];
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:NO]; // no dragging of stix already in stixView
    [stixView initializeWithImage:imageData];
    [stixView populateWithAuxStixFromTag:tag];
    [self.view addSubview:stixView];

    [self createCarouselView];
}

-(void)addNewAuxStix:(UIImageView *)newStix ofType:(NSString *)newStixStringID atLocation:(CGPoint)location {

#if 1
    [self addStixToStixView:newStixStringID atLocation:location];
#else
    
    badgeFrame = newStix.frame;
    // save frame of badge relative to cropped image
    // stix frame coming in relative to a full size 300x275 view at origin 0,0
	float imageScale = 1;// stixView.frame.size.width / 300;
    NSLog(@"AuxStix: badge of frame %f %f %f %f at location %f %f in view %f %f changed to frame %f %f %f %f at location %f %f in view %f %f\n", badgeFrame.origin.x, badgeFrame.origin.y, badgeFrame.size.width, badgeFrame.size.height, location.x, location.y, 300.0, 300.0, badgeFrame.origin.x * imageScale, badgeFrame.origin.y * imageScale, badgeFrame.size.width * imageScale, badgeFrame.size.height * imageScale, location.x * imageScale, location.y * imageScale, stixView.frame.size.width, stixView.frame.size.height);
    location.x *= imageScale; // scale to fit in stixView
    location.y *= imageScale;
    // location of stix should be in auxStix's frame, not stixView's frame
    //location.x += stixView.frame.origin.x; // move center into stixView in this view's reference
    //location.y += stixView.frame.origin.y;
    badgeFrame.size.width *= imageScale;
    badgeFrame.size.height *= imageScale;
    //auxScale = 1;
    //auxRotation = 0;
    
    // location is already the point inside stixFrame
    stixStringID = newStixStringID;
    stix = [[BadgeView getBadgeWithStixStringID:stixStringID] retain];
    [stix setFrame:badgeFrame];
    [stix setCenter:location];
    [self.view addSubview:stix];
    // display transform box 
    showTransformCanvas = YES;
    transformCanvas = nil;
    [self transformBoxShowAtFrame:stix.frame];
#endif
}

-(void)transformBoxShowAtFrame:(CGRect)frame {
    int canvasOffset = 5;
    CGRect frameCanvas = frame;
    frameCanvas.origin.x -= canvasOffset;
    frameCanvas.origin.y -= canvasOffset;
    frameCanvas.size.width += 2*canvasOffset;
    frameCanvas.size.height += 2*canvasOffset;
    transformCanvas = [[UIView alloc] initWithFrame:frameCanvas];
    [transformCanvas setAutoresizesSubviews:YES];
    frame.origin.x = canvasOffset;
    frame.origin.y = canvasOffset;
    CGRect frameInside = frame;
    frameInside.origin.x +=1;
    frameInside.origin.y +=1;
    frameInside.size.width -= 2;
    frameInside.size.height -=2;
    UIImageView * transformBox = [[UIImageView alloc] initWithFrame:frameInside];
    transformBox.backgroundColor = [UIColor clearColor];
    transformBox.layer.borderColor = [[UIColor whiteColor] CGColor];
    transformBox.layer.borderWidth = 2.0;
    
    UIImageView * transformBoxShadow = [[UIImageView alloc] initWithFrame:frame];
    transformBoxShadow.backgroundColor = [UIColor clearColor];
    transformBoxShadow.layer.borderColor = [[UIColor blackColor] CGColor];
    transformBoxShadow.layer.borderWidth = 4.0;
    
    [transformCanvas addSubview:transformBoxShadow];
    [transformCanvas addSubview:transformBox];
    UIImage * corners = [UIImage imageNamed:@"dot_boundingbox.png"];
    
    UIImageView * dot1 = [[UIImageView alloc] initWithImage:corners];
    UIImageView * dot2 = [[UIImageView alloc] initWithImage:corners];
    UIImageView * dot3 = [[UIImageView alloc] initWithImage:corners];
    UIImageView * dot4 = [[UIImageView alloc] initWithImage:corners];
    
    [transformCanvas addSubview:dot1];
    [transformCanvas addSubview:dot2];
    [transformCanvas addSubview:dot3];
    [transformCanvas addSubview:dot4];
    float width = frame.size.width / 5;
    float height = frame.size.height / 5;
    [dot1 setFrame:CGRectMake(0, 0, width, height)];
    [dot2 setFrame:CGRectMake(0, 0, width, height)];
    [dot3 setFrame:CGRectMake(0, 0, width, height)];
    [dot4 setFrame:CGRectMake(0, 0, width, height)];
    [dot1 setCenter:CGPointMake(frame.origin.x, frame.origin.y)];
    [dot2 setCenter:CGPointMake(frame.origin.x, frame.origin.y + frame.size.height)];
    [dot3 setCenter:CGPointMake(frame.origin.x+frame.size.width, frame.origin.y)];
    [dot4 setCenter:CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height)];
    
    [self.view addSubview:transformCanvas];
    
    [transformBox release];
    [transformBoxShadow release];
    [dot1 release];
    [dot2 release];
    [dot3 release];
    [dot4 release];
}
/*** dragging and resizing badge ***/
/** touch messages **/
// a single click on the camera should take a picture
// single click will trigger at the end of a drag motion
// unlike in VerticalFeedItemController because the table
// is not present here.
#if 0

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];	
	CGPoint location = [touch locationInView:self.view];
	drag = 0;
    tap = 0;
    
    [self closeInstructions:nil];
    
    if (CGRectContainsPoint(stix.frame, location))
    {
        tap = 1;
    }
    
    // point where finger clicked badge
    offset_x = (location.x - stix.center.x);
    offset_y = (location.y - stix.center.y);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (tap == 1 || drag == 1)
	{
        drag = 1;
        tap = 0;
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint location = [touch locationInView:self.view];
		// update frame of dragged badge, also scale
		//float scale = 1; // do not change scale while dragging
		if (!drag)
			return;
        
        float centerX = location.x - offset_x;
		float centerY = location.y - offset_y;
        
        // filter out rogue touches, usually when people are using a pinch
        if (abs(centerX - stix.center.x) > 50 || abs(centerY - stix.center.y) > 50) 
            return;
        
		stix.center = CGPointMake(centerX, centerY);
        
        if (transformCanvas) {
            [transformCanvas setCenter:stix.center];
        }
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (drag == 1)
	{
        tap = 0;
        drag = 0;
	}
    else if (tap == 1)
    {
        drag = 0;
        tap = 0;
        // single tap is equivalent to done
        //[self buttonOKPressed:self];
        
        UITouch *touch = [[event allTouches] anyObject];	
        CGPoint location = [touch locationInView:self.view];
        [self didClickAtLocation:location];
    }
}
#endif

-(IBAction)buttonOKPressed:(id)sender
{
    /*
	float imageScale = 1; // 300 / imageView.frame.size.width;
    
	CGRect stixFrameScaled = stix.frame;
    float centerX = stix.center.x - stixView.frame.origin.x;
    float centerY = stix.center.y - stixView.frame.origin.y;
    centerX *= imageScale;
    centerY *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    NSLog(@"AuxStix: set aux stix of size %f %f at %f %f in image size %f %f\n", stixFrameScaled.size.width, stixFrameScaled.size.height, centerX, centerY, imageView.frame.size.width * imageScale, imageView.frame.size.height * imageScale);
    
    // hack: debug to test display
    //auxRotation = 0; //3.1415/4;
    */

    // scale stix frame back
    float imageScale = 1;
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
	[self.delegate didAddDescriptor:[commentField text] andComment:[commentField2 text] andLocation:[locationField text]];
    [self.delegate didAddStixWithStixStringID:[stixView selectStixStringID] withLocation:CGPointMake(centerx, centery) withTransform:stixTransform];
}

-(IBAction)buttonCancelPressed:(id)sender
{
	[self.delegate didCancelAddStix];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	//NSLog(@"Comment entered: %@", [textField text]); 
	return YES;
}

-(IBAction)closeInstructions:(id)sender;
{
    [buttonInstructions setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [carouselView resetBadgeLocations];
}

- (void)dealloc {
    [super dealloc];
	
	[imageView release];
}

// hack
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
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
    [carouselView setDismissedTabY:400];
    [carouselView setExpandedTabY:330];
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

@end