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
@synthesize blackBarView, priceView;

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
    //[commentField setPlaceholder:@"What's Here?"];
    //locationController = [[LocationHeaderViewController alloc] init];
    //[locationController setDelegate:self];
    
    blackBarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blackbar.png"]];
    [blackBarView setFrame:CGRectMake(0, 412, 320, 48)];
    
    priceView = [[UILabel alloc] initWithFrame:CGRectMake(260, 420, 80, 30)];
    [priceView setBackgroundColor:[UIColor clearColor]];
    [priceView setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [priceView setTextColor:[UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1]];
    
    buttonOK = [[UIButton alloc] initWithFrame:CGRectMake(184, 420, 36, 36)];
    [buttonOK setImage:[UIImage imageNamed:@"green_check.png"] forState:UIControlStateNormal];
    [buttonOK addTarget:self action:@selector(buttonOKPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(100, 420, 36, 36)];
    [buttonCancel setImage:[UIImage imageNamed:@"red_x.png"] forState:UIControlStateNormal];    
    [buttonCancel addTarget:self action:@selector(buttonCancelPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	imageView = nil;
    blackBarView = nil;
    priceView = nil;
    buttonOK = nil;
    buttonCancel = nil;
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
    if (stixView) {
        [stixView removeFromSuperview];
    }
    didAddStixToStixView = NO;
    
    stixView = [[StixView alloc] initWithFrame:frame];
    [stixView setInteractionAllowed:NO]; // no dragging of stix already in stixView
    [stixView initializeWithImage:imageData];
    [stixView populateWithAuxStixFromTag:tag];
    [self.view addSubview:stixView];
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
    
}

-(IBAction)buttonOKPressed:(id)sender
{
    // check to see if this sticker requires a purchase
    int cost = 5;
    if ((carouselView.stixSelected != nil) && [self.delegate getStixCount:carouselView.stixSelected] == 0) {
        if ([self.delegate getBuxCount] < cost) {
            UIAlertView* alert = [[UIAlertView alloc]init];
            [alert addButtonWithTitle:@"Ok"];
            [alert setTitle:@"Cannot use this Stix!"];
            [alert setMessage:@"You don't own this Stix and have no Bux to buy it! You can earn more Bux by using Stix you already own."];
            [alert show];
            return;
        }
        // purchase
        [self.delegate didPurchaseStixFromCarousel:carouselView.stixSelected];
    }
    
    // scale stix frame back
    float imageScale = 1;
    CGRect stixFrameScaled = stixView.stix.frame;
	stixFrameScaled.origin.x *= imageScale;
	stixFrameScaled.origin.y *= imageScale;
	stixFrameScaled.size.width *= imageScale;
	stixFrameScaled.size.height *= imageScale;
    float centerx = stixView.stix.center.x * imageScale; // center coordinates in original 300x275 space
    float centery = stixView.stix.center.y * imageScale;
    if (centerx == 0 && centery == 0) {
        NSLog(@"This sticker doesn't exist!");
    }
    //float stixScale = [stixView stixScale];
    //float stixRotation = [stixView stixRotation];
    CGAffineTransform stixTransform = [stixView referenceTransform];
    //stix.frame = badgeFrame;
    //[stix setCenter:CGPointMake(centerx, centery)];
    NSLog(@"TagDescriptor: didAddDescriptor adding badge of size %f %f at %f %f in image size %f %f\n", stixFrameScaled.size.width, stixFrameScaled.size.height, centerx, centery, imageView.frame.size.width * imageScale, imageView.frame.size.height * imageScale);
	[delegate didAddDescriptor:[commentField text] andComment:[commentField2 text] andLocation:[locationField text]];
    [delegate didAddStixWithStixStringID:[stixView selectStixStringID] withLocation:CGPointMake(centerx, centery) withTransform:stixTransform];
}

-(IBAction)buttonCancelPressed:(id)sender
{
    didAddStixToStixView = NO;
	[delegate didCancelAddStix];
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
}

/**** Carousel ****/
-(void)configureCarouselView{
    NSLog(@"ConfigureCarouselView by AddStixViewController");
    // reserves the carousel for self
    [self setCarouselView:[CarouselView sharedCarouselView]];
    carouselView.delegate = self;
    [carouselView setExpandedTabY:5-20+100]; // hack: a bit lower
    [carouselView setDismissedTabY:375-20];
    [carouselView setAllowTap:YES];
//    [carouselView setTapDefaultOffset:CGPointMake(imageView.center.x / 2, imageView.center.y/2)];//carouselView.frame.origin.x - self.aperture.center.x, carouselView.frame.origin.y - self.aperture.center.y)];
    
    [carouselView removeFromSuperview];
    [self.view insertSubview:carouselView aboveSubview:stixView];
    [carouselView setUnderlay:stixView];
    //[carouselView reloadAllStix];   
    
    // add others above carouselView
    [blackBarView removeFromSuperview];
    [priceView removeFromSuperview];
    [buttonOK removeFromSuperview];
    [buttonCancel removeFromSuperview];
    
    [self.view addSubview:blackBarView];
    [self.view addSubview:priceView];
    [self.view addSubview:buttonOK];
    [self.view addSubview:buttonCancel];
    
    [carouselView resetBadgeLocations];
}

// BadgeViewDelegate function
-(void)didTapStixOfType:(NSString *)stixStringID {
    // selection of a stix to use from the carousel
    //[self.carouselView carouselTabDismissWithStix:badge];
    //NSLog(@"DidTapStix: center %f %f, affine transform %f %f %f %f %f %f", badge.center.x, badge.center.y, badge.transform
      //    .a, badge.transform.b, badge.transform.c, badge.transform.d, badge.transform.tx, badge.transform.ty);
    [carouselView carouselTabDismiss:YES];
    [carouselView setStixSelected:stixStringID];
    if (didAddStixToStixView) {
        NSLog(@"updateStixForManipulation   : center %f %f, affine transform %f %f %f %f %f %f", stixView.stix.center.x, stixView.stix.center.y, stixView.stix.transform
              .a, stixView.stix.transform.b, stixView.stix.transform.c, stixView.stix.transform.d, stixView.stix.transform.tx, stixView.stix.transform.ty);
        // we've already added a stix, so the only thing we can do is now change it
        [stixView updateStixForManipulation:stixStringID];
    }
    else {
        CGPoint center = stixView.center;
        [self didDropStixByTap:stixStringID atLocation:center];
    }
    
    int count = [self.delegate getStixCount:stixStringID];
    if (count == 0) {
        [priceView setText:@"5 Bux"];
    }
    else
        [priceView setText:@""];
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
    [carouselView carouselTabDismiss:YES];
    [carouselView resetBadgeLocations];
    CGPoint locationInStixView = location;
    locationInStixView.x -= stixView.frame.origin.x;
    locationInStixView.y -= stixView.frame.origin.y;
    [self addStixToStixView:stixStringID atLocation:locationInStixView];
}

-(void)didDropStix:(UIImageView *)badge ofType:(NSString *)stixStringID {
    // delegate function for CarouselView 
    CGPoint location = badge.center;
    NSLog(@"DidDropStix: location %f %f", location.x, location.y);
    [self.carouselView resetBadgeLocations];
    if (!didAddStixToStixView) {
        [self didDropStixByDrag:stixStringID atLocation:location];
    }
}

-(void)addStixToStixView:(NSString*)stixStringID atLocation:(CGPoint)location {
    [stixView setInteractionAllowed:YES];
    [stixView populateWithStixForManipulation:stixStringID withCount:1 atLocationX:location.x andLocationY:location.y /*andScale:1 andRotation:0*/];
    didAddStixToStixView = YES;

    int count = [self.delegate getStixCount:stixStringID];
    if (count == 0) {
        [priceView setText:@"5 Bux"];
    }
    else
        [priceView setText:@""];
}

-(int)getStixCount:(NSString*)stixStringID {
    return [delegate getStixCount:stixStringID];
}

-(int)getStixOrder:(NSString*)stixStringID;
{
    return [delegate getStixOrder:stixStringID];
}

-(void)didStartDrag {
    [self.carouselView carouselTabDismiss:YES];
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
